// =======================================================
// PRISM TX DMA: copies frames from 2 KB slots of PSRAM B into FIFO B
// (shard 1's SRAM FIFO on SRAM[1]) through TinyQV's QSPI memory port, so
// the host hands transmit frames to the PRISM without pushing their bytes.
// FIFO B is the TX FIFO of the unfractured chromas (FIFO A receives), and
// either shard can run a fractured TX chroma, so the transmitter goes on
// shard 1 and the RX DMA drains FIFO A.
//
// Where it lives.  Next to TinyQV and the RX DMA (project.v); only a
// byte-serial tap crosses the tile to the PRISM: the byte and a push
// strobe, and a room flag back; the TX ring adds a start strobe (toggles
// shard 1's host_in[0]) and shard 1's end-of-frame pulse.  project.v
// arbitrates the memory port between the two DMAs, RX first.
//
// Data path.  32-bit reads in bursts of up to BURST_WORDS words inside one
// QSPI transaction (TinyQV's data_continue), never across the PSRAM's 1 KB
// page.  A burst starts only while the FIFO has room for all of it
// (fifo_room: at least 32 free bytes), so the push side never holds the
// transaction open; the port is released between bursts, which lets the
// CPU and the RX DMA in and keeps the PSRAM's CS-low time short.  The
// bytes of a word go into the FIFO one per clock (the SRAM FIFO takes a
// push every clock; the next word takes at least eight clocks to arrive,
// so the word register is always empty again by then).
//
// One copy (TXDMA): the host starts a copy of a slot and starts the chroma
// itself.
//
// TXDMA (0x8000028, word)
//   write: [11:0]  frame length in bytes (0 - 2048)
//          [23:12] slot: RAM B address 0x1800000 + slot * 2048
//          [24]    skip the slot header: the frame starts at slot byte 4 (the
//                  RX DMA's slot format, so a received frame can go back out
//                  as it is; at most 2044 bytes then)
//          [25]    interrupt enable (TinyQV interrupt 11 while done)
//          [30]    acknowledge: clear done
//          [31]    start a copy with these settings (ignored while busy or
//                  while the TX ring is on)
//   read:  [11:0]  bytes still to push  [23:12] slot  [24] skip  [25] irq en
//          [30]    done  [31] busy
//
// TX ring (TXRING_*): frames one after another with no host work per
// frame, for a chroma that ends its frame when FIFO B runs empty and raises
// its host interrupt then (eth_tx).  The ring is 2^K 2 KB slots of RAM B
// in the RX DMA's slot format: word 0 holds the byte count L ([10:0], at
// most 2044) and the engine sends the L bytes from slot byte 4.  For
// eth_tx those are word 1 = 55 55 55 D5 (the chroma sends four preamble
// bytes from its K0 and pops the rest and the SFD) and the frame from byte
// 8, without its FCS: L = frame + 4.  A slot the RX DMA filled has the
// frame at byte 8 too and L = frame + FCS = frame + 4, so writing
// 55 55 55 D5 into its spare word 1 is all it takes to send it again (the
// received FCS stays behind; eth_tx appends a new one).  For each slot from
// tail to head the engine reads the slot's L, copies, and starts the
// chroma by toggling shard 1's host_in[0] once the inter-frame gap since
// the previous frame's end has passed and START_WORDS words (or all of
// them) are in.  The chroma's host interrupt then ends the frame: it
// does not reach the host (the ring takes it, as the RX DMA's hw_end does),
// tail advances, the frame-sent flag rises (interrupt 11 when enabled), the
// gap starts and the next frame is copied at once; FIFO B holds one frame
// at a time because the chroma ends a frame on an empty FIFO.
//
// TXRING_CFG (0x800002C, word, read / write)
//   [0]     enable (writing 0 resets head, tail and the frame-sent flag; a
//           copy under way still finishes, so flush FIFO B after it)
//   [3:1]   K: 2^K slots, K = 1..4 (head == tail means empty)
//   [6]     interrupt enable: TinyQV interrupt 11 while the frame-sent flag is set
//   [17:8]  inter-frame gap: clocks from a frame's end to the next start
//   [27:20] ring base in RAM B, 2 KB units: slot i at 0x1800000 + (base + i) * 2048
// TXRING_STATUS (0x8000034, word)
//   write: [3:0] -> head when [24] (the host fills slot head, then advances it)
//          [16] clears the frame-sent flag
//   read:  [3:0] head  [11:8] tail  [16] frame sent  [17] a frame is on its way
// =======================================================
module prism_txdma
#(
    parameter BURST_WORDS = 8,              // words per burst: 32 bytes = 64 SPI clocks, well inside the PSRAM's CS-low limit
    parameter START_WORDS = 16              // ring: the chroma starts once this many frame words are read (or the frame is in)
)
(
    input  wire         clk,
    input  wire         rst_n,

    // registers
    input  wire         reg_wr,             // TXDMA
    input  wire         ring_cfg_wr,        // TXRING_CFG
    input  wire         ring_st_wr,         // TXRING_STATUS
    input  wire [31:0]  wdata,
    output wire [31:0]  rd,
    output wire [31:0]  ring_cfg_rd,
    output wire [31:0]  ring_st_rd,
    output wire         irq,

    // FIFO B, byte-serial (prism_periph.v's tap)
    output wire [7:0]   fifo_data,
    output wire         fifo_push,
    input  wire         fifo_room,          // room for a burst

    // the chroma on shard 1 (TX ring)
    output wire         ring_on,            // the ring takes shard 1's host interrupt
    output reg          chroma_start,       // toggle shard 1's host_in[0]
    input  wire         frame_end,          // shard 1's host interrupt: its frame is out

    // TinyQV memory port (through project.v's arbiter)
    output wire         mem_req,
    output wire [24:0]  mem_addr,
    output wire [1:0]   mem_read_n,
    output wire         mem_continue,
    input  wire         mem_ready,
    input  wire [31:0]  mem_rdata
);

    localparam [2:0] LAST_WORD = BURST_WORDS - 1;       // burst index of a burst's last word

    // ---- the copy engine (one copy, or a ring frame)
    reg  [11:0] slot;
    reg         skip;
    reg         irq_en;
    reg  [11:0] left;                                   // bytes still to push
    reg  [9:0]  words;                                  // words still to read
    reg  [8:0]  woff;                                   // word offset in the slot of the next read
    reg  [2:0]  burst;                                  // words read in the open burst
    reg  [31:0] word;                                   // the word being pushed, next byte at [7:0]
    reg  [2:0]  nbytes;                                 // bytes of it still to push (0-4)
    reg         busy;
    reg         reading;                                // a burst holds the port
    reg         done;
    reg         ring_copy;                              // the copy in progress is a ring frame

    // ---- the TX ring
    reg         r_en;
    reg  [2:0]  r_k;
    reg         r_irq_en;
    reg  [9:0]  r_ifg;
    reg  [7:0]  r_base;
    reg  [3:0]  head, tail;
    reg         r_irq;                                  // a frame was sent
    reg  [9:0]  ifg_cnt;                                // gap still to wait
    reg  [1:0]  r_state;
    localparam [1:0] R_IDLE = 2'd0,                     // waiting for a slot and the engine
                     R_HDR  = 2'd1,                     // reading the slot's length
                     R_COPY = 2'd2,                     // copying; the chroma starts when it may
                     R_SEND = 2'd3;                     // the chroma sends; waiting for its end
    wire [4:0]  r_span    = (5'd1 << r_k) - 5'd1;       // K > 4 acts as 4
    wire [3:0]  r_mask    = r_span[3:0];
    wire        r_pending = ((head ^ tail) & r_mask) != 4'd0;
    wire        hdr_req   = (r_state == R_HDR);
    wire        r_ready   = !busy | (woff > START_WORDS);  // the frame is in, or START_WORDS words of it

    // the slot's byte count, capped at what the slot holds from byte 4
    wire [10:0] hdr_n     = (mem_rdata[10:0] > 11'd2044) ? 11'd2044 : mem_rdata[10:0];

    // another word follows in this burst: there is one, the burst has room
    // and this word does not end a 1 KB page (256 words)
    wire more = (words != 10'd1) & (burst != LAST_WORD) & (woff[7:0] != 8'hFF);

    assign mem_req      = reading | hdr_req;
    assign mem_addr     = {2'b11, slot, hdr_req ? 9'h0 : woff, 2'b00};   // 0x1800000 | slot * 2048 | offset
    assign mem_read_n   = mem_req ? 2'b10 : 2'b11;
    assign mem_continue = reading & more;

    assign fifo_data = word[7:0];
    assign fifo_push = (nbytes != 3'd0);
    assign irq       = (done & irq_en) | (r_irq & r_irq_en);
    assign ring_on   = r_en;
    assign rd          = {busy, done, 4'h0, irq_en, skip, slot, left};
    assign ring_cfg_rd = {4'h0, r_base, 2'b00, r_ifg, 1'b0, r_irq_en, 2'b00, r_k, r_en};
    assign ring_st_rd  = {14'h0, (r_state != R_IDLE), r_irq, 4'h0, tail, 4'h0, head};

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            slot         <= 12'h0;
            skip         <= 1'b0;
            irq_en       <= 1'b0;
            left         <= 12'h0;
            words        <= 10'h0;
            woff         <= 9'h0;
            burst        <= 3'd0;
            word         <= 32'h0;
            nbytes       <= 3'd0;
            busy         <= 1'b0;
            reading      <= 1'b0;
            done         <= 1'b0;
            ring_copy    <= 1'b0;
            r_en         <= 1'b0;
            r_k          <= 3'd0;
            r_irq_en     <= 1'b0;
            r_ifg        <= 10'h0;
            r_base       <= 8'h0;
            head         <= 4'h0;
            tail         <= 4'h0;
            r_irq        <= 1'b0;
            ifg_cnt      <= 10'h0;
            r_state      <= R_IDLE;
            chroma_start <= 1'b0;
        end
        else
        begin
            chroma_start <= 1'b0;

            // ---- registers
            if (reg_wr & wdata[30])
                done <= 1'b0;
            if (reg_wr & wdata[31] & !busy & !r_en)
            begin
                slot      <= wdata[23:12];
                skip      <= wdata[24];
                irq_en    <= wdata[25];
                left      <= wdata[11:0];
                words     <= wdata[11:2] + {9'h0, |wdata[1:0]};
                woff      <= {8'h0, wdata[24]};
                busy      <= 1'b1;
                done      <= 1'b0;
                ring_copy <= 1'b0;
            end
            if (ring_st_wr)
            begin
                if (wdata[24]) head  <= wdata[3:0];
                if (wdata[16]) r_irq <= 1'b0;
            end

            // ---- the tap: one byte per clock
            if (nbytes != 3'd0)
            begin
                word   <= {8'h00, word[31:8]};
                nbytes <= nbytes - 3'd1;
                left   <= left - 12'd1;
            end

            // ---- the copy engine
            if (reading)
            begin
                if (mem_ready)
                begin
                    // the word register is empty by now (see the header)
                    word    <= mem_rdata;
                    nbytes  <= (left > 12'd4) ? 3'd4 : left[2:0];
                    woff    <= woff + 9'd1;
                    words   <= words - 10'd1;
                    burst   <= burst + 3'd1;
                    reading <= more;
                end
            end
            else if (busy)
            begin
                if (words == 10'd0)
                begin
                    if (nbytes == 3'd0)
                    begin
                        busy      <= 1'b0;
                        ring_copy <= 1'b0;
                        if (!ring_copy)
                            done  <= 1'b1;
                    end
                end
                else if ((nbytes == 3'd0) & fifo_room)
                begin
                    reading <= 1'b1;
                    burst   <= 3'd0;
                end
            end

            // ---- the TX ring
            if (ifg_cnt != 10'h0)
                ifg_cnt <= ifg_cnt - 10'd1;
            case (r_state)
            R_IDLE:
                if (r_en & r_pending & !busy)
                begin
                    slot    <= {4'h0, r_base} + {8'h0, tail & r_mask};
                    r_state <= R_HDR;
                end
            R_HDR:
                if (mem_ready)
                begin
                    // start the copy of the slot's bytes from byte 4
                    left      <= {1'b0, hdr_n};
                    words     <= {1'b0, hdr_n[10:2]} + {9'h0, |hdr_n[1:0]};
                    woff      <= 9'd1;
                    busy      <= 1'b1;
                    ring_copy <= 1'b1;
                    r_state   <= R_COPY;
                end
            R_COPY:
                if ((ifg_cnt == 10'h0) & r_ready)
                begin
                    chroma_start <= 1'b1;
                    r_state      <= R_SEND;
                end
            R_SEND:
                if (frame_end)
                begin
                    tail    <= (tail + 4'd1) & r_mask;
                    r_irq   <= 1'b1;
                    ifg_cnt <= r_ifg;
                    r_state <= R_IDLE;
                end
            endcase

            if (ring_cfg_wr)
            begin
                r_en     <= wdata[0];
                r_k      <= wdata[3:1];
                r_irq_en <= wdata[6];
                r_ifg    <= wdata[17:8];
                r_base   <= wdata[27:20];
                if (!wdata[0])
                begin
                    head    <= 4'h0;
                    tail    <= 4'h0;
                    r_irq   <= 1'b0;
                    ifg_cnt <= 10'h0;
                    r_state <= R_IDLE;
                end
            end
        end
    end

endmodule
