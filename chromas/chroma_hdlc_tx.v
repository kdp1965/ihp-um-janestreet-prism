// =======================================================
// PRISM HDLC transmitter Chroma (v1, 2026-10-01: 11 states)
//
// A synchronous bit-oriented HDLC / SDLC transmitter: it drives the
// transmit clock and data, idles with flags (0x7E), and on a host start
// sends one frame from the TX FIFO with zero insertion after five ones,
// the 16-bit FCS (CRC-16 / X.25: reflected 0x1021, preset 0xFFFF,
// complemented, low byte first) and a closing flag, then interrupts.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[3]     TXC: transmit clock (data changes on its falling edge)
//   cond_out[0]     uo_out[2]     TXD: transmit data
//
// No RTL support beyond the generic datapath.  The hardware bit-stuff unit
// (CFG3[14]) stuffs after a run of equal bits of either value (CAN); HDLC
// stuffs only after ones, so count2 counts the ones sent (COMPARE = 4: the
// fifth one in a row) and the FSM sends the stuff bit itself.  TXD is
// cond_out[0]: the shifter's output bit in the bit states, 0 in the stuff
// bit's states (the shifter holds meanwhile).  Bits go LSB first.
//
// Bit clock: count1 counts up and wraps at PRELOAD (= half a bit - 1), a
// free-running tick that alternates the clock's low and high halves.
//
//   LO / HI:   one bit, TXC low then high; at the falling edge a 1 goes to
//              ONE, a 0 clears count2 and goes to ADV.  The CRC takes the bit
//              in LO, except in the FCS (F1)
//   ONE:       the fifth one in a row outside the flags -> a stuff bit
//              (SLO / SHI, TXD = 0, count2 <= 0); else count2 + 1
//   ADV:       the next bit of the byte (shift), or at the byte's end BYTE
//   BYTE:      by phase: DATA, FCS, else (INC) FLAGB
//   FLAGB:     a flag went out: a host start with a frame in the FIFO pops
//              its first byte (CRC preset, count2 <= 0, phase = data), else
//              the next flag
//   DATA:      the next byte, or at an empty FIFO the FCS's low byte
//   FCS:       its high byte, then the closing flag and the interrupt
//
// Phases in the flags (OUT_LATCH, CFG0[29]): {F1, F0} = 00 flags, 01 data,
// 10 first FCS byte, 11 second FCS byte.  The frame ends where the FIFO
// runs empty, so the host writes the whole frame before it starts it: up
// to 16 bytes in the flop FIFO, longer frames in the shard's SRAM FIFO
// (CFG0 bit 31, 2 KB).
//
// Host set-up (see HdlcTxTest): CFG1 = in_prev1 <- host_in[0] (8 << 4);
// COMPARE = 4; PRELOAD = half a bit - 1; CONST K0 = 0x7E; CRC_POLY =
// 0x8408.  Per frame: write the bytes (address, control, information) into
// the FIFO, then toggle host_in[0] (REG_TOGGLE); the interrupt comes with
// the closing flag.
//
// Not in v1: aborts on an underrun (the host fills the FIFO first), the
// 32-bit FCS, NRZI, mark idle, an external transmit clock.
// =======================================================
module chroma_hdlc_tx
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
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K0 = 0x7E (the flag)
   localparam [0:0]  FLAG_LATCH     = 1'd1;  // OUT_LATCH stores {cond_out[1:0]}: the phase
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;
   localparam [0:0]  CRC_SRC_OUT    = 1'd1;  // CRC over the bit on the pin (the shifter's output)
   localparam [0:0]  CRC_XOR_OUT    = 1'd1;  // the FCS goes out complemented
   localparam [0:0]  CRC_INIT_ONES  = 1'd1;  // preset 0xFFFF
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;
   localparam [0:0]  FIFO_DIR_TX    = 1'd1;  // TX: the host writes, the FSM pops
   localparam [0:0]  CRC_REFLECT    = 1'd1;  // LSB first, low byte first
   localparam [1:0]  CRC_MODE       = 2'd2;  // 16 bits
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;
   localparam [0:0]  COMM_LOAD_ONE  = 1'd1;  // a loaded byte's first bit is on the pin at once
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;
   localparam [0:0]  WRAP_PRELOAD   = 1'd1;  // count1 wraps at PRELOAD: a periodic half-bit tick
   localparam [0:0]  COUNT_UP       = 1'd1;
   localparam [0:0]  LATCH2         = 1'd1;  // OUT_LATCH enabled
   localparam [0:0]  COUNT3_EN      = 1'd0;
   localparam [0:0]  COUNT32        = 1'd0;
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // comm shifts
   localparam [0:0]  SHIFT_DIR      = 1'd1;  // LSB first
   localparam [0:0]  SHIFT_EN       = 1'd1;
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;
   localparam [0:0]  CLR_NOT_LOAD   = 1'd1;  // OUT_COUNT1_CLEAR_LOAD clears: the bit clock starts at enable
   localparam [1:0]  SHIFT_IN_SEL   = 2'd3;  // (unused: nothing is shifted in)
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
   localparam [2:0]  UO2_SRC  = PIN_COND0;      // TXD
   localparam [2:0]  UO3_SRC  = PIN_OUT0;       // TXC
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States (INC leg: BYTE -> FLAGB, which always exits)
   // =======================================================
   localparam [3:0]  ST_INIT    = 4'd0;    // the first flag, the bit clock from 0, phase = flags
   localparam [3:0]  ST_LO      = 4'd1;    // TXC low (the CRC takes the bit)
   localparam [3:0]  ST_HI      = 4'd2;    // TXC high; at the falling edge: a 1 or a 0
   localparam [3:0]  ST_ONE     = 4'd3;    // a 1 went out: the fifth one in a row is followed by a stuff bit
   localparam [3:0]  ST_SLO     = 4'd4;    // the stuff bit, TXC low
   localparam [3:0]  ST_SHI     = 4'd5;    // the stuff bit, TXC high
   localparam [3:0]  ST_ADV     = 4'd6;    // the next bit of the byte, or the byte's end
   localparam [3:0]  ST_BYTE    = 4'd7;    // the byte's end, by phase
   localparam [3:0]  ST_FLAGB   = 4'd8;    // (INC) a flag went out: start a frame or send another flag
   localparam [3:0]  ST_DATA    = 4'd9;    // a data byte went out: the next one, or the FCS
   localparam [3:0]  ST_FCS     = 4'd10;   // an FCS byte went out: the second one, or the closing flag

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire shift_data  = in_data[7];    // the bit on the pin (comm[0])
   wire host0       = in_data[8];    // start toggle
   wire tick        = in_data[10];   // count1_term: the half-bit tick
   wire ones4       = in_data[11];   // count2 >= COMPARE (4 ones before this one)
   wire f0          = in_data[12];   // phase bit 0
   wire f1          = in_data[13];   // phase bit 1 (the FCS)
   wire shift_term  = in_data[14];   // the byte's last bit is on the pin
   wire in_prev1    = in_data[17];   // host_in[0] at the last start
   wire fifo_empty  = in_data[20];

   // =======================================================
   // Outputs
   // =======================================================
   reg txc;                    // pin_out[0]: TXC
   reg latch;                  // OUT_LATCH: phase <= {cond_out[1:0]}
   reg fifo_pop;               // OUT_FIFO_WR_RD (TX: pop into comm)
   reg count1_step;            // OUT_COUNT1_INC_DEC (the bit clock runs in every state)
   reg count1_clear;           // OUT_COUNT1_CLEAR_LOAD
   reg shift;                  // OUT_SHIFT
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_dec;             // OUT_COUNT2_DEC (with inc: clear)
   reg crc_clear;              // OUT_CRC_CLEAR
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD (K0 = the flag)
   reg load_crc;               // OUT_LOAD_CRC: comm <= the next FCS byte

   assign out_data[0]  = txc;
   assign out_data[4]  = latch;
   assign out_data[5]  = fifo_pop;
   assign out_data[6]  = count1_step;
   assign out_data[7]  = count1_clear;
   assign out_data[8]  = shift;
   assign out_data[9]  = count2_inc;
   assign out_data[10] = count2_dec;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[14] = host_irq;
   assign out_data[16] = comm_load;
   assign out_data[17] = load_crc;

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

      txc          = 1'b0;
      latch        = 1'b0;
      fifo_pop     = 1'b0;
      count1_step  = 1'b1;
      count1_clear = 1'b0;
      shift        = 1'b0;
      count2_inc   = 1'b0;
      count2_dec   = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      load_crc     = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_INIT:                                // the first flag, phase = flags, the bit clock from 0
         begin
            if (tick)
            begin
               comm_load    = 1'b1;
               count1_clear = 1'b1;
               latch        = 1'b1;           // phase 00
               next_state   = ST_LO;
            end
            else if (!tick)
            begin
               comm_load    = 1'b1;
               count1_clear = 1'b1;
               latch        = 1'b1;
               next_state   = ST_LO;
            end
         end

      ST_LO:                                  // TXC low: the CRC takes the bit (not in the FCS)
         begin
            if (shift_data)                   // TXD = the bit
               cond_out[0] = 1'b1;
            if (tick && !f1)
            begin
               crc_update = 1'b1;
               next_state = ST_HI;
            end
            else if (tick && f1)
               next_state = ST_HI;
         end

      ST_HI:                                  // TXC high; the falling edge ends the bit
         begin
            txc = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (tick && shift_data)
               next_state = ST_ONE;
            else if (tick && !shift_data)
            begin
               count2_inc = 1'b1;
               count2_dec = 1'b1;             // a 0: the run of ones ends
               next_state = ST_ADV;
            end
         end

      ST_ONE:                                 // a 1 went out
         begin
            cond_out[0] = 1'b1;               // (it is still on the pin)
            if (ones4 && (f0 || f1))          // the fifth one in a row, outside the flags: a stuff bit
            begin
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               next_state = ST_SLO;
            end
            else if (!(ones4 && (f0 || f1)))
            begin
               count2_inc = 1'b1;
               next_state = ST_ADV;
            end
         end

      ST_SLO:                                 // the stuff bit: TXD = 0, the shifter holds
         begin
            if (tick)
               next_state = ST_SHI;
         end

      ST_SHI:
         begin
            txc = 1'b1;
            if (tick)
               next_state = ST_ADV;
         end

      ST_ADV:                                 // the next bit, or the byte's end
         begin
            if (shift_data)
               cond_out[0] = 1'b1;
            if (!shift_term)
            begin
               shift      = 1'b1;
               next_state = ST_LO;
            end
            else if (shift_term)
               next_state = ST_BYTE;
         end

      ST_BYTE:                                // the byte's end: what comes next depends on the phase
         begin
            if (shift_data)
               cond_out[0] = 1'b1;
            if (f0 && !f1)                    // data
               next_state = ST_DATA;
            else if (f1)                      // FCS
               next_state = ST_FCS;
            else                              // (INC) flags
               next_state = ST_FLAGB;
         end

      ST_FLAGB:                               // a flag went out: start a frame, or another flag
         begin
            cond_out[1] = 1'b0;
            cond_out[0] = 1'b1;               // phase 01 (latched on a start)
            if ((host0 ^ in_prev1) && !fifo_empty)
            begin
               fifo_pop   = 1'b1;
               crc_clear  = 1'b1;
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               latch      = 1'b1;
               next_state = ST_LO;
            end
            else if (!((host0 ^ in_prev1) && !fifo_empty))
            begin
               comm_load  = 1'b1;             // K0 = 0x7E
               next_state = ST_LO;
            end
         end

      ST_DATA:                                // a data byte went out
         begin
            cond_out[1] = 1'b1;
            cond_out[0] = 1'b0;               // phase 10 (latched at the FCS)
            if (!fifo_empty)
            begin
               fifo_pop   = 1'b1;
               next_state = ST_LO;
            end
            else if (fifo_empty)              // the frame's end: the FCS's low byte
            begin
               load_crc   = 1'b1;
               latch      = 1'b1;
               next_state = ST_LO;
            end
         end

      ST_FCS:                                 // an FCS byte went out
         begin
            if (!f0)                          // phase 10 -> 11, 11 -> 00
            begin
               cond_out[1] = 1'b1;
               cond_out[0] = 1'b1;
            end
            if (!f0)                          // the high byte
            begin
               load_crc   = 1'b1;
               latch      = 1'b1;
               next_state = ST_LO;
            end
            else if (f0)                      // the closing flag
            begin
               comm_load  = 1'b1;
               latch      = 1'b1;
               host_irq   = 1'b1;
               next_state = ST_LO;
            end
         end

      default:
         next_state = ST_INIT;
      endcase
   end

endmodule
