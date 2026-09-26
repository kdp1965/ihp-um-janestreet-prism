// =======================================================
// PRISM RX DMA: drains a shard's receive FIFO into a ring of frame slots
// in PSRAM B through TinyQV's QSPI memory port, so the host never has to
// pop received bytes itself.
//
// Where it lives.  The engine sits next to TinyQV (project.v), not in the
// PRISM: its 32-bit data and 25-bit address buses and its registers stay
// local to the memory controller, and only a byte-serial tap crosses the
// tile to the PRISM (the FIFO head, five flags, a pop strobe and four mode
// bits).  A first version inside the PRISM put ~100 nets through the
// CFGMEM mouths and tripled the global-routing overflow (runs dma..dma3,
// 2026-09-23).
//
// Data path.  Bytes are popped from the tap one per clock into a word
// register; each full word is one 32-bit PSRAM write, and consecutive
// words stay inside one QSPI transaction (TinyQV's data_continue) while
// the FIFO already holds the next one (fifo_avail4), up to BURST_WORDS
// words and never across the PSRAM's 1 KB page.  A burst starts when the
// FIFO reaches its almost-full level (the shard's CFG1) or when a frame
// ends; a frame's last bytes (1-3) go out as byte writes.  TinyQV halts on
// its next memory access for the length of a burst.
//
// Ring.  RAM B holds 2^K slots of 2 KB from a 2 KB-aligned base.  Slot
// bytes 0-1 hold the frame length (bit 15: the frame did not fit and was
// cut at 2044 bytes), bytes 2-3 are zero, the frame starts at byte 4 so
// its words are word aligned.  The engine fills slot head; at the frame
// end it writes the length, advances head and raises its interrupt
// (TinyQV interrupt 10).  Software owns tail: a slot is free again once
// tail has passed it.  A frame that starts while the ring is full
// (head + 1 == tail) is consumed and dropped, with the overflow flag set.
//
// Frame end.  The receiving shard's OUT_HOST_INTERRUPT (the eth_rx chroma
// raises it after a frame's last byte), or a write of DMA_STATUS[31].
//
// DMA_CFG (0x8000020, word; writing enable = 0 resets the ring state)
//   [0]     enable            [1]  shard (0 = FIFO A, 1 = FIFO B)
//   [2]     interrupt enable  [3]  frame end = the shard's host interrupt
//   [6:4]   K: 2^K slots      [22:11] ring base in RAM B (2 KB units)
//   [7]     chain: FIFO A drains into FIFO B (shard select 1, frame end
//           from shard 0), see prism_periph.v
// DMA_STATUS (0x8000024, word)
//   read:  [7:0] head  [15:8] tail  [16] irq  [17] overflow  [18] busy
//          [19] dropping  [30:20] slot offset of the next byte (4 = empty)
//   write: [15:8] -> tail when [24]; [16] clears irq; [17] clears
//          overflow; [31] ends the current frame
// =======================================================
module prism_dma
#(
    parameter BURST_WORDS = 8               // words per burst: 32 bytes = 64 SPI clocks, well inside the PSRAM's CS-low limit
)
(
    input  wire         clk,
    input  wire         rst_n,

    // registers
    input  wire         cfg_wr,
    input  wire         st_wr,
    input  wire [31:0]  wdata,
    output wire [31:0]  cfg_rd,
    output wire [31:0]  st_rd,

    // the receive FIFO, byte-serial (prism_periph.v's tap)
    input  wire [7:0]   fifo_head,
    input  wire         fifo_empty,         // the FIFO being popped has nothing
    input  wire         fifo_drained,       // nothing anywhere (chain: both FIFOs and the mover)
    input  wire         fifo_avail4,        // at least four more bytes are coming
    input  wire         fifo_af,            // the FIFO reached its almost-full level
    input  wire         frame_end_pulse,    // the receiving shard's OUT_HOST_INTERRUPT rising
    output wire         fifo_pop,           // take fifo_head this clock
    output wire         enable,
    output wire         shard_sel,
    output wire         hw_end,             // the shard's host interrupt ends frames (and is not a host IRQ)
    output wire         chain,              // FIFO A drains into FIFO B (prism_periph.v does the moving)
    output reg          irq,

    // TinyQV memory port
    output wire         mem_req,
    output wire [24:0]  mem_addr,
    output wire [31:0]  mem_wdata,
    output wire [1:0]   mem_write_n,
    output wire         mem_continue,
    input  wire         mem_grant,
    input  wire         mem_ready
);

    localparam [10:0] FRAME_START = 11'd4;             // first frame byte of a slot
    localparam [10:0] LAST_WORD   = 11'd2044;          // highest offset a word may start at
    localparam [10:0] LAST_BYTE   = 11'd2047;          // highest offset a byte may take

    // ---- registers
    reg  [22:0] cfg;                                    // [22:11] base, [7:4] K / chain, [3:0] flags
    wire        cfg_en     = cfg[0];
    wire        cfg_irq_en = cfg[2];
    wire [2:0]  cfg_k      = cfg[6:4];
    wire [7:0]  slot_mask  = (8'd1 << cfg_k) - 8'd1;
    reg  [7:0]  head, tail;
    reg         ovf;
    reg  [10:0] offset;                                 // slot offset of the next byte to write
    reg         frame_pending;                          // a frame end waits to be flushed
    reg         dropping;                               // this frame is consumed, not written
    reg         trunc;                                  // this frame overflowed its slot
    reg  [3:0]  burst;                                  // words done in the open burst
    reg  [31:0] word;                                   // bytes assembled from the tap, byte k at [8k+7:8k]
    reg  [2:0]  nbytes;                                 // how many of them (0-4)

    assign enable    = cfg_en;
    assign shard_sel = cfg[1];
    assign hw_end    = cfg_en & cfg[3];
    assign chain     = cfg_en & cfg[7];
    assign cfg_rd    = {9'h0, cfg};

    // ---- state
    localparam [2:0] S_IDLE = 3'd0,                     // waiting for a trigger
                     S_WORD = 3'd1,                     // a word write is in flight
                     S_NEXT = 3'd2,                     // burst open, waiting for the next word
                     S_TAIL = 3'd3,                     // a byte write of the frame's tail is in flight
                     S_LEN  = 3'd4;                     // the length write is in flight
    reg [2:0] state;

    wire word_full = (nbytes == 3'd4);
    wire ring_full = ((head + 8'd1) & slot_mask) == (tail & slot_mask);
    wire fifo_done = fifo_drained & (nbytes == 3'd0);   // nothing left of this frame
    wire tail_left = fifo_drained & !word_full & (nbytes != 3'd0);
    wire at_start  = (offset == FRAME_START);
    wire room_word = (offset <= LAST_WORD);
    wire room_byte = (offset <= LAST_BYTE);
    wire page_end  = (offset[9:0] == 10'd1020);         // this word ends a 1 KB PSRAM page
    wire more      = fifo_avail4 & (burst != BURST_WORDS - 1) & !page_end & (offset <= LAST_WORD - 11'd4);
    wire go        = cfg_en & (frame_pending | (fifo_af & word_full));

    // the tap: one byte per clock while the word register has room and no
    // transfer is reading it (a dropped frame's bytes are popped the same
    // way and thrown away)
    assign fifo_pop = cfg_en & !fifo_empty & !word_full & (state != S_WORD) & (state != S_TAIL);

    wire [11:0] slot_hi = cfg[22:11] + {4'h0, head};
    assign mem_req      = (state != S_IDLE);
    assign mem_addr     = {2'b11, slot_hi, (state == S_LEN) ? 11'd0 : offset};   // 0x1800000 | base | slot | offset
    assign mem_wdata    = (state == S_LEN) ? {16'h0, trunc, 4'h0, offset - FRAME_START} : word;
    assign mem_write_n  = (state == S_WORD) ? 2'b10 :
                          (state == S_TAIL) ? 2'b00 :
                          (state == S_LEN)  ? 2'b01 : 2'b11;
    assign mem_continue = (state == S_WORD) & more;

    assign st_rd = {1'b0, offset, dropping, (state != S_IDLE), ovf, irq, tail, head};

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            cfg           <= 23'h0;
            head          <= 8'h0;
            tail          <= 8'h0;
            ovf           <= 1'b0;
            irq           <= 1'b0;
            offset        <= FRAME_START;
            frame_pending <= 1'b0;
            dropping      <= 1'b0;
            trunc         <= 1'b0;
            burst         <= 4'd0;
            word          <= 32'h0;
            nbytes        <= 3'd0;
            state         <= S_IDLE;
        end
        else
        begin
            if (cfg_wr)
            begin
                cfg <= wdata[22:0];
                if (!wdata[0])
                begin
                    head <= 8'h0; tail <= 8'h0; offset <= FRAME_START; nbytes <= 3'd0;
                    frame_pending <= 1'b0; dropping <= 1'b0; trunc <= 1'b0;
                end
            end
            if (st_wr)
            begin
                if (wdata[24]) tail <= wdata[15:8];
                if (wdata[16]) irq  <= 1'b0;
                if (wdata[17]) ovf  <= 1'b0;
            end
            if (cfg_en & ((cfg[3] & frame_end_pulse) | (st_wr & wdata[31])))
                frame_pending <= 1'b1;

            // the word register fills from the tap
            if (fifo_pop)
            begin
                case (nbytes[1:0])
                    2'd0: word[7:0]   <= fifo_head;
                    2'd1: word[15:8]  <= fifo_head;
                    2'd2: word[23:16] <= fifo_head;
                    2'd3: word[31:24] <= fifo_head;
                endcase
                nbytes <= nbytes + 3'd1;
            end

            case (state)
            S_IDLE:
                if (!cfg_en)
                    ;
                else if (dropping)
                begin
                    // consume the frame; a truncated one still gets its length
                    if (word_full)
                        nbytes <= 3'd0;
                    else if (frame_pending & tail_left)
                        nbytes <= 3'd0;
                    else if (frame_pending & fifo_done)
                    begin
                        if (trunc)
                            state <= S_LEN;
                        else
                        begin
                            frame_pending <= 1'b0; dropping <= 1'b0;
                        end
                    end
                end
                else if (go)
                begin
                    burst <= 4'd0;
                    if (at_start & ring_full)
                    begin
                        dropping <= 1'b1; ovf <= 1'b1;
                    end
                    else if (word_full)
                    begin
                        if (room_word)
                            state <= S_WORD;
                        else
                        begin
                            trunc <= 1'b1; dropping <= 1'b1;
                        end
                    end
                    else if (frame_pending & tail_left)
                    begin
                        if (room_byte)
                            state <= S_TAIL;
                        else
                        begin
                            trunc <= 1'b1; dropping <= 1'b1;
                        end
                    end
                    else if (frame_pending & fifo_done)
                        state <= S_LEN;
                end
            S_WORD:
                if (mem_ready)
                begin
                    offset <= offset + 11'd4;
                    burst  <= burst + 4'd1;
                    nbytes <= 3'd0;
                    state  <= more ? S_NEXT : S_IDLE;
                end
            S_NEXT:
                // the controller holds the transaction open until the next
                // word is presented (its bytes are in the FIFO already)
                if (word_full)
                    state <= S_WORD;
                else if (!cfg_en)
                    state <= S_IDLE;
            S_TAIL:
                if (mem_ready)
                begin
                    offset <= offset + 11'd1;
                    word   <= {8'h00, word[31:8]};
                    nbytes <= nbytes - 3'd1;
                    state  <= S_IDLE;
                end
            S_LEN:
                if (mem_ready)
                begin
                    head          <= (head + 8'd1) & slot_mask;
                    offset        <= FRAME_START;
                    frame_pending <= 1'b0;
                    dropping      <= 1'b0;
                    trunc         <= 1'b0;
                    if (cfg_irq_en) irq <= 1'b1;
                    state <= S_IDLE;
                end
            default:
                state <= S_IDLE;
            endcase
        end
    end

endmodule
