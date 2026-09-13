// Compiler regression: a 5-way state (4 conditions + stay) must split into a
// partial upper (INC) and a lower whose stay uses the default path; a
// 2-way "if / else next" must use a tree jump, not INC.
`default_nettype none
module chroma_split
(
   input wire           clk,
   input wire           rst_n,
   input wire           fsm_enable,
   input wire  [31:0]   in_data,
   output wire [20:0]   out_data,
   output reg  [1:0]    cond_out,
   output reg  [31:0]   ctrl_reg
);
   localparam [2:0] S0 = 3'h0, S1 = 3'h1, S2 = 3'h2, S3 = 3'h3, S4 = 3'h4, S5 = 3'h5;
   reg [2:0] curr_state, next_state;
   reg [20:0] outs;
   assign out_data = outs;

   always @(posedge clk or negedge rst_n)
      if (~rst_n) curr_state <= S0;
      else        curr_state <= fsm_enable ? next_state : 3'h0;

   always @*
   begin
      next_state = curr_state;
      outs       = 21'h0;
      cond_out   = 2'b00;
      ctrl_reg   = 32'h0;
      case (curr_state)
      S0: begin                       // 4 conditions + implicit stay
            if (in_data[0])      begin outs = 21'h1; next_state = S1; end
            else if (in_data[1]) begin outs = 21'h2; next_state = S2; end
            else if (in_data[2]) begin outs = 21'h4; next_state = S3; end
            else if (in_data[3]) begin outs = 21'h8; next_state = S4; end
            else outs = 21'h100;
          end
      S1: begin                       // if / else -> next state (no INC wanted)
            if (in_data[4]) next_state = S0;
            else            next_state = S2;
          end
      S2: begin                       // 2 conditions + else -> S5 (needs split)
            if (in_data[5])      next_state = S0;
            else if (in_data[6]) next_state = S1;
            else                 next_state = S5;
          end
      S3: next_state = S0;            // unconditional
      S4: begin end                   // stay only
      S5: begin if (in_data[7]) next_state = S0; end   // 1 condition + stay
      default: next_state = S0;
      endcase
   end
endmodule
