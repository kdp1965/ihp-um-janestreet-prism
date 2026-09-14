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
// FIFO before starting the FSM); only reset and flush clear it.

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

    output wire  [7:0]   head,
    output reg   [AW:0]  count,
    output wire          empty,
    output wire          full,
    output wire          almost_empty,
    output wire          almost_full
);

    reg  [7:0]    mem [0:DEPTH-1];
    reg  [AW-1:0] rd_ptr;
    reg  [AW-1:0] wr_ptr;

    assign empty        = (count == 0);
    assign full         = count[AW];
    assign head         = mem[rd_ptr];
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

    // Storage.  Reset flops on purpose: the contents are don't-care until
    // written, but the reset flavour of the flop places and routes better
    // than a block of plain ones (observed on the tile).
    integer i;
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= 8'h0;
        end
        else if (do_push)
            mem[wr_ptr] <= push_data;
    end

endmodule
