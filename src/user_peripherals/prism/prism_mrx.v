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
//
// Double-edge sampling (`ddr`): the line is also sampled on the falling
// clock edge and both samples arrive here in time order, `line_h` (the
// falling-edge sample) then `line`.  The recoverer processes them one
// after the other in the same clock, and `hb` and the blanking interval
// then count half clocks (hb = 6 at 64 MHz, 5 at 50 MHz): twice the edge
// resolution for the same line rate.
`default_nettype none
module prism_mrx
(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire       ddr,          // two samples per clock: line_h then line
    input  wire       line,         // synchronised receive line (rising-edge sample)
    input  wire       line_h,       // the falling-edge sample half a clock earlier (ddr)
    input  wire [3:0] hb,           // samples per half bit: clocks, or half clocks with ddr
    input  wire       consume,      // the FSM took the bit (shift strobe)
    output reg        valid,
    output reg        value
);
    reg        line_d;
    reg  [4:0] blank;               // samples until the next edge may be accepted
    wire [4:0] blank_ld  = {1'b0, hb} + {2'b0, hb[3:1]};    // hb + hb/2
    // first sample of the clock: the falling-edge one (none without ddr)
    wire       sa        = ddr ? line_h : line_d;
    wire       edge_a    = enable & (line_d ^ sa);
    wire       accept_a  = edge_a & (blank == 5'd0);
    wire [4:0] blank_a   = accept_a ? blank_ld : (ddr && blank != 5'd0) ? blank - 5'd1 : blank;
    // second (or only) sample: the rising-edge one
    wire       edge_b    = enable & (sa ^ line);
    wire       accept_b  = edge_b & (blank_a == 5'd0);
    wire [4:0] blank_nx  = accept_b ? blank_ld : (blank_a != 5'd0) ? blank_a - 5'd1 : 5'd0;

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
            else
            begin
                blank <= blank_nx;
                if (accept_b)
                begin
                    value <= line;
                    valid <= 1'b1;
                end
                else if (accept_a)
                begin
                    value <= sa;
                    valid <= 1'b1;
                end
                else if (consume)
                    valid <= 1'b0;
            end
        end
    end
endmodule
