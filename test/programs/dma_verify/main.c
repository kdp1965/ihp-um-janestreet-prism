/*
 * dma_verify: RISC-V driven system test of the PRISM RX DMA (prism_dma.v).
 *
 * Runs on TinyQV inside the cocotb program testbench (test_prog.mk with
 * PROG=dma_verify): the program is fetched from the simulated QSPI flash,
 * its data lives in PSRAM A, and the DMA ring is PSRAM B.  Results go
 * out over the debug UART (uo_out[6], 4 Mbaud), one line per check; the
 * cocotb side (test_dma_verify.py) checks them.
 *
 * Chain mode: the host pushes bytes into FIFO A (shard 0, TX mode, the
 * same push path a receiving chroma uses), the mover drains A into FIFO B
 * by itself, and the DMA on shard 1 drains B into a two-slot ring at the
 * bottom of RAM B, bursting whenever B reaches its almost-full level (12
 * bytes) and at each software frame end.  No chroma, PRISM disabled.
 *
 *   1. a 70-byte frame -> slot 0 (several bursts and a two-byte tail)
 *   2. a 5-byte frame with the ring full -> dropped, overflow flagged
 *   3. tail released; a 5-byte frame -> slot 1 (one word, one tail byte)
 *   4. tail released; an empty frame -> slot 0, length 0
 *   5. tail released; a 1500-byte frame -> slot 1, crossing a PSRAM page,
 *      with the CPU writing and reading RAM B in between the bursts
 *   6. the upper half of RAM B, outside the ring, is untouched
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
/* csr.h (no include guard) comes in via tqv_prism.h */
#include "tqv_prism.h"

/* RX DMA registers: TinyQV internal peripheral space (prism_dma.v sits next
   to the memory controller; only a byte-serial tap reaches the PRISM) */
#define DMA_CFG_REG             (*(volatile uint32_t *)0x8000020u)
#define DMA_STATUS_REG          (*(volatile uint32_t *)0x8000024u)
#define DMA_EN                  (1u << 0)
#define DMA_SHARD1              (1u << 1)
#define DMA_IRQ_EN              (1u << 2)
#define DMA_HW_END              (1u << 3)
#define DMA_CHAIN               (1u << 7)
#define DMA_K(k)                (((k) & 7u) << 4)
#define DMA_ST_IRQ              (1u << 16)
#define DMA_ST_OVF              (1u << 17)
#define DMA_ST_BUSY             (1u << 18)
#define DMA_ST_DROP             (1u << 19)
#define DMA_ST_SET_TAIL         (1u << 24)
#define DMA_ST_END              (1u << 31)
#define DMA_ST_HEAD(v)          ((v) & 0xffu)
#define DMA_ST_TAIL(v)          (((v) >> 8) & 0xffu)
#define DMA_SLOT                2048u
#define DMA_FRAME_START         4u

#define RAM_B                   ((volatile uint8_t *)0x1800000u)
#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define RAM_B_BYTES             8192u
#define GUARD_START             4096u           /* bytes of RAM B outside the two-slot ring */

#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_REG_FIFO_B        SH1(PRISM_SH_FIFO)
#define PRISM_REG_FIFO_STATUS_B SH1(PRISM_SH_FIFO_STATUS)
#define PRISM_REG_CFG0_B        SH1(PRISM_SH_CFG0)

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

/* ------------------------------------------------------------------ */

static inline uint8_t frame_byte(uint32_t seed, uint32_t i)
{
    return (uint8_t)(seed + i * 7u + (i >> 5));
}

static inline uint32_t guard_word(uint32_t i)
{
    return 0xB0000000u + i * 0x01010101u;
}

static uint32_t dma_status(void)
{
    return DMA_STATUS_REG;
}

/* Push a frame's bytes into FIFO A; the mover carries them to FIFO B.
   While it runs, every 128th byte the CPU also writes and reads back a
   word of RAM B's guard region, so its own transactions interleave with
   the DMA's bursts. */
static uint32_t send_frame(uint32_t n, uint32_t seed)
{
    uint32_t ram_errors = 0;

    for (uint32_t i = 0; i < n; i++) {
        uint32_t spins = 0;
        while (prism_read(PRISM_REG_FIFO_STATUS) & PRISM_FIFO_FULL) {
            if (++spins > POLL_LIMIT)
                return 0xFFFFFFFFu;             /* the chain is stuck */
        }
        prism_write_byte(PRISM_REG_FIFO, frame_byte(seed, i));
        if ((i & 127u) == 127u) {
            uint32_t w = GUARD_START / 4 + (i >> 7);
            RAM_B32[w] = guard_word(w) ^ seed;
            if (RAM_B32[w] != (guard_word(w) ^ seed))
                ram_errors++;
            RAM_B32[w] = guard_word(w);
        }
    }
    return ram_errors;
}

/* End the frame and wait for the DMA to land it (or drop it).  Returns
   the status word after the interrupt, or 0 on a timeout. */
static uint32_t end_frame(void)
{
    uint32_t spins = 0;

    DMA_STATUS_REG = (DMA_ST_END);
    for (;;) {
        uint32_t st = dma_status();
        if (st & DMA_ST_IRQ)
            return st;
        if (++spins > POLL_LIMIT)
            return 0;
    }
}

/* Wait until the engine has finished consuming a dropped frame */
static uint32_t wait_idle(void)
{
    uint32_t spins = 0;
    for (;;) {
        uint32_t st = dma_status();
        if (!(st & (DMA_ST_BUSY | DMA_ST_DROP)))
            return st;
        if (++spins > POLL_LIMIT)
            return 0xFFFFFFFFu;
    }
}

static void check_slot(const char *name, uint32_t slot, uint32_t n, uint32_t seed)
{
    volatile uint8_t *p = RAM_B + slot * DMA_SLOT;
    uint32_t len = p[0] | ((uint32_t)p[1] << 8);
    uint32_t errors = 0, lines = 0;

    check(name, len == n, len);
    for (uint32_t i = 0; i < n; i++) {
        uint8_t got = p[DMA_FRAME_START + i];
        uint8_t exp = frame_byte(seed, i);
        if (got != exp) {
            errors++;
            if (lines++ < MAX_MISMATCH_LINES) {
                dputs("  MISMATCH byte=");
                dput_dec(i);
                dputs(" exp=");
                dput_hex(exp, 2);
                dputs(" got=");
                dput_hex(got, 2);
                dnl();
            }
        }
    }
    report(name, errors, n);
}

int main(void)
{
    uint32_t st, v;

    dputs("DMA_VERIFY START");
    dnl();

    /* A pattern in the half of RAM B the ring must not touch */
    for (uint32_t w = GUARD_START / 4; w < RAM_B_BYTES / 4; w++)
        RAM_B32[w] = guard_word(w);

    prism_write(PRISM_REG_CTRL, 0);
    prism_write(PRISM_REG_FRAC_CFG, 0);
    prism_write(PRISM_REG_CFG0, PRISM_CFG_FIFO_DIR_TX);          /* A: TX, the host pushes */
    prism_write(PRISM_REG_CFG0_B, 0);                            /* B: RX, the DMA pops */
    prism_write(SH1(PRISM_SH_CFG1), 4u << 20);                   /* B almost full at 16 - 4 = 12 bytes */
    prism_write(PRISM_REG_FIFO_STATUS, 0);                       /* flush both */
    prism_write(PRISM_REG_FIFO_STATUS_B, 0);

    /* Two 2 KB slots at the bottom of RAM B, interrupt on each frame,
       frames ended by software; A chained into B, the DMA on B */
#define DMA_MODE (DMA_EN | DMA_SHARD1 | DMA_IRQ_EN | DMA_CHAIN | DMA_K(1))
    DMA_CFG_REG = DMA_MODE;
    v = DMA_CFG_REG;
    check("DMA cfg readback", v == DMA_MODE, v);
    st = dma_status();
    check("DMA idle status", st == (DMA_FRAME_START << 20), st);

    /* 1. a 70-byte frame: bursts as B fills, then the rest at the end */
    v = send_frame(70, 0x11);
    check("frame 1 pushed", v == 0, v);
    st = end_frame();
    check("frame 1 landed", st != 0 && DMA_ST_HEAD(st) == 1 && !(st & DMA_ST_OVF), st);
    v = prism_read(PRISM_REG_INT_STATUS);
    check("frame 1 no shard IRQ", (v & 3u) == 0, v);          /* the DMA's is TinyQV interrupt 10 */
    DMA_STATUS_REG = (DMA_ST_IRQ);
    check("frame 1 IRQ cleared", !(dma_status() & DMA_ST_IRQ), dma_status());
    check_slot("frame 1 slot 0", 0, 70, 0x11);

    /* 2. the ring is full (head 1, tail 0, two slots): a frame is dropped */
    v = send_frame(5, 0x22);
    check("frame 2 pushed", v == 0, v);
    DMA_STATUS_REG = (DMA_ST_END);
    st = wait_idle();
    check("frame 2 dropped", DMA_ST_HEAD(st) == 1 && (st & DMA_ST_OVF) && !(st & DMA_ST_IRQ), st);
    v = prism_read(PRISM_REG_FIFO_STATUS) & prism_read(PRISM_REG_FIFO_STATUS_B);
    check("frame 2 FIFOs drained", (v & PRISM_FIFO_EMPTY) != 0, v);
    DMA_STATUS_REG = (DMA_ST_OVF);
    check("overflow cleared", !(dma_status() & DMA_ST_OVF), dma_status());

    /* 3. release slot 0; a 5-byte frame: one word and a tail byte -> slot 1 */
    DMA_STATUS_REG = (DMA_ST_SET_TAIL | (1u << 8));
    v = send_frame(5, 0x33);
    check("frame 3 pushed", v == 0, v);
    st = end_frame();
    check("frame 3 landed", st != 0 && DMA_ST_HEAD(st) == 0 && DMA_ST_TAIL(st) == 1, st);
    DMA_STATUS_REG = (DMA_ST_IRQ);
    check_slot("frame 3 slot 1", 1, 5, 0x33);

    /* 4. release slot 1; an empty frame -> slot 0 with length 0 */
    DMA_STATUS_REG = (DMA_ST_SET_TAIL | (0u << 8));
    st = end_frame();
    check("frame 4 landed", st != 0 && DMA_ST_HEAD(st) == 1, st);
    DMA_STATUS_REG = (DMA_ST_IRQ);
    check_slot("frame 4 slot 0", 0, 0, 0x44);

    /* 5. release slot 0; a full-size frame -> slot 1, across a PSRAM page */
    DMA_STATUS_REG = (DMA_ST_SET_TAIL | (1u << 8));
    v = send_frame(1500, 0x55);
    check("frame 5 pushed, CPU RAM B interleave", v == 0, v);
    st = end_frame();
    check("frame 5 landed", st != 0 && DMA_ST_HEAD(st) == 0, st);
    DMA_STATUS_REG = (DMA_ST_IRQ);
    check_slot("frame 5 slot 1", 1, 1500, 0x55);

    /* 6. the guard half of RAM B */
    v = 0;
    for (uint32_t w = GUARD_START / 4; w < RAM_B_BYTES / 4; w++)
        if (RAM_B32[w] != guard_word(w))
            v++;
    report("RAM B guard region", v, RAM_B_BYTES - GUARD_START);

    DMA_CFG_REG = 0;
    prism_write(PRISM_REG_CTRL, 0);

    dputs("DMA_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
