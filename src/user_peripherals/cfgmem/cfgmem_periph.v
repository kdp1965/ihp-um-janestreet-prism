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
//
// ------------------------------------------------------------------------------

module cfgmem_periph
#(
   parameter DEPTH = 16,
   parameter WIDTH = 1
 )
(
    input             clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input             rst_n,        // Reset_n - low to reset.
               
    output     [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                    // Note that uo_out[0] is normally used for UART TX.

    (* keep = "true" *)
    input     [5:0]   address,      // Address within this peripheral's address space
    (* keep = "true" *)
    input     [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    (* keep = "true" *)
    input     [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    (* keep = "true" *)
    input     [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    
    (* keep = "true" *)
    output wire[31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output            data_ready,

    output reg  [31:0]         cfgmem_data_out,
    output reg  [WIDTH-1:0]    cfgmem_we_lo,
    output reg  [WIDTH-1:0]    cfgmem_we_hi,
    output reg  [DEPTH-1:0]    cfgmem_wrow,
    output reg                 cfgmem_byp_lo,
    output reg                 cfgmem_byp_hi,
    output reg  [3:0]          cfgmem_addr,
    output reg                 cfgmem_addr_sel,
    input  wire [WIDTH*32-1:0] cfgmem_data_in_hi
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
    wire                 we_lo;
    wire                 we_hi;
    wire [WIDTH-1:0]     inst_vec;
//    wire [31:0]          rdata_lo[WIDTH-1:0];
    wire [31:0]          rdata_hi[WIDTH-1:0];

    // We always write to the cfgmem_data flops when we write to
    // any of the CFGMEM16 instnaces since the flops drive the
    // inputs to all of them for storage during shift load.
    assign we_lo          = address[5] == 1'b0 && data_write_n != 2'b11 && address[4:0] != 5'h1f;
    assign we_hi          = address[5] == 1'b1 && data_write_n != 2'b11 && address[4:0] != 5'h1f;
    assign load           = data_write_n != 2'b11 && address[5:0] != 6'h1f;
    assign uo_out         = 8'h0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_INST
            assign inst_vec[i] = address[4:0] == i * 4;
        end
    endgenerate

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            cfgmem_data_out <= 32'h0;
            cfgmem_we_lo    <= 'h0;
            cfgmem_we_hi    <= 'h0;
            cfgmem_addr     <= 4'h0;
            cfgmem_addr_sel <= 1'b0;
            cfgmem_byp_lo   <= 1'b0;
            cfgmem_byp_hi   <= 1'b0;
        end
        else
        begin
            // Save the input data since shift load takes time
            if (load)
                cfgmem_data_out <= data_in;

            // Control register (byte at 0x1f; 0x1f is not word aligned, so
            // the CPU can only reach it with 8-bit accesses):
            //   [3:0] row address  [4] address select  [5] busy (read only)
            //   [6] bypass lo      [7] bypass hi
            if (data_write_n != 2'b11 && address[5:0] == 6'h1f)
            begin
                cfgmem_addr     <= data_in[3:0];
                cfgmem_addr_sel <= data_in[4];
                cfgmem_byp_lo   <= data_in[6];
                cfgmem_byp_hi   <= data_in[7];
            end

            // Detect writes to LO CFGMEM16 instances
            if (we_lo && data_write_n != 2'b11)
                cfgmem_we_lo <= inst_vec;
            else if (state == IDLE)
                cfgmem_we_lo <= 'h0;

            // Detect writes to HI CFGMEM16 instances
            if (we_hi && data_write_n != 2'b11)
                cfgmem_we_hi <= inst_vec;
            else if (state == IDLE)
                cfgmem_we_hi <= 'h0;
        end
    end

    // Assign readback data
    assign data_ready = data_read_n != 2'b11;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_RDATA
//            assign rdata_lo[i] = cfgmem_data_in_lo[(i+1)*32-1 -: 32];
            assign rdata_hi[i] = cfgmem_data_in_hi[(i+1)*32-1 -: 32];
        end
    endgenerate

 //   wire [31:0] r_lo;
    wire [31:0] r_hi;

//    assign r_lo = rdata_lo[address[4:2]];
    assign r_hi = rdata_hi[address[4:2]];
    // Bit 5 of the control byte reads back the loader FSM busy flag so
    // firmware can pace back-to-back shift writes (each write takes DEPTH*3
    // clocks to walk the WROW pulses; a write issued while busy is dropped).
    assign data_out = address[5:0] == 6'h1F ? {24'h0, cfgmem_byp_hi, cfgmem_byp_lo, state != IDLE, cfgmem_addr_sel, cfgmem_addr} :
                                              r_hi;

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
   assign cfgmem_wrow = idx_decode & {DEPTH{latch_pulse}};
`elsif SCL_sky130_fd_sc_hd
    generate
      for (i = 0; i < DEPTH; i = i + 1)
      begin : AND_GEN
         /* verilator lint_off PINMISSING */
         // Instantiate AND gate for latch enable
         (* keep = 1 *) sky130_fd_sc_hd__and2_1 gate_and
                       (
                           .A ( idx_decode[i]  ),
                           .B ( latch_pulse    ),
                           .X ( cfgmem_wrow[i] )
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
                           .A ( idx_decode[i]  ),
                           .B ( latch_pulse    ),
                           .X ( cfgmem_wrow[i] )
                       );
         /* verilator lint_on PINMISSING */
      end
    endgenerate
`endif


endmodule

// vim: syntax=verilog sw=4 ts=4 et
