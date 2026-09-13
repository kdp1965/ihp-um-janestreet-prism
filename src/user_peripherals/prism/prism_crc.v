// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// Bit-serial CRC unit for a PRISM shard (changes.md item 8).
//
// A 32-bit LFSR with a programmable polynomial.  The FSM feeds one bit per
// OUT_CRC_UPDATE (the bit the shifter is receiving or transmitting in that
// same cycle) and presets the register with OUT_CRC_CLEAR.  Width comes from
// crc_mode (8 / 16 / 32); reflected mode shifts right and expects the
// reflected polynomial (CRC-32/Ethernet 0xEDB88320, CRC-16/USB 0xA001, the
// USB CRC5 0x14 also works there since a reflected CRC is width independent
// as long as the polynomial fits).  Non-reflected mode shifts left with the
// feedback taken from bit width-1 (CRC-8 0x07, CRC-16/CCITT 0x1021,
// CRC-32 0x04C11DB7).
//
//   ok        = value == expected over the width (receiver check against the
//               protocol's residue / magic value, or a value the host set)
//   out_value = value, complemented when xor_out is set, for loading into a
//               shifter to transmit the checksum (OUT_LOAD_CRC)

`default_nettype none

module prism_crc
(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,            // shard enabled (clears the register when low)
    input  wire        clear,             // OUT_CRC_CLEAR: preset to the init value
    input  wire        update,            // OUT_CRC_UPDATE: shift bit_in through the LFSR
    input  wire        consume,           // OUT_LOAD_CRC into the 8-bit shifter: drop the byte just taken
    input  wire        bit_in,
    input  wire  [1:0] mode,              // 0 off, 1 = 8 bits, 2 = 16 bits, 3 = 32 bits
    input  wire        reflect,           // 1 = LSB first (shift right), 0 = MSB first
    input  wire        init_ones,         // preset value: all ones (1) or zero (0)
    input  wire        xor_out,           // complement out_value
    input  wire [31:0] poly,
    input  wire [31:0] expected,
    input  wire        wr,                // host preset of the register
    input  wire [31:0] wr_data,

    output reg  [31:0] value,
    output wire [31:0] out_value,
    output wire  [7:0] out_byte,          // next byte to transmit through the 8-bit shifter
    output wire        ok
);

    wire [31:0] mask     = mode == 2'd1 ? 32'h0000_00FF :
                           mode == 2'd2 ? 32'h0000_FFFF : 32'hFFFF_FFFF;
    wire [31:0] init     = init_ones ? mask : 32'h0;
    wire        msb      = mode == 2'd1 ? value[7] :
                           mode == 2'd2 ? value[15] : value[31];
    wire        fb       = (reflect ? value[0] : msb) ^ bit_in;
    wire [31:0] shifted  = reflect ? {1'b0, value[31:1]} : {value[30:0], 1'b0};
    wire [31:0] next     = (shifted ^ (fb ? poly : 32'h0)) & mask;

    assign out_value = (xor_out ? ~value : value) & mask;
    // Byte order on the wire: reflected CRCs go low byte first, others high
    // byte first; each OUT_LOAD_CRC through comm takes one byte and `consume`
    // moves the next one into place (16- and 32-bit CRCs need 2 / 4 loads).
    wire [7:0]  first    = reflect      ? value[7:0]   :
                           mode == 2'd2 ? value[15:8]  :
                           mode == 2'd3 ? value[31:24] : value[7:0];
    wire [31:0] consumed = reflect ? {8'h0, value[31:8]} : {value[23:0], 8'h0};
    assign out_byte  = xor_out ? ~first : first;
    assign ok        = (mode != 2'd0) && ((value & mask) == (expected & mask));

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            value <= 32'h0;
        else if (!enable)
            value <= 32'h0;
        else if (wr)
            value <= wr_data & mask;
        else if (clear)
            value <= init;
        else if (consume)
            value <= consumed & mask;
        else if (update && mode != 2'd0)
            value <= next;
    end

endmodule
