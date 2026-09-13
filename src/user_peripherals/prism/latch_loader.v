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
// This module implements a shift-register based latch control where it
// pulses latch enables in a clean, successive manner to shift configuration
// words through a shift array.
//
// ------------------------------------------------------------------------------

module latch_loader
#(
    parameter DEPTH    = 8,
    parameter WIDTH    = 64
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire                  debug_wr,         // One-cycle pulse to initiate write
    input  wire                  latch_wr,         // Latch write signal properly timed
    input  wire  [31:0]          data_in,          // Incoming data from RISC-V
    input  wire  [5:0]           address,          // Input address
    output wire  [WIDTH-1:0]     config_data,      // Incoming data from RISC-V
    output wire  [DEPTH-1:0]     latch_en          // Latch enables, active high
);

    localparam    IDX_BITS = DEPTH > 16 ? 5 : DEPTH > 8 ? 4 : 3;

    // Counter-based FSM
    localparam IDLE    = 2'd0;
    localparam SHIFT   = 2'd1;
    localparam WAIT    = 2'd2;
    localparam NEXT    = 2'd3;

    reg  [1:0]           state, next_state;
    reg  [IDX_BITS-1:0]  index;
    reg                  latch_pulse;
    wire [DEPTH-1:0]     idx_decode;
    wire                 msb_enable;
    wire                 load;

    // Load when write_req and MSB of config data available
    assign load       = address == 6'h10 && debug_wr;
    assign msb_enable = address == 6'h14;

    genvar i;
    generate
      for (i = 0; i < DEPTH; i = i + 1)
      begin : IDX_GEN
        assign idx_decode[i] = i == index;
      end
    endgenerate

    // Sequential state machine
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin
            state       <= IDLE;
            index       <= {IDX_BITS{1'b0}};
            latch_pulse <= 1'b0;
        end else begin
            state    <= next_state;
            latch_pulse <= state == SHIFT ? 1'b1 : 1'b0;
            if (state == IDLE && load)
                index <= (IDX_BITS)'(DEPTH - 1);
            else if (state == NEXT)
                index <= index - 1;
        end
    end

    // FSM transitions
    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (load) next_state = SHIFT;
            SHIFT:   next_state = WAIT;
            WAIT:    next_state = NEXT;
            NEXT:    next_state = (index == 0) ? IDLE : SHIFT;
            default: next_state = IDLE;
        endcase
    end

    // Latch enable logic
`ifdef SIM
   assign latch_en = idx_decode & {DEPTH{latch_pulse}};
`elsif SCL_sky130_fd_sc_hd
    generate
      for (i = 0; i < DEPTH; i = i + 1)
      begin : AND_GEN
         /* verilator lint_off PINMISSING */
         // Instantiate AND gate for latch enable
         (* keep = 1 *) sky130_fd_sc_hd__and2_1 gate_and
                       (
                           .A ( idx_decode[i] ),
                           .B ( latch_pulse   ),
                           .X ( latch_en[i]   )
                       );
         /* verilator lint_on PINMISSING */
      end
    endgenerate
`else
    // IHP sg13cmos5l cells: same pins as the sky130 cells above.
    generate
      for (i = 0; i < DEPTH; i = i + 1)
      begin : AND_GEN
         /* verilator lint_off PINMISSING */
         // Instantiate AND gate for latch enable
         (* keep = 1 *) sg13cmos5l_and2_1 gate_and
                       (
                           .A ( idx_decode[i] ),
                           .B ( latch_pulse   ),
                           .X ( latch_en[i]   )
                       );
         /* verilator lint_on PINMISSING */
      end
    endgenerate
`endif

    // Data buffer
    assign config_data[31:0] = data_in;

    prism_latch_reg 
    #(
      .WIDTH(WIDTH-32)
    )
    config_msb
    (
        .rst_n       ( rst_n                   ),
        .enable      ( msb_enable              ),
        .wr          ( latch_wr                ),
        .data_in     ( data_in[WIDTH-32-1:0]   ),
        .data_out    ( config_data[WIDTH-1:32] )
    );

endmodule
