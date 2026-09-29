// =======================================================
// PRISM UART receiver Chroma (2026-09-28: 5 states)
//
// An 8N1 receiver on ui_in[0] that pushes every byte into the shard's RX
// FIFO and runs a CRC-8 over the data bits (the mirror of chroma_uart_tx).
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   prism_in[0]     ui_in[0]      RXD (idle high)
//
// Bit clock: count1 counts up and wraps at PRELOAD (= bit period - 1), so
// count1_term is a periodic tick; the sampler (CFG3: input 0, falling
// edge, timer action with preset k = 1) sets count1 to PRELOAD >> 1 on
// every falling edge, which puts the next tick half a bit later: the
// start bit is sampled at its middle and so is every data bit, with every
// 1 -> 0 data edge re-centring the clock (a 5 % baud-rate error costs
// nothing).  The FSM never touches count1.
//
//   IDLE:  a falling edge (the sampler's pending flag) -> START
//   START: at the tick RXD must still be low (else a glitch: back to IDLE);
//          comm <= K0 = 0 (its shift count restarts) and the pending flag is
//          consumed (OUT_LATCH)
//   DATA:  at the tick shift RXD in (LSB first) and feed the CRC
//   DCHK:  eight bits -> STOP, else DATA
//   STOP:  at the tick RXD high = a byte: push it, host interrupt; low = a
//          framing error: the byte is dropped
//
// Host side: PRELOAD = bit period - 1; CFG2 slot 1 (input 17) = 15 (the
// sampler's pending flag); CFG3 = SMP_EN | SMP_SRC(0) | SMP_FALL |
// SMP_TIMER | SMP_PRESET(1); CONST K0 = 0; CRC_POLY = 0x07.  The CRC
// register accumulates over every received data bit in wire order (LSB
// first into a non-reflected LFSR, as chroma_uart_tx computes it); the host
// clears it (a CRC write) between messages and compares it with the
// transmitter's trailer.  The FIFO may be the SRAM FIFO (CFG0 bit 31).
// =======================================================
module chroma_uart_rx
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd0;   // RXD = ui_in[0] feeds the shifter
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first: the newest bit enters at comm[7]
   localparam [0:0]  SHIFT_24_EN        = 1'b0;   // comm (8-bit) shifts
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled (it consumes the sampler's pending flag)
   localparam [0:0]  COUNT_UP           = 1'b1;   // count1 counts up ...
   localparam [0:0]  WRAP_PRELOAD       = 1'b1;   // ... and wraps at PRELOAD: a periodic tick
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;   // a comm load sets its shift count to 0
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd1;   // CRC8
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // RX FIFO: the FSM pushes, the host reads
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;   // CRC over the shifter input bit
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K0
   localparam [0:0]  FIFO_SRAM          = 1'b0;   // the host may OR CFG_FIFO_SRAM in
   // no output pins
   localparam [2:0]  PIN_OFF   = 3'd7;
   localparam [20:0] PINMUX    = {7{PIN_OFF}};

   // =======================================================
   // States
   // =======================================================
   localparam [2:0]  STATE_IDLE      = 3'd0;
   localparam [2:0]  STATE_START     = 3'd1;
   localparam [2:0]  STATE_DATA      = 3'd2;
   localparam [2:0]  STATE_DCHK      = 3'd3;
   localparam [2:0]  STATE_STOP      = 3'd4;

   reg   [2:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           rxd;
   wire           count1_term;
   wire           shift_term;
   wire           pending;

   assign rxd                  = in_data[0];
   assign count1_term          = in_data[10];    // the bit clock's tick (mid-bit)
   assign shift_term           = in_data[14];    // 8 shifts since the comm load
   assign pending              = in_data[17];    // slot: a falling edge (the start bit)

   // =======================================================
   // Outputs
   // =======================================================
   reg            latch;          // OUT_LATCH: consumes the pending flag
   reg            fifo_push;      // OUT_FIFO_WR_RD: push comm
   reg            count1_step;    // OUT_COUNT1_INC_DEC: the bit clock runs in every state
   reg            shift_en;       // OUT_SHIFT
   reg            crc_update;     // OUT_CRC_UPDATE
   reg            host_irq;       // OUT_HOST_INTERRUPT
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K0

   assign out_data[4]          = latch;
   assign out_data[5]          = fifo_push;
   assign out_data[6]          = count1_step;
   assign out_data[8]          = shift_en;
   assign out_data[13]         = crc_update;
   assign out_data[14]         = host_irq;
   assign out_data[16]         = comm_load;
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

      latch          = 1'b0;
      fifo_push      = 1'b0;
      count1_step    = 1'b1;
      shift_en       = 1'b0;
      crc_update     = 1'b0;
      host_irq       = 1'b0;
      comm_load      = 1'b0;
      cond_out[0]    = 1'b0;
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:                                  // a falling edge: the start bit (count1 already re-centred)
         begin
            if (pending)
               next_state = STATE_START;
         end

      STATE_START:                                 // mid start bit: still low?
         begin
            if (count1_term && !rxd)
            begin
               comm_load  = 1'b1;                  // comm <= 0, eight shifts to go
               latch      = 1'b1;                  // the edge is consumed
               next_state = STATE_DATA;
            end
            else if (count1_term && rxd)           // a glitch
            begin
               latch      = 1'b1;
               next_state = STATE_IDLE;
            end
         end

      STATE_DATA:                                  // mid data bit: take it
         begin
            if (count1_term)
            begin
               shift_en   = 1'b1;
               crc_update = 1'b1;
               next_state = STATE_DCHK;
            end
         end

      STATE_DCHK:
         begin
            if (shift_term)
               next_state = STATE_STOP;
            else if (!shift_term)
               next_state = STATE_DATA;
         end

      STATE_STOP:                                  // mid stop bit: a byte, or a framing error
         begin
            if (count1_term && rxd)
            begin
               fifo_push  = 1'b1;
               host_irq   = 1'b1;
               next_state = STATE_IDLE;
            end
            else if (count1_term && !rxd)
               next_state = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
