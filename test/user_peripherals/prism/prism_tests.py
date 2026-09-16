# The PRISM unit tests, one class per subject.  Each runs on the shared
# PrismBench (bench.py) after a reset; test.py wraps them as cocotb tests.

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge

from user_peripherals.prism.regs import *
from user_peripherals.prism.bench import PrismTest
from user_peripherals.prism.models import Shift74165, Shift74595, SpiMaster, UartRx, Ws2812Slave, I2cSlave, I2cMaster
from user_peripherals.prism.encoder import Encoder
from user_peripherals.prism import usb_model as usb
from user_peripherals.prism import eth_model as eth
from user_peripherals.prism.chroma_ws2812 import *
from user_peripherals.prism.chroma_spislave import *
from user_peripherals.prism.chroma_encoder import *
from user_peripherals.prism.chroma_gpio24 import *
from user_peripherals.prism.chroma_uart_tx import *
from user_peripherals.prism.chroma_fifo_loop import *
from user_peripherals.prism.chroma_edge import *
from user_peripherals.prism.chroma_const_tab import *
from user_peripherals.prism.chroma_i2c_master import *
from user_peripherals.prism.chroma_i2c_slave import *
from user_peripherals.prism.chroma_usb_ls import *
from user_peripherals.prism.chroma_eth_tx import *
from user_peripherals.prism.chroma_eth_rx import *


# =============================================================================
# Registers
# =============================================================================
class RegisterTest(PrismTest):
    ''' Register access with the PRISM disabled: the per-shard windows, the
        FIFO and CRC registers, and the FIFO flag input slots '''
    name = "registers"

    async def run(self):
        tqv = self.tqv
        # PRISM disabled: the state table is still uninitialised, and an
        # enabled PRISM would drive X into the latched output bits of CTRL
        await self.bench.disable()
        await self.clocks(8)
        await tqv.write_word_reg(REG_PRELOAD, 0x0000FA12)
        await tqv.write_byte_reg(REG_COMPARE, 0x34)
        await self.clocks(8)

        self.log("basic control and latch register access")
        assert await tqv.read_byte_reg(REG_COMPARE) == 0x34
        assert await tqv.read_word_reg(REG_PRELOAD) == 0x0000FA12

        self.log("shard 1 register window")
        assert await tqv.read_word_reg(REG_PRELOAD + SHARD1) == 0
        await tqv.write_word_reg(REG_PRELOAD + SHARD1, 0x12345678)
        await tqv.write_byte_reg(REG_COMPARE + SHARD1, 0x56)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, 0x00040100)
        await self.clocks(8)
        assert await tqv.read_word_reg(REG_PRELOAD + SHARD1) == 0x12345678
        assert await tqv.read_byte_reg(REG_COMPARE + SHARD1) == 0x56
        assert await tqv.read_word_reg(REG_CFG0 + SHARD1) == 0x00040100
        assert await tqv.read_word_reg(REG_PRELOAD) == 0x0000FA12
        assert await tqv.read_byte_reg(REG_COMPARE) == 0x34
        assert await tqv.read_word_reg(REG_CFG0) == 0
        await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)

        # FIFO in TX mode: host pushes, reads do not pop, status write flushes;
        # CRC registers.  On both shards.
        self.log("FIFO and CRC registers")
        for base in (0, SHARD1):
            await tqv.write_word_reg(REG_CFG0 + base, CFG_FIFO_DIR_TX)
            assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x1F01 == 0x0001   # empty, count 0
            for b in (0x11, 0x22, 0x33):
                await tqv.write_byte_reg(REG_FIFO + base, b)
            st = await tqv.read_word_reg(REG_FIFO_ST + base)
            assert (st >> 8) & 0x1F == 3 and st & 0x3 == 0, f"{st:#x}"
            assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11
            assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11               # TX: no pop on read
            for b in range(13):
                await tqv.write_byte_reg(REG_FIFO + base, 0x40 + b)
            st = await tqv.read_word_reg(REG_FIFO_ST + base)
            assert (st >> 8) & 0x1F == 16 and st & 0x2, f"{st:#x}"                  # full
            await tqv.write_byte_reg(REG_FIFO + base, 0xEE)                        # dropped
            assert (await tqv.read_word_reg(REG_FIFO_ST + base) >> 8) & 0x1F == 16
            await tqv.write_word_reg(REG_FIFO_ST + base, 0)                        # flush
            assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x1F01 == 0x0001
            await tqv.write_word_reg(REG_CRC_POLY + base, 0x04C11DB7)
            await tqv.write_word_reg(REG_CRC_EXP + base, 0xDEBB20E3)
            assert await tqv.read_word_reg(REG_CRC_POLY + base) == 0x04C11DB7
            assert await tqv.read_word_reg(REG_CRC_EXP + base) == 0xDEBB20E3
            await tqv.write_word_reg(REG_CFG0 + base, 0)
        # the other shard's FIFO must be untouched by the flush above
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1F01 == 0x0001

        # FIFO flag input slots: inputs 20 / 21 show two of the own FIFO's four
        # flags and, for shard 0 unfractured, 26 / 27 two of FIFO B's.  Slot
        # select: bit 0 = almost- flag, bit 1 = the other side (20 / 26 default
        # empty, 21 / 27 full)
        self.log("FIFO flag input selects")
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)
        await tqv.write_word_reg(REG_CFG1 + SHARD1, (4 << 16) | (13 << 20))       # B: ae = count <= 4, af = count >= 3
        for b in range(3):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)                        # B holds 3: ae = af = 1
        async def flag_slots():
            v = await tqv.read_word_reg(REG_IN_DATA)
            return ((v >> 20) & 1, (v >> 21) & 1, (v >> 26) & 1, (v >> 27) & 1)
        def sel4(x): return (x << 24) | (x << 26) | (x << 28) | (x << 30)
        await tqv.write_word_reg(REG_CFG1, sel4(0))
        assert await flag_slots() == (1, 0, 0, 0)          # A empty / A full / B empty / B full
        await tqv.write_word_reg(REG_CFG1, sel4(2))
        assert await flag_slots() == (0, 1, 0, 0)          # A full / A empty / B full / B empty
        await tqv.write_word_reg(REG_CFG1, sel4(1))
        assert await flag_slots() == (1, 0, 1, 1)          # A ae / A af / B ae / B af
        await tqv.write_word_reg(REG_CFG1, sel4(3))
        assert await flag_slots() == (0, 1, 1, 1)          # A af / A ae / B af / B ae
        await tqv.write_word_reg(REG_FRAC_CFG, 1)
        assert await flag_slots() == (0, 1, 0, 0)          # fractured: B's slots read 0
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
        await tqv.write_word_reg(REG_CFG1, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)


# =============================================================================
# State table
# =============================================================================
class StewIntegrityTest(PrismTest):
    ''' Shift patterns through all eight CFGMEM macros and read them back,
        then check the STEW the core fetches for states in both banks '''
    name = "state information integrity"

    @staticmethod
    def pattern(inst, k):
        return ((0x10101010 * k) ^ (0x01000100 * inst)) & 0xFFFFFFFF

    async def run(self):
        tqv, cfg, bench, pattern = self.tqv, self.cfg, self.bench, self.pattern

        # lo macros (bank A) through their chain, then the hi macros (bank B)
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
        for i in range(2):
            for k in range(1, 9):
                for inst in range(STEW_WORDS):
                    await cfg.write_word_reg(CFGMEM_REG_LO(inst), pattern(inst, k))
                    await bench.cfgmem_wait()
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_HI)
        for i in range(2):
            for k in range(1, 9):
                for inst in range(STEW_WORDS):
                    await cfg.write_word_reg(CFGMEM_REG_HI(inst), pattern(inst + 4, k))
                    await bench.cfgmem_wait()

        # Last words written sit in row 0, the first of the last 8 in row 7
        for inst in range(STEW_WORDS):
            assert await bench.cfgmem_read_lo(inst, 0) == pattern(inst, 8)
            assert await bench.cfgmem_read_lo(inst, 7) == pattern(inst, 1)
            assert await bench.cfgmem_read_hi(inst, 0) == pattern(inst + 4, 8)
            assert await bench.cfgmem_read_hi(inst, 7) == pattern(inst + 4, 1)
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

        # Enable bit readback (CTRL[31:16] carries live status)
        self.log("enable bit")
        await bench.enable()
        await self.clocks(8)
        assert (await tqv.read_word_reg(REG_CTRL) & CTRL_ENABLE) == CTRL_ENABLE
        await bench.disable()

        # Unfractured STEW fetch from both banks: halt the debugger, force the
        # state index and read the STEW the core sees.  States 16..31 come
        # from the hi macros (shard 1's SI tracks shard 0's low bits), 0..15
        # from lo.  Row r of the second pattern pass holds pattern(., 8 - r).
        self.log("unfractured STEW fetch from both banks")
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
        await bench.enable()
        await self.clocks(8)
        for si, exp in ((20, lambda inst: pattern(inst + 4, 4)), (31, lambda inst: pattern(inst + 4, 1)),
                        (4,  lambda inst: pattern(inst, 4)),     (15, lambda inst: pattern(inst, 1))):
            await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ | DBG_NEW_SI(si))
            await self.clocks(8)
            st = await bench.dbg_status(0)
            assert (st & 0x1f) == si and (st & DBGS_HALT), f"si {si}: status {st:#x}"
            for inst in range(STEW_WORDS):
                got = await tqv.read_word_reg(REG_STEW0 + 4 * inst)
                assert got == exp(inst), f"state {si} STEW word {inst}: {got:#010x} != {exp(inst):#010x}"
        await tqv.write_word_reg(REG_DBG_CTRL[0], 0)
        await bench.disable()


# =============================================================================
# Chromas
# =============================================================================
class EncoderTest(PrismTest):
    ''' Quadrature encoder on ui_in[1:0], debounced by count1, position in count2 '''
    name = "encoder Chroma"
    clocks_per_phase = 600

    def encoder(self):
        return Encoder(self.dut.clk, self.dut.ui_in[0], self.dut.ui_in[1],
                       clocks_per_phase=self.clocks_per_phase,
                       noise_cycles=self.clocks_per_phase / 8)

    async def drive(self, base, encoder0):
        ''' Drive the encoder chroma in the shard whose window is at base '''
        tqv = self.tqv
        await tqv.write_byte_reg(REG_PRELOAD + base, 128)          # debounce count (short for the test)
        self.bench.chroma = 'encoder'

        self.log("Checking encoder 0")
        for i in range(self.clocks_per_phase * 2 * 20):
            await encoder0.update(1)
        self.log("Testing count2 value")
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 20

        self.log("Checking encoder 0 the other way")
        for i in range(self.clocks_per_phase * 2 * 12):
            await encoder0.update(-1)
        self.log("Testing count2 value")
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 9

    async def run(self):
        await self.tqv.write_byte_reg(REG_HOST, 0x00)
        await self.bench.load_chroma(chroma_encoder, chroma_encoder_ctrlReg, chroma_encoder_pinmuxReg)
        await self.drive(0, self.encoder())


# =============================================================================
# WS2812 RGB LED driver / Encoder unit test
# =============================================================================
class Ws2812Test(PrismTest):
    ''' WS2812 transmitter on uo_out[1] with the LUT-conditional breakpoint check '''
    name = "ws2812 Chroma"

    async def drive(self, base, irq_mask, slave):
        ''' Drive the ws2812 chroma in the shard whose window is at base '''
        tqv, bench = self.tqv, self.bench
        await tqv.write_byte_reg(REG_COMPARE + base, 51)          # 0.8 us at 64 MHz
        await tqv.write_byte_reg(REG_COMM + base, 26)             # 0.4 us
        await tqv.write_word_reg(REG_PRELOAD + base, 0x00FF5367)  # GRB data
        bench.chroma = 'ws2812'
        await tqv.write_byte_reg(REG_HOST + base, 0x01)           # start
        await self.clocks(6000)

        self.log("Testing if Interrupt was set")
        assert await bench.irq(irq_mask)
        assert slave.grb == 0xFF5367

        self.log("Writing new data using auto-toggle")
        await tqv.write_word_reg(REG_PRELOAD + base, 0x0036FE0C)
        await tqv.write_byte_reg(REG_TOGGLE + base, 0x00)
        self.log("Testing if Interrupt was cleared")
        assert await bench.irq(irq_mask)
        self.log("Testing if host_in[0] toggled")
        assert await tqv.read_byte_reg(REG_HOST + base) == 0

        # LUT-conditional breakpoint (changes.md item 7): the auto-toggle
        # started a second transfer (0x36FE0C, first bit 0).  Break in
        # SEND_T0_LOW (compiler row 4) when its "if" fires, i.e. count2 >=
        # compare (51): the FSM must stop with count2 == 51, the transition's
        # count2_clear / shift held off.
        shard = 0 if base == 0 else 1
        dbg   = REG_DBG_CTRL[shard]
        bp = DBG_BP0_EN | DBG_BP0_SI(4) | DBG_BP0_COND(1)
        await tqv.write_word_reg(dbg, bp)
        await self.clocks(400)

        self.log(f"Testing LUT-conditional breakpoint (shard {shard})")
        st = await bench.dbg_status(shard)
        assert (st & 0x1f) == 4, f"status {st:#x}"
        assert st & DBGS_HALT
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 51
        shc_before = (await tqv.read_word_reg(REG_COUNT2 + base) >> 24) & 0x1f

        # Single step (halt_req held so the FSM stays halted afterwards):
        # the transition and its outputs happen now
        self.log("Stepping out of the conditional breakpoint")
        await tqv.write_word_reg(dbg, bp | DBG_HALT_REQ)
        await tqv.write_word_reg(dbg, bp | DBG_HALT_REQ | DBG_STEP)
        st = await bench.dbg_status(shard)
        assert (st & 0x1f) == 6, f"status {st:#x}"                  # CHECK_SHIFT_COUNT
        assert st & DBGS_HALT
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 0     # count2_clear acted
        shc_after = (await tqv.read_word_reg(REG_COUNT2 + base) >> 24) & 0x1f
        assert shc_after == ((shc_before + 1) & 0x1f), f"{shc_before} -> {shc_after}"  # shift acted

        # Release: breakpoint off, halt_req dropped
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        await tqv.write_word_reg(dbg, 0)
        await self.clocks(6000)
        assert not (await bench.dbg_status(shard) & DBGS_HALT)
        assert await bench.irq(irq_mask)

    async def run(self):
        await self.tqv.write_byte_reg(REG_HOST, 0x00)
        await self.bench.load_chroma(chroma_ws2812, chroma_ws2812_ctrlReg, chroma_ws2812_pinmuxReg)
        slave = self.start(Ws2812Slave(self.dut))
        await self.drive(0, IRQ0_MASK, slave)


# =============================================================================
# Gpio24 24-bit GPIO Expander unit test.
# =============================================================================
class Gpio24Test(PrismTest):
    ''' 24-bit GPIO expander: 74165 in on ui_in[0], 74595 out on uo_out[5],
        with a breakpoint, a single step and a resume on the way '''
    name = "gpio24 Chroma"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        await bench.load_chroma(chroma_gpio24, chroma_gpio24_ctrlReg, chroma_gpio24_pinmuxReg)
        await tqv.write_word_reg(REG_PRELOAD, 0x00F05077)          # 24-bit output data
        shift_in  = self.start(Shift74165(self.dut, 0x00BEEF))
        shift_out = self.start(Shift74595(self.dut))
        self.dut.ui_in[0].value = 0
        bench.chroma = 'gpio24'

        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_BP0_EN | DBG_BP0_SI(3))   # breakpoint in state 3
        self.log("Starting GPIO24 shift operation")
        await tqv.write_word_reg(REG_HOST, 3)
        await tqv.write_word_reg(REG_HOST, 2)
        await self.clocks(40)

        self.log("Testing if PRISM halted at breakpoint")
        st = await bench.dbg_status(0)
        assert (st & 0x1f) == 3
        assert st & DBGS_HALT

        self.log("Single stepping PRISM")
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_BP0_EN | DBG_BP0_SI(3) | DBG_STEP)
        self.log("Testing if PRISM stepped")
        assert (await bench.dbg_status(0) & 0x1f) == 4              # STATE_DELAY2 (compiler index 4)

        await tqv.write_byte_reg(REG_INT_CLR0, 0xC0)                # clear the halt interrupt
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)     # resume
        await tqv.write_word_reg(REG_DBG_CTRL[0], 0)
        await self.clocks(200)

        self.log("Testing input read value")
        assert await tqv.read_word_reg(REG_COUNT1) == 0x0000BEEF
        self.log("Testing output store value")
        assert shift_out.value == 0x00F05077


# =============================================================================
# SPI Slave device unit test
# =============================================================================
class SpiSlaveTest(PrismTest):
    ''' SPI slave: received bytes to comm and the RX FIFO with a CRC8, TX
        bytes staged in preload, one interrupt per byte '''
    name = "spislave Chroma"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        master = self.start(SpiMaster(self.dut))                    # CS high, SCLK / MOSI low
        await bench.load_chroma(chroma_spislave, chroma_spislave_ctrlReg, chroma_spislave_pinmuxReg)

        spi_data = [0xF5, 0x27]                                     # master sends
        tx_bytes = [0x67, 0xF3]                                     # slave answers
        bench.chroma = 'spislave'
        # TX bytes are staged in preload[7:0]; the chroma loads comm from it
        # at the first SCLK of each byte
        await tqv.write_word_reg(REG_PRELOAD, tx_bytes[0])
        await tqv.write_word_reg(REG_CRC_POLY, 0x07)               # CRC8 over the received bits
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1

        # The master pauses after every byte until the host has read comm,
        # cleared the interrupt and staged the next byte
        master.transfer(spi_data)
        for n, rx in enumerate(spi_data):
            await master.wait_byte()
            await self.clocks(50)
            self.log(f"Testing received byte {n}")
            assert await tqv.read_byte_reg(REG_COMM) == rx
            assert await bench.irq()
            await tqv.write_byte_reg(REG_INT_CLR0, 0xC0)
            if n + 1 < len(tx_bytes):
                await tqv.write_word_reg(REG_PRELOAD, tx_bytes[n + 1])
            master.release()
        await master.wait_done()
        assert master.rx == tx_bytes

        self.log("Testing if Interrupt is clear after service")
        assert not await bench.irq()

        self.log("Testing RX FIFO and CRC8")
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x1F == len(spi_data), f"{st:#x}"
        for rx in spi_data:
            assert await tqv.read_byte_reg(REG_FIFO) == rx
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_word_reg(REG_CRC) == crc_bytes_msb_first(spi_data)


# =============================================================================
# Full duplex 8N1 UART unit test
# =============================================================================
class UartTxTest(PrismTest):
    ''' 8N1 transmitter on uo_out[1] fed from the TX FIFO, CRC8 trailer on request '''
    name = "uart_tx Chroma"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await bench.load_chroma(chroma_uart_tx, chroma_uart_tx_ctrlReg, chroma_uart_tx_pinmuxReg)
        await tqv.write_word_reg(REG_PRELOAD, 62)                  # bit period 64 clocks (preload = period - 2)
        await tqv.write_word_reg(REG_CRC_POLY, 0x07)
        rx = self.start(UartRx(self.dut, period=64))
        bench.chroma = 'uart_tx'

        data = [0x55, 0xA3, 0x0F]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO, b)
        await self.clocks(3 * 10 * 64 + 400)
        assert rx.bytes == data, rx.bytes
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_word_reg(REG_CRC) == crc_bytes_lsb_first(data)

        self.log("Requesting CRC trailer")
        await tqv.write_word_reg(REG_HOST, 1)
        await self.clocks(10 * 64 + 400)
        assert rx.bytes == data + [crc_bytes_lsb_first(data)], rx.bytes
        assert await bench.irq()
        assert await bench.curr_state() == 9                       # WAIT_ACK

        self.log("Acknowledging: the FSM clears the CRC and idles")
        await tqv.write_word_reg(REG_HOST, 0)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        await self.clocks(20)
        assert await bench.curr_state() == 0
        assert await tqv.read_word_reg(REG_CRC) == 0
        assert not await bench.irq()


# =============================================================================
# Edge-clocked sampler unit test
# =============================================================================
class SamplerTest(PrismTest):
    ''' CFG3[27:16]: on the selected edge of one PRISM input the hardware
        shifts, counts, captures the in_prev flops or reloads count1 with no
        state transition.  An idle chroma (fifo_loop) leaves the datapath to
        the sampler; a clock on ui_in[1] and data on ui_in[3] are driven by
        the test.  Rising, falling and either edge, a 4-clock clock period,
        the pending flag, and its consumption by the uart_tx chroma's shift. '''
    name = "edge-clocked sampler (CFG3[27:16])"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        sh0 = dut.user_project.i_peripherals.i_prism.SH[0]
        CLK, DATA = 1, 3
        dut.ui_in[CLK].value = 0
        dut.ui_in[DATA].value = 0
        await bench.load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0, (1 << 8) | DATA)            # shifter on, MSB first, input = ui_in[3]
        await tqv.write_word_reg(REG_CFG1, DATA)                       # in_prev[0] follows ui_in[3]

        def smp(edge, actions):
            return CFG3_SMP_EN | CFG3_SMP_SRC(CLK) | edge | actions

        async def clock_in(byte, setup=3, high=4, hold=1):
            ''' 8 clock pulses on ui_in[1]; each bit of the byte, MSB first, is on ui_in[3]
                `setup` clocks before the rising edge and `hold` clocks after the falling one '''
            for i in range(8):
                dut.ui_in[DATA].value = (byte >> (7 - i)) & 1
                await self.clocks(setup)
                dut.ui_in[CLK].value = 1
                await self.clocks(high)
                dut.ui_in[CLK].value = 0
                await self.clocks(hold)
            await self.clocks(8)

        async def flags():
            return await tqv.read_word_reg(REG_FLAGS)

        self.log("shift + count on rising edges")
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_RISE, CFG3_SMP_SHIFT | CFG3_SMP_CNT2))
        await clock_in(0xA5)
        assert await tqv.read_byte_reg(REG_COMM) == 0xA5
        assert await tqv.read_byte_reg(REG_COUNT2) == 8
        f = await flags()
        assert f & (1 << 4) and f & FLAG_SMP_PENDING, f"{f:#x}"        # 8 shifts: shift_term; an edge pending
        await clock_in(0x3C)
        assert await tqv.read_byte_reg(REG_COMM) == 0x3C
        assert await tqv.read_byte_reg(REG_COUNT2) == 16

        self.log("shift on falling edges only")
        await tqv.write_byte_reg(REG_COUNT2, 0)
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_FALL, CFG3_SMP_SHIFT))
        await clock_in(0x5A)
        assert await tqv.read_byte_reg(REG_COMM) == 0x5A
        assert await tqv.read_byte_reg(REG_COUNT2) == 0

        self.log("count either edge")
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_ANY, CFG3_SMP_CNT2))
        await clock_in(0xFF)
        assert await tqv.read_byte_reg(REG_COUNT2) == 16
        assert await tqv.read_byte_reg(REG_COMM) == 0x5A                # no shift action

        self.log("a 4-clock clock period")
        await tqv.write_byte_reg(REG_COUNT2, 0)
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_RISE, CFG3_SMP_SHIFT | CFG3_SMP_CNT2))
        await clock_in(0x96, setup=1, high=2, hold=1)                  # 4 clocks per bit
        assert await tqv.read_byte_reg(REG_COMM) == 0x96
        assert await tqv.read_byte_reg(REG_COUNT2) == 8

        self.log("count1 reload and in_prev capture on the edge")
        await tqv.write_word_reg(REG_PRELOAD, 0x1234)
        await tqv.write_word_reg(REG_COUNT1, 5)
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_RISE, CFG3_SMP_TIMER | CFG3_SMP_LATCH))
        assert await tqv.read_word_reg(REG_COUNT1) == 5
        dut.ui_in[DATA].value = 1
        await self.clocks(4)
        assert int(sh0.in_prev.value) & 1 == 0                          # not captured yet
        dut.ui_in[CLK].value = 1
        await self.clocks(6)
        dut.ui_in[CLK].value = 0
        await self.clocks(4)
        assert await tqv.read_word_reg(REG_COUNT1) == 0x1234
        assert int(sh0.in_prev.value) & 1 == 1                          # in_prev[0] = ui_in[3] at the edge
        dut.ui_in[DATA].value = 0
        await self.clocks(6)
        assert int(sh0.in_prev.value) & 1 == 1                          # holds until the next edge
        assert await tqv.read_byte_reg(REG_COMM) == 0x96                # no shift action
        assert (await flags()) & FLAG_SMP_PENDING
        await tqv.write_word_reg(REG_CFG3, 0)                           # off: pending clears
        await self.clocks(3)
        assert not (await flags()) & FLAG_SMP_PENDING

        self.log("the pending flag is consumed by an FSM shift (uart_tx)")
        await bench.disable()
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await bench.load_chroma(chroma_uart_tx, chroma_uart_tx_ctrlReg, chroma_uart_tx_pinmuxReg)
        await tqv.write_word_reg(REG_PRELOAD, 14)                       # 16-clock bits
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_RISE, 0))       # edge detector only
        dut.ui_in[CLK].value = 1
        await self.clocks(4)
        assert (await flags()) & FLAG_SMP_PENDING
        await tqv.write_byte_reg(REG_FIFO, 0x0F)                        # the FSM shifts while it sends
        await self.clocks(10 * 16 + 60)
        assert not (await flags()) & FLAG_SMP_PENDING
        dut.ui_in[CLK].value = 0
        await tqv.write_word_reg(REG_CFG3, 0)
        await tqv.write_word_reg(REG_CFG1, 0)
        await bench.disable()
        dut.ui_in[DATA].value = 0


# =============================================================================
# I2C master Chroma unit test
# =============================================================================
class I2cMasterTest(PrismTest):
    ''' I2C controller through external open-drain buffers: uo_out[1] pulls
        SCL low, uo_out[2] pulls SDA low, the lines come back on ui_in[1:0].
        FIFO B holds the bytes to send (address first), K0 the read address,
        COMPARE the read count, host_in[0] starts, the interrupt ends.  An
        I2cSlave model resolves the bus and answers to one address: write,
        read, write-then-repeated-START-read, and NAKs from an absent slave. '''
    name = "i2c_master Chroma (external open-drain buffers)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        ADDR, HALF = 0x3C, 24
        await tqv.write_byte_reg(REG_HOST, 0x00)
        slave = self.start(I2cSlave(dut, ADDR))
        await bench.load_chroma(chroma_i2c_master, chroma_i2c_master_ctrlReg, chroma_i2c_master_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)      # FIFO B: the host writes
        await tqv.write_word_reg(REG_CFG2, 14)                              # input 16 = flag2 (read phase)
        await tqv.write_word_reg(REG_PRELOAD, HALF - 1)                     # SCL phase = HALF clocks
        await tqv.write_word_reg(REG_CONST, (ADDR << 1) | 1)                # K0 = the read address

        async def transaction(tx, nread, read_data=(), clocks=6000):
            ''' Push `tx` into FIFO B, ask for `nread` bytes, go, wait for the interrupt; the bytes read '''
            slave.events.clear(); slave.rx.clear(); slave.scl_rises.clear()
            slave.read_data = list(read_data)
            for b in tx:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
            await tqv.write_byte_reg(REG_COMPARE, nread)
            await tqv.write_word_reg(REG_HOST, 1)
            for _ in range(clocks // 50):
                if await bench.irq():
                    break
                await self.clocks(50)
            assert await bench.irq(), "no completion interrupt"
            assert await bench.curr_state() == 24                           # DONE
            await tqv.write_word_reg(REG_HOST, 0)
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            await self.clocks(10)
            assert await bench.curr_state() == 0 and not await bench.irq()
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x1F):
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        self.log("write 3 bytes")
        got = await transaction([ADDR << 1, 0x10, 0x20, 0x30], 0)
        assert slave.events == [('start',), ('addr', ADDR << 1, True), ('write', 0x10, True),
                                ('write', 0x20, True), ('write', 0x30, True), ('stop',)], slave.events
        assert got == [] and await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == 0
        periods = [b - a for a, b in zip(slave.scl_rises, slave.scl_rises[1:])]
        assert all(3 * HALF - 3 <= p <= 3 * HALF + 8 for p in periods[:7]), periods[:8]   # 3 phases per bit

        self.log("read 3 bytes (K0 address, NAK on the last)")
        got = await transaction([], 3, read_data=[0xA5, 0x5A, 0x0F])
        assert slave.events == [('start',), ('addr', (ADDR << 1) | 1, True), ('read', 0xA5, True),
                                ('read', 0x5A, True), ('read', 0x0F, False), ('stop',)], slave.events
        assert got == [0xA5, 0x5A, 0x0F], got
        assert await tqv.read_byte_reg(REG_COUNT2) == 3

        self.log("write a register address, repeated START, read 2 bytes")
        got = await transaction([ADDR << 1, 0x42], 2, read_data=[0x11, 0x22])
        assert slave.events == [('start',), ('addr', ADDR << 1, True), ('write', 0x42, True), ('start',),
                                ('addr', (ADDR << 1) | 1, True), ('read', 0x11, True), ('read', 0x22, False),
                                ('stop',)], slave.events
        assert got == [0x11, 0x22], got

        self.log("no slave at the address: NAK, STOP, the unsent byte stays in FIFO B")
        got = await transaction([(ADDR + 1) << 1, 0x99], 0)
        assert slave.events == [('start',), ('addr', (ADDR + 1) << 1, False), ('stop',)], slave.events
        assert got == []
        st = await tqv.read_word_reg(REG_FIFO_ST + SHARD1)
        assert (st >> 8) & 0x1F == 1, f"{st:#x}"
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)

        self.log("read from an absent slave: NAK, nothing read")
        await tqv.write_word_reg(REG_CONST, ((ADDR + 1) << 1) | 1)
        got = await transaction([], 2, read_data=[0x77])
        assert slave.events == [('start',), ('addr', ((ADDR + 1) << 1) | 1, False), ('stop',)], slave.events
        assert got == [] and await tqv.read_byte_reg(REG_COUNT2) == 0

        await bench.disable()
        for reg, v in ((REG_CONST, 0), (REG_CFG2, 0), (REG_CFG0 + SHARD1, 0), (REG_FIFO_ST, 0), (REG_FIFO_ST + SHARD1, 0)):
            await tqv.write_word_reg(reg, v)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_HOST, 0)
        dut.ui_in[0].value = 0
        dut.ui_in[1].value = 0


# =============================================================================
# I2C slave Chroma unit test
# =============================================================================
class I2cSlaveTest(PrismTest):
    ''' I2C target on the sampler: SCL rising edges shift SDA into comm and
        count, flag2 swaps the sampler to falling edges for reads, the FSM
        acts at byte boundaries (13 states).  An I2cMaster model drives the
        bus: writes into FIFO A, reads from FIFO B (0xFF when empty), a NAK
        for another address, a register write with a repeated-START read,
        the interrupt at STOP / end of read, and a fast clock. '''
    name = "i2c_slave Chroma (edge-clocked sampler)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        ADDR = 0x51
        await tqv.write_byte_reg(REG_HOST, 0x00)
        master = self.start(I2cMaster(dut, half=16))
        await bench.load_chroma(chroma_i2c_slave, chroma_i2c_slave_ctrlReg, chroma_i2c_slave_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)      # FIFO B: the bytes to be read
        await tqv.write_word_reg(REG_CFG2, (13 << 4) | (14 << 8) | (5 << 12))   # match, flag2, comm[0]
        await tqv.write_word_reg(REG_CONST, (ADDR << 24) | 0xFF00)          # K3 = address, K1 = 0xFF, K0 = 0
        await tqv.write_byte_reg(REG_COMPARE, 7)
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(1) | CFG3_SMP_RISE |
                                 CFG3_SMP_SHIFT | CFG3_SMP_CNT2 | CFG3_SMP_INV)
        await self.clocks(20)

        async def fifo_a():
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x1F):
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        async def settle():
            await self.clocks(30)
            assert await bench.curr_state() == 0, await bench.curr_state()

        self.log("write 3 bytes")
        await master.send_start()
        assert await master.write_byte(ADDR << 1)
        for b in (0x10, 0x20, 0x30):
            assert await master.write_byte(b)
        await master.send_stop()
        await settle()
        assert await fifo_a() == [0x10, 0x20, 0x30]
        assert await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("another address: NAK, nothing taken")
        await master.send_start()
        assert not await master.write_byte((ADDR + 1) << 1)
        assert not await master.write_byte(0x99)
        await master.send_stop()
        await settle()
        assert await fifo_a() == [] and not await bench.irq()

        self.log("read 3 bytes from FIFO B")
        for b in (0xA5, 0x5A, 0x0F):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await master.send_start()
        assert await master.write_byte((ADDR << 1) | 1)
        got = [await master.read_byte(True), await master.read_byte(True), await master.read_byte(False)]
        await master.send_stop()
        await settle()
        assert got == [0xA5, 0x5A, 0x0F], [hex(v) for v in got]
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 1 == 1
        assert await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("read with FIFO B empty: 0xFF")
        await master.send_start()
        assert await master.write_byte((ADDR << 1) | 1)
        got = [await master.read_byte(True), await master.read_byte(False)]
        await master.send_stop()
        await settle()
        assert got == [0xFF, 0xFF], [hex(v) for v in got]
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("register write, repeated START, read 2")
        for b in (0x11, 0x22):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await master.send_start()
        assert await master.write_byte(ADDR << 1)
        assert await master.write_byte(0x42)
        await master.send_start()                                              # repeated START
        assert await master.write_byte((ADDR << 1) | 1)
        got = [await master.read_byte(True), await master.read_byte(False)]
        await master.send_stop()
        await settle()
        assert got == [0x11, 0x22], [hex(v) for v in got]
        assert await fifo_a() == [0x42]
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("fast clock: 8-clock half period")
        master.half = 8
        for b in (0xC3,):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await master.send_start()
        assert await master.write_byte(ADDR << 1)
        assert await master.write_byte(0x77)
        assert await master.write_byte(0x88)
        await master.send_start()
        assert await master.write_byte((ADDR << 1) | 1)
        got = [await master.read_byte(False)]
        await master.send_stop()
        await settle()
        assert got == [0xC3] and await fifo_a() == [0x77, 0x88], [hex(v) for v in got]
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        await bench.disable()
        for reg, v in ((REG_CFG3, 0), (REG_CONST, 0), (REG_CFG2, 0), (REG_CFG0 + SHARD1, 0), (REG_FIFO_ST, 0), (REG_FIFO_ST + SHARD1, 0)):
            await tqv.write_word_reg(reg, v)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        dut.ui_in[0].value = 0
        dut.ui_in[1].value = 0


# =============================================================================
# Shard FIFO sharing unit test
# =============================================================================
class FifoLoopTest(PrismTest):
    ''' Unfractured: shard 0 owns both FIFOs.  A (its own) is RX, B (shard 1's)
        is TX; the chroma moves every byte the host pushes into B over to A,
        OUT_FIFO_PUSH_POP picking the FIFO that OUT_FIFO_WR_RD strobes '''
    name = "fifo_loop Chroma (shard 0 owns both FIFOs)"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        await bench.load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: host writes
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1

        data = [0x5A, 0x01, 0xFE, 0x80, 0x7F, 0x33]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await self.clocks(100)
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1      # B drained ...
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x1F == len(data), f"{st:#x}"                      # ... into A
        for b in data:
            assert await tqv.read_byte_reg(REG_FIFO) == b
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data)

        # More than A can hold: the FSM stops on fifo_a_full and resumes as the
        # host drains A; the bytes arrive in order
        self.log("FIFO A full back-pressure")
        for b in range(20):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0xC0 + b)
        await self.clocks(200)
        assert (await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x1F == 16
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x1F == 4
        for b in range(20):
            await self.clocks(20)
            assert await tqv.read_byte_reg(REG_FIFO) == 0xC0 + b
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data) + 20
        await bench.disable()


# =============================================================================
# PRISM Edge Detect circuit unit test
# =============================================================================
class SramFifoTest(PrismTest):
    ''' The SRAM FIFOs as a shard's storage (CFG0[31]; one 512x32 macro per
        shard, 2 KB each).  Register-level
        first: host pushes and pops through the shard window in TX / RX
        mode with the PRISM disabled; then the fifo_loop chroma moves bytes
        SRAM -> flop FIFO and flop FIFO -> SRAM, crossing many word
        boundaries, with the host draining. '''
    name = "SRAM FIFO"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        await bench.disable()

        # Shard 1's FIFO as the SRAM, TX mode: host pushes, count grows past 16
        self.log("host pushes into the SRAM FIFO (shard 1, TX mode)")
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)                     # flush
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x3 == 0x1     # empty
        for b in range(40):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, (b * 7) & 0xFF)
        st = await tqv.read_word_reg(REG_FIFO_ST + SHARD1)
        assert (st >> 8) & 0x3FFF == 40, f"{st:#x}"
        assert st & 0x3 == 0                                                   # neither empty nor full
        assert await tqv.read_byte_reg(REG_FIFO + SHARD1) == 0                # TX: read shows the head, no pop
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x3FFF == 40
        # the flop FIFO of shard 1 stayed empty; shard 0's too
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1F01 == 0x0001
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1F01 == 0x0001
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x3FFF == 40  # contents kept
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)                     # flush
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x3FFF01 == 0x000001

        # Almost-empty / almost-full levels are in 64-byte units
        self.log("levels")
        await tqv.write_word_reg(REG_CFG1 + SHARD1, (1 << 16) | (1 << 20))    # ae: <= 64, af: >= 8192 - 64
        for b in range(70):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        st = await tqv.read_word_reg(REG_FIFO_ST + SHARD1)
        assert (st >> 8) & 0x3FFF == 70 and (st & 0xC) == 0, f"{st:#x}"       # neither almost flag
        await tqv.write_word_reg(REG_CFG1 + SHARD1, (2 << 16) | (1 << 20))    # ae: <= 128
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x4) == 0x4
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)

        # Both SRAM FIFOs at once, one per shard: independent contents, counts
        # and flushes (the host pushes into each in TX mode)
        self.log("both SRAM FIFOs, one per shard")
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        for b in range(30):
            await tqv.write_byte_reg(REG_FIFO, 0x40 + b)
        for b in range(50):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x80 + b)
        assert (await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF == 30
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x3FFF == 50
        assert await tqv.read_byte_reg(REG_FIFO) == 0x40
        assert await tqv.read_byte_reg(REG_FIFO + SHARD1) == 0x80
        await tqv.write_word_reg(REG_FIFO_ST, 0)                              # flush shard 0's only
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x3FFF == 50
        assert await tqv.read_byte_reg(REG_FIFO + SHARD1) == 0x80
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG0, 0)

        # SRAM (B, TX) -> flop FIFO (A, RX) through the fifo_loop chroma: the
        # host queues more than 16 bytes, the FSM drains B as the host reads A
        self.log("fifo_loop: SRAM FIFO B -> flop FIFO A")
        await bench.load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        data = [(i * 13 + 5) & 0xFF for i in range(75)]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        got = []
        for i in range(len(data)):
            for _ in range(200):
                if await tqv.read_word_reg(REG_FIFO_ST) & 1 == 0:
                    break
                await self.clocks(10)
            got.append(await tqv.read_byte_reg(REG_FIFO))
        assert got == data, [hex(x) for x in got]
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data) & 0xFF

        # flop FIFO (B, TX) -> SRAM (A, RX): shard 0 owns the SRAM as its RX
        # FIFO, and the host reads the SRAM through the shard 0 window
        self.log("fifo_loop: flop FIFO B -> SRAM FIFO A")
        await bench.disable()
        await bench.load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg | CFG_FIFO_SRAM, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        data = [(i * 29 + 1) & 0xFF for i in range(60)]
        for i in range(0, len(data), 12):                                     # the flop FIFO holds 16
            for b in data[i:i + 12]:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
            await self.clocks(150)
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x3FFF == len(data), f"{st:#x}"
        got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(len(data))]
        assert got == data, [hex(x) for x in got]
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
        await bench.disable()


class EdgeTest(PrismTest):
    ''' in_prev edge capture: in_prev[0] follows ui_in[2] (input 2) and
        in_prev[1] follows host_in[0] (input 8), sources set in CFG1.  The
        chroma counts pin transitions in count2 and host toggles in count1.
        A flop captures its source only when a decision tree reading that
        source fires and the jump executes, so the debugger halt / step must
        be honoured. '''
    name = "edge Chroma (in_prev capture)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[2].value = 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        # Sources go in before the chroma runs: a flop only changes on a
        # capture, so a source changed afterwards leaves the old value behind
        await tqv.write_word_reg(REG_CFG1, (2 << 0) | (8 << 4))
        await bench.load_chroma(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        await self.clocks(20)
        assert await tqv.read_byte_reg(REG_COUNT2) == 0
        assert await tqv.read_word_reg(REG_COUNT1) == 0

        def toggle():
            dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)
        n = 0
        for gap in (8, 5, 30, 4, 12, 9, 6, 40, 4, 7):
            toggle()
            n += 1
            await self.clocks(gap)
        await self.clocks(30)
        assert await tqv.read_byte_reg(REG_COUNT2) == n
        assert await tqv.read_word_reg(REG_COUNT1) == 0

        self.log("host_in[0] toggles through tree 1")
        for m in range(5):
            await tqv.write_byte_reg(REG_TOGGLE, 0x00)
        await self.clocks(30)
        assert await tqv.read_word_reg(REG_COUNT1) == 5
        assert await tqv.read_byte_reg(REG_COUNT2) == n

        self.log("debugger halt / step")
        dbg = REG_DBG_CTRL[0]
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        await self.clocks(10)
        assert await bench.curr_state() == 0                       # WAIT
        toggle()                                                    # edge while halted
        await self.clocks(30)
        assert await tqv.read_byte_reg(REG_COUNT2) == n            # not consumed
        await tqv.write_word_reg(dbg, DBG_HALT_REQ | DBG_STEP)     # WAIT -> CNT_PIN, captures
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        assert await bench.curr_state() == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == n
        await tqv.write_word_reg(dbg, DBG_HALT_REQ | DBG_STEP)     # CNT_PIN -> WAIT, counts
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        assert await bench.curr_state() == 0
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        await tqv.write_word_reg(dbg, DBG_HALT_REQ | DBG_STEP)     # nothing pending: stays
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        assert await bench.curr_state() == 0
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        await tqv.write_word_reg(dbg, 0)                           # resume
        await self.clocks(20)
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        toggle()
        await self.clocks(30)
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 2
        assert await tqv.read_word_reg(REG_COUNT1) == 5
        dut.ui_in[2].value = 0
        await tqv.write_word_reg(REG_CFG1, 0)
        await bench.disable()


class Timer2Test(PrismTest):
    ''' Timer 2 (PRELOAD2): free-running it ticks every PRELOAD2 + 1 clocks
        whatever the FSM does; with [24] the count restarts each time the
        shard enters state [29:25] (a retriggerable timeout, no STEW bits);
        with [30] as well it ticks once per entry and then waits.  The edge
        chroma's WAIT -> CNT_PIN -> WAIT round trip on every pin transition
        is the entry; the timer and its tick are peeked and replayed against
        a model of the counter clock by clock. '''
    name = "timer 2 (PRELOAD2 restart on state entry)"

    class Peek:
        def __init__(self, dut, shard):
            prism = dut.user_project.i_peripherals.i_prism
            self.clk  = dut.clk
            self.si   = prism.i_prism.trace_si if shard == 0 else prism.i_prism.trace_si_1
            self.t    = prism.SH[shard].timer2
            self.tick = prism.SH[shard].timer2_tick
            self.samples = []
        async def _run(self):
            while True:
                await FallingEdge(self.clk)
                self.samples.append((int(self.si.value), int(self.t.value), int(self.tick.value)))
        def start(self):
            self.task = cocotb.start_soon(self._run())
        def stop(self):
            self.task.kill()
        def replay(self, first, period, state=None, one_shot=False, armed=False):
            ''' Samples first.. against the counter model; returns (ticks, entries) '''
            s = self.samples
            t, ticks, entries = s[first][1], 0, 0
            for k in range(first + 1, len(s)):
                entry = state is not None and s[k][0] == state and s[k - 1][0] != state
                tick = 0
                if entry:
                    t, armed = period - 1, True; entries += 1
                elif one_shot and state is not None and not armed:
                    pass
                elif t == 0:
                    t, tick, armed = period - 1, 1, not one_shot
                else:
                    t -= 1
                assert s[k][1:] == (t, tick), f"sample {k}: {s[k]} expected timer {t} tick {tick}"
                ticks += tick
            return ticks, entries

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[2].value = 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG1, (2 << 0) | (8 << 4))
        await bench.load_chroma(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        peek = self.Peek(dut, 0)
        peek.start()
        await self.clocks(20)
        P = 20

        def toggle():
            dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)

        async def toggles(gaps):
            for g in gaps:
                toggle()
                await self.clocks(g)

        self.log("free-running: a tick every 20 clocks, pin transitions change nothing")
        await tqv.write_word_reg(REG_PRELOAD2, P - 1)
        await self.clocks(5)
        first = len(peek.samples)
        await toggles((8, 5, 30, 4, 12, 9, 6, 40, 4, 7))
        await self.clocks(60)
        ticks, entries = peek.replay(first, P)
        n = len(peek.samples) - first
        assert ticks in (n // P, n // P + 1) and entries == 0, (ticks, entries, n)
        n = await tqv.read_byte_reg(REG_COUNT2)
        assert n == 10, n

        self.log("restart on entry into CNT_PIN: a tick 20 clocks after the last entry")
        await tqv.write_word_reg(REG_PRELOAD2, (P - 1) | T2_RELOAD | T2_STATE(1))
        await self.clocks(5)
        first = len(peek.samples)
        await toggles((8, 5, 30, 4, 12, 9, 6, 40, 4, 7))     # the 30 and 40 gaps time out, then free-running
        await self.clocks(100)
        ticks, entries = peek.replay(first, P, state=1)
        assert entries == 10 and 6 <= ticks <= 8, (ticks, entries)
        # a burst closer than the period never ticks: the timeout is held off
        first = len(peek.samples)
        await toggles((8, 5, 4, 7, 9, 6, 4, 8, 5, 4))
        ticks, entries = peek.replay(first, P, state=1)
        assert entries == 10 and ticks == 0, (ticks, entries)
        await self.clocks(60)
        ticks, entries = peek.replay(first, P, state=1)
        assert ticks == 3, ticks                                # 60 clocks after the burst: 3 free-running ticks

        self.log("one-shot: one tick per entry, none while entries keep coming")
        await tqv.write_word_reg(REG_PRELOAD2, (P - 1) | T2_RELOAD | T2_STATE(1) | T2_ONESHOT)
        await self.clocks(5)
        first = len(peek.samples)
        await self.clocks(100)
        assert peek.replay(first, P, state=1, one_shot=True) == (0, 0)       # idle until an entry
        await toggles((40, 40, 40))
        ticks, entries = peek.replay(first, P, state=1, one_shot=True)
        assert (ticks, entries) == (3, 3), (ticks, entries)
        first = len(peek.samples)
        await toggles((8, 5, 4, 7, 9, 6, 4, 8, 5, 4))
        await self.clocks(100)
        ticks, entries = peek.replay(first, P, state=1, one_shot=True, armed=False)
        assert (ticks, entries) == (1, 10), (ticks, entries)  # the burst ends in one timeout
        await tqv.write_word_reg(REG_PRELOAD2, 0)
        await self.clocks(3)
        assert peek.samples[-1][1:] == (0, 0)
        peek.stop()

        self.log("fractured: shard 1's timer restarts on its own entries into CNT_HOST")
        await bench.disable()
        await tqv.write_word_reg(REG_CFG1 + SHARD1, (2 << 0) | (8 << 4))
        await bench.load_fractured(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg,
                                   chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        peek = self.Peek(dut, 1)
        peek.start()
        await tqv.write_word_reg(REG_PRELOAD2 + SHARD1, (P - 1) | T2_RELOAD | T2_STATE(2) | T2_ONESHOT)
        await self.clocks(5)
        first = len(peek.samples)
        for m in range(4):                                  # shard 1's host toggles: CNT_HOST entries
            await tqv.write_byte_reg(REG_TOGGLE + SHARD1, 0x00)
            await self.clocks(30)
        await toggles((30, 30))                             # pin transitions are shard 0's business
        await self.clocks(30)
        ticks, entries = peek.replay(first, P, state=2, one_shot=True)
        assert (ticks, entries) == (4, 4), (ticks, entries)
        peek.stop()
        await tqv.write_word_reg(REG_PRELOAD2 + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG1, 0)
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 0)
        dut.ui_in[2].value = 0
        await bench.disable()


class ConstTableTest(PrismTest):
    ''' CONST_TAB: the shard's 16x8 latch FIFO as addressable constants.
        The host loads 16 bytes through the flop FIFO, then the const_tab
        chroma performs six comm loads with the index modes clear, + 1, + 1,
        + add_to_idx, = / + idx_load, + 1 and pushes each byte into the
        SRAM FIFO for the host to read back.  Pre and post index update,
        the add-idx_load option, wrap-around, the host's index write and
        read-back, the host's view of the current row, and the same loads
        from CONST's K[] with the table off. '''
    name = "constant table (the latch FIFO as addressable constants)"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        table = [((i + 1) * 0x1D) & 0xFF for i in range(16)]         # 16 distinct bytes
        MODES = (0, 1, 1, 2, 3, 1)                                    # the chroma's six loads

        def model(L, A, load_adds, post, idx):
            out = []
            for m in MODES:
                nxt = (0 if m == 0 else idx + 1 if m == 1 else idx + A if m == 2 else
                       idx + L if load_adds else L) & 15
                out.append(table[idx if post else nxt])
                idx = nxt
            return out, idx

        self.log("load the table through the flop FIFO")
        await bench.disable()
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_DIR_TX)          # the flop FIFO, host pushes
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        for b in table:
            await tqv.write_byte_reg(REG_FIFO, b)
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1F03 == 0x1002          # 16 bytes, full
        await bench.load_chroma(chroma_const_tab, chroma_const_tab_ctrlReg, chroma_const_tab_pinmuxReg)
        await tqv.write_word_reg(REG_FIFO_ST, 0)                     # the SRAM FIFO (RX) takes the pushes

        async def run_once(cfg, idx0=0):
            ''' One pass of the chroma with CONST_TAB = cfg and the index preset; the six bytes '''
            await tqv.write_word_reg(REG_CTAB, cfg | CT_IDX(idx0))
            assert (await tqv.read_word_reg(REG_CTAB)) == (cfg | CT_IDX(idx0))
            c2 = await tqv.read_byte_reg(REG_COUNT2)
            await tqv.write_byte_reg(REG_HOST, 0x01)
            await self.clocks(60)
            await tqv.write_byte_reg(REG_HOST, 0x00)
            await self.clocks(20)
            assert await bench.curr_state() == 0
            assert (await tqv.read_byte_reg(REG_COUNT2) - c2) & 0xFF == 6
            st = await tqv.read_word_reg(REG_FIFO_ST)
            assert (st >> 8) & 0x3FFF == 6, f"{st:#x}"
            got = []
            for _ in range(6):
                for _ in range(20):
                    if await tqv.read_word_reg(REG_FIFO_ST) & 1 == 0:
                        break
                    await self.clocks(2)
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        async def check(cfg, L, A, load_adds, post, idx0=0):
            got = await run_once(cfg, idx0)
            exp, idx = model(L, A, load_adds, post, idx0)
            assert got == exp, f"{cfg:#x} idx0 {idx0}: got {got} expected {exp}"
            assert (await tqv.read_word_reg(REG_CTAB) >> 16) & 0xF == idx

        self.log("pre-update: the row after the move; load, then add idx_load")
        await check(CT_EN | CT_LOAD(9) | CT_ADD(3), 9, 3, False, False)
        await check(CT_EN | CT_LOAD_ADDS | CT_LOAD(9) | CT_ADD(3), 9, 3, True, False)
        self.log("post-update: the row before the move, from a preset index")
        await check(CT_EN | CT_POST | CT_LOAD(9) | CT_ADD(3), 9, 3, False, True, idx0=4)
        await check(CT_EN | CT_POST | CT_LOAD_ADDS | CT_LOAD(9) | CT_ADD(3), 9, 3, True, True)
        self.log("wrap-around")
        await check(CT_EN | CT_LOAD(15) | CT_ADD(7), 15, 7, False, False)
        await check(CT_EN | CT_LOAD_ADDS | CT_LOAD(15) | CT_ADD(7), 15, 7, True, False, idx0=13)

        self.log("table off: the same loads take K[] from CONST")
        await tqv.write_word_reg(REG_CONST, 0xD4C3B2A1)
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_SRAM | CFG_COMM_LOAD_K)
        got = await run_once(0)
        assert got == [0xA1, 0xB2, 0xB2, 0xC3, 0xD4, 0xB2], got
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_SRAM)
        got = await run_once(0)                                      # neither: preload[7:0] = 0
        assert got == [0] * 6, got

        self.log("host view: with the flop FIFO selected, the FIFO register reads the row at the index")
        await tqv.write_word_reg(REG_CFG0, 0)                        # the flop FIFO, RX
        for i in (7, 0, 15):                                         # executing: the row post mode names
            await tqv.write_word_reg(REG_CTAB, CT_EN | CT_POST | CT_IDX(i))
            assert await tqv.read_byte_reg(REG_FIFO) == table[i]
        await tqv.write_word_reg(REG_CTAB, CT_EN | CT_IDX(7))        # pre mode while executing (idle
        assert await tqv.read_byte_reg(REG_FIFO) == table[0]        # outputs = "clear"): row 0
        await bench.disable()                                        # not executing: the index's row
        for i in (7, 3, 15):
            await tqv.write_word_reg(REG_CTAB, CT_EN | CT_IDX(i))
            assert await tqv.read_byte_reg(REG_FIFO) == table[i]
        await tqv.write_word_reg(REG_CTAB, 0)
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_DIR_TX)
        await tqv.write_word_reg(REG_FIFO_ST, 0)                     # the table's bytes out of the flop FIFO
        await tqv.write_word_reg(REG_CFG0, 0)
        await tqv.write_word_reg(REG_CONST, 0)


# =============================================================================
# Low-Speed USB interface Chroma unit test
# =============================================================================
class UsbDeviceTest(PrismTest):
    ''' USB low-speed device: the host model drives D+ / D- on ui_in[4:5] at
        BIT clocks per bit and reads the device's D+ / D- / OE on uo_out[2:4].
        SETUP / OUT data lands in FIFO A (with its CRC16) and is ACKed; IN is
        answered from FIFO B (PID, payload, CRC16 queued by the host) or
        NAKed when it is empty. '''
    name = "USB low-speed device Chroma"
    BIT = 40

    async def run(self):
        tqv, bench, BIT = self.tqv, self.bench, self.BIT
        host = self.start(usb.UsbHost(self.dut, BIT))                         # idle J
        await tqv.write_word_reg(REG_CFG1, (5 << 4) | 4)                      # in_prev1 <- D- (input 5)
        await tqv.write_word_reg(REG_CFG2, 0xD876500E)                        # in16 flag2, in19 comm0, in28-30 comm1-3, in31 match
        await tqv.write_word_reg(REG_CONST, (0x00 << 24) | (0x5A << 16) | (0xD2 << 8) | 0x80)
        await tqv.write_byte_reg(REG_COMPARE, 6)                              # bit stuffing: six ones
        await tqv.write_word_reg(REG_PRELOAD, BIT // 2 - 1)                   # half-bit timer
        await tqv.write_word_reg(REG_CRC_POLY, 0xA001)                        # CRC-16/USB, reflected
        await tqv.write_word_reg(REG_CRC_EXP, 0xB001)                         # its residual
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B = TX (host writes)
        await bench.load_chroma(chroma_usb_ls, chroma_usb_ls_ctrlReg, chroma_usb_ls_pinmuxReg)
        await self.clocks(4 * BIT)
        assert host.device_lines()[2] == 0                                    # not driving

        self.log("SETUP + DATA0 -> ACK")
        payload = [0x80, 0x06, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00]            # GET_DESCRIPTOR
        await host.send(usb.token_bits(usb.PID_SETUP, 0, 0))
        await host.send(usb.data_bits(usb.PID_DATA0, payload))
        reply = await host.receive()
        assert reply == [usb.PID_ACK], reply
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x1F == len(payload) + 2, f"{st:#x}"
        got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(len(payload) + 2)]
        assert got == payload + usb.crc16(payload), [hex(x) for x in got]

        self.log("IN with nothing queued -> NAK")
        await host.send(usb.token_bits(usb.PID_IN, 0, 0))
        reply = await host.receive()
        assert reply == [usb.PID_NAK], reply

        self.log("IN -> DATA1 from FIFO B, then ACK it")
        resp = [0x12, 0x01, 0x10, 0x01]
        for b in [usb.PID_DATA1] + resp + usb.crc16(resp):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await host.send(usb.token_bits(usb.PID_IN, 0, 0))
        reply = await host.receive()
        assert reply == [usb.PID_DATA1] + resp + usb.crc16(resp), [hex(x) for x in (reply or [])]
        await host.send(usb.handshake_bits(usb.PID_ACK))
        await self.clocks(4 * BIT)
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 1 == 1         # B drained

        self.log("OUT + DATA1 with bit stuffing -> ACK")
        payload2 = [0xFF, 0xFF, 0x7F, 0x00, 0xFE]
        await host.send(usb.token_bits(usb.PID_OUT, 0, 0))
        await host.send(usb.data_bits(usb.PID_DATA1, payload2))
        reply = await host.receive()
        assert reply == [usb.PID_ACK], reply
        got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(len(payload2) + 2)]
        assert got == payload2 + usb.crc16(payload2), [hex(x) for x in got]
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
        host.idle()
        await bench.disable()


# =============================================================================
# Unit test for a fractured PRISM (i.e. two separate 16-state FSMs)
# =============================================================================
class EthernetTxTest(PrismTest):
    ''' 10BASE-T transmitter from the SRAM FIFO: Manchester at 6 clocks per
        bit, preamble from the constant table and the FIFO, CRC32 FCS from
        the CRC unit, TP_IDL, link pulses on request.  The decoder model
        checks every frame byte for byte. '''
    name = "Ethernet transmitter Chroma (SRAM FIFO)"
    BIT = 6

    async def run(self):
        tqv, bench, BIT = self.tqv, self.bench, self.BIT
        dec = self.start(eth.EthDecoder(self.dut, BIT))
        await tqv.write_word_reg(REG_CFG1, 8 | (9 << 4))                      # in_prev0/1 <- host_in[0]/[1]
        await tqv.write_word_reg(REG_CONST, 0x55)                             # K0 = preamble byte
        await tqv.write_byte_reg(REG_COMPARE, 3)                              # count2 phases of four
        await tqv.write_word_reg(REG_PRELOAD, BIT // 2 - 1)                   # half-bit timer
        await tqv.write_word_reg(REG_CRC_POLY, 0xEDB88320)                    # CRC32, reflected
        await tqv.write_byte_reg(REG_HOST, 0)
        await bench.load_chroma(chroma_eth_tx, chroma_eth_tx_ctrlReg | CFG_FIFO_SRAM, chroma_eth_tx_pinmuxReg)
        await self.clocks(20)
        assert dec.lines()[1] == 0                                            # TX_EN low

        def frame(payload):
            return [0x55, 0x55, 0x55, 0xD5] + payload

        self.log("64-byte frame")
        payload = [0x01, 0x80, 0xC2, 0x00, 0x00, 0x0E] + [0x02, 0x00, 0x00, 0x00, 0x00, 0x01] + \
                  [0x88, 0xCC] + [(i * 7 + 3) & 0xFF for i in range(46)]
        for b in frame(payload):
            await tqv.write_byte_reg(REG_FIFO, b)
        await tqv.write_byte_reg(REG_TOGGLE, 0)                               # host_in[0] toggles: send
        for _ in range(200):
            if dec.frames:
                break
            await self.clocks(BIT * 8)
        assert len(dec.frames) == 1, dec.frames
        expect = [0x55] * 7 + [0xD5] + payload + eth.crc32(payload)
        got = dec.frames[0]
        assert got == expect, f"{len(got)} bytes: {[hex(x) for x in got[:12]]} .. {[hex(x) for x in got[-6:]]}"
        await self.clocks(BIT * 4)
        assert await bench.irq()                                              # frame done
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1

        self.log("link pulse")
        host = await tqv.read_byte_reg(REG_HOST)
        await tqv.write_word_reg(REG_HOST, host ^ 2)                          # host_in[1] toggles, [0] kept
        for _ in range(40):
            if dec.pulses:
                break
            await self.clocks(BIT)
        assert dec.pulses == 1

        self.log("link pulses from the free-running timer (PRELOAD2)")
        period = BIT * 40                                                     # 40 bit times between pulses
        await tqv.write_word_reg(REG_PRELOAD2, period - 1)
        before = dec.pulses
        await self.clocks(period * 4 + BIT * 4)
        assert 3 <= dec.pulses - before <= 5, f"{dec.pulses - before} pulses in four periods"
        await tqv.write_word_reg(REG_PRELOAD2, 0)                             # off
        before = dec.pulses
        await self.clocks(period * 2)
        assert dec.pulses == before, "pulses with the timer off"

        self.log("300-byte frame streamed from the SRAM")
        payload = [(i * 31 + 11) & 0xFF for i in range(300)]
        for b in frame(payload):
            await tqv.write_byte_reg(REG_FIFO, b)
        await tqv.write_byte_reg(REG_TOGGLE, 0)
        for _ in range(600):
            if len(dec.frames) == 2:
                break
            await self.clocks(BIT * 8)
        assert len(dec.frames) == 2
        expect = [0x55] * 7 + [0xD5] + payload + eth.crc32(payload)
        got = dec.frames[1]
        assert got == expect, f"{len(got)} bytes"
        await self.clocks(BIT * 4)
        assert await bench.irq()

        self.log("timer pulses do not disturb a frame")
        await tqv.write_word_reg(REG_PRELOAD2, BIT * 20 - 1)                  # a tick every 20 bit times
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        payload = [(i * 3 + 7) & 0xFF for i in range(80)]
        for b in frame(payload):
            await tqv.write_byte_reg(REG_FIFO, b)
        await tqv.write_byte_reg(REG_TOGGLE, 0)
        for _ in range(300):
            if len(dec.frames) == 3:
                break
            await self.clocks(BIT * 8)
        assert len(dec.frames) == 3
        assert dec.frames[2] == [0x55] * 7 + [0xD5] + payload + eth.crc32(payload)
        await tqv.write_word_reg(REG_PRELOAD2, 0)
        await bench.disable()


class EthernetRxTest(PrismTest):
    ''' 10BASE-T receive: the Manchester bit recoverer (CFG3) on ui_in[3],
        the eth_rx chroma assembling bytes into the SRAM FIFO, the host
        checking the bytes and the CRC32 residue.  A link pulse first (no
        frame), a 64-byte frame, a 300-byte frame from a line 8% slower than
        the clock, a frame with a bad FCS. '''
    name = "ethernet rx"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        BIT = 6                                                               # clocks per bit
        PIN = 3
        await tqv.write_word_reg(REG_CFG3, PIN | (1 << 3) | ((BIT // 2) << 4) | (1 << 8))
        await tqv.write_word_reg(REG_CFG2, 15 | (12 << 4) | (11 << 8))       # in16 bit valid, in17 comm[7], in18 comm[6]
        await tqv.write_word_reg(REG_CONST, 0)                                # K0 = 0 clears comm
        await tqv.write_byte_reg(REG_COMPARE, 8)                              # bits per byte
        await tqv.write_word_reg(REG_PRELOAD, 2 * BIT)                        # idle: two bit times
        await tqv.write_word_reg(REG_CRC_POLY, 0xEDB88320)                    # CRC32, reflected
        await tqv.write_word_reg(REG_CRC_EXP, 0xDEBB20E3)                     # residue over data + FCS
        await bench.load_chroma(chroma_eth_rx, chroma_eth_rx_ctrlReg | CFG_FIFO_SRAM, chroma_eth_rx_pinmuxReg)
        await tqv.write_word_reg(REG_FIFO_ST, 0)                              # flush
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        enc = eth.EthEncoder(self.dut, BIT, rxd=PIN)
        await enc.idle(BIT * 4)

        async def receive(payload, fcs=None, stretch=0):
            e = eth.EthEncoder(self.dut, BIT, rxd=PIN, stretch=stretch)
            await e.frame(payload, fcs=fcs)
            await self.clocks(BIT * 4)
            assert await bench.irq(), "no end-of-frame interrupt"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            expect = payload + (eth.crc32(payload) if fcs is None else fcs)
            st = await tqv.read_word_reg(REG_FIFO_ST)
            assert (st >> 8) & 0x3FFF == len(expect), f"FIFO holds {(st >> 8) & 0x3FFF}, expected {len(expect)}"
            got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(len(expect))]
            assert got == expect, f"{len(got)} bytes: {[hex(x) for x in got[:12]]} .. {[hex(x) for x in got[-6:]]}"
            assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
            return await tqv.read_word_reg(REG_FLAGS), await tqv.read_word_reg(REG_CRC)

        self.log("link pulse: no frame")
        await enc.link_pulse()
        await self.clocks(BIT * 4)
        assert not await bench.irq()
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1

        self.log("64-byte frame")
        payload = [0x01, 0x80, 0xC2, 0x00, 0x00, 0x0E] + [0x02, 0x00, 0x00, 0x00, 0x00, 0x01] + \
                  [0x88, 0xCC] + [(i * 7 + 3) & 0xFF for i in range(46)]
        flags, crc = await receive(payload)
        assert flags & FLAG_CRC_OK, f"crc_ok clear, CRC = {crc:#x}"

        self.log("300-byte frame, line 8% slower than the clock")
        payload = [(i * 31 + 11) & 0xFF for i in range(300)]
        flags, crc = await receive(payload, stretch=6)
        assert flags & FLAG_CRC_OK, f"crc_ok clear, CRC = {crc:#x}"

        self.log("frame with a corrupted FCS")
        payload = [(i * 5 + 1) & 0xFF for i in range(60)]
        bad = eth.crc32(payload)
        bad[1] ^= 0x10
        flags, crc = await receive(payload, fcs=bad)
        assert not (flags & FLAG_CRC_OK), f"crc_ok set on a bad FCS, CRC = {crc:#x}"
        await bench.disable()


class EthernetLoopTest(PrismTest):
    ''' The Ethernet stretch goal in one PRISM: eth_tx in shard 0 (SRAM 0 as
        its TX FIFO) and eth_rx in shard 1 (SRAM 1 as its RX FIFO), fractured,
        with TXD looped back into the receive pin by the bench.  The host
        queues a frame in shard 0 and reads it back from shard 1. '''
    name = "ethernet tx -> rx loopback (fractured)"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        BIT = 6
        PIN = 3

        async def loopback():
            while True:
                await RisingEdge(self.dut.clk)
                v = int(self.dut.uo_out.value)
                txd = (v >> 1) & 1 if (v >> 2) & 1 else 0                    # TXD while TX_EN, else idle low
                ui = int(self.dut.ui_in.value)
                self.dut.ui_in.value = (ui | (1 << PIN)) if txd else (ui & ~(1 << PIN))
        loop_task = cocotb.start_soon(loopback())

        # shard 0: transmitter (as EthernetTxTest)
        await tqv.write_word_reg(REG_CFG1, 8 | (9 << 4))
        await tqv.write_word_reg(REG_CONST, 0x55)
        await tqv.write_byte_reg(REG_COMPARE, 3)
        await tqv.write_word_reg(REG_PRELOAD, BIT // 2 - 1)
        await tqv.write_word_reg(REG_CRC_POLY, 0xEDB88320)
        await tqv.write_byte_reg(REG_HOST, 0)
        # shard 1: receiver (as EthernetRxTest)
        await tqv.write_word_reg(REG_CFG3 + SHARD1, PIN | (1 << 3) | ((BIT // 2) << 4) | (1 << 8))
        await tqv.write_word_reg(REG_CFG2 + SHARD1, 15 | (12 << 4) | (11 << 8))
        await tqv.write_word_reg(REG_CONST + SHARD1, 0)
        await tqv.write_byte_reg(REG_COMPARE + SHARD1, 8)
        await tqv.write_word_reg(REG_PRELOAD + SHARD1, 2 * BIT)
        await tqv.write_word_reg(REG_CRC_POLY + SHARD1, 0xEDB88320)
        await tqv.write_word_reg(REG_CRC_EXP + SHARD1, 0xDEBB20E3)
        await bench.load_fractured(chroma_eth_tx, chroma_eth_tx_ctrlReg | CFG_FIFO_SRAM, chroma_eth_tx_pinmuxReg,
                                   chroma_eth_rx, chroma_eth_rx_ctrlReg | CFG_FIFO_SRAM, chroma_eth_rx_pinmuxReg)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        await tqv.write_byte_reg(REG_INT_CLR1, 0x80)
        await self.clocks(BIT * 8)

        async def send_receive(payload):
            for b in [0x55, 0x55, 0x55, 0xD5] + payload:
                await tqv.write_byte_reg(REG_FIFO, b)
            await tqv.write_byte_reg(REG_TOGGLE, 0)                           # shard 0: send
            for _ in range(len(payload) * 2 + 100):
                if await bench.irq(IRQ1_MASK):
                    break
                await self.clocks(BIT * 8)
            assert await bench.irq(IRQ1_MASK), "receiver never finished"
            assert await bench.irq(IRQ0_MASK), "transmitter never finished"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            await tqv.write_byte_reg(REG_INT_CLR1, 0x80)
            expect = payload + eth.crc32(payload)
            st = await tqv.read_word_reg(REG_FIFO_ST + SHARD1)
            assert (st >> 8) & 0x3FFF == len(expect), f"RX FIFO holds {(st >> 8) & 0x3FFF}, expected {len(expect)}"
            got = [await tqv.read_byte_reg(REG_FIFO + SHARD1) for _ in range(len(expect))]
            assert got == expect, f"{len(got)} bytes: {[hex(x) for x in got[:12]]} .. {[hex(x) for x in got[-6:]]}"
            assert await tqv.read_word_reg(REG_FLAGS + SHARD1) & FLAG_CRC_OK, "crc_ok clear"
            assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1                # TX FIFO drained

        self.log("64-byte frame, shard 0 -> shard 1")
        await send_receive([0x01, 0x80, 0xC2, 0x00, 0x00, 0x0E] + [0x02, 0x00, 0x00, 0x00, 0x00, 0x01] +
                           [0x88, 0xCC] + [(i * 7 + 3) & 0xFF for i in range(46)])
        self.log("300-byte frame through both SRAM FIFOs")
        await send_receive([(i * 31 + 11) & 0xFF for i in range(300)])
        loop_task.kill()
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
        await bench.disable()


class FracturedTest(PrismTest):
    ''' Fractured: encoder in shard 0 (ui_in[1:0], no output pins) and ws2812
        in shard 1 (uo_out[1], host_in, interrupt), each on its own datapath '''
    name = "fractured PRISM (encoder + ws2812)"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        encoder_test = EncoderTest(bench)
        ws2812_test  = Ws2812Test(bench)
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_byte_reg(REG_HOST + SHARD1, 0x00)
        await bench.load_fractured(chroma_encoder, chroma_encoder_ctrlReg, chroma_encoder_pinmuxReg,
                                   chroma_ws2812,  chroma_ws2812_ctrlReg,  chroma_ws2812_pinmuxReg)

        self.log("Shard 0: encoder")
        await encoder_test.drive(0, encoder_test.encoder())

        # Let the encoder's last debounced step land, then remember its position
        await self.clocks(512)
        pos0 = await tqv.read_byte_reg(REG_COUNT2)

        self.log("Shard 1: ws2812")
        slave = self.start(Ws2812Slave(self.dut))
        await ws2812_test.drive(SHARD1, IRQ1_MASK, slave)

        # Shard 0's count2 (encoder position) must be untouched by shard 1's run
        self.log("Testing shard isolation")
        assert await tqv.read_byte_reg(REG_COUNT2) == pos0
        assert not await bench.irq(IRQ0_MASK)
        assert await tqv.read_word_reg(REG_INT_STATUS) & 0x3 == 0x2

        # Shard 1 interrupt clear through its own INT_CLR byte
        await tqv.write_byte_reg(REG_INT_CLR1, 0x80)
        assert not await bench.irq(IRQ1_MASK)
        await tqv.write_word_reg(REG_FRAC_CFG, 0)


# =============================================================================
# Trace: execution capture into the SRAMs
# =============================================================================
class TraceMonitor:
    ''' Golden model of the trace: what the tracer records every clock for
        one shard, sampled at the falling edge (stable, and what the next
        rising edge captures), plus the outputs actually driven, to check
        the host's reconstruction. '''
    def __init__(self, dut, shard):
        prism = dut.user_project.i_peripherals.i_prism
        core  = prism.i_prism
        self.clk = dut.clk
        self.si  = core.trace_si    if shard == 0 else core.trace_si_1
        self.mux = core.trace_mux   if shard == 0 else core.trace_mux_1
        self.mt  = core.trace_match if shard == 0 else core.trace_match_1
        self.out = core.out_data    if shard == 0 else core.out_data_1
        self.inp = core.in_data     if shard == 0 else core.in_data_1
        self.ex  = prism.SH[shard].exec
        self.cap = prism.SH[shard].trc_capture          # the cycles an entry is captured
        self.entries = []
        self.outs    = []
        self.inputs  = []
        self.caps    = []
        self.task = None

    @staticmethod
    def iv(sig):
        try: return int(sig.value)
        except ValueError: return 0

    async def _run(self):
        while True:
            await FallingEdge(self.clk)
            self.entries.append(trace_entry(self.iv(self.si), self.iv(self.mux), self.iv(self.mt), self.iv(self.ex)))
            self.outs.append(self.iv(self.out))
            self.inputs.append(self.iv(self.inp))
            self.caps.append(self.iv(self.cap))

    def start(self):
        self.task = cocotb.start_soon(self._run())

    def stop(self):
        if self.task is not None:
            self.task.kill()

    def start_of_capture(self):
        ''' Golden index of entry 0 of the most recent capture '''
        i = len(self.caps) - 1
        while i >= 0 and not self.caps[i]:
            i -= 1
        while i >= 0 and self.caps[i]:
            i -= 1
        assert i + 1 < len(self.caps), "no capture seen"
        return i + 1

    def check(self, got, first=0):
        ''' `got` must be entries first.. of the most recent capture; returns
            the golden index of entry 0 '''
        off = self.start_of_capture()
        exp = self.entries[off + first: off + first + len(got)]
        if got != exp:
            k = next((i for i in range(min(len(got), len(exp))) if got[i] != exp[i]), min(len(got), len(exp)))
            assert False, (f"entries {first}..: {len(got)} read, {len(exp)} expected; first difference at {first + k}: "
                           f"got " + " ".join(f"{e:04x}" for e in got[k:k + 6]) + " expected " +
                           " ".join(f"{e:04x}" for e in exp[k:k + 6]) + f" (capture run length {self.run_length()})")
        return off

    def run_length(self):
        off = self.start_of_capture(); n = 0
        while off + n < len(self.caps) and self.caps[off + n]:
            n += 1
        return n

    def check_outputs(self, got, chroma, first=0):
        ''' The host's reconstruction of the outputs from each entry and the
            chroma must be what the shard drove in that clock '''
        off = self.start_of_capture()
        for k, e in enumerate(got):
            exp = trace_outputs(e, chroma)
            if exp is not None:
                assert exp == self.outs[off + first + k], f"entry {first + k} {e:04x}: outputs {exp:06x} != {self.outs[off + first + k]:06x}"


class TraceTest(PrismTest):
    ''' The tracer: from the trigger on, every clock's {executing, tree
        results, six LUT inputs, SI} of a shard goes into its SRAM (two
        16-bit entries per word) until the buffer is full, then the host
        reads the entries back as FIFO bytes and rebuilds the outputs from
        the chroma.  Triggers: at once, in a state, a state taking a jump,
        an edge on a PRISM input.  Each shard into its own SRAM at the same
        time, or one shard into both SRAMs as a 2048-entry buffer.  Checked
        against a golden record of the core's taps every clock. '''
    name = "trace (execution capture into the SRAMs)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[2].value = 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG1, (2 << 0) | (8 << 4))
        await bench.load_chroma(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        mon0 = self.start(TraceMonitor(dut, 0))
        await self.clocks(20)

        def toggle():
            dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)

        async def activity(clocks):
            ''' Pin transitions at odd gaps for about `clocks` clocks '''
            gaps = (5, 9, 13, 7, 30, 11, 6, 8, 21, 4)
            n = 0
            while n < clocks:
                for g in gaps:
                    toggle()
                    await self.clocks(g)
                    n += g

        async def status(base=0):
            return await tqv.read_word_reg(REG_TRACE_CTRL + base)

        async def readout(count, base=0):
            ''' The next `count` entries of the trace in the SRAM read through
                window `base`: two FIFO bytes each, low byte first '''
            for _ in range(50):
                if await tqv.read_word_reg(REG_FIFO_ST + base) & 1 == 0:
                    break
                await self.clocks(4)
            got = []
            for _ in range(count):
                lo = await tqv.read_byte_reg(REG_FIFO + base)
                got.append(lo | (await tqv.read_byte_reg(REG_FIFO + base)) << 8)
            return got

        # The STEW word order the reconstruction relies on: the core's STEW
        # of the current state (WAIT) reads back as the chroma's words
        stew = 0
        for w in range(STEW_WORDS):
            stew |= (await tqv.read_word_reg(REG_STEW0 + 4 * w)) << (32 * w)
        assert stew == stew_of(chroma_edge, 0), f"{stew:#034x} != {stew_of(chroma_edge, 0):#034x}"

        async def fifo_bytes(base=0):
            return (await tqv.read_word_reg(REG_FIFO_ST + base) >> 8) & 0x3FFF

        # ---- trigger in a state: CNT_PIN (1) ---------------------------------
        self.log("trigger in state CNT_PIN, 1024 entries into SRAM 0")
        cfg = TRC_EN | TRC_TRIG_STATE | TRC_STATE(1)
        await tqv.write_word_reg(REG_TRACE_CFG, cfg)                # (write-only)
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE, f"{st:#x}"
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)
        await self.clocks(60)                                       # WAIT, no transition: still armed
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_ARMED, f"{st:#x}"
        await activity(1200)
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_DONE, f"{st:#x}"
        assert await fifo_bytes() == TRC_ENTRIES * 2                # the FIFO serves the trace
        got = await readout(48)
        assert trace_si(got[0]) == 1 and got[0] & TRC_E_EXEC, f"{got[0]:#x}"   # entry 0: the trigger cycle
        assert trace_outputs(got[0], chroma_edge) & (1 << 9)        # CNT_PIN: OUT_COUNT2_INC
        assert trace_si(got[1]) == 0                                # back to WAIT
        off = mon0.check(got)
        mon0.check_outputs(got, chroma_edge)
        assert trace_si(mon0.entries[off - 1]) != 1                 # not in CNT_PIN the cycle before
        assert await fifo_bytes() == (TRC_ENTRIES - 48) * 2
        mon0.check(await readout(16), 48)                           # reading on continues

        # ---- trigger on a jump: WAIT (0) taking either branch ----------------
        self.log("trigger on WAIT taking a jump")
        await tqv.write_word_reg(REG_TRACE_CFG, TRC_EN | TRC_TRIG_JUMP | TRC_STATE(0))
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)
        await self.clocks(80)                                       # in WAIT, nothing jumps
        assert (await status()) & TRC_ST_ARMED
        toggle()
        await activity(1200)
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_DONE, f"{st:#x}"
        got = await readout(8)
        assert trace_si(got[0]) == 0 and trace_si(got[1]) == 1, [hex(e) for e in got[:2]]
        assert got[0] & (TRC_E_MATCH0 | TRC_E_MATCH1)               # the jump cycle
        assert trace_outputs(got[1], chroma_edge) & (1 << 9)
        off = mon0.check(got)
        mon0.check_outputs(got, chroma_edge)
        assert trace_si(mon0.entries[off - 1]) == 0                  # WAIT before the jump

        # ---- trigger on an input edge: input 2 rising, falling, either -------
        self.log("trigger on an edge of input 2")
        dut.ui_in[2].value = 0
        await self.clocks(30)
        for edge, level in ((TRC_EDGE_RISE, 1), (TRC_EDGE_FALL, 0), (TRC_EDGE_ANY, 1)):
            await tqv.write_word_reg(REG_TRACE_CFG, TRC_EN | TRC_TRIG_EDGE | edge | TRC_INPUT(2))
            await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)
            await self.clocks(60)
            assert (await status()) & TRC_ST_ARMED
            dut.ui_in[2].value = level
            await activity(1200)
            st = await status()
            assert st & TRC_ST_DONE and await fifo_bytes() == TRC_ENTRIES * 2, f"{st:#x}"
            got = await readout(8)
            off = mon0.check(got)
            assert (mon0.inputs[off] >> 2) & 1 == level             # the edge cycle
            assert (mon0.inputs[off - 1] >> 2) & 1 == 1 - level
            assert trace_si(got[0]) == 0                            # WAIT sees the edge
            dut.ui_in[2].value = level
            await self.clocks(30)

        # ---- trigger at once, stopped by the host ----------------------------
        self.log("immediate trigger, stop")
        await tqv.write_word_reg(REG_TRACE_CFG, TRC_EN | TRC_TRIG_NOW)
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)
        await activity(41)                                          # (an odd count is likely)
        st = await status()
        assert st & 0x7 == TRC_ST_RUNNING, f"{st:#x}"
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_STOP)
        st = await status()
        n = await fifo_bytes() // 2
        assert st & 0x7 == TRC_ST_DONE and 40 < n < TRC_ENTRIES, f"{st:#x} {n}"
        got = await readout(n)                                      # every entry
        mon0.check(got)
        mon0.check_outputs(got, chroma_edge)
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1        # and nothing more

        # ---- both SRAMs as one buffer for shard 0 ----------------------------
        self.log("big buffer: 2048 entries across both SRAMs")
        await tqv.write_word_reg(REG_TRACE_CFG + SHARD1, TRC_EN)   # shard 1 asks too: it gets nothing
        await tqv.write_word_reg(REG_TRACE_CFG, TRC_EN | TRC_BIG | TRC_TRIG_NOW)
        assert (await status(SHARD1)) & TRC_ST_ACTIVE == 0
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)
        await activity(2200)
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_BIG | TRC_ST_DONE, f"{st:#x}"
        assert await fifo_bytes() == TRC_ENTRIES * 2 and await fifo_bytes(SHARD1) == TRC_ENTRIES * 2
        got = await readout(TRC_ENTRIES)                                       # all of SRAM 0 through window 0
        mon0.check(got)
        mon0.check_outputs(got, chroma_edge)
        assert await tqv.read_word_reg(REG_FIFO_ST) & 1 == 1
        mon0.check(await readout(8, SHARD1), TRC_ENTRIES)                      # SRAM 1 through window 1
        await tqv.write_word_reg(REG_TRACE_CFG, 0)
        assert (await status(SHARD1)) & TRC_ST_ACTIVE                          # shard 1 has SRAM 1 now
        await tqv.write_word_reg(REG_TRACE_CFG + SHARD1, 0)

        # ---- the SRAM FIFO while traced, and back once the trace lets go -----
        self.log("SRAM FIFO around a trace")
        await bench.disable()
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        for b in range(5):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x30 + b)
        assert await fifo_bytes(SHARD1) == 5
        # traced (a trigger that cannot fire: state 15 with the PRISM off): pushes dropped
        await tqv.write_word_reg(REG_TRACE_CFG + SHARD1, TRC_EN | TRC_TRIG_STATE | TRC_STATE(15))
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x77)
        assert await fifo_bytes(SHARD1) == 5
        await tqv.write_word_reg(REG_TRACE_CTRL + SHARD1, TRC_ARM)             # arm flushes it
        assert await fifo_bytes(SHARD1) == 0
        assert (await status(SHARD1)) & 0x1f == TRC_ST_ACTIVE | TRC_ST_ARMED
        await tqv.write_word_reg(REG_TRACE_CTRL + SHARD1, TRC_STOP)            # nothing recorded
        st = await status(SHARD1)
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_DONE, f"{st:#x}"
        assert await fifo_bytes(SHARD1) == 0
        await tqv.write_word_reg(REG_TRACE_CFG + SHARD1, 0)
        for b in range(3):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x40 + b)
        assert await fifo_bytes(SHARD1) == 3
        assert await tqv.read_byte_reg(REG_FIFO + SHARD1) == 0x40
        await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)

        # ---- into the other SRAM: shard 0 traces into SRAM 1, its own SRAM FIFO untouched
        self.log("shard 0 traces into SRAM 1 (TRC_OTHER) while its SRAM 0 FIFO keeps its bytes")
        await tqv.write_word_reg(REG_CFG0, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        for b in range(5):
            await tqv.write_byte_reg(REG_FIFO, 0x50 + b)
        await tqv.write_word_reg(REG_TRACE_CFG, TRC_EN | TRC_OTHER | TRC_TRIG_STATE | TRC_STATE(1))
        st = await status()
        assert st & 0x1b == TRC_ST_ACTIVE, f"{st:#x}"              # (done lingers from the last trace)
        await tqv.write_byte_reg(REG_FIFO, 0x55)                 # SRAM 0 is not traced: the push lands
        assert await fifo_bytes() == 6
        await bench.enable()
        await tqv.write_word_reg(REG_TRACE_CTRL, TRC_ARM)         # arm flushes SRAM 1, not SRAM 0
        await self.clocks(40)
        assert (await status()) & TRC_ST_ARMED and await fifo_bytes() == 6
        await activity(1200)
        st = await status()
        assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_DONE, f"{st:#x}"
        assert await fifo_bytes() == 6 and await fifo_bytes(SHARD1) == TRC_ENTRIES * 2
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX | CFG_FIFO_SRAM)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x77)        # SRAM 1 is traced: dropped
        assert await fifo_bytes(SHARD1) == TRC_ENTRIES * 2
        got = await readout(48, SHARD1)                          # shard 0's entries through window 1
        off = mon0.check(got)
        assert trace_si(got[0]) == 1 and got[0] & TRC_E_EXEC, f"{got[0]:#x}"
        mon0.check_outputs(got, chroma_edge)
        assert trace_si(mon0.entries[off - 1]) != 1
        assert await fifo_bytes(SHARD1) == (TRC_ENTRIES - 48) * 2
        assert await fifo_bytes() == 6                           # SRAM 0's FIFO bytes, all still there
        assert await tqv.read_byte_reg(REG_FIFO) == 0x50
        await tqv.write_word_reg(REG_TRACE_CFG, 0)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG0, 0)
        await bench.disable()

        # ---- fractured: one shard at a time (shard 0 wins), each into its own SRAM
        self.log("fractured: shard 0 then shard 1 trace the same kind of edge into their own SRAMs")
        await tqv.write_word_reg(REG_CFG1 + SHARD1, (2 << 0) | (8 << 4))
        await bench.load_fractured(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg,
                                   chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        mon1 = self.start(TraceMonitor(dut, 1))
        await self.clocks(20)
        for base in (0, SHARD1):
            await tqv.write_word_reg(REG_TRACE_CFG + base, TRC_EN | TRC_TRIG_EDGE | TRC_EDGE_ANY | TRC_INPUT(2))
        assert (await status()) & TRC_ST_ACTIVE and not (await status(SHARD1)) & TRC_ST_ACTIVE   # shard 0 wins
        gots = {}
        for base, mon in ((0, mon0), (SHARD1, mon1)):
            await tqv.write_word_reg(REG_TRACE_CTRL + base, TRC_ARM)
            await self.clocks(40)
            assert (await status(base)) & TRC_ST_ARMED
            toggle()
            for m in range(3):                                      # shard 1's host toggles: only it sees them
                await tqv.write_byte_reg(REG_TOGGLE + SHARD1, 0x00)
            await activity(1200)
            st = await status(base)
            assert st & 0x1f == TRC_ST_ACTIVE | TRC_ST_DONE, f"{base:#x}: {st:#x}"
            assert await fifo_bytes(base) == TRC_ENTRIES * 2
            got = await readout(60, base)
            mon.check(got)
            mon.check_outputs(got, chroma_edge)
            assert trace_si(got[0]) == 0
            gots[base] = got
            await tqv.write_word_reg(REG_TRACE_CFG + base, 0)          # hand over to shard 1
            if base == 0:
                assert (await status(SHARD1)) & TRC_ST_ACTIVE
        # shard 1 counted its host toggles (CNT_HOST = 2) somewhere in its trace, shard 0 never
        assert any(trace_si(e) == 2 for e in gots[SHARD1]) and not any(trace_si(e) == 2 for e in gots[0])

        await tqv.write_word_reg(REG_TRACE_CFG, 0)
        await tqv.write_word_reg(REG_TRACE_CFG + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG1, 0)
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 0)
        dut.ui_in[2].value = 0
        await bench.disable()
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
