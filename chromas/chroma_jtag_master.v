// =======================================================
// PRISM JTAG master Chroma (2026-09-29: 14 states)
//
// A JTAG (IEEE 1149.1) controller: it makes TCK, walks the target's TAP
// with TMS and shifts IR / DR bits out on TDI while the bits on TDO come
// back.  Unfractured (shard 0 owns both FIFOs), built like the SPI master.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[1]     TCK (idle low)
//   cond_out[0]     uo_out[2]     TMS
//   shift_data      uo_out[3]     TDI (comm bit 0: LSB first)
//   prism_in[2]     ui_in[2]      TDO
//
// One operation is N bits, 1 .. 256: the host writes LIMIT3 = N - 1, the
// bytes to shift out into FIFO B (LSB first, ceil(N / 8) of them), picks the
// mode on host_in[1] and toggles host_in[0].  The bits sampled on TDO come
// back in FIFO A, one byte per byte sent, and the host interrupt marks the
// end.  The modes:
//
//   host_in[1] = 1  WALK: the bytes are a TMS pattern, TDI follows it (the
//                   TAP ignores TDI outside its shift states).  Five ones =
//                   Test-Logic-Reset; 0 = Run-Test/Idle; from there 1,0,0 =
//                   Shift-DR and 1,1,0,0 = Shift-IR; from Exit1 1,0 =
//                   Update and back to Run-Test/Idle
//   host_in[1] = 0  SCAN: the bytes are TDI; TMS is 0 and, with COMPARE = 0,
//                   1 on the last bit, which leaves the shift state for
//                   Exit1.  COMPARE != 0 keeps TMS at 0 on the last bit too:
//                   the TAP stays in its shift state and the next operation
//                   continues the scan (registers longer than 256 bits,
//                   or than the FIFOs hold)
//
// Timing: TDI and TMS change when TCK falls and the target takes them when
// it rises, half a period later.  TDO is sampled at the end of the TCK-high
// half, through the input synchroniser: with its two flops the half period
// must be three clocks or more (PRELOAD >= 2: 10 MHz at 60 MHz), with one
// flop or none (CFG0[19:18] = 1 / 2) two clocks (15 MHz), for a target that
// answers within a clock.  Between two bytes TCK stays low for two more
// clocks (the push and the pop).  Every waiting state has two legs at most:
// the last bit of an operation has a TCK-high state of its own, chosen in
// the TCK-low state (a third leg would become an INC state that alternates
// with the first and sees the terminal count on every other clock only).
//
// A last byte of k < 8 bits comes back in the top of its FIFO A byte: the
// host shifts it right by 8 - k.  FIFO B running dry ends the operation
// early (the interrupt comes, COUNT3 holds the bits done).
//
// Host side: CFG1 in_prev0 <- host_in[0] (8); shard 1's CFG0 = FIFO_DIR_TX
// (FIFO B sends); PRELOAD = half TCK period - 1; LIMIT3 = N - 1; COMPARE =
// 0 (exit on the last bit) or 1 (stay).
// =======================================================
module chroma_jtag_master
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd2;   // TDO on ui_in[2]
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b1;   // pin_out[3] is count3's second command bit
   localparam [0:0]  LATCH2             = 1'b0;
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a pop counts the first bit: shift_term on the eighth
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;   // two flops
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the TDO bytes
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b0;
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_COND0 = 3'd4, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;          // TCK
   localparam [2:0]  UO2_SRC  = PIN_COND0;         // TMS
   localparam [2:0]  UO3_SRC  = PIN_SHIFT;         // TDI
   localparam [20:0] PINMUX   = {PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE      = 4'd0;
   localparam [3:0]  STATE_NEXT      = 4'd1;   // byte boundary: pop the next byte, by mode
   localparam [3:0]  STATE_SCAN_L    = 4'd2;   // scan, TCK low: TMS 1 on the last bit
   localparam [3:0]  STATE_SCAN_H    = 4'd3;   // scan, TCK high; the shift at its end
   localparam [3:0]  STATE_SCAN_HL   = 4'd4;   // scan, TCK high of the last bit
   localparam [3:0]  STATE_STAY_L    = 4'd5;   // scan that stays in the shift state: TMS 0 throughout
   localparam [3:0]  STATE_STAY_H    = 4'd6;
   localparam [3:0]  STATE_STAY_HL   = 4'd7;
   localparam [3:0]  STATE_WALK_L    = 4'd8;   // walk: TMS is the bit itself
   localparam [3:0]  STATE_WALK_H    = 4'd9;
   localparam [3:0]  STATE_WALK_HL   = 4'd10;
   localparam [3:0]  STATE_BYTE_END  = 4'd11;  // push the byte received, more to come
   localparam [3:0]  STATE_LAST_END  = 4'd12;  // push the last byte
   localparam [3:0]  STATE_DONE      = 4'd13;  // host interrupt

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           shift_data;
   wire           host0;
   wire           host1;
   wire           count1_zero;
   wire           leave;
   wire           shift_term;
   wire           in_prev0;
   wire           fifo_b_empty;
   wire           last;

   assign shift_data           = in_data[7];      // the bit on TDI
   assign host0                = in_data[8];      // toggles: start
   assign host1                = in_data[9];      // 1 = walk, 0 = scan
   assign count1_zero          = in_data[10];     // half period done
   assign leave                = in_data[11];     // count2 (0) >= COMPARE: COMPARE = 0, the last bit leaves the shift state
   assign shift_term           = in_data[14];     // the eighth bit of the byte
   assign in_prev0             = in_data[16];     // host_in[0] at the last start
   assign fifo_b_empty         = in_data[26];
   assign last                 = in_data[29];     // count3 >= LIMIT3: the last bit of the operation

   // =======================================================
   // Outputs
   // =======================================================
   reg            tck;            // pin_out[0]
   reg            count3_hi;      // pin_out[3]: count3 command bit 1 (10 = clear)
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count2_inc;
   reg            count2_dec;     // with inc: clear count2
   reg            count3_lo;      // OUT_COUNT3: command bit 0 (01 = +1)
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B (pop), 0 = FIFO A (push)

   assign out_data[0]          = tck;
   assign out_data[3]          = count3_hi;
   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[8]          = shift_en;
   assign out_data[9]          = count2_inc;
   assign out_data[10]         = count2_dec;
   assign out_data[11]         = count3_lo;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
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

      tck            = 1'b0;
      count3_hi      = 1'b0;
      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      count2_inc     = 1'b0;
      count2_dec     = 1'b0;
      count3_lo      = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      cond_out[0]    = 1'b0;      // TMS
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:
         begin
            if (host0 != in_prev0)                 // start: the bit count and the mode flag from zero
            begin
               count3_hi   = 1'b1;                 // count3 <= 0
               count2_inc  = 1'b1;
               count2_dec  = 1'b1;                 // count2 <= 0
               next_state  = STATE_NEXT;
            end
         end

      STATE_NEXT:                                  // the next byte, by mode
         begin
            if (fifo_b_empty)                      // nothing to send: the operation ends here
               next_state = STATE_DONE;
            else if (host1)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_WALK_L;
            end
            else if (!host1 && leave)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_SCAN_L;
            end
            else if (!host1 && !leave)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_STAY_L;
            end
         end

      // ---- scan: TDI from the byte, TMS 1 on the last bit
      STATE_SCAN_L:                              // TCK low; the last bit takes its own high state
         begin
            cond_out[0] = 1'b0;                    // TMS: 1 on the last bit
            if (last)
               cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && last)
            begin
               count1_load = 1'b1;
               next_state  = STATE_SCAN_HL;
            end
            else if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_SCAN_H;
            end
         end

      STATE_SCAN_H:                              // TCK high; TDO is taken at its end
         begin
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && shift_term)         // the eighth bit of a byte
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_SCAN_L;
            end
         end

      STATE_SCAN_HL:                             // TCK high of the last bit
         begin
            cond_out[0] = 1'b1;                    // TMS 1: the last bit leaves the shift state
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;
               next_state  = STATE_LAST_END;
            end
         end

      // ---- scan that stays: TMS 0 on the last bit too, the next operation continues
      STATE_STAY_L:                              // TCK low; the last bit takes its own high state
         begin
            count1_dec  = 1'b1;
            if (count1_zero && last)
            begin
               count1_load = 1'b1;
               next_state  = STATE_STAY_HL;
            end
            else if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_STAY_H;
            end
         end

      STATE_STAY_H:                              // TCK high; TDO is taken at its end
         begin
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && shift_term)         // the eighth bit of a byte
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_STAY_L;
            end
         end

      STATE_STAY_HL:                             // TCK high of the last bit
         begin
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;
               next_state  = STATE_LAST_END;
            end
         end

      // ---- walk: TMS is the bit itself
      STATE_WALK_L:                              // TCK low; the last bit takes its own high state
         begin
            cond_out[0] = 1'b0;                    // TMS = the pattern bit
            if (shift_data)
               cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && last)
            begin
               count1_load = 1'b1;
               next_state  = STATE_WALK_HL;
            end
            else if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_WALK_H;
            end
         end

      STATE_WALK_H:                              // TCK high; TDO is taken at its end
         begin
            cond_out[0] = 1'b0;                    // TMS = the pattern bit
            if (shift_data)
               cond_out[0] = 1'b1;
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero && shift_term)         // the eighth bit of a byte
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               next_state  = STATE_BYTE_END;
            end
            else if (count1_zero)
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_WALK_L;
            end
         end

      STATE_WALK_HL:                             // TCK high of the last bit
         begin
            cond_out[0] = 1'b0;                    // TMS = the pattern bit
            if (shift_data)
               cond_out[0] = 1'b1;
            tck         = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;
               next_state  = STATE_LAST_END;
            end
         end

      // ---- byte boundaries: the byte received goes to FIFO A
      STATE_BYTE_END:
         begin
            fifo_op    = 1'b1;
            next_state = STATE_NEXT;
         end

      STATE_LAST_END:
         begin
            fifo_op    = 1'b1;
            next_state = STATE_DONE;
         end

      STATE_DONE:
         begin
            host_irq   = 1'b1;
            next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
