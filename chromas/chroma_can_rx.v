// =======================================================
// PRISM CAN 2.0A receiver Chroma (v2, 2026-09-28: 12 states)
//
// Receives standard (11-bit ID) data frames and acknowledges the good
// ones.  RXD (1 = recessive, 0 = dominant) is ui_in[3] (not ui_in[0]: the
// compiler parks unused muxes on input 0, and a spare mux on the RXD input
// would recapture in_prev0 on every jump); TXD is uo_out[1] = pin_out[0]
// meaning "drive dominant" (1 only in the ACK slot; the board inverts it
// for a transceiver's TXD and ANDs it with a transmitter's).
//
// Bit clock: count1 counts up and wraps at PRELOAD (= one bit time - 1),
// so count1_term is a periodic tick; the sampler (CFG3: input 3, falling
// edge, timer action with preset k = 2) sets count1 to PRELOAD >> 2 on
// every recessive-to-dominant edge, which puts the tick 75 % into the bit
// after each edge.  One wait state per bit; the FSM never reloads count1.
//
// Bits: at every tick the FSM shifts RXD into comm (MSB first) and feeds
// the CRC (CRC-15 0x4599 in the unit's 16-bit mode: polynomial 0x8B32,
// init 0, expected 0 after the 15 CRC bits).  The bit-stuff unit (CFG3[14],
// count2 = run length - 1, COMPARE = 4) drops a stuff bit in hardware:
// that tick's shift, CRC update and count3 step are cancelled and input 30
// (dropped) says so until the next shift, which keeps the byte push off.
//
// Fields: count3 counts bits in the header (limit K3 = 19 = SOF + 18) and
// the CRC (limit K2 = 15), and bytes in the data field (limit = the DLC
// from a masked load of comm, mask 0xF0, when the header ends: comm then
// holds {ID0, RTR, IDE, r0, DLC}).  Every 8th bit of the header and every
// data byte is pushed into the RX FIFO: the host gets {SOF, ID[10:4]},
// {ID[3:0], RTR, IDE, r0, DLC3}, {ID0, RTR, IDE, r0, DLC[3:0]} and the data
// bytes.  The phase lives in the FSM flags (OUT_LATCH + FLAG_LATCH): F0 =
// data field, F1 = CRC field.  The tail (ACK delimiter + EOF) is 8 shifts
// of a freshly loaded comm, ended by shift_term.
//
// Frame end: with the CRC register at 0 after the CRC field the ACK slot
// is driven dominant from the delimiter's tick for 1.25 bit times (timer 2,
// PRELOAD2 restart on entry into the ACK state, one-shot); the host
// interrupt follows the EOF and the CRC register (0 = good) stays readable
// until the next SOF.
//
// Host set-up (see test_can_rx): CFG1 = 0; CFG2 = slot 1 (input 17) = 15;
// CFG3 = SMP_EN | SMP_SRC(3) | SMP_FALL | SMP_TIMER | SMP_PRESET(2) |
// STUFF_EN; CONST = {19, 15, 0, 0}; COUNT3 mask byte = 0xF0; COMPARE = 4;
// PRELOAD = bit - 1; PRELOAD2 = 1.25 bit - 2, restart on entry into the
// ACK state, one-shot; CRC_POLY = 0x8B32, CRC_EXPECTED = 0.
//
// Not in v2: extended / remote frames, a DLC above 8 (counted as that many
// bytes), error signalling, late-edge resynchronisation.
// =======================================================
module chroma_can_rx
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
   localparam [0:0]  FIFO_SRAM      = 1'd0;  // 0 = the flop FIFO; the host may OR CFG_FIFO_SRAM in
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}]
   localparam [0:0]  FLAG_LATCH     = 1'd1;  // OUT_LATCH stores {cond_out[1:0]} in latched_in (the phase)
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;  // shifter input = the pin
   localparam [0:0]  CRC_SRC_OUT    = 1'd0;  // CRC over the shifter input bit
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;
   localparam [0:0]  CRC_INIT_ONES  = 1'd0;  // CRC-15 starts from 0
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;
   localparam [0:0]  FIFO_DIR_TX    = 1'd0;  // RX: the FSM pushes, the host reads
   localparam [0:0]  CRC_REFLECT    = 1'd0;  // MSB first
   localparam [1:0]  CRC_MODE       = 2'd2;  // 16 bits (the 15-bit polynomial shifted up one)
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;  // 2-flop sync
   localparam [0:0]  COMM_LOAD_ONE  = 1'd0;
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;
   localparam [0:0]  WRAP_PRELOAD   = 1'd1;  // count1 wraps at PRELOAD: a periodic tick
   localparam [0:0]  COUNT_UP       = 1'd1;  // count1 counts up
   localparam [0:0]  LATCH2         = 1'd1;  // OUT_LATCH enabled
   localparam [0:0]  COUNT3_EN      = 1'd1;  // pin_out[3] is count3's second command bit
   localparam [0:0]  COUNT32        = 1'd0;
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // comm shifts
   localparam [0:0]  SHIFT_DIR      = 1'd0;  // MSB first
   localparam [0:0]  SHIFT_EN       = 1'd1;
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;
   localparam [0:0]  CLR_NOT_LOAD   = 1'd0;
   localparam [1:0]  SHIFT_IN_SEL   = 2'd3;  // RXD = ui_in[3]
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;       // TXD: drive dominant (the ACK slot)
   localparam [2:0]  UO2_SRC  = PIN_OFF;
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States (INC legs: DISP -> CHK, EVENT -> CAP; their targets always exit)
   // =======================================================
   localparam [3:0]  ST_IDLE    = 4'd0;    // bus idle: a falling edge is the SOF
   localparam [3:0]  ST_WAIT    = 4'd1;    // one bit: shift and CRC at the tick
   localparam [3:0]  ST_DISP    = 4'd2;    // count the bit (header / CRC) or the byte (data), push bytes
   localparam [3:0]  ST_CHK     = 4'd3;    // count3 at its limit?
   localparam [3:0]  ST_EVENT   = 4'd4;    // end of the CRC, the data (-> CRC) or the header (INC -> CAP)
   localparam [3:0]  ST_CAP     = 4'd5;    // limit <= the DLC, comm cleared, phase = data
   localparam [3:0]  ST_CAP3    = 4'd6;    // DLC = 0: straight to the CRC field
   localparam [3:0]  ST_TD      = 4'd7;    // the CRC delimiter's tick: ACK or not
   localparam [3:0]  ST_ACK     = 4'd8;    // ACK slot: dominant until timer 2 ticks (1.25 bits)
   localparam [3:0]  ST_TAIL    = 4'd9;    // ACK delimiter + EOF: 8 shifts
   localparam [3:0]  ST_TAILC   = 4'd10;
   localparam [3:0]  ST_END     = 4'd11;   // interrupt

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire rxd         = in_data[3];    // RXD (1 = recessive)
   wire count1_term = in_data[10];   // the bit clock's tick
   wire f0          = in_data[12];   // phase: data field
   wire f1          = in_data[13];   // phase: CRC field
   wire shift_term  = in_data[14];   // 8 bits since the last comm load
   wire pending     = in_data[17];   // slot: sampler edge not yet consumed (the SOF)
   wire crc_ok      = in_data[22];   // CRC register == 0
   wire tick2       = in_data[28];   // timer 2 (the ACK slot's length)
   wire count3_cmp  = in_data[29];   // count3 >= limit
   wire dropped     = in_data[30];   // the last tick's bit was a stuff bit

   // =======================================================
   // Outputs
   // =======================================================
   reg txd_dom;                // pin_out[0]: drive the bus dominant
   reg count3_hi;              // pin_out[3]: count3 command bit 1
   reg latch;                  // OUT_LATCH: phase <= {cond_out[1:0]}
   reg fifo_push;              // OUT_FIFO_WR_RD
   reg count1_step;            // OUT_COUNT1_INC_DEC (the bit clock runs in every state)
   reg shift;                  // OUT_SHIFT
   reg count3_lo;              // OUT_COUNT3: command bit 0
   reg crc_clear;              // OUT_CRC_CLEAR (also restarts the stuff unit's run)
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD (K[{ksel1, ksel0}])
   reg ksel0;                  // OUT_K_SEL0: with the limit command, the masked comm load
   reg ksel1;                  // OUT_K_SEL1: with the limit command, the constant K[{1, ksel0}]

   assign out_data[0]  = txd_dom;
   assign out_data[3]  = count3_hi;
   assign out_data[4]  = latch;
   assign out_data[5]  = fifo_push;
   assign out_data[6]  = count1_step;
   assign out_data[8]  = shift;
   assign out_data[11] = count3_lo;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[14] = host_irq;
   assign out_data[16] = comm_load;
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

      txd_dom      = 1'b0;
      count3_hi    = 1'b0;
      latch        = 1'b0;
      fifo_push    = 1'b0;
      count1_step  = 1'b1;
      shift        = 1'b0;
      count3_lo    = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      ksel0        = 1'b0;
      ksel1        = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_IDLE:                                // the SOF edge: header limit 19, CRC (and the stuff run) cleared
         begin
            if (pending)
            begin
               count3_hi  = 1'b1;
               count3_lo  = 1'b1;             // limit <= K3 = 19 (and count3 <= 0)
               ksel1      = 1'b1;
               ksel0      = 1'b1;
               crc_clear  = 1'b1;
               latch      = 1'b1;             // phase <= 00 (header)
               next_state = ST_WAIT;
            end
            else if (rxd)                     // idle: keep comm empty and its count at 0
            begin
               comm_load  = 1'b1;             // K0 = 0
               next_state = ST_IDLE;
            end
         end

      ST_WAIT:                                // the tick: take the bit (the stuff unit may cancel it)
         begin
            if (count1_term)
            begin
               shift      = 1'b1;
               crc_update = 1'b1;
               next_state = ST_DISP;
            end
         end

      ST_DISP:                                // a stuff bit, or a data-field bit inside a byte: nothing to count
         begin
            count3_lo = 1'b1;                 // INC leg (header / CRC bit): count it
            if (dropped || (f0 && !shift_term))
            begin
               count3_lo  = 1'b0;
               next_state = ST_WAIT;
            end
            else if (shift_term && !f1)       // a byte of the header or the data
            begin
               fifo_push  = 1'b1;
               next_state = ST_CHK;
            end
            else
               next_state = ST_CHK;
         end

      ST_CHK:
         begin
            if (count3_cmp)
               next_state = ST_EVENT;
            else if (!count3_cmp)
               next_state = ST_WAIT;
         end

      ST_EVENT:                               // a field ended: CRC -> tail, data -> CRC, header -> (INC) CAP
         begin
            cond_out[1] = 1'b1;               // (latched only in the data-done leg: phase = CRC)
            fifo_push = 1'b1;                 // INC leg: the header's last byte {ID0, RTR, IDE, r0, DLC}
            if (f1)                           // CRC done: the delimiter is the next tick
            begin
               fifo_push  = 1'b0;
               next_state = ST_TD;
            end
            else if (f0)                      // data done: 15 CRC bits (K2), phase = CRC
            begin
               fifo_push   = 1'b0;
               count3_hi   = 1'b1;
               count3_lo   = 1'b1;
               ksel1       = 1'b1;            // limit <= K2 = 15
               latch       = 1'b1;
               next_state  = ST_WAIT;
            end
            else
               next_state = ST_CAP;
         end

      ST_CAP:                                 // limit <= comm & ~mask (the DLC), comm <= K1 = 0, phase = data
         begin
            cond_out[0]  = 1'b1;
            count3_hi    = 1'b1;
            count3_lo    = 1'b1;
            ksel0        = 1'b1;              // the masked load (and K1 for the comm load)
            comm_load    = 1'b1;
            latch        = 1'b1;
            next_state   = ST_CAP3;
         end

      ST_CAP3:                                // no data at all?
         begin
            cond_out[1] = 1'b1;               // (latched only below: phase = CRC)
            if (count3_cmp)                   // DLC = 0: the CRC field starts now
            begin
               count3_hi   = 1'b1;
               count3_lo   = 1'b1;
               ksel1       = 1'b1;            // limit <= K2 = 15
               latch       = 1'b1;
               next_state  = ST_WAIT;
            end
            else if (!count3_cmp)
               next_state = ST_WAIT;
         end

      // ---------------------------------------------------- tail: delimiter, ACK, EOF
      ST_TD:                                  // the delimiter's tick: ACK a good CRC
         begin
            if (count1_term && crc_ok)
               next_state = ST_ACK;
            else if (count1_term && !crc_ok)  // no ACK: comm reloaded for the 8 tail shifts
            begin
               comm_load  = 1'b1;             // K0
               next_state = ST_TAIL;
            end
         end

      ST_ACK:                                 // dominant until timer 2 says the slot is over
         begin
            txd_dom = 1'b1;
            if (tick2)
            begin
               comm_load  = 1'b1;             // K0: 8 tail shifts from here
               next_state = ST_TAIL;
            end
         end

      ST_TAIL:                                // ACK delimiter + EOF (the no-ACK path: ACK slot + 7)
         begin
            if (count1_term)
            begin
               shift      = 1'b1;
               next_state = ST_TAILC;
            end
         end

      ST_TAILC:
         begin
            if (shift_term)
               next_state = ST_END;
            else if (!shift_term)
               next_state = ST_TAIL;
         end

      ST_END:                                 // frame received (the CRC register says whether it was good)
         begin
            host_irq   = 1'b1;
            next_state = ST_IDLE;
         end

      default:
         next_state = ST_IDLE;
      endcase
   end

endmodule
