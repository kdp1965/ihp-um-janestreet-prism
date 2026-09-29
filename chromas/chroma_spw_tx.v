// =======================================================
// PRISM SpaceWire transmitter Chroma (2026-09-29: 13 states)
//
// The transmit half of a SpaceWire link (ECSS-E-ST-50-12C) on one shard:
// Data-Strobe encoding, the characters with their parity, NULLs while
// there is nothing to send, FCTs on request, data characters from the
// FIFO under flow-control credit, EOP / EEP on request.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   cond_out[0]     uo_out[1]     D
//   cond_out[1]     uo_out[2]     S
//
// Bit clock: count1 counts up and wraps at PRELOAD (= bit period - 1), a
// periodic tick the FSM never touches; every bit lasts exactly one period
// (PRELOAD = 5: 10 Mb/s at 60 MHz, the rate a link starts at).  The
// period cannot be shorter than 5 clocks: the next character is chosen
// inside the last bit of the current one (DO, S1, S3, S4, then the wait).
//
// Data-Strobe: S = D xor C with C toggling every bit, so exactly one of
// the two lines changes per bit.  Every character has an even number of
// bits, so C is a property of the state: S = !D on a character's even
// bits (the parity bit is bit 0), S = D on its odd ones.  D = S = 0 before
// the first bit, whose parity bit 0 moves S.
//
// Characters, all from the 8-bit shifter (LSB first):
//   control  P 1 c0 c1          K3 = 0x03 FCT, K1 = 0x1F ESC, K2 = 0x0B EOP
//                               (0x07 = EEP); NULL = ESC then FCT.  Bit 4
//                               of K1 is not sent: it is the mark "an FCT
//                               follows" that C2 reads as comm[2]
//   data     P 0 d0 .. d7       K0 = 0x00 for P and the flag, then the byte
//                               popped from the FIFO
// Bit 0 of a constant holds a copy of the flag and is sent as the parity
// bit P = crc_ok xor flag: the CRC unit in CRC-8 mode with the polynomial
// 0x80 is a parity accumulator (its register is 0x00 or 0x80), cleared
// after the parity bit and fed every bit after the flag, so crc_ok (CRC =
// CRC_EXPECTED = 0) says the bits of the last character were even.
//
// What is sent next, in this order:
//   1. after an ESC its FCT: a NULL
//   2. an FCT the host asked for: a toggle of host_in[1]
//   3. with credit and a byte in the FIFO: that byte
//   4. with credit, the FIFO empty and a toggle of host_in[0]: EOP (K2),
//      with the host interrupt
//   5. a NULL
//
// Flow control: an FCT received is credit for eight data / EOP / EEP
// characters.  count2 holds the FCTs not used up (credit = count2 >=
// COMPARE = 1), count3 the characters sent on the current one (LIMIT3 = 7:
// the eighth takes the FCT).  Fractured, the receiving shard sets the
// semaphore for every FCT it sees and the sampler adds it to count2 in
// hardware (CFG3: clock input 24 = the semaphore, rising edge, count2 + 1);
// the FSM only clears the semaphore, in every clock, so FCTs two clocks
// apart are all counted and a decrement in the same clock cancels against
// the increment.  Unfractured the host writes COUNT2 while no credit is
// left.  This shard never sets the semaphore the other way.
//
// Host side: PRELOAD = 5; CONST = 0x030B1F00; CRC_POLY = 0x80, CRC_EXPECTED
// = 0; COMPARE = 1; LIMIT3 = 7; CFG1 in_prev0 / 1 <- host_in[0] / [1] (8, 9);
// CFG2 slot 18 = comm[2] (code 7); CFG3 = SMP_EN | SMP_SRC(24) | SMP_RISE |
// SMP_CNT2 when fractured; the FIFO in TX mode (this chroma's CFG0).
// =======================================================
module chroma_spw_tx
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b1;   // pin_out[3] is count3's second command bit
   localparam [0:0]  LATCH2             = 1'b0;
   localparam [0:0]  COUNT_UP           = 1'b1;   // count1 counts up ...
   localparam [0:0]  WRAP_PRELOAD       = 1'b1;   // ... and wraps at PRELOAD: the bit clock
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a pop counts the first bit: shift_term on the eighth
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd1;   // CRC8: with the polynomial 0x80, the parity
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b1;   // the FSM pops
   localparam [0:0]  SEMA_SET_WINS      = 1'b1;   // a set in the clock of a clear shows for one clock: an edge
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b1;   // the parity is over the bits sent
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K[{out20, out18}]
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_COND0;         // D
   localparam [2:0]  UO2_SRC  = PIN_COND1;         // S
   localparam [20:0] PINMUX   = {PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_START     = 4'd0;   // D = S = 0, then the first ESC
   localparam [3:0]  STATE_P         = 4'd1;   // bit 0: the parity bit
   localparam [3:0]  STATE_F         = 4'd2;   // bit 1: the flag
   localparam [3:0]  STATE_C2        = 4'd3;   // control character, bit 2
   localparam [3:0]  STATE_DE        = 4'd4;   // data bits 0, 2, 4, 6
   localparam [3:0]  STATE_DO        = 4'd5;   // data bits 1, 3, 5 (and the way out at 7)
   localparam [3:0]  STATE_S1        = 4'd6;   // last bit of a character: what is next?
   localparam [3:0]  STATE_S3        = 4'd7;
   localparam [3:0]  STATE_S4        = 4'd8;
   localparam [3:0]  STATE_WF        = 4'd9;   // last bit, then an FCT
   localparam [3:0]  STATE_WN        = 4'd10;  // last bit, then an ESC (a NULL)
   localparam [3:0]  STATE_WD        = 4'd11;  // last bit, then a data character
   localparam [3:0]  STATE_WE        = 4'd12;  // last bit, then an EOP

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           shift_data;
   wire           host0;
   wire           host1;
   wire           tick;
   wire           credit;
   wire           shift_term;
   wire           in_prev0;
   wire           in_prev1;
   wire           esc_mark;
   wire           fifo_empty;
   wire           parity_even;
   wire           fct_used;

   assign shift_data           = in_data[7];      // the bit to send
   assign host0                = in_data[8];      // toggles: send an EOP
   assign host1                = in_data[9];      // toggles: send an FCT
   assign tick                 = in_data[10];     // count1_term: the bit clock
   assign credit               = in_data[11];     // count2 >= COMPARE (1): an FCT's credit is left
   assign shift_term           = in_data[14];     // the eighth bit of the byte is out
   assign in_prev0             = in_data[16];     // host_in[0] at the last EOP
   assign in_prev1             = in_data[17];     // host_in[1] at the last FCT
   assign esc_mark             = in_data[18];     // slot comm[2]: at bit 2, bit 4 of the constant (K1's mark)
   assign fifo_empty           = in_data[20];
   assign parity_even          = in_data[22];     // crc_ok: the last character's bits were even
   assign fct_used             = in_data[29];     // count3 >= LIMIT3 (7): the eighth character on this FCT

   // =======================================================
   // Outputs
   // =======================================================
   reg            count3_clr;     // pin_out[3]: count3 command bit 1 (alone: clear)
   reg            fifo_pop;       // OUT_FIFO_WR_RD
   reg            count1_step;    // OUT_COUNT1_INC_DEC: the bit clock runs in every state
   reg            shift_en;       // OUT_SHIFT
   reg            count2_dec;     // an FCT used up
   reg            count3_inc;     // OUT_COUNT3 (alone: + 1)
   reg            crc_clear;      // OUT_CRC_CLEAR: parity from zero
   reg            crc_update;     // OUT_CRC_UPDATE: the bit on the wire into the parity
   reg            host_irq;       // OUT_HOST_INTERRUPT
   reg            sema_clear;     // OUT_SEMA_CLEAR in every clock (unfractured: the FIFO select, 0 at the pop)
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K
   reg            ksel0;          // OUT_K_SEL0
   reg            ksel1;          // OUT_K_SEL1

   assign out_data[3]          = count3_clr;
   assign out_data[5]          = fifo_pop;
   assign out_data[6]          = count1_step;
   assign out_data[8]          = shift_en;
   assign out_data[10]         = count2_dec;
   assign out_data[11]         = count3_inc;
   assign out_data[12]         = crc_clear;
   assign out_data[13]         = crc_update;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = sema_clear;
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

      count3_clr     = 1'b0;
      fifo_pop       = 1'b0;
      count1_step    = 1'b1;
      shift_en       = 1'b0;
      count2_dec     = 1'b0;
      count3_inc     = 1'b0;
      crc_clear      = 1'b0;
      crc_update     = 1'b0;
      host_irq       = 1'b0;
      sema_clear     = 1'b1;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;      // D
      cond_out[1]    = 1'b0;      // S
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_START:                                 // both lines low; the link starts with a NULL
         begin
            if (tick)
            begin
               comm_load   = 1'b1;
               ksel0       = 1'b1;                 // K1: ESC
               crc_clear   = 1'b1;                 // nothing before it: even
               next_state  = STATE_P;
            end
         end

      // ---- the two bits every character starts with
      STATE_P:                                     // bit 0: P = even xor flag (the flag's copy is in comm)
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b1;                    // S = !D
            if (parity_even != shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b0;
            end
            if (tick)
            begin
               shift_en    = 1'b1;
               crc_clear   = 1'b1;                 // the parity of this character starts here
               next_state  = STATE_F;
            end
         end

      STATE_F:                                     // bit 1: the flag
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (tick && shift_data)                // control: two more bits
            begin
               shift_en    = 1'b1;
               next_state  = STATE_C2;
            end
            else if (tick && !shift_data)          // data: the byte
            begin
               fifo_pop    = 1'b1;
               sema_clear  = 1'b0;                 // unfractured this output picks the FIFO: its own
               next_state  = STATE_DE;
            end
         end

      // ---- control character, bit 2; bit 3 is its last
      STATE_C2:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b1;                    // S = !D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b0;
            end
            if (tick && esc_mark)                  // an ESC: its FCT is next, whatever else waits
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_WF;
            end
            else if (tick && !esc_mark)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_S1;
            end
         end

      // ---- data bits
      STATE_DE:                                    // bits 0, 2, 4, 6
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b1;                    // S = !D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b0;
            end
            if (tick)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_DO;
            end
         end

      STATE_DO:                                    // bits 1, 3, 5; bit 7 is the last: straight on
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (shift_term)
               next_state  = STATE_S1;
            else if (tick)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_DE;
            end
         end

      // ---- the last bit of a character is on the lines: choose the next one
      STATE_S1:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (host1 != in_prev1)                 // the FCT the host asked for
               next_state  = STATE_WF;
            else if (!credit)                      // nothing else may go
               next_state  = STATE_WN;
            else
               next_state  = STATE_S3;
         end

      STATE_S3:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (!fifo_empty)
               next_state  = STATE_WD;
            else if (fifo_empty)
               next_state  = STATE_S4;
         end

      STATE_S4:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (host0 != in_prev0)                 // the end of the packet
               next_state  = STATE_WE;
            else if (host0 == in_prev0)
               next_state  = STATE_WN;
         end

      // ---- ... and wait for the bit to end; its value goes into the parity
      STATE_WF:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (tick)
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;
               ksel0       = 1'b1;
               ksel1       = 1'b1;                 // K3: FCT
               next_state  = STATE_P;
            end
         end

      STATE_WN:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;                    // S = D
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (tick)
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;
               ksel0       = 1'b1;                 // K1: ESC
               next_state  = STATE_P;
            end
         end

      STATE_WD:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (tick && fct_used)                  // the eighth character on this FCT
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;                 // K0: P and the flag of a data character
               count2_dec  = 1'b1;
               count3_clr  = 1'b1;
               next_state  = STATE_P;
            end
            else if (tick && !fct_used)
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_P;
            end
         end

      STATE_WE:
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;
            if (shift_data)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (tick && fct_used)
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;
               ksel1       = 1'b1;                 // K2: EOP (or EEP)
               count2_dec  = 1'b1;
               count3_clr  = 1'b1;
               host_irq    = 1'b1;
               next_state  = STATE_P;
            end
            else if (tick && !fct_used)
            begin
               crc_update  = 1'b1;
               comm_load   = 1'b1;
               ksel1       = 1'b1;
               count3_inc  = 1'b1;
               host_irq    = 1'b1;
               next_state  = STATE_P;
            end
         end

      default:
         next_state = STATE_START;
      endcase
   end

endmodule
