// =======================================================
// PRISM count2 / count3 command Chroma (test of the count2 command
// encoding and the per-shard count3, 2026-09-27)
//
// count2 takes its commands on two outputs: OUT_COUNT2_INC alone = + 1,
// OUT_COUNT2_DEC alone = - 1, both = clear.  count3 counts up only; its
// command is {pin_out[3] (with CFG0[12]), OUT_COUNT3}: 01 = + 1, 10 = clear,
// 11 = limit <= comm, and input 29 (slot default) is count3 >= limit.
//
// The host queues command bytes in this shard's FIFO (TX mode); the FSM
// pops one at a time and decodes its low three bits through input slots
// 16-18 (comm[0..2]: CFG2 = 0x765):
//   0  count2 + 1
//   1  count2 - 1
//   2  count2 clear
//   3  count3 + 1
//   4  count3 clear
//   5  count3 limit <= comm (the whole command byte is the limit)
//   6  PRELOAD + 1 clocks that decrement count2 in every clock (a sampler
//      count2 + 1 in the same clock cancels one of them)
//   7  host interrupt
// uo_out[1] shows input 29 in every state; uo_out[2] shows pin_out[3],
// which is a plain pin again without CFG0[12].
//
//   IDLE: if (!fifo_empty) pop            -> D
//   D:    comm[2] ? D1 : D0
//   D0:   comm[1] ? D01 : D00             D1:  comm[1] ? D11 : D10
//   D00:  comm[0] ? count2 - 1 : + 1      D10: comm[0] ? count3 limit : clear
//   D01:  comm[0] ? count3 + 1 : count2 clear
//   D11:  comm[0] ? interrupt : load count1 -> WIN
//   WIN:  count2 - 1 every clock until count1 reaches 0
// =======================================================
module chroma_count3
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

   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_COND0;      // count3 >= limit
   localparam [2:0]  UO2_SRC  = PIN_OUT3;       // count3's command bit (a pin without CFG0[12])
   localparam [2:0]  UO3_SRC  = PIN_OFF;
   localparam [2:0]  UO4_SRC  = PIN_OFF;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // CFG0: the FIFO in TX mode (bit 23: the host writes, OUT_FIFO_WR_RD pops
   // into comm) and count3_en (bit 12: pin_out[3] is count3's command bit)
   localparam [31:0] CTRL      = 32'h0080_1000;

   // =======================================================
   // States (explicit `else if` everywhere: no INC transitions)
   // =======================================================
   localparam [3:0]  STATE_IDLE = 4'h0;
   localparam [3:0]  STATE_D    = 4'h1;
   localparam [3:0]  STATE_D0   = 4'h2;
   localparam [3:0]  STATE_D00  = 4'h3;
   localparam [3:0]  STATE_D01  = 4'h4;
   localparam [3:0]  STATE_D1   = 4'h5;
   localparam [3:0]  STATE_D10  = 4'h6;
   localparam [3:0]  STATE_D11  = 4'h7;
   localparam [3:0]  STATE_WIN  = 4'h8;

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           count1_zero;
   wire           op0, op1, op2;
   wire           fifo_empty;
   wire           count3_ge;

   assign count1_zero          = in_data[10];
   assign op0                  = in_data[16];    // slot: comm[0]
   assign op1                  = in_data[17];    // slot: comm[1]
   assign op2                  = in_data[18];    // slot: comm[2]
   assign fifo_empty           = in_data[20];
   assign count3_ge            = in_data[29];    // slot default: count3 >= limit

   // =======================================================
   // Outputs
   // =======================================================
   reg            count3_hi;      // pin_out[3]: count3 command bit 1 (CFG0[12])
   reg            fifo_op;        // OUT_FIFO_WR_RD: pop the next command into comm
   reg            count1_dec;     // OUT_COUNT1_INC_DEC
   reg            count1_load;    // OUT_COUNT1_CLEAR_LOAD
   reg            count2_inc;     // OUT_COUNT2_INC (with dec: clear)
   reg            count2_dec;     // OUT_COUNT2_DEC
   reg            count3_lo;      // OUT_COUNT3: count3 command bit 0
   reg            host_irq;       // OUT_HOST_INTERRUPT

   assign out_data[3]          = count3_hi;
   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[9]          = count2_inc;
   assign out_data[10]         = count2_dec;
   assign out_data[11]         = count3_lo;
   assign out_data[14]         = host_irq;
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

      count3_hi      = 1'b0;
      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      count2_inc     = 1'b0;
      count2_dec     = 1'b0;
      count3_lo      = 1'b0;
      host_irq       = 1'b0;
      cond_out[0]    = 1'b0;
      if (count3_ge)
         cond_out[0] = 1'b1;           // uo_out[1] = count3 >= limit, in every state
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = CTRL;

      case (curr_state)
      STATE_IDLE:
         begin
            if (!fifo_empty)
            begin
               fifo_op    = 1'b1;
               next_state = STATE_D;
            end
         end

      STATE_D:
         begin
            if (op2)
               next_state = STATE_D1;
            else if (!op2)
               next_state = STATE_D0;
         end

      STATE_D0:
         begin
            if (op1)
               next_state = STATE_D01;
            else if (!op1)
               next_state = STATE_D00;
         end

      STATE_D00:                       // 0: count2 + 1, 1: count2 - 1
         begin
            if (op0)
            begin
               count2_dec = 1'b1;
               next_state = STATE_IDLE;
            end
            else if (!op0)
            begin
               count2_inc = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      STATE_D01:                       // 2: count2 clear, 3: count3 + 1
         begin
            if (op0)
            begin
               count3_lo  = 1'b1;
               next_state = STATE_IDLE;
            end
            else if (!op0)
            begin
               count2_inc = 1'b1;
               count2_dec = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      STATE_D1:
         begin
            if (op1)
               next_state = STATE_D11;
            else if (!op1)
               next_state = STATE_D10;
         end

      STATE_D10:                       // 4: count3 clear, 5: count3 limit <= comm
         begin
            if (op0)
            begin
               count3_hi  = 1'b1;
               count3_lo  = 1'b1;
               next_state = STATE_IDLE;
            end
            else if (!op0)
            begin
               count3_hi  = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      STATE_D11:                       // 6: the count2 window, 7: interrupt
         begin
            if (op0)
            begin
               host_irq   = 1'b1;
               next_state = STATE_IDLE;
            end
            else if (!op0)
            begin
               count1_load = 1'b1;
               next_state  = STATE_WIN;
            end
         end

      STATE_WIN:                       // PRELOAD + 1 clocks, count2 - 1 in each
         begin
            count2_dec = 1'b1;
            count1_dec = 1'b1;
            if (count1_zero)
               next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
