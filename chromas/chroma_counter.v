// =======================================================
// PRISM up / down counter Chroma (test of the CRC register's counter mode)
//
// With CFG3[10] the shard's 32-bit CRC register is an up / down counter
// on the CRC strobes (OUT_CRC_CLEAR presets, OUT_CRC_UPDATE + 1,
// OUT_LOAD_CRC - 1) and input 22 (crc_ok) is "count >= CRC_EXPECTED".
// This chroma steps the counter once per ui_in[2] transition, up when
// host_in[1] is 0 and down when it is 1, presets it on every host_in[0]
// toggle, and counts in count2 the steps that end at or above the compare
// value.  uo_out[1] shows the compare (cond_out[0] = input 22) all the time.
// The edge detection is the chroma_edge scheme: in_prev[0] (input 16)
// follows ui_in[2] and in_prev[1] (input 17) follows host_in[0], both
// set up by the host in CFG1 (sources 2 and 8), captured when the
// decision that reads the source fires.
//
//   WAIT:   if (pin ^ in_prev0)        -> STEP    (captures in_prev0)
//           else if (host0 ^ in_prev1) -> ZERO    (captures in_prev1)
//   STEP:   if (host1) -> DOWN else -> UP
//   UP:     OUT_CRC_UPDATE             -> CHECK
//   DOWN:   OUT_LOAD_CRC               -> CHECK
//   CHECK:  if (count >= compare)      -> HIT else -> WAIT
//   HIT:    count2 += 1                -> WAIT
//   ZERO:   OUT_CRC_CLEAR              -> WAIT
// =======================================================
module chroma_counter
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
   localparam [2:0]  UO1_SRC  = PIN_COND0;      // count >= compare
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
   localparam [2:0]  STATE_WAIT         = 3'h0;
   localparam [2:0]  STATE_STEP         = 3'h1;
   localparam [2:0]  STATE_UP           = 3'h2;
   localparam [2:0]  STATE_DOWN         = 3'h3;
   localparam [2:0]  STATE_CHECK        = 3'h4;
   localparam [2:0]  STATE_HIT          = 3'h5;
   localparam [2:0]  STATE_ZERO         = 3'h6;

   reg   [2:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           pin;
   wire           host0;
   wire           host1;
   wire           in_prev0;
   wire           in_prev1;
   wire           cnt_ge;

   assign pin                  = in_data[2];
   assign host0                = in_data[8];
   assign host1                = in_data[9];
   assign in_prev0             = in_data[16];
   assign in_prev1             = in_data[17];
   assign cnt_ge               = in_data[22];    // crc_ok: count >= compare in counter mode

   // =======================================================
   // Outputs
   // =======================================================
   reg            count2_inc;     // OUT_COUNT2_INC
   reg            crc_clear;      // OUT_CRC_CLEAR:  counter preset
   reg            crc_update;     // OUT_CRC_UPDATE: counter + 1
   reg            load_crc;       // OUT_LOAD_CRC:   counter - 1

   assign out_data[9]          = count2_inc;
   assign out_data[12]         = crc_clear;
   assign out_data[13]         = crc_update;
   assign out_data[17]         = load_crc;
   // other out_data bits unused by this chroma

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 3'h0;
      else
         curr_state <= fsm_enable ? next_state : 3'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state     = curr_state;

      count2_inc     = 1'b0;
      crc_clear      = 1'b0;
      crc_update     = 1'b0;
      load_crc       = 1'b0;
      cond_out[0]    = 1'b0;
      if (cnt_ge)
         cond_out[0] = 1'b1;           // uo_out[1] = count >= compare, in every state
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = 32'h0;          // crc_mode 0: the register is free for the counter

      case (curr_state)
      STATE_WAIT:
         begin
            if (pin ^ in_prev0)
               next_state = STATE_STEP;
            else if (host0 ^ in_prev1)
               next_state = STATE_ZERO;
         end

      STATE_STEP:
         begin
            if (host1)
               next_state = STATE_DOWN;
            else
               next_state = STATE_UP;
         end

      STATE_UP:
         begin
            crc_update = 1'b1;
            next_state = STATE_CHECK;
         end

      STATE_DOWN:
         begin
            load_crc   = 1'b1;
            next_state = STATE_CHECK;
         end

      STATE_CHECK:
         begin
            if (cnt_ge)
               next_state = STATE_HIT;
            else
               next_state = STATE_WAIT;
         end

      STATE_HIT:
         begin
            count2_inc = 1'b1;
            next_state = STATE_WAIT;
         end

      STATE_ZERO:
         begin
            crc_clear  = 1'b1;
            next_state = STATE_WAIT;
         end

      default:
         next_state = STATE_WAIT;
      endcase
   end

endmodule
