// =======================================================
// PRISM TX DMA: copies one frame from a 2 KB slot of PSRAM B into FIFO B
// (shard 1's SRAM FIFO on SRAM[1]) through TinyQV's QSPI memory port, so
// the host hands a transmit frame to the PRISM without pushing its bytes.
// FIFO B is the TX FIFO of the unfractured chromas (FIFO A receives), and
// either shard can run a fractured TX chroma, so the transmitter goes on
// shard 1 and the RX DMA drains FIFO A.
//
// Where it lives.  Next to TinyQV and the RX DMA (project.v); only a
// byte-serial tap crosses the tile to the PRISM: the byte and a push
// strobe, and a room flag back.  project.v arbitrates the memory port
// between the two DMAs, RX first.
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
// TXDMA (0x8000028, word)
//   write: [11:0]  frame length in bytes (0 - 2048)
//          [23:12] slot: RAM B address 0x1800000 + slot * 2048
//          [24]    skip the slot header: the frame starts at slot byte 4 (the
//                  RX DMA's slot format, so a received frame can go back out
//                  as it is; at most 2044 bytes then)
//          [25]    interrupt enable (TinyQV interrupt 11 while done)
//          [30]    acknowledge: clear done
//          [31]    start a copy with these settings (ignored while busy)
//   read:  [11:0]  bytes still to push  [23:12] slot  [24] skip  [25] irq en
//          [30]    done  [31] busy
// =======================================================
module prism_txdma
#(
    parameter BURST_WORDS = 8               // words per burst: 32 bytes = 64 SPI clocks, well inside the PSRAM's CS-low limit
)
(
    input  wire         clk,
    input  wire         rst_n,

    // register
    input  wire         reg_wr,
    input  wire [31:0]  wdata,
    output wire [31:0]  rd,
    output wire         irq,

    // FIFO B, byte-serial (prism_periph.v's tap)
    output wire [7:0]   fifo_data,
    output wire         fifo_push,
    input  wire         fifo_room,          // room for a burst

    // TinyQV memory port (through project.v's arbiter)
    output wire         mem_req,
    output wire [24:0]  mem_addr,
    output wire [1:0]   mem_read_n,
    output wire         mem_continue,
    input  wire         mem_ready,
    input  wire [31:0]  mem_rdata
);

    localparam [2:0] LAST_WORD = BURST_WORDS - 1;       // burst index of a burst's last word

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

    // another word follows in this burst: there is one, the burst has room
    // and this word does not end a 1 KB page (256 words)
    wire more = (words != 10'd1) & (burst != LAST_WORD) & (woff[7:0] != 8'hFF);

    assign mem_req      = reading;
    assign mem_addr     = {2'b11, slot, woff, 2'b00};   // 0x1800000 | slot * 2048 | offset
    assign mem_read_n   = reading ? 2'b10 : 2'b11;
    assign mem_continue = reading & more;

    assign fifo_data = word[7:0];
    assign fifo_push = (nbytes != 3'd0);
    assign irq       = done & irq_en;
    assign rd        = {busy, done, 4'h0, irq_en, skip, slot, left};

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            slot    <= 12'h0;
            skip    <= 1'b0;
            irq_en  <= 1'b0;
            left    <= 12'h0;
            words   <= 10'h0;
            woff    <= 9'h0;
            burst   <= 3'd0;
            word    <= 32'h0;
            nbytes  <= 3'd0;
            busy    <= 1'b0;
            reading <= 1'b0;
            done    <= 1'b0;
        end
        else
        begin
            if (reg_wr & wdata[30])
                done <= 1'b0;
            if (reg_wr & wdata[31] & !busy)
            begin
                slot   <= wdata[23:12];
                skip   <= wdata[24];
                irq_en <= wdata[25];
                left   <= wdata[11:0];
                words  <= wdata[11:2] + {9'h0, |wdata[1:0]};
                woff   <= {8'h0, wdata[24]};
                busy   <= 1'b1;
                done   <= 1'b0;
            end

            // the tap: one byte per clock
            if (nbytes != 3'd0)
            begin
                word   <= {8'h00, word[31:8]};
                nbytes <= nbytes - 3'd1;
                left   <= left - 12'd1;
            end

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
                        busy <= 1'b0;
                        done <= 1'b1;
                    end
                end
                else if ((nbytes == 3'd0) & fifo_room)
                begin
                    reading <= 1'b1;
                    burst   <= 3'd0;
                end
            end
        end
    end

endmodule
