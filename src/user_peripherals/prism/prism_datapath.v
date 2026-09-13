// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// PRISM per-shard datapath (changes.md items 2-5):
//
//   count1      24/32-bit counter / shift register (count down with saturate
//               at 0, or count up with roll-over at preload or at the natural
//               maximum), loadable from the 32-bit preload, clearable, shifts
//               left (MSB first) or right (LSB first)
//   shift_count 5-bit count of wide shifts, wraps at 24/32; a load can set
//               it to 1 (the first bit is already on the pin)
//   comm        8-bit shift register (full duplex serial byte), loadable from
//               preload[7:0]; 3-bit shift count with the same load-to-1 option
//   count2      8-bit up/down counter with an 8-bit compare register
//
// One instance per shard (changes.md item 6).  All PRISM-driven updates are
// gated by `exec` (shard enabled and not halted by the debugger); host writes
// are not.  Disabling the shard clears the counters, like the old peripheral's
// prism_rst_n did.
`default_nettype none

module prism_datapath
(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,            // shard enabled
    input  wire        exec,              // shard executing (enable & !halted)

    // PRISM outputs (raw out_data bits of this shard)
    input  wire        o_count1_step,     // OUT_COUNT1_INC_DEC
    input  wire        o_count1_clrload,  // OUT_COUNT1_CLEAR_LOAD
    input  wire        o_shift,           // OUT_SHIFT
    input  wire        o_count2_inc,
    input  wire        o_count2_dec,
    input  wire        o_count2_clear,
    input  wire        o_comm_load,       // OUT_COMM_LOAD
    input  wire        shift_in,          // serial input bit (selected pin)

    // configuration (CFG0 bits, see prism_periph.v / docs/prism_interface.md)
    input  wire [31:0] cfg,
    input  wire [31:0] preload,
    input  wire  [7:0] compare,

    // host writes (not gated by exec)
    input  wire        wr_count1,
    input  wire [31:0] wr_count1_data,
    input  wire        wr_count2,
    input  wire  [7:0] wr_count2_data,
    input  wire        wr_comm,
    input  wire  [7:0] wr_comm_data,

    // state
    output reg  [31:0] count1,
    output reg   [7:0] count2,
    output reg   [7:0] comm,
    output reg   [4:0] shift_count,
    output reg   [2:0] comm_count,
    output reg         count1_wrap,       // sticky: count-up rolled over

    // flags to the PRISM inputs
    output wire        count1_term,       // ==0 counting down; ==preload / ==max counting up
    output wire        count2_cmp,        // count2 >= compare
    output wire        count2_eq_comm,    // count2 == comm
    output wire        shift_term,        // selected shifter's count is 0
    output wire        shift_data         // selected shifter's serial output bit
);

    // CFG0 bit positions
    localparam CFG_CLR_NOT_LOAD   = 6;    // OUT_COUNT1_CLEAR_LOAD clears instead of loading
    localparam CFG_SHIFT_EN       = 8;
    localparam CFG_SHIFT_DIR      = 9;    // 0 = MSB first (shift left), 1 = LSB first (shift right)
    localparam CFG_SHIFT_WIDE     = 10;   // 1 = count1 shifts, 0 = comm shifts
    localparam CFG_COUNT32        = 11;   // 1 = 32-bit count1, 0 = 24-bit
    localparam CFG_COUNT2_DEC_EN  = 12;
    localparam CFG_COUNT_UP       = 14;
    localparam CFG_WRAP_PRELOAD   = 15;   // count-up rolls over at preload instead of the maximum
    localparam CFG_SHIFT_LOAD_ONE = 16;   // wide load sets shift_count to 1
    localparam CFG_COMM_LOAD_ONE  = 17;   // comm load sets comm_count to 1

    wire clr_not_load   = cfg[CFG_CLR_NOT_LOAD];
    wire shift_en       = cfg[CFG_SHIFT_EN];
    wire shift_dir      = cfg[CFG_SHIFT_DIR];
    wire shift_wide     = cfg[CFG_SHIFT_WIDE];
    wire count32        = cfg[CFG_COUNT32];
    wire count2_dec_en  = cfg[CFG_COUNT2_DEC_EN];
    wire count_up       = cfg[CFG_COUNT_UP];
    wire wrap_preload   = cfg[CFG_WRAP_PRELOAD];
    wire shift_load_one = cfg[CFG_SHIFT_LOAD_ONE];
    wire comm_load_one  = cfg[CFG_COMM_LOAD_ONE];

    wire [31:0] mask        = count32 ? 32'hFFFF_FFFF : 32'h00FF_FFFF;
    wire [31:0] preload_m   = preload & mask;
    wire  [4:0] shift_last  = count32 ? 5'd31 : 5'd23;
    wire        shift_wide_en = o_shift & shift_en &  shift_wide;
    wire        shift_comm_en = o_shift & shift_en & ~shift_wide;
    wire        count1_at_top = wrap_preload ? (count1 == preload_m) : (count1 == mask);

    wire [31:0] count1_shl = count32 ? {count1[30:0], shift_in} : {8'h0, count1[22:0], shift_in};
    wire [31:0] count1_shr = count32 ? {shift_in, count1[31:1]} : {8'h0, shift_in, count1[23:1]};

    // ---------------------------------------------------------------- count1
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            count1      <= 32'h0;
            shift_count <= 5'h0;
            count1_wrap <= 1'b0;
        end
        else if (!enable)
        begin
            count1      <= 32'h0;
            shift_count <= 5'h0;
            count1_wrap <= 1'b0;
        end
        else if (wr_count1)
        begin
            count1      <= wr_count1_data & mask;
            shift_count <= 5'h0;
            count1_wrap <= 1'b0;
        end
        else if (exec)
        begin
            if (o_count1_clrload)
            begin
                count1      <= clr_not_load ? 32'h0 : preload_m;
                count1_wrap <= 1'b0;
                if (shift_wide)
                    shift_count <= shift_load_one ? 5'd1 : 5'd0;
            end
            else if (o_count1_step)
            begin
                if (count_up)
                begin
                    if (count1_at_top)
                    begin
                        count1      <= 32'h0;
                        count1_wrap <= 1'b1;
                    end
                    else
                        count1 <= (count1 + 32'd1) & mask;
                end
                else if (count1 != 32'h0)
                    count1 <= count1 - 32'd1;
            end
            else if (shift_wide_en)
            begin
                count1      <= shift_dir ? count1_shr : count1_shl;
                shift_count <= (shift_count == shift_last) ? 5'd0 : shift_count + 5'd1;
            end
        end
    end

    // ------------------------------------------------------------------ comm
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            comm       <= 8'h0;
            comm_count <= 3'h0;
        end
        else if (wr_comm)
        begin
            comm       <= wr_comm_data;
            comm_count <= 3'h0;
        end
        else if (!enable)
            comm_count <= 3'h0;
        else if (exec)
        begin
            if (o_comm_load)
            begin
                comm       <= preload[7:0];
                comm_count <= comm_load_one ? 3'd1 : 3'd0;
            end
            else if (shift_comm_en)
            begin
                comm       <= shift_dir ? {shift_in, comm[7:1]} : {comm[6:0], shift_in};
                comm_count <= comm_count + 3'd1;
            end
        end
    end

    // ---------------------------------------------------------------- count2
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count2 <= 8'h0;
        else if (!enable)
            count2 <= 8'h0;
        else if (wr_count2)
            count2 <= wr_count2_data;
        else if (exec)
        begin
            if (o_count2_clear)
                count2 <= 8'h0;
            else if (o_count2_inc)
                count2 <= count2 + 8'd1;
            else if (count2_dec_en && o_count2_dec)
                count2 <= count2 - 8'd1;
        end
    end

    // ----------------------------------------------------------------- flags
    assign count1_term    = count_up ? count1_at_top : (count1 == 32'h0);
    assign count2_cmp     = count2 >= compare;
    assign count2_eq_comm = count2 == comm;
    assign shift_term     = shift_wide ? (shift_count == 5'h0) : (comm_count == 3'h0);
    assign shift_data     = shift_wide ? (shift_dir ? count1[0] : (count32 ? count1[31] : count1[23]))
                                       : (shift_dir ? comm[0]   : comm[7]);

endmodule
