// Copyright (c) 2026 Ken Pettit
// SPDX-License-Identifier: Apache-2.0
//
// Small standard-cell byte FIFO for a PRISM shard (changes.md item 9).
//
// One FIFO per shard, direction chosen by CFG0 fifo_dir in prism_periph.v:
//   RX: the FSM pushes comm with OUT_FIFO_WR_RD, the host pops by reading
//       FIFO_DATA
//   TX: the host pushes by writing FIFO_DATA, the FSM pops into comm with
//       OUT_FIFO_WR_RD
// A push on a full FIFO and a pop on an empty one are ignored.  The head is
// available combinationally; count / empty / full / programmable
// almost-empty and almost-full levels feed the PRISM inputs and the status
// register.  Contents survive PRISM enable / disable (the host may fill a TX
// FIFO before starting the FSM); only reset and flush clear it.  The storage
// is latch rows (see below), written one clock after the push.
//
// Constant-table mode (tab_en, CONST_TAB in prism_periph.v): the head is
// row tab_idx instead of the read pointer's row, so the 16 rows serve as
// addressable constants for OUT_COMM_LOAD; pushes and flushes still work
// (that is how the host loads the table).

`default_nettype none

module prism_fifo
#(
    parameter DEPTH = 16,                       // power of two
    parameter AW    = 4                         // log2(DEPTH)
)
(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          flush,
    input  wire          push,
    input  wire  [7:0]   push_data,
    input  wire          pop,
    input  wire  [AW-1:0] ae_level,             // almost_empty when count <= ae_level
    input  wire  [AW-1:0] af_level,             // almost_full  when count >= DEPTH - af_level
    input  wire          tab_en,                // constant table: head = row tab_idx
    input  wire  [AW-1:0] tab_idx,

    output wire  [7:0]   head,
    output reg   [AW:0]  count,
    output wire          empty,
    output wire          full,
    output wire          almost_empty,
    output wire          almost_full
);

    reg  [AW-1:0] rd_ptr;
    reg  [AW-1:0] wr_ptr;

    assign empty        = (count == 0);
    assign full         = count[AW];
    assign almost_empty = count <= {1'b0, ae_level};
    assign almost_full  = count >= ({1'b1, {AW{1'b0}}} - {1'b0, af_level});

    wire do_push = push & ~full;
    wire do_pop  = pop  & ~empty;

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            rd_ptr <= {AW{1'b0}};
            wr_ptr <= {AW{1'b0}};
            count  <= {(AW+1){1'b0}};
        end
        else if (flush)
        begin
            rd_ptr <= {AW{1'b0}};
            wr_ptr <= {AW{1'b0}};
            count  <= {(AW+1){1'b0}};
        end
        else
        begin
            if (do_push)
                wr_ptr <= wr_ptr + 1'b1;
            if (do_pop)
                rd_ptr <= rd_ptr + 1'b1;
            case ({do_push, do_pop})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    // Storage: latch rows (prism_latch_reg, 8 latches each) in two banks,
    // even rows and odd rows, each bank with its own registered write data,
    // row and one-clock strobe.  A push loads the bank of the row it goes
    // to; the row's gate is open during the following clock while that
    // bank's data bus holds still, and since consecutive pushes hit rows of
    // opposite parity the bus of a bank never moves while one of its gates
    // is open or closing (the next push to the same bank is two clocks
    // later).  The latch is transparent while written, so the head is
    // available the clock after the push as with flops.  Reset: the row
    // gates open with rst_n low and the data registers reset to 0.
    // Against 8 flops plus 8 write muxes per row this is about a third less
    // area and far fewer cells in the shard's densest area.
    reg  [7:0]    wq   [0:1];                  // next write data per bank
    reg  [AW-2:0] wrow [0:1];                  // its row within the bank
    reg  [1:0]    wst;                         // one-clock write strobe per bank
    wire [7:0]    mem_w [0:DEPTH-1];

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            wq[0] <= 8'h0; wq[1] <= 8'h0;
            wrow[0] <= {(AW-1){1'b0}}; wrow[1] <= {(AW-1){1'b0}};
            wst   <= 2'b00;
        end
        else
        begin
            wst <= 2'b00;
            if (do_push)
            begin
                wq[wr_ptr[0]]   <= push_data;
                wrow[wr_ptr[0]] <= wr_ptr[AW-1:1];
                wst[wr_ptr[0]]  <= 1'b1;
            end
        end
    end

    genvar r;
    generate
        for (r = 0; r < DEPTH; r = r + 1)
        begin : ROW
            localparam B  = r % 2;
            localparam RR = r / 2;
            wire gate = wst[B] & (wrow[B] == RR);
            prism_latch_reg #( .WIDTH ( 8 ) ) i_row
            (
                .rst_n    ( rst_n     ),
                .enable   ( gate      ),
                .wr       ( 1'b1      ),
                .data_in  ( wq[B]     ),
                .data_out ( mem_w[r]  )
            );
        end
    endgenerate

    assign head = mem_w[tab_en ? tab_idx : rd_ptr];

endmodule
