// =======================================================
// PRISM CAN 2.0A transmitter Chroma (v1, 2026-09-28: 13 states)
//
// Sends one standard data frame from the TX FIFO, with bit-level
// arbitration, hardware bit stuffing, the CRC-15 from the CRC unit and
// the ACK check.  TXD is uo_out[2] = the shifter's output bit through the
// stuff unit (pinmux code 6): 1 = recessive, 0 = dominant, straight to a
// transceiver's TXD.  RXD (the bus) is ui_in[3], shared with chroma_can_rx
// when both run fractured (the board ANDs the two TXDs).
//
// The host packs the frame as a bit stream into the FIFO: {SOF = 0,
// ID[10:4]}, {ID[3:0], RTR, IDE, r0, DLC3}, {DLC[2:0], data...}, i.e. the
// 19 header bits followed by the data bits, MSB first, the last byte
// padded; and writes LIMIT3 = 19 + 8 * DLC - 1 (the bits before the CRC,
// less one: the count is checked before the last bit's step).  A host_in[0]
// toggle (REG_TOGGLE) starts the frame.
//
// Bit clock: count1 counts up and wraps at PRELOAD (= one bit time - 1);
// it is cleared at the start so the first tick ends the SOF, and never
// resynchronised (the transmitter is the bus's clock while it sends).  At
// every tick TXW checks arbitration / bit errors (we sent recessive, the
// bus is dominant -> DONE with F1 = lost) and TXA moves the shifter: a
// plain shift, or at a byte boundary (shift_term) or the end of a field
// (count3 at its limit) the next byte from the FIFO / the CRC / the tail.
// The bit-stuff unit (CFG3[14] | [15], COMPARE = 4) inserts stuff bits in
// hardware: input 31 says one is due at the next move, and TXA then just
// shifts (the unit holds the shifter and sends the complement instead);
// input 30 (holding) lets DELIM / DONE redo a comm load the unit held.
//
// CRC: count3 counts the frame bits against the host's limit; at the
// limit the CRC unit's high byte is loaded into comm (OUT_LOAD_CRC), then
// its low byte at the byte boundary, and count3 counts the CRC bits (limit
// K2 = 14, checked before the last bit's step); the CRC unit is not fed
// while its bits go out.  Then comm <= K1 = 0xFF (recessive), the delimiter, the ACK
// slot (sampled: F0 = acknowledged), and K3 = 11 recessive ticks (ACK
// delimiter, EOF, IFS); the host interrupt ends the frame and FLAGS shows
// F0 (acked) and F1 (lost arbitration or bit error; the FIFO still holds
// the rest of the frame: flush and retry).
//
// Host set-up (see test_can_tx): CFG1 = in_prev1 <- host_in[0] (8 << 4);
// CFG3 = STUFF_EN | STUFF_TX; CONST = {11, 14, 0xFF, 0}; COMPARE = 4;
// PRELOAD = bit - 1; COMM = 0xFF before enabling (the pin follows comm, and
// an idle bus is recessive); LIMIT3 = 19 + 8 * DLC - 1 per frame; CRC_POLY = 0x8B32.
//
// Not in v1: bus-idle detection before starting (the host starts it),
// retransmission, error frames, extended / remote frames.
// =======================================================
module chroma_can_tx
(
   input  wire          clk,
   input  wire          rst_n,
   input  wire          fsm_enable,
   input  wire [31:0]   in_data,       // Inputs to the PRISM
   output wire [20:0]   out_data,      // FSM outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,      // CFG0 for this chroma
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects
);

   // CFG0 (ctrl_reg), one named field per bit group
   localparam [0:0]  FIFO_SRAM      = 1'd0;
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}]
   localparam [0:0]  FLAG_LATCH     = 1'd1;  // OUT_LATCH stores {cond_out[1:0]}: F1 = CRC field / lost, F0 = acked
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;
   localparam [0:0]  CRC_SRC_OUT    = 1'd1;  // CRC over the bit leaving the shifter
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;
   localparam [0:0]  CRC_INIT_ONES  = 1'd0;  // CRC-15 starts from 0
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;
   localparam [0:0]  FIFO_DIR_TX    = 1'd1;  // TX: the host writes, the FSM pops
   localparam [0:0]  CRC_REFLECT    = 1'd0;  // MSB first
   localparam [1:0]  CRC_MODE       = 2'd2;  // 16 bits (the 15-bit polynomial shifted up one)
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;
   localparam [0:0]  COMM_LOAD_ONE  = 1'd1;  // a loaded byte's first bit is on the pin at once
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;
   localparam [0:0]  WRAP_PRELOAD   = 1'd1;  // count1 wraps at PRELOAD: a periodic tick
   localparam [0:0]  COUNT_UP       = 1'd1;
   localparam [0:0]  LATCH2         = 1'd1;  // OUT_LATCH enabled
   localparam [0:0]  COUNT3_EN      = 1'd1;  // pin_out[3] is count3's second command bit
   localparam [0:0]  COUNT32        = 1'd0;
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // comm shifts
   localparam [0:0]  SHIFT_DIR      = 1'd0;  // MSB first
   localparam [0:0]  SHIFT_EN       = 1'd1;
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;
   localparam [0:0]  CLR_NOT_LOAD   = 1'd1;  // OUT_COUNT1_CLEAR_LOAD clears: the SOF starts the bit clock
   localparam [1:0]  SHIFT_IN_SEL   = 2'd3;  // (unused: nothing is shifted in)
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
   localparam [2:0]  UO2_SRC  = PIN_SHIFT;      // TXD = the shifter's bit through the stuff unit
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States (INC legs: TXA -> TXS -> TXS2, POP -> POPB; their targets always exit)
   // =======================================================
   localparam [3:0]  ST_IDLE    = 4'd0;    // a host_in[0] toggle: pop the first byte, start the bit clock
   localparam [3:0]  ST_TXW     = 4'd1;    // one bit: at the tick check the bus against what we sent
   localparam [3:0]  ST_TXA     = 4'd2;    // stuff bit due / a boundary / (INC) a plain shift
   localparam [3:0]  ST_TXS     = 4'd3;    // CRC field: its boundaries and plain bits; else (INC) a data bit
   localparam [3:0]  ST_TXS2    = 4'd4;    // a data bit: shift, CRC, count
   localparam [3:0]  ST_POP     = 4'd5;    // a boundary: end of the frame bits / (INC) next byte
   localparam [3:0]  ST_POPB    = 4'd6;    // the next byte from the FIFO
   localparam [3:0]  ST_POPC    = 4'd7;    // CRC field boundary: its low byte, or the delimiter
   localparam [3:0]  ST_DELIM   = 4'd8;    // the CRC delimiter (comm = 0xFF)
   localparam [3:0]  ST_ACKS    = 4'd9;    // the ACK slot: sample the bus
   localparam [3:0]  ST_TAIL    = 4'd10;   // ACK delimiter, EOF, IFS: 11 ticks
   localparam [3:0]  ST_TAILC   = 4'd11;
   localparam [3:0]  ST_DONE    = 4'd12;   // interrupt

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire rxd         = in_data[3];    // the bus (1 = recessive)
   wire shift_data  = in_data[7];    // the bit on the pin (a stuff bit while the unit holds)
   wire host0       = in_data[8];    // start toggle
   wire count1_term = in_data[10];   // the bit clock's tick
   wire f1          = in_data[13];   // CRC field (or lost, at the end)
   wire shift_term  = in_data[14];   // a byte boundary
   wire in_prev1    = in_data[17];   // host_in[0] at the last start
   wire count3_cmp  = in_data[29];   // count3 >= limit
   wire hold        = in_data[30];   // the stuff unit is holding a comm load
   wire due         = in_data[31];   // the next move would be a stuff bit

   // =======================================================
   // Outputs
   // =======================================================
   reg count3_hi;              // pin_out[3]: count3 command bit 1
   reg latch;                  // OUT_LATCH: flags <= {cond_out[1:0]}
   reg fifo_pop;               // OUT_FIFO_WR_RD (TX: pop into comm)
   reg count1_step;            // OUT_COUNT1_INC_DEC (the bit clock runs in every state)
   reg count1_clear;           // OUT_COUNT1_CLEAR_LOAD
   reg shift;                  // OUT_SHIFT
   reg count3_lo;              // OUT_COUNT3: command bit 0
   reg crc_clear;              // OUT_CRC_CLEAR (also restarts the stuff unit's run)
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD (K[{ksel1, ksel0}])
   reg load_crc;               // OUT_LOAD_CRC: comm <= the next CRC byte
   reg ksel0;                  // OUT_K_SEL0
   reg ksel1;                  // OUT_K_SEL1

   assign out_data[3]  = count3_hi;
   assign out_data[4]  = latch;
   assign out_data[5]  = fifo_pop;
   assign out_data[6]  = count1_step;
   assign out_data[7]  = count1_clear;
   assign out_data[8]  = shift;
   assign out_data[11] = count3_lo;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[14] = host_irq;
   assign out_data[16] = comm_load;
   assign out_data[17] = load_crc;
   assign out_data[18] = ksel0;
   assign out_data[20] = ksel1;

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
      next_state   = curr_state;

      count3_hi    = 1'b0;
      latch        = 1'b0;
      fifo_pop     = 1'b0;
      count1_step  = 1'b1;
      count1_clear = 1'b0;
      shift        = 1'b0;
      count3_lo    = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      load_crc     = 1'b0;
      ksel0        = 1'b0;
      ksel1        = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_IDLE:                                // start: the first byte (SOF on the pin), bit clock from 0
         begin
            if (host0 ^ in_prev1)
            begin
               fifo_pop     = 1'b1;
               count1_clear = 1'b1;
               count3_hi    = 1'b1;           // count3 <= 0 (the tail count of the last frame)
               crc_clear    = 1'b1;
               latch        = 1'b1;           // flags <= 00
               next_state   = ST_TXW;
            end
         end

      ST_TXW:                                 // the tick: lost arbitration / bit error, or move on
         begin
            cond_out[1] = 1'b1;               // (latched only on the way to DONE: lost)
            if (count1_term && shift_data && !rxd)
            begin
               comm_load  = 1'b1;
               ksel0      = 1'b1;             // K1 = 0xFF: release the bus
               latch      = 1'b1;             // F1 = lost
               next_state = ST_DONE;
            end
            else if (count1_term)
               next_state = ST_TXA;
         end

      ST_TXA:                                 // what the shifter does for the next bit
         begin
            if (due)                          // a stuff bit: the unit holds the shifter for this shift
            begin
               shift      = 1'b1;
               next_state = ST_TXW;
            end
            else if ((shift_term || count3_cmp) && !f1)   // a frame-bit boundary: no shift, the CRC takes the bit
            begin
               crc_update = 1'b1;             // the bit that just ended
               next_state = ST_POP;
            end
            else
               next_state = ST_TXS;
         end

      ST_TXS:                                 // the CRC field's bits keep the CRC unit still
         begin
            if (f1 && (shift_term || count3_cmp))   // its low byte, or the delimiter
               next_state = ST_POPC;
            else if (f1)
            begin
               shift      = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
            else
               next_state = ST_TXS2;
         end

      ST_TXS2:                                // a plain frame bit
         begin
            if (rxd)
            begin
               shift      = 1'b1;
               crc_update = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
            else if (!rxd)
            begin
               shift      = 1'b1;
               crc_update = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
         end

      ST_POP:                                 // a frame-bit boundary: the end of the frame bits, or the next byte
         begin
            cond_out[1] = 1'b1;               // (latched only below: F1 = CRC field)
            if (count3_cmp)                   // all frame bits sent: the CRC's high byte, 14 more bits to count
            begin
               load_crc   = 1'b1;
               count3_hi  = 1'b1;
               count3_lo  = 1'b1;
               ksel1      = 1'b1;             // limit <= K2 = 14
               latch      = 1'b1;
               next_state = ST_TXW;
            end
            else if (!count3_cmp)
               next_state = ST_POPB;
         end

      ST_POPB:                                // the next byte of the frame
         begin
            if (rxd)
            begin
               fifo_pop   = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
            else if (!rxd)
            begin
               fifo_pop   = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
         end

      ST_POPC:                                // CRC field: its low byte after 8 bits, the delimiter after 15
         // (count3 = 7 at the first, 14 at the second: K2 = 14)
         begin
            if (count3_cmp)
            begin
               comm_load  = 1'b1;
               ksel0      = 1'b1;             // K1 = 0xFF
               latch      = 1'b1;             // flags <= 00
               next_state = ST_DELIM;
            end
            else if (!count3_cmp)
            begin
               load_crc   = 1'b1;
               count3_lo  = 1'b1;
               next_state = ST_TXW;
            end
         end

      ST_DELIM:                               // the delimiter bit; a held comm load is redone at the tick
         begin
            if (count1_term && hold)
            begin
               comm_load  = 1'b1;
               ksel0      = 1'b1;
               next_state = ST_DELIM;
            end
            else if (count1_term && !hold)
            begin
               count3_hi  = 1'b1;
               count3_lo  = 1'b1;
               ksel1      = 1'b1;
               ksel0      = 1'b1;             // limit <= K3 = 11 tail ticks
               next_state = ST_ACKS;
            end
         end

      ST_ACKS:                                // the ACK slot: dominant = acknowledged
         begin
            cond_out[0] = 1'b0;
            if (!rxd)
               cond_out[0] = 1'b1;
            if (count1_term)
            begin
               latch      = 1'b1;             // F0 = acked
               next_state = ST_TAIL;
            end
         end

      ST_TAIL:                                // ACK delimiter, EOF, IFS
         begin
            if (count1_term)
            begin
               count3_lo  = 1'b1;
               next_state = ST_TAILC;
            end
         end

      ST_TAILC:
         begin
            if (count3_cmp)
               next_state = ST_DONE;
            else if (!count3_cmp)
               next_state = ST_TAIL;
         end

      ST_DONE:                                // frame over (or lost); a held release is redone first
         begin
            if (count1_term && hold)
            begin
               comm_load  = 1'b1;
               ksel0      = 1'b1;
               next_state = ST_DONE;
            end
            else if (!hold)
            begin
               host_irq   = 1'b1;
               next_state = ST_IDLE;
            end
         end

      default:
         next_state = ST_IDLE;
      endcase
   end

endmodule
