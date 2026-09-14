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
   localparam [31:0] CTRL               = 32'h4EF20300;
   // uo_out[1] = cond_out[0] (TXD), uo_out[2] = pin_out[0] (TX_EN)
   localparam [20:0] PINMUX             = 21'h1FFFC4;

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
