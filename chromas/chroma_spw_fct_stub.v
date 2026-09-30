// =======================================================
// PRISM SpaceWire test stub: "an FCT arrived" (3 states)
//
// Stands in for the receiving shard in the transmitter's fractured test:
// a toggle of host_in[0] sets the semaphore towards the other shard
// COUNT2 times, two clocks apart (the fastest a semaphore can repeat), as
// a receiver does for every FCT it decodes, and holds pin_out[1] up, the
// receiver's "a link is coming in".  No pins.
//
// Host side: CFG1 in_prev0 <- host_in[0] (8); COMPARE = 1; COUNT2 = the
// number of semaphores, then the toggle.
// =======================================================
module chroma_spw_fct_stub
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

   localparam [2:0]  PIN_OFF   = 3'd7;
   localparam [20:0] PINMUX    = {7{PIN_OFF}};

   localparam [1:0]  STATE_IDLE      = 2'd0;
   localparam [1:0]  STATE_SET       = 2'd1;
   localparam [1:0]  STATE_GAP       = 2'd2;

   reg   [1:0]    curr_state, next_state;

   wire           host0;
   wire           more;
   wire           in_prev0;

   assign host0                = in_data[8];
   assign more                 = in_data[11];     // count2 >= COMPARE (1)
   assign in_prev0             = in_data[16];

   reg            link;           // pin_out[1]: the transmitter's input 26
   reg            count2_dec;
   reg            sema_set;       // OUT_SEMA_SET

   assign out_data[1]          = link;
   assign out_data[10]         = count2_dec;
   assign out_data[19]         = sema_set;
   // other out_data bits unused by this chroma

   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 2'h0;
      else
         curr_state <= fsm_enable ? next_state : 2'h0;
   end

   always @*
   begin
      next_state     = curr_state;

      link           = 1'b1;
      count2_dec     = 1'b0;
      sema_set       = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = 32'h0;

      case (curr_state)
      STATE_IDLE:
         begin
            if (host0 != in_prev0)
               next_state  = STATE_SET;
         end

      STATE_SET:
         begin
            if (more)
            begin
               sema_set    = 1'b1;
               count2_dec  = 1'b1;
               next_state  = STATE_GAP;
            end
            else if (!more)
               next_state  = STATE_IDLE;
         end

      STATE_GAP:
         begin
            next_state  = STATE_SET;
         end
      endcase
   end

endmodule
