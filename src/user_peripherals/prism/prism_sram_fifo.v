// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// Byte FIFO on a single-port 32-bit SRAM (IHP 1024x32 / 2048x32 macro).
//
// Same FSM-side contract as prism_fifo.v (push / pop strobes, head byte,
// count and flags) with the storage in the SRAM, four bytes per word.
// The port is shared by whole-word accesses only:
//
//   - pushes assemble a word in `asm_w`; the fourth byte writes the word
//     to the SRAM in the same clock (writes have priority; a push is
//     never refused unless `full`);
//   - the word at the read pointer is cached in `rd_w`, so pops within a
//     word need no access; a pop that leaves a word issues the read of the
//     next word at once (one clock later if a word is being written) and
//     `empty` is reported until the data is back (two or three clocks).
//     The head byte comes from the word being assembled while the reader
//     is in it, and a write to the reader's word refreshes the cache.
//
// The read data of the macro is registered (one clock after A_REN).
// Contents survive PRISM disable like the flop FIFO; flush empties it.
// The almost-empty / almost-full levels (64-byte units) are compared by the
// shard from `count`, so that only the count crosses the tile.
// `load` makes the FIFO serve load_bytes bytes from word 0 that something
// else (the tracer) wrote into the SRAM directly, oldest byte first.
// Almost-empty / almost-full levels are in 64-byte units.
`default_nettype none
module prism_sram_fifo
#(
    parameter AW = 11                       // word address bits (2^AW x 32)
)
(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          flush,
    input  wire          load,              // the SRAM holds load_bytes bytes from word 0 (a trace): serve them
    input  wire [AW+2:0] load_bytes,
    input  wire          push,
    input  wire    [7:0] push_data,
    input  wire          pop,
    output wire    [7:0] head,
    output wire [AW+2:0] count,             // bytes held (0 .. 4 * 2^AW); the almost-empty /
                                            // almost-full flags are derived from it by the shard
    output wire          empty,             // no byte available to pop right now
    output wire          full,              // no room for a push right now
    // SRAM port (A_MEN = ren | wen)
    output reg  [AW-1:0] sram_addr,
    output reg    [31:0] sram_din,
    output wire   [31:0] sram_bm,
    output reg           sram_wen,
    output reg           sram_ren,
    input  wire   [31:0] sram_dout
);
    localparam BYTES = 1 << (AW + 2);

    reg  [AW+1:0] wr_ptr, rd_ptr;           // byte pointers {word, lane}
    reg  [AW+2:0] cnt;
    reg    [23:0] asm_w;                    // bytes 0..2 of the word being assembled
    reg    [31:0] rd_w;                     // cached word at the read pointer
    reg           rd_v;
    reg           rd_need;                  // read deferred by a write last clock
    reg           read_pending;             // a read was issued last clock

    wire [AW-1:0] wr_word = wr_ptr[AW+1:2];
    wire    [1:0] wr_lane = wr_ptr[1:0];
    wire [AW-1:0] rd_word = rd_ptr[AW+1:2];
    wire    [1:0] rd_lane = rd_ptr[1:0];

    // Head byte source: the word being assembled while the reader is in it
    // (fewer than four bytes held), else the cache
    wire        same_word  = (rd_word == wr_word) && (cnt[AW+2:2] == 0);
    wire        head_valid = same_word | rd_v;
    wire [31:0] src_w      = same_word ? {8'h0, asm_w} : rd_w;

    assign head         = src_w[rd_lane * 8 +: 8];
    assign count        = cnt;
    assign empty        = (cnt == 0) || !head_valid;
    assign full         = cnt[AW+2];        // cnt == BYTES

    wire push_ok = push && !full;
    wire pop_ok  = pop && !empty;

    // A pop that leaves the cached word wants the next word read, unless it
    // empties the FIFO (the next push then serves the head directly); the
    // fourth byte of a word writes it now (words complete at most every
    // four clocks, so a deferred read always goes out on the next clock)
    wire [AW+1:0] rd_next   = rd_ptr + 1'b1;
    wire [AW+2:0] cnt_next  = cnt + {{(AW+2){1'b0}}, push_ok} - {{(AW+2){1'b0}}, pop_ok};
    wire          leave     = pop_ok && (rd_lane == 2'd3);
    wire          read_want = (leave && (cnt_next != 0)) || rd_need;
    wire [AW-1:0] rd_word_next = leave ? rd_next[AW+1:2] : rd_word;
    wire          asm_done  = push_ok && (wr_lane == 2'd3);
    wire        [31:0] asm_word = {push_data, asm_w};

    always @*
    begin
        sram_wen  = asm_done;
        sram_ren  = read_want && !asm_done;
        sram_addr = asm_done ? wr_word : rd_word_next;
        sram_din  = asm_word;
    end
    assign sram_bm = {32{1'b1}};

    // A write to the reader's word refreshes the cache (it is newer than
    // any read in flight) and makes a deferred read unnecessary
    wire write_thru = asm_done && (wr_word == rd_word_next);

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            wr_ptr <= 0; rd_ptr <= 0; cnt <= 0;
            asm_w <= 24'h0; rd_w <= 32'h0; rd_v <= 1'b0;
            rd_need <= 1'b0; read_pending <= 1'b0;
        end
        else if (flush)
        begin
            wr_ptr <= 0; rd_ptr <= 0; cnt <= 0;
            rd_v <= 1'b0; rd_need <= 1'b0; read_pending <= 1'b0;
        end
        else if (load)
        begin
            // the write pointer rounds up to a word boundary so the reader
            // never sees a "word being assembled" (the last, partial word is
            // in the SRAM, not in asm_w); flush before pushing again
            wr_ptr <= {load_bytes[AW+1:2] + {{AW-1{1'b0}}, |load_bytes[1:0]}, 2'b00};
            rd_ptr <= 0;
            cnt    <= load_bytes;
            rd_v   <= 1'b0;
            rd_need <= (load_bytes != 0);   // fetch word 0
            read_pending <= 1'b0;
        end
        else
        begin
            cnt          <= cnt_next;
            read_pending <= sram_ren;
            rd_need      <= read_want && asm_done && !write_thru;

            // push: assemble; the fourth byte goes to the SRAM with the rest
            if (push_ok)
            begin
                wr_ptr <= wr_ptr + 1'b1;
                if (wr_lane != 2'd3)
                    asm_w[wr_lane * 8 +: 8] <= push_data;
            end

            // pop: leaving the cached word invalidates it
            if (pop_ok)
            begin
                rd_ptr <= rd_next;
                if (rd_lane == 2'd3)
                    rd_v <= 1'b0;
            end

            // cache refill: read return, overridden by a write to that word
            if (read_pending)
            begin
                rd_w <= sram_dout;
                rd_v <= 1'b1;
            end
            if (write_thru)
            begin
                rd_w <= asm_word;
                rd_v <= 1'b1;
            end
        end
    end
endmodule
