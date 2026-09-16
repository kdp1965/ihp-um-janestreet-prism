// =======================================================
// PRISM I2C slave (target) Chroma
//
// An I2C target behind an external open-drain buffer on SDA: one PRISM
// output means "pull SDA low" (1 = the buffer drives it low, 0 =
// released), the two line levels come back on ui_in pins.  The bit loop
// is the edge-clocked sampler's (CFG3, section 4p): on every SCL rising
// edge the hardware shifts SDA into comm and counts the edge in count2,
// and while the FSM's flag2 is set (a read in progress) the same sampler
// shifts on SCL falling edges instead, so the outgoing bit on SDA changes
// while SCL is low.  The FSM only acts at byte boundaries: 13 states
// against 25 for the master chroma.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   cond_out[0]     uo_out[2]     SDA pull-low (1 = drive SDA low)
//   prism_in[0]     ui_in[0]      SDA level (the shifter's input)
//   prism_in[1]     ui_in[1]      SCL level (the sampler's clock)
//
// Host side (shard 0, unfractured: it owns both FIFOs):
//   - CONST K3 = the 7-bit address (K3[6:0]; the compare is done after the
//     seventh bit, before R/W arrives), K1 = 0xFF (sent when FIFO B is
//     empty), K0 = 0x00 (clears comm); COMPARE = 7
//   - CFG2: slot 1 = comm == K3 (code 13), slot 2 = flag2 (14), slot 3 =
//     comm[0] (5): CFG2 = 0x5ED0; slot 0 stays in_prev[0] (SDA tracking)
//   - CFG3 = sampler on input 1, rising, shift + count2, flag2 swaps the
//     edge: PRISM_CFG3_SMP_EN | SRC(1) | RISE | SHIFT | CNT2 | INV
//   - FIFO A (own, RX) receives the bytes the master writes; FIFO B
//     (shard 1's, TX mode) holds the bytes the master reads
//   - the host interrupt fires at a STOP and when the master NAKs a read
//     byte (end of a read)
//
// Not handled: clock stretching (never needed: the FSM keeps up), a
// general call, FIFO A full (the push is dropped, the byte still ACKed).
// =======================================================
module chroma_i2c_slave
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;   // SDA on ui_in[0] feeds the shifter
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b0;   // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT2_DEC         = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled (flag2 = read in progress)
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the bytes written to us
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b1;   // OUT_LATCH stores output 19 in flag2
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K0 / K1
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
   localparam [2:0]  UO2_SRC  = PIN_COND0;         // SDA pull-low
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE      = 4'd0;   // track SDA; START = SDA falls while SCL high
   localparam [3:0]  STATE_ADDR_WAIT = 4'd1;   // 7 bits in: ours?
   localparam [3:0]  STATE_ADDR_RW   = 4'd2;   // 8th bit: R/W into flag2
   localparam [3:0]  STATE_ACK1      = 4'd3;   // wait SCL low
   localparam [3:0]  STATE_ACK2      = 4'd4;   // SDA low, wait SCL high
   localparam [3:0]  STATE_ACK3      = 4'd5;   // SDA low, wait SCL low; write: clear comm
   localparam [3:0]  STATE_ACK3R     = 4'd6;   // read: first byte from FIFO B (or 0xFF)
   localparam [3:0]  STATE_DATA_A    = 4'd7;   // receive: START/STOP while SCL high, or 8 bits
   localparam [3:0]  STATE_DATA_B    = 4'd8;   // receive: track SDA while SCL low
   localparam [3:0]  STATE_RESYNC    = 4'd9;   // SDA moved while SCL high: STOP or repeated START
   localparam [3:0]  STATE_TX_WAIT   = 4'd10;  // transmit: 8 bits out
   localparam [3:0]  STATE_MACK1     = 4'd11;  // the master's ACK / NAK at SCL high
   localparam [3:0]  STATE_MACK_ACK  = 4'd12;  // ACKed: next byte at SCL low

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           sda;
   wire           scl;
   wire           count2_cmp;
   wire           shift_zero;
   wire           in_prev0;
   wire           addr_match;
   wire           reading;
   wire           rw_bit;
   wire           fifo_b_empty;
   wire           shift_data;

   assign sda                  = in_data[0];      // SDA level
   assign shift_data           = in_data[7];      // comm MSB: the bit to send
   assign scl                  = in_data[1];      // SCL level
   assign count2_cmp           = in_data[11];     // >= 7 SCL edges since the last clear
   assign shift_zero           = in_data[14];     // shift count at 0 (before the first or after the 8th)
   assign in_prev0             = in_data[16];     // SDA as last captured (tree-fire capture)
   assign addr_match           = in_data[17];     // comm == K3 (slot code 13)
   assign reading              = in_data[18];     // flag2 (slot code 14): a read in progress
   assign rw_bit               = in_data[19];     // comm[0] (slot code 5)
   assign fifo_b_empty         = in_data[26];     // nothing to send

   // =======================================================
   // Outputs
   // =======================================================
   reg            latch_flag;     // OUT_LATCH: flag2 <= flag2_val
   reg            fifo_op;        // OUT_FIFO_WR_RD: push comm into A / pop B into comm
   reg            count2_clear;
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K[ksel]
   reg            ksel0;          // OUT_K_SEL0: 1 = K1 (0xFF), 0 = K0 (0x00)
   reg            flag2_val;      // OUT_FLAG2

   assign out_data[4]          = latch_flag;
   assign out_data[5]          = fifo_op;
   assign out_data[11]         = count2_clear;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
   assign out_data[19]         = flag2_val;
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

      latch_flag     = 1'b0;
      fifo_op        = 1'b0;
      count2_clear   = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      flag2_val      = 1'b0;
      cond_out[0]    = 1'b0;     // SDA released
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      case (curr_state)
      // ---- idle: SDA tracked through in_prev0; START = SDA falls while SCL is high
      STATE_IDLE:
         begin
            if ((sda ^ in_prev0) && scl && !sda)
            begin
               comm_load    = 1'b1;                // comm <= K0 = 0, shift count 0
               count2_clear = 1'b1;
               latch_flag   = 1'b1;                // flag2 <= 0: rising-edge sampling
               next_state   = STATE_ADDR_WAIT;
            end
            else if ((sda ^ in_prev0))
               next_state = STATE_IDLE;            // re-capture in_prev0
         end

      // ---- address: after 7 SCL edges comm = {0, a6..a0}; then the R/W bit
      STATE_ADDR_WAIT:
         begin
            if (count2_cmp && addr_match)
               next_state = STATE_ADDR_RW;
            else if (count2_cmp)
               next_state = STATE_IDLE;            // not for us
         end

      STATE_ADDR_RW:
         begin
            if (shift_zero && rw_bit)
            begin
               latch_flag = 1'b1;                  // flag2 <= 1: a read, falling-edge sampling
               flag2_val  = 1'b1;
               next_state = STATE_ACK1;
            end
            else if (shift_zero)
            begin
               latch_flag = 1'b1;                  // flag2 <= 0: a write
               next_state = STATE_ACK1;
            end
         end

      // ---- our ACK: SDA low through the ninth clock
      STATE_ACK1:
         begin
            if (!scl)
               next_state = STATE_ACK2;
         end

      STATE_ACK2:
         begin
            cond_out[0] = 1'b1;
            if (scl)
               next_state = STATE_ACK3;
         end

      STATE_ACK3:
         begin
            cond_out[0] = 1'b1;
            if (!scl && reading)
               next_state = STATE_ACK3R;
            else if (!scl)
            begin
               comm_load    = 1'b1;                // write: comm <= 0, shift count 0
               count2_clear = 1'b1;                // and the edge count
               next_state   = STATE_DATA_A;
            end
         end

      STATE_ACK3R:
         begin
            cond_out[0] = 1'b1;
            if (!fifo_b_empty)
            begin
               fifo_op      = 1'b1;                // comm <= FIFO B
               push_pop     = 1'b1;
               count2_clear = 1'b1;
               next_state   = STATE_TX_WAIT;
            end
            else
            begin
               comm_load    = 1'b1;                // comm <= K1 = 0xFF
               ksel0        = 1'b1;
               count2_clear = 1'b1;
               next_state   = STATE_TX_WAIT;
            end
         end

      // ---- receive: the sampler shifts on SCL rising edges; A and B alternate
      // (A: SDA moved while SCL high / 8 bits in; B: track SDA while SCL low)
      STATE_DATA_A:
         begin
            if ((sda ^ in_prev0) && scl)
               next_state = STATE_RESYNC;
            else if (count2_cmp && shift_zero)     // 8 edges since the ACK, 8 shifts
            begin
               fifo_op    = 1'b1;                  // push comm into FIFO A
               next_state = STATE_ACK1;
            end
            else
               next_state = STATE_DATA_B;
         end

      STATE_DATA_B:
         begin
            if ((sda ^ in_prev0) && !scl)
               next_state = STATE_DATA_A;          // re-capture in_prev0
         end

      STATE_RESYNC:
         begin
            if (sda)
            begin
               host_irq   = 1'b1;                  // STOP
               next_state = STATE_IDLE;
            end
            else
            begin
               comm_load    = 1'b1;                // repeated START
               count2_clear = 1'b1;
               latch_flag   = 1'b1;
               next_state   = STATE_ADDR_WAIT;
            end
         end

      // ---- transmit: the sampler shifts on SCL falling edges (flag2 = 1)
      STATE_TX_WAIT:
         begin
            cond_out[0] = 1'b1;                    // bit 0: SDA low
            if (shift_data)
               cond_out[0] = 1'b0;                 // bit 1: released
            if (count2_cmp && shift_zero)          // 8 falling edges, 8 shifts
               next_state = STATE_MACK1;
         end

      STATE_MACK1:
         begin
            if (scl && !sda)
               next_state = STATE_MACK_ACK;        // ACK: more
            else if (scl && sda)
            begin
               latch_flag = 1'b1;                  // NAK: done, flag2 <= 0
               host_irq   = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      STATE_MACK_ACK:
         begin
            if (!scl && !fifo_b_empty)
            begin
               fifo_op      = 1'b1;
               push_pop     = 1'b1;
               count2_clear = 1'b1;
               next_state   = STATE_TX_WAIT;
            end
            else if (!scl)
            begin
               comm_load    = 1'b1;
               ksel0        = 1'b1;
               count2_clear = 1'b1;
               next_state   = STATE_TX_WAIT;
            end
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
