// =======================================================
// PRISM FIFO loopback Chroma
//
// Exercises the unfractured two-FIFO mode: shard 0 owns its own FIFO (A)
// and shard 1's (B).  With A configured RX (host reads) and B configured
// TX (host writes, through the shard 1 window), the FSM moves every byte
// the host pushes into B across to A, counting them in count2:
//
//   IDLE:  wait for B not empty (input 26) and A not full (input 21)
//   POP:   OUT_FIFO_WR_RD with OUT_FIFO_PUSH_POP = 1 -> pop B into comm
//   PUSH:  OUT_FIFO_WR_RD with OUT_FIFO_PUSH_POP = 0 -> push comm into A
//
// Host side: write CFG0 of shard 1 (0x180) with fifo_dir = TX, push bytes
// at 0x1A0, read them back at 0x120; count2 (0x110) counts the bytes.
// No pins are driven.
// =======================================================
module chroma_fifo_loop
(
   input  wire          clk,
   input  wire          rst_n,
   input  wire          fsm_enable,
   input  wire [31:0]   in_data,       // Inputs to the PRISM
   output wire [20:0]   out_data,      // FSM outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,      // CFG0 for this chroma (all defaults: FIFO A is RX)
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects
);

   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
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
   localparam [1:0]  STATE_IDLE         = 2'h0;
   localparam [1:0]  STATE_POP          = 2'h1;
   localparam [1:0]  STATE_PUSH         = 2'h2;

   reg   [1:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           fifo_a_full;
   wire           fifo_b_empty;

   assign fifo_a_full          = in_data[21];      // own FIFO flag slot F (default full)
   assign fifo_b_empty         = in_data[26];      // FIFO B flag slot E (default empty)

   // =======================================================
   // Outputs
   // =======================================================
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count2_inc;     // OUT_COUNT2_INC
   reg            push_pop;       // OUT_FIFO_PUSH_POP (unfractured: 1 = the TX FIFO)

   assign out_data[5]          = fifo_op;
   assign out_data[9]          = count2_inc;
   assign out_data[15]         = push_pop;
   // other out_data bits unused by this chroma

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
      next_state     = curr_state;

      fifo_op        = 1'b0;
      count2_inc     = 1'b0;
      push_pop       = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = 32'h0;

      case (curr_state)
      STATE_IDLE:
         begin
            if (!fifo_b_empty && !fifo_a_full)
               next_state = STATE_POP;
         end

      STATE_POP:
         begin
            fifo_op    = 1'b1;                     // pop B into comm
            push_pop   = 1'b1;
            next_state = STATE_PUSH;
         end

      STATE_PUSH:
         begin
            fifo_op    = 1'b1;                     // push comm into A
            count2_inc = 1'b1;
            next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
