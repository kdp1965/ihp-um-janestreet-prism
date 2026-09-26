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
// is latch rows (see below), written two clocks after the push; `count`
// counts the byte on that clock, so a reader that waits for the count always
// finds it.
//
// Constant-table mode (tab_en, CONST_TAB in prism_periph.v): the head is
// row tab_idx instead of the read pointer's row, so the 16 rows serve as
// addressable constants for OUT_COMM_LOAD; pushes and flushes still work
// (that is how the host loads the table).
//
// The head mux is two stages (rows inside a group, then the group) with a
// kept boundary, see the read path at the end.

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
    reg  [AW:0]   wcount;                       // bytes written or on their way
    reg           push_d;                       // push whose row write lands this clock

    // The reader's flags follow `count`, which counts a byte only once its row
    // write has landed (a push takes two clocks, see the storage below); the
    // writer's flags follow `wcount`, which counts it as soon as it is pushed,
    // so a full FIFO can never be overrun by the byte still on its way.
    assign empty        = (count == 0);
    assign full         = wcount[AW];
    assign almost_empty = count <= {1'b0, ae_level};
    assign almost_full  = wcount >= ({1'b1, {AW{1'b0}}} - {1'b0, af_level});

    wire do_push = push & ~full;
    wire do_pop  = pop  & ~empty;

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            rd_ptr <= {AW{1'b0}};
            wr_ptr <= {AW{1'b0}};
            count  <= {(AW+1){1'b0}};
            wcount <= {(AW+1){1'b0}};
            push_d <= 1'b0;
        end
        else if (flush)
        begin
            rd_ptr <= {AW{1'b0}};
            wr_ptr <= {AW{1'b0}};
            count  <= {(AW+1){1'b0}};
            wcount <= {(AW+1){1'b0}};
            push_d <= 1'b0;
        end
        else
        begin
            push_d <= do_push;
            if (do_push)
                wr_ptr <= wr_ptr + 1'b1;
            if (do_pop)
                rd_ptr <= rd_ptr + 1'b1;
            // writer's view: the push counts at once (wr_ptr has moved on)
            case ({do_push, do_pop})
                2'b10:   wcount <= wcount + 1'b1;
                2'b01:   wcount <= wcount - 1'b1;
                default: wcount <= wcount;
            endcase
            // reader's view: the push counts one clock later, the clock the
            // row's gate opens and the byte appears on the head mux
            case ({push_d, do_pop})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    // Storage: latch rows (prism_latch_reg, 8 latches each) in two banks,
    // even rows and odd rows, sharing one registered write data bus and with
    // a row register and a one-clock strobe each.  A push loads that bus and
    // the bank of the row it goes to;
    // the strobe is then delayed one more clock (wst_p1) and drives the `wr`
    // input of the row's latch register, so the gate is the AND of a stable
    // row decode and a registered strobe and cannot be glitched open while
    // the bank's data bus moves.  The write lands on the second clock after
    // the push and the gate is open for that whole clock.
    //
    // The data bus must hold still from the push until that row's gate has
    // closed, which bounds the push rate: two pushes must be at least three
    // clocks apart.  The bus is shared, so this counts every push, not just
    // the ones to the same bank: a push one or two clocks after another would
    // move the bus before or as the first row's gate closes.  Nothing pushes
    // that fast (the FSM's OUT_FIFO_WR_RD and the host's register write are
    // both far slower), and the regression's FIFO monitor sees no two pushes
    // closer than that in any test.  One bus instead of two costs a bank's
    // worth of data flops (8 per FIFO) in the shard's densest area.
    //
    // The latch is transparent while written, so the head is available on the
    // clock the write lands, which is the clock `count` counts it.  Reset:
    // the row gates open with rst_n low and the data registers reset to 0.
    // Against 8 flops plus 8 write muxes per row this is about a third less
    // area and far fewer cells in the shard's densest area.
    reg  [7:0]    wq;                          // next write data, shared by both banks
    reg  [AW-2:0] wrow [0:1];                  // its row within the bank
    reg  [1:0]    wst;                         // one-clock write strobe per bank
    reg  [1:0]    wst_p1;                      // that strobe one clock later: the row gate
    wire [7:0]    mem_w [0:DEPTH-1];

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            wq      <= 8'h0;
            wrow[0] <= {(AW-1){1'b0}};
            wrow[1] <= {(AW-1){1'b0}};
            wst     <= 2'b00;
            wst_p1  <= 2'b00;
        end
        else
        begin
            wst       <= 2'b00;
            wst_p1[0] <= wst[0]; 
            wst_p1[1] <= wst[1]; 

            if (do_push)
            begin
                wq              <= push_data;
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
            wire gate = wrow[B] == RR;
            prism_latch_reg #( .WIDTH ( 8 ) ) i_row
            (
                .rst_n    ( rst_n     ),
                .enable   ( gate      ),
                .wr       ( wst_p1[B] ),
                .data_in  ( wq        ),
                .data_out ( mem_w[r]  )
            );
        end
    endgenerate

    // Read path: two mux stages with a kept boundary between them.  Left to
    // itself the synthesizer flattens the DEPTH:1 selection into one wide
    // AND-OR whose every latch output travels to a single point; on the
    // 64-byte FIFO that is 512 nets converging, and the tile's Metal3 could
    // not take it (run dma, 2026-09-23: GRT overflow 21k against 9k).  Stage
    // one picks a row inside each group of 2^GW rows, next to the rows;
    // stage two picks the group, so only 8 x NG nets leave the groups.
    localparam GW = AW / 2;                     // rows per group = 2^GW
    localparam NG = DEPTH >> GW;                // groups
    wire [AW-1:0]   sel = tab_en ? tab_idx : rd_ptr;
    (* keep *) wire [8*NG-1:0] grp_head;        // stage one: the selected row of each group

    genvar g, k;
    generate
        for (g = 0; g < NG; g = g + 1)
        begin : GRP
            wire [8*(1<<GW)-1:0] rows;
            for (k = 0; k < (1 << GW); k = k + 1)
            begin : RK
                assign rows[8*k +: 8] = mem_w[g*(1<<GW) + k];
            end
            assign grp_head[8*g +: 8] = rows[8*sel[GW-1:0] +: 8];
        end
    endgenerate

    assign head = grp_head[8*sel[AW-1:GW] +: 8];

endmodule
