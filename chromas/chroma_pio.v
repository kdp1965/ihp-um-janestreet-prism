// =======================================================
// PRISM PIO-style multi-bit shift Chroma
//
// Exercises the multi-bit comm shift (CFG0[2], section 4r): every
// OUT_SHIFT moves {OUT_K_SEL1, OUT_K_SEL0} + 1 bits through comm.  Both
// modes start on a trigger edge of ui_in[0] (channel 0, e.g. a SPI chip
// select), rising with host_in[0] = 0 or falling with host_in[0] = 1,
// detected by the in_prev[0] edge capture; host_in[1] picks the mode.
//
//   host_in[1] = 0: 4-channel logic analyser.  The edge-clocked sampler
//     (host-configured: input 4 = the sample clock, shift + count2) takes
//     ui_in[3:0] four bits at a time, MSB first, so two samples make a
//     byte; after two edges (COMPARE = 2) the FSM pushes comm into FIFO A.
//     The capture runs from the trigger until FIFO A is full (16 bytes,
//     or 2 KB with the SRAM FIFO), raises the host interrupt and re-arms.
//   host_in[1] = 1: 2-lane waveform generator.  From the trigger, each
//     byte popped from FIFO B is played as four bit pairs, one per count1
//     period: uo_out[1] and uo_out[2] show comm[7] and comm[6] through
//     COMM_PINS, and a 2-bit shift brings the next pair up.  comm_load_one
//     makes the pop count as the first pair, so shift_term marks the last
//     one.  When FIFO B is empty the FSM interrupts and re-arms.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[0]     ui_in[0]      trigger (and logic analyser channel 0)
//   prism_in[3:0]   ui_in[3:0]    logic analyser channels
//   prism_in[4]     ui_in[4]      sample clock (sampler source)
//   shift lane      uo_out[1]     waveform lane 1 (comm[7])
//   shift lane      uo_out[2]     waveform lane 0 (comm[6])
//
// Host: CFG3 = sampler on input 4, rising, shift + count2; COMPARE = 2;
// COMM_PINS = uo_out[1] <- bit 7, uo_out[2] <- bit 6; PRELOAD = the pair
// period - 1; FIFO B (shard 1's window) TX; host_in = {mode, falling}.
// =======================================================
module chroma_pio
(
   input  wire          clk,
   input  wire          rst_n,
   input  wire          fsm_enable,
   input  wire [31:0]   in_data,       // Inputs to the PRISM
   output wire [20:0]   out_data,      // FSM outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,      // CFG0 for this chroma
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects (see prism_periph.v)
);

   // =======================================================
   // Configuration
   // =======================================================
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;   // pins 0..3 are the four shift inputs
   localparam [0:0]  MSHIFT_EN          = 1'b1;   // multi-bit comm shift
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b0;   // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT2_DEC         = 1'b0;
   localparam [0:0]  LATCH2             = 1'b0;
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a pop counts as the first pair
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX (the samples)
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b0;
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_SHIFT;         // lane: comm bit per COMM_PINS
   localparam [2:0]  UO2_SRC  = PIN_SHIFT;
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [2:0]  STATE_IDLE    = 3'd0;   // track ui_in[0]; the selected edge triggers
   localparam [2:0]  STATE_TRIG    = 3'd1;   // triggered: analyser or generator
   localparam [2:0]  STATE_LA_WAIT = 3'd2;   // sampler shifts 4 bits per edge; 2 edges -> push
   localparam [2:0]  STATE_WG_POP  = 3'd3;   // next byte from FIFO B
   localparam [2:0]  STATE_WG_OUT  = 3'd4;   // a pair per count1 period, 2-bit shifts

   reg   [2:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           trig;
   wire           host0;
   wire           host1;
   wire           count1_zero;
   wire           count2_cmp;
   wire           shift_zero;
   wire           in_prev0;
   wire           fifo_a_full;
   wire           fifo_b_empty;

   assign trig                 = in_data[0];      // trigger input (channel 0)
   assign host0                = in_data[8];      // trigger edge: 0 = rising, 1 = falling
   assign host1                = in_data[9];      // 0 = logic analyser, 1 = waveform generator
   assign count1_zero          = in_data[10];
   assign count2_cmp           = in_data[11];     // 2 sample edges
   assign shift_zero           = in_data[14];     // shift count back at 0: the last pair
   assign in_prev0             = in_data[16];     // ui_in[0] as last captured
   assign fifo_a_full          = in_data[21];     // capture buffer full
   assign fifo_b_empty         = in_data[26];

   // =======================================================
   // Outputs
   // =======================================================
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count2_clear;
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B
   reg            ksel0;          // OUT_K_SEL0 / bits per shift - 1, bit 0
   reg            ksel1;          // OUT_K_SEL1 / bits per shift - 1, bit 1

   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[8]          = shift_en;
   assign out_data[11]         = count2_clear;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
   assign out_data[18]         = ksel0;
   assign out_data[20]         = ksel1;
   // other out_data bits unused by this chroma

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 3'h0;
      else
         curr_state <= fsm_enable ? next_state : 3'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state     = curr_state;

      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      count2_clear   = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      ksel0          = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      // ---- armed: ui_in[0] tracked through in_prev0; the edge in the
      // direction host_in[0] names (0 rising, 1 falling) triggers
      STATE_IDLE:
         begin
            if ((trig ^ in_prev0) && (trig ^ host0))
               next_state = STATE_TRIG;
            else if (trig ^ in_prev0)
               next_state = STATE_IDLE;            // re-capture in_prev0
         end

      STATE_TRIG:
         begin
            if (host1)
               next_state = STATE_WG_POP;
            else if (!host1)                       // explicit: an `else` to the next state would compile
            begin                                  // to INC and make LA_WAIT loop back here
               count2_clear = 1'b1;                // samples counted from here
               next_state   = STATE_LA_WAIT;
            end
         end

      // ---- logic analyser: 4 bits per sample edge (the sampler shifts),
      // until the capture FIFO is full
      STATE_LA_WAIT:
         begin
            ksel0 = 1'b1;                          // 4 bits per shift
            ksel1 = 1'b1;
            if (fifo_a_full)
            begin
               host_irq   = 1'b1;                  // capture complete; re-arm
               next_state = STATE_IDLE;
            end
            else if (count2_cmp)
            begin
               fifo_op      = 1'b1;                // two samples: push the byte
               count2_clear = 1'b1;
               next_state   = STATE_LA_WAIT;
            end
         end

      // ---- waveform generator: 2 bits per pair, until FIFO B is empty
      STATE_WG_POP:
         begin
            ksel0 = 1'b1;                          // the pop counts one pair
            if (!fifo_b_empty)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_WG_OUT;
            end
            else
            begin
               host_irq   = 1'b1;                  // played out; re-arm
               next_state = STATE_IDLE;
            end
         end

      STATE_WG_OUT:
         begin
            ksel0      = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)         // the last pair has been shown
               next_state = STATE_WG_POP;
            else if (count1_zero)
            begin
               shift_en    = 1'b1;                 // next pair
               count1_load = 1'b1;
               next_state  = STATE_WG_OUT;
            end
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
