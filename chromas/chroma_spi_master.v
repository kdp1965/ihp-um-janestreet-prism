// =======================================================
// PRISM SPI master Chroma, single or quad lane (multi-bit shift)
//
// A mode-0 SPI controller for a board with external tri-state buffers on
// the four IO lanes: OE = 1 makes the buffers drive IO0..IO3 from the
// comm lanes, OE = 0 releases them for the slave, and the lane levels
// come back on ui_in.  The multi-bit comm shift (CFG0[2], section 4r)
// moves one bit (single lane) or four (quad) per SCLK; the width is a
// per-state constant on {OUT_K_SEL1, OUT_K_SEL0}, so there is one set
// of clock states per width and host_in[1] chooses between them for
// every byte.  Full duplex in single mode (every byte sent brings one
// back), half duplex in quad mode.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[1]     SCLK (idle low, mode 0)
//   cond_out[0]     uo_out[2]     CS_N (idle high)
//   pin_out[1]      uo_out[3]     OE: 1 = drive IO0..IO3 from the lanes
//   shift lanes     uo_out[7:4]   IO0..IO3 drive (comm bits per COMM_PINS)
//   prism_in[4:1]   ui_in[4:1]    IO0..IO3 levels (IO1 = MISO in single mode)
//
// Host side (shard 0, unfractured: it owns both FIFOs):
//   - FIFO B (shard 1's window, TX mode) = the bytes to send; FIFO A (own,
//     RX) = the bytes received: all of them in single mode, the read
//     phase in quad mode
//   - COMPARE = bytes to read after FIFO B drains (0 = none); the byte
//     sent meanwhile is K0 in single mode (0xFF for a flash), K3 in quad
//     mode (the lanes are released, its value is moot); count2 counts them
//   - host_in[0] = 1 asserts CS and runs: pop and send while FIFO B has
//     bytes, then read COMPARE bytes, then wait; host_in[0] = 0 ends the
//     frame (CS high, host interrupt).  host_in[1] = width of the next
//     byte: 0 single, 1 quad - it may change between bytes of one frame
//   - per width the host also sets CFG0 shift_in_sel (2 = MISO on ui_in[2]
//     for single, 1 = IO0..IO3 on ui_in[4:1] for quad) and COMM_PINS
//     (single: uo_out[4] <- comm[7]; quad: uo_out[4+k] <- comm[4+k])
//   - PRELOAD = half SCLK period - 1 (0 = 32 MHz at 64 MHz)
//
// The pop / K load "counts one" (comm_load_one), so shift_term marks the
// last bit or nibble of a byte in both widths; the shift that ends it is
// taken on the transition into BYTE_END, where comm holds the byte read.
// =======================================================
module chroma_spi_master
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd2;   // single: MISO = IO1 on ui_in[2]; the host sets 1 for quad
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
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a pop / K load counts the first bit or nibble
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the bytes received
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // the read-phase dummy byte from K0 / K3
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;          // SCLK
   localparam [2:0]  UO2_SRC  = PIN_COND0;         // CS_N
   localparam [2:0]  UO3_SRC  = PIN_OUT1;          // OE
   localparam [2:0]  UO4_SRC  = PIN_SHIFT;         // IO0 (comm bit per COMM_PINS)
   localparam [2:0]  UO5_SRC  = PIN_SHIFT;         // IO1
   localparam [2:0]  UO6_SRC  = PIN_SHIFT;         // IO2
   localparam [2:0]  UO7_SRC  = PIN_SHIFT;         // IO3
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE      = 4'd0;   // CS high
   localparam [3:0]  STATE_START     = 4'd1;   // CS low, setup
   localparam [3:0]  STATE_NEXT_A    = 4'd2;   // anything to send?
   localparam [3:0]  STATE_NEXT_B    = 4'd3;   // pop it, by width
   localparam [3:0]  STATE_NEXT2     = 4'd4;   // anything to read, or done?
   localparam [3:0]  STATE_RX_D      = 4'd5;   // dummy byte, by width
   localparam [3:0]  STATE_TX_LOW_S  = 4'd6;   // single lane, SCLK low
   localparam [3:0]  STATE_TX_HIGH_S = 4'd7;   // single lane, SCLK high; shift at the end
   localparam [3:0]  STATE_TX_LOW_Q  = 4'd8;   // quad, SCLK low
   localparam [3:0]  STATE_TX_HIGH_Q = 4'd9;   // quad, SCLK high
   localparam [3:0]  STATE_RX_LOW_S  = 4'd10;  // read phases: lanes released
   localparam [3:0]  STATE_RX_HIGH_S = 4'd11;
   localparam [3:0]  STATE_RX_LOW_Q  = 4'd12;
   localparam [3:0]  STATE_RX_HIGH_Q = 4'd13;
   localparam [3:0]  STATE_BYTE_END  = 4'd14;  // push the byte received
   localparam [3:0]  STATE_END       = 4'd15;  // CS hold, then high

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           host0;
   wire           host1;
   wire           count1_zero;
   wire           count2_cmp;
   wire           shift_zero;
   wire           fifo_b_empty;

   assign host0                = in_data[8];      // frame: CS low while set
   assign host1                = in_data[9];      // width of the next byte: 0 single, 1 quad
   assign count1_zero          = in_data[10];     // half period done
   assign count2_cmp           = in_data[11];     // bytes read >= COMPARE
   assign shift_zero           = in_data[14];     // the last bit / nibble of the byte is out
   assign fifo_b_empty         = in_data[26];     // nothing more to send

   // =======================================================
   // Outputs
   // =======================================================
   reg            sclk;           // pin_out[0]
   reg            oe;             // pin_out[1]: drive the lanes
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count2_inc;
   reg            count2_clear;
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B
   reg            comm_load;      // OUT_COMM_LOAD: the dummy byte
   reg            ksel0;          // OUT_K_SEL0: width - 1 bit 0 (and the K index)
   reg            ksel1;          // OUT_K_SEL1

   assign out_data[0]          = sclk;
   assign out_data[1]          = oe;
   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[8]          = shift_en;
   assign out_data[9]          = count2_inc;
   assign out_data[11]         = count2_clear;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
   assign out_data[20]         = ksel1;
   // other out_data bits unused by this chroma

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

      sclk           = 1'b0;
      oe             = 1'b0;
      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      count2_inc     = 1'b0;
      count2_clear   = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;     // CS_N low in every active state ...
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
            cond_out[0] = 1'b1;                    // ... but high here
            if (host0)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = STATE_START;
            end
         end

      STATE_START:                                 // CS setup: half a period
         begin
            count1_dec = 1'b1;
            if (count1_zero)
               next_state = STATE_NEXT_A;
         end

      // ---- between bytes: send, read, or finish
      STATE_NEXT_A:
         begin
            if (fifo_b_empty)
               next_state = STATE_NEXT2;
            else if (!fifo_b_empty)
               next_state = STATE_NEXT_B;
         end

      STATE_NEXT_B:                                // pop, counting the first unit of the width
         begin
            if (host1)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               ksel0       = 1'b1;                 // width 4
               ksel1       = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW_Q;
            end
            else if (!host1)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;                 // width 1
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW_S;
            end
         end

      STATE_NEXT2:
         begin
            if (!count2_cmp)                       // bytes still to read
               next_state = STATE_RX_D;
            else if (!host0)                       // the host ends the frame
            begin
               count1_load = 1'b1;
               next_state  = STATE_END;
            end
         end

      STATE_RX_D:                                  // the dummy byte: K3 (quad) / K0 (single)
         begin
            if (host1)
            begin
               comm_load   = 1'b1;
               ksel0       = 1'b1;
               ksel1       = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW_Q;
            end
            else if (!host1)
            begin
               comm_load   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW_S;
            end
         end

      // ---- single lane, sending (and receiving on MISO)
      STATE_TX_LOW_S:
         begin
            oe         = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TX_HIGH_S;
            end
         end

      STATE_TX_HIGH_S:
         begin
            oe         = 1'b1;
            sclk       = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)         // last bit: shift it in, the byte is complete
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW_S;
            end
         end

      // ---- quad, sending (half duplex: nothing to keep)
      STATE_TX_LOW_Q:
         begin
            oe         = 1'b1;
            ksel0      = 1'b1;
            ksel1      = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TX_HIGH_Q;
            end
         end

      STATE_TX_HIGH_Q:
         begin
            oe         = 1'b1;
            sclk       = 1'b1;
            ksel0      = 1'b1;
            ksel1      = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_NEXT_A;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW_Q;
            end
         end

      // ---- reading: lanes released, sampled at the end of SCLK high
      STATE_RX_LOW_S:
         begin
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RX_HIGH_S;
            end
         end

      STATE_RX_HIGH_S:
         begin
            sclk       = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)
            begin
               shift_en    = 1'b1;
               count2_inc  = 1'b1;                 // one byte read
               count1_load = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW_S;
            end
         end

      STATE_RX_LOW_Q:
         begin
            ksel0      = 1'b1;
            ksel1      = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RX_HIGH_Q;
            end
         end

      STATE_RX_HIGH_Q:
         begin
            sclk       = 1'b1;
            ksel0      = 1'b1;
            ksel1      = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && shift_zero)
            begin
               shift_en    = 1'b1;
               count2_inc  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW_Q;
            end
         end

      STATE_BYTE_END:                              // comm = the byte received
         begin
            fifo_op    = 1'b1;                     // push into FIFO A
            next_state = STATE_NEXT_A;
         end

      STATE_END:                                   // CS hold, then release
         begin
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               host_irq   = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
