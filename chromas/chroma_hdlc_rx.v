// =======================================================
// PRISM HDLC receiver Chroma (v1, 2026-10-01: 10 states)
//
// A synchronous bit-oriented HDLC / SDLC receiver: flags (0x7E), zero
// deletion after five ones, aborts (seven ones), the 16-bit FCS (CRC-16 /
// X.25, ITU-T V.42), bytes LSB first.  Every frame's bytes, FCS included,
// go into the shard's RX FIFO; at the closing flag the host interrupt
// fires and FLAGS F0 says whether the FCS was good.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[2]     ui_in[2]      RXC: receive clock (data sampled on its rising edge)
//   prism_in[3]     ui_in[3]      RXD: receive data
//
// No RTL support beyond the generic datapath: count2 counts the ones in a
// row (COMPARE = 5), the FSM follows RXC itself (wait low, wait high), and
// the bit enters the shifter through cond_out[0] (CFG0[28]), so the shift
// never depends on when RXD is looked at again.
//
//   LOW / HIGH:  one RXC period; at the rising edge RXD picks ONE or ZERO
//   ONE:   the sixth one in a row is not data (a flag or an abort): F6;
//          else shift a 1, feed the CRC, count2 + 1
//   ZERO:  after five ones it is a stuff bit: dropped (count2 <= 0);
//          else shift a 0, feed the CRC, count2 <= 0
//   PUSH:  (after a shift) at RXC low, eight bits in a frame = a byte:
//          push it, count3 + 1
//   F6L / F6H: the bit after six ones: 0 = a flag, 1 = an abort
//   FLAG:  a frame with bytes ends (END); else a frame starts here
//   END:   F0 <= FCS good, host interrupt; then as FLAG's start
//   ABORT: seven ones: a frame with bytes reports F0 = 0 and an interrupt
//          and the receiver hunts for the next flag (F1 = 0)
//
// Bits are committed as they arrive, so a closing flag has already put its
// leading 0 and five of its ones into the shifter and the CRC when the
// sixth one shows it is a flag.  Frames are whole bytes, so those six bits
// never complete a byte; and the CRC register of a good frame ends at a
// fixed value: the X.25 residue 0xF0B8 run on through 0,1,1,1,1,1 = 0x9F0B
// (CRC_EXPECTED).  The flag that closes a frame opens the next one (shared
// flags), idle flags make empty frames that are ignored (count3 = 0), and
// a line idling at 1 (mark idle) is a run of aborts with nothing to report.
//
// F1 = inside a frame (a flag was seen since the last abort): bytes are
// pushed only then, so the bits before the first flag are never stored.
//
// Host set-up (see HdlcRxTest): COMPARE = 5; LIMIT3 = 1 (a frame reports
// when it holds at least one byte); CRC_POLY = 0x8408 (reflected 0x1021);
// CRC_EXPECTED = 0x9F0B.  At each interrupt the FIFO holds the frame's
// bytes and its two FCS bytes (the host drops them); FLAGS F0 = FCS good.
// The host must take the bytes before the next frame's first byte lands
// (idle flags or mark idle between frames give it the time).  The flop
// FIFO holds 16 bytes, a 14-byte frame with its FCS; longer frames need
// the shard's SRAM FIFO (CFG0 bit 31, 2 KB).
//
// Not in v1: residue bits (frames that are not whole bytes are reported
// with a bad FCS), address filtering, the 32-bit FCS, NRZI.
// =======================================================
module chroma_hdlc_rx
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
   localparam [0:0]  COMM_LOAD_K    = 1'd0;  // OUT_COMM_LOAD only restarts the shift count here
   localparam [0:0]  FLAG_LATCH     = 1'd1;  // OUT_LATCH stores {cond_out[1:0]}: F1 = in a frame, F0 = FCS good
   localparam [0:0]  SHIFT_IN_COND  = 1'd1;  // the shifter takes cond_out[0]: the bit the FSM decided on
   localparam [0:0]  CRC_SRC_OUT    = 1'd0;  // CRC over the bit entering the shifter
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;
   localparam [0:0]  CRC_INIT_ONES  = 1'd1;  // the FCS starts from 0xFFFF
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;
   localparam [0:0]  FIFO_DIR_TX    = 1'd0;  // RX: the FSM pushes comm, the host reads
   localparam [0:0]  CRC_REFLECT    = 1'd1;  // LSB first
   localparam [1:0]  CRC_MODE       = 2'd2;  // 16 bits
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;  // RXC and RXD through the same two flops
   localparam [0:0]  COMM_LOAD_ONE  = 1'd0;  // a comm load sets the shift count to 0
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;
   localparam [0:0]  WRAP_PRELOAD   = 1'd0;
   localparam [0:0]  COUNT_UP       = 1'd0;
   localparam [0:0]  LATCH2         = 1'd1;  // OUT_LATCH enabled
   localparam [0:0]  COUNT3_EN      = 1'd1;  // pin_out[3] is count3's second command bit (clear)
   localparam [0:0]  COUNT32        = 1'd0;
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // comm shifts
   localparam [0:0]  SHIFT_DIR      = 1'd1;  // LSB first: the newest bit enters at comm[7]
   localparam [0:0]  SHIFT_EN       = 1'd1;
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;
   localparam [0:0]  CLR_NOT_LOAD   = 1'd0;
   localparam [1:0]  SHIFT_IN_SEL   = 2'd3;  // (unused: the input is cond_out[0])
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;        // the receiver drives no pin
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
   localparam [3:0]  ST_LOW     = 4'd0;    // wait for RXC low (no byte to push)
   localparam [3:0]  ST_HIGH    = 4'd1;    // wait for RXC high: the bit
   localparam [3:0]  ST_ONE     = 4'd2;    // a 1: data, or the sixth in a row
   localparam [3:0]  ST_ZERO    = 4'd3;    // a 0: data, or a stuff bit
   localparam [3:0]  ST_PUSH    = 4'd4;    // after a shift: wait for RXC low, push a full byte
   localparam [3:0]  ST_F6L     = 4'd5;    // six ones: wait for RXC low
   localparam [3:0]  ST_F6H     = 4'd6;    // ... and high: flag or abort
   localparam [3:0]  ST_FLAG    = 4'd7;    // a flag: end of a frame with bytes, or a start
   localparam [3:0]  ST_END     = 4'd8;    // a frame ends: FCS result, interrupt, restart
   localparam [3:0]  ST_ABORT   = 4'd9;    // seven ones

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire rxc         = in_data[2];    // receive clock
   wire rxd         = in_data[3];    // receive data
   wire ones5       = in_data[11];   // count2 >= COMPARE (5 ones in a row)
   wire f0          = in_data[12];   // FCS good (last frame)
   wire f1          = in_data[13];   // inside a frame
   wire shift_term  = in_data[14];   // comm has taken 8 bits since its count restarted
   wire crc_ok      = in_data[22];   // CRC register == CRC_EXPECTED
   wire has_bytes   = in_data[29];   // count3 >= limit (1): the frame pushed a byte

   // =======================================================
   // Outputs
   // =======================================================
   reg count3_hi;              // pin_out[3]: count3 command bit 1 (clear = {1, 0})
   reg latch;                  // OUT_LATCH: flags <= {cond_out[1:0]}
   reg push;                   // OUT_FIFO_WR_RD (RX: push comm)
   reg shift;                  // OUT_SHIFT (the bit is cond_out[0])
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_dec;             // OUT_COUNT2_DEC (with inc: clear)
   reg count3_lo;              // OUT_COUNT3: command bit 0 (+ 1 = {0, 1})
   reg crc_clear;              // OUT_CRC_CLEAR
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD: the shift count restarts at 0

   assign out_data[3]  = count3_hi;
   assign out_data[4]  = latch;
   assign out_data[5]  = push;
   assign out_data[8]  = shift;
   assign out_data[9]  = count2_inc;
   assign out_data[10] = count2_dec;
   assign out_data[11] = count3_lo;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[14] = host_irq;
   assign out_data[16] = comm_load;

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
      push         = 1'b0;
      shift        = 1'b0;
      count2_inc   = 1'b0;
      count2_dec   = 1'b0;
      count3_lo    = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_LOW:                                 // the rest of RXC high
         begin
            if (!rxc)
               next_state = ST_HIGH;
         end

      ST_HIGH:                                // the rising edge: the bit
         begin
            if (rxc && rxd)
               next_state = ST_ONE;
            else if (rxc && !rxd)
               next_state = ST_ZERO;
         end

      ST_ONE:                                 // a 1
         begin
            cond_out[0] = 1'b1;               // the bit shifted in
            if (ones5)                        // the sixth in a row: not data
               next_state = ST_F6L;
            else if (!ones5)
            begin
               shift      = 1'b1;
               crc_update = 1'b1;
               count2_inc = 1'b1;
               next_state = ST_PUSH;
            end
         end

      ST_ZERO:                                // a 0
         begin
            cond_out[0] = 1'b0;
            if (ones5)                        // after five ones: a stuff bit, dropped
            begin
               count2_inc = 1'b1;
               count2_dec = 1'b1;             // count2 <= 0
               next_state = ST_LOW;
            end
            else if (!ones5)
            begin
               shift      = 1'b1;
               crc_update = 1'b1;
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               next_state = ST_PUSH;
            end
         end

      ST_PUSH:                                // after a shift: a whole byte in a frame goes to the FIFO
         begin
            if (!rxc && shift_term && f1)
            begin
               push       = 1'b1;
               count3_lo  = 1'b1;             // count3 + 1
               next_state = ST_HIGH;
            end
            else if (!rxc && !(shift_term && f1))
               next_state = ST_HIGH;
         end

      ST_F6L:                                 // six ones: the next bit decides
         begin
            if (!rxc)
               next_state = ST_F6H;
         end

      ST_F6H:
         begin
            if (rxc && !rxd)                  // 01111110: a flag
               next_state = ST_FLAG;
            else if (rxc && rxd)              // seven ones: an abort (or a line idling at 1)
               next_state = ST_ABORT;
         end

      ST_FLAG:                                // a flag ends a frame that holds bytes; a frame starts
         begin
            cond_out[1] = 1'b1;               // F1 = in a frame
            if (f0)                           // F0 kept
               cond_out[0] = 1'b1;
            if (f1 && has_bytes)
               next_state = ST_END;
            else if (!(f1 && has_bytes))
            begin
               latch      = 1'b1;
               crc_clear  = 1'b1;
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               count3_hi  = 1'b1;             // count3 <= 0
               comm_load  = 1'b1;             // shift count <= 0
               next_state = ST_LOW;
            end
         end

      ST_END:                                 // the frame's FCS, the interrupt, and the next frame starts
         begin
            cond_out[1] = 1'b1;
            if (crc_ok)                       // F0 = FCS good
               cond_out[0] = 1'b1;
            if (rxc)
            begin
               latch      = 1'b1;
               host_irq   = 1'b1;
               crc_clear  = 1'b1;
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               count3_hi  = 1'b1;
               comm_load  = 1'b1;
               next_state = ST_LOW;
            end
            else if (!rxc)
            begin
               latch      = 1'b1;
               host_irq   = 1'b1;
               crc_clear  = 1'b1;
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               count3_hi  = 1'b1;
               comm_load  = 1'b1;
               next_state = ST_LOW;
            end
         end

      ST_ABORT:                               // seven ones
         begin
            cond_out[1] = 1'b0;               // F1 = 0: hunt for a flag
            cond_out[0] = 1'b0;               // F0 = 0: the frame is bad
            if (f1 && has_bytes)              // an aborted frame: report it
            begin
               latch      = 1'b1;
               host_irq   = 1'b1;
               next_state = ST_LOW;
            end
            else if (!(f1 && has_bytes))      // idle ones: no stray byte may build up
            begin
               count3_hi  = 1'b1;
               comm_load  = 1'b1;
               next_state = ST_LOW;
            end
         end

      default:
         next_state = ST_LOW;
      endcase
   end

endmodule
