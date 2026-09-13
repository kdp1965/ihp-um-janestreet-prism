// =======================================================
// PRISM edge-capture Chroma
//
// Exercises the in_prev edge-capture flops: in_prev[0] (input 16) follows
// ui_in[2] (input 2) and in_prev[1] (input 17) follows host_in[0] (input
// 8), both configured by the host in CFG1 (source numbers 2 and 8).  A
// flop captures its source only when a decision tree that reads that
// source fires and the jump is executed, so "input != in_prev" is true
// exactly once per transition:
//
//   WAIT:      if (pin ^ in_prev0)       -> CNT_PIN   (captures in_prev0)
//              else if (host0 ^ in_prev1) -> CNT_HOST  (captures in_prev1)
//   CNT_PIN:   count2 += 1                -> WAIT
//   CNT_HOST:  count1 += 1                -> WAIT
//
// count2 ends up counting the pin transitions and count1 (counting up) the
// host_in[0] toggles.  No pins are driven.
// =======================================================
module chroma_edge
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

   localparam [0:0]  COUNT_UP           = 1'b1;       // count1 counts up
   localparam [20:0] PINMUX             = 21'h1FFFFF; // no pins driven

   // =======================================================
   // States
   // =======================================================
   localparam [1:0]  STATE_WAIT         = 2'h0;
   localparam [1:0]  STATE_CNT_PIN      = 2'h1;
   localparam [1:0]  STATE_CNT_HOST     = 2'h2;

   reg   [1:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           pin;
   wire           host0;
   wire           in_prev0;
   wire           in_prev1;

   assign pin                  = in_data[2];
   assign host0                = in_data[8];
   assign in_prev0             = in_data[16];
   assign in_prev1             = in_data[17];

   // =======================================================
   // Outputs
   // =======================================================
   reg            count1_inc;     // OUT_COUNT1_INC_DEC
   reg            count2_inc;     // OUT_COUNT2_INC

   assign out_data[6]          = count1_inc;
   assign out_data[9]          = count2_inc;
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

      count1_inc     = 1'b0;
      count2_inc     = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {17'h0, COUNT_UP, 14'h0};

      case (curr_state)
      STATE_WAIT:
         begin
            if (pin ^ in_prev0)
               next_state = STATE_CNT_PIN;
            else if (host0 ^ in_prev1)
               next_state = STATE_CNT_HOST;
         end

      STATE_CNT_PIN:
         begin
            count2_inc = 1'b1;
            next_state = STATE_WAIT;
         end

      STATE_CNT_HOST:
         begin
            count1_inc = 1'b1;
            next_state = STATE_WAIT;
         end

      default:
         next_state = STATE_WAIT;
      endcase
   end

endmodule
