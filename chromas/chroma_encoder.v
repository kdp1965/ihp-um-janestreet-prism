// =======================================================
// PRISM Encoder chroma
//
// This is a Chroma (personality) for the TinyQV PRISM
// peripheral. It implements a rotary encoder that increments
// or decrements the count in count2 depending on the direction
// and speed of rotation.
//
// FSM Deined pin assignments.
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[0]     ui_in[0]      Rotary input a
//   prism_in[1]     ui_in[1]      Rotary input b
//
// This assumes:
//   1. shift_in_sel  = 0 (Shift input data on ui_in[2])
//   2. shift_24_le   = 0 (Enable 8-bit shift)
//   3. shift_en      = 0 (Disalbe shift operation)
//   4. shift_dir     = 0 (MSB first)
//   5. pinmux_reg    routes pin_out[n] to uo_out[7:1]
//   6. count32       = 0 (24-bit count1 / shift)
//   7. latch_in_out  = 0 (Readback latched in data {shift_data, cond_out})
//   8. cond_sel      = 0 (cond_out not used)
// 
// We will use:
//
// Diagram of our "circuit" for SPI Slave
//                                                                             
//  +-----------------------------+                          
//  |                             |      +------------+       
//  |            PRISM            |      |            |      
//  |                             |      |  Rotary    |      
//  |                             |      |  Encoder   |      
//  |  +-------------+    ui_in[0]|      |            |      
//  |  |   24-bit    |<-----------|------+ Output A   |      
//  |  |  debounce   |    ui_in[1]|      |            |      
//  |  |   counter   |<-----------|------+ Output B   |      
//  |  +------+------+            |      |            |      
//  |         |                   |      +------------+      
//  |         v                   |
//  |  +----------------------+   |                          
//  |  | 8-bit up/dn Counter  |   |                          
//  |  | used to track pulses |   |                             
//  |  | and rotation dir.    |   |                             
//  |  +----------------------+   |                    
//  |                             |                    
//  |              host_interrupt +---------> 
//  +-----------------------------+
//
// =======================================================

`default_nettype none

module chroma_encoder
(
   input wire           clk,
   input wire           rst_n,         // Global reset active low
   input wire           fsm_enable,    // Global FSM enable active high

   // Input data
   input wire  [31:0]   in_data,       // Input data

   // Output data
   output wire [20:0]   out_data,      // Static State outputs
   output reg  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects (see prism_periph.v)
);

   // Local FSM states
   localparam [2:0]  STATE_IDLE                 = 3'h0;
   localparam [2:0]  STATE_DEBOUNCE_RISING      = 3'h1;
   localparam [2:0]  STATE_DEBOUNCE_RISING2     = 3'h2;
   localparam [2:0]  STATE_DECREMENT            = 3'h3;
   localparam [2:0]  STATE_INCREMENT            = 3'h4;

   // Control Register State
   localparam [1:0]  SHIFT_IN_SEL       = 2'h0;  // Shift input data on ui_in[2]
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;  // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;  // Readback latched in data {shift_data,cond_out[0]}
   localparam [0:0]  SHIFT_EN           = 1'b0;  // Enable shift operation
   localparam [0:0]  SHIFT_DIR          = 1'b0;  // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;  // Enable 24-bit shift
   localparam [0:0]  COUNT32            = 1'b0;  // 24-bit count1
   localparam [0:0]  COUNT_UP           = 1'b0;  // count1 counts down
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [20:0] PINMUX             = 21'h1FFFFF;  // uo_out[7:1] sources
   localparam [0:0]  COUNT2_DEC         = 1'b1;  // Enable count2 decrement
   localparam [0:0]  LATCH2             = 1'b1;  // Use prism_out[2] as input latch enable

   localparam integer   PIN_DATA        = 0;

   reg   [2:0]    curr_state, next_state;

   // =======================================================
   // Wires to map inputs
   // =======================================================
   wire [6:0]     pin_in;
   wire           shift_in_data;
   wire [1:0]     host_in;
   wire [1:0]     pin_compare;
   wire           count1_zero;
   wire           count2_equal;
   wire           shift_zero;

   // =======================================================
   // Wires to map outputs based on PRISM RTL
   // =======================================================
   reg  [3:0]     pin_out;        // pin_out[3:0] -> OUT 0..3 (muxable to uo_out[7:1])
   reg            host_irq;
   reg            latch_out;      // OUT_LATCH
   reg            count2_dec;     // OUT_COUNT2_DEC
   reg            comm_load;      // OUT_COMM_LOAD
   reg  [1:0]     latched_out;
   reg            count1_dec;
   reg            count1_load;
   reg            count2_inc;
   reg            count2_clear;
   reg            shift_en;
   wire           count2_eq_comm;

   wire           pin0_in_prev;

   // =======================================================
   // Assign in_data bits to individual signals.
   //
   // This assignment is specific to the application in which
   // the prism_fsm is being used. 
   // =======================================================
   assign pin_in               = in_data[6:0];
   assign shift_in_data        = in_data[7];
   assign host_in              = in_data[9:8];
   assign count1_zero          = in_data[10];
   assign count2_equal         = in_data[11];
   assign pin_compare          = in_data[13:12];
   assign shift_zero           = in_data[14];
   assign count2_eq_comm       = in_data[15];

   // Assign out_data to array
   // PRISM outputs (prism_periph.v OUT_* numbering)
   assign out_data[3:0]        = pin_out[3:0];
   assign out_data[4]          = latch_out;         // OUT_LATCH (input latch strobe)
   assign out_data[6]          = count1_dec;        // OUT_COUNT1_INC_DEC
   assign out_data[7]          = count1_load;       // OUT_COUNT1_CLEAR_LOAD
   assign out_data[8]          = shift_en;          // OUT_SHIFT
   assign out_data[9]          = count2_inc;        // OUT_COUNT2_INC
   assign out_data[10]         = count2_dec;        // OUT_COUNT2_DEC
   assign out_data[11]         = count2_clear;      // OUT_COUNT2_CLEAR
   assign out_data[14]         = host_irq;          // OUT_HOST_INTERRUPT
   assign out_data[16]         = comm_load;         // OUT_COMM_LOAD
   // out_data[5], [13:12], [15], [20:17] unused by this chroma (left unmapped)

   // Chroma specific pin assignments
   assign pin0_in_prev          = in_data[12];
   
   /*
   ==========================================================
   Clocked block to update current state
   ==========================================================
   */
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 3'h0;
      else
      begin
         curr_state <= fsm_enable ? next_state : 'h0;
      end
   end

   /*
   ==========================================================
   Combinatorial block to set next state and drive out_data.
   ==========================================================
   */
   always @*
   begin
      // Default to staying in current state
      next_state = curr_state;

      // Defaults outputs
      pin_out        = 4'h0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      count2_inc     = 1'b0;
      count2_clear   = 1'b0;
      shift_en       = 1'b0;
      host_irq       = 1'b0;
      latch_out      = 1'b0;
      count2_dec     = 1'b0;
      comm_load      = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      cond_out[0]    = 1'b0;
      ctrl_reg       = {12'h0, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE, WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      // Use cond_out to reflect pin_in[0] so we can latch it and 
      // detect transitions
      if (pin_in[0])
          cond_out[0]= 1'b1;

      // =========================================================
      // State machine logic
      //
      // In tinyqv_periph, we have only 8 states...use them wisely
      // =========================================================
      case (curr_state)

      STATE_IDLE:
         begin
            // Detect rising edge of input A
            if (pin_in[0] != pin0_in_prev)
            begin
               // Load the debounce count to count1
               count1_load = 1'b1;

               // Latch pin_in[0] state (through cond_out)
               latch_out = 1'b1;

               // Go wait for debounce count to expire
               next_state = STATE_DEBOUNCE_RISING;
            end
         end

      STATE_DEBOUNCE_RISING:
         begin
            // Decrement count1 debounce counter
            count1_dec = 1'b1;

            // Test if count1 count is zero
            if (count1_zero)
               next_state = STATE_DECREMENT;
            else
               next_state = STATE_DEBOUNCE_RISING2;
         end

      STATE_DEBOUNCE_RISING2:
         begin
            // Continue decrementing count1 debounce counter
            count1_dec = 1'b1;

            // Test if input A went low again
            if (pin_in[0] != pin0_in_prev)
            begin
               // Latch pin_in[0] state (through cond_out)
               latch_out = 1'b1;

               // Go check the shift_coun
               next_state = STATE_IDLE;
            end
         end
      
      STATE_DECREMENT:
         begin
            // Test if we need to decrement count2
            if (pin_in[0] == pin_in[1])
            begin
               // Decrement count2 
               count2_dec = 1'b1;
               next_state = STATE_IDLE;
            end
            else
               next_state = STATE_INCREMENT;
         end

      STATE_INCREMENT:
         begin
            // Increment count2
            count2_inc = 1'b1;
            next_state = STATE_IDLE;
         end

      endcase
   end

endmodule

