// =======================================================
// PRISM SpaceWire receiver Chroma (2026-09-29: 15 states)
//
// The receive half of a SpaceWire link (ECSS-E-ST-50-12C) on one shard:
// the bits of a Data-Strobe pair, the characters and their parity, data
// into the FIFO, an FCT as a semaphore for the transmitting shard, the
// ends of packets, the link errors.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[1]     ui_in[1]      D
//   prism_in[2]     ui_in[2]      S
//
// Bits: the sampler is clocked by D xor S (CFG3 edge code 3: input 1 xor
// input 2, either edge); on every bit it sets "edge pending", clears
// count1 and adds one to count2.  The FSM shifts D in, which clears the
// flag.  count1 counts up and wraps at PRELOAD: its terminal count is "no
// bit for PRELOAD + 1 clocks", the disconnect time-out (850 ns: PRELOAD =
// 50 at 60 MHz).  count2 counts the bits of a data character (COMPARE = 8).
//
// The link (the passive end of it): a link starts on a quiet line, so its
// first bit is the first bit of a NULL.  QUIET waits for the time-out
// whatever the line does, FIRST for that first bit; from then on
// pin_out[1] is up, which the transmitting shard reads as its input 26 and
// starts to send.  Any error takes the receiver back to QUIET: the
// transmitter stops, the other end sees the silence and restarts, and the
// link forms again without the host.
//
// Characters (LSB first, the newest bit is comm[7]):
//   P 0 d0 .. d7   data: the byte goes to the FIFO
//   P 1 0 0        FCT: the semaphore for the other shard (its credit)
//   P 1 0 1 / 1 0  EOP / EEP: a mark in the FIFO, host interrupt
//   P 1 1 1        ESC: the next character must be an FCT (a NULL)
// Parity: the CRC unit with the polynomial 0x80 is a parity accumulator
// (chroma_spw_tx.v); it takes every bit, is checked after the flag (odd:
// CRC_EXPECTED = 0x80) and cleared there.
//
// The FIFO is 8 bits wide and a packet's end is a ninth value, so the
// stream is escaped with K3 (0xF0 here):
//   data other than K3   the byte
//   data equal to K3     K3, K3
//   EOP                  K3, K0 (0x00)
//   EEP                  K3, K2 (0x01)
// The latch FIFO has one write bus: two pushes of different values must be
// three clocks apart (prism_fifo.v).  Both bytes of an escape go the same
// way, the first push, two clocks in MARK and MARK2, the second in PUSH2.
//
// Errors: wrong parity, anything but an FCT after an ESC (time-codes are
// not taken), no bit for the time-out.  Each one interrupts the host and
// adds one to count3, the number of links lost.
//
// Host side: CFG2 = 15 | 12 << 4 | 11 << 8 | 13 << 12 (inputs 16-19: edge
// pending, comm[7], comm[6], comm == K3); CFG3 = SMP_EN | SMP_SRC(1) | edge
// code 3 | SMP_TIMER | SMP_CNT2; CONST = 0xF0010000 (K3 escape, K2 EEP, K0
// EOP); CRC_POLY = 0x80, CRC_EXPECTED = 0x80; PRELOAD = 50; COMPARE = 8.
// The bit period must be 4 clocks or more.
// =======================================================
module chroma_spw_rx
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd1;   // D on ui_in[1]
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b1;   // the sampler's timer action clears count1
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first: the newest bit enters at comm[7]
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled: the two flags
   localparam [0:0]  COUNT_UP           = 1'b1;   // count1 counts up from the last bit ...
   localparam [0:0]  WRAP_PRELOAD       = 1'b1;   // ... to PRELOAD: the time-out
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;   // a comm load sets its shift count to 0
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd1;   // CRC8: with the polynomial 0x80, the parity
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // the FSM pushes
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;   // the parity is over the bits shifted in
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b1;   // OUT_LATCH stores {cond_out[1], cond_out[0]}: after an ESC, EEP
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K[{out20, out18}]
   localparam [0:0]  FIFO_SRAM          = 1'b0;   // the host may OR CFG_FIFO_SRAM in
   localparam [2:0]  PIN_OFF   = 3'd7;
   localparam [20:0] PINMUX    = {7{PIN_OFF}};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_QUIET     = 4'd0;   // no link: wait until the line has been quiet
   localparam [3:0]  STATE_FIRST     = 4'd1;   // the first bit of a link
   localparam [3:0]  STATE_P         = 4'd2;   // bit 0: the parity bit
   localparam [3:0]  STATE_F         = 4'd3;   // bit 1: the flag
   localparam [3:0]  STATE_CHK       = 4'd4;   // parity, and which kind
   localparam [3:0]  STATE_DCHK      = 4'd5;   // data: eight bits?
   localparam [3:0]  STATE_MARK      = 4'd6;   // an escape's first byte is in: two clocks ...
   localparam [3:0]  STATE_MARK2     = 4'd7;
   localparam [3:0]  STATE_PUSH2     = 4'd8;   // ... then its second byte
   localparam [3:0]  STATE_D         = 4'd9;   // a data bit
   localparam [3:0]  STATE_C0        = 4'd10;  // control bit 0
   localparam [3:0]  STATE_C1        = 4'd11;  // control bit 1
   localparam [3:0]  STATE_CDEC      = 4'd12;  // an FCT?
   localparam [3:0]  STATE_CDEC2     = 4'd13;  // an ESC?  after one, an error
   localparam [3:0]  STATE_CDEC3     = 4'd14;  // the end of a packet: the escape value

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           timeout;
   wire           after_esc;
   wire           is_eep;
   wire           byte_in;
   wire           pending;
   wire           c1;
   wire           c0;
   wire           is_escape;
   wire           parity_odd;

   assign timeout              = in_data[10];     // count1_term: no bit for PRELOAD + 1 clocks
   assign after_esc            = in_data[13];     // flag (cond_out[1]): the character before was an ESC
   assign is_eep               = in_data[12];     // flag (cond_out[0]): the mark is an EEP
   assign byte_in              = in_data[11];     // count2 >= COMPARE (8): the bits of a data character
   assign pending              = in_data[16];     // slot: the sampler saw a bit
   assign c1                   = in_data[17];     // slot comm[7]: the newest bit (the flag, control bit 1)
   assign c0                   = in_data[18];     // slot comm[6]: the one before (control bit 0)
   assign is_escape            = in_data[19];     // slot: comm == K3
   assign parity_odd           = in_data[22];     // crc_ok (CRC_EXPECTED = 0x80)

   // =======================================================
   // Outputs
   // =======================================================
   reg            link;           // pin_out[1]: a link is coming in (the other shard's input 26)
   reg            latch;          // OUT_LATCH: store the flags
   reg            fifo_push;      // OUT_FIFO_WR_RD
   reg            count1_step;    // OUT_COUNT1_INC_DEC: the time-out counts in every state
   reg            shift_en;       // OUT_SHIFT (it clears "edge pending")
   reg            count2_inc;     // with the decrement: clear count2
   reg            count2_dec;
   reg            count3_inc;     // OUT_COUNT3: one more link lost
   reg            crc_clear;      // OUT_CRC_CLEAR
   reg            crc_update;     // OUT_CRC_UPDATE: the bit shifted in
   reg            host_irq;       // OUT_HOST_INTERRUPT
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K
   reg            ksel0;          // OUT_K_SEL0
   reg            sema_set;       // OUT_SEMA_SET: an FCT for the transmitter
   reg            ksel1;          // OUT_K_SEL1

   assign out_data[1]          = link;
   assign out_data[4]          = latch;
   assign out_data[5]          = fifo_push;
   assign out_data[6]          = count1_step;
   assign out_data[8]          = shift_en;
   assign out_data[9]          = count2_inc;
   assign out_data[10]         = count2_dec;
   assign out_data[11]         = count3_inc;
   assign out_data[12]         = crc_clear;
   assign out_data[13]         = crc_update;
   assign out_data[14]         = host_irq;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
   assign out_data[19]         = sema_set;
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

      link           = 1'b1;
      latch          = 1'b0;
      fifo_push      = 1'b0;
      count1_step    = 1'b1;
      shift_en       = 1'b0;
      count2_inc     = 1'b0;
      count2_dec     = 1'b0;
      count3_inc     = 1'b0;
      crc_clear      = 1'b0;
      crc_update     = 1'b0;
      host_irq       = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      sema_set       = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;      // the "EEP" flag OUT_LATCH stores
      cond_out[1]    = 1'b0;      // the "after an ESC" flag
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_QUIET:                                 // whatever is on the line is not ours: wait for silence
         begin
            link        = 1'b0;
            if (pending)                           // (the latch clears the flag, and the two flags of the FSM)
            begin
               latch       = 1'b1;
               next_state  = STATE_QUIET;
            end
            else if (timeout)
               next_state  = STATE_FIRST;
         end

      STATE_FIRST:                                 // both lines quiet: the first bit of a NULL; parity and flags
         begin                                     // from zero, whatever the link before left in them
            link        = 1'b0;
            crc_clear   = 1'b1;
            latch       = 1'b1;
            if (pending)
            begin
               crc_clear   = 1'b0;
               latch       = 1'b0;
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_F;
            end
         end

      // ---- the two bits every character starts with
      STATE_P:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_F;
            end
            else if (timeout)                      // the link is gone
            begin
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
         end

      STATE_F:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_CHK;
            end
            else if (timeout)                      // the link is gone
            begin
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
         end

      STATE_CHK:                                   // the flag is c1; the parity up to it must be odd
         begin
            crc_clear   = 1'b1;                    // (else: a data character, its bits counted from zero)
            count2_inc  = 1'b1;
            count2_dec  = 1'b1;
            if (!parity_odd || (after_esc && !c1)) // parity, or data after an ESC
            begin
               crc_clear   = 1'b0;
               count2_inc  = 1'b0;
               count2_dec  = 1'b0;
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
            else if (c1)                           // a control character
            begin
               crc_clear   = 1'b1;
               count2_inc  = 1'b0;
               count2_dec  = 1'b0;
               next_state  = STATE_C0;
            end
            else
               next_state  = STATE_DCHK;
         end

      // ---- data
      STATE_DCHK:
         begin
            fifo_push   = 1'b1;                    // (else: the escape value itself, the first of two)
            if (!byte_in)
            begin
               fifo_push   = 1'b0;
               next_state  = STATE_D;
            end
            else if (byte_in && !is_escape)        // the byte
            begin
               fifo_push   = 1'b1;
               next_state  = STATE_P;
            end
            else
               next_state  = STATE_MARK;
         end

      STATE_MARK:                                  // the FIFO's write bus holds still
         begin
            next_state  = STATE_MARK2;
         end

      STATE_MARK2:
         begin
            next_state  = STATE_PUSH2;
         end

      STATE_PUSH2:                                 // the second byte
         begin
            fifo_push   = 1'b1;
            next_state  = STATE_P;
         end

      STATE_D:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_DCHK;
            end
            else if (timeout)                      // the link is gone
            begin
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
         end

      // ---- control characters
      STATE_C0:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_C1;
            end
            else if (timeout)                      // the link is gone
            begin
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
         end

      STATE_C1:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_CDEC;
            end
            else if (timeout)                      // the link is gone
            begin
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
         end

      STATE_CDEC:                                  // c0 c1: 00 FCT, 01 EOP, 10 EEP, 11 ESC
         begin
            if (!after_esc && !c0 && !c1)          // an FCT: credit for the transmitter
            begin
               sema_set    = 1'b1;
               latch       = 1'b1;
               next_state  = STATE_P;
            end
            else if (!c0 && !c1)                   // the FCT of a NULL (the flags: both 0)
            begin
               latch       = 1'b1;
               next_state  = STATE_P;
            end
            else
               next_state  = STATE_CDEC2;
         end

      STATE_CDEC2:
         begin
            cond_out[1] = 1'b0;                    // "after an ESC" for the next character
            if (c0 && c1)
               cond_out[1] = 1'b1;
            cond_out[0] = 1'b0;                    // "EEP" for the mark
            if (c0)
               cond_out[0] = 1'b1;
            latch       = 1'b1;                    // (else: the end of a packet, the escape value first)
            comm_load   = 1'b1;
            ksel0       = 1'b1;
            ksel1       = 1'b1;                    // K3
            if (after_esc)                         // after an ESC only the FCT is legal
            begin
               latch       = 1'b0;
               comm_load   = 1'b0;
               ksel0       = 1'b0;
               ksel1       = 1'b0;
               link        = 1'b0;
               host_irq    = 1'b1;
               count3_inc  = 1'b1;
               next_state  = STATE_QUIET;
            end
            else if (c0 && c1)                     // an ESC
            begin
               latch       = 1'b1;
               comm_load   = 1'b0;
               ksel0       = 1'b0;
               ksel1       = 1'b0;
               next_state  = STATE_P;
            end
            else
               next_state  = STATE_CDEC3;
         end

      STATE_CDEC3:                                 // the escape value goes in; which end it is comes after it
         begin
            if (is_eep)
            begin
               fifo_push   = 1'b1;
               comm_load   = 1'b1;
               ksel1       = 1'b1;                 // K2: EEP
               host_irq    = 1'b1;
               next_state  = STATE_MARK;
            end
            else if (!is_eep)
            begin
               fifo_push   = 1'b1;
               comm_load   = 1'b1;                 // K0: EOP
               host_irq    = 1'b1;
               next_state  = STATE_MARK;
            end
         end

      default:
         next_state = STATE_QUIET;
      endcase
   end

endmodule
