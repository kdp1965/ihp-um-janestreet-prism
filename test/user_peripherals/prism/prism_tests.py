# The PRISM unit tests, one class per subject.  Each runs on the shared
# PrismBench (bench.py) after a reset; test.py wraps them as cocotb tests.

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge

from user_peripherals.prism.regs import *
from user_peripherals.prism.bench import PrismTest
from user_peripherals.prism.models import Shift74165, Shift74595, SpiMaster, UartRx, Ws2812Slave
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
