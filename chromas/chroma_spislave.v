// =======================================================
// PRISM GPIO-24 Chroma
//
// This is a Chroma (personality) for the TinyQV PRISM
// peripheral. It implements a 24-input / 24-output
// I/O expander assuming you have connected 3 74165
// input shift registers and 3 74595 output shift register
// chips externally.
//
// FSM Deined pin assignments.
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[0]     ui_in[0]      CSB
//   prism_in[1]     ui_in[1]      SCLK In
//   prism_in[2]     ui_in[2]      MOSI In
//   cond_out[0]     uo_out[2]     MISO Out
//
// This assumes:
//   1. shift_in_sel  = 2 (Shift input data on ui_in[2])
//   2. shift_24_le   = 0 (Enable 8-bit shift)
//   3. shift_en      = 1 (Enable shift operation)
//   4. shift_dir     = 0 (MSB first)
//   5. pinmux_reg    routes shift_data to uo_out[2]
//   6. count32       = 0 (24-bit count1 / shift)
//   7. latch_in_out  = 0 (Readback latched out data [6:1])
//   8. cond_sel      = 0 (cond_out not used)
// 
// We will use:
//
// Diagram of our "circuit" for SPI Slave
//                                                                             
//  +---------------------------+                          
//  |                           |      +------------+       
//  |          PRISM            |      |            |      
//  |                           |      |     SPI    |      
//  |                           |      |    Master  |      
//  |   +----------+            |      |            |      
//  |   |          |      in[0] |<-----+ CSB        |      
//  |   |   host   |            |      |            |      
//  |   |          |      in[1] |<-----+ SCLK       |      
//  |   +-------+--+            |      |            |      
//  |      ^    |         in[2] |<-----+ MOSI       |      
//  |      |    v               |      |            |      
//  |  +---+----------+  out[2] +----->|            |      
//  |  |  comm_data   |         |      |            |         
//  |  +--------------+         |      +------------+         
//  |                           |
//  |                           |
//  |            host_interrupt +---------> 
//  +---------------------------+
//
//       ___                                                   ___
// CSB      |_________________________________________________|
//             __    __    __    __    __    __    __    __   
// SCLK  _____|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
//             ___________             _____             _____
// MOSI  _____|           |___________|     |___________|     |___
//                   ___________                   _____
// MISO  ___________|           |_________________|     |_________
//
// =======================================================

`default_nettype none

module chroma_spislave
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
   localparam [2:0]  STATE_FIRST_SCLK           = 3'h1;  // wait for first SCLK of a byte, load TX byte
   localparam [2:0]  STATE_LATCH_FIRST          = 3'h2;  // latch MSB of the freshly loaded TX byte
   localparam [2:0]  STATE_CHECK_SCLK2          = 3'h3;  // wait for rising SCLK (bits 2..8)
   localparam [2:0]  STATE_AWAIT_SCLK_FALLING   = 3'h4;
   localparam [2:0]  STATE_CHECK_COUNT          = 3'h5;
   localparam [2:0]  STATE_GEN_INTERRUPT        = 3'h6;

   // Control Register State
   localparam [1:0]  SHIFT_IN_SEL       = 2'h2;  // Shift input data on ui_in[2]
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;  // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;  // Readback latched in data {shift_data,ui_in[0]}
   localparam [0:0]  SHIFT_EN           = 1'b1;  // Enable shift operation
   localparam [0:0]  SHIFT_DIR          = 1'b0;  // MSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;  // Enable 24-bit shift
   localparam [0:0]  COUNT32            = 1'b0;  // 24-bit count1
   localparam [0:0]  COUNT_UP           = 1'b0;  // count1 counts down
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [1:0]  CRC_MODE           = 2'd1;  // CRC8 over the received bits  // 0 off, 1 = CRC8, 2 = CRC16, 3 = CRC32
   localparam [0:0]  CRC_REFLECT        = 1'b0;  // 1 = LSB-first LFSR (reflected polynomial)
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;  // 0 = RX (FSM pushes, host reads), 1 = TX (host writes, FSM pops)
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;  // semaphore set beats clear in the same cycle
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;  // OUT_CRC_CLEAR presets all ones instead of zero
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;  // complement the CRC on OUT_LOAD_CRC
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;  // 0 = CRC over the shifter input bit, 1 = over its output bit
   localparam [20:0] PINMUX             = 21'h1FFFE7;  // uo_out[7:1] sources
   localparam [0:0]  COUNT2_DEC         = 1'b0;  // No count2 decrement
   localparam [0:0]  LATCH2             = 1'b1;  // Use prism_out[2] as input latch enable

   localparam integer   PIN_CSB     = 0;
   localparam integer   PIN_SCLK    = 1;

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
   reg            fifo_wr;        // OUT_FIFO_WR_RD (RX: push comm)
   reg            crc_update;     // OUT_CRC_UPDATE
   reg  [1:0]     latched_out;
   reg            count1_dec;
   reg            count1_load;
   reg            count2_inc;
   reg            count2_clear;
   reg            shift_en;
   wire           count2_eq_comm;

   wire           shift_out_reg;

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
   assign out_data[5]          = fifo_wr;           // OUT_FIFO_WR_RD
   assign out_data[6]          = count1_dec;        // OUT_COUNT1_INC_DEC
   assign out_data[7]          = count1_load;       // OUT_COUNT1_CLEAR_LOAD
   assign out_data[8]          = shift_en;          // OUT_SHIFT
   assign out_data[9]          = count2_inc;        // OUT_COUNT2_INC
   assign out_data[10]         = count2_dec;        // OUT_COUNT2_DEC
   assign out_data[11]         = count2_clear;      // OUT_COUNT2_CLEAR
   assign out_data[13]         = crc_update;        // OUT_CRC_UPDATE
   assign out_data[14]         = host_irq;          // OUT_HOST_INTERRUPT
   assign out_data[16]         = comm_load;         // OUT_COMM_LOAD
   // out_data[5], [13:12], [15], [20:17] unused by this chroma (left unmapped)

   // Chroma specific pin assignments
   assign shift_out_reg         = in_data[13];
   
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
      fifo_wr        = 1'b0;
      crc_update     = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      cond_out[0]    = 1'b0;
      ctrl_reg       = {4'h0, CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE, WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      // Send registered shift_out data to cond_out so it says steady during
      // shift operation at falling SCLK edge.
      if (shift_out_reg)
          cond_out[0]    = 1'b1;

      // =========================================================
      // State machine logic
      //
      // 7 states (dual compare folds the CSB-deassert checks into the
      // SCLK wait states)
      // =========================================================
      case (curr_state)
      STATE_IDLE:
         begin
            // Detect falling CSB
            if (!pin_in[PIN_CSB])
               next_state = STATE_FIRST_SCLK;
         end

      STATE_FIRST_SCLK:
         begin
            // First rising SCLK of a byte: load the TX byte staged by the
            // host in preload[7:0] into comm.  Dual compare: the second
            // condition watches for CSB deasserting between bytes.
            if (pin_in[PIN_SCLK])
            begin
               comm_load  = 1'b1;
               next_state = STATE_LATCH_FIRST;
            end
            else if (pin_in[PIN_CSB])
               next_state = STATE_IDLE;
         end

      STATE_LATCH_FIRST:
         begin
            // comm was loaded on the previous clock; register its MSB on
            // MISO (cond_out[0]) so it stays stable through the shift.
            latch_out  = 1'b1;
            next_state = STATE_AWAIT_SCLK_FALLING;
         end

      STATE_CHECK_SCLK2:
         begin
            // Wait for rising SCLK
            if (pin_in[PIN_SCLK])
            begin
               // Register the output shift_data so it remains stable during
               // the shift operation at the falling SCLK edge.
               latch_out  = 1'b1;
               next_state = STATE_AWAIT_SCLK_FALLING;
            end
            else if (pin_in[PIN_CSB])
               // CSB deasserted mid-byte: abort
               next_state = STATE_IDLE;
         end

      STATE_AWAIT_SCLK_FALLING:
         begin
            // Wait for falling SCLK
            if (!pin_in[PIN_SCLK])
            begin
               // Shift MOSI into comm (and the next MSB out); the CRC sees
               // the same input bit
               shift_en   = 1'b1;
               crc_update = 1'b1;
               next_state = STATE_CHECK_COUNT;
            end
            else if (pin_in[PIN_CSB])
               next_state = STATE_IDLE;
         end

      STATE_CHECK_COUNT:
         begin
            // Check if the shift count is zero (byte received)
            if (!shift_zero)
               // Not 8 bits yet, go wait for next SCLK
               next_state = STATE_CHECK_SCLK2;
            else
               // Byte received, go generate interrupt to host
               next_state = STATE_GEN_INTERRUPT;
         end

      STATE_GEN_INTERRUPT:
         begin
            // Byte received: push it into the RX FIFO and interrupt the
            // host, which stages the next TX byte in preload before the
            // next byte starts.
            fifo_wr    = 1'b1;          // OUT_FIFO_WR_RD (RX push)
            host_irq   = 1'b1;          // OUT_HOST_INTERRUPT
            next_state = STATE_FIRST_SCLK;
         end

      default:
         begin
            // All others, go to IDLE state
            next_state = STATE_IDLE;
         end
      endcase
   end

endmodule

