/*
 * txdma_verify: RISC-V driven system test of the PRISM TX DMA
 * (prism_txdma.v), which copies a frame from a 2 KB slot of PSRAM B into
 * FIFO B (shard 1's SRAM FIFO on SRAM[1]).
 *
 * Runs on TinyQV inside the cocotb program testbench (test_prog.mk with
 * PROG=txdma_verify): the program is fetched from the simulated QSPI flash
 * (so the CPU's own fetches compete with the DMAs for the memory port), its
 * data lives in PSRAM A.  RAM B (8 KB in the sim) holds four slots: 0 and
 * 1 are the RX DMA's ring, 2 and 3 the TX sources.  Results go out over
 * the debug UART, one line per check; test_txdma_verify.py checks them and
 * watches the memory-port arbiter (RX first).
 *
 *   1. 70 bytes from slot 2 behind its header -> FIFO B; popped back
 *   2. 5 bytes from slot 3 byte 0 (one word and a byte) -> FIFO B; popped back
 *   3. a zero-length copy is done at once
 *   4. loopback: 1500 bytes from slot 3 -> FIFO B -> the fifo_loop chroma
 *      (unfractured, B to A) -> FIFO A -> the RX DMA -> ring slot 0, both
 *      DMAs running at once, crossing a PSRAM page
 *   5. flow control: 2044 bytes from slot 2 fill FIFO B; a second copy of 64
 *      bytes from slot 3 waits for room; 64 bytes popped let it finish; the
 *      2044 bytes left go through the loopback into ring slot 1
 *   6. the RX DMA on an SRAM FIFO: FIFO A on SRAM[0], B the flop FIFO; the
 *      host pushes a 1500-byte frame into B, the chroma loops it into A and
 *      the RX DMA drains A into ring slot 0, bursting from 1088 bytes in
 *   7. full duplex on the two SRAMs: the TX DMA fills B on SRAM[1] with a
 *      2044-byte frame from slot 2 while the chroma loops it into A on
 *      SRAM[0] and the RX DMA drains A into ring slot 1
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
/* csr.h (no include guard) comes in via tqv_prism.h */
#include "tqv_prism.h"

extern const uint32_t chroma_fifo_loop[];
extern const uint32_t chroma_fifo_loop_ctrlReg;
extern const uint32_t chroma_fifo_loop_pinmuxReg;

/* TX DMA: TinyQV internal peripheral space, next to the RX DMA */
#define TXDMA_REG               (*(volatile uint32_t *)0x8000028u)
#define TXDMA_LEN(n)            ((n) & 0xfffu)
#define TXDMA_SLOT(s)           (((s) & 0xfffu) << 12)
#define TXDMA_SKIP              (1u << 24)
#define TXDMA_IRQ_EN            (1u << 25)
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
#define DMA_K(k)                (((k) & 7u) << 4)
#define DMA_ST_IRQ              (1u << 16)
#define DMA_ST_OVF              (1u << 17)
#define DMA_ST_SET_TAIL         (1u << 24)
#define DMA_ST_END              (1u << 31)
#define DMA_ST_HEAD(v)          ((v) & 0xffu)
#define DMA_SLOT                2048u
#define DMA_FRAME_START         4u

#define RAM_B                   ((volatile uint8_t *)0x1800000u)
#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define SLOT_SRC_A              2u
#define SLOT_SRC_B              3u
#define SEED_A                  0x61u
#define SEED_B                  0x72u
#define SEED_C                  0x83u           /* the host-pushed frame of case 6 */

#define PRISM_CFG_FIFO_SRAM     (1u << 31)
#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_REG_CFG0_B        SH1(PRISM_SH_CFG0)
#define PRISM_REG_FIFO_B        SH1(PRISM_SH_FIFO)
#define PRISM_REG_FIFO_STATUS_B SH1(PRISM_SH_FIFO_STATUS)
#define FIFO_COUNT(v)           (((v) >> 8) & 0x3fffu)
#define B_TX                    (PRISM_CFG_FIFO_DIR_TX | PRISM_CFG_FIFO_SRAM)
#define B_RX                    (PRISM_CFG_FIFO_SRAM)
/* On an SRAM FIFO the CFG1 levels count 64-byte units, the almost-full one
   as free space: level 15 = 2048 - 15 * 64 = 1088 bytes in, the earliest
   the RX DMA's burst trigger can be set */
#define SRAM_AF_LEVEL           15u
#define SRAM_AF_BYTES           (2048u - SRAM_AF_LEVEL * 64u)
#define RX_BURST_BYTES          32u             /* prism_dma.v BURST_WORDS = 8 */

#define MAX_MISMATCH_LINES      6
#define POLL_LIMIT              200000u

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

static void report(const char *name, uint32_t errors, uint32_t bytes)
{
    dputs(name);
    dputs(": ");
    if (errors == 0) {
        dputs("PASS (");
        pass_count++;
    } else {
        dputs("FAIL (");
        dput_dec(errors);
        dputs(" bad of ");
        fail_count++;
    }
    dput_dec(bytes);
    dputs(" bytes)");
    dnl();
}

static void mismatch(uint32_t *lines, uint32_t i, uint8_t exp, uint8_t got)
{
    if ((*lines)++ < MAX_MISMATCH_LINES) {
        dputs("  MISMATCH byte=");
        dput_dec(i);
        dputs(" exp=");
        dput_hex(exp, 2);
        dputs(" got=");
        dput_hex(got, 2);
        dnl();
    }
}

/* ------------------------------------------------------------------ */

static inline uint8_t slot_byte(uint32_t seed, uint32_t i)
{
    return (uint8_t)(seed + i * 7u + (i >> 5));
}

/* A TX source slot: byte i of the slot is slot_byte(seed, i) */
static void fill_slot(uint32_t slot, uint32_t seed)
{
    for (uint32_t w = 0; w < DMA_SLOT / 4; w++) {
        uint32_t i = w * 4;
        RAM_B32[slot * (DMA_SLOT / 4) + w] = slot_byte(seed, i) | (slot_byte(seed, i + 1) << 8) |
                                             (slot_byte(seed, i + 2) << 16) | ((uint32_t)slot_byte(seed, i + 3) << 24);
    }
}

static void tx_start(uint32_t slot, uint32_t len, uint32_t flags)
{
    TXDMA_REG = TXDMA_START | flags | TXDMA_SLOT(slot) | TXDMA_LEN(len);
}

/* Wait for a copy to finish; returns the status, 0 on a timeout */
static uint32_t tx_wait(void)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = TXDMA_REG;
        if (!(st & TXDMA_ST_BUSY))
            return st;
    }
    return 0;
}

static uint32_t fifo_b_count(void)
{
    return FIFO_COUNT(prism_read(PRISM_REG_FIFO_STATUS_B));
}

static uint32_t fifo_a_count(void)
{
    return FIFO_COUNT(prism_read(PRISM_REG_FIFO_STATUS));
}

/* The host pushes n bytes of slot_byte(seed, i) into FIFO B (in TX mode),
   waiting while it is full; returns 0, or all ones if B never drains */
static uint32_t push_b(uint32_t n, uint32_t seed)
{
    for (uint32_t i = 0; i < n; i++) {
        uint32_t spins = 0;
        while (prism_read(PRISM_REG_FIFO_STATUS_B) & PRISM_FIFO_FULL)
            if (++spins > POLL_LIMIT)
                return 0xFFFFFFFFu;
        prism_write_byte(PRISM_REG_FIFO_B, slot_byte(seed, i));
    }
    return 0;
}

/* Pop n bytes of FIFO B (switched to RX so the host reads it) and compare
   them with slot_byte(seed, first + i); B is left in TX mode */
static void pop_check_b(const char *name, uint32_t n, uint32_t seed, uint32_t first)
{
    uint32_t errors = 0, lines = 0;

    prism_write(PRISM_REG_CFG0_B, B_RX);
    for (uint32_t i = 0; i < n; i++) {
        uint32_t spins = 0;
        while (prism_read(PRISM_REG_FIFO_STATUS_B) & PRISM_FIFO_EMPTY)
            if (++spins > 64) break;              /* the SRAM FIFO refills its head word */
        uint8_t got = prism_read_byte(PRISM_REG_FIFO_B);
        uint8_t exp = slot_byte(seed, first + i);
        if (got != exp) {
            errors++;
            mismatch(&lines, i, exp, got);
        }
    }
    prism_write(PRISM_REG_CFG0_B, B_TX);
    report(name, errors, n);
}

/* Compare ring slot `slot` (length at byte 0, data from byte 4) with the
   expected bytes: n0 bytes of seed0 from first0, then n1 of seed1 from first1 */
static void check_ring(const char *name, uint32_t slot,
                       uint32_t n0, uint32_t seed0, uint32_t first0,
                       uint32_t n1, uint32_t seed1, uint32_t first1)
{
    volatile uint8_t *p = RAM_B + slot * DMA_SLOT;
    uint32_t len = p[0] | ((uint32_t)p[1] << 8);
    uint32_t errors = 0, lines = 0;

    check(name, len == n0 + n1, len);
    for (uint32_t i = 0; i < n0 + n1; i++) {
        uint8_t exp = (i < n0) ? slot_byte(seed0, first0 + i) : slot_byte(seed1, first1 + i - n0);
        uint8_t got = p[DMA_FRAME_START + i];
        if (got != exp) {
            errors++;
            mismatch(&lines, i, exp, got);
        }
    }
    report(name, errors, n0 + n1);
}

/* Loopback: wait until FIFO B is empty and the chroma has pushed its last
   byte into A (then `settle` more clocks); false on a timeout */
static bool wait_b_drained(uint32_t settle)
{
    uint32_t spins = 0;
    while (!(prism_read(PRISM_REG_FIFO_STATUS_B) & PRISM_FIFO_EMPTY))
        if (++spins > POLL_LIMIT)
            return false;
    delay_cycles(settle);
    return true;
}

/* End the RX frame; the RX DMA drains what A still holds (it only bursts
   at A's almost-full level).  Returns the RX DMA status after its
   interrupt, 0 on a timeout */
static uint32_t rx_end(void)
{
    DMA_STATUS_REG = DMA_ST_END;
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        uint32_t st = DMA_STATUS_REG;
        if (st & DMA_ST_IRQ)
            return st;
    }
    return 0;
}

static uint32_t rx_frame_end(void)
{
    return wait_b_drained(200) ? rx_end() : 0;
}

int main(void)
{
    uint32_t st, v;

    dputs("TXDMA_VERIFY START");
    dnl();

    fill_slot(SLOT_SRC_A, SEED_A);
    fill_slot(SLOT_SRC_B, SEED_B);

    /* PRISM stopped, unfractured; FIFO A: RX flop FIFO, FIFO B: TX on SRAM[1] */
    prism_write(PRISM_REG_CTRL, 0);
    prism_write(PRISM_REG_FRAC_CFG, 0);
    prism_write(PRISM_REG_CFG0, chroma_fifo_loop_ctrlReg);        /* A: RX */
    prism_write(PRISM_REG_PINMUX, chroma_fifo_loop_pinmuxReg);
    prism_write(PRISM_REG_CFG1, 4u << 20);                        /* A almost full at 16 - 4 = 12 bytes */
    prism_write(PRISM_REG_CFG0_B, B_TX);
    prism_write(PRISM_REG_FIFO_STATUS, 0);                        /* flush both */
    prism_write(PRISM_REG_FIFO_STATUS_B, 0);

    st = TXDMA_REG;
    check("TX DMA idle", st == 0, st);

    /* 1. 70 bytes from slot 2 behind its header */
    tx_start(SLOT_SRC_A, 70, TXDMA_SKIP | TXDMA_IRQ_EN);
    st = tx_wait();
    check("copy 1 done", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0 &&
          (st & TXDMA_IRQ_EN) && (st & TXDMA_SKIP), st);
    v = fifo_b_count();
    check("copy 1 FIFO B count", v == 70, v);
    TXDMA_REG = TXDMA_ACK;
    st = TXDMA_REG;
    check("copy 1 acknowledged", !(st & TXDMA_ST_DONE), st);
    pop_check_b("copy 1 bytes", 70, SEED_A, DMA_FRAME_START);
    v = fifo_b_count();
    check("copy 1 FIFO B empty", v == 0, v);

    /* 2. 5 bytes from slot 3 byte 0: one word and one byte */
    tx_start(SLOT_SRC_B, 5, 0);
    st = tx_wait();
    check("copy 2 done", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0, st);
    v = fifo_b_count();
    check("copy 2 FIFO B count", v == 5, v);
    pop_check_b("copy 2 bytes", 5, SEED_B, 0);
    TXDMA_REG = TXDMA_ACK;

    /* 3. a zero-length copy */
    tx_start(SLOT_SRC_B, 0, 0);
    st = tx_wait();
    check("copy 3 empty done", (st & TXDMA_ST_DONE) && fifo_b_count() == 0, st);
    TXDMA_REG = TXDMA_ACK;

    /* 4. loopback: TX DMA -> B -> fifo_loop chroma -> A -> RX DMA -> ring slot 0 */
    v = prism_load_chroma(chroma_fifo_loop, PRISM_STATES);
    check("fifo_loop chroma loaded", v == 0, v);
    DMA_CFG_REG = DMA_EN | DMA_IRQ_EN | DMA_K(1);                 /* FIFO A, two slots, software frame end */
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    tx_start(SLOT_SRC_B, 1500, TXDMA_SKIP);
    st = tx_wait();
    check("copy 4 done", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0, st);
    TXDMA_REG = TXDMA_ACK;
    st = rx_frame_end();
    check("copy 4 received", st != 0 && DMA_ST_HEAD(st) == 1 && !(st & DMA_ST_OVF), st);
    DMA_STATUS_REG = DMA_ST_IRQ;
    check_ring("copy 4 ring slot 0", 0, 1500, SEED_B, DMA_FRAME_START, 0, 0, 0);

    /* 5. flow control, chroma stopped: 2044 bytes fill B; 64 more wait for room */
    prism_write(PRISM_REG_CTRL, 0);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (1u << 8);                 /* slot 0 is free again */
    tx_start(SLOT_SRC_A, 2044, TXDMA_SKIP);
    st = tx_wait();
    check("copy 5a done", (st & TXDMA_ST_DONE) && fifo_b_count() == 2044, st);
    TXDMA_REG = TXDMA_ACK;
    tx_start(SLOT_SRC_B, 64, 0);
    delay_cycles(4000);
    st = TXDMA_REG;
    check("copy 5b waits for room", (st & TXDMA_ST_BUSY) && TXDMA_ST_LEFT(st) == 64 &&
          fifo_b_count() == 2044, st);
    pop_check_b("copy 5a first 64 bytes", 64, SEED_A, DMA_FRAME_START);    /* back in TX: room */
    st = tx_wait();
    check("copy 5b done", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0, st);
    v = fifo_b_count();
    check("copy 5 FIFO B count", v == 2044, v);
    TXDMA_REG = TXDMA_ACK;
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);               /* drain B through the loopback */
    st = rx_frame_end();
    check("copy 5 received", st != 0 && DMA_ST_HEAD(st) == 0 && !(st & DMA_ST_OVF), st);
    DMA_STATUS_REG = DMA_ST_IRQ;
    check_ring("copy 5 ring slot 1", 1, 2044 - 64, SEED_A, DMA_FRAME_START + 64, 64, SEED_B, 0);

    /* 6. the RX DMA on an SRAM FIFO: A on SRAM[0] in RX mode, B the flop FIFO
       in TX mode; the host pushes a 1500-byte frame into B, the chroma loops
       it into A, and the RX DMA bursts from A while it holds SRAM_AF_BYTES
       or more, then drains the rest at the frame end */
    prism_write(PRISM_REG_CTRL, 0);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (0u << 8);                 /* slot 1 consumed: both free */
    prism_write(PRISM_REG_CFG0, chroma_fifo_loop_ctrlReg | PRISM_CFG_FIFO_SRAM);   /* A: RX on SRAM[0] */
    prism_write(PRISM_REG_CFG1, SRAM_AF_LEVEL << 20);
    prism_write(PRISM_REG_CFG0_B, PRISM_CFG_FIFO_DIR_TX);         /* B: TX flop FIFO, the host pushes */
    prism_write(PRISM_REG_FIFO_STATUS, 0);                        /* flush both */
    prism_write(PRISM_REG_FIFO_STATUS_B, 0);
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    v = push_b(1500, SEED_C);
    check("frame 6 pushed", v == 0, v);
    /* every byte is in A now; the bursts stop once A holds less than the
       almost-full level, so A keeps between one burst below it and it */
    v = wait_b_drained(4000) ? fifo_a_count() : 0xFFFFFFFFu;
    check("frame 6 SRAM A settled below its almost-full level", v >= SRAM_AF_BYTES - RX_BURST_BYTES &&
          v < SRAM_AF_BYTES, v);
    st = rx_end();
    check("frame 6 received", st != 0 && DMA_ST_HEAD(st) == 1 && !(st & DMA_ST_OVF), st);
    DMA_STATUS_REG = DMA_ST_IRQ;
    check_ring("frame 6 ring slot 0", 0, 1500, SEED_C, 0, 0, 0, 0);
    v = fifo_a_count();
    check("frame 6 SRAM A empty", v == 0, v);

    /* 7. full duplex on the two SRAMs: the TX DMA fills B on SRAM[1] with a
       maximum-size frame while the chroma loops it into A on SRAM[0] and the
       RX DMA drains A into ring slot 1 */
    prism_write(PRISM_REG_CTRL, 0);
    DMA_STATUS_REG = DMA_ST_SET_TAIL | (1u << 8);                 /* slot 0 consumed */
    prism_write(PRISM_REG_CFG0_B, B_TX);                          /* B: TX on SRAM[1] */
    prism_write(PRISM_REG_FIFO_STATUS_B, 0);
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    tx_start(SLOT_SRC_A, 2044, TXDMA_SKIP);
    st = tx_wait();
    v = fifo_a_count();                     /* without the RX DMA draining alongside, A would hold ~2 KB */
    check("frame 7 TX DMA done", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0, st);
    check("frame 7 RX DMA drained A during the copy", v < 2044 - 512, v);
    TXDMA_REG = TXDMA_ACK;
    st = rx_frame_end();
    check("frame 7 received", st != 0 && DMA_ST_HEAD(st) == 0 && !(st & DMA_ST_OVF), st);
    DMA_STATUS_REG = DMA_ST_IRQ;
    check_ring("frame 7 ring slot 1", 1, 2044, SEED_A, DMA_FRAME_START, 0, 0, 0);
    v = fifo_a_count() | fifo_b_count();
    check("frame 7 both SRAM FIFOs empty", v == 0, v);

    DMA_CFG_REG = 0;
    prism_write(PRISM_REG_CTRL, 0);

    dputs("TXDMA_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
