// =======================================================
// PRISM 10BASE-T receiver Chroma (evaluation, v1)
//
// Receives Ethernet frames from a Manchester line on a ui_in pin through
// the Manchester bit recoverer (CFG3): its "bit valid" is input 16, the
// recovered bit is the shifter input, and every accepted bit costs one
// state transition that shifts it into comm (LSB first), runs the CRC32
// over it and counts it in count2.  Preamble / SFD: the frame starts at
// the first two consecutive 1s (0x55 .. 0xD5 sent LSB first end in 1, 1),
// read back as comm[7:6] (inputs 17 / 18).  Every eight bits comm is
// pushed into the RX FIFO (meant to be the shard's SRAM FIFO).  count1 is
// the idle timer: reloaded on every bit, its terminal count (no bit for
// two bit times) ends the frame with the host interrupt, and comm is
// reloaded from K0 = 0 so a stale byte or a link pulse cannot look like
// an SFD.  The FCS is checked by the host: with CRC_EXPECTED = the CRC32
// residue 0xDEBB20E3, FLAGS crc_ok says the frame was good.
//
//   RXD = ui_in[CFG3 pin]; no output pins.
//
// Host set-up: CFG3 = pin | enable | (clocks per half bit) << 4 | bit 8
// (shifter from the recoverer); CFG2 slots: input 16 <- 15 (bit valid),
// 17 <- 12 (comm[7]), 18 <- 11 (comm[6]); compare = 8; preload = two bit
// times; CONST K0 = 0; CRC poly 0xEDB88320, CRC_EXPECTED 0xDEBB20E3;
// CFG0 |= FIFO_SRAM as wanted.
//
// Not in v1 (findings): destination address filter, a partial last byte
// is dropped, no carrier / collision sense.
// =======================================================
module chroma_eth_rx
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

   // CFG0: shift_en, shift right (LSB first, newest bit in comm[7]),
   // CRC32 reflected init ones over the shifter input bit, RX FIFO,
   // comm loads from CONST
   // CFG0 (ctrl_reg), one named field per bit group
   localparam [0:0]  FIFO_SRAM      = 1'd0;  // 0 = the flop FIFO; the host may OR CFG_FIFO_SRAM in for the SRAM FIFO
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}] instead of preload[7:0]
   localparam [0:0]  FLAG_LATCH     = 1'd0;  // OUT_LATCH stores {cond_out[1:0]} in latched_in and out19 in flag2
   localparam [0:0]  SHIFT_IN_COND  = 1'd0;  // shifter input = cond_out[0] instead of a pin
   localparam [0:0]  CRC_SRC_OUT    = 1'd0;  // 0 = CRC over the shifter input bit, 1 = over its output bit
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;  // complement the CRC on OUT_LOAD_CRC
   localparam [0:0]  CRC_INIT_ONES  = 1'd1;  // OUT_CRC_CLEAR presets all ones instead of zero
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;  // semaphore set beats clear in the same cycle
   localparam [0:0]  FIFO_DIR_TX    = 1'd0;  // 0 = RX (FSM pushes, host reads), 1 = TX (host writes, FSM pops)
   localparam [0:0]  CRC_REFLECT    = 1'd1;  // 1 = LSB-first LFSR (reflected polynomial)
   localparam [1:0]  CRC_MODE       = 2'd3;  // 0 off, 1 = CRC8, 2 = CRC16, 3 = CRC32
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [0:0]  COMM_LOAD_ONE  = 1'd0;  // OUT_COMM_LOAD also loads a 1 into the shifter
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;  // OUT_SHIFT with preload loads a 1
   localparam [0:0]  WRAP_PRELOAD   = 1'd0;  // count1 wraps to preload
   localparam [0:0]  COUNT_UP       = 1'd0;  // count1 counts up (0 = down)
   localparam [0:0]  LATCH2         = 1'd0;  // use prism_out[2] as input latch enable
   localparam [0:0]  COUNT2_DEC     = 1'd0;  // count2 decrement enable
   localparam [0:0]  COUNT32        = 1'd0;  // 32-bit count1 (0 = 24-bit)
   localparam [0:0]  SHIFT_24_EN    = 1'd0;  // wide shifter (count1) instead of comm
   localparam [0:0]  SHIFT_DIR      = 1'd1;  // 1 = shift right (LSB first, newest bit at the top)
   localparam [0:0]  SHIFT_EN       = 1'd1;  // enable shift operation
   localparam [0:0]  LATCH_IN_OUT   = 1'd0;  // read back latched outputs instead of inputs
   localparam [0:0]  CLR_NOT_LOAD   = 1'd0;  // OUT_COUNT1_CLEAR_LOAD clears (1) or loads from preload (0)
   localparam [1:0]  SHIFT_IN_SEL   = 2'd0;  // shifter input pin ui_in[k]
   localparam [31:0] CTRL           = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                                       CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                                       CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                                       WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT2_DEC, COUNT32, SHIFT_24_EN,
                                       SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD, 4'h0, SHIFT_IN_SEL};
   // no output pins driven
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
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
   localparam [1:0]  ST_WAIT      = 2'd0;    // idle / preamble: wait for a bit
   localparam [1:0]  ST_CHK       = 2'd1;    // two consecutive 1s = end of SFD?
   localparam [1:0]  ST_DWAIT     = 2'd2;    // frame: wait for a bit, or the idle timeout
   localparam [1:0]  ST_DCHK      = 2'd3;    // eight bits in comm: push

   reg   [1:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire count1_zero = in_data[10];   // idle timer
   wire count2_cmp  = in_data[11];   // count2 >= 8
   wire bit_valid   = in_data[16];   // recoverer: a bit is waiting
   wire comm7       = in_data[17];   // newest bit
   wire comm6       = in_data[18];   // the one before

   // =======================================================
   // Outputs
   // =======================================================
   reg fifo_push;              // OUT_FIFO_WR_RD (RX: push comm)
   reg count1_dec;             // OUT_COUNT1_INC_DEC
   reg count1_load;            // OUT_COUNT1_CLEAR_LOAD
   reg shift;                  // OUT_SHIFT (consumes the bit)
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_clear;           // OUT_COUNT2_CLEAR
   reg crc_clear;              // OUT_CRC_CLEAR
   reg crc_update;             // OUT_CRC_UPDATE
   reg host_irq;               // OUT_HOST_INTERRUPT
   reg comm_load;              // OUT_COMM_LOAD (K0 = 0: clear comm)

   assign out_data[5]  = fifo_push;
   assign out_data[6]  = count1_dec;
   assign out_data[7]  = count1_load;
   assign out_data[8]  = shift;
   assign out_data[9]  = count2_inc;
   assign out_data[11] = count2_clear;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[14] = host_irq;
   assign out_data[16] = comm_load;

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 2'h0;
      else
         curr_state <= fsm_enable ? next_state : 2'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state   = curr_state;

      fifo_push    = 1'b0;
      count1_dec   = 1'b1;      // the idle timer runs in every state
      count1_load  = 1'b0;
      shift        = 1'b0;
      count2_inc   = 1'b0;
      count2_clear = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      host_irq     = 1'b0;
      comm_load    = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      ST_WAIT:
         begin
            if (bit_valid)                    // a preamble (or any) bit: take it
            begin
               shift        = 1'b1;
               count1_load  = 1'b1;
               next_state   = ST_CHK;
            end
            else if (count1_zero)             // idle: keep comm clear
            begin
               comm_load    = 1'b1;
               next_state   = ST_WAIT;
            end
         end

      ST_CHK:
         begin
            if (comm7 && comm6)               // 1, 1: the SFD just ended
            begin
               crc_clear    = 1'b1;
               count2_clear = 1'b1;
               next_state   = ST_DWAIT;
            end
            else
               next_state   = ST_WAIT;
         end

      ST_DWAIT:
         begin
            if (bit_valid)                    // frame bit: shift, CRC, count
            begin
               shift        = 1'b1;
               crc_update   = 1'b1;
               count2_inc   = 1'b1;
               count1_load  = 1'b1;
               next_state   = ST_DCHK;
            end
            else if (count1_zero)             // no bit for two bit times: done
            begin
               host_irq     = 1'b1;
               comm_load    = 1'b1;
               next_state   = ST_WAIT;
            end
         end

      ST_DCHK:
         begin
            if (count2_cmp)                   // eight bits: push the byte
            begin
               fifo_push    = 1'b1;
               count2_clear = 1'b1;
               next_state   = ST_DWAIT;
            end
            else
               next_state   = ST_DWAIT;
         end
      endcase
   end
endmodule
