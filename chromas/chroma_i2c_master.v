// =======================================================
// PRISM I2C master (controller) Chroma
//
// Drives an I2C bus through two external open-drain (tri-state) buffers:
// each of SCL and SDA has one PRISM output meaning "pull the line low"
// (1 = the buffer drives the line low, 0 = released, so the idle level of
// an unset output releases the bus), and the line levels come back on
// ui_in pins.  Standard-mode timing from count1: every SCL phase lasts
// PRELOAD + 1 clocks (SCL low = 2 phases, SDA changing mid-way; SCL high
// = 1 phase; at 64 MHz PRELOAD = 212 gives ~100 kHz).  No clock
// stretching support, no arbitration.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[1]     SCL pull-low (1 = drive SCL low)
//   cond_out[0]     uo_out[2]     SDA pull-low (1 = drive SDA low)
//   prism_in[0]     ui_in[0]      SDA level (the shifter's input)
//   prism_in[1]     ui_in[1]      SCL level (unused so far: no stretching)
//
// Host side (shard 0, unfractured: it owns both FIFOs):
//   - FIFO B (shard 1's, TX mode: the host writes) = the bytes to send,
//     the first one the address with R/W = 0
//   - CONST K0 = the address byte with R/W = 1 for a read; COMPARE = the
//     number of bytes to read (0 = no read phase); CFG2[3:0] = 14 so that
//     input 16 is flag2 (the "read phase" flag the FSM sets)
//   - host_in[0] = 1 starts a transaction: START, the FIFO B bytes each
//     followed by the slave's ACK; then, if COMPARE != 0, a repeated START
//     (or the first START if FIFO B was empty), K0, and COMPARE bytes read
//     into FIFO A (own, RX mode) with ACK, the last one NAK; STOP; host
//     interrupt.  count2 = the bytes read.  A NAK from the slave aborts
//     with a STOP: the unsent bytes stay in FIFO B (the host's error flag).
//   - the FSM waits in DONE until host_in[0] is cleared.
//
// Configuration (ctrl_reg): comm shifts MSB first with SDA (ui_in[0]) as
// the shifter input, count1 24-bit down counter, FIFO A RX, comm_load_k,
// flag_latch + latch_en (flag2 = read phase).
// =======================================================
module chroma_i2c_master
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
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;   // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b0;   // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;   // comm (8-bit) shifts
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT2_DEC         = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled (stores the read-phase flag)
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the FSM pushes the bytes read
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b1;   // OUT_LATCH stores output 19 in flag2
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K0 (the read address)
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;          // SCL pull-low
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
   localparam [4:0]  STATE_IDLE      = 5'd0;
   localparam [4:0]  STATE_START1    = 5'd1;   // SDA low while SCL high
   localparam [4:0]  STATE_START2    = 5'd2;   // SCL low; fetch the first byte
   localparam [4:0]  STATE_TX_LOW    = 5'd3;   // SCL low, bit on SDA
   localparam [4:0]  STATE_TX_HIGH   = 5'd4;   // SCL high, slave samples
   localparam [4:0]  STATE_TX_FALL   = 5'd5;   // SCL low again, bit held, then shift
   localparam [4:0]  STATE_TX_CHECK  = 5'd6;   // 8 bits sent?
   localparam [4:0]  STATE_ACK_LOW   = 5'd7;   // SDA released for the slave's ACK
   localparam [4:0]  STATE_ACK_HIGH  = 5'd8;   // sample ACK at the end of SCL high
   localparam [4:0]  STATE_ACK_FALL  = 5'd9;   // SCL low; read phase -> receive
   localparam [4:0]  STATE_ACK_NEXT1 = 5'd10;  // more bytes to send?
   localparam [4:0]  STATE_ACK_NEXT2 = 5'd11;  // read phase wanted, else STOP
   localparam [4:0]  STATE_NAK_FALL  = 5'd12;  // slave NAK: SCL low, then STOP
   localparam [4:0]  STATE_RS_LOW    = 5'd13;  // repeated START: SDA up while SCL low
   localparam [4:0]  STATE_RS_HIGH   = 5'd14;  // SCL up, then START1
   localparam [4:0]  STATE_RX_LOW    = 5'd15;  // SCL low, SDA released
   localparam [4:0]  STATE_RX_HIGH   = 5'd16;  // SCL high, sample SDA at the end (shift in)
   localparam [4:0]  STATE_RX_CHECK  = 5'd17;  // 8 bits in? push into FIFO A
   localparam [4:0]  STATE_MACK_LOW  = 5'd18;  // master ACK (NAK on the last byte)
   localparam [4:0]  STATE_MACK_HIGH = 5'd19;
   localparam [4:0]  STATE_MACK_FALL = 5'd20;  // SCL low, ACK held; next byte or STOP
   localparam [4:0]  STATE_STOP_LOW  = 5'd21;  // SDA low while SCL low
   localparam [4:0]  STATE_STOP_HIGH = 5'd22;  // SCL released
   localparam [4:0]  STATE_STOP_REL  = 5'd23;  // SDA released: STOP
   localparam [4:0]  STATE_DONE      = 5'd24;  // interrupt raised; wait for host_in[0] = 0

   reg   [4:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           sda_in;
   wire           shift_data;
   wire           host0;
   wire           count1_zero;
   wire           count2_cmp;
   wire           shift_zero;
   wire           read_phase;
   wire           fifo_b_empty;

   assign sda_in               = in_data[0];      // SDA level
   assign shift_data           = in_data[7];      // comm MSB: the bit to send
   assign host0                = in_data[8];      // go
   assign count1_zero          = in_data[10];     // phase timer done
   assign count2_cmp           = in_data[11];     // bytes read >= COMPARE
   assign shift_zero           = in_data[14];     // 8 shifts done
   assign read_phase           = in_data[16];     // flag2 via CFG2 slot code 14
   assign fifo_b_empty         = in_data[26];     // FIFO B empty (nothing more to send)

   // =======================================================
   // Outputs
   // =======================================================
   reg            scl_low;        // pin_out[0]: pull SCL low
   reg            latch_flag;     // OUT_LATCH: store flag2_val in flag2
   reg            fifo_op;        // OUT_FIFO_WR_RD: pop B into comm / push comm into A
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count2_inc;
   reg            count2_clear;
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B (pop), 0 = FIFO A (push)
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K0
   reg            flag2_val;      // OUT_FLAG2: the value latched into flag2

   assign out_data[0]          = scl_low;
   assign out_data[4]          = latch_flag;        // OUT_LATCH
   assign out_data[5]          = fifo_op;           // OUT_FIFO_WR_RD
   assign out_data[6]          = count1_dec;        // OUT_COUNT1_INC_DEC
   assign out_data[7]          = count1_load;       // OUT_COUNT1_CLEAR_LOAD
   assign out_data[8]          = shift_en;          // OUT_SHIFT
   assign out_data[9]          = count2_inc;        // OUT_COUNT2_INC
   assign out_data[11]         = count2_clear;      // OUT_COUNT2_CLEAR
   assign out_data[14]         = host_irq;          // OUT_HOST_INTERRUPT
   assign out_data[15]         = push_pop;          // OUT_FIFO_PUSH_POP
   assign out_data[16]         = comm_load;         // OUT_COMM_LOAD
   assign out_data[19]         = flag2_val;         // OUT_FLAG2
   // other out_data bits unused by this chroma (18, 20 = K select 0 -> K0)

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 5'h0;
      else
         curr_state <= fsm_enable ? next_state : 5'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state     = curr_state;

      scl_low        = 1'b0;
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
      STATE_IDLE:                                  // bus released
         begin
            if (host0)
            begin
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               latch_flag   = 1'b1;                // read phase flag <= 0
               next_state   = STATE_START1;
            end
         end

      // ---- START: SDA falls while SCL is high, then SCL falls
      STATE_START1:
         begin
            cond_out[0] = 1'b1;                    // SDA low
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_START2;
            end
         end

      STATE_START2:
         begin
            cond_out[0] = 1'b1;
            scl_low     = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && !fifo_b_empty)      // the address (or next) byte from FIFO B
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW;
            end
            else if (count1_zero)                  // nothing to write: the read address from K0
            begin
               comm_load   = 1'b1;
               latch_flag  = 1'b1;
               flag2_val   = 1'b1;                 // read phase flag <= 1
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW;
            end
         end

      // ---- transmit one byte, MSB first: low (bit set) / high / low (bit held) per bit
      STATE_TX_LOW:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;                    // bit 0 = SDA low
            if (shift_data)
               cond_out[0] = 1'b0;                 // bit 1 = SDA released
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TX_HIGH;
            end
         end

      STATE_TX_HIGH:
         begin
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TX_FALL;
            end
         end

      STATE_TX_FALL:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;                 // next bit
               count1_load = 1'b1;
               next_state  = STATE_TX_CHECK;
            end
         end

      STATE_TX_CHECK:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (shift_zero)
               next_state = STATE_ACK_LOW;         // 8 bits sent
            else
               next_state = STATE_TX_LOW;
         end

      // ---- the slave's ACK: SDA released, sampled at the end of SCL high
      STATE_ACK_LOW:
         begin
            scl_low    = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_ACK_HIGH;
            end
         end

      STATE_ACK_HIGH:
         begin
            count1_dec = 1'b1;
            if (count1_zero && !sda_in)            // ACK
            begin
               count1_load = 1'b1;
               next_state  = STATE_ACK_FALL;
            end
            else if (count1_zero)                  // NAK: abort with a STOP
            begin
               count1_load = 1'b1;
               next_state  = STATE_NAK_FALL;
            end
         end

      STATE_ACK_FALL:
         begin
            scl_low    = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero && read_phase)         // the read address was ACKed: receive
            begin
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW;
            end
            else if (count1_zero)
               next_state = STATE_ACK_NEXT1;
         end

      STATE_ACK_NEXT1:
         begin
            scl_low = 1'b1;
            if (!fifo_b_empty)                     // next byte to send
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TX_LOW;
            end
            else
               next_state = STATE_ACK_NEXT2;
         end

      STATE_ACK_NEXT2:
         begin
            scl_low     = 1'b1;
            count1_load = 1'b1;
            if (count2_cmp)                        // COMPARE = 0: no read phase
               next_state = STATE_STOP_LOW;
            else
               next_state = STATE_RS_LOW;          // repeated START for the read
         end

      STATE_NAK_FALL:
         begin
            scl_low    = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_STOP_LOW;
            end
         end

      // ---- repeated START: SDA up while SCL low, SCL up, then START1
      STATE_RS_LOW:
         begin
            scl_low    = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RS_HIGH;
            end
         end

      STATE_RS_HIGH:
         begin
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_START1;
            end
         end

      // ---- receive one byte: SDA released, sampled at the end of SCL high
      STATE_RX_LOW:
         begin
            scl_low    = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RX_HIGH;
            end
         end

      STATE_RX_HIGH:
         begin
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;                 // shift SDA in
               count1_load = 1'b1;
               next_state  = STATE_RX_CHECK;
            end
         end

      STATE_RX_CHECK:
         begin
            scl_low = 1'b1;
            if (shift_zero)                        // a whole byte: into FIFO A
            begin
               fifo_op    = 1'b1;
               count2_inc = 1'b1;
               next_state = STATE_MACK_LOW;
            end
            else
               next_state = STATE_RX_LOW;
         end

      // ---- the master's ACK (SDA low), NAK (released) after the last byte
      STATE_MACK_LOW:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;
            if (count2_cmp)
               cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_MACK_HIGH;
            end
         end

      STATE_MACK_HIGH:
         begin
            cond_out[0] = 1'b1;
            if (count2_cmp)
               cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_MACK_FALL;
            end
         end

      STATE_MACK_FALL:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;
            if (count2_cmp)
               cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero && count2_cmp)         // that was the last byte
            begin
               count1_load = 1'b1;
               next_state  = STATE_STOP_LOW;
            end
            else if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RX_LOW;
            end
         end

      // ---- STOP: SDA low, SCL up, SDA up
      STATE_STOP_LOW:
         begin
            scl_low     = 1'b1;
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_STOP_HIGH;
            end
         end

      STATE_STOP_HIGH:
         begin
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_STOP_REL;
            end
         end

      STATE_STOP_REL:
         begin
            count1_dec = 1'b1;
            if (count1_zero)
            begin
               host_irq   = 1'b1;                  // transaction done
               next_state = STATE_DONE;
            end
         end

      STATE_DONE:
         begin
            if (!host0)
               next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
