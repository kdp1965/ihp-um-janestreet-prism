// =======================================================
// PRISM GPIO-24 Chroma
//
// This is a Chroma (personality) for the TinyQV PRISM
// peripheral. It implements a WS2412 "NeoPixel" driver
// capable of driving a string of RGB addressable LEDs.
//
// FSM Deined pin assignments.
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_out[0]    uo_out[1]     Output data
//
// This assumes:
//   1. shift_in_sel  = 2 (Shift input data on ui_in[2])
//   2. shift_24_le   = 0 (Enable 8-bit shift)
//   3. shift_en      = 1 (Enable shift operation)
//   4. shift_dir     = 0 (MSB first)
//   5. pinmux_reg    routes shift_data to uo_out[2]
//   6. count32       = 0 (24-bit count1 / shift)
//   7. latch_in_out  = 0 (Readback latched in data {shift_data, cond_out})
//   8. cond_sel      = 0 (cond_out not used)
// 
// We will use:
//
// Diagram of our "circuit" for SPI Slave
//                                                                             
//  +-----------------------------+                          
//  |                             |                           
//  |            PRISM            |                          
//  |                             |      +------------+      
//  |                             |      |            |      
//  |  +-------------+            |      |  NeoPixel  |      
//  |  |   24-bit    |            |      |   LEDs     |      
//  |  |  shift Reg  |            |      |            |      
//  |  |       shift |  uo_out[0] |----->| Data       |      
//  |  +-------------+            |      |            |      
//  |                             |      |            |      
//  |  +---------------+          |      |            |      
//  |  | 8-bit Counter |          |      +------------+      
//  |  |    used as    |          |                             
//  |  |   bit timer   |          |                             
//  |  +---------------+          |                    
//  |                             |                    
//  |              host_interrupt +---------> 
//  +-----------------------------+
//
// =======================================================

`default_nettype none

module chroma_ws2812
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
   localparam [2:0]  STATE_SEND_T0_HIGH         = 3'h1;
   localparam [2:0]  STATE_CHECK_BIT_VALUE      = 3'h2;
   localparam [2:0]  STATE_SEND_T1_HIGH         = 3'h3;
   localparam [2:0]  STATE_SEND_T0_LOW          = 3'h4;
   localparam [2:0]  STATE_SEND_T1_LOW          = 3'h5;
   localparam [2:0]  STATE_CHECK_SHIFT_COUNT    = 3'h6;
   localparam [2:0]  STATE_GOTO_IDLE            = 3'h7;

   // Control Register State
   localparam [1:0]  SHIFT_IN_SEL       = 2'h0;  // Shift input data on ui_in[2]
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;  // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;  // Readback latched in data {shift_data,cond_out[0]}
   localparam [0:0]  SHIFT_EN           = 1'b1;  // Enable shift operation
   localparam [0:0]  SHIFT_DIR          = 1'b0;  // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b1;  // Enable 24-bit shift
   localparam [0:0]  COUNT32            = 1'b0;  // 24-bit count1
   localparam [0:0]  COUNT_UP           = 1'b0;  // count1 counts down
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [20:0] PINMUX             = 21'h1FFFF8;  // uo_out[7:1] sources
   localparam [0:0]  COUNT2_DEC         = 1'b0;  // No count2 decrement
   localparam [0:0]  LATCH2             = 1'b1;  // Use prism_out[5] as input latch enable

   localparam integer   PIN_DATA    = 0;

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

   wire           host_in_prev;

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
   assign host_in_prev          = in_data[12];
   
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

      // Use cond_out to reflect host-in so we can latch it and 
      // detect transitions
      if (host_in[0])
          cond_out[0]= 1'b1;

      // =========================================================
      // State machine logic
      //
      // In tinyqv_periph, we have only 8 states...use them wisely
      // =========================================================
      case (curr_state)

      STATE_IDLE:
         begin
            // Detect new data to send
            if (host_in[0] != host_in_prev)
            begin
               // Save new state of host_in[0]
               latch_out = 1'b1;

               // Generate an interrupt to the host to tell it we are ready
               // for more pixels of data
               host_irq = 1'b1;          // OUT_HOST_INTERRUPT

               // Copy count1_preload into the count1 shift register
               count1_load = 1'b1;

               // Go to wait for SCLK
               next_state = STATE_SEND_T0_HIGH;
            end
         end

      STATE_SEND_T0_HIGH:
         begin
            // Drive the data line HIGH for 0.4us
            pin_out[PIN_DATA] = 1'b1;

            // Start the count2 counter
            count2_inc = 1'b1;

            // Test if count2 time expired. comm_data has 0.4us count
            if (count2_eq_comm)
            begin
               next_state = STATE_CHECK_BIT_VALUE;
            end
         end

      STATE_CHECK_BIT_VALUE:
         begin
            // Continue Driving the data line HIGH
            pin_out[PIN_DATA] = 1'b1;

            // Keep counting
            count2_inc = 1'b1;

            // Test if the bit is a '0'
            if (shift_in_data == 1'b0)
            begin
               // Clear the count2 counter and go send T0_LOW
               count2_clear = 1'b1;
               count2_inc = 1'b0;

               // Go check the shift_coun
               next_state = STATE_SEND_T0_LOW;
            end
            else
            begin
               // No rising SCLK ... go check for end of transaction
               next_state = STATE_SEND_T1_HIGH;
            end
         end
      
      STATE_SEND_T1_HIGH:
         begin
            // Continue Driving the data line HIGH
            pin_out[PIN_DATA] = 1'b1;

            // Keep counting
            count2_inc = 1'b1;

            // Test if count2 time expired.  count2_compare has 0.8us count
            if (count2_equal)
            begin
               // Clear count2 counter
               count2_clear = 1'b1;
               count2_inc = 1'b0;

               // Go send T1LOW period
               next_state = STATE_SEND_T1_LOW;
            end
         end

      STATE_SEND_T0_LOW:
         begin
            // Keep counting
            count2_inc = 1'b1;

            // Test when time expires.  count2_compare has .8us compare value
            if (count2_equal)
            begin
               // Shift next bit
               shift_en = 1'b1;

               // Clear the counter
               count2_clear = 1'b1;
               count2_inc = 1'b0;

               // Go check the shift count
               next_state = STATE_CHECK_SHIFT_COUNT;
            end
         end

      STATE_SEND_T1_LOW:
         begin
            // Keep counting
            count2_inc = 1'b1;

            // Test if 0.4us have passed
            if (count2_eq_comm)
            begin
               // Shift next bit
               shift_en = 1'b1;

               // Clear the counter
               count2_clear = 1'b1;
               count2_inc = 1'b0;

               // Go check the shift count
               next_state = STATE_CHECK_SHIFT_COUNT;
            end
         end

      STATE_CHECK_SHIFT_COUNT:
         begin
            // Check if the shift count is zero (byte received)
            if (!shift_zero)
               // Not 8 bits yet, go wati for next SCLK
               next_state = STATE_SEND_T0_HIGH;
            else
               // Byte received, go generate interrupt to host
               next_state = STATE_GOTO_IDLE;
         end

      STATE_GOTO_IDLE:
         begin
            next_state = STATE_IDLE;
         end

      default:
         begin
            // All others, go to IDLE state
            next_state = STATE_IDLE;
         end
      endcase
   end

endmodule

