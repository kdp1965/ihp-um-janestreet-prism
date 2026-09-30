// =======================================================
// PRISM VGA line shard (shard 0 of the vga pair, v1, 2026-09-30)
//
// The vertical half of the VGA timing: it counts the lines the pixel shard
// (chroma_vga_px, shard 1) clocks over the semaphore, one set per line at
// the hsync, and drives VSync (negative, pin_out[0] on uo_out[3]) and the
// "active" flag (pin_out[1], the pixel shard's input 26) that tells it
// whether the next line carries pixels or black.
//
// The 480 active lines are counted in the 32-bit counter (CFG3[10],
// CRC_EXPECTED = 479); the 45 blanking lines in count2 against comm, which
// each blanking state loads with its constant: K1 = the front porch end
// (10 lines), K2 = the end of the sync pulse (12), K3 = the end of the
// frame (45).  The line shard reads the semaphore two clocks after the
// pixel shard sets it and clears it at once, so VSync moves with the
// hsync edge.  Nothing else: the TX DMA feeding FIFO B (each source line
// four times, 160 bytes per line) is the host's business.
//
// Host set-up (shard 0): CFG3 = CNT_EN, CRC (preset) = 0, CRC_EXPECTED =
// 479, CONST = K3 45 | K2 12 | K1 10 (the test uses shorter frames).
// =======================================================
module chroma_vga_ln
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

   // CFG0: comm loads from the constants (the blanking line counts); the
   // CRC register is the active line counter (crc_mode 0, CFG3[10]); the
   // semaphore clear wins a same-cycle set (never happens: one set per line)
   localparam [31:0] CTRL      = 32'h4000_0000;

   // uo_out[3] = VSync; every other pin is the pixel shard's
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO0_SRC  = PIN_OFF;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
   localparam [2:0]  UO2_SRC  = PIN_OFF;
   localparam [2:0]  UO3_SRC  = PIN_OUT0;          // VSync (negative)
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [23:0] PINMUX    = {UO0_SRC, UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [1:0]  ST_VACT   = 2'd0;   // active lines: the counter per line
   localparam [1:0]  ST_VFP    = 2'd1;   // vertical front porch: count2 to K1
   localparam [1:0]  ST_VS     = 2'd2;   // vsync low: count2 to K2
   localparam [1:0]  ST_VBP    = 2'd3;   // vertical back porch: count2 to K3

   reg   [1:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire eq_comm     = in_data[15];   // count2 == comm (the blanking constant)
   wire cnt_ge      = in_data[22];   // counter mode: the last active line
   wire sema        = in_data[24];   // the pixel shard's line clock

   // =======================================================
   // Outputs
   // =======================================================
   reg vsync_n;                // pin_out[0] -> uo_out[3]
   reg active;                 // pin_out[1] -> the pixel shard's input 26
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_dec;             // OUT_COUNT2_DEC (with inc: clear)
   reg crc_clear;              // OUT_CRC_CLEAR: counter preset (0)
   reg crc_update;             // OUT_CRC_UPDATE: counter + 1
   reg sema_clear;             // OUT_SEMA_CLEAR
   reg comm_load;              // OUT_COMM_LOAD: K[{k_sel1, k_sel0}]
   reg k_sel0;                 // OUT_K_SEL0
   reg k_sel1;                 // OUT_K_SEL1

   assign out_data[0]  = vsync_n;
   assign out_data[1]  = active;
   assign out_data[9]  = count2_inc;
   assign out_data[10] = count2_dec;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[15] = sema_clear;
   assign out_data[16] = comm_load;
   assign out_data[18] = k_sel0;
   assign out_data[20] = k_sel1;

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 2'h0;
      else
         curr_state <= fsm_enable ? next_state : 2'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state   = curr_state;

      vsync_n      = 1'b1;
      active       = 1'b0;
      count2_inc   = 1'b0;
      count2_dec   = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      sema_clear   = 1'b0;
      comm_load    = 1'b0;
      k_sel0       = 1'b0;
      k_sel1       = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_VACT:
         begin
            active      = 1'b1;
            if (sema && !cnt_ge)             // another active line
            begin
               sema_clear  = 1'b1;
               crc_update  = 1'b1;
               next_state  = ST_VACT;
            end
            else if (sema && cnt_ge)         // the last one: blanking, count2 from 0
            begin
               sema_clear  = 1'b1;
               count2_inc  = 1'b1;
               count2_dec  = 1'b1;
               next_state  = ST_VFP;
            end
         end

      ST_VFP:
         begin
            comm_load   = 1'b1;              // comm = K1
            k_sel0      = 1'b1;
            if (sema && !eq_comm)
            begin
               sema_clear  = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_VFP;
            end
            else if (sema && eq_comm)
            begin
               sema_clear  = 1'b1;
               next_state  = ST_VS;
            end
         end

      ST_VS:
         begin
            vsync_n     = 1'b0;
            comm_load   = 1'b1;              // comm = K2
            k_sel1      = 1'b1;
            if (sema && !eq_comm)
            begin
               sema_clear  = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_VS;
            end
            else if (sema && eq_comm)
            begin
               sema_clear  = 1'b1;
               next_state  = ST_VBP;
            end
         end

      ST_VBP:
         begin
            comm_load   = 1'b1;              // comm = K3
            k_sel0      = 1'b1;
            k_sel1      = 1'b1;
            if (sema && !eq_comm)
            begin
               sema_clear  = 1'b1;
               count2_inc  = 1'b1;
               next_state  = ST_VBP;
            end
            else if (sema && eq_comm)        // frame: counter and count2 from 0
            begin
               sema_clear  = 1'b1;
               crc_clear   = 1'b1;
               count2_inc  = 1'b1;
               count2_dec  = 1'b1;
               next_state  = ST_VACT;
            end
         end

      default:
         next_state = ST_VACT;
      endcase
   end
endmodule
