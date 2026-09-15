// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// Trace port of one SRAM (docs section 4m).  Packs the owning shard's
// 16-bit trace entries two per 32-bit word and writes them into the SRAM
// from entry 0 up; when the capture ends (the shard stops, or the SRAM is
// full) it hands the contents to the SRAM FIFO wrapper (load / load_bytes)
// so the host reads the entries back as bytes.  It sits next to the SRAM:
// from the shard come the entry and three strobes, `full` goes back.
//
// Two ports make one buffer when `big`: the lower one fills first and the
// upper one takes over once lower_full.
`default_nettype none
module prism_trace_port
#(
    parameter AW = 9                        // SRAM word address bits (2^AW x 32)
)
(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          own,               // this SRAM belongs to a trace
    input  wire          big,               // ... as half of a two-SRAM buffer
    input  wire          upper,             // ... the upper half
    input  wire          lower_full,        // the lower half has all its entries
    input  wire          arm,               // the owner armed: restart at entry 0
    input  wire          cap,               // the owner captured an entry this clock
    input  wire          stop,              // the owner stopped the capture
    input  wire   [15:0] entry,
    output wire          full,              // 2^(AW+1) entries recorded
    output wire          held,              // holds a finished trace (until the next arm)
    output reg           load,              // hand the entries to the FIFO wrapper
    output wire [AW+2:0] load_bytes,        // ... this many bytes (2 per entry)
    output wire          wen,
    output wire [AW-1:0] addr,
    output wire   [31:0] din
);
    reg  [AW+1:0] n;                        // entries recorded (0 .. 2^(AW+1))
    reg    [15:0] hold;                     // low half of the word being assembled
    reg           held_r;

    wire turn   = own & !held_r & (!big | !upper | lower_full);
    wire take   = cap & turn & !n[AW+1];
    wire flush  = stop & own & !held_r & n[0];          // odd count: write the pending half
    wire ending = own & !held_r & (stop | (take & (&n[AW:0])));

    assign full       = n[AW+1];
    assign held       = held_r;
    assign wen        = (take & n[0]) | flush;
    assign addr       = n[AW:1];
    assign din        = flush ? {16'h0, hold} : {entry, hold};
    assign load_bytes = {n, 1'b0};

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            n      <= 0;
            hold   <= 16'h0;
            held_r <= 1'b0;
            load   <= 1'b0;
        end
        else
        begin
            load <= ending;
            if (arm || !own)
            begin
                n      <= 0;
                held_r <= 1'b0;
            end
            else
            begin
                if (take)
                begin
                    n <= n + 1'b1;
                    if (!n[0])
                        hold <= entry;
                end
                if (ending)
                    held_r <= 1'b1;
            end
        end
    end
endmodule
