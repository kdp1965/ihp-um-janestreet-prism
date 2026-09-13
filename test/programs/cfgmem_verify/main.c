/*
 * cfgmem_verify: RISC-V driven system test of the CFGMEM peripheral and
 * the CFGMEM-backed PRISM.
 *
 * Runs on TinyQV inside the cocotb program testbench (test_prog.mk with
 * PROG=cfgmem_verify): the program is fetched from the simulated QSPI
 * flash, RAM lives in the two simulated PSRAMs, and results are reported
 * over the debug UART (uo_out[6], 4 Mbaud) as one line per check.  The
 * cocotb side (test_cfgmem_verify.py) models the 74165/74595 shift
 * registers the gpio24 chroma talks to and checks the report.
 *
 *   1. Shift 16 words into each lo and hi macro, read every row back.
 *   2. Chain lo[i] -> hi[i] through the macro data path and read back.
 *   3. Load chroma_gpio24 into lo[1]:lo[0] and verify the SIT rows.
 *   4. Enable PRISM, run the gpio24 chroma against the PMOD models with
 *      a breakpoint / single-step / resume sequence, check the shifted
 *      in value.
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
/* csr.h (no include guard) comes in via tqv_prism.h */
#include "tqv_prism.h"

extern const uint32_t chroma_gpio24[];
extern const uint32_t chroma_gpio24_ctrlReg;
extern const uint32_t chroma_gpio24_pinmuxReg;

#define MAX_MISMATCH_LINES  6

static uint32_t pass_count;
static uint32_t fail_count;

static uint32_t lo_pat[CFGMEM_COUNT][CFGMEM_DEPTH];
static uint32_t hi_pat[CFGMEM_COUNT][CFGMEM_DEPTH];

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
        /* division-free /10 for rv32e without M */
        while (r >= 10) { r -= 10; q++; }
        buf[n++] = '0' + r;
        v = q;
    } while (v);
    while (n)
        debug_uart_putc(buf[--n]);
}

static void report(const char *name, uint32_t errors, uint32_t words)
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
    dput_dec(words);
    dputs(" words)");
    dnl();
}

static void check(const char *name, bool ok, uint32_t value)
{
    dputs(name);
    dputs(ok ? ": PASS " : ": FAIL ");
    dput_hex(value, 8);
    dnl();
    if (ok) pass_count++; else fail_count++;
}

static void mismatch(uint32_t *lines, const char *what, uint32_t inst,
                     uint32_t row, uint32_t exp, uint32_t got)
{
    if ((*lines)++ >= MAX_MISMATCH_LINES)
        return;
    dputs("  MISMATCH ");
    dputs(what);
    dputs(" inst=");
    dput_dec(inst);
    dputs(" row=");
    dput_dec(row);
    dputs(" exp=");
    dput_hex(exp, 8);
    dputs(" got=");
    dput_hex(got, 8);
    dnl();
}

/* ------------------------------------------------------------------ */

static void make_patterns(void)
{
    uint32_t x = 0x2545F491u;           /* xorshift32 */
    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (uint32_t r = 0; r < CFGMEM_DEPTH; r++) {
            x ^= x << 13; x ^= x >> 17; x ^= x << 5;
            lo_pat[i][r] = x;
            x ^= x << 13; x ^= x >> 17; x ^= x << 5;
            hi_pat[i][r] = x;
        }
}

/* 1. Shift patterns into every macro and read every row back. */
static void test_shift_readback(void)
{
    uint32_t errors = 0, lines = 0;

    /* lo macros: bypass the lo chain so every macro sees the host word
       (PRISM address irrelevant while loading).  Write row 15 first so
       lo_pat[i][r] lands in row r. */
    cfgmem_ctrl(CFGMEM_CTRL_BYP_LO);
    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (int r = CFGMEM_DEPTH - 1; r >= 0; r--)
            cfgmem_shift_lo(i, lo_pat[i][r]);

    /* hi macros: the same through the hi chain. */
    cfgmem_ctrl(CFGMEM_CTRL_BYP_HI);
    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (int r = CFGMEM_DEPTH - 1; r >= 0; r--)
            cfgmem_shift_hi(i, hi_pat[i][r]);

    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (uint32_t r = 0; r < CFGMEM_DEPTH; r++) {
            uint32_t got = cfgmem_read_hi(i, r);
            if (got != hi_pat[i][r]) {
                errors++;
                mismatch(&lines, "hi", i, r, hi_pat[i][r], got);
            }
        }
    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (uint32_t r = 0; r < CFGMEM_DEPTH; r++) {
            uint32_t got = cfgmem_read_lo(i, r);
            if (got != lo_pat[i][r]) {
                errors++;
                mismatch(&lines, "lo", i, r, lo_pat[i][r], got);
            }
        }
    cfgmem_release();
    report("CFGMEM shift/readback", errors, 2 * CFGMEM_COUNT * CFGMEM_DEPTH);
}

/* 2. Walk each bank's chain with the bypass off: addressing row r of the
      bank and shifting macro i once per row (15..0) copies macro i-1 into
      macro i.  Going up the chain, every macro of a bank ends up holding
      macro 0's pattern. */
static void test_chain(void)
{
    uint32_t errors = 0, lines = 0;

    for (uint32_t i = 1; i < CFGMEM_COUNT; i++)
        for (int r = CFGMEM_DEPTH - 1; r >= 0; r--) {
            cfgmem_ctrl(CFGMEM_CTRL_ADDR_SEL | CFGMEM_CTRL_ADDR(r));
            cfgmem_shift_lo(i, 0xDEAD0000u | r);   /* data ignored */
            cfgmem_shift_hi(i, 0xBEEF0000u | r);
        }

    for (uint32_t i = 0; i < CFGMEM_COUNT; i++)
        for (uint32_t r = 0; r < CFGMEM_DEPTH; r++) {
            uint32_t got = cfgmem_read_lo(i, r);
            if (got != lo_pat[0][r]) {
                errors++;
                mismatch(&lines, "lo", i, r, lo_pat[0][r], got);
            }
            got = cfgmem_read_hi(i, r);
            if (got != hi_pat[0][r]) {
                errors++;
                mismatch(&lines, "hi", i, r, hi_pat[0][r], got);
            }
        }
    cfgmem_release();
    report("CFGMEM chains lo0->lo3 / hi0->hi3", errors, 2 * CFGMEM_COUNT * CFGMEM_DEPTH);
}

/* 3. Load the gpio24 chroma (32 states x 4 words) and verify every row. */
static void test_chroma_load(void)
{
    uint32_t errors = prism_load_chroma(chroma_gpio24, PRISM_STATES);
    if (errors) {
        uint32_t lines = 0;
        for (uint32_t s = 0; s < PRISM_STATES; s++) {
            const uint32_t *ws = chroma_gpio24 + (PRISM_STATES - 1 - s) * PRISM_STEW_WORDS;
            for (uint32_t j = 0; j < PRISM_STEW_WORDS; j++) {
                uint32_t inst = PRISM_STEW_WORDS - 1 - j;
                uint32_t got  = s < PRISM_BANK_STATES ? cfgmem_read_lo(inst, s)
                                                      : cfgmem_read_hi(inst, s - PRISM_BANK_STATES);
                if (got != ws[j])
                    mismatch(&lines, s < PRISM_BANK_STATES ? "lo" : "hi", inst, s, ws[j], got);
            }
        }
        cfgmem_release();
    }
    report("CHROMA gpio24 load", errors, PRISM_STATES * PRISM_STEW_WORDS);
}

/* 4. Run the gpio24 chroma (mirrors test/user_peripherals/prism/test.py). */
static void test_prism_gpio24(void)
{
    uint32_t v;

    /* Reset PRISM, then program shard 0's datapath configuration (the
       chroma's ctrl_reg) and pin mux (its pinmux_reg). */
    prism_write(PRISM_REG_CTRL, 0);
    delay_cycles(64);
    v = prism_read(PRISM_REG_CTRL);
    check("PRISM ctrl clear", (v & 0x40000000) == 0, v);

    prism_write(PRISM_REG_CFG0, chroma_gpio24_ctrlReg);
    prism_write(PRISM_REG_PINMUX, chroma_gpio24_pinmuxReg);
    v = prism_read(PRISM_REG_CFG0);
    check("PRISM cfg0 write", v == chroma_gpio24_ctrlReg, v);
    v = prism_read(PRISM_REG_PINMUX);
    check("PRISM pinmux write", v == chroma_gpio24_pinmuxReg, v);

    /* The 512-byte PRISM region is fully decoded: the old 64-byte alias of
       the control register at +0x40 and the old image of the whole map at
       0x8000600 must both read as zero now. */
    v = prism_read(0x40);
    check("PRISM no alias +0x40", v == 0, v);
    v = *(volatile uint32_t *)(PRISM_BASE_ADDRESS + 0x400);
    check("PRISM no alias +0x400", v == 0, v);

    /* Shard 1 has its own register window, independent of shard 0 */
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_PRELOAD, 0xA5C3F00Fu);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_PRELOAD);
    check("PRISM shard1 preload", v == 0xA5C3F00Fu, v);
    v = prism_read(PRISM_REG_PRELOAD);
    check("PRISM shard0 preload untouched", v == 0, v);

    /* Shard 1 FIFO in TX mode: the host pushes, reads do not pop, a write to
       the status register flushes.  Works with the PRISM disabled. */
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_CFG0, PRISM_CFG_FIFO_DIR_TX);
    prism_write_byte(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO, 0x11);
    prism_write_byte(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO, 0x22);
    prism_write_byte(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO, 0x33);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO_STATUS);
    check("PRISM shard1 fifo count", PRISM_FIFO_COUNT(v) == 3 && !(v & PRISM_FIFO_EMPTY), v);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO);
    check("PRISM shard1 fifo head", v == 0x11, v);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO);
    check("PRISM shard1 fifo head holds (TX)", v == 0x11, v);
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO_STATUS, 0);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_FIFO_STATUS);
    check("PRISM shard1 fifo flush", (v & PRISM_FIFO_EMPTY) && PRISM_FIFO_COUNT(v) == 0, v);
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_CRC_POLY, 0x04C11DB7u);
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_CRC_EXPECTED, 0xDEBB20E3u);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_CRC_POLY);
    check("PRISM shard1 crc poly", v == 0x04C11DB7u, v);
    v = prism_read(PRISM_SHARD_BASE(1) + PRISM_SH_CRC_EXPECTED);
    check("PRISM shard1 crc expected", v == 0xDEBB20E3u, v);
    prism_write(PRISM_SHARD_BASE(1) + PRISM_SH_CFG0, 0);

    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    v = prism_read(PRISM_REG_CTRL);
    check("PRISM enable", (v & PRISM_CTRL_ENABLE) != 0, v);

    /* 24-bit output word to be shifted out to the 74595 */
    prism_write(PRISM_REG_PRELOAD, 0x00F05077);

    /* Breakpoint at state 3, then start the transfer via host_in */
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_BP0_EN | PRISM_DBG_BP0_SI(3));
    prism_write(PRISM_REG_HOST, 3);
    prism_write(PRISM_REG_HOST, 2);
    delay_cycles(100);

    v = prism_read(PRISM_REG_DBG_STATUS);
    check("PRISM breakpoint", PRISM_DBGS_CURR_SI(v) == 3 && (v & PRISM_DBGS_HALT), v);

    /* Single step */
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_STEP | PRISM_DBG_BP0_EN | PRISM_DBG_BP0_SI(3));
    v = prism_read(PRISM_REG_DBG_STATUS);
    check("PRISM single step", PRISM_DBGS_CURR_SI(v) == 4, v);   /* DELAY -> DELAY2 */

    /* Clear the halt interrupt, resume */
    prism_write_byte(PRISM_REG_INT_CLR, 0xC0);
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_HALT_REQ);
    prism_write(PRISM_REG_DBG_CTRL, 0);
    delay_cycles(1000);

    /* The 74165 model feeds 0x00BEEF; it lands in count1 */
    v = prism_read(PRISM_REG_COUNT1);
    check("PRISM gpio24 input", v == 0x0000BEEF, v);

    dputs("GPIO24 DONE");
    dnl();

    /* Same transfer again without the debugger in the loop: separates a
       core/chroma semantic problem from a halt/step timing problem. */
    prism_write(PRISM_REG_CTRL, 0);
    delay_cycles(64);
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    prism_write(PRISM_REG_PRELOAD, 0x00F05077);   /* same word: the cocotb 74595 model checks the last capture */

    /* LUT-conditional breakpoint: stop in DELAY2 (row 4) when its "else if"
       fires, i.e. after the 24th shift, before that transition's outputs. */
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_BP0_EN | PRISM_DBG_BP0_SI(4) | PRISM_DBG_BP0_COND(PRISM_BPC_ELSE_IF));
    prism_write(PRISM_REG_HOST, 3);
    prism_write(PRISM_REG_HOST, 2);
    delay_cycles(1500);
    v = prism_read(PRISM_REG_DBG_STATUS);
    check("PRISM LUT breakpoint", PRISM_DBGS_CURR_SI(v) == 4 && (v & PRISM_DBGS_HALT), v);
    v = prism_read(PRISM_REG_COUNT1);
    check("PRISM LUT breakpoint data", v == 0x0000BEEF, v);
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_HALT_REQ | PRISM_DBG_BP0_EN | PRISM_DBG_BP0_SI(4) | PRISM_DBG_BP0_COND(PRISM_BPC_ELSE_IF));
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_STEP | PRISM_DBG_HALT_REQ | PRISM_DBG_BP0_EN | PRISM_DBG_BP0_SI(4) | PRISM_DBG_BP0_COND(PRISM_BPC_ELSE_IF));
    v = prism_read(PRISM_REG_DBG_STATUS);
    check("PRISM LUT breakpoint step", PRISM_DBGS_CURR_SI(v) == 5 && (v & PRISM_DBGS_HALT), v);
    prism_write_byte(PRISM_REG_INT_CLR, 0xC0);
    prism_write(PRISM_REG_DBG_CTRL, PRISM_DBG_HALT_REQ);
    prism_write(PRISM_REG_DBG_CTRL, 0);
    delay_cycles(2000);
    v = prism_read(PRISM_REG_COUNT1);
    check("PRISM gpio24 plain input", v == 0x0000BEEF, v);
    dputs("GPIO24 PLAIN DONE");
    dnl();
}

int main(void)
{
    /* Keep uo_out[6] on the debug UART (debug_sel bit 6 low) and give
       uo_out[7] to the peripherals; disable register debug on out2-5. */
    set_register_debug(false);
    set_debug_sel(0x80);

    /* gpio24 chroma pins: out0 -> uo_out[1] (74165 load), out1 -> uo_out[2]
       (74595 store), out4 -> uo_out[5] (serial data), out6 -> uo_out[7]
       (shift clock).  uo_out[0] stays UART TX. */
    prism_claim_pins(0xA6);

    dputs("CFGMEM_VERIFY START");
    dnl();

    make_patterns();
    test_shift_readback();
    test_chain();
    test_chroma_load();
    test_prism_gpio24();

    dputs("CFGMEM_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
