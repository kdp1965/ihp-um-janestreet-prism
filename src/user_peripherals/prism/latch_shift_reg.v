// Copyright (c) 2025 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
// 
// Description:  
// ------------------------------------------------------------------------------
//
//    This is a Programmable Reconfigurable Indexed State Machine (PRISM)
//    peripheral for the TinyQV RISC-V processor.
//
//                        /\           
//                       /  \           
//                   ..-/----\-..       
//               --''  /      \  ''--   
//                    /________\        
//
// This module implements a latch based shift register config array.  The
// config words are not randomly accessible during write in order to save
// space in a limited 2-tile peripheal.  Instead they are shifted through
// the N states like a shift register.  Also there is no "read address" 
// decode ... all config latch bits are expose in a single wide bus.
//
// ------------------------------------------------------------------------------

module latch_shift_reg
#(
    parameter WIDTH = 48,
    parameter DEPTH = 8
)(
    input  wire                     rst_n,
    input  wire [WIDTH-1:0]         data_in,
    input  wire [DEPTH-1:0]         latch_en,
    output wire [WIDTH*DEPTH-1:0]   data_out
);

`ifdef SIM
    // Internal storage
    reg  [WIDTH-1:0] latch_regs [0:DEPTH-1];

    always @(latch_en or rst_n or data_in)
    begin
        integer i;
        for (i = 0; i < DEPTH; i = i + 1)
        begin : gen_prism_reg
            if (!rst_n | latch_en[i])
               latch_regs[i] <= i == 0 ? data_in : latch_regs[i-1];
        end
    end

`elsif SCL_sky130_fd_sc_hd
    // Internal storage
    wire [WIDTH-1:0] latch_regs [0:DEPTH-1];

    /* verilator lint_off PINMISSING */
    genvar i;
    genvar b;
    generate
    for (i = 0; i < DEPTH; i = i + 1)
    begin : gen_prism_reg
        for (b = 0; b < WIDTH; b = b + 1)
        begin : gen_prism_bit
            sky130_fd_sc_hd__dlxtp_1 prism_cfg_bit
            (
                .D((i == 0) ? data_in[b] : latch_regs[i-1][b]),
                .GATE(latch_en[i] | !rst_n),
                .Q(latch_regs[i][b])
            );
        end
    end
    endgenerate
    /* verilator lint_on PINMISSING */
`else
    // IHP sg13cmos5l cells: same pins as the sky130 cells above.
    // Internal storage
    wire [WIDTH-1:0] latch_regs [0:DEPTH-1];

    /* verilator lint_off PINMISSING */
    genvar i;
    genvar b;
    generate
    for (i = 0; i < DEPTH; i = i + 1)
    begin : gen_prism_reg
        for (b = 0; b < WIDTH; b = b + 1)
        begin : gen_prism_bit
            sg13cmos5l_dlhq_1 prism_cfg_bit
            (
                .D((i == 0) ? data_in[b] : latch_regs[i-1][b]),
                .GATE(latch_en[i] | !rst_n),
                .Q(latch_regs[i][b])
            );
        end
    end
    endgenerate
    /* verilator lint_on PINMISSING */
`endif

    // Flatten output
    genvar j;
    generate
        for (j = 0; j < DEPTH; j = j + 1) begin : output_pack
            assign data_out[(j+1)*WIDTH-1:j*WIDTH] = latch_regs[j];
        end
    endgenerate

endmodule

