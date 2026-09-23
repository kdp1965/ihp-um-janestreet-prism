# The PRISM test bench: clock, TinyQV bus, CFGMEM loading, chroma loading,
# and the optional execution tracer.  One bench per simulation; every
# cocotb test resets it and runs one PrismTest subclass on it.

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

from tqv import TinyQV
from user_peripherals.prism.regs import *


class PrismBench:
    _instance = None

    @classmethod
    async def get(cls, dut):
        ''' The one bench of this simulation, created on first use '''
        if cls._instance is None:
            cls._instance = cls(dut)
        return cls._instance

    def __init__(self, dut):
        self.dut = dut
        self.tqv = TinyQV(dut, PERIPHERAL_NUM)
        self.cfg = TinyQV(dut, CFGMEM_PERIPHERAL_NUM)   # STEW loader (no reset: shares the bus)
        self.chroma = ''                                 # name of the running chroma (tracer)

    def log(self, msg):
        self.dut._log.info(msg)

    async def reset(self):
        ''' Start of a test: cocotb kills every task when a test ends, so the
            clock (and the tracer) start again here; then reset TinyQV and
            the peripheral.  The PRISM comes up disabled. '''
        self.chroma = ''
        cocotb.start_soon(Clock(self.dut.clk, 16, units="ns").start())
        if os.environ.get("PRISM_TRACE", "0") == "1":
            cocotb.start_soon(self.trace())
        for k in range(8):                       # a stray model drive on ui_in[1] at reset would put
            self.dut.ui_in[k].value = 0          # TinyQV into debug mode (uo_out[5:2] hijacked)
        await self.tqv.reset()

    async def clocks(self, n):
        for _ in range(n):
            await RisingEdge(self.dut.clk)

    delay = clocks

    # ---- PRISM control ---------------------------------------------------------
    async def enable(self):
        await self.tqv.write_word_reg(REG_CTRL, CTRL_ENABLE)

    async def disable(self):
        await self.tqv.write_word_reg(REG_CTRL, 0)

    async def irq(self, mask=IRQ0_MASK):
        return (await self.tqv.read_word_reg(REG_CTRL) & mask) != 0

    async def dbg_status(self, shard=0):
        ''' The shard's 13-bit debugger status field '''
        return (await self.tqv.read_word_reg(REG_DBG_STATUS) >> (13 * shard)) & 0x1fff

    async def curr_state(self, shard=0):
        return await self.dbg_status(shard) & 0x1f

    # ---- CFGMEM (state table) --------------------------------------------------
    async def cfgmem_wait(self):
        ''' Wait for the CFGMEM shift-load FSM (control byte bit 5 = busy) '''
        for _ in range(8):
            if (await self.cfg.read_byte_reg(CFGMEM_REG_CTRL) & CFGMEM_CTRL_BUSY) == 0:
                return
        assert False, "CFGMEM loader stuck busy"

    async def cfgmem_read_lo(self, inst, row):
        ''' Row `row` of lo macro `inst` (bypass off) '''
        await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_ADDR_SEL | row)
        return await self.cfg.read_word_reg(CFGMEM_REG_LO(inst))

    async def cfgmem_read_hi(self, inst, row):
        ''' Row `row` of hi macro `inst` (bypass off) '''
        await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_ADDR_SEL | row)
        return await self.cfg.read_word_reg(CFGMEM_REG_HI(inst))

    async def load_banks(self, lo_words, hi_words):
        '''
           Loads the PRISM State Information Table (the CFGMEM macros).
           lo_words / hi_words list the states of bank A / bank B highest
           state first, 4 words per state, MSW first; word 0 -> macro 3 ...
           word 3 -> macro 0.  Each bank's macros form two chains, one per
           macro column (host -> 0 -> 1 and host -> 2 -> 3); with the bank's
           bypass bit set every macro sees the host word and is shifted with
           its own strobe.  State s ends
           up in row s of its bank.
        '''
        await self.disable()
        await self.clocks(64)
        assert (await self.tqv.read_word_reg(REG_CTRL) & 0xFFFF) == 0

        if hi_words:
            await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_HI)
            for i, wv in enumerate(hi_words):
                j = i % STEW_WORDS
                await self.cfg.write_word_reg(CFGMEM_REG_HI(STEW_WORDS - 1 - j), wv)
                await self.cfgmem_wait()
        await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
        for i, wv in enumerate(lo_words):
            j = i % STEW_WORDS
            await self.cfg.write_word_reg(CFGMEM_REG_LO(STEW_WORDS - 1 - j), wv)
            await self.cfgmem_wait()
        await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

        # Validate a few rows of each bank (row 0 = last words written)
        for words, rd in ((lo_words, self.cfgmem_read_lo), (hi_words, self.cfgmem_read_hi)):
            if not words:
                continue
            states = len(words) // STEW_WORDS
            for s_idx in (0, 1, states - 1):
                base = (states - 1 - s_idx) * STEW_WORDS
                for j in range(STEW_WORDS):
                    got = await rd(STEW_WORDS - 1 - j, s_idx)
                    assert got == words[base + j], f"row {s_idx} word {j}: {got:#x} != {words[base+j]:#x}"
        # Hand the row address back to PRISM
        await self.cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

    @staticmethod
    def bank_rows(chroma):
        ''' The 16 lowest states of a 32-state chroma table (one bank) '''
        return chroma[-BANK_STATES * STEW_WORDS:]

    async def program_shard(self, base, ctrl_reg, pinmux_reg):
        await self.tqv.write_word_reg(REG_CFG0 + base, ctrl_reg)
        await self.tqv.write_word_reg(REG_PINMUX + base, pinmux_reg)
        assert await self.tqv.read_word_reg(REG_CFG0 + base) == ctrl_reg
        assert await self.tqv.read_word_reg(REG_PINMUX + base) == pinmux_reg

    async def load_chroma(self, chroma, ctrl_reg, pinmux_reg):
        ''' Unfractured: one 32-state chroma, shard 0 configuration, then enable '''
        states = len(chroma) // STEW_WORDS
        if states > BANK_STATES:
            await self.load_banks(chroma[(states - BANK_STATES) * STEW_WORDS:],
                                  chroma[:(states - BANK_STATES) * STEW_WORDS])
        else:
            await self.load_banks(chroma, [])
        await self.tqv.write_word_reg(REG_FRAC_CFG, 0)
        await self.program_shard(0, ctrl_reg, pinmux_reg)
        await self.enable()

    async def load_fractured(self, chroma_a, ctrl_a, pinmux_a, chroma_b, ctrl_b, pinmux_b):
        ''' Fractured: chroma A (16 states) in shard 0, chroma B in shard 1, then enable '''
        await self.load_banks(self.bank_rows(chroma_a), self.bank_rows(chroma_b))
        await self.tqv.write_word_reg(REG_FRAC_CFG, 1)
        await self.tqv.write_word_reg(REG_OUT_MASK0, 0x1FFFFF)
        await self.tqv.write_word_reg(REG_OUT_MASK1, 0x1FFFFF)
        await self.tqv.write_word_reg(REG_COND_MASK0, 0x3)
        await self.tqv.write_word_reg(REG_COND_MASK1, 0x3)
        await self.program_shard(0, ctrl_a, pinmux_a)
        await self.program_shard(SHARD1, ctrl_b, pinmux_b)
        await self.enable()

    # ---- execution tracer (PRISM_TRACE=1): log every state change of shard 0 ----
    async def trace(self):
        dut  = self.dut
        core = dut.user_project.i_peripherals.i_prism.i_prism
        sh0  = dut.user_project.i_peripherals.i_prism.SH[0]
        def iv(sig):
            try: return int(sig.value)
            except ValueError: return -1
        last = None; n = 0; cyc = 0
        limit = int(os.environ.get("PRISM_TRACE_MAX", "400"))
        while n < limit:
            await RisingEdge(dut.clk)
            cyc += 1
            cur = iv(core.curr_si[0])
            if cur != last:
                dut._log.info(f"TRACE @{cyc:6d} si {last}->{cur} in={iv(core.in_data):08x} "
                              f"out={iv(core.out_data):06x} cond={iv(core.cond_out)} "
                              f"cnt1={iv(sh0.count1):06x} cnt2={iv(sh0.count2):02x} "
                              f"lin={iv(sh0.latched_in)} ui={iv(dut.ui_in):02x}")
                last = cur
                n += 1


class PrismTest:
    ''' One test on the bench: subclasses implement run() '''
    name = "prism"

    def __init__(self, bench):
        self.bench = bench
        self.dut   = bench.dut
        self.tqv   = bench.tqv
        self.cfg   = bench.cfg
        self.tasks = []

    def log(self, msg):
        self.bench.log(f"    {msg}")

    async def clocks(self, n):
        await self.bench.clocks(n)

    def start(self, model):
        ''' Start an external-device model; stopped when the test ends '''
        self.tasks.append(model)
        model.start()
        return model

    async def run(self):
        raise NotImplementedError

    async def execute(self):
        self.bench.log(f"Testing {self.name}")
        try:
            await self.run()
        finally:
            for m in self.tasks:
                m.stop()
            self.tasks = []
