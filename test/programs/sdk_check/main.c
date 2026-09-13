/*
 * sdk_check: drive the PRISM through the tinyQV-sdk driver compiled for this
 * design (PRISM_CONFIG_JANESTREET) and report over the debug UART.
 *
 *   1. load chroma_uart_tx with prism_load_chroma_ex, push bytes into the
 *      TX FIFO, check the CRC8, request the CRC trailer (host_in[0]) and
 *      handle the interrupt.  The cocotb side decodes the UART on uo_out[1].
 *   2. conditional breakpoint in the DATA state, single step, resume.
 *   3. fracture: encoder in shard 0, ws2812 in shard 1, per-shard registers
 *      and interrupt through prism_set_shard().
 *   4. CFGMEM pattern self test.
 */
#include <stdint.h>
#include <stdbool.h>
#include <gpio.h>
#include <uart.h>
#include <csr.h>
#include <prism.h>

extern const uint32_t chroma_uart_tx[];
extern const uint32_t chroma_uart_tx_ctrlReg;
extern const uint32_t chroma_uart_tx_pinmuxReg;
extern const uint32_t chroma_encoder[];
extern const uint32_t chroma_encoder_ctrlReg;
extern const uint32_t chroma_encoder_pinmuxReg;
extern const uint32_t chroma_ws2812[];
extern const uint32_t chroma_ws2812_ctrlReg;
extern const uint32_t chroma_ws2812_pinmuxReg;

#define UART_TX_STATE_IDLE      0
#define UART_TX_STATE_DATA      2
#define UART_TX_STATE_DATA_CHECK 3
#define UART_TX_STATE_WAIT_ACK  9
#define BIT_PERIOD              64          /* clocks; preload = period - 2 */
#define POLL_LIMIT              200000

static uint32_t pass_count;
static uint32_t fail_count;

static void dputs(const char *s)
{
    while (*s)
        debug_uart_putc(*s++);
}

static void dput_hex(uint32_t v, int digits)
{
    static const char hex[] = "0123456789ABCDEF";
    for (int d = digits - 1; d >= 0; d--)
        debug_uart_putc(hex[(v >> (d * 4)) & 0xf]);
}

static void dput_dec(uint32_t v)
{
    char buf[12];
    int n = 0;
    do {
        buf[n++] = '0' + (v % 10);
        v /= 10;
    } while (v);
    while (n)
        debug_uart_putc(buf[--n]);
}

static void check(const char *name, bool ok, uint32_t value)
{
    dputs(name);
    dputs(ok ? ": PASS " : ": FAIL ");
    dput_hex(value, 8);
    debug_uart_putc('\n');
    if (ok) pass_count++; else fail_count++;
}

/* Bit model of the PRISM CRC (non-reflected, poly 0x07) over UART bit order */
static uint32_t crc8_lsb_first(const uint8_t *data, int n)
{
    uint32_t crc = 0;
    for (int i = 0; i < n; i++)
        for (int b = 0; b < 8; b++) {
            uint32_t fb = ((crc >> 7) & 1) ^ ((data[i] >> b) & 1);
            crc = ((crc << 1) ^ (fb ? 0x07 : 0)) & 0xFF;
        }
    return crc;
}

static bool wait_idle(void)
{
    for (uint32_t i = 0; i < POLL_LIMIT; i++)
        if (prism_fifo_empty() && prism_dbg_curr_state() == UART_TX_STATE_IDLE)
            return true;
    return false;
}

static bool wait_interrupt(void)
{
    for (uint32_t i = 0; i < POLL_LIMIT; i++)
        if (prism_interrupt_pending())
            return true;
    return false;
}

int main(void)
{
    static const uint8_t data[] = { 0x55, 0xA3, 0x0F };
    uint32_t v;
    int err;

    dputs("SDK_CHECK START\n");
    dputs("config " PRISM_CFG_NAME "\n");

    /* ---- 1. UART transmitter from the TX FIFO, CRC trailer ------------ */
    prism_claim_pins(0x02);                     /* uo_out[1] = TXD */
    err = prism_load_chroma_ex(chroma_uart_tx, chroma_uart_tx_ctrlReg, chroma_uart_tx_pinmuxReg);
    check("load uart_tx", err == 0, (uint32_t)err);
    check("enabled", prism_is_enabled(), prism_get_ctrl());
    check("ctrl readback", (prism_get_ctrl() & PRISM_CTRL_CFG_MASK) == chroma_uart_tx_ctrlReg, prism_get_ctrl());
    check("pinmux readback", prism_get_pinmux() == chroma_uart_tx_pinmuxReg, prism_get_pinmux());
    v = prism_get_id();
    check("id word", v != 0 && v != 0xFFFFFFFFu, v);

    prism_set_count1_preload(BIT_PERIOD - 2);
    prism_crc_set_poly(0x07);
    for (int i = 0; i < 3; i++)
        check("fifo push", prism_fifo_push(data[i]), data[i]);
    check("fifo drained", wait_idle(), prism_fifo_status());
    check("crc8", prism_crc_get() == crc8_lsb_first(data, 3), prism_crc_get());

    prism_host_write(1);                        /* send the CRC trailer */
    check("trailer irq", wait_interrupt(), prism_get_ctrl());
    check("wait_ack state", prism_dbg_curr_state() == UART_TX_STATE_WAIT_ACK, prism_dbg_status());
    prism_host_write(0);
    prism_clear_interrupt();
    check("irq cleared", !prism_interrupt_pending(), prism_get_ctrl());
    check("back to idle", wait_idle(), prism_dbg_status());
    check("crc cleared", prism_crc_get() == 0, prism_crc_get());

    /* ---- 2. conditional breakpoint: DATA state when its bit time ends -- */
    prism_dbg_set_breakpoint_cond(0, UART_TX_STATE_DATA, PRISM_BPC_IF);
    prism_fifo_push(0x5A);
    check("cond break", prism_dbg_wait_halt(1000) && prism_dbg_curr_state() == UART_TX_STATE_DATA, prism_dbg_status());
    check("break flag", prism_dbg_break_active(), prism_dbg_status());
    check("step", prism_dbg_step() && prism_dbg_curr_state() == UART_TX_STATE_DATA_CHECK, prism_dbg_status());
    prism_dbg_clear_breakpoint(0);
    prism_dbg_resume();
    check("resumed", wait_idle() && !prism_dbg_is_halted(), prism_dbg_status());
    prism_clear_interrupt();                    /* the halt raised it */

    /* ---- 3. fractured: encoder (shard 0) + ws2812 (shard 1) ------------ */
    err = prism_load_shards(chroma_encoder, chroma_encoder_ctrlReg, chroma_encoder_pinmuxReg,
                            chroma_ws2812,  chroma_ws2812_ctrlReg,  chroma_ws2812_pinmuxReg);
    check("load shards", err == 0, (uint32_t)err);
    check("fractured", prism_is_fractured(), prism_read32(PRISM_REG_FRAC_CFG));
    prism_set_shard(1);
    check("shard select", prism_get_shard() == 1, prism_shard_reg(0));
    check("shard1 ctrl", (prism_get_ctrl() & PRISM_CTRL_CFG_MASK) == chroma_ws2812_ctrlReg, prism_get_ctrl());
    prism_set_count2_compare(51);
    prism_comm_write(26);
    prism_set_count1_preload(0x00FF5367);
    check("shard1 compare", prism_get_count2_compare() == 51, prism_get_count2_compare());
    check("shard1 comm", prism_comm_read() == 26, prism_comm_read());
    prism_host_write(1);                        /* start a pixel: raises the shard 1 IRQ */
    check("shard1 irq", wait_interrupt(), prism_read32(PRISM_REG_CTRL));
    prism_set_shard(0);
    check("shard0 no irq", !prism_interrupt_pending(), prism_read32(PRISM_REG_CTRL));
    check("shard0 ctrl", (prism_get_ctrl() & PRISM_CTRL_CFG_MASK) == chroma_encoder_ctrlReg, prism_get_ctrl());
    prism_set_shard(1);
    prism_clear_interrupt();
    check("shard1 irq cleared", !prism_interrupt_pending(), prism_read32(PRISM_REG_CTRL));
    prism_set_shard(0);
    prism_set_fractured(false, 0, 0, 0, 0);

    /* ---- 4. CFGMEM pattern self test (leaves the PRISM disabled) ------- */
    err = prism_test_config();
    check("config self test", err == 0, (uint32_t)err);
    check("disabled after test", !prism_is_enabled(), prism_get_ctrl());

    dputs("SDK_CHECK END pass=");
    dput_dec(pass_count);
    dputs(" fail=");
    dput_dec(fail_count);
    debug_uart_putc('\n');

    while (1)
        ;
    return 0;
}
