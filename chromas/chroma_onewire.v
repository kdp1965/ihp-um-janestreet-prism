// =======================================================
// PRISM 1-Wire master Chroma
//
// A Dallas / Maxim 1-Wire controller through one external open-drain
// buffer: cond_out[0] = 1 pulls DQ low, the line level comes back on
// ui_in[0] (the shifter input).  Standard-speed timing from two timers:
//
//   count1  = one unit u (PRELOAD + 1 clocks; 5.5 us = PRELOAD 351 at
//             64 MHz), counted in count2 against COMPARE = 12 (66 us):
//             write-0 low, the slot length and the presence sample
//   timer 2 = the reset pulse: PRELOAD2 = 480 us with restart on entry
//             into RESET_LOW (T2_RELOAD | T2_STATE(1), free-running), so
//             its first tick ends the low and its second, 480 us after
//             the release, ends the presence window
//
//   slot   write 1: low 1u, released to 12u        (6 us / 66 us)
//          write 0: low 12u, released 1u           (66 us + 6 us recovery)
//          read:    low 1u, released, DQ sampled at 2u (11 us), to 12u
//   reset  low 480 us, released; DQ sampled at 66 us: low = presence,
//          latched into FLAGS[7] (latched_in[1]); interrupt at 960 us
//
// Bits go LSB first.  Host side (shard 0 unfractured, both FIFOs):
//   - host_in[0] = 1 starts a session: reset + presence, then bytes from
//     FIFO B (shard 1's window, TX) are written as they arrive; while
//     host_in[1] = 1 and FIFO B is empty, bytes are read into FIFO A
//     (own, RX) until host_in[1] drops - the host reads FIFO A's count
//     and stops after the bytes it wants; host_in[0] = 0 ends the session
//   - CONST K0 = 0 (the read shift register's seed)
//   - PRELOAD, COMPARE = 12, PRELOAD2 as above
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   cond_out[0]     uo_out[1]     DQ pull-low (1 = drive DQ low)
//   prism_in[0]     ui_in[0]      DQ level
// =======================================================
module chroma_onewire
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;   // DQ on ui_in[0]
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT2_DEC         = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled (presence into latched_in)
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a pop / K load counts the first bit
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the bytes read
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b1;   // OUT_LATCH stores {cond_out[1], cond_out[0]}
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // reads seed comm from K0
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_COND0;         // DQ pull-low
   localparam [2:0]  UO2_SRC  = PIN_OFF;
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE      = 4'd0;
   localparam [3:0]  STATE_RESET_LOW = 4'd1;   // DQ low until timer 2 ticks (480 us); T2_STATE = 1
   localparam [3:0]  STATE_PRES_WAIT = 4'd2;   // released; sample presence at 12u
   localparam [3:0]  STATE_PRES_END  = 4'd3;   // wait for timer 2's second tick
   localparam [3:0]  STATE_LOOP_A    = 4'd4;   // write a byte, or read one; else ...
   localparam [3:0]  STATE_LOOP_B    = 4'd5;   // ... session over?  (alternates with A)
   localparam [3:0]  STATE_BIT_DISP  = 4'd6;   // write: which slot for this bit
   localparam [3:0]  STATE_W1_LOW    = 4'd7;   // write 1: low 1u
   localparam [3:0]  STATE_W0_LOW    = 4'd8;   // write 0: low 12u
   localparam [3:0]  STATE_W_REC     = 4'd9;   // write 0: released 1u
   localparam [3:0]  STATE_W_REST    = 4'd10;  // write 1: released to 12u
   localparam [3:0]  STATE_BIT_END   = 4'd11;  // next bit or byte done
   localparam [3:0]  STATE_RD_LOW    = 4'd12;  // read: low 1u
   localparam [3:0]  STATE_RD_REL    = 4'd13;  // read: released 1u, then sample (shift)
   localparam [3:0]  STATE_RD_REST   = 4'd14;  // read: to 12u, next bit
   localparam [3:0]  STATE_RD_LAST   = 4'd15;  // read: to 12u, byte into FIFO A

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           dq;
   wire           shift_data;
   wire           host0;
   wire           host1;
   wire           count1_zero;
   wire           count2_cmp;
   wire           shift_zero;
   wire           fifo_b_empty;
   wire           t2_tick;

   assign dq                   = in_data[0];      // DQ level
   assign shift_data           = in_data[7];      // comm LSB: the bit to write
   assign host0                = in_data[8];      // session
   assign host1                = in_data[9];      // read while set
   assign count1_zero          = in_data[10];     // a unit elapsed
   assign count2_cmp           = in_data[11];     // 12 units
   assign shift_zero           = in_data[14];     // the last bit of the byte
   assign fifo_b_empty         = in_data[26];
   assign t2_tick              = in_data[28];     // timer 2 (default slot value)

   // =======================================================
   // Outputs
   // =======================================================
   reg            latch_flag;     // OUT_LATCH: presence into latched_in[1]
   reg            fifo_op;
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count2_inc;
   reg            count2_clear;
   reg            host_irq;
   reg            push_pop;
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K0

   assign out_data[4]          = latch_flag;
   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[8]          = shift_en;
   assign out_data[9]          = count2_inc;
   assign out_data[11]         = count2_clear;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
   assign out_data[16]         = comm_load;
   // other out_data bits unused by this chroma (18, 20 = K select 0 -> K0)

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 4'h0;
      else
         curr_state <= fsm_enable ? next_state : 4'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state     = curr_state;

      latch_flag     = 1'b0;
      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      count2_inc     = 1'b0;
      count2_clear   = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      comm_load      = 1'b0;
      cond_out[0]    = 1'b0;     // DQ released
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:
         begin
            if (host0)
               next_state = STATE_RESET_LOW;       // timer 2 restarts on this entry
         end

      // ---- reset: low until timer 2 ticks, release, sample presence at 12u
      STATE_RESET_LOW:
         begin
            cond_out[0] = 1'b1;
            if (t2_tick)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_PRES_WAIT;
            end
         end

      STATE_PRES_WAIT:
         begin
            cond_out[1] = 1'b0;                    // presence = DQ low ...
            if (!dq)
               cond_out[1] = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && count2_cmp)
            begin
               latch_flag = 1'b1;                  // ... latched here into latched_in[1]
               next_state = STATE_PRES_END;
            end
            else if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_PRES_WAIT;
            end
         end

      STATE_PRES_END:
         begin
            if (t2_tick)                           // 480 us after the release
            begin
               host_irq   = 1'b1;
               next_state = STATE_LOOP_A;
            end
         end

      // ---- session loop: A and B alternate (A falls through to B)
      STATE_LOOP_A:
         begin
            if (!fifo_b_empty)                     // a byte to write
            begin
               fifo_op    = 1'b1;
               push_pop   = 1'b1;
               next_state = STATE_BIT_DISP;
            end
            else if (host1)                        // a byte to read
            begin
               comm_load    = 1'b1;                // comm <= K0, first bit counted
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_RD_LOW;
            end
            else
               next_state = STATE_LOOP_B;          // INC: B loops back here
         end

      STATE_LOOP_B:
         begin
            if (!host0)
               next_state = STATE_IDLE;            // session over
         end

      // ---- write slots
      STATE_BIT_DISP:
         begin
            if (shift_data)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_W1_LOW;
            end
            else if (!shift_data)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_W0_LOW;
            end
         end

      STATE_W1_LOW:                                // 1: low for one unit
         begin
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_W_REST;
            end
         end

      STATE_W0_LOW:                                // 0: low for 12 units
         begin
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && count2_cmp)
            begin
               count1_load = 1'b1;
               next_state  = STATE_W_REC;
            end
            else if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_W0_LOW;
            end
         end

      STATE_W_REC:                                 // recovery: released one unit
         begin
            count1_dec = 1'b1;
            if (count1_zero)
               next_state = STATE_BIT_END;
         end

      STATE_W_REST:                                // released to the end of the slot
         begin
            count1_dec = 1'b1;
            if (count1_zero && count2_cmp)
               next_state = STATE_BIT_END;
            else if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_W_REST;
            end
         end

      STATE_BIT_END:
         begin
            if (shift_zero)                        // that was bit 7
               next_state = STATE_LOOP_A;
            else if (!shift_zero)
            begin
               shift_en   = 1'b1;                  // next bit
               next_state = STATE_BIT_DISP;
            end
         end

      // ---- read slots: low 1u, released, sample at 2u, to 12u
      STATE_RD_LOW:
         begin
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RD_REL;
            end
         end

      STATE_RD_REL:
         begin
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)         // bit 7: the byte completes with this shift
            begin
               shift_en    = 1'b1;
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RD_LAST;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;                 // DQ into comm
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RD_REST;
            end
         end

      STATE_RD_REST:
         begin
            count1_dec = 1'b1;
            if (count1_zero && count2_cmp)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_RD_LOW;
            end
            else if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RD_REST;
            end
         end

      STATE_RD_LAST:
         begin
            count1_dec = 1'b1;
            if (count1_zero && count2_cmp)
            begin
               fifo_op    = 1'b1;                  // the byte into FIFO A
               next_state = STATE_LOOP_A;
            end
            else if (count1_zero)
            begin
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RD_LAST;
            end
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
