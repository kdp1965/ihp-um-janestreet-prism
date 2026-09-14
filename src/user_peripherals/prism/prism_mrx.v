// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// Manchester bit recoverer for the PRISM (10BASE-T receive; IEEE 802.3:
// a 1 is a low-to-high mid-bit transition, a 0 high-to-low).
//
// Runs on the PRISM clock with `hb` clocks per half bit.  An edge on the
// (already synchronised) line is accepted when the blanking interval since
// the last accepted edge has passed: hb + hb/2 clocks, three quarters of a
// bit, so the transition at a bit boundary (half a bit after a mid-bit
// edge, present between two equal bits) is skipped and the next mid-bit
// edge is taken, whatever the phase of the line against the clock.  The
// level after the accepted edge is the bit.  `valid` stays set until the
// FSM consumes the bit with its shift strobe, so a two-state receive loop
// never misses one; a new bit replaces an unconsumed one.  Everything else
// (preamble / SFD hunting, byte assembly, CRC, end of frame by timeout)
// is the chroma's job with the usual datapath.
`default_nettype none
module prism_mrx
(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire       line,         // synchronised receive line
    input  wire [3:0] hb,           // clocks per half bit (3 at 60 MHz)
    input  wire       consume,      // the FSM took the bit (shift strobe)
    output reg        valid,
    output reg        value
);
    reg        line_d;
    reg  [4:0] blank;               // clocks until the next edge may be accepted
    wire       edge_seen = enable & (line ^ line_d);
    wire       accept    = edge_seen & (blank == 5'd0);
    wire [4:0] blank_ld  = {1'b0, hb} + {2'b0, hb[3:1]};    // hb + hb/2

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            line_d <= 1'b0;
            blank  <= 5'd0;
            valid  <= 1'b0;
            value  <= 1'b0;
        end
        else
        begin
            line_d <= line;
            if (!enable)
            begin
                blank <= 5'd0;
                valid <= 1'b0;
            end
            else if (accept)
            begin
                value <= line;
                valid <= 1'b1;
                blank <= blank_ld;
            end
            else
            begin
                if (blank != 5'd0)
                    blank <= blank - 5'd1;
                if (consume)
                    valid <= 1'b0;
            end
        end
    end
endmodule
