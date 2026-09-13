// =======================================================
// PRISM GPIO-24 Chroma
//
// This is a Chroma (personality) for the TinyQV PRISM
// peripheral. It implements a 24-input / 24-output
// I/O expander assuming you have connected 3 74165
// input shift registers and 3 74595 output shift register
// chips externally.
//
// FSM Deined pin outputs.  This assumes:
//
// 1. shift_in_sel  = 0 (Shift input data on ui_in[0])
// 2. shift_24_le   = 1 (Enable 24-bit shift)
// 3. shift_en      = 1 (Enable shift operation)
// 4. shift_dir     = 0 (MSB first)
// 5. shift_out_sel = 1 (Route shift_data to uo_out[4])
// 6. count32       = 0 (24-bit count1 / shift)
// 7. latch_in_out  = 1 (Readback latched out data [6:1])
// 8. cond_sel      = 1 (Route cond_out to uo_out[2])
// 
// We will use:
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_out[0]    (uo_out[1])   GPIO load_bar 75165
//   cond_out[0]     (uo_out[2])   GPIO store for 74595
//   shift_data      (uo_out[5])   Shift data out
//   prism_out[6]    (uo_out[7])   Shift clock (shift_en)
//
//   prism_in[0]  (ui_in[0]):   Shift data in
//
//   host_in[0]:  Start shift operation
//   host_io[1]:  Latch new outputs
//
// Diagram of our "circuit" for 24 inputs + 24 outputs
//                                                                             
//     +---------+          Parallel         Parallel          Parallel        
//     |  PRISM  |           Inputs          Inputs            Inputs          
//     |         |          |  |  |           |  |  |           |  |  |        
//     |         |          v  v  v           v  v  v           v  v  v        
//     |         |       +------------+    +------------+    +------------+    
//     |         |       |   74165    |    |   74165    |    |   74165    |    
//     |         |       |            |    |            |    |            |    
//     |uo_out[1]+------>|ld/shift    | -->|ld/shift    | -->|ld/shift    |    
//     |uo_out[7]+--*--->|clk         | -->|clk         | -->|clk         |    
//     |         |  | 0->|in  ser  out+--->|in  ser  out+--->|in  ser  out+--+ 
//     |         |  |    +------------+    +------------+    +------------+  | 
//     | uo_in[0]|<-|--------------------------------------------------------+ 
//     |         |  |                                                          
//     |         |  |       Parallel          Parallel          Parallel        
//     |         |  |       outputs           outputs           outputs         
//     |         |  |       ^  ^  ^           ^  ^  ^           ^  ^  ^        
//     |         |  |       |  |  |           |  |  |           |  |  |        
//     |         |  |    +--+--+--+---+    +--+--+--+---+    +--+--+--+---+    
//     |         |  |    |   74595    |    |   74595    |    |   74595    |    
//     |         |  |    |            |    |            |    |            |    
//     |         |  +--->|clk         | -->|clk         | -->|clk         |    
//     |uo_out[2]+------>|ld/shift    | -->|ld/shift    | -->|ld/shift    |    
//     |uo_out[5]+------>|in  ser  out+--->|in  ser  out+--->|in  ser  out|
//     |         |       +------------+    +------------+    +------------+
//     |         | 
//     +---------+  
//
// =======================================================

`default_nettype none

module chroma_gpio24
(
   input wire           clk,
   input wire           rst_n,         // Global reset active low
   input wire           fsm_enable,    // Global FSM enable active high

   // Input data
   input wire  [31:0]   in_data,       // Input data

   // Output data
   output wire [20:0]   out_data,      // Static State outputs
   output wire  [1:0]    cond_out,      // Conditional outputs
   output reg  [31:0]   ctrl_reg,
   output reg  [20:0]   pinmux_reg     // uo_out[7:1] source selects (see prism_periph.v)
);

   // Local FSM states
   localparam [2:0]  STATE_IDLE                 = 3'h0;
   localparam [2:0]  STATE_LATCH_INPUTS         = 3'h1;
   localparam [2:0]  STATE_SHIFT_BITS           = 3'h2;
   localparam [2:0]  STATE_DELAY                = 3'h3;
   localparam [2:0]  STATE_MAYBE_SAVE_OUTPUTS   = 3'h4;
   localparam [2:0]  STATE_AWAIT_DEASSERT       = 3'h5;
   localparam [2:0]  STATE_DELAY2               = 3'h6;

   localparam integer GPIO_LOAD         = 0;
   localparam integer GPIO_CLK          = 1;   // shift clock pin (was OUT_SHIFT itself)
   localparam integer GPIO_STORE        = 0;
   localparam integer HOST_START        = 0;
   localparam integer HOST_SAVE_OUTPUTS = 1;

   // Control Register State
   localparam [1:0]  SHIFT_IN_SEL       = 2'h0;  // Shift input data on ui_in[0]
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;  // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b1;  // Readback latched out data [6,1]
   localparam [0:0]  SHIFT_EN           = 1'b1;  // Enable shift operation
   localparam [0:0]  SHIFT_DIR          = 1'b0;  // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b1;  // Enable 24-bit shift
   localparam [0:0]  COUNT32            = 1'b0;  // 24-bit count1
   localparam [0:0]  COUNT_UP           = 1'b0;  // count1 counts down
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [1:0]  CRC_MODE           = 2'd0;  // 0 off, 1 = CRC8, 2 = CRC16, 3 = CRC32
   localparam [0:0]  CRC_REFLECT        = 1'b0;  // 1 = LSB-first LFSR (reflected polynomial)
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;  // 0 = RX (FSM pushes, host reads), 1 = TX (host writes, FSM pops)
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;  // semaphore set beats clear in the same cycle
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;  // OUT_CRC_CLEAR presets all ones instead of zero
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;  // complement the CRC on OUT_LOAD_CRC
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;  // 0 = CRC over the shifter input bit, 1 = over its output bit
   localparam [20:0] PINMUX             = 21'h7EFE0;  // uo_out[7:1] sources
   localparam [0:0]  COUNT2_DEC         = 1'b0;  // No count2 decrement
   localparam [0:0]  LATCH2             = 1'b0;  // Use prism_out[2] as input latch enable

   reg   [2:0]    curr_state, next_state;


   // =======================================================
   // Wires to map inputs
   // =======================================================
   wire [6:0]     pin_in;
   wire           shift_out_data;
   wire [1:0]     host_in;
   wire [1:0]     pin_compare;
   wire           count1_zero;
   wire           count2_equal;
   wire           shift_zero;
   wire           count2_eq_comm;

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

   wire           shift_clk_in;
   reg            gpio_store;

   // =======================================================
   // assign in_data from array
   //
   // These assignments represent the TinyQV PRISM peripheral
   // hardware inputs.
   // =======================================================
   assign pin_in               = in_data[6:0];
   assign shift_out_data       = in_data[7];
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
   assign cond_out[GPIO_STORE] = gpio_store;

   // =======================================================
   // Assign Chroma specific defined pins
   // =======================================================
   assign shift_clk_in         = in_data[13];

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
      pin_out[0]     = 1'b1;     // Out[0] is active LOW so drive it high as default
      pin_out[3:1]   = 3'h0;
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
      gpio_store     = 1'b0;
      ctrl_reg       = {4'h0, CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE, WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      // =========================================================
      // State machine logic
      //
      // In tinyqv_periph, we have only 8 states...use them wisely
      // =========================================================
      case (curr_state)

      STATE_IDLE:                // State 0
         begin
            // Detect I/O shift start 
            if (host_in[HOST_START])
            begin
               // Load inputs 
               pin_out[GPIO_LOAD] = 1'b0;

               // Load 24-bit shift register from preload (our OUTPUTS)
               count1_load = 1'b1;

               next_state = STATE_LATCH_INPUTS;
            end
         end

      STATE_LATCH_INPUTS:        // State 1
         begin
            next_state = STATE_SHIFT_BITS;
         end
      
      STATE_SHIFT_BITS:          // State 2
         begin
            // Shift the next bit out (OUT_SHIFT) and raise the shift clock pin
            shift_en = 1'b1;
            pin_out[GPIO_CLK] = 1'b1;

            // Detect the rising shift_en bit to go to next state
            if (shift_clk_in)
            begin
               next_state = STATE_DELAY;
               shift_en = 1'b0;
               pin_out[GPIO_CLK] = 1'b0;
            end
         end

      STATE_DELAY:               // State 3
         begin
            // This is a delay state because external 74xxx don't run at 32MHz
            // (and the PMOD inputs are two synchronizer flops away, so the
            // shift loop must be at least four clocks long)
            next_state = STATE_DELAY2;
         end

      STATE_DELAY2:              // State 6
         begin
            // Test if we are done shifting
            if (!shift_zero)
               next_state = STATE_SHIFT_BITS;
            else
               next_state = STATE_MAYBE_SAVE_OUTPUTS;
         end

      STATE_MAYBE_SAVE_OUTPUTS:  // State 4
         begin
            // Test if we should save outputs
            if (host_in[HOST_SAVE_OUTPUTS])
               gpio_store = 1'b1;

            // Now go wait for host_in[0] to go low
            next_state = STATE_AWAIT_DEASSERT;
         end

      STATE_AWAIT_DEASSERT:      // State 5
         begin
            // Wait for host to clear the 'start' signal
            if (!host_in[HOST_START])
               // Transaction complete ... go to IDLE
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

