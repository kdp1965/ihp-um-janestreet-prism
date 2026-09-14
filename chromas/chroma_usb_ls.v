// =======================================================
// PRISM USB low-speed device Chroma (evaluation, v1)
//
// A 1.5 Mbit/s USB device on two input pins (D+ = ui_in[4], D- = ui_in[5])
// and three output pins (D+ = uo_out[2] = cond_out[0], D- = uo_out[3] =
// cond_out[1], OE = uo_out[4] = pin_out[2]) driving external tri-state
// buffers; the inputs see the line, i.e. the device's own drive while OE.
// Low speed: idle J = D+ 0 / D- 1.
//
// Receive: from the first K the bit engine samples every bit at its
// centre (count1 = half-bit timer, two terminal counts per bit), NRZI
// decodes against in_prev1 (the D- level at the previous sample, captured
// by the sampling tree), drops stuffed zeros (count2 counts ones, compare
// = 6), shifts the decoded bit in through cond_out[0] and feeds the CRC.
// Byte boundaries come from shift_term.  Phase in the FSM flags
// (latched_in = {F1, F0}): 01 = sync / PID, 10 = IN token bytes, 11 =
// data bytes (pushed into FIFO A, CRC16 checked), 00 = anything else
// (OUT / SETUP token bytes, handshakes) until EOP.  EOP (SE0) then: DATA
// -> send ACK; IN -> send the response the CPU queued in FIFO B (PID,
// payload, CRC16), or NAK when it is empty.
//
// Transmit: NRZI through J / K state pairs, count1 half-bit timer,
// stuffing from count2.  Sync / ACK / NAK come from the constant table
// (K0 = 0x80, K1 = 0xD2, K2 = 0x5A; K3 = address, unused in v1), bytes
// from FIFO B.  TX phase: F1 = handshake pending (F2: 0 = ACK, 1 = NAK),
// F1 = 0 & F2 = 1 = FIFO bytes, F1 = F2 = 0 = EOP next; F0 mirrors the
// line level (D+ is cond_out[0], which OUT_LATCH also stores).  After the
// last bit the line is held one bit from F0, then SE0 for 1.5 bits and
// release.
//
// Not in v1 (findings): address match, CRC5 on tokens, CRC16 on TX (CPU
// computes it), DATA0/1 toggle, edge resync during a packet.
//
// Host set-up: CFG1 in_prev1 <- input 5 (D-); CFG2 slots: in16 = flag2,
// in19 = comm[0], in28..30 = comm[1..3], in31 = comm == K3;
// CONST = {addr, 0x5A, 0xD2, 0x80}; compare = 6; preload = half bit - 1;
// CRC_EXPECTED = 0xB001; shard 1 CFG0 fifo_dir = TX (FIFO B).
// =======================================================
module chroma_usb_ls
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

   // CFG0: shift_en, LSB first, latch_en, CRC16 reflected init ones,
   // shifter input from cond_out[0], flag latch, comm loads from CONST
   // CFG0 (ctrl_reg), one named field per bit group
   localparam [0:0]  FIFO_SRAM      = 1'd0;  // 0 = the flop FIFO; the host may OR CFG_FIFO_SRAM in for the SRAM FIFO
   localparam [0:0]  COMM_LOAD_K    = 1'd1;  // OUT_COMM_LOAD loads constant K[{out20, out18}] instead of preload[7:0]
   localparam [0:0]  FLAG_LATCH     = 1'd1;  // OUT_LATCH stores {cond_out[1:0]} in latched_in and out19 in flag2
   localparam [0:0]  SHIFT_IN_COND  = 1'd1;  // shifter input = cond_out[0] instead of a pin
   localparam [0:0]  CRC_SRC_OUT    = 1'd0;  // 0 = CRC over the shifter input bit, 1 = over its output bit
   localparam [0:0]  CRC_XOR_OUT    = 1'd0;  // complement the CRC on OUT_LOAD_CRC
   localparam [0:0]  CRC_INIT_ONES  = 1'd1;  // OUT_CRC_CLEAR presets all ones instead of zero
   localparam [0:0]  SEMA_SET_WINS  = 1'd0;  // semaphore set beats clear in the same cycle
   localparam [0:0]  FIFO_DIR_TX    = 1'd0;  // 0 = RX (FSM pushes, host reads), 1 = TX (host writes, FSM pops)
   localparam [0:0]  CRC_REFLECT    = 1'd1;  // 1 = LSB-first LFSR (reflected polynomial)
   localparam [1:0]  CRC_MODE       = 2'd2;  // 0 off, 1 = CRC8, 2 = CRC16, 3 = CRC32
   localparam [1:0]  IN_SYNC_SEL    = 2'd0;  // 0 = 2-flop sync, 1 = 1 flop, 2 = raw pins
   localparam [0:0]  COMM_LOAD_ONE  = 1'd0;  // OUT_COMM_LOAD also loads a 1 into the shifter
   localparam [0:0]  SHIFT_LOAD_ONE = 1'd0;  // OUT_SHIFT with preload loads a 1
   localparam [0:0]  WRAP_PRELOAD   = 1'd0;  // count1 wraps to preload
   localparam [0:0]  COUNT_UP       = 1'd0;  // count1 counts up (0 = down)
   localparam [0:0]  LATCH2         = 1'd1;  // use prism_out[2] as input latch enable
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
   // uo_out[2] = cond_out[0] (D+), uo_out[3] = cond_out[1] (D-), uo_out[4] = pin_out[2] (OE)
   // uo_out[7:1] sources, 3 bits per pin: pin_out[k], cond_out[k], the
   // shifter's output bit, or 7 = this chroma leaves the pin alone
   localparam [2:0]  PIN_OUT0  = 3'd0, PIN_OUT1 = 3'd1, PIN_OUT2 = 3'd2, PIN_OUT3 = 3'd3;
   localparam [2:0]  PIN_COND0 = 3'd4, PIN_COND1 = 3'd5, PIN_SHIFT = 3'd6, PIN_OFF = 3'd7;
   localparam [2:0]  UO1_SRC  = PIN_OFF;
   localparam [2:0]  UO2_SRC  = PIN_COND0;
   localparam [2:0]  UO3_SRC  = PIN_COND1;
   localparam [2:0]  UO4_SRC  = PIN_OUT2;
   localparam [2:0]  UO5_SRC  = PIN_OFF;
   localparam [2:0]  UO6_SRC  = PIN_OFF;
   localparam [2:0]  UO7_SRC  = PIN_OFF;
   localparam [20:0] PINMUX    = {UO7_SRC, UO6_SRC, UO5_SRC, UO4_SRC, UO3_SRC, UO2_SRC, UO1_SRC};

   // =======================================================
   // States (INC targets must be the next state: J_DEC -> K_CHK,
   // K_NEXT -> K_NEXT2, K_DEC -> J_CHK, J_NEXT -> J_NEXT2)
   // =======================================================
   localparam [4:0]  ST_IDLE      = 5'd0;
   localparam [4:0]  ST_RX_WAIT_A = 5'd1;
   localparam [4:0]  ST_RX_WAIT_B = 5'd2;
   localparam [4:0]  ST_RX_SAMPLE = 5'd3;
   localparam [4:0]  ST_RX_ZERO   = 5'd4;
   localparam [4:0]  ST_RX_CHECK  = 5'd5;
   localparam [4:0]  ST_RX_BYTE   = 5'd6;
   localparam [4:0]  ST_RX_BYTE2  = 5'd7;
   localparam [4:0]  ST_RX_PID    = 5'd8;
   localparam [4:0]  ST_RX_PID2   = 5'd9;
   localparam [4:0]  ST_RX_TOKEN  = 5'd10;
   localparam [4:0]  ST_RX_NONTOK = 5'd11;
   localparam [4:0]  ST_RX_EOP    = 5'd12;
   localparam [4:0]  ST_RX_EOP2   = 5'd13;
   localparam [4:0]  ST_RX_EOP3   = 5'd14;
   localparam [4:0]  ST_TX_J_A    = 5'd15;
   localparam [4:0]  ST_TX_J_A2   = 5'd16;
   localparam [4:0]  ST_TX_J_DEC  = 5'd17;
   localparam [4:0]  ST_TX_K_CHK  = 5'd18;
   localparam [4:0]  ST_TX_K_NEXT = 5'd19;
   localparam [4:0]  ST_TX_K_NEXT2= 5'd20;
   localparam [4:0]  ST_TX_K_A    = 5'd21;
   localparam [4:0]  ST_TX_K_A2   = 5'd22;
   localparam [4:0]  ST_TX_K_DEC  = 5'd23;
   localparam [4:0]  ST_TX_J_CHK  = 5'd24;
   localparam [4:0]  ST_TX_J_NEXT = 5'd25;
   localparam [4:0]  ST_TX_J_NEXT2= 5'd26;
   localparam [4:0]  ST_TX_HOLD_A = 5'd27;
   localparam [4:0]  ST_TX_HOLD_A2= 5'd28;
   localparam [4:0]  ST_TX_SE0_1  = 5'd29;
   localparam [4:0]  ST_TX_SE0_2  = 5'd30;
   localparam [4:0]  ST_TX_SE0_3  = 5'd31;

   reg   [4:0]    curr_state, next_state;

   // =======================================================
   // Inputs
   // =======================================================
   wire dp          = in_data[4];
   wire dm          = in_data[5];
   wire count1_zero = in_data[10];
   wire count2_cmp  = in_data[11];   // count2 >= 6: six ones in a row
   wire f0          = in_data[12];   // phase bit 0 (latched_in[0])
   wire f1          = in_data[13];   // phase bit 1
   wire shift_term  = in_data[14];   // 8 bits shifted
   wire f2          = in_data[16];   // slot: flag2 (TX phase)
   wire in_prev1    = in_data[17];   // D- at the previous sample
   wire comm0       = in_data[19];   // slot: comm[0]
   wire fifob_empty = in_data[26];   // FIFO B (TX) empty
   wire comm1       = in_data[28];   // slot: comm[1]
   wire comm2       = in_data[29];   // slot: comm[2]
   wire comm3       = in_data[30];   // slot: comm[3]
   wire shift_data  = in_data[7];    // next bit to send

   // =======================================================
   // Outputs
   // =======================================================
   reg oe_o;                   // pin_out[2]; D+ / D- are cond_out[1:0]
   reg latch;                  // OUT_LATCH (flags <= {cond_out[1:0]}, flag2 <= flag2_v)
   reg fifo_op;                // OUT_FIFO_WR_RD
   reg count1_dec;             // OUT_COUNT1_INC_DEC
   reg count1_load;            // OUT_COUNT1_CLEAR_LOAD
   reg shift;                  // OUT_SHIFT
   reg count2_inc;             // OUT_COUNT2_INC
   reg count2_clear;           // OUT_COUNT2_CLEAR
   reg crc_clear;              // OUT_CRC_CLEAR
   reg crc_update;             // OUT_CRC_UPDATE
   reg push_pop;               // OUT_FIFO_PUSH_POP (1 = FIFO B)
   reg comm_load;              // OUT_COMM_LOAD
   reg ksel0;                  // OUT_K_SEL0
   reg flag2_v;                // OUT_FLAG2
   reg ksel1;                  // OUT_K_SEL1

   assign out_data[2]  = oe_o;
   assign out_data[4]  = latch;
   assign out_data[5]  = fifo_op;
   assign out_data[6]  = count1_dec;
   assign out_data[7]  = count1_load;
   assign out_data[8]  = shift;
   assign out_data[9]  = count2_inc;
   assign out_data[11] = count2_clear;
   assign out_data[12] = crc_clear;
   assign out_data[13] = crc_update;
   assign out_data[15] = push_pop;
   assign out_data[16] = comm_load;
   assign out_data[18] = ksel0;
   assign out_data[19] = flag2_v;
   assign out_data[20] = ksel1;

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
      next_state   = curr_state;

      oe_o         = 1'b0;
      latch        = 1'b0;
      fifo_op      = 1'b0;
      count1_dec   = 1'b1;      // the bit timer runs in every state
      count1_load  = 1'b0;
      shift        = 1'b0;
      count2_inc   = 1'b0;
      count2_clear = 1'b0;
      crc_clear    = 1'b0;
      crc_update   = 1'b0;
      push_pop     = 1'b0;
      comm_load    = 1'b0;
      ksel0        = 1'b0;
      flag2_v      = 1'b0;
      ksel1        = 1'b0;
      cond_out[0]  = 1'b0;
      cond_out[1]  = 1'b0;
      pinmux_reg   = PINMUX;
      ctrl_reg     = CTRL;

      case (curr_state)
      // ---------------------------------------------------- receive
      ST_IDLE:
         begin
            // phase 01 (sync / PID), counters primed; a K starts a packet
            cond_out[0]  = 1'b1;
            latch        = 1'b1;
            count2_clear = 1'b1;
            if (dp)
            begin
               count1_load = 1'b1;           // half a bit to the first centre
               next_state  = ST_RX_WAIT_B;
            end
         end

      ST_RX_WAIT_A:                          // first half bit
         begin
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_RX_WAIT_B;
            end
            else if (!dp && !dm)
               next_state  = ST_RX_EOP;
         end

      ST_RX_WAIT_B:                          // second half bit, then sample
         begin
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_RX_SAMPLE;
            end
            else if (!dp && !dm)
               next_state  = ST_RX_EOP;
         end

      ST_RX_SAMPLE:                          // NRZI: no transition = 1
         begin
            cond_out[0] = 1'b0;
            if (dm == in_prev1)
               cond_out[0] = 1'b1;
            if (dm == in_prev1)
            begin
               shift       = 1'b1;
               count2_inc  = 1'b1;
               crc_update  = 1'b1;
               next_state  = ST_RX_CHECK;
            end
            else if (dm != in_prev1)
               next_state  = ST_RX_ZERO;
         end

      ST_RX_ZERO:                            // a 0: stuffed after six ones
         begin
            cond_out[0] = 1'b0;
            if (count2_cmp)
            begin
               count2_clear = 1'b1;
               next_state   = ST_RX_WAIT_A;
            end
            else if (!count2_cmp)
            begin
               shift        = 1'b1;
               count2_clear = 1'b1;
               crc_update   = 1'b1;
               next_state   = ST_RX_CHECK;
            end
         end

      ST_RX_CHECK:
         begin
            if (shift_term)
               next_state = ST_RX_BYTE;
            else if (!shift_term)
               next_state = ST_RX_WAIT_A;
         end

      ST_RX_BYTE:                            // a byte is in comm
         begin
            if (f0 && f1)                    // data phase: push it
            begin
               fifo_op    = 1'b1;
               next_state = ST_RX_WAIT_A;
            end
            else if (!(f0 && f1))
               next_state = ST_RX_BYTE2;
         end

      ST_RX_BYTE2:
         begin
            if (f0 && !f1)                   // sync / PID phase
               next_state = ST_RX_PID;
            else if (!f0)                    // token bytes or ignored
               next_state = ST_RX_WAIT_A;
         end

      ST_RX_PID:                             // sync byte (0x80) or a PID
         begin
            if (!comm0 && !comm1)
               next_state = ST_RX_WAIT_A;
            else if (comm0 || comm1)
               next_state = ST_RX_PID2;
         end

      ST_RX_PID2:
         begin
            if (!comm1)                      // token
               next_state = ST_RX_TOKEN;
            else if (comm1)                  // data or handshake
               next_state = ST_RX_NONTOK;
         end

      ST_RX_TOKEN:                           // IN -> phase 10, OUT / SETUP -> 00
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;
            if (comm3 && !comm2)
               cond_out[1] = 1'b1;
            latch      = 1'b1;
            next_state = ST_RX_WAIT_A;
         end

      ST_RX_NONTOK:                          // data -> phase 11 + CRC start, else 00
         begin
            cond_out[0] = 1'b0;
            cond_out[1] = 1'b0;
            if (comm0)
            begin
               cond_out[0] = 1'b1;
               cond_out[1] = 1'b1;
            end
            if (comm0)
            begin
               latch      = 1'b1;
               crc_clear  = 1'b1;
               next_state = ST_RX_WAIT_A;
            end
            else if (!comm0)
            begin
               latch      = 1'b1;
               next_state = ST_RX_WAIT_A;
            end
         end

      ST_RX_EOP:                             // SE0 seen: wait for J
         begin
            if (dm)
               next_state = ST_RX_EOP2;
         end

      ST_RX_EOP2:                            // anything to send?  (phase 1x)
         begin
            if (f1)
               next_state = ST_RX_EOP3;
            else if (!f1)
               next_state = ST_IDLE;
         end

      ST_RX_EOP3:                            // DATA -> ACK (F1, F2 = 0); IN -> FIFO bytes
         begin                               // (F2 = 1, F1 = 0) or NAK (F2 = 1, F1 = 1)
            cond_out[0] = 1'b0;              // entering on J
            cond_out[1] = 1'b0;
            if (f0 || fifob_empty)
               cond_out[1] = 1'b1;
            if (f0)
            begin
               comm_load    = 1'b1;          // K0 = sync
               latch        = 1'b1;
               flag2_v      = 1'b0;
               count1_load  = 1'b1;
               count2_clear = 1'b1;
               next_state   = ST_TX_J_A;
            end
            else if (!f0)
            begin
               comm_load    = 1'b1;
               latch        = 1'b1;
               flag2_v      = 1'b1;
               count1_load  = 1'b1;
               count2_clear = 1'b1;
               next_state   = ST_TX_J_A;
            end
         end

      // ---------------------------------------------------- transmit, line J (cond = 01)
      ST_TX_J_A:
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_J_A2;
            end
         end

      ST_TX_J_A2:
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_J_DEC;
            end
         end

      ST_TX_J_DEC:                           // next bit: stuff / one (stay J) / zero (to K)
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1;
            shift        = 1'b1;             // default path: a 0 -> K_CHK
            count2_clear = 1'b1;
            if (count2_cmp)
            begin
               shift        = 1'b0;
               count2_clear = 1'b1;
               next_state   = ST_TX_K_A;
            end
            else if (!count2_cmp && shift_data)
            begin
               shift        = 1'b1;
               count2_clear = 1'b0;
               count2_inc   = 1'b1;
               next_state   = ST_TX_J_CHK;
            end
            else
               next_state   = ST_TX_K_CHK;
         end

      ST_TX_K_CHK:
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1;
            if (shift_term)
               next_state = ST_TX_K_NEXT;
            else if (!shift_term)
               next_state = ST_TX_K_A;
         end

      ST_TX_K_NEXT:                          // byte done: handshake byte, else NEXT2
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1; // LATCH keeps F0 = K
            if (f1 && !f2)                   // ACK
            begin
               comm_load = 1'b1; ksel0 = 1'b1; latch = 1'b1;
               next_state = ST_TX_K_A;
            end
            else if (f1 && f2)               // NAK
            begin
               comm_load = 1'b1; ksel1 = 1'b1; latch = 1'b1;
               next_state = ST_TX_K_A;
            end
            else
               next_state = ST_TX_K_NEXT2;
         end

      ST_TX_K_NEXT2:                         // FIFO byte, or hold the last bit then EOP
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1;
            if (!f1 && f2 && !fifob_empty)
            begin
               fifo_op  = 1'b1;
               push_pop = 1'b1;
               next_state = ST_TX_K_A;
            end
            else if (!f1 && (!f2 || fifob_empty))
            begin
               latch      = 1'b1;            // F0 <= K: the level HOLD keeps
               next_state = ST_TX_HOLD_A;
            end
         end

      // ---------------------------------------------------- transmit, line K (cond = 10)
      ST_TX_K_A:
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_K_A2;
            end
         end

      ST_TX_K_A2:
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_K_DEC;
            end
         end

      ST_TX_K_DEC:
         begin
            cond_out[0] = 1'b1; oe_o = 1'b1;
            shift        = 1'b1;             // default path: a 0 -> J_CHK
            count2_clear = 1'b1;
            if (count2_cmp)
            begin
               shift        = 1'b0;
               count2_clear = 1'b1;
               next_state   = ST_TX_J_A;
            end
            else if (!count2_cmp && shift_data)
            begin
               shift        = 1'b1;
               count2_clear = 1'b0;
               count2_inc   = 1'b1;
               next_state   = ST_TX_K_CHK;
            end
            else
               next_state   = ST_TX_J_CHK;
         end

      ST_TX_J_CHK:
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1;
            if (shift_term)
               next_state = ST_TX_J_NEXT;
            else if (!shift_term)
               next_state = ST_TX_J_A;
         end

      ST_TX_J_NEXT:
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1; // LATCH keeps F0 = J; F1 <- 0
            if (f1 && !f2)
            begin
               comm_load = 1'b1; ksel0 = 1'b1; latch = 1'b1;
               next_state = ST_TX_J_A;
            end
            else if (f1 && f2)
            begin
               comm_load = 1'b1; ksel1 = 1'b1; latch = 1'b1;
               next_state = ST_TX_J_A;
            end
            else
               next_state = ST_TX_J_NEXT2;
         end

      ST_TX_J_NEXT2:
         begin
            cond_out[1] = 1'b1; oe_o = 1'b1;
            if (!f1 && f2 && !fifob_empty)
            begin
               fifo_op  = 1'b1;
               push_pop = 1'b1;
               next_state = ST_TX_J_A;
            end
            else if (!f1 && (!f2 || fifob_empty))
            begin
               latch      = 1'b1;            // F0 <= J
               next_state = ST_TX_HOLD_A;
            end
         end

      // ---------------------------------------------------- last bit held (level from F0), EOP
      ST_TX_HOLD_A:
         begin
            cond_out[0] = 1'b0;
            if (f0)
               cond_out[0] = 1'b1;
            cond_out[1] = 1'b0;
            if (!f0)
               cond_out[1] = 1'b1;
            oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_HOLD_A2;
            end
         end

      ST_TX_HOLD_A2:
         begin
            cond_out[0] = 1'b0;
            if (f0)
               cond_out[0] = 1'b1;
            cond_out[1] = 1'b0;
            if (!f0)
               cond_out[1] = 1'b1;
            oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_SE0_1;
            end
         end

      ST_TX_SE0_1:                           // SE0 for 1.5 bits, then release
         begin
            oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_SE0_2;
            end
         end

      ST_TX_SE0_2:
         begin
            oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_TX_SE0_3;
            end
         end

      ST_TX_SE0_3:
         begin
            oe_o = 1'b1;
            if (count1_zero)
            begin
               count1_load = 1'b1;
               next_state  = ST_IDLE;
            end
         end

      default:
         next_state = ST_IDLE;
      endcase
   end

endmodule
