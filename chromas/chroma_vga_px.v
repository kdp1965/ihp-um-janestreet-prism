// =======================================================
// PRISM VGA pixel shard (shard 1 of the vga pair, v1, 2026-09-30)
//
// Plays a 160 x 120 RGB222 frame buffer on the Tiny VGA PMOD at 640 x 480
// timing with a 3-clock pixel (71.4 MHz / 3 = 23.8 MHz): every pixel byte
// is popped from the shard's FIFO (FIFO B, the TX DMA's, meant to be the
// SRAM FIFO) into comm and held for four pixels = 12 clocks, so a line is
// 160 bytes, and the line shard (chroma_vga_ln, shard 0) has the TX DMA
// send each source line four times.  The six colour pins show comm[5:0]
// through the multi-bit shift window (CFG0[2], COMM_PINS: uo_out[2:0] =
// R1 G1 B1 = comm[5:3], uo_out[6:4] = R0 G0 B0 = comm[2:0]); in the
// blanking comm is loaded with K0 = 0, black.  HSync (negative) is
// pin_out[0] on uo_out[7]; VSync and the active-lines flag come from the
// line shard (uo_out[3], and its pin_out[1] = our input 26).
//
// Timing, in 12-clock units (count1 free-running, counting up to preload 11):
//   active 160 units   count2 counts the pops, compare = 159
//   front porch  4     timer 2, one-shot 48 clocks restarted on entry to FP
//   hsync       24     the 32-bit counter (CFG3[10]) per unit, CRC_EXPECTED
//   back porch  12     count3 per unit, limit 10, plus the ST_LINE unit
// = 200 units = 2400 clocks = 33.6 us per line (31.5 kHz nominal is 31.8).
// One semaphore per line, set on the FP -> HS transition, is the line
// shard's line clock.  Every wait is entered by an explicit jump and every
// exit is on the unit tick, so the line length is constant.
//
// Each source line is shown four times and fetched once: FIFO B holds
// exactly the line, and on three showings out of four the pops re-push
// the popped byte at the tail (CFG3[29]: a pop while cond_out[0] is high
// recirculates), which this shard does by raising cond_out[0] in ST_ACT
// while the line shard's "replay" flag (its pin_out[2], our input 27) is
// up.  On the fourth showing the pops consume the line; the line shard
// interrupts TinyQV as that showing starts, and TinyQV's one 160-byte TX
// DMA copy puts the next line behind it (its tap yields to a re-push).
//
// Host set-up (shard 1): PRELOAD 11, COMPARE 159, CRC_EXPECTED 23,
// COUNT3 limit 10, CFG3 = CNT_EN | FIFO_REPUSH, PRELOAD2 = 47 | T2_RELOAD
// | T2_STATE(FP) | T2_ONESHOT, COMM_PINS = the VGA lanes, CONST = 0 (K0
// black), CFG0 |= FIFO_SRAM for the SRAM FIFO, the first line in FIFO B;
// TinyQV routes all eight uo_out pins to the PRISM (uo_out[0] is the UART
// TX otherwise).
// =======================================================
module chroma_vga_px
(
   input  wire          clk,
   input  wire          rst_n,
   input  wire          fsm_enable,
   input  wire [31:0]   in_data,       // Inputs to the PRISM
   output wire [20:0]   out_data,      // FSM outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,      // CFG0 for this chroma
   output reg  [23:0]   pinmux_reg     // uo_out[7:0] source selects
);

   // CFG0 (ctrl_reg), one named field per bit group
   localparam [0:0]  FIFO_SRAM      = 1'd0;  // the host ORs CFG_FIFO_SRAM in for the SRAM FIFO
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}]: K0 = 0 = black
   localparam [0:0]  FLAG_LATCH     = 1'd0;
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;
   localparam [0:0]  CRC_SRC_OUT    = 1'd0;
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;
   localparam [0:0]  CRC_INIT_ONES  = 1'd0;  // counter preset = 0
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;
   localparam [0:0]  FIFO_DIR_TX    = 1'd1;  // the FSM pops pixel bytes into comm
   localparam [0:0]  CRC_REFLECT    = 1'd0;
   localparam [1:0]  CRC_MODE       = 2'd0;  // 0: the CRC register is the hsync unit counter (CFG3[10])
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;
   localparam [0:0]  COMM_LOAD_ONE  = 1'd0;
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;
   localparam [0:0]  WRAP_PRELOAD   = 1'd1;  // count1 free-runs: up to PRELOAD, terminal count there, back to 0
   localparam [0:0]  COUNT_UP       = 1'd1;  // (counting down it would stop at 0)
   localparam [0:0]  LATCH2         = 1'd0;
   localparam [0:0]  COUNT3_EN      = 1'd1;  // pin_out[3] is count3's second command bit
   localparam [0:0]  COUNT32        = 1'd0;
   localparam [0:0]  SHIFT_24_EN    = 1'd0;
   localparam [0:0]  SHIFT_DIR      = 1'd0;
   localparam [0:0]  SHIFT_EN       = 1'd0;
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;
   localparam [0:0]  CLR_NOT_LOAD   = 1'd0;
   localparam [0:0]  MSHIFT_EN      = 1'd1;  // CFG0[2]: pins with code 6 show comm window lanes
   localparam [1:0]  SHIFT_IN_SEL   = 2'd0;
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 3'h0, MSHIFT_EN, SHIFT_IN_SEL};

   // uo_out sources, 3 bits per pin: the Tiny VGA PMOD is R1 G1 B1 VSync
   // R0 G0 B0 HSync on uo_out[0..7]; the colours are comm window lanes
   // (code 6, lanes per COMM_PINS), VSync belongs to the line shard
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO0_SRC  = PIN_SHIFT;         // R1 = comm[5]
   localparam [2:0]  UO1_SRC  = PIN_SHIFT;         // G1 = comm[4]
   localparam [2:0]  UO2_SRC  = PIN_SHIFT;         // B1 = comm[3]
   localparam [2:0]  UO3_SRC  = PIN_OFF;           // VSync: the line shard's
   localparam [2:0]  UO4_SRC  = PIN_SHIFT;         // R0 = comm[2]
   localparam [2:0]  UO5_SRC  = PIN_SHIFT;         // G0 = comm[1]
   localparam [2:0]  UO6_SRC  = PIN_SHIFT;         // B0 = comm[0]
   localparam [2:0]  UO7_SRC  = PIN_OUT0;          // HSync (negative)
   localparam [23:0] PINMUX    = {UO0_SRC, UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [2:0]  ST_LINE   = 3'd0;   // last unit before the active region: pixels or black?
   localparam [2:0]  ST_ACT    = 3'd1;   // 160 pixel bytes, one pop per unit
   localparam [2:0]  ST_BLK    = 3'd2;   // a blank line: 160 units of black
   localparam [2:0]  ST_FP     = 3'd3;   // front porch: timer 2
   localparam [2:0]  ST_HS     = 3'd4;   // hsync low: the counter per unit
   localparam [2:0]  ST_BP     = 3'd5;   // back porch: count3 per unit

   reg   [2:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire tick        = in_data[10];   // count1 terminal: the 12-clock unit
   wire count2_cmp  = in_data[11];   // count2 >= 159: last pixel byte popped
   wire cnt_ge      = in_data[22];   // counter mode: hsync units done
   wire active      = in_data[26];   // the line shard's pin_out[1]: this line carries pixels
   wire replay      = in_data[27];   // its pin_out[2]: this showing is not the last: re-push what is popped
   wire t2_tick     = in_data[28];   // timer 2 one-shot: front porch over
   wire count3_ge   = in_data[29];   // count3 >= limit: back porch over

   // =======================================================
   // Outputs
   // =======================================================
   reg hsync_n;                // pin_out[0] -> uo_out[7]
   reg count3_hi;              // pin_out[3]: count3 command bit 1
   reg fifo_pop;               // OUT_FIFO_WR_RD: pop the next pixel byte into comm
   reg count1_dec;             // OUT_COUNT1_INC_DEC: the unit timer runs always
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_dec;             // OUT_COUNT2_DEC (with inc: clear)
   reg count3_lo;              // OUT_COUNT3: count3 command bit 0
   reg crc_clear;              // OUT_CRC_CLEAR: counter preset
   reg crc_update;             // OUT_CRC_UPDATE: counter + 1
   reg comm_load;              // OUT_COMM_LOAD: K0 = black
   reg sema_set;               // OUT_SEMA_SET: one per line, at the hsync

   assign out_data[0]  = hsync_n;
   assign out_data[3]  = count3_hi;
   assign out_data[5]  = fifo_pop;
   assign out_data[6]  = count1_dec;
   assign out_data[9]  = count2_inc;
   assign out_data[10] = count2_dec;
   assign out_data[11] = count3_lo;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[16] = comm_load;
   assign out_data[19] = sema_set;

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 3'h0;
      else
         curr_state <= fsm_enable ? next_state : 3'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state   = curr_state;

      hsync_n      = 1'b1;
      count3_hi    = 1'b0;
      fifo_pop     = 1'b0;
      count1_dec   = 1'b1;      // the unit timer runs in every state
      count2_inc   = 1'b0;
      count2_dec   = 1'b0;
      count3_lo    = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      comm_load    = 1'b0;
      sema_set     = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_LINE:                               // the back porch's last unit
         begin
            if (replay)
               cond_out[0] = 1'b1;           // the first pop of a replayed line re-pushes too
            if (tick && active)              // pixels: first byte on the tick, count2 from 0
            begin
               fifo_pop    = 1'b1;
               count2_inc  = 1'b1;
               count2_dec  = 1'b1;
               next_state  = ST_ACT;
            end
            else if (tick && !active)        // black line, same length
            begin
               count2_inc  = 1'b1;
               count2_dec  = 1'b1;
               next_state  = ST_BLK;
            end
         end

      ST_ACT:
         begin
            if (replay)
               cond_out[0] = 1'b1;           // FIFO replay: every pop re-pushes its byte
            if (tick && !count2_cmp)         // next byte, every unit
            begin
               fifo_pop    = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_ACT;
            end
            else if (tick && count2_cmp)     // the last byte has had its unit
            begin
               comm_load   = 1'b1;           // black
               next_state  = ST_FP;
            end
         end

      ST_BLK:
         begin
            if (tick && !count2_cmp)
            begin
               count2_inc  = 1'b1;
               next_state  = ST_BLK;
            end
            else if (tick && count2_cmp)
            begin
               comm_load   = 1'b1;
               next_state  = ST_FP;
            end
         end

      ST_FP:                                 // timer 2 restarts on entry
         begin
            comm_load   = 1'b1;              // black, every clock
            crc_clear   = 1'b1;              // preset the hsync unit counter
            count3_hi   = 1'b1;              // clear count3 ({1, 0})
            if (t2_tick)
            begin
               sema_set    = 1'b1;           // the line shard's line clock
               next_state  = ST_HS;
            end
         end

      ST_HS:
         begin
            hsync_n     = 1'b0;
            count3_hi   = 1'b1;              // keep count3 cleared
            if (tick && !cnt_ge)
            begin
               crc_update  = 1'b1;           // one unit
               next_state  = ST_HS;
            end
            else if (tick && cnt_ge)
               next_state  = ST_BP;
         end

      ST_BP:
         begin
            if (tick && !count3_ge)
            begin
               count3_lo   = 1'b1;           // count3 + 1 ({0, 1})
               next_state  = ST_BP;
            end
            else if (tick && count3_ge)
               next_state  = ST_LINE;
         end

      default:
         next_state = ST_LINE;
      endcase
   end
endmodule
