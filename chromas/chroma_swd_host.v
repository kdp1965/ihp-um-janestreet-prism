// =======================================================
// PRISM SWD host Chroma (2026-09-29: 20 states)
//
// An ARM Serial Wire Debug host (ADIv5): it makes SWCLK, drives SWDIO or
// lets the target drive it, and runs a transfer from the request to the
// data with the turnarounds between them.  Unfractured (shard 0 owns both
// FIFOs); SWDIO goes through an external buffer with an output enable, as
// the lanes of the SPI master do.
//
//   PRISM_SIGNAL    TT Pin        Function
//   ============    ===========   ======================
//   pin_out[0]      uo_out[1]     SWCLK (idle high)
//   shift_data      uo_out[2]     SWDIO out (comm bit 0: LSB first)
//   pin_out[1]      uo_out[3]     SWDIO output enable: 1 = the host drives
//   prism_in[2]     ui_in[2]      SWDIO level
//
// Two operations, started by a toggle of host_in[0], host interrupt at the
// end:
//
//   COMPARE != 0   RAW: LIMIT3 + 1 bits from FIFO B, the host driving: the
//                  line reset (56 ones), the JTAG-to-SWD sequence, idle
//                  cycles.  Nothing comes back.
//   COMPARE = 0    TRANSFER: LIMIT3 = 7 and the request byte in FIFO B
//                  (start, APnDP, RnW, A2, A3, parity, stop, park: 0xA5
//                  reads DPIDR), host_in[1] = its RnW bit, and for a write
//                  five more bytes, the data and its parity in bit 0 of the
//                  last.
//                    request  8 bits out
//                    Trn      one clock, the line released
//                    ACK      3 bits in (OK = 1 0 0 on the wire)
//                    read:    33 bits in (data, parity), Trn
//                    write:   Trn, 33 bits out
//                    no OK:   Trn, and that is all
//                  FIFO A gets the ACK in the top of a byte (>> 5: 1 OK, 2
//                  WAIT, 4 FAULT, 7 nobody there) and after a read the four
//                  data bytes and the parity in the top of a fifth (>> 7).
//                  The host checks that parity and makes the one it sends.
//
// Timing: the host changes SWDIO when SWCLK falls and the target takes it
// when SWCLK rises; the target changes it when SWCLK rises and the host
// takes it at the end of the low half (through the two-flop synchroniser:
// a half period of 3 clocks or more, PRELOAD >= 2).  The states that
// decide what comes next all sit in a high half, which they make longer by
// their one clock each: SWCLK never makes an edge that is not a bit.
//
// Bit counts: count3 against its limit, which the FSM loads from K2 (the
// ACK: 2) and K3 (the data: 32); the first part of an operation uses the
// limit the host wrote.  Bytes: the comm shift count.  Two flags remember
// where a transfer is: "data" (latched_in[0]) and "write" (latched_in[1]).
//
// Host side: CFG1 in_prev0 <- host_in[0] (8); CFG2 slots 17-19 = comm[5],
// comm[6], comm[7] (codes 10, 11, 12: the ACK); CONST = 0x2002FF00 (K3 32,
// K2 2, K1 0xFF the idle line, K0); COMM = 0xFF before the PRISM is
// enabled; shard 1's CFG0 = FIFO_DIR_TX; PRELOAD = half SWCLK period - 1.
// After a transfer that was not OK the host flushes FIFO B.
// =======================================================
module chroma_swd_host
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
   localparam [1:0]  SHIFT_IN_SEL       = 2'd2;   // SWDIO level on ui_in[2]
   localparam [0:0]  MSHIFT_EN          = 1'b0;
   localparam [0:0]  CLR_NOT_LOAD       = 1'b0;
   localparam [0:0]  LATCH_IN_OUT       = 1'b0;
   localparam [0:0]  SHIFT_EN           = 1'b1;
   localparam [0:0]  SHIFT_DIR          = 1'b1;   // LSB first
   localparam [0:0]  SHIFT_24_EN        = 1'b0;
   localparam [0:0]  COUNT32            = 1'b0;
   localparam [0:0]  COUNT3_EN          = 1'b1;   // pin_out[3] is count3's second command bit
   localparam [0:0]  LATCH2             = 1'b1;   // OUT_LATCH enabled: the two flags
   localparam [0:0]  COUNT_UP           = 1'b0;
   localparam [0:0]  WRAP_PRELOAD       = 1'b0;
   localparam [0:0]  SHIFT_LOAD_ONE     = 1'b0;
   localparam [0:0]  COMM_LOAD_ONE      = 1'b1;   // a load counts the first bit: shift_term before the eighth
   localparam [1:0]  IN_SYNC_SEL        = 2'd0;   // two flops
   localparam [1:0]  CRC_MODE           = 2'd0;
   localparam [0:0]  CRC_REFLECT        = 1'b0;
   localparam [0:0]  FIFO_DIR_TX        = 1'b0;   // FIFO A is RX: the ACK and the data read
   localparam [0:0]  SEMA_SET_WINS      = 1'b0;
   localparam [0:0]  CRC_INIT_ONES      = 1'b0;
   localparam [0:0]  CRC_XOR_OUT        = 1'b0;
   localparam [0:0]  CRC_SRC_OUT        = 1'b0;
   localparam [0:0]  SHIFT_IN_COND      = 1'b0;
   localparam [0:0]  FLAG_LATCH         = 1'b1;   // OUT_LATCH stores {cond_out[1], cond_out[0]}: write, data
   localparam [0:0]  COMM_LOAD_K        = 1'b1;   // OUT_COMM_LOAD takes K[{out20, out18}]
   localparam [0:0]  FIFO_SRAM          = 1'b0;
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OUT0;          // SWCLK
   localparam [2:0]  UO2_SRC  = PIN_SHIFT;         // SWDIO out
   localparam [2:0]  UO3_SRC  = PIN_OUT1;          // SWDIO output enable
   localparam [20:0] PINMUX   = {PIN_OFF, PIN_OFF, PIN_OFF, PIN_OFF, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States
   // =======================================================
   localparam [4:0]  STATE_IDLE      = 5'd0;
   localparam [4:0]  STATE_TPOP      = 5'd1;   // the next byte to send
   localparam [4:0]  STATE_TL        = 5'd2;   // sending, SWCLK low
   localparam [4:0]  STATE_TH        = 5'd3;   // sending, SWCLK high; the shift at its end
   localparam [4:0]  STATE_THL       = 5'd4;   // SWCLK high of the last bit sent
   localparam [4:0]  STATE_TEND      = 5'd5;   // sent: the end, or a transfer's turnaround
   localparam [4:0]  STATE_TRN_W     = 5'd6;   // the rest of a high half, the line released
   localparam [4:0]  STATE_TRN_L     = 5'd7;   // turnaround, SWCLK low
   localparam [4:0]  STATE_TRN_H     = 5'd8;   // turnaround, SWCLK high
   localparam [4:0]  STATE_TDISP     = 5'd9;   // after it: the ACK ...
   localparam [4:0]  STATE_TDISP2    = 5'd10;  // ... the data to write, or the end
   localparam [4:0]  STATE_RL        = 5'd11;  // receiving, SWCLK low; the sample at its end
   localparam [4:0]  STATE_RPUSH     = 5'd12;  // a byte is in
   localparam [4:0]  STATE_RH        = 5'd13;  // receiving, SWCLK high
   localparam [4:0]  STATE_RLL       = 5'd14;  // SWCLK low of the last bit received
   localparam [4:0]  STATE_RENDP     = 5'd15;  // what is in comm goes to the FIFO
   localparam [4:0]  STATE_RDISP     = 5'd16;  // received: the data, or the ACK ...
   localparam [4:0]  STATE_RDISP2    = 5'd17;  // ... which is OK or not ...
   localparam [4:0]  STATE_RDISP3    = 5'd18;  // ... for a read or a write
   localparam [4:0]  STATE_DONE      = 5'd19;  // host interrupt

   reg   [4:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire           host0;
   wire           reading;
   wire           tick;
   wire           transfer;
   wire           in_data_part;
   wire           writing;
   wire           shift_term;
   wire           in_prev0;
   wire           ack0;
   wire           ack1;
   wire           ack2;
   wire           fifo_b_empty;
   wire           last;

   assign host0                = in_data[8];      // toggles: start
   assign reading              = in_data[9];      // host_in[1]: the transfer's RnW
   assign tick                 = in_data[10];     // count1_term: half a period done
   assign transfer             = in_data[11];     // count2 (0) >= COMPARE: COMPARE = 0
   assign in_data_part         = in_data[12];     // flag: past the ACK
   assign writing              = in_data[13];     // flag: the turnaround leads to the data to write
   assign shift_term           = in_data[14];     // seven bits since the load
   assign in_prev0             = in_data[16];     // host_in[0] at the last start
   assign ack0                 = in_data[17];     // slot comm[5]: the first ACK bit
   assign ack1                 = in_data[18];     // slot comm[6]
   assign ack2                 = in_data[19];     // slot comm[7]: the last
   assign fifo_b_empty         = in_data[26];
   assign last                 = in_data[29];     // count3 >= its limit: the last bit of this part

   // =======================================================
   // Outputs
   // =======================================================
   reg            swclk;          // pin_out[0]
   reg            oe;             // pin_out[1]: the host drives SWDIO
   reg            count3_hi;      // pin_out[3]: count3 command bit 1 (alone: clear; with bit 0: limit load)
   reg            latch;          // OUT_LATCH: store the flags
   reg            fifo_op;        // OUT_FIFO_WR_RD
   reg            count1_dec;
   reg            count1_load;
   reg            shift_en;
   reg            count3_lo;      // OUT_COUNT3: command bit 0 (alone: + 1)
   reg            host_irq;
   reg            push_pop;       // OUT_FIFO_PUSH_POP: 1 = FIFO B (pop), 0 = FIFO A (push)
   reg            comm_load;      // OUT_COMM_LOAD: comm <= K
   reg            ksel0;          // OUT_K_SEL0
   reg            ksel1;          // OUT_K_SEL1

   assign out_data[0]          = swclk;
   assign out_data[1]          = oe;
   assign out_data[3]          = count3_hi;
   assign out_data[4]          = latch;
   assign out_data[5]          = fifo_op;
   assign out_data[6]          = count1_dec;
   assign out_data[7]          = count1_load;
   assign out_data[8]          = shift_en;
   assign out_data[11]         = count3_lo;
   assign out_data[14]         = host_irq;
   assign out_data[15]         = push_pop;
   assign out_data[16]         = comm_load;
   assign out_data[18]         = ksel0;
   assign out_data[20]         = ksel1;
   // other out_data bits unused by this chroma

   // =======================================================
   // State register
   // =======================================================
   always @(posedge clk or negedge rst_n)
   begin
      if (~rst_n)
         curr_state <= 5'h0;
      else
         curr_state <= fsm_enable ? next_state : 5'h0;
   end

   // =======================================================
   // Next state and outputs
   // =======================================================
   always @*
   begin
      next_state     = curr_state;

      swclk          = 1'b1;
      oe             = 1'b0;
      count3_hi      = 1'b0;
      latch          = 1'b0;
      fifo_op        = 1'b0;
      count1_dec     = 1'b0;
      count1_load    = 1'b0;
      shift_en       = 1'b0;
      count3_lo      = 1'b0;
      host_irq       = 1'b0;
      push_pop       = 1'b0;
      comm_load      = 1'b0;
      ksel0          = 1'b0;
      ksel1          = 1'b0;
      cond_out[0]    = 1'b0;      // the "data" flag OUT_LATCH stores
      cond_out[1]    = 1'b0;      // the "write" flag
      pinmux_reg     = PINMUX;
      ctrl_reg       = {FIFO_SRAM, COMM_LOAD_K, FLAG_LATCH, SHIFT_IN_COND,
                        CRC_SRC_OUT, CRC_XOR_OUT, CRC_INIT_ONES, SEMA_SET_WINS, FIFO_DIR_TX,
                        CRC_REFLECT, CRC_MODE, IN_SYNC_SEL, COMM_LOAD_ONE, SHIFT_LOAD_ONE,
                        WRAP_PRELOAD, COUNT_UP, LATCH2, COUNT3_EN,
                        COUNT32, SHIFT_24_EN, SHIFT_DIR, SHIFT_EN, LATCH_IN_OUT, CLR_NOT_LOAD,
                        3'h0, MSHIFT_EN, SHIFT_IN_SEL};

      case (curr_state)
      STATE_IDLE:                                  // SWCLK high, the line driven
         begin
            oe          = 1'b1;
            if (host0 != in_prev0)                 // start: both flags 0, the bits counted from 0
            begin
               latch       = 1'b1;
               count3_hi   = 1'b1;
               next_state  = STATE_TPOP;
            end
         end

      // ---- sending: the first part of an operation, or the data of a write
      STATE_TPOP:                                  // (still the high half: no edge if there is nothing to send)
         begin
            oe          = 1'b1;
            if (fifo_b_empty)
               next_state  = STATE_DONE;
            else if (!fifo_b_empty)
            begin
               fifo_op     = 1'b1;
               push_pop    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TL;
            end
         end

      STATE_TL:                                    // the last bit takes its own high state
         begin
            swclk       = 1'b0;
            oe          = 1'b1;
            count1_dec  = 1'b1;
            if (tick && last)
            begin
               count1_load = 1'b1;
               next_state  = STATE_THL;
            end
            else if (tick)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TH;
            end
         end

      STATE_TH:                                    // the target takes the bit as this state is entered
         begin
            oe          = 1'b1;
            count1_dec  = 1'b1;
            if (tick && shift_term)                // the eighth bit of a byte
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               next_state  = STATE_TPOP;
            end
            else if (tick)
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_TL;
            end
         end

      STATE_THL:
         begin
            oe          = 1'b1;
            count1_dec  = 1'b1;
            if (tick)
               next_state  = STATE_TEND;
         end

      STATE_TEND:                                  // a RAW operation or the data of a write: done
         begin
            oe          = 1'b1;
            if (in_data_part || !transfer)
               next_state  = STATE_DONE;
            else if (!in_data_part && transfer)    // a request: the turnaround, then the ACK
            begin
               count1_load = 1'b1;
               next_state  = STATE_TRN_L;
            end
         end

      // ---- turnaround: one clock with the line released
      STATE_TRN_W:                                 // what is left of the high half of the last bit received
         begin
            count1_dec  = 1'b1;
            if (tick)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TRN_L;
            end
         end

      STATE_TRN_L:
         begin
            swclk       = 1'b0;
            count1_dec  = 1'b1;
            if (tick)
            begin
               count1_load = 1'b1;
               next_state  = STATE_TRN_H;
            end
         end

      STATE_TRN_H:
         begin
            count1_dec  = 1'b1;
            if (tick)
               next_state  = STATE_TDISP;
         end

      STATE_TDISP:
         begin
            if (!in_data_part)                     // after the request: the ACK, 3 bits
            begin
               count3_hi   = 1'b1;
               count3_lo   = 1'b1;                 // limit <= K2, count3 <= 0
               ksel1       = 1'b1;
               comm_load   = 1'b1;                 // (and the byte count from 1)
               count1_load = 1'b1;
               next_state  = STATE_RL;
            end
            else if (in_data_part)
               next_state  = STATE_TDISP2;
         end

      STATE_TDISP2:
         begin
            if (writing)                           // after the ACK of a write: its data, 33 bits
            begin
               count3_hi   = 1'b1;
               count3_lo   = 1'b1;                 // limit <= K3, count3 <= 0
               ksel0       = 1'b1;
               ksel1       = 1'b1;
               next_state  = STATE_TPOP;
            end
            else if (!writing)                     // after the data read, or an ACK that was not OK
               next_state  = STATE_DONE;
         end

      // ---- receiving: the ACK, or the data of a read
      STATE_RL:                                    // the bit is taken as SWCLK rises
         begin
            swclk       = 1'b0;
            count1_dec  = 1'b1;
            if (tick && shift_term)                // the eighth bit of a byte
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RPUSH;
            end
            else if (tick)
            begin
               shift_en    = 1'b1;
               count3_lo   = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RH;
            end
         end

      STATE_RPUSH:
         begin
            fifo_op     = 1'b1;
            comm_load   = 1'b1;                    // the byte count from 1 again
            next_state  = STATE_RH;
         end

      STATE_RH:                                    // the last bit takes its own low state
         begin
            count1_dec  = 1'b1;
            if (tick && last)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RLL;
            end
            else if (tick)
            begin
               count1_load = 1'b1;
               next_state  = STATE_RL;
            end
         end

      STATE_RLL:
         begin
            swclk       = 1'b0;
            count1_dec  = 1'b1;
            if (tick)
            begin
               shift_en    = 1'b1;
               count1_load = 1'b1;
               next_state  = STATE_RENDP;
            end
         end

      STATE_RENDP:                                 // the ACK, or the parity of the data read
         begin
            fifo_op     = 1'b1;
            next_state  = STATE_RDISP;
         end

      STATE_RDISP:
         begin
            if (in_data_part)                      // the data of a read is in
               next_state  = STATE_TRN_W;
            else if (!in_data_part)
               next_state  = STATE_RDISP2;
         end

      STATE_RDISP2:                                // the ACK: 1 0 0 is OK
         begin
            cond_out[0] = 1'b1;                    // "data": what follows is not the ACK any more
            if (ack0 && !ack1 && !ack2)
               next_state  = STATE_RDISP3;
            else if (!ack0 || ack1 || ack2)        // WAIT, FAULT, or nobody: the turnaround and the end
            begin
               latch       = 1'b1;
               next_state  = STATE_TRN_W;
            end
         end

      STATE_RDISP3:
         begin
            cond_out[0] = 1'b1;
            cond_out[1] = 1'b1;                    // "write", unless this is a read
            if (reading)
               cond_out[1] = 1'b0;
            if (reading)                           // the data follows at once, 33 bits
            begin
               latch       = 1'b1;
               count3_hi   = 1'b1;
               count3_lo   = 1'b1;                 // limit <= K3, count3 <= 0
               ksel0       = 1'b1;
               ksel1       = 1'b1;
               comm_load   = 1'b1;
               next_state  = STATE_RH;
            end
            else if (!reading)                     // the turnaround first
            begin
               latch       = 1'b1;
               next_state  = STATE_TRN_W;
            end
         end

      STATE_DONE:                                  // the line driven high again
         begin
            oe          = 1'b1;
            host_irq    = 1'b1;
            comm_load   = 1'b1;
            ksel0       = 1'b1;                    // K1: 0xFF
            next_state  = STATE_IDLE;
         end

      default:
         next_state = STATE_IDLE;
      endcase
   end

endmodule
