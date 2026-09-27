/*
 * ethring_verify: RISC-V driven test of the TX DMA's ring (prism_txdma.v,
 * TXRING_*) and the RX DMA's per-frame status (prism_dma.v slot header
 * bit 16 = crc_ok), over the 10BASE-T loopback of ethloop_verify:
 *
 *   TX ring slot -> TX DMA -> FIFO B (SRAM[1]) -> eth_tx on shard 1 -> the
 *   bench's wire -> ui_in[3] -> eth_rx on shard 0 -> FIFO A -> RX DMA ->
 *   RX ring slot
 *
 * The bench runs 32 KB PSRAMs (SIM_RAM_BITS=15): RAM B holds 16 slots of
 * 2 KB, the RX ring in slots 0-7 and the TX ring in slots 8-15.  Both use
 * one slot format: word 0 the byte count L, word 1 55 55 55 D5 in a TX
 * slot (spare in an RX slot), the frame from byte 8.  The TX ring sends
 * the L bytes from byte 4 (the preamble tail eth_tx pops, then the frame,
 * L = frame + 4), starts the chroma itself and waits the inter-frame gap
 * between frames; an RX slot's L is frame + FCS = frame + 4, so writing
 * 55 55 55 D5 into its word 1 makes it a TX slot.
 *
 *   1. ring burst: six frames (60, 1514, 64, 101, 200, 61 bytes) queued in
 *      one head write go out back to back; the ring takes shard 1's end of
 *      frame interrupts (none reach the host); each lands in the RX ring
 *      with crc_ok set and matches its TX slot.  test_ethring_verify.py
 *      checks that TX_EN stays low for 96 bit times (+ a little) between
 *      them and decodes the line.
 *   2. RX status: the bench injects three frames on ui_in[3] at the
 *      minimum gap, the middle one with a wrong FCS: all three land in
 *      their own slots (back-to-back boundaries on the flop FIFO), crc_ok
 *      1 / 0 / 1.
 *   3. forward: 55 55 55 D5 into the spare word of the first injected
 *      frame's RX slot and the TX ring pointed at it (base = that slot)
 *      sends it again (the received FCS stays behind, eth_tx appends a new
 *      one); it comes back identical, FCS included.
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

/* TX ring (prism_txdma.v) */
#define TXRING_CFG_REG          (*(volatile uint32_t *)0x800002Cu)
#define TXRING_STATUS_REG       (*(volatile uint32_t *)0x8000034u)
#define TXR_EN                  (1u << 0)
#define TXR_K(k)                (((k) & 7u) << 1)
#define TXR_IRQ_EN              (1u << 6)
#define TXR_IFG(c)              (((c) & 0x3ffu) << 8)
#define TXR_BASE(b)             (((b) & 0xffu) << 20)
#define TXR_SET_HEAD            (1u << 24)
#define TXR_ST_HEAD(v)          ((v) & 0xfu)
#define TXR_ST_TAIL(v)          (((v) >> 8) & 0xfu)
#define TXR_ST_SENT             (1u << 16)
#define TXR_ST_BUSY             (1u << 17)

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
#define HDR_LEN(h)              ((h) & 0x7ffu)
#define HDR_TRUNC               (1u << 15)
#define HDR_CRC_OK              (1u << 16)

#define RAM_B                   ((volatile uint8_t *)0x1800000u)
#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define DMA_SLOT                2048u
#define SLOT_WORDS              (DMA_SLOT / 4)
#define FRAME_WORD              2u              /* the frame starts at slot byte 8 */
#define RX_K                    3u              /* RX ring: slots 0-7 */
#define RX_SLOTS                (1u << RX_K)
#define TX_BASE                 8u              /* TX ring: slots 8-15 */
#define TX_K                    3u

#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_CFG_FIFO_SRAM     (1u << 31)

#define BIT_CLOCKS              6u
#define IFG_CLOCKS              (96u * BIT_CLOCKS)
#define RXD_PIN                 3u
#define RX_AF_LEVEL             8u
#define ETH_PREAMBLE_TAIL       0xD5555555u     /* 55 55 55 D5 */
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

/* Frame byte i (no FCS): as ethtx_verify; test_ethring_verify.py builds the same */
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

/* A TX ring slot: L = n + 4 in word 0, 55 55 55 D5 in word 1, the frame from byte 8 */
static void fill_tx_slot(uint32_t slot, uint32_t n, uint32_t seed)
{
    volatile uint32_t *w = RAM_B32 + slot * SLOT_WORDS;

    w[0] = n + 4;
    w[1] = ETH_PREAMBLE_TAIL;
    for (uint32_t i = 0; i < n; i += 4)
        w[FRAME_WORD + i / 4] = eth_byte(seed, i) | ((uint32_t)eth_byte(seed, i + 1) << 8) |
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

/* Wait until the RX ring's head reaches `head`; the last status, 0 on a timeout */
static uint32_t rx_wait_head(uint32_t head)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = DMA_STATUS_REG;
        if (DMA_ST_HEAD(st) == head)
            return st;
    }
    return 0;
}

/* Wait until the TX ring's tail reaches `tail` and it is idle; its status, 0 on a timeout */
static uint32_t tx_wait_tail(uint32_t tail)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = TXRING_STATUS_REG;
        if (TXR_ST_TAIL(st) == tail && !(st & TXR_ST_BUSY))
            return st;
    }
    return 0;
}

/* Byte i of RX slot `slot`'s frame against byte i of slot `src`'s frame (both
   from byte 8), or against eth_byte(seed, i) when src is ~0; returns the
   number of words that differ */
static uint32_t compare_frame(uint32_t slot, uint32_t src, uint32_t seed, uint32_t n)
{
    volatile uint32_t *r = RAM_B32 + slot * SLOT_WORDS + FRAME_WORD;
    uint32_t errors = 0, lines = 0;

    for (uint32_t w = 0; w < (n + 3) / 4; w++) {
        uint32_t got = r[w], exp;
        if (src != ~0u)
            exp = RAM_B32[src * SLOT_WORDS + FRAME_WORD + w];
        else {
            uint32_t i = w * 4;
            exp = eth_byte(seed, i) | ((uint32_t)eth_byte(seed, i + 1) << 8) |
                  ((uint32_t)eth_byte(seed, i + 2) << 16) | ((uint32_t)eth_byte(seed, i + 3) << 24);
        }
        if (w * 4 + 4 > n)                               /* the last word: only the frame's bytes */
            exp ^= (exp ^ got) & ~(0xffffffffu >> (8 * (w * 4 + 4 - n)));
        if (got != exp) {
            errors++;
            if (lines++ < MAX_MISMATCH_LINES) {
                dputs("  MISMATCH word=");
                dput_dec(w);
                dputs(" exp=");
                dput_hex(exp, 8);
                dputs(" got=");
                dput_hex(got, 8);
                dnl();
            }
        }
    }
    return errors;
}

/* RX slot `slot`: its header (length n + FCS, not truncated, crc_ok as
   expected) and its frame (against TX slot `src`, or the generator) */
static void check_rx(const char *name, uint32_t slot, uint32_t src, uint32_t seed, uint32_t n, bool crc_ok)
{
    uint32_t hdr = RAM_B32[slot * SLOT_WORDS];

    dputs(name);
    check(" header", HDR_LEN(hdr) == n + 4 && !(hdr & HDR_TRUNC) && ((hdr & HDR_CRC_OK) != 0) == crc_ok, hdr);
    dputs(name);
    check(" matches", compare_frame(slot, src, seed, n) == 0, slot);
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

    /* shard 0: eth_rx on the flop FIFO A (see ethloop_verify) */
    prism_write(PRISM_REG_CFG0, chroma_eth_rx_ctrlReg);
    prism_write(PRISM_REG_PINMUX, chroma_eth_rx_pinmuxReg);
    prism_write(PRISM_REG_CFG1, RX_AF_LEVEL << 20);
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CFG2, 15u | (12u << 4) | (11u << 8));
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CFG3,
                RXD_PIN | (1u << 3) | ((BIT_CLOCKS / 2) << 4) | (1u << 8));
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CONST, 0);
    prism_write_byte(PRISM_REG_COMPARE, 8);
    prism_write(PRISM_REG_PRELOAD, 2 * BIT_CLOCKS);
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

    /* RX DMA: FIFO A into an eight-slot ring at the bottom of RAM B */
    DMA_CFG_REG = DMA_EN | DMA_IRQ_EN | DMA_HW_END | DMA_K(RX_K);

    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    prism_claim_pins((1u << 1) | (1u << 2));
    return errors;
}

static const uint16_t burst_len[6]  = { 60, 1514, 64, 101, 200, 61 };
static const uint8_t  burst_seed[6] = { 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 };

int main(void)
{
    uint32_t st, v;

    dputs("ETHRING_VERIFY START");
    dnl();

    v = eth_setup();
    check("eth_rx in bank A, eth_tx in bank B", v == 0, v);

    /* the TX ring: slots 8-15, the minimum gap */
    TXRING_CFG_REG = TXR_EN | TXR_K(TX_K) | TXR_IRQ_EN | TXR_IFG(IFG_CLOCKS) | TXR_BASE(TX_BASE);
    v = TXRING_CFG_REG;
    check("TX ring configuration read back",
          v == (TXR_EN | TXR_K(TX_K) | TXR_IRQ_EN | TXR_IFG(IFG_CLOCKS) | TXR_BASE(TX_BASE)), v);
    dputs("ETH READY");
    dnl();

    /* 1. six frames queued with one head write */
    for (uint32_t k = 0; k < 6; k++) {
        fill_tx_slot(TX_BASE + k, burst_len[k], burst_seed[k]);
        announce(burst_len[k], burst_seed[k]);
    }
    TXRING_STATUS_REG = TXR_SET_HEAD | 6;
    st = tx_wait_tail(6);
    check("ring burst: six frames sent", st != 0 && (st & TXR_ST_SENT), st);
    st = rx_wait_head(6);
    check("ring burst: six frames received", st != 0 && !(st & DMA_ST_OVF), st);
    v = prism_read(PRISM_REG_CTRL);
    check("shard 1 end-of-frame interrupts taken by the ring", !(v & PRISM_CTRL_IRQ1), v);
    for (uint32_t k = 0; k < 6; k++) {
        static const char *names[6] = { "burst 1", "burst 2", "burst 3", "burst 4", "burst 5", "burst 6" };
        check_rx(names[k], k, TX_BASE + k, 0, burst_len[k], true);
    }
    TXRING_STATUS_REG = TXR_ST_SENT;                                  /* clear frame sent */
    check("frame-sent flag cleared", !(TXRING_STATUS_REG & TXR_ST_SENT), TXRING_STATUS_REG);
    DMA_STATUS_REG = DMA_ST_IRQ | DMA_ST_SET_TAIL | (6u << 8);          /* RX slots 0-5 consumed */

    /* 2. the bench injects three frames at the minimum gap, the second with
          a wrong FCS; they land in RX slots 6, 7 and 0 */
    dputs("ETH INJECT");
    dnl();
    st = rx_wait_head(1);
    check("injected: three frames received", st != 0 && !(st & DMA_ST_OVF), st);
    check_rx("injected 1 (good)", 6, ~0u, 0xA1, 100, true);
    check_rx("injected 2 (bad FCS)", 7, ~0u, 0xA2, 80, false);
    check_rx("injected 3 (good)", 0, ~0u, 0xA3, 60, true);

    /* 3. forward RX slot 6 through the TX ring: 55 55 55 D5 into its spare
          word, the ring's base = that slot */
    RAM_B32[6 * SLOT_WORDS + 1] = ETH_PREAMBLE_TAIL;
    TXRING_CFG_REG = 0;
    TXRING_CFG_REG = TXR_EN | TXR_K(1) | TXR_IRQ_EN | TXR_IFG(IFG_CLOCKS) | TXR_BASE(6);
    announce(100, 0xA1);
    TXRING_STATUS_REG = TXR_SET_HEAD | 1;
    st = tx_wait_tail(1);
    check("forward sent", st != 0, st);
    st = rx_wait_head(2);
    check("forward received in RX slot 1", st != 0 && !(st & DMA_ST_OVF), st);
    check_rx("forward", 1, 6, 0, 100, true);
    v = 0;
    for (uint32_t i = 0; i < 4; i++)                                  /* the FCS behind the frame */
        v |= (uint32_t)(RAM_B[DMA_SLOT + 8 + 100 + i] ^ RAM_B[6 * DMA_SLOT + 8 + 100 + i]) << (8 * i);
    check("forward FCS = received FCS", v == 0, v);

    TXRING_CFG_REG = 0;
    DMA_CFG_REG = 0;
    prism_write(PRISM_REG_CTRL, 0);

    dputs("ETHRING_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
