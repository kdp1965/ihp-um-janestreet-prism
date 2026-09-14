// =======================================================
// PRISM UART transmitter Chroma
//
// A Chroma (personality) for the TinyQV PRISM peripheral: 8N1 UART
// transmitter fed from the shard's TX FIFO, with a CRC-8 over the data
// bits that is sent as a trailer on request.
//
//   (the compiler wants constant assignments, so the data bit on TXD is
//    written as cond_out[0] = 0; if (shift_data) cond_out[0] = 1)
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   cond_out[0]     uo_out[1]     TXD (idle high)
//
// Host side:
//   - preload  = bit period in clocks - 2 (count1 counts it down)
//   - FIFO     = bytes to send (TX mode: host writes, FSM pops into comm)
//   - host_in[0] = 1: after the FIFO drains, send the CRC-8 byte, raise the
//     host interrupt and wait until host_in[0] is cleared, then clear the
//     CRC for the next message
//
// CRC: CRC-8, polynomial 0x07, init 0, computed over the bits in the order
// they leave the pin (LSB first, non-reflected LFSR, so it is a bit-order
// variant of CRC-8; use CRC_REFLECT with polynomial 0xE0 for the reflected
// form).  The CRC covers the data bits only, not start / stop bits.
//
// Configuration (ctrl_reg): comm shifts LSB first, count1 24-bit down
// counter, TX FIFO, CRC8 over the shifter output bit.
// =======================================================
module chroma_uart_tx
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

   // =======================================================
   // Configuration
   // =======================================================
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;  // OUT_COUNT1_CLEAR_LOAD loads from preload
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;  // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;  // comm (8-bit) shifts
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT2_DEC         = 1'b0;
   localparam [0:0]  LATCH2             = 1'b0;
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd1;  // CRC8
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b1;  // host writes, FSM pops
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b1;  // CRC over the transmitted bit
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_COND0;
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
   localparam [3:0]  STATE_IDLE         = 4'h0;
   localparam [3:0]  STATE_START        = 4'h1;
   localparam [3:0]  STATE_DATA         = 4'h2;
   localparam [3:0]  STATE_DATA_CHECK   = 4'h3;
   localparam [3:0]  STATE_STOP         = 4'h4;
   localparam [3:0]  STATE_START_CRC    = 4'h5;
   localparam [3:0]  STATE_DATA_CRC     = 4'h6;
   localparam [3:0]  STATE_CRC_CHECK    = 4'h7;
   localparam [3:0]  STATE_STOP_CRC     = 4'h8;
   localparam [3:0]  STATE_WAIT_ACK     = 4'h9;

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           shift_data;
   wire [1:0]     host_in;
   wire           count1_zero;
   wire           shift_zero;
   wire           fifo_empty;

   assign shift_data           = in_data[7];
   assign host_in              = in_data[9:8];
   assign count1_zero          = in_data[10];
   assign shift_zero           = in_data[14];
   assign fifo_empty           = in_data[20];

   // =======================================================
   // Outputs
   // =======================================================
   reg            fifo_rd;        // OUT_FIFO_WR_RD (TX: pop into comm)
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            crc_clear;
   reg            crc_update;
   reg            host_irq;
   reg            load_crc;       // OUT_LOAD_CRC

   assign out_data[5]          = fifo_rd;           // OUT_FIFO_WR_RD
   assign out_data[6]          = count1_dec;        // OUT_COUNT1_INC_DEC
   assign out_data[7]          = count1_load;       // OUT_COUNT1_CLEAR_LOAD
   assign out_data[8]          = shift_en;          // OUT_SHIFT
   assign out_data[12]         = crc_clear;         // OUT_CRC_CLEAR
   assign out_data[13]         = crc_update;        // OUT_CRC_UPDATE
   assign out_data[14]         = host_irq;          // OUT_HOST_INTERRUPT
   assign out_data[17]         = load_crc;          // OUT_LOAD_CRC
   // out_data[4:0], [11:9], [16:15], [20:18] unused by this chroma

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

      fifo_rd        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      crc_clear      = 1'b0;
      crc_update     = 1'b0;
      host_irq       = 1'b0;
      load_crc       = 1'b0;
      cond_out[0]    = 1'b1;     // TXD idle high
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {4'h0, CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:
         begin
            // Next byte from the FIFO, or the CRC trailer when the host asks
            if (!fifo_empty)
            begin
               fifo_rd     = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_START;
            end
            else if (host_in[0])
            begin
               load_crc    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_START_CRC;
            end
         end

      STATE_START:
         begin
            cond_out[0] = 1'b0;                     // start bit
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_DATA;
            end
         end

      STATE_DATA:
         begin
            cond_out[0] = 1'b0;                     // current data bit (LSB first)
            if (shift_data)
               cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;                  // next bit; the CRC takes this one
               crc_update  = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_DATA_CHECK;
            end
         end

      STATE_DATA_CHECK:
         begin
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (shift_zero)
               next_state = STATE_STOP;             // 8 bits sent
            else
               next_state = STATE_DATA;
         end

      STATE_STOP:
         begin
            cond_out[0] = 1'b1;                     // stop bit
            count1_dec  = 1'b1;
            if (count1_zero)
               next_state = STATE_IDLE;
         end

      // ---- CRC trailer: same frame, comm was loaded from the CRC, no update
      STATE_START_CRC:
         begin
            cond_out[0] = 1'b0;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = STATE_DATA_CRC;
            end
         end

      STATE_DATA_CRC:
         begin
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_CRC_CHECK;
            end
         end

      STATE_CRC_CHECK:
         begin
            cond_out[0] = 1'b0;
            if (shift_data)
               cond_out[0] = 1'b1;
            if (shift_zero)
               next_state = STATE_STOP_CRC;
            else
               next_state = STATE_DATA_CRC;
         end

      STATE_STOP_CRC:
         begin
            cond_out[0] = 1'b1;
            count1_dec  = 1'b1;
            if (count1_zero)
            begin
               host_irq   = 1'b1;                   // message + CRC sent
               next_state = STATE_WAIT_ACK;
            end
         end

      STATE_WAIT_ACK:
         begin
            // Hold until the host drops its request, then start a new CRC
            if (!host_in[0])
            begin
               crc_clear  = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end
endmodule
