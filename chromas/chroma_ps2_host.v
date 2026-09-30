// =======================================================
// PRISM PS/2 host Chroma (2026-09-29: 16 states, one shard)
//
// The host side of a PS/2 port, what a keyboard or a mouse plugs into:
// it receives the device's bytes and sends it commands.  Both lines are
// open collector with a pull-up and the device makes the clock, always.
// An output means "pull the line low" (1 = the external buffer drives it
// low, 0 = released); the two line levels come back on ui_in pins.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[1]     CLK pull-low
//   cond_out[0]     uo_out[2]     DATA pull-low
//   prism_in[2]     ui_in[2]      CLK level (the sampler's clock: falling edges)
//   prism_in[3]     ui_in[3]      DATA level (the shifter's input)
//                                 Not ui_in[1]: TinyQV samples it at reset.
//
// From the device: start 0, eight bits LSB first, odd parity, stop 1, each
// valid as CLK falls.  The byte goes to the FIFO with the host interrupt
// when the parity is odd and the stop bit 1; anything else, or a frame
// that stops, is an error: interrupt, count3 + 1, nothing in the FIFO.
//
// To the device, on a toggle of host_in[0], the byte in K0 and its odd
// parity in bit 0 of K1 (the host makes it):
//   CLK low for the time-out period (100 us or more): the device is held
//   DATA low, CLK released: the request, which is the start bit
//   on the device's falling edges: the eight bits, the parity, DATA
//   released for the stop bit; on the next one DATA low is the device's
//   acknowledge: host interrupt.  No acknowledge, or no clock: an error.
// A frame from the device that has begun is received first.
//
// Timers: count1 counts up, cleared by every falling edge of CLK, and
// wraps at PRELOAD: its terminal count is the time CLK is held low for a
// request and the time-out inside a frame.  Timer 2 (restarted as WAIT1
// is entered, one tick) is the longer time the device may take to make
// its first clock after a request (15 ms).
// Parity received: the CRC unit with the polynomial 0x80 is a parity
// accumulator (chroma_spw_tx.v), CRC_EXPECTED = 0x80 for odd.
//
// Host side: CFG1 in_prev0 <- host_in[0] (8); CFG2 slot 17 = edge pending
// (code 15); CFG3 = SMP_EN | SMP_SRC(2) | SMP_FALL | SMP_TIMER; CRC_POLY =
// 0x80, CRC_EXPECTED = 0x80; PRELOAD = the time-out - 1; PRELOAD2 = the
// first-clock time | T2_RELOAD | T2_STATE(WAIT1, the state that drives
// pin_out[2]) | T2_ONESHOT; per command CONST = parity << 8 | byte.
// =======================================================
module chroma_ps2_host
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd3;   // DATA on ui_in[3]
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b1;   // count1 is cleared, by the FSM and by the sampler
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b0;
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled: it clears "edge pending"
   localparam [0:0]  COUNT_UP           = 1'b1;   // count1 counts up ...
   localparam [0:0]  WRAP_PRELOAD       = 1'b1;   // ... to PRELOAD: the time-out
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b0;   // a comm load sets its shift count to 0
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;
   localparam [1:0]  CRC_MODE           = 2'd1;   // CRC8: with the polynomial 0x80, the parity
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // the FSM pushes what the device sent
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;   // the parity is over the bits shifted in
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b0;
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K[{out20, out18}]
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_COND0 = 3'd4, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;          // CLK pull-low
   localparam [2:0]  UO2_SRC  = PIN_COND0;         // DATA pull-low
   localparam [20:0] PINMUX   = {PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [3:0]  STATE_IDLE      = 4'd0;
   localparam [3:0]  STATE_START     = 4'd1;   // from the device: is it a start bit?
   localparam [3:0]  STATE_BIT       = 4'd2;   // a data bit
   localparam [3:0]  STATE_BITS      = 4'd3;   // eight?
   localparam [3:0]  STATE_PARITY    = 4'd4;   // the parity bit
   localparam [3:0]  STATE_STOP      = 4'd5;   // the stop bit
   localparam [3:0]  STATE_CHECK     = 4'd6;   // stop 1, parity odd: the byte
   localparam [3:0]  STATE_ERROR     = 4'd7;
   localparam [3:0]  STATE_HOLD      = 4'd8;   // to the device: CLK low
   localparam [3:0]  STATE_REQUEST   = 4'd9;   // DATA low as well
   localparam [3:0]  STATE_WAIT1     = 4'd10;  // CLK released: the device's first clock
   localparam [3:0]  STATE_SEND      = 4'd11;  // a bit on DATA
   localparam [3:0]  STATE_SENT      = 4'd12;  // eight?
   localparam [3:0]  STATE_SPARITY   = 4'd13;  // the parity bit on DATA
   localparam [3:0]  STATE_SSTOP     = 4'd14;  // DATA released: the stop bit
   localparam [3:0]  STATE_ACK       = 4'd15;  // DATA low is the device's acknowledge

   reg   [3:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           data;
   wire           shift_data;
   wire           host0;
   wire           timeout;
   wire           shift_term;
   wire           in_prev0;
   wire           pending;
   wire           parity_odd;
   wire           first_late;

   assign data                 = in_data[3];      // the DATA line
   assign shift_data           = in_data[7];      // the bit to send
   assign host0                = in_data[8];      // toggles: send K0
   assign timeout              = in_data[10];     // count1_term: no clock for PRELOAD + 1 clocks
   assign shift_term           = in_data[14];     // eight bits since the comm load
   assign in_prev0             = in_data[16];     // host_in[0] at the last command
   assign pending              = in_data[17];     // slot: CLK fell
   assign parity_odd           = in_data[22];     // crc_ok (CRC_EXPECTED = 0x80)
   assign first_late           = in_data[28];     // timer 2: the device made no clock after the request

   // =======================================================
   // Outputs
   // =======================================================
   reg            clk_low;        // pin_out[0]: pull CLK low
   reg            waiting;        // pin_out[2]: marks WAIT1 (timer 2 restarts as it is entered)
   reg            latch;          // OUT_LATCH: clears "edge pending"
   reg            fifo_push;      // OUT_FIFO_WR_RD
   reg            count1_step;    // OUT_COUNT1_INC_DEC: the time-out counts in every state
   reg            count1_clear;   // OUT_COUNT1_CLEAR_LOAD
   reg            shift_en;       // OUT_SHIFT (it clears "edge pending" too)
   reg            count3_inc;     // OUT_COUNT3: one more error
   reg            crc_clear;      // OUT_CRC_CLEAR
   reg            crc_update;     // OUT_CRC_UPDATE: the bit on DATA into the parity
   reg            host_irq;       // OUT_HOST_INTERRUPT
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K
   reg            ksel0;          // OUT_K_SEL0: K1, the parity to send

   assign out_data[0]          = clk_low;
   assign out_data[2]          = waiting;
   assign out_data[4]          = latch;
   assign out_data[5]          = fifo_push;
   assign out_data[6]          = count1_step;
   assign out_data[7]          = count1_clear;
   assign out_data[8]          = shift_en;
   assign out_data[11]         = count3_inc;
   assign out_data[12]         = crc_clear;
   assign out_data[13]         = crc_update;
   assign out_data[14]         = host_irq;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
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

      clk_low        = 1'b0;
      waiting        = 1'b0;
      latch          = 1'b0;
      fifo_push      = 1'b0;
      count1_step    = 1'b1;
      count1_clear   = 1'b0;
      shift_en       = 1'b0;
      count3_inc     = 1'b0;
      crc_clear      = 1'b0;
      crc_update     = 1'b0;
      host_irq       = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      cond_out[0]    = 1'b0;      // DATA pull-low
      cond_out[1]    = 1'b0;
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:                                  // a frame from the device first, then the host's command
         begin
            if (pending)
               next_state  = STATE_START;
            else if (host0 != in_prev0)
            begin
               count1_clear = 1'b1;                // CLK low from here, for the time-out period
               next_state   = STATE_HOLD;
            end
         end

      // ---- from the device
      STATE_START:
         begin
            if (!data)                             // the start bit: parity and byte count from zero
            begin
               latch       = 1'b1;
               crc_clear   = 1'b1;
               comm_load   = 1'b1;
               next_state  = STATE_BIT;
            end
            else if (data)                         // not one: a glitch on CLK
            begin
               latch       = 1'b1;
               next_state  = STATE_IDLE;
            end
         end

      STATE_BIT:
         begin
            if (pending)
            begin
               shift_en    = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_BITS;
            end
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_BITS:
         begin
            if (shift_term)
               next_state  = STATE_PARITY;
            else if (!shift_term)
               next_state  = STATE_BIT;
         end

      STATE_PARITY:                                // into the parity, not into the byte
         begin
            if (pending)
            begin
               latch       = 1'b1;
               crc_update  = 1'b1;
               next_state  = STATE_STOP;
            end
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_STOP:
         begin
            if (pending)
               next_state  = STATE_CHECK;
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_CHECK:
         begin
            if (data && parity_odd)                // the byte
            begin
               latch       = 1'b1;
               fifo_push   = 1'b1;
               host_irq    = 1'b1;
               next_state  = STATE_IDLE;
            end
            else if (!data || !parity_odd)
               next_state  = STATE_ERROR;
         end

      STATE_ERROR:                                 // both lines released
         begin
            latch       = 1'b1;
            host_irq    = 1'b1;
            count3_inc  = 1'b1;
            next_state  = STATE_IDLE;
         end

      // ---- to the device
      STATE_HOLD:                                  // CLK low: the device stops and listens
         begin
            clk_low     = 1'b1;
            if (timeout)
            begin
               comm_load   = 1'b1;                 // K0: the byte
               next_state  = STATE_REQUEST;
            end
         end

      STATE_REQUEST:                               // DATA low before CLK goes; our own edge on CLK is not a bit
         begin
            clk_low     = 1'b1;
            cond_out[0] = 1'b1;
            latch       = 1'b1;
            next_state  = STATE_WAIT1;
         end

      STATE_WAIT1:                                 // DATA low is the start bit; the device makes the clock
         begin
            waiting     = 1'b1;
            cond_out[0] = 1'b1;
            if (pending)                           // CLK fell: the first data bit goes on DATA
            begin
               waiting     = 1'b1;
               latch       = 1'b1;
               next_state  = STATE_SEND;
            end
            else if (first_late)
               next_state  = STATE_ERROR;
         end

      STATE_SEND:                                  // the device takes the bit as CLK rises
         begin
            cond_out[0] = 1'b1;                    // a 0 pulls DATA low
            if (shift_data)
               cond_out[0] = 1'b0;
            if (pending)
            begin
               shift_en    = 1'b1;
               next_state  = STATE_SENT;
            end
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_SENT:
         begin
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (shift_term)                        // eight are out: the parity, from K1
            begin
               comm_load   = 1'b1;
               ksel0       = 1'b1;
               next_state  = STATE_SPARITY;
            end
            else if (!shift_term)
               next_state  = STATE_SEND;
         end

      STATE_SPARITY:
         begin
            cond_out[0] = 1'b1;
            if (shift_data)
               cond_out[0] = 1'b0;
            if (pending)
            begin
               latch       = 1'b1;
               next_state  = STATE_SSTOP;
            end
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_SSTOP:                                 // DATA released
         begin
            if (pending)
               next_state  = STATE_ACK;
            else if (timeout)
               next_state  = STATE_ERROR;
         end

      STATE_ACK:
         begin
            if (!data)                             // the device has it
            begin
               latch       = 1'b1;
               host_irq    = 1'b1;
               next_state  = STATE_IDLE;
            end
            else if (data)
               next_state  = STATE_ERROR;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
