// Copyright (c) 2025-2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// PRISM (Programmable Reconfigurable Indexed State Machine) peripheral for the
// TinyQV RISC-V SoC - Jane Street 8x4 version.
//
// A 32-state fracturable PRISM core (two 16-state shards) with one datapath
// per shard (prism_datapath.v: 24/32-bit count1 / shifter, 8-bit count2 with
// compare, 8-bit comm shifter).  Each shard's outputs drive only its own
// datapath; unfractured, shard 0 is the whole machine and shard 1 is idle.
//
// Register map (byte offsets in the 512-byte region, docs/prism_interface.md):
//
//   Common block (0x000-0x0FF)
//     0x000  CTRL        [31] shard 0 interrupt (RO)  [30] enable  [29] shard 1 interrupt (RO)
//            byte 0x003  write bit 7: clear shard 0 interrupt
//            byte 0x007  write bit 7: clear shard 1 interrupt
//     0x004-0x050        debugger / fracture registers (prism.v)
//     0x020  ID
//     0x024  INT_STATUS  [3:2] semaphore seen by shard 1 / shard 0, [1:0] interrupts
//
//   Shard windows, identical layout: shard 0 at 0x100, shard 1 at 0x180
//     +0x00  CFG0     datapath / input configuration (chroma ctrl_reg)
//     +0x04  PINMUX   uo_out[7:1] sources, 3 bits per pin (chroma pinmux_reg)
//     +0x08  PRELOAD  32-bit
//     +0x0C  COUNT1   read = count, write = load
//     +0x10  COUNTS   {comm_count, shift_count, comm, compare, count2}; byte lanes 0-2 writable
//     +0x14  HOST     host_in[1:0]; byte +0x15 write toggles host_in[0] and clears the interrupt
//     +0x18  FLAGS    RO datapath flags
//     +0x1C  CFG1     [19:16] FIFO almost-empty level, [23:20] FIFO almost-full level
//     +0x20  FIFO     byte: write pushes (TX mode), read pops (RX mode)
//     +0x24  FIFO_STATUS {count[21:8], almost_full[3], almost_empty[2], full[1], empty[0]}; any write flushes
//     +0x28  CRC_POLY
//     +0x2C  CRC      value; write = preset
//     +0x30  CRC_EXPECTED
//     +0x34  CFG2     input slot selects: [3:0]/[7:4]/[11:8]/[15:12] inputs 16-19, [19:16]..[31:28] inputs 28-31
//                     (0 = default: in_prev[i] / 0, 1-4 in_prev[0..3], 5-12 comm[0..7], 13 comm == K3, 14 flag2,
//                      15 Manchester bit valid)
//     +0x38  CONST    constants K0 [7:0] .. K3 [31:24]; OUT_COMM_LOAD source with CFG0[30] (select = {out20, out18}),
//                     K3 also the comm match value
//     +0x3C  CFG3     Manchester bit recoverer (prism_mrx.v): [2:0] receive pin (PRISM input 0-6), [3] enable,
//                     [7:4] clocks per half bit, [8] shifter input = the recovered bit (slot code 15 = bit valid)
//     +0x40  PRELOAD2 free-running timer: a 24-bit down counter reloads from it and raises input 28 (default
//                     slot value) for one clock every PRELOAD2 + 1 clocks; 0 = off (Ethernet link pulses)
//     +0x44  TRACE_CFG  (write-only) [0] enable (this shard's trace owns its SRAM; one shard at a time, shard 0 wins),
//                       [1] big: both SRAMs as one buffer, [3:2] trigger: 0 = at once, 1 = in state [12:8], 2 = state
//                       [12:8] taking either jump, 3 = an edge on PRISM input [20:16] ([5:4]: 0 rising, 1 falling,
//                       2/3 either)
//     +0x48  TRACE_CTRL write [0] arm (flushes the SRAM FIFO, waits for the trigger, then records every clock
//                       until the buffer is full), [1] stop; read [0] armed, [1] running, [2] done, [3] big,
//                       [4] active.  Entry (16 bits, two per SRAM word, prism_trace_port.v) = [4:0] SI,
//                       [10:5] LUT mux inputs, [11] tree 0 matched, [12] tree 1 taken, [13] executing (not
//                       halted); the outputs follow from these and the STEW.  1024 entries per SRAM.
//            Readout: the SRAM FIFO wrapper then serves the entries (2 bytes each, low byte first) through the
//            FIFO register of the window that reads that SRAM (shard s's for SRAM s), which acts as the SRAM
//            FIFO in RX mode while the SRAM holds a finished trace (until the trace is switched off or armed
//            again; the shard's own FIFO works as configured until then).  Pushes into a traced SRAM are dropped.
//
// CFG0 bits (chroma ctrl_reg; the datapath ones are decoded in prism_datapath.v):
//     1:0  shift_in_sel      6 clr_not_load     7 latch_in_out    8 shift_en
//     9    shift_dir        10 shift_wide      11 count32        12 count2_dec_en
//     13   latch_en         14 count_up        15 wrap_preload   16 shift_load_one
//     17   comm_load_one    19:18 in_sync_sel (0 = 2 flops, 1 = 1 flop, 2/3 = raw pins)
//     21:20 crc_mode (0 off, 1 = 8, 2 = 16, 3 = 32 bits)   22 crc_reflect
//     23   fifo_dir (0 = RX: FSM pushes comm, host reads; 1 = TX: host writes, FSM pops into comm)
//     24   sema_set_wins (semaphore set beats clear in the same cycle)
//     25   crc_init_ones    26 crc_xor_out (complement on OUT_LOAD_CRC)
//     27   crc_src (0 = shifter input bit, 1 = shifter output bit)
//     28   shift_in_cond (shifter input = cond_out[0], e.g. an FSM-decoded bit, instead of a pin)
//     29   flag_latch (OUT_LATCH stores {cond_out[1], cond_out[0]} in latched_in and output 19 in flag2: FSM flags)
//     30   comm_load_k (OUT_COMM_LOAD loads constant K[{out20, out18}] from CONST instead of preload[7:0])
//     31   fifo_sram: this shard's FIFO is an SRAM FIFO (prism_sram_fifo.v on an IHP 1P macro; levels in
//          64-byte units).  SRAM_FIFO parameter: 0 none, 1 one shared FIFO (shard 0 wins if both ask),
//          2 one per shard (shard s owns SRAM s; unfractured shard 0 reaches SRAM 1 as FIFO B)
//
// Output bits (changes.md item 12):
//     0-3  pin_out[3:0]        4  OUT_LATCH             5  OUT_FIFO_WR_RD (Phase 4)
//     6    OUT_COUNT1_INC_DEC  7  OUT_COUNT1_CLEAR_LOAD 8  OUT_SHIFT
//     9    OUT_COUNT2_INC     10  OUT_COUNT2_DEC       11  OUT_COUNT2_CLEAR
//     12   OUT_CRC_CLEAR      13  OUT_CRC_UPDATE       14  OUT_HOST_INTERRUPT
//     15   OUT_SEMA_CLEAR (fractured) / OUT_FIFO_PUSH_POP (unfractured, shard 0: which FIFO bit 5 strobes)
//     16   OUT_COMM_LOAD      17  OUT_LOAD_CRC (selected shifter <= CRC; through comm one byte per load)
//     18   OUT_K_SEL0 (constant select bit 0 for OUT_COMM_LOAD with CFG0[30])
//     19   OUT_SEMA_SET (fractured) / OUT_FLAG2 (value OUT_LATCH stores in flag2 with CFG0[29])
//     20   OUT_K_SEL1 (constant select bit 1)
//
// Unfractured, shard 0 owns both FIFOs: A = its own, B = shard 1's (still
// configured and served by the host through the shard 1 window).  Bit 5
// strobes A when bit 15 is 0 and B when it is 1, each per its own
// direction (push comm into an RX FIFO, pop a TX FIFO into comm); with the
// usual A = RX / B = TX arrangement bit 15 is therefore "push (0) / pop
// (1)", and single-FIFO chromas (bit 15 = 0) behave as before.  Shard 0
// inputs 28-31 show FIFO B's empty / full / almost-empty / almost-full.
//
// Input bits (per shard):
//     6:0  ui_in[6:0] (sync select)  7 shift_data   9:8 host_in   10 count1_term
//     11   count2_cmp   13:12 latched_in (or latched outputs)   14 shift_term
//     15   count2_eq_comm   19:16 in_prev[3:0] (edge-capture flops, sources in CFG1)
//     20   FIFO flag slot E (default empty)   21 FIFO flag slot F (default full)
//     22   crc_ok   23 count1_wrap   24 sema_in   25 other_shard_halt
//     26   FIFO B flag slot E   27 FIFO B flag slot F (shard 0, unfractured; else 0)
//     28    timer2 tick (slot default; CFG2 may select something else)   31:29 spare
//
// CFG1 (per shard):
//     3:0 / 7:4 / 11:8 / 15:12  in_prev[0..3] source: PRISM input number of the
//          edge-capable input the flop follows (0-6 = ui_in pin, 8-9 = host_in);
//          the flop captures its source when a decision tree reading that
//          input fires and the jump is executed (core in_prev_cap strobe)
//     19:16 FIFO almost-empty level   23:20 FIFO almost-full level
//     25:24 / 27:26  flag select for inputs 20 / 21 (own FIFO)
//     29:28 / 31:30  flag select for inputs 26 / 27 (FIFO B, shard 0 unfractured)
//          each slot has a default side (E = empty, F = full): select bit 0
//          picks the almost- flag of that side, bit 1 swaps to the other side,
//          so any two of the four flags reach the two inputs (reset = empty, full)

`default_nettype none

module tqvp_prism #( parameter SRAM_FIFO = 2, parameter SRAM_AW = 9 ) (    // SRAM_FIFO: number of SRAM FIFOs (0/1/2); SRAM_AW 11: 2048x32, 10: 1024x32, 9: 512x32 (2 KB)
    input             clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input             rst_n,        // Reset_n - low to reset.
    input      [7:0]  ui_in,        // The input PMOD, 2-flop synchronized (project.v).  ui_in[7] is normally UART RX.
    input      [7:0]  ui_in_1ff,    // The input PMOD after one synchronizer flop
    input      [7:0]  ui_in_raw,    // The raw input PMOD
    output     [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.

    (* keep = "true" *)
    input     [8:0]   address,      // Byte address within the 512-byte PRISM region (0x200-0x3ff), fully decoded
    (* keep = "true" *)
    input     [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.
    (* keep = "true" *)
    input     [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    (* keep = "true" *)
    input     [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    (* keep = "true" *)
    output reg [31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output            data_ready,

    output     [1:0]  user_interrupt, // Interrupt request per shard

    // State Information Table interface (CFGMEM macros in peripherals.v)
    output    [3:0]   sit_addr_a,
    output    [3:0]   sit_addr_b,
    input   [127:0]   stew_a,
    input   [127:0]   stew_b
);

    // PRISM core configuration.  These must agree with the chroma .cfg used by
    // yosys-prism: 128-bit STEW = 6 muxes x 5 bits, 2 x LUT3 (8 bits each),
    // 2 x 5-bit jump, 3 x 21 outputs, 2 x 4-bit conditional-output LUT2, inc.
    localparam  DEPTH               = 32;
    localparam  PRISM_INPUTS        = 32;
    localparam  OUTPUTS             = 21;
    localparam  PRISM_COND_OUT      = 2;
    localparam  PRISM_COND_LUT_SIZE = 2;
    localparam  PRISM_STATE_INPUTS  = 6;
    localparam  PRISM_LUT_SIZE      = 3;
    localparam  PRISM_FRACTURABLE   = 1;
    localparam  PRISM_DUAL_COMPARE  = 1;
    localparam  SHARDS              = 2;

    // Output bit assignments (changes.md item 12)
    localparam  OUT_LATCH             = 4;
    localparam  OUT_FIFO_WR_RD        = 5;
    localparam  OUT_COUNT1_INC_DEC    = 6;
    localparam  OUT_COUNT1_CLEAR_LOAD = 7;
    localparam  OUT_SHIFT             = 8;
    localparam  OUT_COUNT2_INC        = 9;
    localparam  OUT_COUNT2_DEC        = 10;
    localparam  OUT_COUNT2_CLEAR      = 11;
    localparam  OUT_CRC_CLEAR         = 12;
    localparam  OUT_CRC_UPDATE        = 13;
    localparam  OUT_HOST_INTERRUPT    = 14;
    localparam  OUT_SEMA_CLEAR        = 15;
    localparam  OUT_FIFO_PUSH_POP     = 15;     // same bit, unfractured meaning
    localparam  OUT_COMM_LOAD         = 16;
    localparam  OUT_LOAD_CRC          = 17;
    localparam  OUT_SEMA_SET          = 19;
    localparam  OUT_FLAG2             = 19;     // same bit: value OUT_LATCH loads into flag2
    localparam  OUT_K_SEL0            = 18;     // constant select for OUT_COMM_LOAD (CFG_COMM_LOAD_K)
    localparam  OUT_K_SEL1            = 20;

    // CFG0 bits used here (the rest live in prism_datapath.v)
    localparam  CFG_LATCH_IN_OUT      = 7;
    localparam  CFG_SHIFT_WIDE        = 10;
    localparam  CFG_LATCH_EN          = 13;
    localparam  CFG_IN_SYNC_SEL       = 18;   // [19:18]
    localparam  CFG_CRC_MODE          = 20;   // [21:20]
    localparam  CFG_CRC_REFLECT       = 22;
    localparam  CFG_FIFO_DIR          = 23;
    localparam  CFG_SEMA_SET_WINS     = 24;
    localparam  CFG_CRC_INIT_ONES     = 25;
    localparam  CFG_CRC_XOR_OUT       = 26;
    localparam  CFG_CRC_SRC           = 27;
    localparam  CFG_SHIFT_IN_COND     = 28;   // shifter input = cond_out[0] instead of a pin
    localparam  CFG_FLAG_LATCH        = 29;   // OUT_LATCH loads latched_in from {cond_out[1:0]} (FSM flags)
    localparam  CFG_COMM_LOAD_K       = 30;   // OUT_COMM_LOAD loads comm from constant K[sel] instead of preload
    localparam  CFG_FIFO_SRAM         = 31;   // this shard's FIFO is the 8 KB SRAM FIFO (shard 0 first)

    // Common register addresses
    localparam [8:0] REG_CTRL       = 9'h000;
    localparam [8:0] REG_INT_CLR0   = 9'h003;   // byte
    localparam [8:0] REG_INT_CLR1   = 9'h007;   // byte
    localparam [8:0] REG_ID         = 9'h020;
    localparam [8:0] REG_INT_STATUS = 9'h024;

    // Shard window offsets (shard s base = 0x100 + 0x80 * s)
    localparam [6:0] SH_CFG0    = 7'h00;
    localparam [6:0] SH_PINMUX  = 7'h04;
    localparam [6:0] SH_PRELOAD = 7'h08;
    localparam [6:0] SH_COUNT1  = 7'h0C;
    localparam [6:0] SH_COUNTS  = 7'h10;
    localparam [6:0] SH_HOST    = 7'h14;
    localparam [6:0] SH_TOGGLE  = 7'h15;   // byte
    localparam [6:0] SH_FLAGS   = 7'h18;
    localparam [6:0] SH_CFG1    = 7'h1C;
    localparam [6:0] SH_FIFO    = 7'h20;
    localparam [6:0] SH_FIFO_ST = 7'h24;
    localparam [6:0] SH_CRC_POLY= 7'h28;
    localparam [6:0] SH_CRC     = 7'h2C;
    localparam [6:0] SH_CRC_EXP = 7'h30;
    localparam [6:0] SH_CFG2    = 7'h34;    // input slot selects
    localparam [6:0] SH_CONST   = 7'h38;    // constants K3..K0 (K3 also the comm match value)
    localparam [6:0] SH_CFG3    = 7'h3C;    // Manchester bit recoverer
    localparam [6:0] SH_PRELOAD2 = 7'h40;   // free-running timer period (24 bits)
    localparam [6:0] SH_TRACE_CFG  = 7'h44; // trace: configuration
    localparam [6:0] SH_TRACE_CTRL = 7'h48; //        arm / stop, status
    localparam       TRC_EN   = 0;          // TRACE_CFG bits
    localparam       TRC_BIG  = 1;
    localparam       TRC_TRIG = 2;          // [3:2]
    localparam       TRC_EDGE = 4;          // [5:4]
    localparam       TRC_SI   = 8;          // [12:8]
    localparam       TRC_IN   = 16;         // [20:16]
    localparam       SI_W     = 5;          // state index width (DEPTH 32)
    localparam       CFG3_MRX_EN    = 3;    // CFG3: [2:0] pin, [3] enable, [7:4] clocks per half bit
    localparam       CFG3_SHIFT_MRX = 8;    //       [8] shifter input = recovered bit

    localparam  FIFO_DEPTH  = 16;
    localparam  FIFO_AW     = 4;

    wire                prism_enable;
    wire                prism_wr;
    wire                word_wr;
    wire                byte_wr;
    wire                shard_win;          // address in a shard window
    wire                shard_sel;          // which shard window
    wire [6:0]          shard_off;          // offset within the window
    wire [31:0]         prism_read_data;
    reg                 enable_r;

    // Core interface, shard 0 / shard 1
    wire [PRISM_INPUTS-1:0]   in_data_0, in_data_1;
    wire [OUTPUTS-1:0]        out_data_0, out_data_1;
    wire [PRISM_COND_OUT-1:0] cond_out_0, cond_out_1;
    wire                      fractured;         // cfg_fractured, static at run time
    wire [1:0]                halt;           // per-shard halt, incl. the conditional-break cycle
    wire                      halt_either;    // unused: per-shard halts are used instead

    // Per-shard state exported for the register reads and cross-shard wiring
    wire [32*SHARDS-1:0] cfg0_v;
    wire [21*SHARDS-1:0] pinmux_v;
    wire [32*SHARDS-1:0] preload_v;
    wire [32*SHARDS-1:0] count1_v;
    wire [32*SHARDS-1:0] counts_v;
    wire [32*SHARDS-1:0] flags_v;
    wire [32*SHARDS-1:0] cfg1_v;
    wire [32*SHARDS-1:0] cfg2_v;
    wire [32*SHARDS-1:0] cfg3_v;
    wire [32*SHARDS-1:0] preload2_v;
    wire [32*SHARDS-1:0] const_v;
    wire [32*SHARDS-1:0] fifo_st_v;
    wire [8*SHARDS-1:0]  fifo_head_v;
    wire [8*SHARDS-1:0]  comm_v;            // comm register per shard (FIFO push data)
    wire                 fifo_op_to_b;      // unfractured: shard 0's strobe aimed at FIFO B
    localparam           IN_NUM_BITS = 5;   // PRISM input number width
    wire [4*IN_NUM_BITS*SHARDS-1:0] in_prev_num_v; // per shard: 4 source input numbers
    wire [4*SHARDS-1:0]  in_prev_cap_v;     // per shard: capture strobes from the core
    // SRAM FIFO: per-shard requests, and the one FIFO's outputs
    wire [SHARDS-1:0]    sram_sel_v, sram_push_v, sram_pop_v, sram_flush_v;
    wire [8*SHARDS-1:0]  sram_pdata_v;
    wire [8*SHARDS-1:0]  sram_head_v;       // per SRAM FIFO instance (index = shard, or 0 when shared)
    wire [14*SHARDS-1:0] sram_count_v;
    wire [SHARDS-1:0]    sram_empty_v, sram_full_v;
    localparam [13:0]    SRAM_BYTES = 14'd4 << SRAM_AW;
    // ---- SRAM FIFOs: prism_sram_fifo.v on IHP single-port macros ---------------
    // SRAM_FIFO = 1: one FIFO owned by the shard with CFG0[31] set (shard 0
    // first), its requests routed here and its flags / head fed back.
    // SRAM_FIFO = 2: one FIFO per shard (shard s <-> SRAM s), no sharing.
    localparam SRAM_SHARED = (SRAM_FIFO == 1);
    localparam NSRAM       = (SRAM_FIFO > SHARDS) ? SHARDS : SRAM_FIFO;
    // Trace (section 4m): per shard the 16-bit entry and three strobes for
    // the SRAM trace ports (one shard's set is registered and sent below);
    // per SRAM whether it is full and whether it holds a finished trace
    // (its window's FIFO then reads it).
    wire [SHARDS-1:0]    trc_en_v, trc_big_v, trc_active_v, trc_big_act_v, trc_cap_v, trc_stop_v, trc_arm_v;
    wire [SHARDS-1:0]    trc_full_v, trc_held_v;
    wire [16*SHARDS-1:0] trc_din_v;
    wire [32*SHARDS-1:0] trace_st_v;
    localparam           TRC_CFG_W = 21;    // TRACE_CFG bits in use (write-only: no readback, to spare the read mux)
    wire [SI_W-1:0]      trace_si_0, trace_si_1;
    wire [PRISM_STATE_INPUTS-1:0] trace_mux_0, trace_mux_1;
    wire [1:0]           trace_match_0, trace_match_1;
    // One shard traces at a time (shard 0 wins if both enable): into SRAM
    // s (SRAM 0 when there is only one), or with TRACE_CFG[1] into both
    // SRAMs as one buffer.  One 16-bit bus and three strobes cross the tile
    // from a single set of flops here to the SRAM trace ports.  Two shards.
    assign trc_active_v[0]        = (NSRAM > 0) && trc_en_v[0];
    assign trc_active_v[SHARDS-1] = (NSRAM > 0) && trc_en_v[SHARDS-1] && !trc_en_v[0];
    assign trc_big_act_v[0]        = (NSRAM > 1) && trc_active_v[0] && trc_big_v[0];
    assign trc_big_act_v[SHARDS-1] = (NSRAM > 1) && trc_active_v[SHARDS-1] && trc_big_v[SHARDS-1];
    wire        trc_sel1 = trc_active_v[SHARDS-1];      // whose entry goes out
    reg  [15:0] trc_bus_din;
    reg         trc_bus_cap, trc_bus_arm, trc_bus_stop, trc_stop_r;
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            trc_bus_din  <= 16'h0;
            trc_bus_cap  <= 1'b0;
            trc_bus_arm  <= 1'b0;
            trc_bus_stop <= 1'b0;
            trc_stop_r   <= 1'b0;
        end
        else
        begin
            trc_bus_din  <= trc_sel1 ? trc_din_v[16*(SHARDS-1) +: 16] : trc_din_v[15:0];
            trc_bus_cap  <= trc_sel1 ? trc_cap_v[SHARDS-1]  : trc_cap_v[0];
            trc_bus_arm  <= trc_sel1 ? trc_arm_v[SHARDS-1]  : trc_arm_v[0];
            trc_stop_r   <= trc_sel1 ? trc_stop_v[SHARDS-1] : trc_stop_v[0];  // stop reaches the port after the last entry
            trc_bus_stop <= trc_stop_r;
        end
    end

    // Input slot (inputs 16-19 and 28-31, CFG2 4 bits each): 0 = the slot's
    // default (in_prev[i] for 16-19, 0 for 28-31), 1-4 = in_prev[0..3],
    // 5-12 = comm[0..7], 13 = comm == K3, 14 = flag2
    function slot_val;
        input [3:0] code;
        input       dflt;
        input [3:0] in_prev;
        input [7:0] comm;
        input       match, flag2, mrx_valid;
        begin
            case (code)
                4'd0:    slot_val = dflt;
                4'd1:    slot_val = in_prev[0];
                4'd2:    slot_val = in_prev[1];
                4'd3:    slot_val = in_prev[2];
                4'd4:    slot_val = in_prev[3];
                4'd5:    slot_val = comm[0];
                4'd6:    slot_val = comm[1];
                4'd7:    slot_val = comm[2];
                4'd8:    slot_val = comm[3];
                4'd9:    slot_val = comm[4];
                4'd10:   slot_val = comm[5];
                4'd11:   slot_val = comm[6];
                4'd12:   slot_val = comm[7];
                4'd15:   slot_val = mrx_valid;
                4'd13:   slot_val = match;
                4'd14:   slot_val = flag2;
                default: slot_val = 1'b0;
            endcase
        end
    endfunction

    // FIFO flag input slot: a default side (0 = empty side, 1 = full side);
    // select bit 0 picks the almost- flag, bit 1 swaps to the other side
    function fifo_flag;
        input       full_side;
        input [1:0] sel;
        input       empty, full, ae, af;
        begin
            fifo_flag = (full_side ^ sel[1]) ? (sel[0] ? af : full) : (sel[0] ? ae : empty);
        end
    endfunction
    wire [32*SHARDS-1:0] crc_poly_v;
    wire [32*SHARDS-1:0] crc_v;
    wire [32*SHARDS-1:0] crc_exp_v;
    wire [2*SHARDS-1:0]  host_in_v;
    wire [SHARDS-1:0]    irq_v;
    wire [SHARDS-1:0]    sema_v;            // semaphore as seen by shard s
    wire [SHARDS-1:0]    sema_set_req;      // shard s asserts OUT_SEMA_SET (to the other shard)
    wire [SHARDS-1:0]    halt_r_v;          // registered per-shard halt (breaks the cross-shard comb. path)
    wire [7*SHARDS-1:0]  pin_src_v;         // per-shard candidate value for uo_out[k+1]
    wire [7*SHARDS-1:0]  pin_claim_v;       // per-shard "drives uo_out[k+1]"

    // Pins
    wire  [6:0]         uo_out_c;
    (* keep = "true" *)
    reg   [6:0]         latched_out;

`ifndef SYNTH_FPGA
    (* keep = "true" *)
    reg   [31:0]        latch_data;
    (* keep = "true" *)
    reg                 latch_wr;
    reg                 latch_wr_p0;
`else
    wire  [31:0]        latch_data;
    assign latch_data = data_in;
`endif

    // =============================================================
    // PRISM core
    // =============================================================
    prism
    #(
        .DEPTH         ( DEPTH               ),
        .INPUTS        ( PRISM_INPUTS        ),
        .OUTPUTS       ( OUTPUTS             ),
        .COND_OUT      ( PRISM_COND_OUT      ),
        .COND_LUT_SIZE ( PRISM_COND_LUT_SIZE ),
        .STATE_INPUTS  ( PRISM_STATE_INPUTS  ),
        .DUAL_COMPARE  ( PRISM_DUAL_COMPARE  ),
        .FRACTURABLE   ( PRISM_FRACTURABLE   ),
        .LUT_SIZE      ( PRISM_LUT_SIZE      ),
        .W_ADDR        ( 9                   )
     )
    i_prism
    (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .fsm_enable         ( prism_enable      ),
        .in_data            ( in_data_0         ),
        .in_data_1          ( in_data_1         ),
        .out_data           ( out_data_0        ),
        .cond_out           ( cond_out_0        ),
        .out_data_1         ( out_data_1        ),
        .cond_out_1         ( cond_out_1        ),
        .fractured_out      ( fractured         ),
`ifndef SYNTH_FPGA
        .latch_data         ( latch_data        ),
        .latch_wr           ( latch_wr          ),
`endif
        .debug_addr         ( address           ),
        .debug_wr           ( prism_wr          ),
        .debug_wdata        ( data_in           ),
        .debug_rdata        ( prism_read_data   ),
        .debug_halt_either  ( halt_either       ),
        .debug_halt_shard   ( halt              ),
        .in_prev_src        ( in_prev_num_v[0 +: 4*IN_NUM_BITS]           ),
        .in_prev_src_1      ( in_prev_num_v[4*IN_NUM_BITS +: 4*IN_NUM_BITS] ),
        .in_prev_cap        ( in_prev_cap_v[3:0]                          ),
        .in_prev_cap_1      ( in_prev_cap_v[7:4]                          ),
        .trace_si           ( trace_si_0        ),
        .trace_si_1         ( trace_si_1        ),
        .trace_mux          ( trace_mux_0       ),
        .trace_mux_1        ( trace_mux_1       ),
        .trace_match        ( trace_match_0     ),
        .trace_match_1      ( trace_match_1     ),
        .sit_addr_a         ( sit_addr_a        ),
        .sit_addr_b         ( sit_addr_b        ),
        .stew_a             ( stew_a            ),
        .stew_b             ( stew_b            )
    );

    assign prism_wr     = data_write_n != 2'b11;
    assign word_wr      = data_write_n == 2'b10;
    assign byte_wr      = data_write_n == 2'b00;
    assign prism_enable = enable_r;
    assign shard_win    = address[8];
    assign shard_sel    = address[7];
    assign shard_off    = address[6:0];

    // =============================================================
    // Per-shard datapath, configuration, host handshake, interrupt
    // =============================================================
    genvar s;
    generate
        for (s = 0; s < SHARDS; s = s + 1)
        begin : SH
            wire [OUTPUTS-1:0]        out_s  = (s == 0) ? out_data_0 : out_data_1;
            wire [PRISM_COND_OUT-1:0] cond_s = (s == 0) ? cond_out_0 : cond_out_1;
            wire                      win    = shard_win && (shard_sel == (s == 1));
            wire                      halt_s = halt[s];
            reg                       halt_r;
            wire                      exec;
            wire [31:0]               cfg0;
            wire [20:0]               pinmux;
            wire [31:0]               preload;
            wire                      cfg0_en, pinmux_en, preload_en;
            reg   [7:0]               compare;
            (* keep = "true" *)
            reg   [1:0]               host_in;
            reg                       irq;
            reg                       host_irq_r;
            (* keep = "true" *)
            reg   [1:0]               latched_in;
            reg                       sema;
            wire [31:0]               count1;
            wire  [7:0]               count2;
            wire  [7:0]               comm;
            wire  [4:0]               shift_count;
            wire  [2:0]               comm_count;
            wire                      count1_wrap, count1_term, count2_cmp, count2_eq_comm, shift_term, shift_data;
            wire  [6:0]               pin_in;
            wire  [1:0]               sync_sel = cfg0[CFG_IN_SYNC_SEL +: 2];
            wire [PRISM_INPUTS-1:0]   in_s;
            wire  [3:0]               pin_out = out_s[3:0];
            wire                      sema_clr = exec & out_s[OUT_SEMA_CLEAR] & fractured;
            wire [31:0]               cfg3;
            wire [31:0]               preload2;
            wire                      preload2_en;
            wire                      mrx_valid, mrx_value;      // Manchester bit recoverer
            wire                      shift_in_bit = cfg3[CFG3_SHIFT_MRX]    ? mrx_value :
                                                     cfg0[CFG_SHIFT_IN_COND] ? cond_s[0] : pin_in[{1'b0, cfg0[1:0]}];
            // FIFO / CRC
            wire [31:0]               cfg1;
            wire [31:0]               cfg2;
            wire [31:0]               consts;
            wire [31:0]               crc_poly;
            wire [31:0]               crc_exp;
            wire                      cfg1_en, cfg2_en, const_en, crc_poly_en, crc_exp_en, cfg3_en;
            reg                       flag2;
            // OUT_COMM_LOAD source: preload[7:0], or constant K[{out20, out18}]
            wire  [7:0]               k_sel = out_s[OUT_K_SEL1] ? (out_s[OUT_K_SEL0] ? consts[31:24] : consts[23:16])
                                                                : (out_s[OUT_K_SEL0] ? consts[15:8]  : consts[7:0]);
            wire  [7:0]               comm_load_data = cfg0[CFG_COMM_LOAD_K] ? k_sel : preload[7:0];
            wire                      comm_match = (comm == consts[31:24]);
            wire  [7:0]               crc_byte;
            // While the SRAM this window reads holds a finished trace, the
            // window's FIFO is that SRAM FIFO in RX mode: the host pops the
            // trace entries (the shard's own FIFO is frozen meanwhile; until
            // the capture is done it works as configured)
            wire                      fifo_traced;
            wire                      fifo_dir = cfg0[CFG_FIFO_DIR] & !fifo_traced;
            // Unfractured, shard 0's OUT_FIFO_WR_RD strobes FIFO A (own,
            // OUT_FIFO_PUSH_POP = 0) or FIFO B (shard 1's, = 1), each per
            // its own direction.
            wire                      fifo_dir_b = cfg0_v[32*(SHARDS-1) + CFG_FIFO_DIR];
            wire                      sel_b    = (s == 0) && !fractured && out_s[OUT_FIFO_PUSH_POP];
            wire                      fifo_op  = (exec & out_s[OUT_FIFO_WR_RD] & !sel_b) |
                                                 ((s == SHARDS-1) ? fifo_op_to_b : 1'b0);
            wire                      fifo_rd  = (data_read_n != 2'b11) && win && (shard_off[6:2] == SH_FIFO[6:2]);
            wire                      fifo_wr  = prism_wr && win && shard_off == SH_FIFO;
            wire                      fifo_flush = prism_wr && win && shard_off == SH_FIFO_ST;
            wire  [7:0]               fifo_head;
            wire [13:0]               fifo_count;
            wire                      fifo_empty, fifo_full, fifo_ae, fifo_af;
            // This shard's FIFO storage: the flop FIFO, or the SRAM FIFO (CFG0[31])
            localparam                SI = (SRAM_FIFO == 1) ? 0 : s;     // the SRAM FIFO serving this shard
            wire                      fifo_sram = (SRAM_FIFO != 0) && (cfg0[CFG_FIFO_SRAM] || fifo_traced) &&
                                                  (SRAM_FIFO != 1 || s == 0 || !cfg0_v[CFG_FIFO_SRAM]);
            assign fifo_traced = (SRAM_FIFO != 0) && trc_held_v[SI];
            wire  [7:0]               lf_head;
            wire  [FIFO_AW:0]         lf_count;
            wire                      lf_empty, lf_full, lf_ae, lf_af;
            wire [31:0]               crc_value, crc_out;
            wire                      crc_ok;
            // in_prev edge-capture flops: CFG1[4i+3:4i] = source input number
            reg   [3:0]               in_prev;
            wire  [3:0]               in_prev_src_val;
            wire  [3:0]               in_prev_cap = in_prev_cap_v[4*s +: 4];
            genvar ip;
            for (ip = 0; ip < 4; ip = ip + 1)
            begin : IN_PREV_SRC
                wire [3:0] sel = cfg1[4*ip +: 4];
                assign in_prev_src_val[ip] = sel < 4'd7  ? pin_in[sel[2:0]] :
                                             sel == 4'd8 ? host_in[0]       :
                                             sel == 4'd9 ? host_in[1]       : 1'b0;
                assign in_prev_num_v[IN_NUM_BITS*(4*s+ip) +: IN_NUM_BITS] = {1'b0, sel};
            end
            wire                      pop_dir  = sel_b ? fifo_dir_b : fifo_dir;          // direction of the FIFO bit 5 strobes
            wire  [7:0]               pop_head = sel_b ? fifo_head_v[8*(SHARDS-1) +: 8] : fifo_head;
            wire  [7:0]               push_src = (s == SHARDS-1 && !fractured) ? comm_v[7:0] : comm;
            // FIFO requests: RX (fifo_dir = 0) FSM pushes comm / host pops by reading,
            //                TX (fifo_dir = 1) host pushes by writing / FSM pops into comm
            wire                      f_push  = fifo_dir ? fifo_wr : fifo_op;
            wire  [7:0]               f_pdata = fifo_dir ? data_in[7:0] : push_src;
            wire                      f_pop   = fifo_dir ? fifo_op : fifo_rd;

            // halt_s covers the debugger halt and the cycle a conditional
            // breakpoint fires, so that cycle's outputs never reach the datapath
            assign exec = prism_enable && !halt_s;

            // Input pins: 2-flop (default), 1-flop or raw, per shard (item 13)
            assign pin_in = sync_sel == 2'd0 ? ui_in[6:0]     :
                            sync_sel == 2'd1 ? ui_in_1ff[6:0] :
                                               ui_in_raw[6:0];

            prism_datapath i_dp
            (
                .clk              ( clk                                ),
                .rst_n            ( rst_n                              ),
                .enable           ( prism_enable                       ),
                .exec             ( exec                               ),
                .o_count1_step    ( out_s[OUT_COUNT1_INC_DEC]          ),
                .o_count1_clrload ( out_s[OUT_COUNT1_CLEAR_LOAD]       ),
                .o_shift          ( out_s[OUT_SHIFT]                   ),
                .o_count2_inc     ( out_s[OUT_COUNT2_INC]              ),
                .o_count2_dec     ( out_s[OUT_COUNT2_DEC]              ),
                .o_count2_clear   ( out_s[OUT_COUNT2_CLEAR]            ),
                .o_comm_load      ( out_s[OUT_COMM_LOAD]               ),
                .o_fifo_pop       ( out_s[OUT_FIFO_WR_RD] & pop_dir    ),
                .fifo_data        ( pop_head                           ),
                .o_load_crc       ( out_s[OUT_LOAD_CRC]                ),
                .crc_data         ( crc_out                            ),
                .crc_byte         ( crc_byte                           ),
                .comm_load_data   ( comm_load_data                     ),
                .shift_in         ( shift_in_bit                       ),
                .cfg              ( cfg0                               ),
                .preload          ( preload                            ),
                .compare          ( compare                            ),
                .wr_count1        ( prism_wr && win && shard_off == SH_COUNT1 ),
                .wr_count1_data   ( data_in                            ),
                .wr_count2        ( (word_wr || byte_wr) && win && shard_off == SH_COUNTS ),
                .wr_count2_data   ( data_in[7:0]                       ),
                .wr_comm          ( win && ((word_wr && shard_off == SH_COUNTS) ||
                                            (byte_wr && shard_off == SH_COUNTS + 7'd2)) ),
                .wr_comm_data     ( word_wr ? data_in[23:16] : data_in[7:0] ),
                .count1           ( count1                             ),
                .count2           ( count2                             ),
                .comm             ( comm                               ),
                .shift_count      ( shift_count                        ),
                .comm_count       ( comm_count                         ),
                .count1_wrap      ( count1_wrap                        ),
                .count1_term      ( count1_term                        ),
                .count2_cmp       ( count2_cmp                         ),
                .count2_eq_comm   ( count2_eq_comm                     ),
                .shift_term       ( shift_term                         ),
                .shift_data       ( shift_data                         )
            );

            // The flop FIFO (idle while the SRAM FIFO is this shard's storage)
            prism_fifo #( .DEPTH ( FIFO_DEPTH ), .AW ( FIFO_AW ) ) i_fifo
            (
                .clk          ( clk                              ),
                .rst_n        ( rst_n                            ),
                .flush        ( fifo_flush & !fifo_sram          ),
                .push         ( f_push & !fifo_sram              ),
                .push_data    ( f_pdata                          ),
                .pop          ( f_pop & !fifo_sram               ),
                .ae_level     ( cfg1[16 +: FIFO_AW]              ),
                .af_level     ( cfg1[20 +: FIFO_AW]              ),
                .head         ( lf_head                          ),
                .count        ( lf_count                         ),
                .empty        ( lf_empty                         ),
                .full         ( lf_full                          ),
                .almost_empty ( lf_ae                            ),
                .almost_full  ( lf_af                            )
            );
            assign fifo_head  = fifo_sram ? sram_head_v[8*SI +: 8]    : lf_head;
            assign fifo_count = fifo_sram ? sram_count_v[14*SI +: 14] : {{(13-FIFO_AW){1'b0}}, lf_count};
            assign fifo_empty = fifo_sram ? sram_empty_v[SI] : lf_empty;
            assign fifo_full  = fifo_sram ? sram_full_v[SI]  : lf_full;
            // SRAM FIFO almost-empty / almost-full (levels in 64-byte units),
            // compared here so only the count crosses from the SRAM side
            assign fifo_ae    = fifo_sram ? (sram_count_v[14*SI +: 14] <= {4'h0, cfg1[16 +: 4], 6'b0}) : lf_ae;
            assign fifo_af    = fifo_sram ? (sram_count_v[14*SI +: 14] >= (SRAM_BYTES - {4'h0, cfg1[20 +: 4], 6'b0})) : lf_af;
            assign sram_sel_v[s]          = fifo_sram;
            assign sram_push_v[s]         = f_push;
            assign sram_pdata_v[8*s +: 8] = f_pdata;
            assign sram_pop_v[s]          = f_pop;
            assign sram_flush_v[s]        = fifo_flush;

            // CRC over the bit the shifter is receiving (crc_src = 0) or
            // transmitting (crc_src = 1) in the cycle OUT_CRC_UPDATE is set
            prism_crc i_crc
            (
                .clk          ( clk                              ),
                .rst_n        ( rst_n                            ),
                .enable       ( prism_enable                     ),
                .clear        ( exec & out_s[OUT_CRC_CLEAR]      ),
                .update       ( exec & out_s[OUT_CRC_UPDATE]     ),
                .consume      ( exec & out_s[OUT_LOAD_CRC] & !cfg0[CFG_SHIFT_WIDE] ),
                .bit_in       ( cfg0[CFG_CRC_SRC] ? shift_data : shift_in_bit ),
                .mode         ( cfg0[CFG_CRC_MODE +: 2]          ),
                .reflect      ( cfg0[CFG_CRC_REFLECT]            ),
                .init_ones    ( cfg0[CFG_CRC_INIT_ONES]          ),
                .xor_out      ( cfg0[CFG_CRC_XOR_OUT]            ),
                .poly         ( crc_poly                         ),
                .expected     ( crc_exp                          ),
                .wr           ( prism_wr && win && shard_off == SH_CRC ),
                .wr_data      ( data_in                          ),
                .value        ( crc_value                        ),
                .out_value    ( crc_out                          ),
                .out_byte     ( crc_byte                         ),
                .ok           ( crc_ok                           )
            );

            // PRISM inputs for this shard
            assign in_s[6:0]   = pin_in;
            assign in_s[7]     = shift_data;
            assign in_s[9:8]   = host_in;
            assign in_s[10]    = count1_term;
            assign in_s[11]    = count2_cmp;
            assign in_s[13:12] = cfg0[CFG_LATCH_IN_OUT] ? {latched_out[6], latched_out[1]} : latched_in;
            assign in_s[14]    = shift_term;
            assign in_s[15]    = count2_eq_comm;
            // Free-running timer (PRELOAD2): reloads itself and ticks for one
            // clock every PRELOAD2 + 1 clocks; the default value of input 28.
            // Nothing in the FSM needs to start it, which is the point: it
            // paces things like Ethernet link pulses while count1 is busy.
            reg  [23:0]               timer2;
            reg                       timer2_tick;
            always @(posedge clk or negedge rst_n)
            begin
                if (!rst_n)
                begin
                    timer2      <= 24'h0;
                    timer2_tick <= 1'b0;
                end
                else
                begin
                    timer2_tick <= 1'b0;
                    if (preload2[23:0] == 24'h0)
                        timer2 <= 24'h0;
                    else if (timer2 == 24'h0)
                    begin
                        timer2      <= preload2[23:0];
                        timer2_tick <= 1'b1;
                    end
                    else
                        timer2 <= timer2 - 24'd1;
                end
            end

            genvar sl;
            for (sl = 0; sl < 4; sl = sl + 1)
            begin : SLOTS
                assign in_s[16+sl] = slot_val(cfg2[4*sl +: 4],    in_prev[sl], in_prev, comm, comm_match, flag2, mrx_valid);
                assign in_s[28+sl] = slot_val(cfg2[16+4*sl +: 4], (sl == 0) ? timer2_tick : 1'b0,
                                              in_prev, comm, comm_match, flag2, mrx_valid);
            end

            // Manchester bit recoverer: its bit valid is slot code 15, its bit
            // the shifter input with CFG3[8]; consumed by the FSM's shift
            prism_mrx i_mrx
            (
                .clk     ( clk                    ),
                .rst_n   ( rst_n                  ),
                .enable  ( cfg3[CFG3_MRX_EN]      ),
                .line    ( in_s[cfg3[2:0]]        ),
                .hb      ( cfg3[7:4]              ),
                .consume ( out_s[OUT_SHIFT]       ),
                .valid   ( mrx_valid              ),
                .value   ( mrx_value              )
            );
            assign in_s[20]    = fifo_flag(1'b0, cfg1[25:24], fifo_empty, fifo_full, fifo_ae, fifo_af);
            assign in_s[21]    = fifo_flag(1'b1, cfg1[27:26], fifo_empty, fifo_full, fifo_ae, fifo_af);
            assign in_s[22]    = crc_ok;
            assign in_s[23]    = count1_wrap;
            assign in_s[24]    = sema;
            assign in_s[25]    = halt_r_v[1-s];     // other shard halted (registered: the live
                                                    // halt includes the conditional break, which
                                                    // depends on this shard's inputs)
            // FIFO B's flags for shard 0 while it owns both FIFOs, same two-slot select
            wire [3:0]                fifo_b_fl = fifo_st_v[32*(SHARDS-1) +: 4];   // {af, ae, full, empty}
            wire                      own_b     = (s == 0) && !fractured;
            assign in_s[26]    = own_b & fifo_flag(1'b0, cfg1[29:28], fifo_b_fl[0], fifo_b_fl[1], fifo_b_fl[2], fifo_b_fl[3]);
            assign in_s[27]    = own_b & fifo_flag(1'b1, cfg1[31:30], fifo_b_fl[0], fifo_b_fl[1], fifo_b_fl[2], fifo_b_fl[3]);

            // Output pins: uo_out[k+1] source select PINMUX[3k+2:3k]
            //   0-3 pin_out[3:0], 4 cond_out[0], 5 cond_out[1], 6 shift_data,
            //   7 = this shard does not drive the pin
            genvar k;
            for (k = 0; k < 7; k = k + 1)
            begin : GEN_PINMUX
                wire [2:0] sel = pinmux[3*k+2 : 3*k];
                assign pin_src_v[7*s+k]   = sel == 3'd0 ? pin_out[0] :
                                            sel == 3'd1 ? pin_out[1] :
                                            sel == 3'd2 ? pin_out[2] :
                                            sel == 3'd3 ? pin_out[3] :
                                            sel == 3'd4 ? cond_s[0]  :
                                            sel == 3'd5 ? cond_s[1]  :
                                            sel == 3'd6 ? shift_data : 1'b0;
                assign pin_claim_v[7*s+k] = sel != 3'd7;
            end

            // Semaphore from the other shard: set by its OUT_SEMA_SET, cleared
            // by our OUT_SEMA_CLEAR; same-cycle priority from our CFG0.
            assign sema_set_req[s] = exec & out_s[OUT_SEMA_SET];

            always @(posedge clk or negedge rst_n)
            begin
                if (!rst_n)
                begin
                    halt_r      <= 1'b0;
                    host_irq_r  <= 1'b0;
                    irq         <= 1'b0;
                    host_in     <= 2'b0;
                    compare     <= 8'h0;
                    sema        <= 1'b0;
                    latched_in  <= 2'h0;
                    in_prev     <= 4'h0;
                    flag2       <= 1'b0;
                end
                else
                begin
                    halt_r     <= halt_s;
                    host_irq_r <= exec & out_s[OUT_HOST_INTERRUPT];

                    // Interrupt: debugger halt, or OUT_HOST_INTERRUPT asserted
                    // (once per assertion).  Cleared by a byte write to the
                    // shard's INT_CLR byte with bit 7 set, by the host_in
                    // toggle write, or by disabling the PRISM.
                    if ((halt_s && !halt_r) ||
                        (exec && out_s[OUT_HOST_INTERRUPT] && !host_irq_r))
                        irq <= 1'b1;
                    else if (!prism_enable ||
                             (byte_wr && address == (s == 0 ? REG_INT_CLR0 : REG_INT_CLR1) && data_in[7]) ||
                             (byte_wr && win && shard_off == SH_TOGGLE))
                        irq <= 1'b0;

                    // host_in
                    if (prism_wr && win && shard_off == SH_HOST)
                        host_in <= data_in[1:0];
                    else if (byte_wr && win && shard_off == SH_TOGGLE)
                        host_in[0] <= ~host_in[0];

                    // count2 compare register
                    if (word_wr && win && shard_off == SH_COUNTS)
                        compare <= data_in[15:8];
                    else if (byte_wr && win && shard_off == SH_COUNTS + 7'd1)
                        compare <= data_in[7:0];

                    // Semaphore
                    if (!prism_enable)
                        sema <= 1'b0;
                    else if (sema_set_req[1-s] && sema_clr)
                        sema <= cfg0[CFG_SEMA_SET_WINS];
                    else if (sema_set_req[1-s])
                        sema <= 1'b1;
                    else if (sema_clr)
                        sema <= 1'b0;

                    // Latched inputs, or FSM flags: with CFG_FLAG_LATCH the
                    // conditional outputs (per-state constants) are the values
                    // OUT_LATCH stores, and output 19 goes into flag2
                    if (!prism_enable)
                    begin
                        latched_in <= 2'h0;
                        flag2      <= 1'b0;
                    end
                    else if (exec && cfg0[CFG_LATCH_EN] && out_s[OUT_LATCH])
                    begin
                        latched_in <= cfg0[CFG_FLAG_LATCH] ? cond_s : {shift_data, cond_s[0]};
                        flag2      <= out_s[OUT_FLAG2];
                    end

                    // in_prev: capture the selected source on the core's strobe
                    if (!prism_enable)
                        in_prev <= 4'h0;
                    else
                        in_prev <= (in_prev & ~in_prev_cap) | (in_prev_src_val & in_prev_cap);
                end
            end

            // ---- Trace (section 4m): from the trigger on, every clock's
            // {executing, tree 1 taken, tree 0 matched, the six selected LUT
            // inputs, SI} goes to the SRAM trace port (next to the SRAM,
            // prism_trace_port.v) until the buffer is full; the SRAM FIFO
            // wrapper then serves the entries to the host as bytes.  One shard
            // at a time: the entry and strobes are picked and registered above.
            wire [TRC_CFG_W-1:0]      trace_cfg;
            wire                      trace_cfg_en;
            wire                      trc_act   = trc_active_v[s];       // owns an SRAM
            wire                      big_act   = trc_big_act_v[s];      // owns both
            wire [SI_W-1:0]           si_s      = (s == 0) ? trace_si_0    : trace_si_1;
            wire [PRISM_STATE_INPUTS-1:0] mux_s = (s == 0) ? trace_mux_0   : trace_mux_1;
            wire [1:0]                match_s   = (s == 0) ? trace_match_0 : trace_match_1;
            wire [1:0]                trc_trig  = trace_cfg[TRC_TRIG +: 2];
            wire [1:0]                trc_edge  = trace_cfg[TRC_EDGE +: 2];
            wire                      trc_in_now = in_s[trace_cfg[TRC_IN +: 5]];
            wire                      trc_full_in = big_act ? trc_full_v[(NSRAM > 1) ? NSRAM-1 : 0] : trc_full_v[SI];
            reg                       trc_in_prev;
            reg                       trc_armed, trc_running, trc_done;
            wire                      trc_edge_hit = trc_edge[1] ? (trc_in_now ^ trc_in_prev) :
                                                     trc_edge[0] ? (!trc_in_now & trc_in_prev) :
                                                                   (trc_in_now & !trc_in_prev);
            wire                      trc_si_hit = (si_s == trace_cfg[TRC_SI +: SI_W]);
            wire                      trc_trigger = trc_armed &
                                                    ((trc_trig == 2'd0) |
                                                     (trc_trig == 2'd1 && trc_si_hit) |
                                                     (trc_trig == 2'd2 && trc_si_hit && exec && (|match_s)) |
                                                     (trc_trig == 2'd3 && trc_edge_hit));
            wire                      trc_capture = trc_act & (trc_running | trc_trigger) & !trc_full_in;
            wire                      trc_ctrl_wr = prism_wr && win && shard_off == SH_TRACE_CTRL;
            wire                      trc_arm     = trc_act & trc_ctrl_wr & data_in[0];
            wire                      trc_stop    = trc_act & trc_ctrl_wr & data_in[1] & !data_in[0];
            assign trc_en_v[s]              = trace_cfg[TRC_EN];
            assign trc_big_v[s]             = trace_cfg[TRC_BIG];
            assign trc_cap_v[s]             = trc_capture;
            assign trc_stop_v[s]            = trc_stop;
            assign trc_arm_v[s]             = trc_arm;
            assign trc_din_v[16*s +: 16]    = {2'b00, exec, match_s, mux_s, si_s};
            assign trace_st_v [32*s +: 32]  = {27'h0, trc_act, big_act, trc_done, trc_running, trc_armed};

            always @(posedge clk or negedge rst_n)
            begin
                if (!rst_n)
                begin
                    trc_in_prev <= 1'b0;
                    trc_armed   <= 1'b0;
                    trc_running <= 1'b0;
                    trc_done    <= 1'b0;
                end
                else
                begin
                    trc_in_prev <= trc_in_now;

                    if (!trc_act)
                    begin
                        trc_armed   <= 1'b0;
                        trc_running <= 1'b0;
                    end
                    else if (trc_arm)
                    begin
                        trc_armed   <= 1'b1;
                        trc_running <= 1'b0;
                        trc_done    <= 1'b0;
                    end
                    else if (trc_stop || (trc_running && trc_full_in))   // (full_in lingers 2 clocks after an arm)
                    begin
                        trc_armed   <= 1'b0;
                        trc_running <= 1'b0;
                        trc_done    <= 1'b1;
                    end
                    else if (trc_capture)
                    begin
                        trc_armed   <= 1'b0;
                        trc_running <= 1'b1;
                    end
                end
            end

            // Configuration registers: latches (area) or flops (FPGA)
            assign trace_cfg_en = win && shard_off == SH_TRACE_CFG;
            assign cfg0_en    = win && shard_off == SH_CFG0;
            assign pinmux_en  = win && shard_off == SH_PINMUX;
            assign preload_en = win && shard_off == SH_PRELOAD;
            assign cfg1_en     = win && shard_off == SH_CFG1;
            assign cfg2_en     = win && shard_off == SH_CFG2;
            assign const_en    = win && shard_off == SH_CONST;
            assign cfg3_en     = win && shard_off == SH_CFG3;
            assign preload2_en = win && shard_off == SH_PRELOAD2;
            assign crc_poly_en = win && shard_off == SH_CRC_POLY;
            assign crc_exp_en  = win && shard_off == SH_CRC_EXP;

`ifndef SYNTH_FPGA
            prism_latch_reg #( .WIDTH ( 32 ) ) cfg1_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( cfg1_en       ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( cfg1          )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) crc_poly_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( crc_poly_en   ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( crc_poly      )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) crc_exp_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( crc_exp_en    ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( crc_exp       )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) cfg2_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( cfg2_en       ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( cfg2          )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) const_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( const_en      ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( consts        )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) cfg3_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( cfg3_en       ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( cfg3          )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) preload2_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( preload2_en   ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( preload2      )
            );
            prism_latch_reg #( .WIDTH ( TRC_CFG_W ) ) trace_cfg_reg
            (
                .rst_n      ( rst_n                    ),
                .enable     ( trace_cfg_en             ),
                .wr         ( latch_wr                 ),
                .data_in    ( latch_data[TRC_CFG_W-1:0] ),
                .data_out   ( trace_cfg                )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) cfg0_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( cfg0_en       ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( cfg0          )
            );
            prism_latch_reg #( .WIDTH ( 21 ) ) pinmux_reg
            (
                .rst_n      ( rst_n             ),
                .enable     ( pinmux_en         ),
                .wr         ( latch_wr          ),
                .data_in    ( latch_data[20:0]  ),
                .data_out   ( pinmux            )
            );
            prism_latch_reg #( .WIDTH ( 32 ) ) preload_reg
            (
                .rst_n      ( rst_n         ),
                .enable     ( preload_en    ),
                .wr         ( latch_wr      ),
                .data_in    ( latch_data    ),
                .data_out   ( preload       )
            );
`else
            reg [31:0] cfg0_r;
            reg [20:0] pinmux_r;
            reg [31:0] preload_r;
            reg [31:0] cfg1_r, crc_poly_r, crc_exp_r, cfg2_r, const_r, cfg3_r, preload2_r;
            reg [TRC_CFG_W-1:0] trace_cfg_r;
            always @(posedge clk or negedge rst_n)
            begin
                if (~rst_n)
                begin
                    cfg0_r     <= 32'h0;
                    pinmux_r   <= 21'h0;
                    preload_r  <= 32'h0;
                    cfg1_r     <= 32'h0;
                    crc_poly_r <= 32'h0;
                    crc_exp_r  <= 32'h0;
                    cfg2_r     <= 32'h0;
                    const_r    <= 32'h0;
                    cfg3_r     <= 32'h0;
                    preload2_r <= 32'h0;
                    trace_cfg_r <= 0;
                end
                else
                begin
                    if (cfg0_en & prism_wr)     cfg0_r     <= data_in;
                    if (pinmux_en & prism_wr)   pinmux_r   <= data_in[20:0];
                    if (preload_en & prism_wr)  preload_r  <= data_in;
                    if (cfg1_en & prism_wr)     cfg1_r     <= data_in;
                    if (crc_poly_en & prism_wr) crc_poly_r <= data_in;
                    if (crc_exp_en & prism_wr)  crc_exp_r  <= data_in;
                    if (cfg2_en & prism_wr)     cfg2_r     <= data_in;
                    if (const_en & prism_wr)    const_r    <= data_in;
                    if (cfg3_en & prism_wr)     cfg3_r     <= data_in;
                    if (preload2_en & prism_wr) preload2_r <= data_in;
                    if (trace_cfg_en & prism_wr) trace_cfg_r <= data_in[TRC_CFG_W-1:0];
                end
            end
            assign cfg0     = cfg0_r;
            assign pinmux   = pinmux_r;
            assign preload  = preload_r;
            assign cfg1     = cfg1_r;
            assign crc_poly = crc_poly_r;
            assign crc_exp  = crc_exp_r;
            assign cfg2     = cfg2_r;
            assign consts   = const_r;
            assign cfg3     = cfg3_r;
            assign preload2 = preload2_r;
            assign trace_cfg = trace_cfg_r;
`endif

            // Export for the read mux and cross-shard use
            assign cfg0_v   [32*s +: 32] = cfg0;
            assign pinmux_v [21*s +: 21] = pinmux;
            assign preload_v[32*s +: 32] = preload;
            assign count1_v [32*s +: 32] = count1;
            assign counts_v [32*s +: 32] = {comm_count, shift_count, comm, compare, count2};
            assign flags_v  [32*s +: 32] = {21'h0, crc_ok, fifo_full, fifo_empty,
                                            latched_in, shift_data, shift_term, count2_eq_comm,
                                            count2_cmp, count1_wrap, count1_term};
            assign cfg1_v    [32*s +: 32] = cfg1;
            assign cfg2_v    [32*s +: 32] = cfg2;
            assign cfg3_v    [32*s +: 32] = cfg3;
            assign preload2_v[32*s +: 32] = preload2;
            assign const_v   [32*s +: 32] = consts;
            assign fifo_st_v [32*s +: 32] = {10'h0, fifo_count, 4'h0, fifo_af, fifo_ae, fifo_full, fifo_empty};
            assign fifo_head_v[8*s +: 8]  = fifo_head;
            assign comm_v     [8*s +: 8]  = comm;
            if (s == 0)
            begin : XOP
                assign fifo_op_to_b = exec & out_s[OUT_FIFO_WR_RD] & sel_b;
            end
            assign crc_poly_v[32*s +: 32] = crc_poly;
            assign crc_v     [32*s +: 32] = crc_value;
            assign crc_exp_v [32*s +: 32] = crc_exp;
            assign host_in_v[2*s +: 2]   = host_in;
            assign irq_v[s]              = irq;
            assign sema_v[s]             = sema;
            assign halt_r_v[s]           = halt_r;

            if (s == 0)
            begin : IN0
                assign in_data_0 = in_s;
            end
            else
            begin : IN1
                assign in_data_1 = in_s;
            end
        end
    endgenerate

    assign user_interrupt = irq_v;

    // =============================================================
    // Output pins: shard 0 wins a pin it claims, otherwise shard 1
    // (whose default PINMUX claims everything with pin_out[0], which is
    // 0 while unfractured).  A pin freezes while its owning shard is halted.
    // =============================================================
    genvar p;
    generate
        for (p = 0; p < 7; p = p + 1)
        begin : GEN_PINS
            wire owner1 = !pin_claim_v[p];
            assign uo_out_c[p] = owner1 ? pin_src_v[7+p] : pin_src_v[p];
            always @(posedge clk or negedge rst_n)
            begin
                if (!rst_n)
                    latched_out[p] <= 1'b0;
                else if (!prism_enable)
                    latched_out[p] <= 1'b0;
                else if (!(owner1 ? halt[1] : halt[0]))
                    latched_out[p] <= uo_out_c[p];
            end
        end
    endgenerate
    assign uo_out[7:1] = latched_out;
    assign uo_out[0]   = 1'b0;

    // =============================================================
    // Register reads.  Registers are decoded on the word address; a byte
    // or half-word read returns the addressed lane in data_out[7:0]
    // (TinyQV takes the low bits), so e.g. COUNTS + 1 reads compare.
    // =============================================================
    reg [31:0] reg_word;
    // ---- SRAM FIFOs (see the localparams above) and the trace's use of the SRAMs
    wire       sram_own1   = sram_sel_v[SHARDS-1] & ~sram_sel_v[0];     // shared: shard 1 owns it
    wire       sram_any    = |sram_sel_v;
    genvar n;
    generate
        for (n = 0; n < NSRAM; n = n + 1)
        begin : SRAM
            // the requesting shard: the owner when shared, shard n otherwise
            wire               si_1   = SRAM_SHARED ? sram_own1 : (n != 0);
            wire               req_on = SRAM_SHARED ? sram_any  : sram_sel_v[n];
            // Trace ownership of this SRAM (the FIFO is held flushed meanwhile):
            // shard 0 when it traces into SRAM 0 or into both, shard 1 when it
            // traces into SRAM 1 (SRAM 0 if that is the only one) or into both
            wire               own0   = trc_active_v[0] & (trc_big_act_v[0] | (n == 0));
            wire               own1   = trc_active_v[SHARDS-1] &
                                        (trc_big_act_v[SHARDS-1] | (n == (SRAM_SHARED ? 0 : SHARDS-1)));
            wire               trace_own = own0 | own1;
            wire               big_own   = trc_big_act_v[0] | trc_big_act_v[SHARDS-1];
            // the trace port: packs the owner's entries into this SRAM and
            // hands them to the FIFO wrapper when the capture ends
            wire               port_wen, port_full, port_held, port_load;
            wire [SRAM_AW-1:0] port_addr;
            wire        [31:0] port_din;
            wire [SRAM_AW+2:0] port_bytes;
            prism_trace_port #( .AW ( SRAM_AW ) ) i_trace
            (
                .clk        ( clk                    ),
                .rst_n      ( rst_n                  ),
                .own        ( trace_own              ),
                .big        ( big_own                ),
                .upper      ( n != 0                 ),
                .lower_full ( trc_full_v[0]          ),
                .arm        ( trc_bus_arm            ),
                .cap        ( trc_bus_cap            ),
                .stop       ( trc_bus_stop           ),
                .entry      ( trc_bus_din            ),
                .full       ( port_full              ),
                .held       ( port_held              ),
                .load       ( port_load              ),
                .load_bytes ( port_bytes             ),
                .wen        ( port_wen               ),
                .addr       ( port_addr              ),
                .din        ( port_din               )
            );
            wire               push   = req_on & sram_push_v[si_1] & !trace_own;   // a traced SRAM takes no pushes
            wire               pop    = req_on & sram_pop_v[si_1];
            wire               flush  = (req_on & sram_flush_v[si_1]) | (trace_own & trc_bus_arm);
            wire         [7:0] pdata  = sram_pdata_v[8*si_1 +: 8];
            wire [SRAM_AW-1:0] f_addr;
            wire [SRAM_AW+2:0] sram_cnt;
            wire        [31:0] f_din, f_bm, sram_dout;
            wire               f_wen, f_ren;
            // the macro port: the trace port's write in the clocks it has one, else the FIFO's
            wire [SRAM_AW-1:0] sram_addr = port_wen ? port_addr  : f_addr;
            wire        [31:0] sram_din  = port_wen ? port_din   : f_din;
            wire        [31:0] sram_bm   = port_wen ? {32{1'b1}} : f_bm;
            wire               sram_wen  = port_wen | f_wen;
            wire               sram_ren  = !port_wen & f_ren;
            assign sram_count_v[14*n +: 14] = sram_cnt;          // zero-extended
            assign trc_full_v[n]            = port_full;
            assign trc_held_v[n]            = trace_own & port_held;
            prism_sram_fifo #( .AW ( SRAM_AW ) ) i_sram_fifo
            (
                .clk          ( clk                    ),
                .rst_n        ( rst_n                  ),
                .flush        ( flush                  ),
                .load         ( port_load              ),
                .load_bytes   ( port_bytes             ),
                .push         ( push                   ),
                .push_data    ( pdata                  ),
                .pop          ( pop                    ),
                .head         ( sram_head_v[8*n +: 8]  ),
                .count        ( sram_cnt               ),
                .empty        ( sram_empty_v[n]        ),
                .full         ( sram_full_v[n]         ),
                .sram_addr    ( f_addr                 ),
                .sram_din     ( f_din                  ),
                .sram_bm      ( f_bm                   ),
                .sram_wen     ( f_wen                  ),
                .sram_ren     ( f_ren                  ),
                .sram_dout    ( sram_dout              )
            );
            // IHP single-port SRAM: A_DLY must be tied high, BIST off.  Separate
            // `if`s (no else-if chain) so the instance path stays SRAM[n].M512.i_sram
            if (SRAM_AW == 11)
            begin : M2048
                RM_IHPSG13_1P_2048x32_c2_bm_bist i_sram
                (
                    .A_CLK       ( clk                  ),
                    .A_MEN       ( sram_ren | sram_wen  ),
                    .A_WEN       ( sram_wen             ),
                    .A_REN       ( sram_ren             ),
                    .A_ADDR      ( sram_addr            ),
                    .A_DIN       ( sram_din             ),
                    .A_DLY       ( 1'b1                 ),
                    .A_DOUT      ( sram_dout            ),
                    .A_BM        ( sram_bm              ),
                    .A_BIST_CLK  ( 1'b0                 ),
                    .A_BIST_EN   ( 1'b0                 ),
                    .A_BIST_MEN  ( 1'b0                 ),
                    .A_BIST_WEN  ( 1'b0                 ),
                    .A_BIST_REN  ( 1'b0                 ),
                    .A_BIST_ADDR ( 11'h0                ),
                    .A_BIST_DIN  ( 32'h0                ),
                    .A_BIST_BM   ( 32'h0                )
                );
            end
            if (SRAM_AW == 10)
            begin : M1024
                RM_IHPSG13_1P_1024x32_c2_bm_bist i_sram
                (
                    .A_CLK       ( clk                  ),
                    .A_MEN       ( sram_ren | sram_wen  ),
                    .A_WEN       ( sram_wen             ),
                    .A_REN       ( sram_ren             ),
                    .A_ADDR      ( sram_addr            ),
                    .A_DIN       ( sram_din             ),
                    .A_DLY       ( 1'b1                 ),
                    .A_DOUT      ( sram_dout            ),
                    .A_BM        ( sram_bm              ),
                    .A_BIST_CLK  ( 1'b0                 ),
                    .A_BIST_EN   ( 1'b0                 ),
                    .A_BIST_MEN  ( 1'b0                 ),
                    .A_BIST_WEN  ( 1'b0                 ),
                    .A_BIST_REN  ( 1'b0                 ),
                    .A_BIST_ADDR ( 10'h0                ),
                    .A_BIST_DIN  ( 32'h0                ),
                    .A_BIST_BM   ( 32'h0                )
                );
            end
            if (SRAM_AW == 9)
            begin : M512
                RM_IHPSG13_1P_512x32_c2_bm_bist i_sram
                (
                    .A_CLK       ( clk                  ),
                    .A_MEN       ( sram_ren | sram_wen  ),
                    .A_WEN       ( sram_wen             ),
                    .A_REN       ( sram_ren             ),
                    .A_ADDR      ( sram_addr            ),
                    .A_DIN       ( sram_din             ),
                    .A_DLY       ( 1'b1                 ),
                    .A_DOUT      ( sram_dout            ),
                    .A_BM        ( sram_bm              ),
                    .A_BIST_CLK  ( 1'b0                 ),
                    .A_BIST_EN   ( 1'b0                 ),
                    .A_BIST_MEN  ( 1'b0                 ),
                    .A_BIST_WEN  ( 1'b0                 ),
                    .A_BIST_REN  ( 1'b0                 ),
                    .A_BIST_ADDR ( 9'h0                 ),
                    .A_BIST_DIN  ( 32'h0                ),
                    .A_BIST_BM   ( 32'h0                )
                );
            end
        end
        for (n = NSRAM; n < SHARDS; n = n + 1)
        begin : NO_SRAM
            assign sram_head_v[8*n +: 8]    = 8'h0;
            assign sram_count_v[14*n +: 14] = 14'h0;
            assign sram_empty_v[n]          = 1'b1;
            assign sram_full_v[n]           = 1'b1;
            assign trc_held_v[n]            = 1'b0;
            assign trc_full_v[n]            = 1'b0;
        end
    endgenerate

    always @*
    begin
        if (shard_win)
        begin
            case ({shard_off[6:2], 2'b00})
                SH_CFG0:    reg_word = cfg0_v   [32*shard_sel +: 32];
                SH_PINMUX:  reg_word = {11'h0, pinmux_v[21*shard_sel +: 21]};
                SH_PRELOAD: reg_word = preload_v[32*shard_sel +: 32];
                SH_COUNT1:  reg_word = count1_v [32*shard_sel +: 32];
                SH_COUNTS:  reg_word = counts_v [32*shard_sel +: 32];
                SH_HOST:    reg_word = {30'h0, host_in_v[2*shard_sel +: 2]};
                SH_FLAGS:   reg_word = flags_v  [32*shard_sel +: 32];
                SH_CFG1:    reg_word = cfg1_v   [32*shard_sel +: 32];
                SH_FIFO:    reg_word = {24'h0, fifo_head_v[8*shard_sel +: 8]};
                SH_FIFO_ST: reg_word = fifo_st_v[32*shard_sel +: 32];
                SH_CRC_POLY:reg_word = crc_poly_v[32*shard_sel +: 32];
                SH_CRC:     reg_word = crc_v    [32*shard_sel +: 32];
                SH_CRC_EXP: reg_word = crc_exp_v[32*shard_sel +: 32];
                SH_CFG2:    reg_word = cfg2_v   [32*shard_sel +: 32];
                SH_CFG3:    reg_word = cfg3_v   [32*shard_sel +: 32];
                SH_PRELOAD2: reg_word = preload2_v[32*shard_sel +: 32];
                SH_CONST:   reg_word = const_v  [32*shard_sel +: 32];
                SH_TRACE_CTRL: reg_word = trace_st_v  [32*shard_sel +: 32];
                default:    reg_word = 32'h0;
            endcase
        end
        else
        begin
            case ({1'b0, address[7:2], 2'b00})
                REG_CTRL:       reg_word = {irq_v[0], prism_enable, irq_v[1], 29'h0};
                REG_ID:         reg_word = {3'(PRISM_COND_LUT_SIZE), 3'(PRISM_COND_OUT), 6'(PRISM_INPUTS), 6'(OUTPUTS), 6'(DEPTH),
                                            1'(PRISM_FRACTURABLE), 1'(PRISM_DUAL_COMPARE), 3'(PRISM_STATE_INPUTS), 3'(PRISM_LUT_SIZE)};
                REG_INT_STATUS: reg_word = {28'h0, sema_v, irq_v};
                default:        reg_word = prism_read_data;   // debugger registers (word access)
            endcase
        end
        data_out = reg_word >> {address[1:0], 3'b000};
    end
    assign data_ready = 1'b1;

    // =============================================================
    // Enable and the delayed write strobe for the latch based registers
    // =============================================================
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            enable_r        <= 1'b0;
            `ifndef SYNTH_FPGA
            latch_wr        <= 1'b0;
            latch_wr_p0     <= 1'b0;
            latch_data      <= 32'h0;
            `endif
        end
        else
        begin
            `ifndef SYNTH_FPGA
            latch_wr_p0 <= prism_wr;
            latch_wr    <= latch_wr_p0;
            if (prism_wr)
                latch_data <= data_in;
            `endif

            if (word_wr && address == REG_CTRL)
                enable_r <= data_in[30];
        end
    end

endmodule
