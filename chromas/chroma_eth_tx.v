// =======================================================
// PRISM 10BASE-T transmitter Chroma (evaluation, v1)
//
// Sends Ethernet frames from the shard's TX FIFO (meant to be the 8 KB
// SRAM FIFO) with Manchester coding at 6 clocks per bit: count1 is the
// half-bit timer (preload = 2 -> a terminal count every 3 clocks) and the
// line is cond_out[0] = shift_data ^ first_half, i.e. the LUT of the
// shifter's output bit, so a bit costs two states and no decision.
//
//   TXD   = uo_out[1] (cond_out[0]),  TX_EN = uo_out[2] (pin_out[0])
//
// Frame: 4 x 0x55 from constant K0, then 4 bytes from the FIFO (the host
// queues 55 55 55 D5 in front of the frame so the SFD comes with it),
// then the frame bytes until the FIFO is empty with the CRC32 running on
// every transmitted bit, then the four FCS bytes from the CRC unit
// (OUT_LOAD_CRC through comm, low byte first), then TP_IDL: two bit
// times high, release.  count2 counts bytes / half bits in each of those
// phases against compare = 3.  A toggle of host_in[0] starts a frame
// (in_prev edge), a toggle of host_in[1] sends a link pulse (one bit high).
// The host interrupt is raised at the end of the frame.
//
// Not in v1 (findings): inter-frame gap timing, the 16 ms link-pulse
// timer (the CPU asks for pulses), collision / carrier sense, receive.
//
// Host set-up: CFG1 in_prev0 <- input 8 (host_in[0]), in_prev1 <- 9;
// CONST K0 = 0x55; compare = 3; preload = 2; CFG0 |= FIFO_SRAM as wanted;
// CRC poly 0xEDB88320.
// =======================================================
module chroma_eth_tx
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

   // CFG0: shift_en, LSB first, comm_load_one, CRC32 reflected init ones
   // xor out over the transmitted bit, TX FIFO, comm loads from CONST
   // CFG0 (ctrl_reg), one named field per bit group
   localparam [0:0]  FIFO_SRAM      = 1'd0;  // 0 = the flop FIFO; the host may OR CFG_FIFO_SRAM in for the SRAM FIFO
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}] instead of preload[7:0]
   localparam [0:0]  FLAG_LATCH     = 1'd0;  // OUT_LATCH stores {cond_out[1:0]} in latched_in and out19 in flag2
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;  // shifter input = cond_out[0] instead of a pin
   localparam [0:0]  CRC_SRC_OUT    = 1'd1;  // 0 = CRC over the shifter input bit, 1 = over its output bit
   localparam [0:0]  CRC_XOR_OUT    = 1'd1;  // complement the CRC on OUT_LOAD_CRC
   localparam [0:0]  CRC_INIT_ONES  = 1'd1;  // OUT_CRC_CLEAR presets all ones instead of zero
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;  // semaphore set beats clear in the same cycle
   localparam [0:0]  FIFO_DIR_TX    = 1'd1;  // 0 = RX (FSM pushes, host reads), 1 = TX (host writes, FSM pops)
   localparam [0:0]  CRC_REFLECT    = 1'd1;  // 1 = LSB-first LFSR (reflected polynomial)
   localparam [1:0]  CRC_MODE       = 2'd3;  // 0 off, 1 = CRC8, 2 = CRC16, 3 = CRC32
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [0:0]  COMM_LOAD_ONE  = 1'd1;  // OUT_COMM_LOAD also loads a 1 into the shifter
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;  // OUT_SHIFT with preload loads a 1
   localparam [0:0]  WRAP_PRELOAD   = 1'd0;  // count1 wraps to preload
   localparam [0:0]  COUNT_UP       = 1'd0;  // count1 counts up (0 = down)
   localparam [0:0]  LATCH2         = 1'd0;  // use prism_out[2] as input latch enable
   localparam [0:0]  COUNT2_DEC     = 1'd0;  // count2 decrement enable
   localparam [0:0]  COUNT32        = 1'd0;  // 32-bit count1 (0 = 24-bit)
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // wide shifter (count1) instead of comm
   localparam [0:0]  SHIFT_DIR      = 1'd1;  // 1 = shift right (LSB first, newest bit at the top)
   localparam [0:0]  SHIFT_EN       = 1'd1;  // enable shift operation
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;  // read back latched outputs instead of inputs
   localparam [0:0]  CLR_NOT_LOAD   = 1'd0;  // OUT_COUNT1_CLEAR_LOAD clears (1) or loads from preload (0)
   localparam [1:0]  SHIFT_IN_SEL   = 2'd0;  // shifter input pin ui_in[k]
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   // uo_out[1] = cond_out[0] (TXD), uo_out[2] = pin_out[0] (TX_EN)
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_COND0;
   localparam [2:0]  UO2_SRC  = PIN_OUT0;
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  ST_IDLE      = 4'd0;
   localparam [3:0]  ST_A_H1      = 4'd1;    // preamble from K0
   localparam [3:0]  ST_A_H2      = 4'd2;
   localparam [3:0]  ST_A_H2L     = 4'd3;
   localparam [3:0]  ST_B_H1      = 4'd4;    // preamble / SFD from the FIFO
   localparam [3:0]  ST_B_H2      = 4'd5;
   localparam [3:0]  ST_B_H2L     = 4'd6;
   localparam [3:0]  ST_D_H1      = 4'd7;    // frame bytes, CRC running
   localparam [3:0]  ST_D_H2      = 4'd8;
   localparam [3:0]  ST_D_H2L     = 4'd9;
   localparam [3:0]  ST_F_H1      = 4'd10;   // FCS bytes from the CRC
   localparam [3:0]  ST_F_H2      = 4'd11;
   localparam [3:0]  ST_F_H2L     = 4'd12;
   localparam [3:0]  ST_IDL       = 4'd13;   // TP_IDL: high for two bit times
   localparam [3:0]  ST_NLP_A     = 4'd14;   // link pulse: high for one bit time
   localparam [3:0]  ST_NLP_B     = 4'd15;

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire shift_data  = in_data[7];
   wire host0       = in_data[8];
   wire host1       = in_data[9];
   wire count1_zero = in_data[10];   // half-bit timer
   wire count2_cmp  = in_data[11];   // count2 >= 3
   wire shift_term  = in_data[14];   // last bit of the byte
   wire in_prev0    = in_data[16];   // host_in[0] at the last start
   wire in_prev1    = in_data[17];   // host_in[1] at the last pulse
   wire fifo_empty  = in_data[20];

   // =======================================================
   // Outputs
   // =======================================================
   reg tx_en;                  // pin_out[0]
   reg fifo_pop;               // OUT_FIFO_WR_RD (TX: pop into comm)
   reg count1_dec;             // OUT_COUNT1_INC_DEC
   reg count1_load;            // OUT_COUNT1_CLEAR_LOAD
   reg shift;                  // OUT_SHIFT
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_clear;           // OUT_COUNT2_CLEAR
   reg crc_clear;              // OUT_CRC_CLEAR
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD (K0)
   reg load_crc;               // OUT_LOAD_CRC

   assign out_data[0]  = tx_en;
   assign out_data[5]  = fifo_pop;
   assign out_data[6]  = count1_dec;
   assign out_data[7]  = count1_load;
   assign out_data[8]  = shift;
   assign out_data[9]  = count2_inc;
   assign out_data[11] = count2_clear;
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

      tx_en        = 1'b0;
      fifo_pop     = 1'b0;
      count1_dec   = 1'b1;      // the half-bit timer runs in every state
      count1_load  = 1'b0;
      shift        = 1'b0;
      count2_inc   = 1'b0;
      count2_clear = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      load_crc     = 1'b0;
      cond_out[0]  = 1'b0;      // TXD (only driven with TX_EN)
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_IDLE:
         begin
            if (host0 != in_prev0)            // frame: first preamble byte from K0
            begin
               comm_load    = 1'b1;
               count2_clear = 1'b1;
               count1_load  = 1'b1;
               next_state   = ST_A_H1;
            end
            else if (host1 != in_prev1)       // link pulse
            begin
               count1_load  = 1'b1;
               next_state   = ST_NLP_A;
            end
         end

      // ---- bit engine: H1 drives !bit for a half bit, H2 drives bit ------
      // ---- preamble from K0 (no CRC), four bytes counted by count2 -------
      ST_A_H1:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (count1_zero && !shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_A_H2;
            end
            else if (count1_zero && shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_A_H2L;
            end
         end

      ST_A_H2:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               shift       = 1'b1;
               next_state  = ST_A_H1;
            end
         end

      ST_A_H2L:                              // last bit of a K0 byte
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero && !count2_cmp)
            begin
               count1_load = 1'b1;
               comm_load   = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_A_H1;
            end
            else if (count1_zero && count2_cmp)
            begin
               count1_load  = 1'b1;
               fifo_pop     = 1'b1;          // first FIFO byte (preamble / SFD)
               count2_clear = 1'b1;
               next_state   = ST_B_H1;
            end
         end

      // ---- preamble / SFD from the FIFO (no CRC), four bytes -------------
      ST_B_H1:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (count1_zero && !shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_B_H2;
            end
            else if (count1_zero && shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_B_H2L;
            end
         end

      ST_B_H2:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               shift       = 1'b1;
               next_state  = ST_B_H1;
            end
         end

      ST_B_H2L:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero && !count2_cmp)
            begin
               count1_load = 1'b1;
               fifo_pop    = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_B_H1;
            end
            else if (count1_zero && count2_cmp)
            begin
               count1_load = 1'b1;
               fifo_pop    = 1'b1;           // first frame byte
               crc_clear   = 1'b1;
               next_state  = ST_D_H1;
            end
         end

      // ---- frame bytes, CRC over every transmitted bit --------------------
      ST_D_H1:                               // the CRC takes the bit mid-bit, so the
         begin                               // FCS load at the byte end sees it
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (count1_zero && !shift_term)
            begin
               count1_load = 1'b1;
               crc_update  = 1'b1;
               next_state  = ST_D_H2;
            end
            else if (count1_zero && shift_term)
            begin
               count1_load = 1'b1;
               crc_update  = 1'b1;
               next_state  = ST_D_H2L;
            end
         end

      ST_D_H2:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               shift       = 1'b1;
               next_state  = ST_D_H1;
            end
         end

      ST_D_H2L:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero && !fifo_empty)
            begin
               count1_load = 1'b1;
               fifo_pop    = 1'b1;
               next_state  = ST_D_H1;
            end
            else if (count1_zero && fifo_empty)
            begin
               count1_load  = 1'b1;
               load_crc     = 1'b1;          // FCS byte 0 (the CRC is complete)
               count2_clear = 1'b1;
               next_state   = ST_F_H1;
            end
         end

      // ---- FCS: four bytes from the CRC (no update), count2 --------------
      ST_F_H1:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (count1_zero && !shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_F_H2;
            end
            else if (count1_zero && shift_term)
            begin
               count1_load = 1'b1;
               next_state  = ST_F_H2L;
            end
         end

      ST_F_H2:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               shift       = 1'b1;
               next_state  = ST_F_H1;
            end
         end

      ST_F_H2L:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (count1_zero && !count2_cmp)
            begin
               count1_load = 1'b1;
               load_crc    = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_F_H1;
            end
            else if (count1_zero && count2_cmp)
            begin
               count1_load  = 1'b1;
               count2_clear = 1'b1;
               next_state   = ST_IDL;
            end
         end

      // ---- TP_IDL: high for four half bits, then release, interrupt -------
      ST_IDL:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (count1_zero && !count2_cmp)
            begin
               count1_load = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_IDL;
            end
            else if (count1_zero && count2_cmp)
            begin
               host_irq   = 1'b1;
               next_state = ST_IDLE;
            end
         end

      // ---- link pulse: high for one bit time ------------------------------
      ST_NLP_A:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_NLP_B;
            end
         end

      ST_NLP_B:
         begin
            tx_en = 1'b1;
            cond_out[0] = 1'b1;
            if (count1_zero)
               next_state = ST_IDLE;
         end

      default:
         next_state = ST_IDLE;
      endcase
   end

endmodule
