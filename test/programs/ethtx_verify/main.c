/*
 * ethtx_verify: RISC-V driven system test of 10BASE-T transmission from
 * PSRAM.  The TX DMA (prism_txdma.v) copies a frame from a 2 KB slot of RAM
 * B into FIFO B (shard 1's SRAM FIFO on SRAM[1]) and the eth_tx chroma, run
 * fractured on shard 1, sends it Manchester coded at 6 clocks per bit:
 * TXD = uo_out[1], TX_EN = uo_out[2].  Shard 0 idles with its outputs
 * masked (it is where eth_rx goes for a loopback).
 *
 * Slot layout: bytes 0-3 = 55 55 55 D5 (the chroma sends four preamble
 * bytes from its constant K0 and takes the last three and the SFD from the
 * FIFO), the frame from byte 4 without its FCS (the chroma appends it from
 * the CRC unit).  An RX DMA ring slot has the same layout with the length
 * in bytes 0-1, so a received frame goes back out once word 0 is rewritten.
 * The chroma ends a frame when FIFO B runs empty, so one frame at a time is
 * copied, and it has no inter-frame gap timer: the host waits 96 bit times
 * after a frame's interrupt before it starts the next one.
 *
 * Runs in the cocotb program testbench (test_prog.mk PROG=ethtx_verify);
 * results go out over the debug UART.  Each "ETH FRAME len=N seed=SS" line
 * tells test_ethtx_verify.py which frame comes next; it decodes TXD / TX_EN
 * (eth_model.EthDecoder), checks every byte and the FCS, and that TX_EN
 * stays low for at least the inter-frame gap between frames.
 *
 *   1. a minimum frame (60 bytes + FCS), copied whole, then sent
 *   2. an odd length (101 bytes: the TX DMA's copy ends with a tail byte)
 *   3. a maximum frame (1514 bytes + FCS) sent while the TX DMA is still
 *      copying it: the chroma starts once FIFO B holds 64 bytes
 *   4. two frames back to back: the second is copied as soon as the first
 *      ends and started one inter-frame gap after it
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

/* TX DMA: TinyQV internal peripheral space (see txdma_verify) */
#define TXDMA_REG               (*(volatile uint32_t *)0x8000028u)
#define TXDMA_LEN(n)            ((n) & 0xfffu)
#define TXDMA_SLOT(s)           (((s) & 0xfffu) << 12)
#define TXDMA_ACK               (1u << 30)
#define TXDMA_START             (1u << 31)
#define TXDMA_ST_DONE           (1u << 30)
#define TXDMA_ST_BUSY           (1u << 31)
#define TXDMA_ST_LEFT(v)        ((v) & 0xfffu)

#define RAM_B32                 ((volatile uint32_t *)0x1800000u)
#define DMA_SLOT                2048u

#define SH1(r)                  (PRISM_SHARD_BASE(1) + (r))
#define PRISM_CFG_FIFO_SRAM     (1u << 31)
#define FIFO_COUNT(v)           (((v) >> 8) & 0x3fffu)
#define ALL_PINS_OFF            0x1FFFFFu       /* PINMUX: 7 = not driven, every pin */

#define BIT_CLOCKS              6u              /* preload 2: a half bit every 3 clocks */
#define IFG_CLOCKS              (96u * BIT_CLOCKS)
#define ETH_PREAMBLE_TAIL       0xD5555555u     /* slot bytes 0-3: 55 55 55 D5 */
#define STREAM_START            64u             /* bytes in FIFO B before a streamed frame starts */
#define SLOT_A                  0u
#define SLOT_B                  1u

#define POLL_LIMIT              400000u

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

/* Frame byte i, the FCS not included: broadcast destination, source
   02:00:00:00:00:seed, EtherType 0x88B5 (local experimental), then a
   pattern.  test_ethtx_verify.py builds the same bytes. */
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

/* A frame of n bytes in a slot behind 55 55 55 D5 */
static void fill_frame(uint32_t slot, uint32_t n, uint32_t seed)
{
    volatile uint32_t *w = RAM_B32 + slot * (DMA_SLOT / 4);

    w[0] = ETH_PREAMBLE_TAIL;
    for (uint32_t i = 0; i < n; i += 4)
        w[1 + i / 4] = eth_byte(seed, i) | ((uint32_t)eth_byte(seed, i + 1) << 8) |
                       ((uint32_t)eth_byte(seed, i + 2) << 16) | ((uint32_t)eth_byte(seed, i + 3) << 24);
}

/* Tell the line checker which frame comes next */
static void announce(uint32_t n, uint32_t seed)
{
    dputs("ETH FRAME len=");
    dput_dec(n);
    dputs(" seed=");
    dput_hex(seed, 2);
    dnl();
}

/* Copy a slot's preamble tail and frame into FIFO B */
static void tx_copy(uint32_t slot, uint32_t n)
{
    TXDMA_REG = TXDMA_START | TXDMA_SLOT(slot) | TXDMA_LEN(4 + n);
}

/* Wait for the copy to finish; the status, 0 on a timeout */
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
    return FIFO_COUNT(prism_read(SH1(PRISM_SH_FIFO_STATUS)));
}

/* Wait until FIFO B holds n bytes; false on a timeout */
static bool wait_fifo_b(uint32_t n)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++)
        if (fifo_b_count() >= n)
            return true;
    return false;
}

/* Start the frame in FIFO B: a toggle of shard 1's host_in[0] (the byte
   write also clears shard 1's interrupt) */
static void eth_send(void)
{
    prism_write_byte(SH1(PRISM_SH_TOGGLE), 0);
}

/* Wait for the chroma's end-of-frame interrupt (after TP_IDL, as TX_EN
   drops) and clear it; false on a timeout */
static bool eth_wait_sent(void)
{
    for (uint32_t spins = 0; spins < POLL_LIMIT; spins++) {
        if (prism_read(PRISM_REG_CTRL) & PRISM_CTRL_IRQ1) {
            prism_write_byte(PRISM_REG_INT_CLR1, 0x80);
            return true;
        }
    }
    return false;
}

/* Fractured: the eth_tx states in bank B for shard 1; bank A gets the
   table's unused rows and shard 0's outputs stay masked */
static uint32_t eth_setup(void)
{
    uint32_t errors;

    prism_write(PRISM_REG_CTRL, 0);
    errors = prism_load_banks(chroma_eth_tx, chroma_eth_tx + PRISM_BANK_STATES * PRISM_STEW_WORDS);
    prism_write(PRISM_REG_FRAC_CFG, 1);
    prism_write(PRISM_REG_OUT_MASK0, 0);
    prism_write(PRISM_REG_COND_MASK0, 0);
    prism_write(PRISM_REG_OUT_MASK1, 0x1FFFFF);
    prism_write(PRISM_REG_COND_MASK1, 0x3);
    prism_write(PRISM_REG_PINMUX, ALL_PINS_OFF);                              /* shard 0 claims no pin */
    prism_write(SH1(PRISM_SH_CFG0), chroma_eth_tx_ctrlReg | PRISM_CFG_FIFO_SRAM);  /* TX FIFO on SRAM[1] */
    prism_write(SH1(PRISM_SH_PINMUX), chroma_eth_tx_pinmuxReg);
    prism_write(SH1(PRISM_SH_CFG1), 8u | (9u << 4));                          /* in_prev0/1 <- host_in[0]/[1] */
    prism_write(SH1(PRISM_SH_CONST), 0x55);                                   /* K0 = preamble byte */
    prism_write_byte(SH1(PRISM_SH_COMPARE), 3);                               /* count2 phases of four */
    prism_write(SH1(PRISM_SH_PRELOAD), BIT_CLOCKS / 2 - 1);                   /* half-bit timer */
    prism_write(SH1(PRISM_SH_CRC_POLY), 0xEDB88320u);                         /* CRC32, reflected */
    prism_write(SH1(PRISM_SH_PRELOAD2), 0);                                   /* no link pulses */
    prism_write_byte(SH1(PRISM_SH_HOST), 0);
    prism_write(SH1(PRISM_SH_FIFO_STATUS), 0);                                /* flush FIFO B */
    prism_write(PRISM_REG_CTRL, PRISM_CTRL_ENABLE);
    prism_claim_pins((1u << 1) | (1u << 2));                                  /* TXD, TX_EN */
    return errors;
}

/* One frame copied whole, then sent */
static void send_whole(const char *name, uint32_t slot, uint32_t n, uint32_t seed)
{
    uint32_t st;

    fill_frame(slot, n, seed);
    announce(n, seed);
    tx_copy(slot, n);
    st = tx_wait();
    dputs(name);
    check(" copied", (st & TXDMA_ST_DONE) && fifo_b_count() == 4 + n, st);
    TXDMA_REG = TXDMA_ACK;
    eth_send();
    dputs(name);
    check(" sent", eth_wait_sent() && fifo_b_count() == 0, fifo_b_count());
}

int main(void)
{
    uint32_t st, st2, v, left, t0;

    dputs("ETHTX_VERIFY START");
    dnl();

    v = eth_setup();
    check("eth_tx loaded into bank B", v == 0, v);
    v = prism_read(SH1(PRISM_SH_CFG0));
    check("shard 1 CFG0", v == (chroma_eth_tx_ctrlReg | PRISM_CFG_FIFO_SRAM), v);
    dputs("ETH READY");
    dnl();

    /* 1. a minimum frame, 2. an odd length */
    send_whole("frame 1 (60 bytes)", SLOT_A, 60, 0x11);
    send_whole("frame 2 (101 bytes)", SLOT_B, 101, 0x22);

    /* 3. a maximum frame, started once 64 bytes are in while the TX DMA
          goes on copying: it has to stay ahead of the line */
    fill_frame(SLOT_A, 1514, 0x33);
    announce(1514, 0x33);
    tx_copy(SLOT_A, 1514);
    v = wait_fifo_b(STREAM_START);
    eth_send();
    left = TXDMA_ST_LEFT(TXDMA_REG);
    check("frame 3 started while copying", v && left > 256, left);           /* ~1000 left in the sim */
    st = tx_wait();
    check("frame 3 copied", (st & TXDMA_ST_DONE) && TXDMA_ST_LEFT(st) == 0, st);
    TXDMA_REG = TXDMA_ACK;
    check("frame 3 (1514 bytes) sent", eth_wait_sent() && fifo_b_count() == 0, fifo_b_count());

    /* 4. back to back: the second frame is copied as soon as the first
          ends and started one inter-frame gap later (no output until then,
          the UART would stretch the gap) */
    fill_frame(SLOT_A, 200, 0x44);
    fill_frame(SLOT_B, 60, 0x55);
    announce(200, 0x44);
    announce(60, 0x55);
    tx_copy(SLOT_A, 200);
    st = tx_wait();
    TXDMA_REG = TXDMA_ACK;
    eth_send();
    v = eth_wait_sent();
    t0 = read_cycle();
    tx_copy(SLOT_B, 60);
    st2 = tx_wait();
    TXDMA_REG = TXDMA_ACK;
    while ((uint32_t)(read_cycle() - t0) < IFG_CLOCKS)
        ;
    eth_send();
    check("frame 4a (200 bytes) sent", v && (st & TXDMA_ST_DONE), st);
    check("frame 4b (60 bytes) copied in the gap", (st2 & TXDMA_ST_DONE) != 0, st2);
    check("frame 4b sent", eth_wait_sent() && fifo_b_count() == 0, fifo_b_count());

    prism_write(PRISM_REG_CTRL, 0);

    dputs("ETHTX_VERIFY END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    dnl();

    while (1)
        ;
}
