/*
 * vga_verify: RISC-V driven system test of the VGA chroma pair with the SRAM
 * FIFO's line replay and one TX DMA copy per source line (2026-09-30).
 *
 * Runs on TinyQV inside the cocotb program testbench (test_prog.mk with
 * PROG=vga_verify).  The program writes a small frame buffer into RAM B
 * (SRC_LINES lines of 160 RGB222 bytes, eight lines per 2 KB slot at 256
 * bytes each, from slot 2), loads chroma_vga_ln into shard 0 and
 * chroma_vga_px into shard 1, sets their constants for a short frame
 * (SRC_LINES * 4 active lines, then 7 blank ones), copies line 0 into FIFO
 * B with the TX DMA and enables the PRISM.  Every source line is shown four
 * times: three showings re-push what they pop (CFG3[29] under the pixel
 * shard's cond_out[0], the line shard's replay flag), and as the fourth
 * begins the line shard raises its host interrupt; the program answers each
 * with one 160-byte TX DMA copy of the next line (its block within a slot,
 * TXDMA[28:26]), which lands behind the line being consumed.  From "VGA
 * START" test_vga_verify.py watches uo_out for two frames: every active
 * line must be its source line's bytes, 12 clocks a byte, black elsewhere,
 * the frames identical.  The program counts the requests it served over
 * the two frames and reports.
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
#include "tqv_prism.h"

extern const uint32_t chroma_vga_px[];
extern const uint32_t chroma_vga_px_ctrlReg;
extern const uint32_t chroma_vga_px_pinmuxReg;
extern const uint32_t chroma_vga_ln[];
extern const uint32_t chroma_vga_ln_ctrlReg;
extern const uint32_t chroma_vga_ln_pinmuxReg;

/* TX DMA: TinyQV internal peripheral space */
#define TXDMA_REG               (*(volatile uint32_t *)0x8000028u)
#define TXDMA_LEN(n)            ((n) & 0xfffu)
#define TXDMA_SLOT(s)           (((s) & 0xfffu) << 12)
#define TXDMA_BLOCK(b)          (((b) & 7u) << 26)
#define TXDMA_ACK               (1u << 30)
#define TXDMA_START             (1u << 31)
#define TXDMA_ST_DONE           (1u << 30)
#define TXDMA_ST_BUSY           (1u << 31)

#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define SLOT_BYTES              2048u
#define LINE_STRIDE             256u            /* eight lines per slot */

#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_CFG_FIFO_SRAM     (1u << 31)
#define PRISM_CTRL_IRQ0         (1u << 31)      /* shard 0 interrupt pending (RO) */
#define FIFO_COUNT(v)           (((v) >> 8) & 0x3fffu)

/* the pair's constants, as in test_vga (prism_tests.py), at the real line timing */
#define SRC_SLOT                2u
#define SRC_LINES               13u             /* slots 2 and 3 */
#define BYTES                   160u
#define UNIT                    12u             /* clocks per pixel byte */
#define A_LINES                 (SRC_LINES * 4u)
#define K1                      1u              /* vsync falls after K1 + 1 blank lines */
#define K2                      2u              /* ... and lasts K2 - K1 + 1 = 2 */
#define K3                      4u              /* K3 + 3 blank lines */
#define HS_UNITS                24u
#define BP_LIMIT                10u
#define FP_CLOCKS               48u
#define FRAMES                  2u
#define CFG3_CNT_EN             (1u << 10)
#define CFG3_FIFO_REPUSH        (1u << 29)
#define T2_RELOAD               (1u << 24)
#define T2_STATE(si)            (((si) & 0x1fu) << 25)
#define T2_ONESHOT              (1u << 30)
#define FP_STATE                3u              /* chroma_vga_px ST_FP */
/* COMM_PINS: base 0, uo_out[0..2] = lanes 5 4 3, uo_out[4..6] = lanes 2 1 0 */
#define COMM_LANE(uo, lane)     ((uint32_t)(lane) << (4 + 3 * (uo)))
#define VGA_COMM_PINS           (COMM_LANE(0, 5) | COMM_LANE(1, 4) | COMM_LANE(2, 3) | \
                                 COMM_LANE(4, 2) | COMM_LANE(5, 1) | COMM_LANE(6, 0))

#define POLL_LIMIT              400000u

static uint32_t pass_count;
static uint32_t fail_count;

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

/* Pixel byte i of source line ln: odd values 1..63, never 0, so the active
   window shows (no modulo: rv32ec has no divider and the fetch is slow);
   test_vga_verify.py computes the same. */
static uint8_t pixel(uint32_t ln, uint32_t i)
{
    return (uint8_t)(((ln * 37u + i * 11u) & 62u) + 1u);
}

static void fill_frame_buffer(void)
{
    /* word writes: a byte store is a whole QSPI transaction */
    for (uint32_t ln = 0; ln < SRC_LINES; ln++) {
        volatile uint32_t *p = RAM_B32 + (SRC_SLOT * SLOT_BYTES + ln * LINE_STRIDE) / 4;
        for (uint32_t i = 0; i < BYTES; i += 4)
            *p++ = (uint32_t)pixel(ln, i) | ((uint32_t)pixel(ln, i + 1) << 8) |
                   ((uint32_t)pixel(ln, i + 2) << 16) | ((uint32_t)pixel(ln, i + 3) << 24);
    }
}

/* One line into FIFO B: slot 2 + ln / 8, block ln % 8 */
static void dma_line(uint32_t ln)
{
    TXDMA_REG = TXDMA_START | TXDMA_LEN(BYTES) | TXDMA_SLOT(SRC_SLOT + (ln >> 3)) | TXDMA_BLOCK(ln & 7u);
}

static uint32_t dma_wait(void)
{
    uint32_t st = 0;
    for (uint32_t i = 0; i < POLL_LIMIT; i++) {
        st = TXDMA_REG;
        if (st & TXDMA_ST_DONE)
            break;
    }
    return st;
}

static uint32_t vga_setup(void)
{
    uint32_t errors;

    prism_write(PRISM_REG_CTRL, 0);
    /* the 16 lowest states of each chroma: bank A = shard 0 (line), bank B = shard 1 (pixel) */
    errors = prism_load_banks(chroma_vga_ln + PRISM_BANK_STATES * PRISM_STEW_WORDS,
                              chroma_vga_px + PRISM_BANK_STATES * PRISM_STEW_WORDS);
    prism_write(PRISM_REG_FRAC_CFG, 1);
    prism_write(PRISM_REG_OUT_MASK0, 0x1FFFFF);
    prism_write(PRISM_REG_COND_MASK0, 0x3);
    prism_write(PRISM_REG_OUT_MASK1, 0x1FFFFF);
    prism_write(PRISM_REG_COND_MASK1, 0x3);

    /* shard 0: the line shard */
    prism_write(PRISM_REG_CFG0, chroma_vga_ln_ctrlReg);
    prism_write(PRISM_REG_PINMUX, chroma_vga_ln_pinmuxReg);
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CFG3, CFG3_CNT_EN);
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CRC, 0);                   /* line counter preset */
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CRC_EXPECTED, A_LINES - 1);
    prism_write_byte(PRISM_SHARD_BASE(0) + PRISM_SH_COUNT3 + 1, 2);         /* three replays, then the next line */
    prism_write(PRISM_SHARD_BASE(0) + PRISM_SH_CONST, (K3 << 24) | (K2 << 16) | (K1 << 8));

    /* shard 1: the pixel shard on the SRAM FIFO */
    prism_write(SH1(PRISM_SH_CFG0), chroma_vga_px_ctrlReg | PRISM_CFG_FIFO_SRAM);
    prism_write(SH1(PRISM_SH_PINMUX), chroma_vga_px_pinmuxReg);
    prism_write(SH1(PRISM_SH_PRELOAD), UNIT - 1);
    prism_write_byte(SH1(PRISM_SH_COMPARE), BYTES - 1);
    prism_write(SH1(PRISM_SH_CFG3), CFG3_CNT_EN | CFG3_FIFO_REPUSH);
    prism_write(SH1(PRISM_SH_CRC_EXPECTED), HS_UNITS - 1);
    prism_write_byte(SH1(PRISM_SH_COUNT3) + 1, BP_LIMIT);
    prism_write(SH1(PRISM_SH_PRELOAD2), (FP_CLOCKS - 1) | T2_RELOAD | T2_STATE(FP_STATE) | T2_ONESHOT);
    prism_write(SH1(PRISM_SH_CONST), 0);                                   /* K0 = black */
    prism_write(SH1(PRISM_SH_COMM_PINS), VGA_COMM_PINS);
    prism_write(SH1(PRISM_SH_FIFO_STATUS), 0);                             /* flush FIFO B */
    return errors;
}

int main(void)
{
    uint32_t v, st, served = 0, late = 0, next = 1;

    dputs("VGA_VERIFY START");
    dnl();

    fill_frame_buffer();
    dputs("FRAME BUFFER WRITTEN");
    dnl();
    v = vga_setup();
    check("chromas loaded", v == 0, v);
    v = prism_read(SH1(PRISM_SH_COMM_PINS));
    check("shard 1 COMM_PINS", v == VGA_COMM_PINS, v);
    v = prism_read(SH1(PRISM_SH_PINMUX));
    check("shard 1 PINMUX (24 bits)", v == chroma_vga_px_pinmuxReg, v);

    /* line 0 into FIFO B before the picture starts */
    dma_line(0);
    st = dma_wait();
    TXDMA_REG = TXDMA_ACK;
    v = FIFO_COUNT(prism_read(SH1(PRISM_SH_FIFO_STATUS)));
    check("line 0 copied into FIFO B", (st & TXDMA_ST_DONE) && v == BYTES, v);
    prism_write_byte(PRISM_REG_INT_CLR, 0x80);

    dputs("VGA START lines=");
    dput_dec(SRC_LINES);
    dnl();
    delay_cycles(4000);                                                     /* let the line go out */
    prism_claim_pins(0xFF);                                                 /* all eight: the VGA PMOD */
    set_debug_sel(get_debug_sel() | (1u << 6));                             /* uo_out[6] is the debug UART otherwise */
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);

    /* serve the line requests for FRAMES frames: the line shard's interrupt
       as the fourth showing of a line begins, one TX DMA copy each */
    while (served < FRAMES * SRC_LINES) {
        if (!(prism_read(PRISM_REG_CTRL) & PRISM_CTRL_IRQ0))
            continue;
        prism_write_byte(PRISM_REG_INT_CLR, 0x80);
        if (TXDMA_REG & TXDMA_ST_BUSY)                                       /* the previous copy is still going: too slow */
            late++;
        dma_line(next);
        next = (next + 1u == SRC_LINES) ? 0u : next + 1u;
        served++;
    }
    delay_cycles(20000);                                                    /* the picture runs on a little */
    set_debug_sel(get_debug_sel() & ~(1u << 6));
    delay_cycles(6u * 2400u);

    check("line requests served", served == FRAMES * SRC_LINES, served);
    check("no copy started while the previous one ran", late == 0, late);
    st = TXDMA_REG;
    check("TX DMA idle", (st & TXDMA_ST_BUSY) == 0, st);
    prism_write(PRISM_REG_CTRL, 0);

    dputs("VGA_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
