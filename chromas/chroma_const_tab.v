// =======================================================
// PRISM constant-table Chroma
//
// Exercises CONST_TAB (+0x4C): the shard's 16x8 latch FIFO as addressable
// constants.  When host_in[0] goes high the FSM performs six comm loads,
// each with a different index mode in {OUT_K_SEL1, OUT_K_SEL0}, and pushes
// each loaded byte into its FIFO (the SRAM FIFO, RX: the host reads the
// bytes back; the latch FIFO is the table):
//
//   L0: clear   L1: + 1   L1B: + 1   L2: + add_to_idx   L3: = / + idx_load   L1C: + 1
//
// then waits for host_in[0] to go low again.  count2 counts the pushes.
// Without CONST_TAB enabled the same loads take preload[7:0] or, with
// CFG0 comm_load_k, K[{OUT_K_SEL1, OUT_K_SEL0}].  No pins are driven.
// =======================================================
module chroma_const_tab
(
   input  wire          clk,
   input  wire          rst_n,
   input  wire          fsm_enable,
   input  wire [31:0]   in_data,       // Inputs to the PRISM
   output wire [20:0]   out_data,      // FSM outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,      // CFG0 for this chroma: the SRAM FIFO, RX
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects
);

   localparam [2:0]  PIN_OFF   = 3'd7;
   localparam [20:0] PINMUX    = {PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF};
   localparam [31:0] CTRL      = 32'h80000000;    // CFG_FIFO_SRAM (fifo_dir = RX)

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE = 4'h0;
   localparam [3:0]  STATE_L0   = 4'h1;
   localparam [3:0]  STATE_P0   = 4'h2;
   localparam [3:0]  STATE_L1   = 4'h3;
   localparam [3:0]  STATE_P1   = 4'h4;
   localparam [3:0]  STATE_L1B  = 4'h5;
   localparam [3:0]  STATE_P1B  = 4'h6;
   localparam [3:0]  STATE_L2   = 4'h7;
   localparam [3:0]  STATE_P2   = 4'h8;
   localparam [3:0]  STATE_L3   = 4'h9;
   localparam [3:0]  STATE_P3   = 4'hA;
   localparam [3:0]  STATE_L1C  = 4'hB;
   localparam [3:0]  STATE_P1C  = 4'hC;
   localparam [3:0]  STATE_WAIT = 4'hD;

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           host0;
   assign host0 = in_data[8];             // host_in[0]

   // =======================================================
   // Outputs
   // =======================================================
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count2_inc;     // OUT_COUNT2_INC
   reg            comm_load;      // OUT_COMM_LOAD
   reg            ksel0;          // OUT_K_SEL0: index mode bit 0
   reg            ksel1;          // OUT_K_SEL1: index mode bit 1

   assign out_data[5]          = fifo_op;
   assign out_data[9]          = count2_inc;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
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

      fifo_op        = 1'b0;
      count2_inc     = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = CTRL;

      case (curr_state)
      STATE_IDLE:
         begin
            if (host0)
               next_state = STATE_L0;
         end

      STATE_L0:                                   // clear the index
         begin
            comm_load  = 1'b1;
            next_state = STATE_P0;
         end
      STATE_P0:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_L1;
         end

      STATE_L1:                                   // + 1
         begin
            comm_load  = 1'b1;
            ksel0      = 1'b1;
            next_state = STATE_P1;
         end
      STATE_P1:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_L1B;
         end

      STATE_L1B:                                  // + 1
         begin
            comm_load  = 1'b1;
            ksel0      = 1'b1;
            next_state = STATE_P1B;
         end
      STATE_P1B:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_L2;
         end

      STATE_L2:                                   // + add_to_idx
         begin
            comm_load  = 1'b1;
            ksel1      = 1'b1;
            next_state = STATE_P2;
         end
      STATE_P2:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_L3;
         end

      STATE_L3:                                   // = idx_load (or + idx_load)
         begin
            comm_load  = 1'b1;
            ksel0      = 1'b1;
            ksel1      = 1'b1;
            next_state = STATE_P3;
         end
      STATE_P3:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_L1C;
         end

      STATE_L1C:                                  // + 1
         begin
            comm_load  = 1'b1;
            ksel0      = 1'b1;
            next_state = STATE_P1C;
         end
      STATE_P1C:
         begin
            fifo_op    = 1'b1;
            count2_inc = 1'b1;
            next_state = STATE_WAIT;
         end

      STATE_WAIT:
         begin
            if (!host0)
               next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
