/*
 * Register map and access helpers for the TinyQV PRISM design in this repo
 * (CFGMEM peripheral 4 + PRISM peripheral 8).  Shared by the RISC-V test
 * programs under test/programs/.
 *
 * NOTE: this design differs from the ttsky25a PRISM in the tinyQV-sdk
 * (prism.h): the State Information Table (STEW per state) lives in the
 * CFGMEM macros and is loaded through the CFGMEM peripheral, not through
 * PRISM_REG_CFG_LSW/MSW.
 *
 * CFGMEM peripheral (base PERI_BASE_ADDRESS(4) = 0x8000100)
 *   0x00 + i*4  write: shift a 32-bit word into "lo" macro i (i = 0..3).
 *               read : "hi" macro i output word at row CFGMEM_CTRL addr.
 *   0x20 + i*4  write: shift the lo[i] output word into "hi" macro i
 *               (hi.Di0 = lo.Do0; with BYP_LO set the written data goes
 *               straight through lo into hi).
 *   0x1f        control BYTE (0x1f is not word aligned, so use 8-bit
 *               accesses): [3:0] row address, [4] address select (1 = use
 *               [3:0], 0 = PRISM drives the address), [5] (read only)
 *               loader FSM busy, [6] bypass lo, [7] bypass hi.
 *
 *   Each macro is a 16 x 32 shift-loaded, random-read memory: a shift
 *   write puts the new word in row 0 and moves row r to row r+1, so the
 *   first word written ends up in row 15 and the last in row 0.  Every
 *   shift write takes ~50 clocks (WROW walks rows 15..0); poll BUSY.
 *
 * PRISM peripheral (base PERI_BASE_ADDRESS(8) = 0x8000200)
 *   32 states, 128-bit STEW: states 0-15 live in the lo macros (bank A,
 *   stew bits [31:0] = lo[0] ... [127:96] = lo[3]) and states 16-31 in the
 *   hi macros (bank B).  Fractured, shard 0 runs bank A and shard 1 bank B.
 */
#pragma once

#include <stdint.h>
#include <gpio.h>
#include <csr.h>

#define CFGMEM_PERIPHERAL_NUM   4
#define PRISM_PERIPHERAL_NUM    8

#define CFGMEM_BASE_ADDRESS     PERI_BASE_ADDRESS(CFGMEM_PERIPHERAL_NUM)
#define PRISM_BASE_ADDRESS      PERI_BASE_ADDRESS(PRISM_PERIPHERAL_NUM)

#define CFGMEM_COUNT            4       /* lo/hi macro pairs           */
#define CFGMEM_DEPTH            16      /* rows per macro              */

#define CFGMEM_REG_LO(i)        ((i) * 4)
#define CFGMEM_REG_HI(i)        (0x20 + (i) * 4)
#define CFGMEM_REG_CTRL         0x1f

#define CFGMEM_CTRL_ADDR(r)     ((r) & 0xf)
#define CFGMEM_CTRL_ADDR_SEL    (1u << 4)
#define CFGMEM_CTRL_BUSY        (1u << 5)   /* read only */
#define CFGMEM_CTRL_BYP_LO      (1u << 6)
#define CFGMEM_CTRL_BYP_HI      (1u << 7)

/* PRISM registers (byte offsets in the 512-byte region; docs/prism_interface.md) */
#define PRISM_REG_CTRL          0x00    /* [31] interrupt (RO), [30] enable */
#define PRISM_REG_INT_CLR       0x03    /* byte write, bit 7 clears the shard 0 IRQ */
#define PRISM_REG_INT_CLR1      0x07    /* byte write, bit 7 clears the shard 1 IRQ */
#define PRISM_REG_DBG_CTRL      0x04    /* shard 0 debug control */
#define PRISM_REG_DBG_CTRL1     0x08    /* shard 1 debug control */
#define PRISM_REG_DBG_STATUS    0x0c
#define PRISM_REG_STEW0         0x10    /* current STEW of shard 0, 4 words */
#define PRISM_REG_ID            0x20
#define PRISM_REG_INT_STATUS    0x24    /* [3:2] semaphore seen by shard 1 / 0, [1:0] shard IRQs */
#define PRISM_REG_DEBUG_DOUT    0x30
#define PRISM_REG_DECISION      0x34
#define PRISM_REG_OUT_DATA      0x38
#define PRISM_REG_IN_DATA       0x3c
#define PRISM_REG_FRAC_CFG      0x40    /* bit 0: fractured */
#define PRISM_REG_OUT_MASK0     0x44
#define PRISM_REG_COND_MASK0    0x48
#define PRISM_REG_OUT_MASK1     0x4c
#define PRISM_REG_COND_MASK1    0x50

/* Per-shard window (shard 0 at 0x100, shard 1 at 0x180) */
#define PRISM_SHARD_BASE(s)     (0x100 + (s) * 0x80)
#define PRISM_SH_CFG0           0x00    /* chroma ctrl_reg: datapath configuration */
#define PRISM_SH_PINMUX         0x04    /* chroma pinmux_reg: uo_out[7:1] sources */
#define PRISM_SH_PRELOAD        0x08    /* 32-bit */
#define PRISM_SH_COUNT1         0x0c    /* read count1; write loads it */
#define PRISM_SH_COUNTS         0x10    /* {comm_count, shift_count, comm, compare, count2}; byte lanes writable */
#define PRISM_SH_COUNT2         0x10    /* byte */
#define PRISM_SH_COMPARE        0x11    /* byte */
#define PRISM_SH_COMM           0x12    /* byte */
#define PRISM_SH_HOST           0x14    /* host_in[1:0] */
#define PRISM_SH_TOGGLE         0x15    /* byte write: toggle host_in[0], clear IRQ */
#define PRISM_SH_FLAGS          0x18    /* RO datapath flags */

/* Shard 0 shortcuts */
#define PRISM_REG_CFG0          (PRISM_SHARD_BASE(0) + PRISM_SH_CFG0)
#define PRISM_REG_PINMUX        (PRISM_SHARD_BASE(0) + PRISM_SH_PINMUX)
#define PRISM_REG_PRELOAD       (PRISM_SHARD_BASE(0) + PRISM_SH_PRELOAD)
#define PRISM_REG_COUNT1        (PRISM_SHARD_BASE(0) + PRISM_SH_COUNT1)
#define PRISM_REG_COUNTS        (PRISM_SHARD_BASE(0) + PRISM_SH_COUNTS)
#define PRISM_REG_COUNT2        (PRISM_SHARD_BASE(0) + PRISM_SH_COUNT2)
#define PRISM_REG_COMPARE       (PRISM_SHARD_BASE(0) + PRISM_SH_COMPARE)
#define PRISM_REG_COMM          (PRISM_SHARD_BASE(0) + PRISM_SH_COMM)
#define PRISM_REG_HOST          (PRISM_SHARD_BASE(0) + PRISM_SH_HOST)
#define PRISM_REG_TOGGLE        (PRISM_SHARD_BASE(0) + PRISM_SH_TOGGLE)
#define PRISM_REG_FLAGS         (PRISM_SHARD_BASE(0) + PRISM_SH_FLAGS)

/* CFG0 bits (prism_datapath.v) */
#define PRISM_CFG_SHIFT_IN_SEL(n) ((n) & 3)
#define PRISM_CFG_CLR_NOT_LOAD  (1u << 6)
#define PRISM_CFG_LATCH_IN_OUT  (1u << 7)
#define PRISM_CFG_SHIFT_EN      (1u << 8)
#define PRISM_CFG_SHIFT_DIR     (1u << 9)
#define PRISM_CFG_SHIFT_WIDE    (1u << 10)
#define PRISM_CFG_COUNT32       (1u << 11)
#define PRISM_CFG_COUNT2_DEC_EN (1u << 12)
#define PRISM_CFG_LATCH_EN      (1u << 13)
#define PRISM_CFG_COUNT_UP      (1u << 14)
#define PRISM_CFG_WRAP_PRELOAD  (1u << 15)
#define PRISM_CFG_SHIFT_LOAD_ONE (1u << 16)
#define PRISM_CFG_COMM_LOAD_ONE (1u << 17)
#define PRISM_CFG_IN_SYNC_SEL(n) (((n) & 3u) << 18)  /* 0 = 2 flops, 1 = 1 flop, 2 = raw pins */
#define PRISM_CFG_SEMA_SET_WINS (1u << 24)

/* Interrupt lines (TinyQV user interrupts): shard 0 = 8, shard 1 = 9 */
#define PRISM_IRQ_SHARD0        8
#define PRISM_IRQ_SHARD1        9
#define PRISM_CTRL_IRQ1         (1u << 29)  /* shard 1 interrupt pending (RO) */

#define PRISM_CTRL_ENABLE       (1u << 30)

/* Debug control register bits (prism.v debug_ctrl0) */
#define PRISM_DBG_HALT_REQ      (1u << 0)
#define PRISM_DBG_STEP          (1u << 1)
#define PRISM_DBG_BP0_EN        (1u << 2)
#define PRISM_DBG_BP1_EN        (1u << 3)
#define PRISM_DBG_BP0_SI(si)    (((si) & 0x1f) << 4)
#define PRISM_DBG_BP1_SI(si)    (((si) & 0x1f) << 9)
#define PRISM_DBG_NEW_SI(si)    ((1u << 14) | (((si) & 0x1f) << 15))  /* load SI on write */

/* Debug status register fields */
/* shard 0 in [12:0], shard 1 in [25:13]: {break[1:0], halt, next_si, curr_si} */
#define PRISM_DBGS_CURR_SI(v)   ((v) & 0x1f)
#define PRISM_DBGS_NEXT_SI(v)   (((v) >> 5) & 0x1f)
#define PRISM_DBGS_HALT         (1u << 10)
#define PRISM_DBGS_BREAK        (3u << 11)
#define PRISM_DBGS_SHARD1(v)    (((v) >> 13) & 0x1fff)

/* STEW / chroma geometry (chromas/tinyqv32.cfg) */
#define PRISM_STATES            32
#define PRISM_BANK_STATES       16      /* rows per CFGMEM bank */
#define PRISM_STEW_WORDS        4       /* 128-bit STEW = 4 x 32 */

/* ---------------------------------------------------------------------- */

static inline void cfgmem_write(uint32_t reg, uint32_t value)
{
    *(volatile uint32_t *)(CFGMEM_BASE_ADDRESS + reg) = value;
}

static inline uint32_t cfgmem_read(uint32_t reg)
{
    return *(volatile uint32_t *)(CFGMEM_BASE_ADDRESS + reg);
}

static inline void cfgmem_ctrl(uint8_t value)
{
    *(volatile uint8_t *)(CFGMEM_BASE_ADDRESS + CFGMEM_REG_CTRL) = value;
}

static inline uint8_t cfgmem_ctrl_read(void)
{
    return *(volatile uint8_t *)(CFGMEM_BASE_ADDRESS + CFGMEM_REG_CTRL);
}

/* Wait for the shift-load FSM to finish walking the rows. */
static inline void cfgmem_wait(void)
{
    while (cfgmem_ctrl_read() & CFGMEM_CTRL_BUSY)
        ;
}

/* Shift one word into lo macro i (row 0; older rows move up). */
static inline void cfgmem_shift_lo(uint32_t i, uint32_t value)
{
    cfgmem_write(CFGMEM_REG_LO(i), value);
    cfgmem_wait();
}

/* Shift lo[i]'s current output word into hi macro i. */
static inline void cfgmem_shift_hi(uint32_t i, uint32_t value)
{
    cfgmem_write(CFGMEM_REG_HI(i), value);
    cfgmem_wait();
}

/* Read row r of hi macro i (no bypass). */
static inline uint32_t cfgmem_read_hi(uint32_t i, uint32_t row)
{
    cfgmem_ctrl(CFGMEM_CTRL_ADDR_SEL | CFGMEM_CTRL_ADDR(row));
    return cfgmem_read(CFGMEM_REG_LO(i));
}

/* Read row r of lo macro i, looking through the bypassed hi macro. */
static inline uint32_t cfgmem_read_lo(uint32_t i, uint32_t row)
{
    cfgmem_ctrl(CFGMEM_CTRL_BYP_HI | CFGMEM_CTRL_ADDR_SEL | CFGMEM_CTRL_ADDR(row));
    return cfgmem_read(CFGMEM_REG_LO(i));
}

/* Hand the row address back to PRISM and clear the bypasses. */
static inline void cfgmem_release(void)
{
    cfgmem_ctrl(0);
}

/*
 * Load a chroma as emitted by yosys-prism: the highest state first, state 0
 * last, PRISM_STEW_WORDS words per state with the most significant word
 * first.  Word 0 goes to macro 3 ... word 3 to macro 0.  States 16-31 are
 * loaded first into the hi macros (bank B) through the bypassed lo macros,
 * then states 15-0 into the lo macros; the last word shifted in lands in
 * row 0.  Returns the number of words that read back wrong.
 */
static inline uint32_t prism_load_chroma(const uint32_t *chroma, uint32_t states)
{
    uint32_t errors = 0;
    const uint32_t *w = chroma;
    uint32_t lo_states = states > PRISM_BANK_STATES ? PRISM_BANK_STATES : states;

    if (states > PRISM_BANK_STATES) {
        cfgmem_ctrl(CFGMEM_CTRL_BYP_LO);
        for (uint32_t k = 0; k < states - PRISM_BANK_STATES; k++)
            for (uint32_t j = 0; j < PRISM_STEW_WORDS; j++)
                cfgmem_shift_hi(PRISM_STEW_WORDS - 1 - j, *w++);
    }
    cfgmem_ctrl(0);
    for (uint32_t k = 0; k < lo_states; k++)
        for (uint32_t j = 0; j < PRISM_STEW_WORDS; j++)
            cfgmem_shift_lo(PRISM_STEW_WORDS - 1 - j, *w++);

    for (uint32_t s = 0; s < states; s++) {
        const uint32_t *ws = chroma + (states - 1 - s) * PRISM_STEW_WORDS;
        for (uint32_t j = 0; j < PRISM_STEW_WORDS; j++) {
            uint32_t inst = PRISM_STEW_WORDS - 1 - j;
            uint32_t got  = s < PRISM_BANK_STATES ? cfgmem_read_lo(inst, s)
                                                  : cfgmem_read_hi(inst, s - PRISM_BANK_STATES);
            if (got != ws[j]) errors++;
        }
    }
    cfgmem_release();
    return errors;
}

/* ---------------------------------------------------------------------- */

static inline void prism_write(uint32_t reg, uint32_t value)
{
    *(volatile uint32_t *)(PRISM_BASE_ADDRESS + reg) = value;
}

static inline void prism_write_byte(uint32_t reg, uint8_t value)
{
    *(volatile uint8_t *)(PRISM_BASE_ADDRESS + reg) = value;
}

static inline uint32_t prism_read(uint32_t reg)
{
    return *(volatile uint32_t *)(PRISM_BASE_ADDRESS + reg);
}

static inline uint8_t prism_read_byte(uint32_t reg)
{
    return *(volatile uint8_t *)(PRISM_BASE_ADDRESS + reg);
}

/* Route uo_out pins (bit mask) to the PRISM peripheral. */
static inline void prism_claim_pins(uint32_t mask)
{
    for (uint32_t pin = 0; pin < 8; pin++)
        if (mask & (1u << pin))
            set_gpio_func(pin, PRISM_PERIPHERAL_NUM);
}

static inline void delay_cycles(uint32_t cycles)
{
    uint32_t start = read_cycle();
    while ((uint32_t)(read_cycle() - start) < cycles)
        ;
}
