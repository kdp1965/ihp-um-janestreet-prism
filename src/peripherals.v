/*
 * Copyright (c) 2025 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Wrapper for all TinyQV peripherals
//
// Address space:
// 0x800_0000 - 03f: Reserved by project wrapper (time, debug, etc)
// 0x800_0040 - 07f: GPIO configuration
// 0x800_0080 - 0bf: UART TX
// 0x800_00c0 - 0ff: UART RX
// 0x800_0100 - 13f: PRISM CFGMEM programming (user peripheral 4)
// 0x800_0200 - 3ff: PRISM Peripheral (user peripheral 8; the whole 512 byte
//                   region is decoded, so registers can sit at any +4 offset)
// 0x800_0400 - 7ff: unmapped (reads 0)
// The PRISM's SRAM FIFOs (IHP 1P macros): PRISM_SRAM_FIFO = number of them
// (2: one per shard, 1: one shared, 0: none, flop FIFOs only), PRISM_SRAM_AW
// their depth (9: 512x32 = 2 KB each)
`ifndef PRISM_SRAM_FIFO
`define PRISM_SRAM_FIFO 2
`endif
`ifndef PRISM_SRAM_AW
`define PRISM_SRAM_AW 9             // 9: 512x32 (2 KB), 10: 1024x32 (4 KB), 11: 2048x32 (8 KB)
`endif
`ifndef PRISM_CNT_CMP
`define PRISM_CNT_CMP 1             // 1: the CRC register doubles as a 32-bit up / down counter with compare (CFG3[10])
`endif

module tinyQV_peripherals (
    input         clk,
    input         rst_n,

    input  [7:0]  ui_in,        // The input PMOD, always available (2-flop synchronized)
    input  [7:0]  ui_in_1ff,    // The input PMOD after one synchronizer flop (PRISM raw/1-flop option)
    input  [7:0]  ui_in_raw,    // The raw input PMOD
    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected

    input [10:0]  addr_in,
    input [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    input [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    input [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits

    output [31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output        data_ready,

    input         data_read_complete,  // Set by TinyQV when a read is complete

    output [15:2] user_interrupts,  // User peripherals get interrupts 2-15

    // The PRISM's RX DMA tap (the engine, prism_dma.v, sits next to TinyQV)
    output  [7:0] dma_head,
    output        dma_empty,
    output        dma_drained,
    output        dma_avail4,
    output        dma_af,
    output        dma_frame_end,
    input         dma_pop,
    input         dma_en,
    input         dma_shard,
    input         dma_chain,
    input         dma_hw_end
);

    // Registered data out to TinyQV
    reg  [31:0] data_out_r;
    reg         data_out_hold;
    reg         data_ready_r;

    wire        read_req = data_read_n != 2'b11;

    // Muxed data out direct from selected peripheral
    reg [31:0] data_from_peri;
    reg        data_ready_from_peri;
    reg        data_ready_from_prism;

    // Must mask the data_read_n to avoid extra read while
    // buffering the result
    wire [1:0] data_read_n_peri;
    assign data_read_n_peri = data_read_n | {2{data_ready_r}};

    wire [31:0] data_from_user_peri   [0:7];
    wire [31:0] data_from_prism;
    wire        data_ready_from_user_peri   [0:7];

    wire [7:0]  uo_out_from_user_peri   [0:15];
    wire [7:0]  uo_out_from_prism;
    reg [7:0] uo_out_comb;
    assign uo_out = uo_out_comb;

    // Register the data output from the peripheral.  This improves timing and
    // also simplifies the peripheral interface (no need for the peripheral to care
    // about holding data_out until data_read_complete - it looks like it is read
    // synchronously).
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out_hold <= 0;
        end else begin
            if (data_read_complete) data_out_hold <= 0;

            if (!data_out_hold && data_ready_from_peri && data_read_n != 2'b11) begin
                data_out_hold <= 1;
                data_out_r <= data_from_peri;
            end

            // Data ready must be registered because data_out is.
            data_ready_r <= read_req && data_ready_from_peri;
        end
    end

    assign data_out = data_out_r;
    assign data_ready = data_ready_r || data_write_n != 2'b11;

    // --------------------------------------------------------------------- //
    // Decode the address to select the active peripheral

    localparam PERI_GPIO   = 1;
    localparam PERI_UART   = 2;
    localparam PERI_CFGMEM = 4;

    reg [7:0] peri_user;
    reg       peri_prism;

    always @(*) begin
        peri_user  = 0;
        peri_prism = 0;

        case (addr_in[10:9])
        2'b01: begin
            // 0x200 - 0x3ff: PRISM, fully decoded (no aliasing)
            data_from_peri = data_from_prism;
            data_ready_from_peri = data_ready_from_prism;
            peri_prism = 1;
        end
        2'b00: begin
            // 0x000 - 0x1ff: eight 64-byte user peripheral slots
            peri_user[addr_in[8:6]] = 1;
            data_from_peri = data_from_user_peri[addr_in[8:6]];
            data_ready_from_peri = data_ready_from_user_peri[addr_in[8:6]];
        end
        default: begin
            // 0x400 - 0x7ff: unmapped
            data_from_peri = 32'h0;
            data_ready_from_peri = 1'b1;
        end
        endcase
    end

    assign data_from_user_peri[0] = 32'h0;
    assign data_from_user_peri[5] = 32'h0;
    assign data_from_user_peri[6] = 32'h0;
    assign data_from_user_peri[7] = 32'h0;
    assign data_ready_from_user_peri[0] = 0;
    assign data_ready_from_user_peri[5] = 0;
    assign data_ready_from_user_peri[6] = 0;
    assign data_ready_from_user_peri[7] = 0;
    assign uo_out_from_user_peri[0] = 8'h0;

    // --------------------------------------------------------------------- //
    // GPIO

    reg  [3:0] gpio_out_func_sel [0:7];
    reg  [7:0] gpio_out;

    assign uo_out_from_user_peri[5] = 8'h0;
    assign uo_out_from_user_peri[6] = 8'h0;
    assign uo_out_from_user_peri[7] = 8'h0;
    assign uo_out_from_user_peri[9] = 8'h0;
    assign uo_out_from_user_peri[10] = 8'h0;
    assign uo_out_from_user_peri[11] = 8'h0;
    assign uo_out_from_user_peri[12] = 8'h0;
    assign uo_out_from_user_peri[13] = 8'h0;
    assign uo_out_from_user_peri[14] = 8'h0;
    assign uo_out_from_user_peri[15] = 8'h0;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            gpio_out <= 0;
        end else if (peri_user[PERI_GPIO]) begin
            if (addr_in[5:0] == 6'h0) begin
                if (data_write_n != 2'b11) gpio_out <= data_in[7:0];
            end
        end
    end

    assign data_from_user_peri[PERI_GPIO] = (addr_in[5:0] == 6'h0) ? {24'h0, gpio_out} :
                                            (addr_in[5:0] == 6'h4) ? {24'h0, ui_in}    :
                                            ({addr_in[5], addr_in[1:0]} == 3'b100) ? {27'h0, gpio_out_func_sel[addr_in[4:2]]} :
                                            32'h0;
    assign data_ready_from_user_peri[PERI_GPIO] = 1;
    assign uo_out_from_user_peri[PERI_GPIO] = gpio_out;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            always @(posedge clk) begin
                if (!rst_n) begin
                    gpio_out_func_sel[i] <= (i == 0 || i == 1) ? PERI_UART : PERI_GPIO;
                end else if (peri_user[PERI_GPIO]) begin
                    if ({addr_in[5], addr_in[1:0]} == 3'b100 && addr_in[4:2] == i) begin
                        if (data_write_n != 2'b11) gpio_out_func_sel[i] <= data_in[3:0];
                    end
                end
            end

            always @(*) begin
                uo_out_comb[i] = 0;

                uo_out_comb[i] = uo_out_from_user_peri[gpio_out_func_sel[i][3:0]][i];
            end
        end
    endgenerate

    // --------------------------------------------------------------------- //
    // UART

    tqvp_uart_wrapper i_uart (
        .clk(clk),
        .rst_n(rst_n),

        .ui_in(ui_in),
        .uo_out(uo_out_from_user_peri[PERI_UART]),

        .address(addr_in[5:0]),
        .data_in(data_in),

        .data_write_n(data_write_n    | {2{~peri_user[PERI_UART]}}),
        .data_read_n(data_read_n_peri | {2{~peri_user[PERI_UART]}}),

        .data_out(data_from_user_peri[PERI_UART]),
        .data_ready(data_ready_from_user_peri[PERI_UART]),

        .user_interrupt(user_interrupts[PERI_UART+1:PERI_UART])
    );

    // There is no peripheral 3, UART uses its interrupt.
    assign uo_out_from_user_peri[3] = 8'h0;
    assign data_from_user_peri[3] = 32'h0;
    assign data_ready_from_user_peri[3] = 1;

    // --------------------------------------------------------------------- //
    // CFGMEM peripheral
    localparam CFGMEM_COUNT = 4;
    localparam CFGMEM_DEPTH = 16;
    localparam SIT_ADDR_BITS = CFGMEM_DEPTH > 16 ? 5 : CFGMEM_DEPTH > 8 ? 4 : 3;

    wire [31:0]                cfgmem_data_out;
    wire [SIT_ADDR_BITS-1:0]   cfgmem_addr;
    wire                       cfgmem_addr_sel;
    wire [CFGMEM_COUNT-1:0]    cfgmem_we_lo;
    wire [CFGMEM_COUNT-1:0]    cfgmem_we_hi;
    wire [CFGMEM_DEPTH-1:0]    cfgmem_wrow;
    wire [CFGMEM_COUNT*32-1:0] cfgmem_data_in_lo;
    wire [CFGMEM_COUNT*32-1:0] cfgmem_data_in_hi;
    wire                       cfgmem_byp_lo;
    wire                       cfgmem_byp_hi;

    // Address bits from PRISM to be muxed with CFGMEM addr
    wire [SIT_ADDR_BITS-1:0]   prism_sit_addr_a;
    wire [SIT_ADDR_BITS-1:0]   prism_sit_addr_b;

    wire [SIT_ADDR_BITS-1:0]   cfgmem_addr_lo;
    wire [SIT_ADDR_BITS-1:0]   cfgmem_addr_hi;

    assign cfgmem_addr_lo = cfgmem_addr_sel ? cfgmem_addr : prism_sit_addr_a;
    assign cfgmem_addr_hi = cfgmem_addr_sel ? cfgmem_addr : prism_sit_addr_b;

    // Programming chains, one per macro column: host -> lo0 -> lo1 (left
    // column) and host -> lo2 -> lo3 (right column), the same for hi (macro
    // i's Di is macro i-1's Do within a column, the host word at the head of
    // each).  One chain through all four (2026-09-23 and earlier) put the
    // 64-wire link from lo1 / hi1 to lo2 / hi2 across the whole middle
    // corridor on Metal3 for a path that only runs during download.  With
    // the bank's bypass bit set every macro's Do is its Di, so the host word
    // still reaches every macro and each is shifted with its own strobe.
    wire [CFGMEM_COUNT*32-1:0] cfgmem_chain_lo;
    wire [CFGMEM_COUNT*32-1:0] cfgmem_chain_hi;
    assign cfgmem_chain_lo[ 31: 0] = cfgmem_data_out;
    assign cfgmem_chain_hi[ 31: 0] = cfgmem_data_out;
    assign cfgmem_chain_lo[ 63:32] = cfgmem_data_in_lo[31:0];
    assign cfgmem_chain_hi[ 63:32] = cfgmem_data_in_hi[31:0];
    assign cfgmem_chain_lo[ 95:64] = cfgmem_data_out;
    assign cfgmem_chain_hi[ 95:64] = cfgmem_data_out;
    assign cfgmem_chain_lo[127:96] = cfgmem_data_in_lo[95:64];
    assign cfgmem_chain_hi[127:96] = cfgmem_data_in_hi[95:64];

    cfgmem_periph
    #(
        .WIDTH ( CFGMEM_COUNT )
     )
    i_cfgmem
    (
        .clk(clk),
        .rst_n(rst_n),

        .uo_out(uo_out_from_user_peri[PERI_CFGMEM]),

        .address(addr_in[5:0]),
        .data_in(data_in),

        .data_write_n(data_write_n    | {2{~peri_user[PERI_CFGMEM]}}),
        .data_read_n(data_read_n_peri | {2{~peri_user[PERI_CFGMEM]}}),

        .data_out(data_from_user_peri[PERI_CFGMEM]),
        .data_ready(data_ready_from_user_peri[PERI_CFGMEM]),

        // CFGMEM access
        .cfgmem_data_out   ( cfgmem_data_out   ),
        .cfgmem_addr       ( cfgmem_addr       ),
        .cfgmem_addr_sel   ( cfgmem_addr_sel   ),
        .cfgmem_we_lo      ( cfgmem_we_lo      ),
        .cfgmem_we_hi      ( cfgmem_we_hi      ),
        .cfgmem_byp_lo     ( cfgmem_byp_lo     ),
        .cfgmem_byp_hi     ( cfgmem_byp_hi     ),
        .cfgmem_wrow       ( cfgmem_wrow       ),
        .cfgmem_data_in_lo ( cfgmem_data_in_lo ),
        .cfgmem_data_in_hi ( cfgmem_data_in_hi )
    );

    generate
        for (i = 0; i < CFGMEM_COUNT/2; i = i + 1) begin : CFGMEMS_LEFT
            (* keep = "true" *)
            CFGMEM_IHP_LEFT16 cfgmem_lo
            (
                .WE0  ( cfgmem_we_lo[i]                     ),
                .EN0  ( 1'b1                                ),
                .BYP  ( cfgmem_byp_lo                       ),
                .WROW ( cfgmem_wrow                         ),
                .A0   ( cfgmem_addr_lo                      ),
                .Di0  ( cfgmem_chain_lo[(i+1)*32-1 -: 32]   ),
                .Do0  ( cfgmem_data_in_lo[(i+1)*32-1 -: 32] )
            );
            
            (* keep = "true" *)
            CFGMEM_IHP_LEFT16 cfgmem_hi
            (
                .WE0  ( cfgmem_we_hi[i]                     ),
                .EN0  ( 1'b1                                ),
                .BYP  ( cfgmem_byp_hi                       ),
                .WROW ( cfgmem_wrow                         ),
                .A0   ( cfgmem_addr_hi                      ),
                .Di0  ( cfgmem_chain_hi[(i+1)*32-1 -: 32]   ),
                .Do0  ( cfgmem_data_in_hi[(i+1)*32-1 -: 32] )
            );
        end

        for (i = CFGMEM_COUNT/2; i < CFGMEM_COUNT; i = i + 1) begin : CFGMEMS
            (* keep = "true" *)
            CFGMEM_IHP16 cfgmem_lo
            (
                .WE0  ( cfgmem_we_lo[i]                     ),
                .EN0  ( 1'b1                                ),
                .BYP  ( cfgmem_byp_lo                       ),
                .WROW ( cfgmem_wrow                         ),
                .A0   ( cfgmem_addr_lo                      ),
                .Di0  ( cfgmem_chain_lo[(i+1)*32-1 -: 32]   ),
                .Do0  ( cfgmem_data_in_lo[(i+1)*32-1 -: 32] )
            );
            
            (* keep = "true" *)
            CFGMEM_IHP16 cfgmem_hi
            (
                .WE0  ( cfgmem_we_hi[i]                     ),
                .EN0  ( 1'b1                                ),
                .BYP  ( cfgmem_byp_hi                       ),
                .WROW ( cfgmem_wrow                         ),
                .A0   ( cfgmem_addr_hi                      ),
                .Di0  ( cfgmem_chain_hi[(i+1)*32-1 -: 32]   ),
                .Do0  ( cfgmem_data_in_hi[(i+1)*32-1 -: 32] )
            );
        end
    endgenerate

    // --------------------------------------------------------------------- //
    // PRISM Peripheral

    tqvp_prism #( .SRAM_FIFO ( `PRISM_SRAM_FIFO ), .SRAM_AW ( `PRISM_SRAM_AW ), .CNT_CMP ( `PRISM_CNT_CMP ) ) i_prism
    (
        .clk(clk),
        .rst_n(rst_n),

        .ui_in(ui_in),
        .ui_in_1ff(ui_in_1ff),
        .ui_in_raw(ui_in_raw),
        .uo_out(uo_out_from_user_peri[8]),

        .address(addr_in[8:0]),
        .data_in(data_in),

        .data_write_n(data_write_n    | {2{~peri_prism}}),
        .data_read_n(data_read_n_peri | {2{~peri_prism}}),

        .data_out(data_from_prism),
        .data_ready(data_ready_from_prism),

        .user_interrupt(user_interrupts[9:8]),   // shard 0 = IRQ 8, shard 1 = IRQ 9

        .dma_head      ( dma_head      ),
        .dma_empty     ( dma_empty     ),
        .dma_drained   ( dma_drained   ),
        .dma_avail4    ( dma_avail4    ),
        .dma_af        ( dma_af        ),
        .dma_frame_end ( dma_frame_end ),
        .dma_pop       ( dma_pop       ),
        .dma_en        ( dma_en        ),
        .dma_shard     ( dma_shard     ),
        .dma_chain     ( dma_chain     ),
        .dma_hw_end    ( dma_hw_end    ),

        // CFGMEM interface
        .sit_addr_a ( prism_sit_addr_a  ),
        .sit_addr_b ( prism_sit_addr_b  ),
        .stew_a     ( cfgmem_data_in_lo ),
        .stew_b     ( cfgmem_data_in_hi )
    );

    assign user_interrupts[7:4]  = 4'h0;
    assign user_interrupts[15:10] = 6'h0;

endmodule

// vim: et sw=4 ts=4
