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
//     +0x24  FIFO_STATUS {count[12:8], almost_full[3], almost_empty[2], full[1], empty[0]}; any write flushes
//     +0x28  CRC_POLY
//     +0x2C  CRC      value; write = preset
//     +0x30  CRC_EXPECTED
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
//
// Output bits (changes.md item 12):
//     0-3  pin_out[3:0]        4  OUT_LATCH             5  OUT_FIFO_WR_RD (Phase 4)
//     6    OUT_COUNT1_INC_DEC  7  OUT_COUNT1_CLEAR_LOAD 8  OUT_SHIFT
//     9    OUT_COUNT2_INC     10  OUT_COUNT2_DEC       11  OUT_COUNT2_CLEAR
//     12   OUT_CRC_CLEAR      13  OUT_CRC_UPDATE       14  OUT_HOST_INTERRUPT
//     15   OUT_SEMA_CLEAR     16  OUT_COMM_LOAD        17  OUT_LOAD_CRC (selected shifter <= CRC)
//     19   OUT_SEMA_SET
//
// Input bits (per shard):
//     6:0  ui_in[6:0] (sync select)  7 shift_data   9:8 host_in   10 count1_term
//     11   count2_cmp   13:12 latched_in (or latched outputs)   14 shift_term
//     15   count2_eq_comm   20 fifo_empty   21 fifo_full   22 crc_ok
//     23   count1_wrap   24 sema_in   25 other_shard_halt
//     26   fifo_almost_full   27 fifo_almost_empty

`default_nettype none

module tqvp_prism (
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
    localparam  OUT_COMM_LOAD         = 16;
    localparam  OUT_LOAD_CRC          = 17;
    localparam  OUT_SEMA_SET          = 19;

    // CFG0 bits used here (the rest live in prism_datapath.v)
    localparam  CFG_LATCH_IN_OUT      = 7;
    localparam  CFG_LATCH_EN          = 13;
    localparam  CFG_IN_SYNC_SEL       = 18;   // [19:18]
    localparam  CFG_CRC_MODE          = 20;   // [21:20]
    localparam  CFG_CRC_REFLECT       = 22;
    localparam  CFG_FIFO_DIR          = 23;
    localparam  CFG_SEMA_SET_WINS     = 24;
    localparam  CFG_CRC_INIT_ONES     = 25;
    localparam  CFG_CRC_XOR_OUT       = 26;
    localparam  CFG_CRC_SRC           = 27;

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
    wire [32*SHARDS-1:0] fifo_st_v;
    wire [8*SHARDS-1:0]  fifo_head_v;
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
            wire                      sema_clr = exec & out_s[OUT_SEMA_CLEAR];
            wire                      shift_in_bit = pin_in[{1'b0, cfg0[1:0]}];
            // FIFO / CRC
            wire [31:0]               cfg1;
            wire [31:0]               crc_poly;
            wire [31:0]               crc_exp;
            wire                      cfg1_en, crc_poly_en, crc_exp_en;
            wire                      fifo_dir = cfg0[CFG_FIFO_DIR];
            wire                      fifo_op  = exec & out_s[OUT_FIFO_WR_RD];
            wire                      fifo_rd  = (data_read_n != 2'b11) && win && (shard_off[6:2] == SH_FIFO[6:2]);
            wire                      fifo_wr  = prism_wr && win && shard_off == SH_FIFO;
            wire                      fifo_flush = prism_wr && win && shard_off == SH_FIFO_ST;
            wire  [7:0]               fifo_head;
            wire  [FIFO_AW:0]         fifo_count;
            wire                      fifo_empty, fifo_full, fifo_ae, fifo_af;
            wire [31:0]               crc_value, crc_out;
            wire                      crc_ok;

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
                .o_fifo_pop       ( out_s[OUT_FIFO_WR_RD] & fifo_dir   ),
                .fifo_data        ( fifo_head                          ),
                .o_load_crc       ( out_s[OUT_LOAD_CRC]                ),
                .crc_data         ( crc_out                            ),
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

            // FIFO: RX (fifo_dir = 0) FSM pushes comm / host pops by reading,
            //       TX (fifo_dir = 1) host pushes by writing / FSM pops into comm
            prism_fifo #( .DEPTH ( FIFO_DEPTH ), .AW ( FIFO_AW ) ) i_fifo
            (
                .clk          ( clk                              ),
                .rst_n        ( rst_n                            ),
                .flush        ( fifo_flush                       ),
                .push         ( fifo_dir ? fifo_wr : fifo_op     ),
                .push_data    ( fifo_dir ? data_in[7:0] : comm   ),
                .pop          ( fifo_dir ? fifo_op : fifo_rd     ),
                .ae_level     ( cfg1[16 +: FIFO_AW]              ),
                .af_level     ( cfg1[20 +: FIFO_AW]              ),
                .head         ( fifo_head                        ),
                .count        ( fifo_count                       ),
                .empty        ( fifo_empty                       ),
                .full         ( fifo_full                        ),
                .almost_empty ( fifo_ae                          ),
                .almost_full  ( fifo_af                          )
            );

            // CRC over the bit the shifter is receiving (crc_src = 0) or
            // transmitting (crc_src = 1) in the cycle OUT_CRC_UPDATE is set
            prism_crc i_crc
            (
                .clk          ( clk                              ),
                .rst_n        ( rst_n                            ),
                .enable       ( prism_enable                     ),
                .clear        ( exec & out_s[OUT_CRC_CLEAR]      ),
                .update       ( exec & out_s[OUT_CRC_UPDATE]     ),
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
            assign in_s[19:16] = 4'h0;              // in_prev[3:2], spare
            assign in_s[20]    = fifo_empty;
            assign in_s[21]    = fifo_full;
            assign in_s[22]    = crc_ok;
            assign in_s[23]    = count1_wrap;
            assign in_s[24]    = sema;
            assign in_s[25]    = halt_r_v[1-s];     // other shard halted (registered: the live
                                                    // halt includes the conditional break, which
                                                    // depends on this shard's inputs)
            assign in_s[26]    = fifo_af;
            assign in_s[27]    = fifo_ae;
            assign in_s[31:28] = 4'h0;

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

                    // Latched inputs
                    if (!prism_enable)
                        latched_in <= 2'h0;
                    else if (exec && cfg0[CFG_LATCH_EN] && out_s[OUT_LATCH])
                        latched_in <= {shift_data, cond_s[0]};
                end
            end

            // Configuration registers: latches (area) or flops (FPGA)
            assign cfg0_en    = win && shard_off == SH_CFG0;
            assign pinmux_en  = win && shard_off == SH_PINMUX;
            assign preload_en = win && shard_off == SH_PRELOAD;
            assign cfg1_en     = win && shard_off == SH_CFG1;
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
            reg [31:0] cfg1_r, crc_poly_r, crc_exp_r;
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
                end
                else
                begin
                    if (cfg0_en & prism_wr)     cfg0_r     <= data_in;
                    if (pinmux_en & prism_wr)   pinmux_r   <= data_in[20:0];
                    if (preload_en & prism_wr)  preload_r  <= data_in;
                    if (cfg1_en & prism_wr)     cfg1_r     <= data_in;
                    if (crc_poly_en & prism_wr) crc_poly_r <= data_in;
                    if (crc_exp_en & prism_wr)  crc_exp_r  <= data_in;
                end
            end
            assign cfg0     = cfg0_r;
            assign pinmux   = pinmux_r;
            assign preload  = preload_r;
            assign cfg1     = cfg1_r;
            assign crc_poly = crc_poly_r;
            assign crc_exp  = crc_exp_r;
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
            assign fifo_st_v [32*s +: 32] = {19'h0, fifo_count, 4'h0, fifo_af, fifo_ae, fifo_full, fifo_empty};
            assign fifo_head_v[8*s +: 8]  = fifo_head;
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
