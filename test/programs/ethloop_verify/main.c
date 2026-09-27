/*
 * ethloop_verify: RISC-V driven 10BASE-T loopback from PSRAM to PSRAM.
 *
 *   RAM B slot -> TX DMA -> FIFO B (SRAM[1]) -> eth_tx on shard 1 ->
 *   TXD / TX_EN (uo_out[1] / uo_out[2]) -> the bench's wire -> ui_in[3] ->
 *   Manchester recoverer (CFG3) -> eth_rx on shard 0 -> FIFO A (the 16-byte
 *   flop FIFO) -> RX DMA -> RX ring slot in RAM B
 *
 * Both chromas run fractured: eth_rx in bank A (shard 0), eth_tx in bank B
 * (shard 1).  The RX DMA ends each frame on eth_rx's host interrupt (DMA_CFG
 * hw_end: no bit for two bit times) and writes it to a two-slot ring at the
 * bottom of RAM B, the frame from slot byte 4 and its length (FCS included)
 * in bytes 0-1; the TX sources are RAM B slots 2 and 3, 55 55 55 D5 in bytes
 * 0-3 and the frame from byte 4 (see ethtx_verify).  RX uses the flop FIFO:
 * with the RX DMA bursting from 8 bytes it closes every frame within a few
 * hundred clocks, long before the next frame (an SRAM FIFO would not, see
 * the frame-boundary note in docs 4y.1).
 *
 * The program compares every received frame with its source slot word by
 * word and checks eth_rx's crc_ok (FLAGS[10]: the CRC32 residue over frame
 * and FCS).  test_ethloop_verify.py closes the wire (TXD while TX_EN, else
 * low, onto ui_in[3]) and also decodes the line to cross-check the frames.
 *
 *   1. a minimum frame (60 bytes)            slot 2 -> ring slot 0
 *   2. an odd length (101 bytes)             slot 3 -> ring slot 1
 *   3. a maximum frame (1514 bytes), started while the TX DMA is still
 *      copying it, so both DMAs run while it is on the wire
 *                                            slot 2 -> ring slot 0
 *   4. echo: ring slot 0 sent again as it is, word 0 rewritten to
 *      55 55 55 D5 and the length field as the copy length (the FCS stays
 *      behind; eth_tx appends a new one)    ring slot 0 -> ring slot 1
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
/* csr.h (no include guard) comes in via tqv_prism.h */
#include "tqv_prism.h"

extern const uint32_t chroma_eth_tx[];
extern const uint32_t chroma_eth_tx_ctrlReg;
extern const uint32_t chroma_eth_tx_pinmuxReg;
extern const uint32_t chroma_eth_rx[];
extern const uint32_t chroma_eth_rx_ctrlReg;
extern const uint32_t chroma_eth_rx_pinmuxReg;

/* TX DMA (see txdma_verify) */
#define TXDMA_REG               (*(volatile uint32_t *)0x8000028u)
#define TXDMA_LEN(n)            ((n) & 0xfffu)
#define TXDMA_SLOT(s)           (((s) & 0xfffu) << 12)
#define TXDMA_ACK               (1u << 30)
#define TXDMA_START             (1u << 31)
#define TXDMA_ST_DONE           (1u << 30)
#define TXDMA_ST_BUSY           (1u << 31)
#define TXDMA_ST_LEFT(v)        ((v) & 0xfffu)

/* RX DMA (see dma_verify) */
#define DMA_CFG_REG             (*(volatile uint32_t *)0x8000020u)
#define DMA_STATUS_REG          (*(volatile uint32_t *)0x8000024u)
#define DMA_EN                  (1u << 0)
#define DMA_IRQ_EN              (1u << 2)
#define DMA_HW_END              (1u << 3)
#define DMA_K(k)                (((k) & 7u) << 4)
#define DMA_ST_IRQ              (1u << 16)
#define DMA_ST_OVF              (1u << 17)
#define DMA_ST_SET_TAIL         (1u << 24)
#define DMA_ST_HEAD(v)          ((v) & 0xffu)
#define DMA_LEN_TRUNC           (1u << 15)

#define RAM_B                   ((volatile uint8_t *)0x1800000u)
#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define DMA_SLOT                2048u
#define SLOT_WORDS              (DMA_SLOT / 4)
#define SRC_A                   2u              /* TX source slots; the ring is slots 0 and 1 */
#define SRC_B                   3u

#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_CFG_FIFO_SRAM     (1u << 31)
#define FIFO_COUNT(v)           (((v) >> 8) & 0x3fffu)
#define FLAG_CRC_OK             (1u << 10)

#define BIT_CLOCKS              6u              /* both chromas: 3 clocks per half bit */
#define RXD_PIN                 3u              /* ui_in[3]: the bench's wire */
#define RX_AF_LEVEL             8u              /* FIFO A almost full at 16 - 8 = 8 bytes: RX DMA burst */
#define ETH_PREAMBLE_TAIL       0xD5555555u     /* 55 55 55 D5 */
#define STREAM_START            64u
#define CRC32_RESIDUE           0xDEBB20E3u

#define POLL_LIMIT              400000u
#define MAX_MISMATCH_LINES      6

static uint32_t pass_count;
static uint32_t fail_count;

/* ------------------------------------------------------------------ */
/* Debug UART output helpers (no printf: keeps the image and sim small) */

static void dputs(const char *s)
{
    while (*s)
        debug_uart_putc(*s++);
}

static void dnl(void)
{
    debug_uart_putc('\n');
}

static void dput_hex(uint32_t v, int digits)
{
    static const char hex[] = "0123456789ABCDEF";
    for (int d = digits - 1; d >= 0; d--)
        debug_uart_putc(hex[(v >> (d * 4)) & 0xf]);
}

static void dput_dec(uint32_t v)
{
    char buf[11];
    int  n = 0;
    do {
        uint32_t q = 0, r = v;
        while (r >= 10) { r -= 10; q++; }
        buf[n++] = '0' + r;
        v = q;
    } while (v);
    while (n)
        debug_uart_putc(buf[--n]);
}

static void check(const char *name, bool ok, uint32_t value)
{
    dputs(name);
    dputs(ok ? ": PASS " : ": FAIL ");
    dput_hex(value, 8);
    dnl();
    if (ok) pass_count++; else fail_count++;
}

/* ------------------------------------------------------------------ */

/* Frame byte i (no FCS): as ethtx_verify, test_ethloop_verify.py builds the same */
static uint8_t eth_byte(uint32_t seed, uint32_t i)
{
    if (i < 6)
        return 0xFF;
    if (i < 12)
        return (i == 6) ? 0x02 : (i == 11) ? (uint8_t)seed : 0x00;
    if (i < 14)
        return (i == 12) ? 0x88 : 0xB5;
    return (uint8_t)(seed + i * 13u + (i >> 4));
}

static void fill_frame(uint32_t slot, uint32_t n, uint32_t seed)
{
    volatile uint32_t *w = RAM_B32 + slot * SLOT_WORDS;

    w[0] = ETH_PREAMBLE_TAIL;
    for (uint32_t i = 0; i < n; i += 4)
        w[1 + i / 4] = eth_byte(seed, i) | ((uint32_t)eth_byte(seed, i + 1) << 8) |
                       ((uint32_t)eth_byte(seed, i + 2) << 16) | ((uint32_t)eth_byte(seed, i + 3) << 24);
}

static void announce(uint32_t n, uint32_t seed)
{
    dputs("ETH FRAME len=");
    dput_dec(n);
    dputs(" seed=");
    dput_hex(seed, 2);
    dnl();
}

static uint32_t tx_wait(void)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = TXDMA_REG;
        if (!(st & TXDMA_ST_BUSY))
            return st;
    }
    return 0;
}

static bool wait_fifo_b(uint32_t n)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++)
        if (FIFO_COUNT(prism_read(SH1(PRISM_SH_FIFO_STATUS))) >= n)
            return true;
    return false;
}

/* eth_tx's end-of-frame interrupt (shard 1), cleared; false on a timeout */
static bool tx_sent(void)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        if (prism_read(PRISM_REG_CTRL) & PRISM_CTRL_IRQ1) {
            prism_write_byte(PRISM_REG_INT_CLR1, 0x80);
            return true;
        }
    }
    return false;
}

/* The RX DMA's frame interrupt: its status, 0 on a timeout */
static uint32_t rx_landed(void)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = DMA_STATUS_REG;
        if (st & DMA_ST_IRQ)
            return st;
    }
    return 0;
}

/* Send n frame bytes from slot `src` (55 55 55 D5 in front of them): copy,
   start (whole or once STREAM_START bytes are in), wait for the frame to
   leave and for the RX DMA to land it; the RX DMA status, 0 on a failure */
static uint32_t loop_frame(const char *name, uint32_t src, uint32_t n, bool stream)
{
    uint32_t st, left = 0;
    bool started;

    TXDMA_REG = TXDMA_START | TXDMA_SLOT(src) | TXDMA_LEN(4 + n);
    if (stream) {
        started = wait_fifo_b(STREAM_START);
        prism_write_byte(SH1(PRISM_SH_TOGGLE), 0);
        left = TXDMA_ST_LEFT(TXDMA_REG);
        st = tx_wait();
    } else {
        st = tx_wait();
        started = true;
        prism_write_byte(SH1(PRISM_SH_TOGGLE), 0);
    }
    TXDMA_REG = TXDMA_ACK;
    bool sent = tx_sent();
    uint32_t rx = rx_landed();
    dputs(name);
    check(stream ? " sent while copying" : " sent", started && sent && (st & TXDMA_ST_DONE) &&
          (!stream || left > 256), stream ? left : st);
    dputs(name);
    check(" received", rx != 0 && !(rx & DMA_ST_OVF), rx);
    DMA_STATUS_REG = DMA_ST_IRQ;
    return rx;
}

/* Compare ring slot `slot` with the n frame bytes at byte 4 of slot `src`
   (words, then the tail) and check its length field and eth_rx's crc_ok */
static void check_ring(const char *name, uint32_t slot, uint32_t src, uint32_t n)
{
    volatile uint32_t *r = RAM_B32 + slot * SLOT_WORDS;
    volatile uint32_t *s = RAM_B32 + src * SLOT_WORDS;
    uint32_t len = r[0] & 0xffffu;
    uint32_t flags = prism_read(PRISM_REG_FLAGS);
    uint32_t errors = 0, lines = 0;

    dputs(name);
    check(" length (frame + FCS)", len == n + 4, len);
    dputs(name);
    check(" crc_ok", (flags & FLAG_CRC_OK) != 0, prism_read(PRISM_REG_CRC));
    for (uint32_t w = 1; w <= n / 4; w++) {
        if (r[w] != s[w]) {
            errors++;
            if (lines++ < MAX_MISMATCH_LINES) {
                dputs("  MISMATCH word=");
                dput_dec(w);
                dputs(" exp=");
                dput_hex(s[w], 8);
                dputs(" got=");
                dput_hex(r[w], 8);
                dnl();
            }
        }
    }
    for (uint32_t i = n & ~3u; i < n; i++)
        if (RAM_B[slot * DMA_SLOT + 4 + i] != RAM_B[src * DMA_SLOT + 4 + i])
            errors++;
    dputs(name);
    check(" matches its source", errors == 0, errors);
}

static uint32_t eth_setup(void)
{
    uint32_t errors;

    prism_write(PRISM_REG_CTRL, 0);
    errors = prism_load_banks(chroma_eth_rx + PRISM_BANK_STATES * PRISM_STEW_WORDS,
                              chroma_eth_tx + PRISM_BANK_STATES * PRISM_STEW_WORDS);
    prism_write(PRISM_REG_FRAC_CFG, 1);
    prism_write(PRISM_REG_OUT_MASK0, 0x1FFFFF);
    prism_write(PRISM_REG_COND_MASK0, 0x3);
    prism_write(PRISM_REG_OUT_MASK1, 0x1FFFFF);
    prism_write(PRISM_REG_COND_MASK1, 0x3);

    /* shard 0: eth_rx on the flop FIFO A, bits from the recoverer on ui_in[3] */
    prism_write(PRISM_REG_CFG0, chroma_eth_rx_ctrlReg);
    prism_write(PRISM_REG_PINMUX, chroma_eth_rx_pinmuxReg);
    prism_write(PRISM_REG_CFG1, RX_AF_LEVEL << 20);
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CFG2, 15u | (12u << 4) | (11u << 8));  /* 16 <- bit valid, 17/18 <- comm[7]/[6] */
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CFG3,
                RXD_PIN | (1u << 3) | ((BIT_CLOCKS / 2) << 4) | (1u << 8));        /* recoverer on, shifter from it */
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CONST, 0);                             /* K0 = 0 clears comm */
    prism_write_byte(PRISM_REG_COMPARE, 8);                                           /* count2: eight bits */
    prism_write(PRISM_REG_PRELOAD, 2 * BIT_CLOCKS);                                   /* idle timer: two bit times */
    prism_write(PRISM_REG_CRC_POLY, 0xEDB88320u);
    prism_write(PRISM_REG_CRC_EXPECTED, CRC32_RESIDUE);
    prism_write(PRISM_REG_FIFO_STATUS, 0);

    /* shard 1: eth_tx on FIFO B = SRAM[1] (see ethtx_verify) */
    prism_write(SH1(PRISM_SH_CFG0), chroma_eth_tx_ctrlReg | PRISM_CFG_FIFO_SRAM);
    prism_write(SH1(PRISM_SH_PINMUX), chroma_eth_tx_pinmuxReg);
    prism_write(SH1(PRISM_SH_CFG1), 8u | (9u << 4));
    prism_write(SH1(PRISM_SH_CONST), 0x55);
    prism_write_byte(SH1(PRISM_SH_COMPARE), 3);
    prism_write(SH1(PRISM_SH_PRELOAD), BIT_CLOCKS / 2 - 1);
    prism_write(SH1(PRISM_SH_CRC_POLY), 0xEDB88320u);
    prism_write(SH1(PRISM_SH_PRELOAD2), 0);
    prism_write_byte(SH1(PRISM_SH_HOST), 0);
    prism_write(SH1(PRISM_SH_FIFO_STATUS), 0);

    /* RX DMA: FIFO A, a two-slot ring at the bottom of RAM B, frames ended
       by eth_rx's host interrupt */
    DMA_CFG_REG = DMA_EN | DMA_IRQ_EN | DMA_HW_END | DMA_K(1);

    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    prism_claim_pins((1u << 1) | (1u << 2));                                          /* TXD, TX_EN */
    return errors;
}

int main(void)
{
    uint32_t st, v, len;

    dputs("ETHLOOP_VERIFY START");
    dnl();

    v = eth_setup();
    check("eth_rx in bank A, eth_tx in bank B", v == 0, v);
    dputs("ETH READY");
    dnl();

    /* 1. a minimum frame -> ring slot 0 */
    fill_frame(SRC_A, 60, 0x11);
    announce(60, 0x11);
    st = loop_frame("frame 1 (60 bytes)", SRC_A, 60, false);
    check("frame 1 in ring slot 0", DMA_ST_HEAD(st) == 1, st);
    check_ring("frame 1", 0, SRC_A, 60);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (1u << 8);                   /* slot 0 consumed */

    /* 2. an odd length -> ring slot 1 */
    fill_frame(SRC_B, 101, 0x22);
    announce(101, 0x22);
    st = loop_frame("frame 2 (101 bytes)", SRC_B, 101, false);
    check("frame 2 in ring slot 1", DMA_ST_HEAD(st) == 0, st);
    check_ring("frame 2", 1, SRC_B, 101);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (0u << 8);                   /* slot 1 consumed */

    /* 3. a maximum frame, streamed: TX DMA, RX DMA and the line all at once */
    fill_frame(SRC_A, 1514, 0x33);
    announce(1514, 0x33);
    st = loop_frame("frame 3 (1514 bytes)", SRC_A, 1514, true);
    check("frame 3 in ring slot 0", DMA_ST_HEAD(st) == 1, st);
    check_ring("frame 3", 0, SRC_A, 1514);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (1u << 8);                   /* slot 0 released (still read below) */

    /* 4. echo ring slot 0: word 0 = 55 55 55 D5, copy length = the length
          field (4 header bytes + the frame, the old FCS left behind) */
    len = RAM_B32[0] & 0x7ffu;                                      /* frame + FCS */
    RAM_B32[0] = ETH_PREAMBLE_TAIL;
    announce(len - 4, 0x33);
    st = loop_frame("echo (ring slot 0)", 0, len - 4, false);
    check("echo in ring slot 1", DMA_ST_HEAD(st) == 0, st);
    check_ring("echo", 1, 0, len - 4);
    v = 0;
    for (uint32_t i = 0; i < 4; i++)                                /* the FCS bytes behind the frame */
        v |= (uint32_t)(RAM_B[DMA_SLOT + len + i] ^ RAM_B[len + i]) << (8 * i);
    check("echo FCS = frame 3 FCS", v == 0, v);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (0u << 8);

    DMA_CFG_REG = 0;
    prism_write(PRISM_REG_CTRL, 0);

    dputs("ETHLOOP_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
