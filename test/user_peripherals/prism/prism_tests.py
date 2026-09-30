# The PRISM unit tests, one class per subject.  Each runs on the shared
# PrismBench (bench.py) after a reset; test.py wraps them as cocotb tests.

import os

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge

from user_peripherals.prism.regs import *
from user_peripherals.prism.bench import PrismTest
from user_peripherals.prism.models import Shift74165, Shift74595, SpiMaster, UartRx, UartTx, Ws2812Slave, I2cSlave, I2cMaster, QspiSlave, OneWireSlave, JtagTap, SwdTarget, Ps2Device
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
from user_peripherals.prism.chroma_pio import *
from user_peripherals.prism.chroma_spi_master import *
from user_peripherals.prism.chroma_onewire import *
from user_peripherals.prism.chroma_usb_ls import *
from user_peripherals.prism.chroma_eth_tx import *
from user_peripherals.prism.chroma_eth_rx import *
from user_peripherals.prism.chroma_counter import *
from user_peripherals.prism.chroma_count3 import *
from user_peripherals.prism.chroma_can_rx import *
from user_peripherals.prism.chroma_can_tx import *
from user_peripherals.prism.chroma_uart_rx import *
from user_peripherals.prism.chroma_jtag_master import *
from user_peripherals.prism.chroma_spw_tx import *
from user_peripherals.prism.chroma_spw_fct_stub import *
from user_peripherals.prism.chroma_spw_rx import *
from user_peripherals.prism.chroma_swd_host import *
from user_peripherals.prism.chroma_ps2_host import *
from user_peripherals.prism.chroma_vga_px import *
from user_peripherals.prism.chroma_vga_ln import *
from user_peripherals.prism import can_model as can
from user_peripherals.prism import spw_model as spw


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
            assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x3FFF03 == 0x000001   # empty, count 0
            for b in (0x11, 0x22, 0x33):
                await tqv.write_byte_reg(REG_FIFO + base, b)
            st = await tqv.read_word_reg(REG_FIFO_ST + base)
            assert (st >> 8) & 0x3FFF == 3 and st & 0x3 == 0, f"{st:#x}"
            assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11
            assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11               # TX: no pop on read
            for b in range(fifo_depth(base) - 3):
                await tqv.write_byte_reg(REG_FIFO + base, (0x40 + b) & 0xFF)
            st = await tqv.read_word_reg(REG_FIFO_ST + base)
            assert fifo_count(st) == fifo_depth(base) and st & 0x2, f"{st:#x}"       # full
            await tqv.write_byte_reg(REG_FIFO + base, 0xEE)                        # dropped
            assert fifo_count(await tqv.read_word_reg(REG_FIFO_ST + base)) == fifo_depth(base)
            await tqv.write_word_reg(REG_FIFO_ST + base, 0)                        # flush
            assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x3FFF03 == 0x000001
            await tqv.write_word_reg(REG_CRC_POLY + base, 0x04C11DB7)
            await tqv.write_word_reg(REG_CRC_EXP + base, 0xDEBB20E3)
            assert await tqv.read_word_reg(REG_CRC_POLY + base) == 0x04C11DB7
            assert await tqv.read_word_reg(REG_CRC_EXP + base) == 0xDEBB20E3
            await tqv.write_word_reg(REG_CFG0 + base, 0)
        # the other shard's FIFO must be untouched by the flush above
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x3FFF03 == 0x000001

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
        assert (st >> 8) & 0x3FFF == len(spi_data), f"{st:#x}"
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

        self.log("the timer action with a phase preset: count1 <= PRELOAD >> k on the edge")
        await tqv.write_word_reg(REG_COUNT1, 5)
        await tqv.write_word_reg(REG_CFG3, smp(CFG3_SMP_RISE, CFG3_SMP_TIMER) | CFG3_SMP_PRESET(2))
        dut.ui_in[CLK].value = 1
        await self.clocks(6)
        dut.ui_in[CLK].value = 0
        await self.clocks(4)
        assert await tqv.read_word_reg(REG_COUNT1) == 0x1234 >> 2, "preset = PRELOAD >> 2"
        await tqv.write_word_reg(REG_CFG3, 0)

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
        slave = self.start(I2cSlave(dut, ADDR, scl_in=2))
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
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF):
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
        assert (st >> 8) & 0x3FFF == 1, f"{st:#x}"
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
        master = self.start(I2cMaster(dut, half=16, scl_in=2))
        await bench.load_chroma(chroma_i2c_slave, chroma_i2c_slave_ctrlReg, chroma_i2c_slave_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)      # FIFO B: the bytes to be read
        await tqv.write_word_reg(REG_CFG2, (13 << 4) | (14 << 8) | (5 << 12))   # match, flag2, comm[0]
        await tqv.write_word_reg(REG_CONST, (ADDR << 24) | 0xFF00)          # K3 = address, K1 = 0xFF, K0 = 0
        await tqv.write_byte_reg(REG_COMPARE, 7)
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(2) | CFG3_SMP_RISE |       # SCL on ui_in[2]
                                 CFG3_SMP_SHIFT | CFG3_SMP_CNT2 | CFG3_SMP_INV)
        await self.clocks(20)

        async def fifo_a():
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF):
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
# PIO-style multi-bit shift unit test
# =============================================================================
class PioTest(PrismTest):
    ''' CFG0[2]: comm shifts {OUT_K_SEL1, OUT_K_SEL0} + 1 bits per shift from
        pins shift_in_sel.. and COMM_PINS routes any comm bit to a uo_out pin
        with pinmux code 6.  The pio chroma, armed on a rising (host_in[0] =
        0) or falling edge of ui_in[0]: as a 4-channel logic analyser
        (sampler-clocked, two samples per byte into FIFO A until it is full,
        MSB and LSB first) and as a 2-lane waveform generator (FIFO B bytes
        as four bit pairs per count1 period on uo_out[2:1] until empty). '''
    name = "pio Chroma (multi-bit comm shift, edge trigger)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        LA, WG, RISE, FALL = 0, 2, 0, 1
        for k in range(5):
            dut.ui_in[k].value = 0
        await tqv.write_byte_reg(REG_HOST, LA | RISE)
        await bench.load_chroma(chroma_pio, chroma_pio_ctrlReg, chroma_pio_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: the waveform bytes
        await tqv.write_word_reg(REG_FIFO_ST, 0)                              # both FIFOs empty to start
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(4) | CFG3_SMP_RISE | CFG3_SMP_SHIFT | CFG3_SMP_CNT2)
        await tqv.write_byte_reg(REG_COMPARE, 2)
        await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS((1, 7), (2, 6)))
        assert await tqv.read_word_reg(REG_COMM_PINS) == COMM_PINS((1, 7), (2, 6))

        async def sample(nibbles):
            ''' One sample-clock pulse on ui_in[4] per nibble on ui_in[3:0] '''
            for n in nibbles:
                for k in range(4):
                    dut.ui_in[k].value = (n >> k) & 1
                await self.clocks(3)
                dut.ui_in[4].value = 1
                await self.clocks(3)
                dut.ui_in[4].value = 0
                await self.clocks(2)
            await self.clocks(12)

        async def trigger(level):
            dut.ui_in[0].value = level
            await self.clocks(8)

        async def fifo_a():
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF):
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        self.log(f"logic analyser: nothing before the rising trigger, then {2 * FIFO_DEPTH_A} samples fill FIFO A")
        await self.clocks(10)
        await sample([0x2, 0x4, 0x6])                                         # channel 0 low: no trigger
        assert await bench.curr_state() == 0 and await fifo_a() == []
        await trigger(1)                                                      # rising edge on ui_in[0]
        assert await bench.curr_state() == 2                                  # LA_WAIT
        nibbles = [(i * 7 + 3) & 0xF for i in range(2 * FIFO_DEPTH_A)]
        await sample(nibbles)
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert await bench.irq() and await bench.curr_state() == 0, (await bench.curr_state(), hex(st), await bench.irq())   # full: interrupt, re-armed
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert await fifo_a() == [(nibbles[2 * i] << 4) | nibbles[2 * i + 1] for i in range(FIFO_DEPTH_A)]

        self.log("logic analyser, LSB first, falling trigger")
        await tqv.write_word_reg(REG_CFG0, chroma_pio_ctrlReg | CFG_SHIFT_DIR_LSB)
        await tqv.write_byte_reg(REG_HOST, LA | FALL)
        await trigger(1)
        await sample([0x3, 0xD])                                              # channel 0 high: no trigger
        assert await bench.curr_state() == 0
        await trigger(0)                                                      # falling edge
        assert await bench.curr_state() == 2
        await sample([0x3, 0xC, 0x7, 0x8])
        assert await fifo_a() == [0xC3, 0x87]
        await bench.disable()                                                 # re-arm (not full)
        await tqv.write_word_reg(REG_CFG0, chroma_pio_ctrlReg)
        await bench.enable()

        self.log("waveform generator: falling trigger plays 4 bytes as 16 bit pairs, then interrupts")
        PERIOD = 8
        await tqv.write_word_reg(REG_PRELOAD, PERIOD - 1)
        await tqv.write_byte_reg(REG_HOST, WG | FALL)
        data = [0x1B, 0x6C, 0xE4, 0x93]                                       # consecutive pairs all differ
        pairs = [(b >> (6 - 2 * i)) & 3 for b in data for i in range(4)]
        runs = []                                                             # (lane value, clocks)
        async def watch():
            while True:
                await FallingEdge(dut.clk)
                uo = int(dut.uo_out.value)
                v = ((uo >> 1) & 1) << 1 | ((uo >> 2) & 1)                    # lane 1 = bit 7, lane 0 = bit 6
                if runs and runs[-1][0] == v:
                    runs[-1][1] += 1
                else:
                    runs.append([v, 1])
        await trigger(1)
        w = cocotb.start_soon(watch())
        for b in data:
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await self.clocks(40)
        assert len(runs) == 1 and await bench.curr_state() == 0               # nothing plays before the trigger
        await trigger(0)                                                      # falling edge
        await self.clocks(16 * (PERIOD + 2) + 60)
        w.kill()
        seq = [r[0] for r in runs]
        i = seq.index(pairs[0])
        assert seq[i:i + 16] == pairs, (runs[:24], pairs)
        assert all(PERIOD - 1 <= r[1] <= PERIOD + 3 for r in runs[i + 1:i + 15]), runs[i:i + 16]
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 1 == 1
        assert await bench.irq() and await bench.curr_state() == 0            # played out: interrupt, re-armed
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("waveform generator, rising trigger")
        await tqv.write_byte_reg(REG_HOST, WG | RISE)
        runs.clear()
        w = cocotb.start_soon(watch())
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x6C)
        await trigger(1)                                                      # rising edge
        await self.clocks(4 * (PERIOD + 2) + 40)
        w.kill()
        seq = [r[0] for r in runs]
        i = seq.index(1)
        assert seq[i:i + 4] == [1, 2, 3, 0], runs[:8]
        assert await bench.irq() and await bench.curr_state() == 0
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        await bench.disable()
        for reg, v in ((REG_CFG3, 0), (REG_COMM_PINS, 0), (REG_CFG0 + SHARD1, 0), (REG_FIFO_ST, 0), (REG_FIFO_ST + SHARD1, 0)):
            await tqv.write_word_reg(reg, v)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_HOST, 0)
        for k in range(5):
            dut.ui_in[k].value = 0


# =============================================================================
# SPI master (single / quad) Chroma unit test
# =============================================================================
class SpiMasterTest(PrismTest):
    ''' Mode-0 SPI controller on the multi-bit shift: single lane (full
        duplex, 8 SCLKs per byte) and quad (half duplex, 2 SCLKs per byte),
        host_in[1] choosing the width per byte, FIFO B sent, FIFO A
        received, COMPARE bytes read after the send with the K0 / K3 dummy,
        host_in[0] framing CS.  A QspiSlave model resolves the lanes behind
        the external buffers. '''
    name = "spi_master Chroma (single / quad lanes)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        FRAME, QUAD = 1, 2
        await tqv.write_byte_reg(REG_HOST, 0x00)
        slave = self.start(QspiSlave(dut))
        await bench.load_chroma(chroma_spi_master, chroma_spi_master_ctrlReg, chroma_spi_master_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: the bytes to send
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_CONST, 0xA5000000 | 0xFF)                # K3 = quad dummy, K0 = 0xFF
        HALF = 4
        await tqv.write_word_reg(REG_PRELOAD, HALF - 1)

        async def single_mode():
            await tqv.write_word_reg(REG_CFG0, (chroma_spi_master_ctrlReg & ~3) | 2)   # MISO = IO1 on ui_in[2]
            await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS((4, 7)))                  # IO0 = comm[7]
            slave.quad = False

        async def quad_mode():
            await tqv.write_word_reg(REG_CFG0, (chroma_spi_master_ctrlReg & ~3) | 1)   # IO0..3 on ui_in[4:1]
            await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS((4, 4), (5, 5), (6, 6), (7, 7)))
            slave.quad = True

        async def fifo_a():
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF):
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        async def frame(tx, nread, width, clocks):
            ''' One CS frame: push `tx`, ask for `nread` more bytes, run, end; the bytes received '''
            slave.rx.clear(); slave.events.clear()
            for b in tx:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
            await tqv.write_byte_reg(REG_COMPARE, nread)
            await tqv.write_byte_reg(REG_HOST, FRAME | width)
            await self.clocks(clocks)
            assert await bench.curr_state() == 4, await bench.curr_state()    # NEXT2: waiting for the host
            await tqv.write_byte_reg(REG_HOST, width)                         # end the frame
            await self.clocks(HALF * 2 + 20)
            assert await bench.irq() and await bench.curr_state() == 0
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            assert slave.events == ['cs_low', 'cs_high'], slave.events
            return await fifo_a()

        self.log("single lane, full duplex: 4 bytes out, 4 back")
        await single_mode()
        slave.tx = [0xEF, 0x40, 0x18, 0xC2]
        got = await frame([0x9F, 0x00, 0x00, 0x00], 0, 0, 4 * 8 * 2 * HALF + 200)
        assert slave.rx == [0x9F, 0x00, 0x00, 0x00], [hex(v) for v in slave.rx]
        assert got == [0xEF, 0x40, 0x18, 0xC2], [hex(v) for v in got]
        assert slave.sclks == 32, slave.sclks

        self.log("single lane: a command byte, then 3 bytes read with the 0xFF dummy")
        slave.tx = [0x00, 0x11, 0x22, 0x33]
        got = await frame([0x05], 3, 0, 4 * 8 * 2 * HALF + 200)
        assert slave.rx == [0x05, 0xFF, 0xFF, 0xFF], [hex(v) for v in slave.rx]
        assert got == [0x00, 0x11, 0x22, 0x33], [hex(v) for v in got]
        assert await tqv.read_byte_reg(REG_COUNT2) == 3

        self.log("quad: 2 bytes out on four lanes (nothing kept), 3 bytes read")
        await quad_mode()
        slave.tx = [0x5A, 0xC3, 0x0F]
        got = await frame([0xA5, 0x3C], 3, QUAD, 5 * 2 * 2 * HALF + 200)
        assert slave.rx == [0xA5, 0x3C], [hex(v) for v in slave.rx]
        assert got == [0x5A, 0xC3, 0x0F], [hex(v) for v in got]
        assert slave.sclks == 10, slave.sclks                                  # 2 SCLKs per byte

        self.log("mixed frame: single-lane command, then quad data")
        await single_mode()
        slave.rx.clear(); slave.events.clear()
        slave.tx = [0xFF] * 8
        for b in (0x6B,):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_HOST, FRAME)                              # single width
        await self.clocks(8 * 2 * HALF + 60)
        assert await bench.curr_state() == 4 and slave.rx == [0x6B]
        await quad_mode()                                                      # switch width mid-frame ...
        await tqv.write_byte_reg(REG_HOST, FRAME | QUAD)                       # ... before pushing: a byte
        slave.tx = [0x12, 0x34]                                                # goes out as soon as it lands
        slave.prime()
        for b in (0x00, 0x10):                                                 # a 2-byte "address"
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await tqv.write_byte_reg(REG_COMPARE, 2)                               # the read count after the pushes:
                                                                               # with FIFO B empty it would read at once
        await self.clocks(4 * 2 * 2 * HALF + 100)
        assert await bench.curr_state() == 4
        await tqv.write_byte_reg(REG_HOST, QUAD)
        await self.clocks(HALF * 2 + 20)
        assert await bench.irq() and await bench.curr_state() == 0
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert slave.rx == [0x6B, 0x00, 0x10], [hex(v) for v in slave.rx]
        assert await fifo_a() == [0xFF, 0x12, 0x34]                            # the command's full-duplex byte, then the read
        assert slave.events == ['cs_low', 'cs_high']

        await bench.disable()
        for reg, v in ((REG_COMM_PINS, 0), (REG_CONST, 0), (REG_CFG0 + SHARD1, 0), (REG_FIFO_ST, 0), (REG_FIFO_ST + SHARD1, 0)):
            await tqv.write_word_reg(reg, v)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_HOST, 0)
        for k in range(1, 5):
            dut.ui_in[k].value = 0


# =============================================================================
# 1-Wire master Chroma unit test
# =============================================================================
class OneWireTest(PrismTest):
    ''' 1-Wire controller: reset and presence (timer 2 restarted on entry
        into RESET_LOW, presence latched into FLAGS[7]), bytes written from
        FIFO B LSB first with 1 / 12-unit low slots, bytes read into FIFO A
        while host_in[1] is set (DQ sampled 2 units into the slot), a device
        that is absent.  A OneWireSlave model plays a DS18B20-like device. '''
    name = "onewire Chroma (1-Wire master)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        U = 8                                                                 # clocks per unit
        ROM = [0x28, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0xC7]
        await tqv.write_byte_reg(REG_HOST, 0x00)
        slave = self.start(OneWireSlave(dut, unit=U))
        slave.responses = {0x33: ROM}
        await bench.load_chroma(chroma_onewire, chroma_onewire_ctrlReg, chroma_onewire_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: bytes to write
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_PRELOAD, U - 1)                          # count1 unit
        await tqv.write_byte_reg(REG_COMPARE, 12)                             # 12 units = a slot
        await tqv.write_word_reg(REG_PRELOAD2, (96 * U - 1) | T2_RELOAD | T2_STATE(1))   # 96-unit reset, restarted in RESET_LOW
        await tqv.write_word_reg(REG_CONST, 0)                                # K0 = 0
        SLOT = 14 * U

        async def fifo_a():
            got = []
            for _ in range((await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF):
                got.append(await tqv.read_byte_reg(REG_FIFO))
            return got

        self.log("reset and presence")
        await tqv.write_byte_reg(REG_HOST, 0x01)                              # session
        await self.clocks(2 * 96 * U + 100)
        assert await bench.irq() and await bench.curr_state() in (4, 5)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert (await tqv.read_word_reg(REG_FLAGS)) & (1 << 7), hex(await tqv.read_word_reg(REG_FLAGS))   # presence
        assert slave.resets == 1

        self.log("write 4 bytes")
        data = [0xCC, 0x4E, 0x12, 0x34]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        await self.clocks(4 * 8 * SLOT + 200)
        assert slave.rx == data, [hex(v) for v in slave.rx]
        assert await bench.curr_state() in (4, 5)

        self.log("READ ROM: a command byte, then 8 bytes read while host_in[1] is set")
        slave.rx.clear()
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x33)
        await tqv.write_byte_reg(REG_HOST, 0x03)                              # read after the write
        for _ in range(200):
            if (await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF >= 8:
                break
            await self.clocks(SLOT)
        await tqv.write_byte_reg(REG_HOST, 0x01)                              # stop reading
        await self.clocks(9 * SLOT)
        got = await fifo_a()
        assert got[:8] == ROM and slave.rx[0] == 0x33, ([hex(v) for v in got], slave.rx)
        assert all(v == 0xFF for v in got[8:] + slave.rx[1:])                 # slots after the ROM: 1s both ways

        self.log("end of session, then a session with no device")
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await self.clocks(20)
        assert await bench.curr_state() == 0
        slave.present = False
        await tqv.write_byte_reg(REG_HOST, 0x01)
        await self.clocks(2 * 96 * U + 100)
        assert await bench.irq() and slave.resets == 2
        assert not (await tqv.read_word_reg(REG_FLAGS)) & (1 << 7)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        await tqv.write_byte_reg(REG_HOST, 0x00)

        await bench.disable()
        for reg, v in ((REG_PRELOAD2, 0), (REG_CFG0 + SHARD1, 0), (REG_FIFO_ST, 0), (REG_FIFO_ST + SHARD1, 0), (REG_PRELOAD, 0)):
            await tqv.write_word_reg(reg, v)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        dut.ui_in[0].value = 0


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
        assert (st >> 8) & 0x3FFF == len(data), f"{st:#x}"                      # ... into A
        for b in data:
            assert await tqv.read_byte_reg(REG_FIFO) == b
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data)

        # More than A can hold: the FSM stops on fifo_a_full and resumes as the
        # host drains A; the bytes arrive in order
        self.log("FIFO A full back-pressure")
        for b in range(FIFO_DEPTH_A + 4):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, (0xC0 + b) & 0xFF)
        await self.clocks(200)
        assert fifo_count(await tqv.read_word_reg(REG_FIFO_ST)) == FIFO_DEPTH_A
        assert fifo_count(await tqv.read_word_reg(REG_FIFO_ST + SHARD1)) == 4
        for b in range(FIFO_DEPTH_A + 4):
            await self.clocks(20)
            assert await tqv.read_byte_reg(REG_FIFO) == (0xC0 + b) & 0xFF
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == (len(data) + FIFO_DEPTH_A + 4) & 0xFF
        await bench.disable()


# =============================================================================
# PRISM Edge Detect circuit unit test
# =============================================================================
class Fifo32Test(PrismTest):
    ''' 32-bit FIFO access (CFG3[11], FIFO32 at +0x54) on the fifo_loop chroma:
        shard 0 owns both FIFOs, B (shard 1's window) is TX and A is RX, and
        the chroma moves every byte from B to A.  A word written to B's
        FIFO32 is pushed a byte at a time, low byte first; A's pop machine
        assembles four bytes into its word register, flags it (FIFO_STATUS[4]
        and the shard 0 interrupt) and a read of A's FIFO32 takes it.  Byte
        reads of A's FIFO while the word register holds bytes come from its
        low byte and the machine refills behind them, so mixing never
        reorders; short messages leave their stragglers in the FIFO where
        byte reads find them.  The push machine stalls on a full FIFO
        (FIFO_STATUS[5] busy) and resumes as the host drains.  Repeated with
        A as the SRAM FIFO where the tile has one. '''
    name = "32-bit FIFO access (FIFO32 word push / pop)"

    async def run(self):
        tqv, bench = self.tqv, self.bench
        WORD_FULL, BUSY = FIFO_ST_WORD_FULL, FIFO_ST_PUSH_BUSY

        async def st(base=0):
            return await tqv.read_word_reg(REG_FIFO_ST + base)

        async def count(base=0):
            return ((await st(base)) >> 8) & 0x3FFF

        async def wait_word(tries=60):
            for _ in range(tries):
                if (await st()) & WORD_FULL:
                    return
                await self.clocks(10)
            raise AssertionError("no complete word in A's word register")

        async def wait_idle(tries=60):
            for _ in range(tries):
                if not (await st(SHARD1)) & BUSY:
                    return True
                await self.clocks(10)
            return False

        async def push_word(w):
            assert await wait_idle(), "push machine stuck busy"
            await tqv.write_word_reg(REG_FIFO32 + SHARD1, w)

        async def settle(base=0):
            s0 = await st(base)
            assert not (s0 & WORD_FULL) and FIFO_ST_WORD_BYTES(s0) == 0 and s0 & 0x1, f"{s0:#x}"

        await bench.load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # B: host pushes
        await tqv.write_word_reg(REG_CFG3, CFG3_FIFO32)                        # A: word pops
        await tqv.write_word_reg(REG_CFG3 + SHARD1, CFG3_FIFO32)               # B: word pushes
        await settle(); await settle(SHARD1)
        assert not await bench.irq()

        self.log("one word through: pushed low byte first, assembled low byte first")
        await push_word(0x44332211)
        await wait_word()
        s0 = await st()
        assert (s0 >> 8) & 0x3FFF == 0 and s0 & 0x1, f"{s0:#x}"              # A itself drained into the word register
        assert await bench.irq(), "no interrupt for the complete word"
        assert await tqv.read_word_reg(REG_FIFO32) == 0x44332211
        await settle()
        assert not await bench.irq(), "interrupt should clear with the word read"
        assert await tqv.read_byte_reg(REG_COUNT2) == 4                        # the chroma moved 4 bytes

        self.log("a run of words keeps its order")
        words = [0x01020304, 0xDEADBEEF, 0x00000000, 0xFFFFFFFF, 0x80000001, 0x7F00FF01]
        for w in words:
            await push_word(w)
        for w in words:
            await wait_word()
            got = await tqv.read_word_reg(REG_FIFO32)
            assert got == w, f"{got:#x} expected {w:#x}"
        await settle(); await settle(SHARD1)

        self.log("stragglers: the machine waits for four, byte reads take the rest")
        await push_word(0xA4A3A2A1)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0xB1)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0xB2)
        await wait_word()
        assert await tqv.read_word_reg(REG_FIFO32) == 0xA4A3A2A1
        await self.clocks(60)
        s0 = await st()
        assert FIFO_ST_WORD_BYTES(s0) == 0 and (s0 >> 8) & 0x3FFF == 2, f"{s0:#x}"
        assert not await bench.irq()
        assert await tqv.read_byte_reg(REG_FIFO) == 0xB1
        assert await tqv.read_byte_reg(REG_FIFO) == 0xB2
        await settle()

        self.log("a byte read of a complete word: low byte out, the FIFO's next byte refills the top")
        await push_word(0x14131211)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x15)
        await wait_word()
        await self.clocks(40)
        assert await count() == 1                                              # 0x15 waits in A
        assert await tqv.read_byte_reg(REG_FIFO) == 0x11
        await wait_word()                                                      # topped up with 0x15
        assert await count() == 0
        assert await tqv.read_word_reg(REG_FIFO32) == 0x15141312
        await settle()

        self.log("byte reads with nothing behind them leave a partial word; later bytes complete it")
        await push_word(0x24232221)
        await wait_word()
        assert await tqv.read_byte_reg(REG_FIFO) == 0x21
        await self.clocks(30)
        s0 = await st()
        assert FIFO_ST_WORD_BYTES(s0) == 3 and not (s0 & WORD_FULL), f"{s0:#x}"
        assert not await bench.irq()
        assert await tqv.read_byte_reg(REG_FIFO) == 0x22
        s0 = await st()
        assert FIFO_ST_WORD_BYTES(s0) == 2, f"{s0:#x}"
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x25)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x26)
        await wait_word()
        assert await bench.irq()
        assert await tqv.read_word_reg(REG_FIFO32) == 0x26252423
        await settle()

        self.log("back-pressure: words until the push machine stalls, then drained in order")
        sent = []
        for i in range(40):
            if not await wait_idle(tries=8):
                break                                                          # stalled on a full B: stop writing
            w = ((i + 1) * 0x11111111) & 0xFFFFFFFF
            await tqv.write_word_reg(REG_FIFO32 + SHARD1, w)
            sent.append(w)
        await self.clocks(100)
        sA, sB = await st(), await st(SHARD1)
        assert sA & WORD_FULL and sA & 0x2, f"A {sA:#x}"                     # word register and A full
        assert sB & 0x2 and sB & BUSY, f"B {sB:#x}"                            # B full, a word stuck in the machine
        assert len(sent) >= 4, len(sent)
        for w in sent:
            await wait_word()
            got = await tqv.read_word_reg(REG_FIFO32)
            assert got == w, f"{got:#x} expected {w:#x}"
        await self.clocks(60)
        await settle(); await settle(SHARD1)
        assert not (await st(SHARD1)) & BUSY

        self.log("mode off: the word register still drains first, then the FIFO")
        await push_word(0x34333231)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x35)
        await wait_word()
        await tqv.write_word_reg(REG_CFG3, 0)                                  # A: byte mode again
        await self.clocks(20)
        assert not await bench.irq()                                           # no word interrupt without the mode
        for b in (0x31, 0x32, 0x33, 0x34, 0x35):
            assert await tqv.read_byte_reg(REG_FIFO) == b
        await settle()
        await tqv.write_word_reg(REG_CFG3, CFG3_FIFO32)

        if os.environ.get("PRISM_SRAM_FIFO", "2") != "0":
            self.log("A as the SRAM FIFO: the machine rides out the SRAM's refetch gaps")
            await tqv.write_word_reg(REG_CFG0, chroma_fifo_loop_ctrlReg | CFG_FIFO_SRAM)
            await tqv.write_word_reg(REG_FIFO_ST, 0)                           # flush
            await settle()
            words = [0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00, 0x0F1E2D3C]
            for w in words:
                await push_word(w)
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0xE1)
            for w in words:
                await wait_word()
                got = await tqv.read_word_reg(REG_FIFO32)
                assert got == w, f"{got:#x} expected {w:#x}"
            await self.clocks(60)
            assert await count() == 1
            assert await tqv.read_byte_reg(REG_FIFO) == 0xE1
            await settle()
            await tqv.write_word_reg(REG_CFG0, chroma_fifo_loop_ctrlReg)

        await tqv.write_word_reg(REG_CFG3, 0)
        await tqv.write_word_reg(REG_CFG3 + SHARD1, 0)
        await bench.disable()


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
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x3FFF03 == 0x000001
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x3FFF03 == 0x000001
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


class CounterTest(PrismTest):
    ''' CRC register counter mode (CFG3[10]): the 32-bit CRC register is an
        up / down counter on the CRC strobes, OUT_CRC_CLEAR presets it,
        OUT_CRC_UPDATE counts up, OUT_LOAD_CRC counts down, and crc_ok
        (input 22, FLAGS[10]) is the unsigned count >= CRC_EXPECTED.  The
        counter chroma steps once per ui_in[2] transition (down while
        host_in[1] is set), presets on a host_in[0] toggle, counts the steps
        that end at or above the compare value in count2 and shows the
        compare on uo_out[1].  Everything is checked against a model of the
        count; with the mode off the same strobes run the CRC as before. '''
    name = "up / down counter with compare (CRC register counter mode)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[2].value = 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG1, (2 << 0) | (8 << 4))     # in_prev0 <- ui_in[2], in_prev1 <- host_in[0]
        await tqv.write_word_reg(REG_CFG3, CFG3_CNT_EN)
        await bench.load_chroma(chroma_counter, chroma_counter_ctrlReg, chroma_counter_pinmuxReg)
        await self.clocks(20)

        m = {"v": 0, "hits": 0, "cmp": 0, "host0": 0, "down": False}

        async def compare(c):
            m["cmp"] = c
            await tqv.write_word_reg(REG_CRC_EXP, c)

        async def direction(down):
            m["down"] = down
            await tqv.write_byte_reg(REG_HOST, (0x02 if down else 0x00) | m["host0"])

        async def steps(n, gap=12):
            for _ in range(n):
                dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)
                m["v"] = (m["v"] + (-1 if m["down"] else 1)) & 0xFFFFFFFF
                if m["v"] >= m["cmp"]:
                    m["hits"] += 1
                await self.clocks(gap)

        async def host_preset(v):                       # host_in[0] toggle -> ZERO state
            await tqv.write_byte_reg(REG_TOGGLE, 0x00)
            m["host0"] ^= 1
            m["v"] = v
            await self.clocks(12)

        async def preset(v):                            # host write of the count
            await tqv.write_word_reg(REG_CRC, v)
            m["v"] = v

        async def check(what):
            v = await tqv.read_word_reg(REG_CRC)
            assert v == m["v"], f"{what}: count {v:#x} expected {m['v']:#x}"
            hits = await tqv.read_byte_reg(REG_COUNT2)
            assert hits == m["hits"] & 0xFF, f"{what}: {hits} hits expected {m['hits']}"
            ge = m["v"] >= m["cmp"]
            flags = await tqv.read_word_reg(REG_FLAGS)
            assert bool(flags & FLAG_CRC_OK) == ge, f"{what}: FLAGS {flags:#x}, count >= compare should be {ge}"
            pin = (int(dut.uo_out.value) >> 1) & 1
            assert pin == ge, f"{what}: uo_out[1] {pin}, count >= compare should be {ge}"

        self.log("count up through the compare value, then down through it")
        await compare(5)
        await check("start")
        await steps(3)
        await check("3 up")
        await steps(4)                                   # 5, 6, 7 are at or above 5
        await check("7 up")
        await direction(True)
        await steps(4)                                   # 6, 5 are, 4, 3 are not
        await check("4 down")

        self.log("OUT_CRC_CLEAR presets 0, the host presets anything; 32-bit wrap both ways")
        await host_preset(0)
        await check("cleared")
        await direction(False)
        await preset(0xFFFF_FFFE)
        await check("host preset")
        await steps(3)                                   # FFFFFFFF, 0, 1
        await check("wrapped up")
        await preset(1)
        await direction(True)
        await steps(2)                                   # 0, FFFFFFFF
        await check("wrapped down")

        self.log("the compare is unsigned")
        await compare(0x8000_0000)
        await direction(False)
        await preset(0x7FFF_FFFF)
        await check("below")
        await steps(1)
        await check("at")
        await direction(True)
        await steps(1)
        await check("below again")
        await compare(0)                                 # always at or above
        await check("compare 0")
        await compare(0xFFFF_FFFF)
        await preset(0xFFFF_FFFF)
        await check("all ones")

        self.log("crc_init_ones presets all ones; a count down leaves the shifter alone")
        await tqv.write_word_reg(REG_CFG0, chroma_counter_ctrlReg | (1 << 25))
        await host_preset(0xFFFF_FFFF)
        await check("preset ones")
        await tqv.write_word_reg(REG_CFG0, chroma_counter_ctrlReg)
        await tqv.write_byte_reg(REG_COMM, 0xA5)
        await steps(1)
        await check("down 1")
        assert await tqv.read_byte_reg(REG_COMM) == 0xA5
        await host_preset(0)
        await check("preset zero")

        self.log("mode off: the strobes run the CRC register as before (mode 0: shift on OUT_LOAD_CRC only)")
        await tqv.write_word_reg(REG_CFG3, 0)
        await direction(False)
        await tqv.write_word_reg(REG_CRC, 0x1234_5678)
        await steps(2)                                   # OUT_CRC_UPDATE: nothing with crc_mode 0
        assert await tqv.read_word_reg(REG_CRC) == 0x1234_5678
        await direction(True)
        await steps(1)                                   # OUT_LOAD_CRC: comm <= low byte, register advances
        assert await tqv.read_word_reg(REG_CRC) == 0x3456_7800
        assert await tqv.read_byte_reg(REG_COMM) == 0x78
        assert not (await tqv.read_word_reg(REG_FLAGS) & FLAG_CRC_OK)
        assert ((int(dut.uo_out.value) >> 1) & 1) == 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG1, 0)
        dut.ui_in[2].value = 0
        await bench.disable()


class Count3Test(PrismTest):
    ''' count2's two-bit commands (OUT_COUNT2_INC alone + 1, OUT_COUNT2_DEC
        alone - 1, both clear) and the per-shard count3: it counts up only,
        its command is {pin_out[3] with CFG0[12], OUT_COUNT3} = 01 + 1,
        10 clear, 11 limit <= comm, and count3 >= limit is input 29 (slot
        default) and FLAGS[12].  The count3 chroma pops command bytes from
        its FIFO and decodes their low three bits (5 = the whole byte is the
        limit); uo_out[1] shows input 29.  Also: the COUNT3 register (byte
        lanes; a disable clears the count and keeps the limit), CFG0[12]
        off (pin_out[3] a plain pin, output 11 alone counts up), a sampler
        count2 + 1 cancelling an FSM decrement in the same clock, and
        shard 1's own count3. '''
    name = "count2 command encoding and count3 (an up counter with a limit from the data)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[3].value = 0
        await tqv.write_word_reg(REG_FIFO_ST, 0)                 # flush
        await tqv.write_word_reg(REG_CFG2, 0x765)                # inputs 16-18 = comm[0..2]; 29 stays count3 >= limit
        await tqv.write_word_reg(REG_PRELOAD, 200)               # op 6: 201 clocks of count2 - 1
        await bench.load_chroma(chroma_count3, chroma_count3_ctrlReg, chroma_count3_pinmuxReg)
        await self.clocks(20)

        m = {"c2": 0, "c3": 0, "lim": 0, "mode": True}

        async def ops(*cmds):
            for c in cmds:
                await tqv.write_byte_reg(REG_FIFO, c)
                op = c & 7
                if op == 0:
                    m["c2"] = (m["c2"] + 1) & 0xFF
                elif op == 1:
                    m["c2"] = (m["c2"] - 1) & 0xFF
                elif op == 2:
                    m["c2"] = 0
                elif op == 3 or (op == 5 and not m["mode"]):     # output 11 alone
                    m["c3"] = (m["c3"] + 1) & 0xFF
                elif op == 4 and m["mode"]:
                    m["c3"] = 0
                elif op == 5:
                    m["lim"] = c
                    m["c3"] = 0                                      # a limit load starts a new count
            for _ in range(50):
                if await tqv.read_word_reg(REG_FIFO_ST) & 1:     # empty: the last one is being decoded
                    break
            await self.clocks(10)

        async def check(what):
            c2 = await tqv.read_byte_reg(REG_COUNT2)
            assert c2 == m["c2"], f"{what}: count2 {c2} expected {m['c2']}"
            w = await tqv.read_word_reg(REG_COUNT3) & 0xFFFF       # (byte 2 is the mask)
            exp = (m["lim"] << 8) | m["c3"]
            assert w == exp, f"{what}: COUNT3 {w:#06x} expected {exp:#06x}"
            ge = m["c3"] >= m["lim"]
            flags = await tqv.read_word_reg(REG_FLAGS)
            assert bool(flags & FLAG_COUNT3) == ge, f"{what}: FLAGS {flags:#x}, count3 >= limit should be {ge}"
            pin = (int(dut.uo_out.value) >> 1) & 1
            assert pin == ge, f"{what}: uo_out[1] {pin} (input 29), count3 >= limit should be {ge}"

        self.log("count2: inc alone + 1, dec alone - 1, both clear; 8-bit wrap both ways")
        await check("start")
        await ops(0, 0, 0)
        await check("+3")
        await ops(1)
        await check("-1")
        await ops(2)
        await check("clear")
        await ops(1)
        await check("wrap down")
        await ops(0)
        await check("wrap up")

        self.log("count3 counts up; the limit comes from the command byte (comm)")
        await ops(3, 3, 3, 3, 3)
        await check("count3 5, limit 0")
        await ops(0x3D)                                          # op 5: limit = 0x3D
        await check("limit 0x3D")
        await ops(4)
        await check("count3 cleared")
        await ops(0x05)                                          # a length of 5 from the data
        for k in range(1, 6):
            await ops(3)
            await check(f"step {k} of 5")                        # the flag rises on exactly the fifth

        self.log("COUNT3 register: word and byte writes; a disable clears the count, not the limit")
        await tqv.write_word_reg(REG_COUNT3, 0x2010)
        m["c3"], m["lim"] = 0x10, 0x20
        await check("word write")
        await tqv.write_byte_reg(REG_COUNT3, 0x33)
        await tqv.write_byte_reg(REG_LIMIT3, 0x30)
        m["c3"], m["lim"] = 0x33, 0x30
        await check("byte writes")
        assert await tqv.read_byte_reg(REG_LIMIT3) == 0x30
        await tqv.write_byte_reg(REG_LIMIT3, 0)
        m["lim"] = 0
        await check("limit 0: always at or above")
        await tqv.write_byte_reg(REG_LIMIT3, 0x30)
        m["lim"] = 0x30
        await bench.disable()
        assert await tqv.read_word_reg(REG_COUNT3) == 0x3000, "a disable clears count3 and keeps the limit"
        await bench.enable()
        await self.clocks(10)
        m["c2"], m["c3"] = 0, 0                                  # (count2 is cleared by the disable too)
        await check("after the disable")

        self.log("CFG0[12] off: pin_out[3] is a plain pin, output 11 alone counts up")
        m["mode"] = False
        await tqv.write_word_reg(REG_CFG0, chroma_count3_ctrlReg & ~CFG_COUNT3_EN)
        await ops(3, 3)
        await check("+2 without the mode")
        watch = {"on": True, "pulses": 0}

        async def watcher():
            prev = 0
            while watch["on"]:
                await RisingEdge(dut.clk)
                v = (int(dut.uo_out.value) >> 2) & 1
                if v and not prev:
                    watch["pulses"] += 1
                prev = v
        cocotb.start_soon(watcher())
        await ops(4)                                             # pin_out[3] alone: a pin pulse, no clear
        watch["on"] = False
        await self.clocks(2)
        assert watch["pulses"] == 1, f"pin_out[3] reached uo_out[2] {watch['pulses']} times, expected once"
        await check("pin_out[3] alone does not clear")
        await ops(0x45)                                          # both: just + 1, the limit stays
        await check("both bits without the mode = + 1")
        m["mode"] = True
        await tqv.write_word_reg(REG_CFG0, chroma_count3_ctrlReg)

        self.log("a sampler count2 + 1 in the clock of an FSM decrement cancels it")
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(3) | CFG3_SMP_ANY | CFG3_SMP_CNT2)
        await tqv.write_byte_reg(REG_COUNT2, 250)
        m["c2"] = 250
        for _ in range(2):                                       # idle: each edge is + 1
            dut.ui_in[3].value = 1 - int(dut.ui_in[3].value)
            await self.clocks(20)
            m["c2"] += 1
        await check("two sampler steps")
        await tqv.write_byte_reg(REG_FIFO, 6)                    # 201 clocks of - 1
        await self.clocks(30)
        for _ in range(4):                                       # four edges inside the window
            dut.ui_in[3].value = 1 - int(dut.ui_in[3].value)
            await self.clocks(25)
        await self.clocks(250)
        m["c2"] = (m["c2"] - 201 + 4) & 0xFF                     # each edge clock nets 0 (old priority: + 1)
        await check("decrement window with four edges")
        await tqv.write_word_reg(REG_CFG3, 0)

        self.log("the mask: only a masked load (OUT_K_SEL0 with the command) clears bits")
        await tqv.write_byte_reg(REG_MASK3, 0xF0)
        assert (await tqv.read_word_reg(REG_COUNT3) >> 16) & 0xFF == 0xF0
        await ops(0x45)                                          # op 5 without K_SEL0: the whole byte
        await check("plain limit load with the mask set")
        await tqv.write_byte_reg(REG_MASK3, 0)
        assert (await tqv.read_word_reg(REG_COUNT3) >> 16) & 0xFF == 0
        self.log("shard 1 has its own count3")
        await tqv.write_word_reg(REG_COUNT3 + SHARD1, 0x0807)
        assert await tqv.read_word_reg(REG_COUNT3 + SHARD1) == 0x0807
        assert not (await tqv.read_word_reg(REG_FLAGS + SHARD1) & FLAG_COUNT3)
        await tqv.write_byte_reg(REG_LIMIT3 + SHARD1, 0x07)
        assert await tqv.read_word_reg(REG_FLAGS + SHARD1) & FLAG_COUNT3
        await check("shard 0 unchanged")
        dut.ui_in[3].value = 0
        await bench.disable()


class CanRxTest(PrismTest):
    ''' CAN 2.0A receiver chroma: standard data frames from a bus model on
        ui_in[3] (64 clocks per bit), each pushed into the RX FIFO as
        {SOF, ID[10:4]}, {ID[3:0], RTR, IDE, r0, DLC3}, {ID0, RTR, IDE, r0,
        DLC} and the data bytes, acknowledged on uo_out[1] when the CRC-15 is
        good, with the host interrupt after the EOF and the CRC register at 0
        for a good frame.  Frames: a 3-byte one, all-zero ID with 8 zero
        bytes (stuff bits every 5 bits), ID 0x7FF with no data, a bad CRC
        (no ACK, CRC register not 0), 0xFF / 0x00 patterns and two frames
        back to back with the minimum interframe space. '''
    name = "CAN 2.0A receiver chroma"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        bus = can.CanBus(dut, rxd=3, txd=1, bit_clocks=64)
        await tqv.write_word_reg(REG_FIFO_ST, 0)                        # flush
        await tqv.write_word_reg(REG_CFG1, 3)                           # in_prev0 <- input 3 (RXD)
        await tqv.write_word_reg(REG_CFG2, (15 << 4) | (8 << 8))        # in17 = sampler pending, in18 = comm[3]
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(3) | CFG3_SMP_FALL | CFG3_SMP_TIMER |
                                           CFG3_SMP_PRESET(2) | CFG3_STUFF_EN)
        await tqv.write_word_reg(REG_CONST, (19 << 24) | (15 << 16))          # K3 = 19 header bits, K2 = 15 CRC bits
        ack_si = can.state_with_default_output(chroma_can_rx, 0)         # the ACK state drives pin_out[0]
        await tqv.write_word_reg(REG_PRELOAD2, 78 | (1 << 24) | (ack_si << 25) | (1 << 30))   # 1.25 bits, restart on entry, one-shot
        await tqv.write_word_reg(REG_COUNT3, 0xF0 << 16)                # limit loads keep comm[3:0] (the DLC)
        await tqv.write_byte_reg(REG_COMPARE, 4)                        # a run of five = stuff bit next
        await tqv.write_word_reg(REG_PRELOAD, 63)                       # one bit: the tick wraps at 63
        await tqv.write_word_reg(REG_CRC_POLY, 0x8B32)                  # CRC-15 0x4599 in 16-bit mode
        await tqv.write_word_reg(REG_CRC_EXP, 0)
        await bench.load_chroma(chroma_can_rx, chroma_can_rx_ctrlReg, chroma_can_rx_pinmuxReg)
        await self.clocks(200)

        async def receive(ident, data, rtr=False, bad_crc=False, ifs=3, expect_ack=True, dlc=None):
            acked = await bus.send(ident, data, rtr=rtr, bad_crc=bad_crc, ifs=ifs, dlc=dlc)
            assert acked == expect_ack, f"ID {ident:#x}: ACK {acked}, expected {expect_ack}"
            for _ in range(20):
                if await bench.irq():
                    break
                await self.clocks(16)
            assert await bench.irq(), f"ID {ident:#x}: no interrupt after the frame"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            _, body, _ = can.frame_bits(ident, data, rtr, bad_crc, dlc)
            exp = can.expected_bytes(body)
            st = await tqv.read_word_reg(REG_FIFO_ST)
            got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(st))]
            assert got == exp, f"ID {ident:#x}: FIFO {[hex(b) for b in got]} expected {[hex(b) for b in exp]}"
            crc = await tqv.read_word_reg(REG_CRC)
            assert (crc == 0) == (not bad_crc), f"ID {ident:#x}: CRC register {crc:#x}"

        self.log("a 3-byte frame")
        await receive(0x123, [0xDE, 0xAD, 0x42])
        self.log("ID 0 with eight zero bytes: a stuff bit every five bits")
        await receive(0x000, [0] * 8)
        self.log("ID 0x7FF, no data (the DLC = 0 path)")
        await receive(0x7FF, [])
        self.log("a bad CRC: no ACK, the CRC register is not 0")
        await receive(0x555, [1, 2, 3, 4], bad_crc=True, expect_ack=False)
        self.log("eight bytes of 0xFF / 0x00 patterns")
        await receive(0x2AA, [0xFF, 0x00, 0xFF, 0x00, 0xAA, 0x55, 0x0F, 0xF0])
        self.log("two frames back to back with the minimum interframe space")
        await receive(0x101, [0x11], ifs=3)
        await receive(0x102, [0x22, 0x33], ifs=3)
        await bench.disable()


class CanTxTest(PrismTest):
    ''' CAN 2.0A transmitter chroma: frames packed by the host into the TX
        FIFO (19 header bits then the data, MSB first) with LIMIT3 = the bit
        count, started by a host_in[0] toggle, go out on uo_out[2] (1 =
        recessive) with hardware stuffing and the CRC-15; the remote node
        (can_model.CanNode) decodes them and acknowledges, and FLAGS shows
        F0 = acked, F1 = lost.  Frames: 3 bytes, ID 0 with eight zero bytes
        (a stuff bit every five), no data, 0xFF / 0x00 patterns, one the node
        does not acknowledge, and one lost in arbitration (the node drives an
        ID bit dominant): F1, the bus released, the FIFO flushed by the host. '''
    name = "CAN 2.0A transmitter chroma"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        node = can.CanNode(dut, rxd=3, txd=2, ack_pin=1, bit_clocks=64)
        dut.ui_in[3].value = 1
        await tqv.write_word_reg(REG_FIFO_ST, 0)                        # flush
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_word_reg(REG_CFG1, 8 << 4)                      # in_prev1 <- host_in[0]
        await tqv.write_word_reg(REG_CFG3, CFG3_STUFF_EN | CFG3_STUFF_TX)
        await tqv.write_word_reg(REG_CONST, (11 << 24) | (14 << 16) | (0xFF << 8))   # K3 = 11 tail ticks, K2 = 14 (CRC bits - 1), K1 = recessive
        await tqv.write_byte_reg(REG_COMPARE, 4)
        await tqv.write_word_reg(REG_PRELOAD, 63)
        await tqv.write_word_reg(REG_CRC_POLY, 0x8B32)
        await tqv.write_byte_reg(REG_COMM, 0xFF)                        # the pin follows comm: recessive
        await bench.load_chroma(chroma_can_tx, chroma_can_tx_ctrlReg, chroma_can_tx_pinmuxReg)
        await self.clocks(100)

        async def send(ident, data, ack=True, jam=None):
            image, nbits = can.pack_frame(ident, data)
            listener = cocotb.start_soon(node.receive(ack=ack, jam=jam))   # armed before the SOF
            for b in image:
                await tqv.write_byte_reg(REG_FIFO, b)
            await tqv.write_byte_reg(REG_LIMIT3, nbits - 1)
            await tqv.write_byte_reg(REG_TOGGLE, 0)                      # go
            got = await listener
            for _ in range(40):
                if await bench.irq():
                    break
                await self.clocks(16)
            assert await bench.irq(), f"ID {ident:#x}: no interrupt"
            flags = await tqv.read_word_reg(REG_FLAGS)
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            return got, (flags >> 6) & 1, (flags >> 7) & 1             # acked, lost

        async def check(ident, data, ack=True):
            got, acked, lost = await send(ident, data, ack=ack)
            assert got and not got.get("lost"), f"ID {ident:#x}: the node saw no frame: {got}"
            if (got["ident"], got["data"], got["crc_ok"]) != (ident, data, True):
                stuffed, _, _ = can.frame_bits(ident, data)
                raw = got["raw"]
                first = next((i for i in range(min(len(raw), len(stuffed))) if raw[i] != stuffed[i]), None)
                self.log(f"expected {''.join(map(str, stuffed))}")
                self.log(f"raw      {''.join(map(str, raw[:len(stuffed) + 4]))}  first difference at {first}")
                assert False, f"ID {ident:#x}: node decoded {dict((k, v) for k, v in got.items() if k != 'raw')}"
            assert acked == (1 if ack else 0) and lost == 0, f"ID {ident:#x}: flags acked {acked} lost {lost}"
            assert (int(dut.uo_out.value) >> 2) & 1 == 1, "TXD released"
            st = await tqv.read_word_reg(REG_FIFO_ST)
            assert fifo_count(st) == 0, f"ID {ident:#x}: {fifo_count(st)} bytes left in the FIFO"
            return got

        self.log("a 3-byte frame, acknowledged")
        await check(0x123, [0xDE, 0xAD, 0x42])
        self.log("ID 0 with eight zero bytes: stuff bits inserted every five bits")
        got = await check(0x000, [0] * 8)
        assert got["stuffed"] > 19 + 64 + 15, "no stuff bits were inserted"
        self.log("no data")
        await check(0x7FF, [])
        self.log("0xFF / 0x00 patterns")
        await check(0x2AA, [0xFF, 0x00, 0xFF, 0x00, 0xAA, 0x55, 0x0F, 0xF0])
        self.log("nobody acknowledges: F0 stays 0")
        await check(0x555, [1, 2, 3, 4], ack=False)
        self.log("lost arbitration on ID bit 4 (the node drives it dominant)")
        got, acked, lost = await send(0x7FF, [0x11, 0x22], jam=5)      # raw bit 5 = ID bit 6 (recessive)
        assert lost == 1 and acked == 0, f"flags acked {acked} lost {lost}"
        await self.clocks(64)
        assert (int(dut.uo_out.value) >> 2) & 1 == 1, "TXD released after losing"
        await tqv.write_word_reg(REG_FIFO_ST, 0)                        # the rest of the frame: flush
        await self.clocks(64 * 12)
        self.log("and the next frame goes out fine")
        await check(0x321, [0x99])
        await bench.disable()
        dut.ui_in[3].value = 0


class CanLoopTest(PrismTest):
    ''' A CAN node: the receiver chroma in shard 0 (ACK on uo_out[1]) and
        the transmitter in shard 1 (TXD on uo_out[2]), the bus a wired AND
        of the two on ui_in[3].  Frames sent by shard 1 land in shard 0's
        FIFO with the ACK from shard 0 seen by shard 1 (F0), interrupts on
        both shards. '''
    name = "CAN node: transmitter (shard 1) to receiver (shard 0) over the bus"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        node = can.CanNode(dut, rxd=3, txd=2, ack_pin=1, bit_clocks=64)
        dut.ui_in[3].value = 1
        for base in (0, SHARD1):
            await tqv.write_word_reg(REG_FIFO_ST + base, 0)
            await tqv.write_byte_reg(REG_HOST + base, 0x00)
            await tqv.write_byte_reg(REG_COMPARE + base, 4)
            await tqv.write_word_reg(REG_PRELOAD + base, 63)
            await tqv.write_word_reg(REG_CRC_POLY + base, 0x8B32)
            await tqv.write_word_reg(REG_CRC_EXP + base, 0)
        # receiver (shard 0)
        await tqv.write_word_reg(REG_CFG1, 0)
        await tqv.write_word_reg(REG_CFG2, 15 << 4)
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(3) | CFG3_SMP_FALL | CFG3_SMP_TIMER |
                                           CFG3_SMP_PRESET(2) | CFG3_STUFF_EN)
        await tqv.write_word_reg(REG_CONST, (19 << 24) | (15 << 16))
        await tqv.write_word_reg(REG_COUNT3, 0xF0 << 16)
        ack_si = can.state_with_default_output(chroma_can_rx, 0)
        await tqv.write_word_reg(REG_PRELOAD2, 78 | T2_RELOAD | T2_STATE(ack_si) | T2_ONESHOT)
        # transmitter (shard 1)
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 8 << 4)
        await tqv.write_word_reg(REG_CFG3 + SHARD1, CFG3_STUFF_EN | CFG3_STUFF_TX)
        await tqv.write_word_reg(REG_CONST + SHARD1, (11 << 24) | (14 << 16) | (0xFF << 8))
        await tqv.write_byte_reg(REG_COMM + SHARD1, 0xFF)
        await bench.load_fractured(chroma_can_rx, chroma_can_rx_ctrlReg, chroma_can_rx_pinmuxReg,
                                   chroma_can_tx, chroma_can_tx_ctrlReg, chroma_can_tx_pinmuxReg)
        await self.clocks(100)

        async def send(ident, data):
            image, nbits = can.pack_frame(ident, data)
            bus = cocotb.start_soon(node.mirror(64 * (19 + 8 * len(data) + 15 + 24 + 20) + 600))
            for b in image:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
            await tqv.write_byte_reg(REG_LIMIT3 + SHARD1, nbits - 1)
            await tqv.write_byte_reg(REG_TOGGLE + SHARD1, 0)
            await bus
            assert await bench.irq(IRQ0_MASK), f"ID {ident:#x}: no receive interrupt"
            assert await bench.irq(IRQ1_MASK), f"ID {ident:#x}: no transmit interrupt"
            flags = await tqv.read_word_reg(REG_FLAGS + SHARD1)
            assert (flags >> 6) & 3 == 1, f"ID {ident:#x}: transmitter flags {flags:#x} (acked, not lost expected)"
            assert await tqv.read_word_reg(REG_CRC) == 0, f"ID {ident:#x}: receiver CRC not 0"
            _, body, _ = can.frame_bits(ident, data)
            exp = can.expected_bytes(body)
            st = await tqv.read_word_reg(REG_FIFO_ST)
            got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(st))]
            assert got == exp, f"ID {ident:#x}: received {[hex(b) for b in got]} expected {[hex(b) for b in exp]}"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            await tqv.write_byte_reg(REG_INT_CLR1, 0x80)

        self.log("three frames from shard 1 to shard 0")
        await send(0x123, [0xDE, 0xAD, 0x42])
        await send(0x000, [0] * 8)
        await send(0x7FF, [])
        await bench.disable()
        dut.ui_in[3].value = 0


class UartRxTest(PrismTest):
    ''' 8N1 receiver on ui_in[0] (chroma_uart_rx): the bit clock of 4b.2
        re-centred by the sampler on every falling edge, bytes into the RX
        FIFO with an interrupt each, a CRC-8 over the data bits.  Bytes at
        the nominal rate, 5 % fast and 5 % slow, back to back, a framing
        error (dropped), and the CRC against regs.crc_bits. '''
    name = "UART receiver chroma (chroma_uart_rx)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        uart = UartTx(dut, pin=0, period=64.0)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_CFG2, 15 << 4)                     # input 17 = the sampler's pending flag
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(0) | CFG3_SMP_FALL | CFG3_SMP_TIMER |
                                           CFG3_SMP_PRESET(1))
        await tqv.write_word_reg(REG_CONST, 0)
        await tqv.write_word_reg(REG_PRELOAD, 63)                       # 64-clock bits
        await tqv.write_word_reg(REG_CRC_POLY, 0x07)
        await bench.load_chroma(chroma_uart_rx, chroma_uart_rx_ctrlReg, chroma_uart_rx_pinmuxReg)
        await self.clocks(100)

        async def receive(data, period=64.0, gap=0, bad_stop=False):
            uart.period = period
            await tqv.write_word_reg(REG_CRC, 0)
            await uart.send(data, gap=gap, bad_stop=bad_stop)
            await self.clocks(100)
            st = await tqv.read_word_reg(REG_FIFO_ST)
            got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(st))]
            return got

        self.log("bytes at the nominal rate, with an interrupt per byte")
        got = await receive([0x55, 0xA3, 0x00, 0xFF])
        assert got == [0x55, 0xA3, 0x00, 0xFF], f"got {[hex(b) for b in got]}"
        assert await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        self.log("5 % fast and 5 % slow bit rates, back to back")
        assert await receive([0x12, 0x34, 0x56], period=60.8) == [0x12, 0x34, 0x56]
        assert await receive([0x9A, 0xBC, 0xDE], period=67.2) == [0x9A, 0xBC, 0xDE]
        self.log("a framing error drops the byte; the next one is fine")
        assert await receive([0x77], bad_stop=True) == []
        assert await receive([0x88], gap=64) == [0x88]
        self.log("the CRC-8 over the data bits, as chroma_uart_tx computes it")
        msg = [0x31, 0x32, 0x33, 0x34]
        assert await receive(msg) == msg
        bits = [(b >> k) & 1 for b in msg for k in range(8)]
        assert await tqv.read_word_reg(REG_CRC) == crc_bits(bits, 0x07, 8)
        await tqv.write_word_reg(REG_CFG3, 0)
        await bench.disable()


class UartLoopTest(PrismTest):
    ''' chroma_uart_tx in shard 0 (uo_out[1]) to chroma_uart_rx in shard 1
        (ui_in[0], mirrored from uo_out[1] by the bench), fractured: a
        message and its CRC-8 trailer arrive in shard 1's FIFO, and shard
        1's CRC over the message equals the trailer. '''
    name = "UART loopback: transmitter (shard 0) to receiver (shard 1)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        dut.ui_in[0].value = 1
        for base in (0, SHARD1):
            await tqv.write_word_reg(REG_FIFO_ST + base, 0)
            await tqv.write_word_reg(REG_CRC_POLY + base, 0x07)
            await tqv.write_word_reg(REG_CRC + base, 0)
        await tqv.write_word_reg(REG_HOST, 0)
        await tqv.write_word_reg(REG_PRELOAD, 62)                       # tx: 64-clock bits (period - 2)
        await tqv.write_word_reg(REG_PRELOAD + SHARD1, 63)              # rx: bit period - 1
        await tqv.write_word_reg(REG_CFG2 + SHARD1, 15 << 4)
        await tqv.write_word_reg(REG_CFG3 + SHARD1, CFG3_SMP_EN | CFG3_SMP_SRC(0) | CFG3_SMP_FALL | CFG3_SMP_TIMER |
                                                    CFG3_SMP_PRESET(1))
        await tqv.write_word_reg(REG_CONST + SHARD1, 0)
        await bench.load_fractured(chroma_uart_tx, chroma_uart_tx_ctrlReg, chroma_uart_tx_pinmuxReg,
                                   chroma_uart_rx, chroma_uart_rx_ctrlReg, chroma_uart_rx_pinmuxReg)

        async def mirror(clocks):
            for _ in range(clocks):
                dut.ui_in[0].value = (int(dut.uo_out.value) >> 1) & 1
                await RisingEdge(dut.clk)
        wire = cocotb.start_soon(mirror(64 * 10 * 8 + 2000))
        msg = [0x48, 0x65, 0x6C, 0x6C, 0x6F]                            # "Hello"
        for b in msg:
            await tqv.write_byte_reg(REG_FIFO, b)
        await tqv.write_word_reg(REG_HOST, 1)                           # send, then the CRC trailer
        await wire
        assert await bench.irq(IRQ0_MASK), "transmitter done interrupt"
        bits = [(b >> k) & 1 for b in msg for k in range(8)]
        trailer = crc_bits(bits, 0x07, 8)
        st = await tqv.read_word_reg(REG_FIFO_ST + SHARD1)
        got = [await tqv.read_byte_reg(REG_FIFO + SHARD1) for _ in range(fifo_count(st))]
        assert got == msg + [trailer], f"received {[hex(b) for b in got]}, expected {[hex(b) for b in msg + [trailer]]}"
        await tqv.write_word_reg(REG_HOST, 0)
        await tqv.write_word_reg(REG_CFG3 + SHARD1, 0)
        await bench.disable()
        dut.ui_in[0].value = 0


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
        assert fifo_count(await tqv.read_word_reg(REG_FIFO_ST)) == 16          # the 16 table rows
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
        assert (st >> 8) & 0x3FFF == len(payload) + 2, f"{st:#x}"
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
        assert not dec.edges[0], f"edges off the half-bit grid (phase steps): {dec.edges[0][:4]}"
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
        assert not dec.edges[1], f"edges off the half-bit grid (phase steps): {dec.edges[1][:4]}"
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
        assert not dec.edges[2], f"edges off the half-bit grid with timer ticks: {dec.edges[2][:4]}"
        await tqv.write_word_reg(REG_PRELOAD2, 0)
        await bench.disable()


class EthernetRxTest(PrismTest):
    ''' 10BASE-T receive: the Manchester bit recoverer (CFG3) on ui_in[3],
        the eth_rx chroma assembling bytes into the SRAM FIFO, the host
        checking the bytes and the CRC32 residue.  A link pulse first (no
        frame), a 64-byte frame, a 300-byte frame from a line 8% slower than
        the clock, a frame with a bad FCS.  Then double-edge sampling
        (CFG3[9], half clocks per half bit): a 12% slow frame at 64 MHz, and
        a 50 MHz clock (2.5 clocks per half bit, hb = 5) with a slow line. '''
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

        async def receive(payload, fcs=None, stretch=0, bit=BIT):
            e = eth.EthEncoder(self.dut, bit, rxd=PIN, stretch=stretch)
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

        self.log("double-edge sampling: 6 half clocks per half bit, 300-byte frame 12% slow")
        await tqv.write_word_reg(REG_CFG3, PIN | (1 << 3) | (BIT << 4) | (1 << 8) | CFG3_MRX_DDR)
        payload = [(i * 13 + 5) & 0xFF for i in range(300)]
        flags, crc = await receive(payload, stretch=4)
        assert flags & FLAG_CRC_OK, f"crc_ok clear, CRC = {crc:#x}"

        self.log("double-edge sampling at a 50 MHz clock: 2.5 clocks per half bit, hb = 5, line 8% slow")
        await tqv.write_word_reg(REG_CFG3, PIN | (1 << 3) | (5 << 4) | (1 << 8) | CFG3_MRX_DDR)
        await tqv.write_word_reg(REG_PRELOAD, 10)                             # idle: two 5-clock bit times
        payload = [(i * 3 + 7) & 0xFF for i in range(200)]
        flags, crc = await receive(payload, bit=5.4)                          # 2.7 clocks per half bit: 2, 3, 3, ...
        assert flags & FLAG_CRC_OK, f"crc_ok clear, CRC = {crc:#x}"
        flags, crc = await receive(payload[:60], bit=5)
        assert flags & FLAG_CRC_OK, f"crc_ok clear, CRC = {crc:#x}"
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


class JtagMasterTest(PrismTest):
    ''' JTAG controller: TMS walks and IR / DR scans of N bits (LIMIT3)
        from FIFO B with the TDO bits back in FIFO A, against a TAP model:
        reset, IDCODE, an IR scan, a 20-bit register written and read
        back (a partial last byte), BYPASS, and a 300-bit register scanned
        in three chained operations (the first two stay in Shift-DR). '''
    name = "jtag_master Chroma (TAP walks, IR / DR scans)"
    HALF = int(os.environ.get("JTAG_HALF", 3))       # TCK half period in clocks

    async def run(self):
        tqv, bench, dut, HALF = self.tqv, self.bench, self.dut, self.HALF
        T = JtagTap
        await tqv.write_byte_reg(REG_HOST, 0x00)
        tap = self.start(JtagTap(dut))
        sync = int(os.environ.get("JTAG_SYNC", 0))                           # CFG0[19:18]: 0 = two flops, 1 = one, 2 = raw
        await bench.load_chroma(chroma_jtag_master, chroma_jtag_master_ctrlReg | (sync << 18), chroma_jtag_master_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: the bytes to shift out
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        await tqv.write_word_reg(REG_CFG1, 8)                                 # in_prev0 <- host_in[0]
        await tqv.write_word_reg(REG_PRELOAD, HALF - 1)
        self.mode = 0

        async def op(value, nbits, walk=False, stay=False):
            ''' One operation of `nbits`: `value` out LSB first; the TDO bits as an integer '''
            mode = 2 if walk else 0
            if mode != self.mode:
                host = await tqv.read_byte_reg(REG_HOST)
                await tqv.write_byte_reg(REG_HOST, (host & 1) | mode)         # host_in[1], [0] kept
                self.mode = mode
            await tqv.write_byte_reg(REG_LIMIT3, nbits - 1)
            await tqv.write_byte_reg(REG_COMPARE, 1 if stay else 0)
            nbytes = (nbits + 7) // 8
            for k in range(nbytes):
                await tqv.write_byte_reg(REG_FIFO + SHARD1, (value >> (8 * k)) & 0xFF)
            before = tap.tcks
            await tqv.write_byte_reg(REG_TOGGLE, 0)                           # go
            for _ in range(nbits * 2 * HALF // 8 + 40):
                if await bench.irq():
                    break
                await self.clocks(8)
            assert await bench.irq(), f"no interrupt, state {await bench.curr_state()}"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            assert await bench.curr_state() == 0
            assert tap.tcks - before == nbits, f"{tap.tcks - before} TCKs for {nbits} bits"
            count = (await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x3FFF
            assert count == nbytes, f"{count} bytes in FIFO A, {nbytes} expected"
            got = 0
            for k in range(nbytes):
                b = await tqv.read_byte_reg(REG_FIFO)
                if k == nbytes - 1 and nbits % 8:
                    b >>= 8 - nbits % 8                                       # a partial byte sits at the top
                got |= b << (8 * k)
            return got

        async def shift_dr():
            await op(0b001, 3, walk=True)                                     # Select-DR, Capture-DR, Shift-DR
            assert tap.state == T.SH_DR, tap.state

        async def shift_ir():
            await op(0b0011, 4, walk=True)                                    # Select-DR, Select-IR, Capture-IR, Shift-IR
            assert tap.state == T.SH_IR, tap.state

        async def to_idle():
            await op(0b01, 2, walk=True)                                      # Update, Run-Test/Idle
            assert tap.state == T.RTI, tap.state

        async def set_ir(ir):
            await shift_ir()
            got = await op(ir, T.IR_LEN)
            assert tap.state == T.EX1_IR
            await to_idle()
            assert tap.ir == ir
            return got

        self.log("reset: five TMS ones, then Run-Test/Idle")
        tap.state = T.SH_DR                                                   # from anywhere
        await op(0b011111, 6, walk=True)
        assert tap.state == T.RTI and T.TLR in tap.trail, tap.trail
        assert tap.ir == T.IDCODE

        self.log("IDCODE: 32 bits")
        await shift_dr()
        got = await op(0, 32)
        assert got == tap.idcode, hex(got)
        assert tap.state == T.EX1_DR                                          # TMS rose on the last bit
        await to_idle()

        self.log("IR scan: USER")
        assert await set_ir(T.USER) == 0b0001                                 # the IR's capture value

        self.log("20-bit register: written, the old value comes back")
        await shift_dr()
        got = await op(0xABCDE, 20)
        assert got == 0x5A5A5, hex(got)
        await to_idle()
        assert tap.user == 0xABCDE and tap.updates[-1] == (T.USER, 0xABCDE), tap.updates[-1:]
        await shift_dr()
        got = await op(0x12345, 20)
        assert got == 0xABCDE, hex(got)
        await to_idle()
        assert tap.user == 0x12345

        self.log("BYPASS: one bit of delay")
        await set_ir(0xF)
        await shift_dr()
        got = await op(0x1A5, 9)
        assert got == (0x1A5 << 1) & 0x1FF, hex(got)                          # the bypass bit captures 0
        await to_idle()

        self.log("300-bit register in three chained operations")
        await set_ir(T.LONG)
        old = tap.long
        new = int.from_bytes(bytes((i * 37 + 11) & 0xFF for i in range(38)), 'little') & ((1 << 300) - 1)
        await shift_dr()
        got = await op(new & ((1 << 128) - 1), 128, stay=True)
        assert tap.state == T.SH_DR                                           # no exit: TMS stayed low
        got |= await op((new >> 128) & ((1 << 128) - 1), 128, stay=True) << 128
        assert tap.state == T.SH_DR
        got |= await op(new >> 256, 44) << 256
        assert tap.state == T.EX1_DR
        assert got == old, hex(got ^ old)
        await to_idle()
        assert tap.long == new, hex(tap.long ^ new)

        self.log("FIFO B runs dry: the operation ends early")
        await tqv.write_byte_reg(REG_HOST, (await tqv.read_byte_reg(REG_HOST) & 1) | 2)
        self.mode = 2
        await tqv.write_byte_reg(REG_LIMIT3, 15)
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, 0x00)                     # one byte for a 16-bit walk (TMS 0: stays idle)
        before = tap.tcks
        await tqv.write_byte_reg(REG_TOGGLE, 0)
        await self.clocks(16 * 2 * HALF + 60)
        assert await bench.irq() and await bench.curr_state() == 0
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert tap.tcks - before == 8, tap.tcks - before
        assert await tqv.read_byte_reg(REG_COUNT3) == 8
        assert await tqv.read_byte_reg(REG_FIFO) == 0xFF                      # TDO released: ones
        assert tap.state == T.RTI

        assert tap.unstable == 0, f"{tap.unstable} rising edges without TMS / TDI setup"
        await bench.disable()


class SpwTxTest(PrismTest):
    ''' SpaceWire transmitter: Data-Strobe bits of exactly one bit-clock
        period, NULLs while idle, an FCT per host request, data characters
        from the FIFO under credit (count2 FCTs of eight characters each),
        EOP / EEP on request, the parity of every character; a decoder model
        recovers the bits from the edges of D xor S.  Unfractured the host
        writes the credit into COUNT2. '''
    name = "spw_tx Chroma (SpaceWire transmitter)"
    BIT = int(os.environ.get("SPW_BIT", 6))          # clocks per bit
    FRACTURED = False

    async def credit(self, fcts):
        ''' `fcts` more FCTs of credit: the host adds them to COUNT2 (no character is using one up meanwhile) '''
        have = await self.tqv.read_byte_reg(REG_COUNT2 + self.base)
        await self.tqv.write_byte_reg(REG_COUNT2 + self.base, have + fcts)

    async def load(self):
        await self.bench.load_chroma(chroma_spw_tx, chroma_spw_tx_ctrlReg, chroma_spw_tx_pinmuxReg)

    async def run(self):
        tqv, bench, dut, BIT = self.tqv, self.bench, self.dut, self.BIT
        self.base = base = SHARD1 if self.FRACTURED else 0
        irq_mask, irq_clr = (IRQ1_MASK, REG_INT_CLR1) if self.FRACTURED else (IRQ0_MASK, REG_INT_CLR0)
        for b in (0, SHARD1):
            await tqv.write_byte_reg(REG_HOST + b, 0x00)
            await tqv.write_word_reg(REG_FIFO_ST + b, 0)
            await tqv.write_byte_reg(REG_COUNT2 + b, 0)                       # no credit yet
        await tqv.write_word_reg(REG_CFG1, 8 | (9 << 4))                      # in_prev0 / 1 <- host_in[0] / [1]
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 8 | (9 << 4))
        await tqv.write_word_reg(REG_CFG2 + base, (7 << 8) | (14 << 12))      # inputs 18, 19 = comm[2] (the ESC's mark), flag2
        await tqv.write_word_reg(REG_CONST + base, 0x030B1F00)                # K3 FCT, K2 EOP, K1 ESC + mark, K0 data prefix
        await tqv.write_word_reg(REG_CRC_POLY + base, 0x80)                   # CRC8 with x^8 + x^7: the parity
        await tqv.write_word_reg(REG_CRC_EXP + base, 0)
        await tqv.write_word_reg(REG_PRELOAD + base, BIT - 1)
        await tqv.write_byte_reg(REG_COMPARE + base, 1)                       # credit: count2 >= 1
        await tqv.write_byte_reg(REG_LIMIT3 + base, 7)                        # eight characters per FCT
        dec = self.start(spw.SpwDecoder(dut))
        self.host = 0
        self.seen = 0

        async def news(clocks):
            ''' Run, then the events since the last call; the stream must stay clean '''
            await self.clocks(clocks)
            events, errors = dec.decode()
            assert not errors, errors
            assert dec.both == 0, f"D and S changed together {dec.both} times"
            bad = [p for p in dec.periods() if p != BIT]
            assert not bad, f"bit periods other than {BIT} clocks: {bad[:8]}"
            new, self.seen = events[self.seen:], len(events)
            return new

        async def until(done, bits=200):
            ''' Run until done(events so far in this call) holds; the events '''
            new = []
            for _ in range(bits // 4):
                new += await news(4 * BIT)
                if done(new):
                    return new + await news(12 * BIT)                         # and what follows it
            assert False, f"not within {bits} bits: {new}"

        async def toggle(bit):
            self.host ^= 1 << bit
            await tqv.write_byte_reg(REG_HOST + base, self.host)

        def data(new):
            return [e[1] for e in new if isinstance(e, tuple) and e[0] == 'DATA']

        async def push(values):
            ''' Into the FIFO, no faster than the link takes them '''
            for b in values:
                for _ in range(200):
                    if fifo_count(await tqv.read_word_reg(REG_FIFO_ST + base)) < 12:
                        break
                    await self.clocks(4 * BIT)
                await tqv.write_byte_reg(REG_FIFO + base, b)

        self.log("the link starts from D = S = 0: a NULL, the first FCT, NULLs")
        await self.load()
        new = await news(60 * BIT)
        assert dec.first == (0, 0), dec.first
        assert dec.bits[:8] == [0, 1, 1, 1, 0, 1, 0, 0], dec.bits[:8]          # the NULL of the standard
        assert len(new) >= 5 and new[:2] == ['NULL', 'FCT'] and set(new[2:]) == {'NULL'}, new

        self.log("an FCT for the host")
        await toggle(1)
        new = await until(lambda n: 'FCT' in n)
        assert new.count('FCT') == 1 and set(new) == {'NULL', 'FCT'}, new
        await toggle(1)
        new = await until(lambda n: 'FCT' in n)                               # a request is taken between two characters:
        await toggle(1)                                                       # the next one only after that
        new += await until(lambda n: 'FCT' in n)
        assert new.count('FCT') == 2 and set(new) == {'NULL', 'FCT'}, new

        self.log("data waits for credit")
        packet = [0x00, 0xFF, 0x01, 0x80, 0x5A]
        await push(packet)
        new = await news(40 * BIT)
        assert set(new) == {'NULL'}, new
        await self.credit(1)                                                  # one FCT: eight characters
        new = await until(lambda n: len(data(n)) == len(packet))
        assert [e for e in new if e != 'NULL'] == [('DATA', b) for b in packet], new

        self.log("EOP on request, with the interrupt")
        await tqv.write_byte_reg(irq_clr, 0x80)
        assert not await bench.irq(irq_mask)
        await toggle(0)
        new = await until(lambda n: 'EOP' in n)
        assert new.count('EOP') == 1 and set(new) == {'NULL', 'EOP'}, new
        assert await bench.irq(irq_mask)
        await tqv.write_byte_reg(irq_clr, 0x80)
        assert await tqv.read_byte_reg(REG_COUNT3 + base) == 6                # five data characters and the EOP
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 1

        self.log("the credit runs out after eight characters")
        more = [0xA5, 0x3C, 0x7E, 0x11, 0xEE]
        await push(more)
        new = await until(lambda n: len(data(n)) == 2) + await news(40 * BIT)
        assert data(new) == more[:2], new                                     # characters seven and eight
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 0
        assert await tqv.read_byte_reg(REG_COUNT3 + base) == 0
        await toggle(1)                                                       # FCTs need no credit
        new = await until(lambda n: 'FCT' in n)
        assert new.count('FCT') == 1 and not data(new), new
        await self.credit(2)                                                  # two more FCTs
        new = await until(lambda n: len(data(n)) == 3)
        assert data(new) == more[2:], new
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 2

        self.log("EEP instead of EOP: K2")
        await tqv.write_word_reg(REG_CONST + base, 0x03071F00)
        await toggle(0)
        new = await until(lambda n: 'EEP' in n)
        assert new.count('EEP') == 1 and 'EOP' not in new, new
        await tqv.write_word_reg(REG_CONST + base, 0x030B1F00)

        self.log("a packet of 40 bytes, the FIFO refilled on the way")
        await self.credit(7)                                                  # seven FCTs at once: all the standard allows
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 9
        packet = [(i * 29 + 7) & 0xFF for i in range(40)]
        before = len(data(dec.decode()[0]))
        await push(packet)
        for _ in range(100):
            await news(8 * BIT)
            if len(data(dec.decode()[0])) - before == len(packet):
                break
        got = data(dec.decode()[0])[before:]
        assert got == packet, [hex(v) for v in got]
        await toggle(0)
        new = await until(lambda n: 'EOP' in n)
        assert new.count('EOP') == 1 and not data(new), new
        self.log(f"    {len(dec.bits)} bits, {self.seen} characters, every period {BIT} clocks")
        await bench.disable()
        await tqv.write_word_reg(REG_FRAC_CFG, 0)


class SpwTxFracturedTest(SpwTxTest):
    ''' The same transmitter on shard 1 of the fractured PRISM, its 13
        states in one bank; shard 0 runs a stub that sets the semaphore
        COUNT2 times, two clocks apart, on a toggle of its host_in[0], as a
        receiver does for every FCT it decodes.  The sampler counts the
        semaphore's edges into the transmitter's count2: the credit. '''
    name = "spw_tx Chroma on one shard, credit by semaphore"
    FRACTURED = True

    async def credit(self, fcts):
        ''' A burst of `fcts` semaphores from the stub; count2 must rise by as many '''
        tqv = self.tqv
        before = await tqv.read_byte_reg(REG_COUNT2 + self.base)
        used = await tqv.read_byte_reg(REG_COUNT3 + self.base)
        await tqv.write_byte_reg(REG_COUNT2, fcts)                            # the stub's own count
        self.stub_host ^= 1
        await tqv.write_byte_reg(REG_HOST, self.stub_host)
        await self.clocks(4 * fcts + 40)
        assert await tqv.read_byte_reg(REG_COUNT2) == 0
        after = await tqv.read_byte_reg(REG_COUNT2 + self.base)
        # characters that went out meanwhile may have used one FCT up
        spent = 1 if await tqv.read_byte_reg(REG_COUNT3 + self.base) < used else 0
        assert after == before + fcts - spent, (before, fcts, spent, after)

    async def load(self):
        tqv = self.tqv
        self.stub_host = 0
        await tqv.write_byte_reg(REG_COMPARE, 1)                              # the stub: while count2 >= 1
        await tqv.write_word_reg(REG_CFG3 + self.base, CFG3_SMP_EN | CFG3_SMP_SRC(24) | CFG3_SMP_RISE | CFG3_SMP_CNT2)
        await self.bench.load_fractured(chroma_spw_fct_stub, chroma_spw_fct_stub_ctrlReg, chroma_spw_fct_stub_pinmuxReg,
                                        chroma_spw_tx, chroma_spw_tx_ctrlReg, chroma_spw_tx_pinmuxReg)

    async def run(self):
        await super().run()
        await self.tqv.write_word_reg(REG_CFG3 + SHARD1, 0)


class SpwRxTest(PrismTest):
    ''' SpaceWire receiver on shard 0 (D on ui_in[1], S on ui_in[2]) fed by
        an encoder model, the transmitter on shard 1: the receiver waits for
        a quiet line and the first bit, the transmitter for the receiver
        (a NULL, then the link's first FCT); FCTs into the transmitter's
        credit, packets into the FIFO with their ends escaped, NULLs and
        FCTs inside a packet; then every link error (parity on data, on
        control, on a NULL, anything but an FCT after an ESC, a time-code,
        the lines stopping): interrupt, one more link lost, the transmitter
        silent, and a new link without the host touching the PRISM. '''
    name = "spw_rx Chroma (SpaceWire receiver, the link's passive end)"
    BIT = int(os.environ.get("SPW_BIT", 6))          # clocks per bit of the other end
    TX_BIT = max(BIT, 6)                             # ours: the transmitter's minimum is 6
    ESC_BYTE = 0xF0
    TIMEOUT = 51                                     # 850 ns at 60 MHz
    QUIET, FIRST = 0, 1                              # the receiver's states without a link

    async def configure(self):
        tqv, BIT = self.tqv, self.BIT
        for b in (0, SHARD1):
            await tqv.write_byte_reg(REG_HOST + b, 0x00)
            await tqv.write_word_reg(REG_FIFO_ST + b, 0)
            await tqv.write_byte_reg(REG_COUNT2 + b, 0)
            await tqv.write_byte_reg(REG_COUNT3 + b, 0)
            await tqv.write_word_reg(REG_CRC_POLY + b, 0x80)                  # CRC8 with x^8 + x^7: the parity
            await tqv.write_word_reg(REG_CRC + b, 0)
        # the receiver, shard 0
        await tqv.write_word_reg(REG_CFG2, 15 | (12 << 4) | (11 << 8) | (13 << 12))   # edge pending, comm[7], comm[6], comm == K3
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(1) | CFG3_SMP_DS | CFG3_SMP_TIMER | CFG3_SMP_CNT2)
        await tqv.write_byte_reg(REG_COMPARE, 8)                              # the bits of a data character
        await tqv.write_word_reg(REG_CONST, (self.ESC_BYTE << 24) | 0x010000)  # K3 escape, K2 EEP, K0 EOP
        await tqv.write_word_reg(REG_CRC_EXP, 0x80)                           # odd
        await tqv.write_word_reg(REG_PRELOAD, self.TIMEOUT - 1)
        # the transmitter, shard 1
        await tqv.write_word_reg(REG_CFG1 + SHARD1, 8 | (9 << 4))
        await tqv.write_word_reg(REG_CFG2 + SHARD1, (7 << 8) | (14 << 12))
        await tqv.write_word_reg(REG_CFG3 + SHARD1, CFG3_SMP_EN | CFG3_SMP_SRC(24) | CFG3_SMP_RISE | CFG3_SMP_CNT2)
        await tqv.write_word_reg(REG_CONST + SHARD1, 0x030B1F00)
        await tqv.write_word_reg(REG_CRC_EXP + SHARD1, 0)
        await tqv.write_word_reg(REG_PRELOAD + SHARD1, self.TX_BIT - 1)
        await tqv.write_byte_reg(REG_COMPARE + SHARD1, 1)
        await tqv.write_byte_reg(REG_LIMIT3 + SHARD1, 7)
        self.host = 0

    async def load(self):
        await self.bench.load_fractured(chroma_spw_rx, chroma_spw_rx_ctrlReg, chroma_spw_rx_pinmuxReg,
                                        chroma_spw_tx, chroma_spw_tx_ctrlReg, chroma_spw_tx_pinmuxReg)

    async def unload(self):
        tqv, dut = self.tqv, self.dut
        await self.bench.disable()
        for b in (0, SHARD1):
            await tqv.write_word_reg(REG_CFG3 + b, 0)
            await tqv.write_word_reg(REG_CFG2 + b, 0)
            await tqv.write_byte_reg(REG_HOST + b, 0)
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
        dut.ui_in[1].value = 0
        dut.ui_in[2].value = 0

    async def toggle(self, bit):
        ''' A request to the transmitter: 1 an FCT, 0 an EOP '''
        self.host ^= 1 << bit
        await self.tqv.write_byte_reg(REG_HOST + SHARD1, self.host)

    async def fifo(self):
        tqv = self.tqv
        return [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(await tqv.read_word_reg(REG_FIFO_ST)))]

    async def lost(self):
        ''' Links the receiver has lost '''
        return await self.tqv.read_byte_reg(REG_COUNT3)

    async def credit(self):
        return await self.tqv.read_byte_reg(REG_COUNT2 + SHARD1)

    async def run(self):
        tqv, bench, dut, BIT = self.tqv, self.bench, self.dut, self.BIT
        E = self.ESC_BYTE
        await self.configure()
        enc = spw.SpwEncoder(dut, BIT)
        dec = spw.SpwDecoder(dut)
        self.tasks += [enc, dec]

        async def packet(stream, settle=6):
            ''' Send it, then what the FIFO holds '''
            await enc.send(stream)
            await self.clocks(settle * BIT)
            return await self.fifo()

        self.log("no link: the receiver waits, the transmitter is silent")
        await self.load()
        dec.start()
        await self.clocks(6 * self.TIMEOUT)
        assert await bench.curr_state() == self.FIRST and await bench.curr_state(1) == 0
        assert dec.bits == [] and dec.lines() == (0, 0)
        assert not await bench.irq() and await self.lost() == 0

        self.log("the link comes in: the transmitter answers with a NULL and the FCT")
        enc.start()
        await self.clocks(100 * BIT)
        events, errors = dec.decode()
        assert not errors and dec.both == 0, errors
        assert events[:3] == ['NULL', 'FCT', 'NULL'] and set(events[2:]) == {'NULL'}, events[:6]
        assert [p for p in dec.periods() if p != self.TX_BIT] == []
        assert not await bench.irq() and await self.lost() == 0
        assert await self.fifo() == [] and await self.credit() == 0

        self.log("FCTs are the transmitter's credit")
        await enc.send(['FCT'] * 3)
        await self.clocks(6 * BIT)
        assert await self.credit() == 3, await self.credit()
        await enc.send(['FCT', 'NULL', 'FCT', 'FCT', 'FCT'])
        await self.clocks(6 * BIT)
        assert await self.credit() == 7, await self.credit()

        self.log("a packet, the escape value in its data")
        data = [0x00, 0xFF, E, 0x5A, 0x01, 0x80, E, E]
        stream = [('DATA', b) for b in data] + ['EOP']
        got = await packet(stream)
        assert got == spw.escaped(stream, E), f"{[hex(v) for v in got]} expected {[hex(v) for v in spw.escaped(stream, E)]}"
        assert await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("EEP; NULLs and an FCT inside a packet")
        stream = [('DATA', 0x11), 'NULL', ('DATA', 0x22), 'FCT', 'NULL', ('DATA', 0x33), 'EEP']
        got = await packet(stream)
        assert got == [0x11, 0x22, 0x33, E, 0x01], [hex(v) for v in got]
        assert await self.credit() == 8
        assert await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("two packets back to back, an empty one between them")
        stream = [('DATA', 0xA1), ('DATA', 0xA2), 'EOP', 'EOP', ('DATA', 0xB1), 'EOP']
        got = await packet(stream)
        assert got == [0xA1, 0xA2, E, 0, E, 0, 0xB1, E, 0], [hex(v) for v in got]
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert await self.lost() == 0
        events, errors = dec.decode()
        assert not errors and events.count('FCT') == 1, errors                # the transmitter: NULLs all along

        async def error(what, stream, keeps, before=None):
            ''' The stream ends in an error: interrupt, one more link lost, only `keeps` in the
                FIFO, the transmitter silent; then the next link, with nothing done to the PRISM '''
            self.log(f"error: {what}")
            if before is None:
                before = await self.lost()
            if stream is not None:
                await enc.send(stream)
            for _ in range(40):
                if await self.lost() != before:
                    break
                await self.clocks(BIT)
            assert await self.lost() == before + 1, f"{await self.lost()} links lost, state {await bench.curr_state()}"
            assert await bench.irq()
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            got = await self.fifo()
            assert got == keeps, [hex(v) for v in got]
            await self.clocks(12 * self.TX_BIT)                               # the transmitter: to the end of its NULL
            assert dec.lines() == (0, 0) and await bench.curr_state(1) == 0, (dec.lines(), await bench.curr_state(1))
            assert dec.both == 0
            await self.clocks(20 * BIT)
            assert await self.lost() == before + 1 and await self.fifo() == []    # what is on the line is left alone
            assert await bench.curr_state() == (self.QUIET if enc.running else self.FIRST)
            # the other end notices the silence and starts again; lines that were left
            # standing come down first, which is one more link that comes to nothing
            standing = not enc.running and (enc.D, enc.S) != (0, 0)
            enc.restart()
            await self.clocks(3 * self.TIMEOUT)
            assert await bench.curr_state() == self.FIRST
            assert await self.lost() == before + (2 if standing else 1)
            before = await self.lost() - 1
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            dec.restart()
            enc.start()
            got = await packet(['NULL', 'NULL', ('DATA', 0x77), 'EOP'], settle=40)
            assert got == [0x77, E, 0], [hex(v) for v in got]
            assert await self.lost() == before + 1 and await self.credit() == 0
            events, errors = dec.decode()
            assert not errors and events[:2] == ['NULL', 'FCT'] and set(events[2:]) == {'NULL'}, (errors, events[:6])
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        await error("parity of a data character", [('DATA', 0x42), ('BAD', ('DATA', 0x33)), ('DATA', 0x44)], [0x42])
        await error("parity of a control character", [('DATA', 0x42), ('BAD', 'FCT')], [0x42])
        await error("parity of a NULL", [('BAD', 'NULL')], [])
        await error("ESC, then EOP", ['ESC', 'EOP'], [])
        await error("ESC, then ESC", ['ESC', 'ESC'], [])
        await error("a time-code (not taken)", [('TIME', 0x15)], [])

        before = await self.lost()
        await enc.send([('DATA', 0x55)])
        enc.stop()                                                            # the lines stop where they are
        await error("disconnect", None, [0x55], before)

        self.log("enabled with the line busy: nothing until it has been quiet")
        await bench.disable()
        lost = await self.lost()
        await enc.send(['FCT', ('DATA', 0x66), 'EOP'])
        await bench.enable()                                                  # in the middle of the NULLs
        await enc.send(['FCT', ('DATA', 0x67), 'EOP', 'NULL', 'NULL'])
        assert await bench.curr_state() == self.QUIET and await bench.curr_state(1) == 0
        assert await self.fifo() == [] and await self.credit() == 0 and await self.lost() == lost
        assert not await bench.irq() and dec.lines() == (0, 0)
        enc.restart()
        await self.clocks(2 * self.TIMEOUT)
        dec.restart()
        enc.start()
        got = await packet(['FCT', ('DATA', 0x99), 'EOP'], settle=40)
        assert got == [0x99, E, 0], [hex(v) for v in got]
        assert await self.credit() == 1 and await self.lost() == lost

        enc.stop()
        dec.stop()
        await self.unload()


class SpwLinkTest(SpwRxTest):
    ''' A SpaceWire link: the two chromas (receiver on shard 0, transmitter
        on shard 1) against the other end, a model of the standard's link
        state machine that starts the link.  The link reaches Run on the
        first attempt, packets go both ways under the credit of the FCTs,
        a parity error from the other end and the other end switched off
        and on take the link down, and it forms again with nothing done by
        the host. '''
    name = "SpaceWire link: the passive end against the standard's state machine"

    async def run(self):
        tqv, bench, dut, BIT = self.tqv, self.bench, self.dut, self.BIT
        E = self.ESC_BYTE
        US = 60                                                               # clocks per microsecond
        await self.configure()
        peer = spw.SpwPeer(dut, BIT, grant=2, disconnect=self.TIMEOUT)
        self.tasks.append(peer)

        async def up(within_us, since):
            ''' The clock at which the other end reached Run '''
            for _ in range(within_us):
                if peer.runs(since):
                    return peer.runs(since)[0]
                await self.clocks(US)
            assert False, f"no link in {within_us} us: {peer.history[-8:]}"

        async def push(values):
            for b in values:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)

        async def received(n, within=400):
            ''' Wait until the other end has n packets '''
            for _ in range(within):
                if len(peer.packets) >= n:
                    return
                await self.clocks(BIT * 4)
            assert False, f"{len(peer.packets)} packets, {n} expected; {peer.errors[-3:]} {peer.history[-4:]}"

        self.log("the link: ErrorReset, ErrorWait, Started, Connecting, Run")
        await self.load()
        peer.start()
        t = await up(200, 0)
        states = [st for _, st, _ in peer.history]
        assert states == ['ErrorReset', 'ErrorWait', 'Ready', 'Started', 'Connecting', 'Run'], peer.history
        started = [c for c, st, _ in peer.history if st == 'Started'][0]
        self.log(f"    Run {(t - started) / US:.1f} us after the other end's first NULL")
        assert t - started < 12.8 * US
        await self.clocks(20 * BIT)
        assert await self.credit() == 2 and peer.tx_credit == 8               # its two FCTs, our one
        assert not await bench.irq() and await self.lost() == 0 and not peer.errors

        self.log("a packet to the other end")
        data = [0x53, 0x70, 0x57, E, 0x00, 0xFF, 0x80]
        await push(data)
        await self.clocks(12 * len(data) * BIT)
        await self.toggle(0)                                                  # EOP
        await received(1)
        assert peer.packets[0] == data + ['EOP'], peer.packets
        assert await bench.irq(IRQ1_MASK)
        await tqv.write_byte_reg(REG_INT_CLR1, 0x80)
        assert await self.credit() == 1                                       # eight characters: one FCT used

        self.log("a packet from the other end, inside the credit of our FCT")
        back = [0xC0, E, 0xC2, 0x01, 0x02]
        peer.send([('DATA', b) for b in back] + ['EOP'])
        await self.clocks((10 * len(back) + 30) * BIT)
        got = await self.fifo()
        assert got == spw.escaped([('DATA', b) for b in back] + ['EOP'], E), [hex(v) for v in got]
        assert await bench.irq(IRQ0_MASK)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert peer.tx_credit == 2

        self.log("it waits for our next FCT")
        peer.send([('DATA', b) for b in (1, 2, 3, 4)] + ['EOP'])
        await self.clocks(80 * BIT)
        assert await self.fifo() == [1, 2] and peer.tx_credit == 0
        await self.toggle(1)                                                  # the host has room again
        await self.clocks(80 * BIT)
        assert await self.fifo() == [3, 4, E, 0] and peer.tx_credit == 5
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert not peer.errors and await self.lost() == 0

        self.log("a parity error from the other end: both ends start again")
        mark = peer.clock
        peer.bad_parity = 1
        t = await up(200, mark + 1)
        self.log(f"    Run again {(t - mark) / US:.1f} us after the error")
        assert await self.lost() == 1 and await bench.irq(IRQ0_MASK)
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        assert [e[2] for e in peer.errors] == ['disconnect'], peer.errors     # it saw our silence
        after = [st for c, st, _ in peer.history if c > mark]
        assert after == ['ErrorReset', 'ErrorWait', 'Ready', 'Started', 'Connecting', 'Run'], peer.history[-8:]
        await self.clocks(20 * BIT)
        assert await self.credit() == 2 and peer.tx_credit == 8               # credit from zero on both sides
        lost = await self.lost()

        self.log("the link works again")
        await push([0xAA, 0x55])
        await self.clocks(40 * BIT)
        await self.toggle(0)
        await received(2)
        assert peer.packets[1] == [0xAA, 0x55, 'EOP'], peer.packets
        peer.send([('DATA', 0x5A), 'EEP'])
        await self.clocks(60 * BIT)
        assert await self.fifo() == [0x5A, E, 1]
        assert await self.lost() == lost and len(peer.errors) == 1

        self.log("the other end is switched off, and on again")
        peer.enabled = False
        peer._enter('ErrorReset', 'switched off')
        await self.clocks(4 * self.TIMEOUT)
        assert await self.lost() == lost + 1 and await bench.curr_state() == self.FIRST
        await self.clocks(10 * BIT)
        assert await bench.curr_state(1) == 0                                 # the transmitter stopped too
        uo = int(dut.uo_out.value)
        assert (uo >> 1) & 3 == 0
        mark = peer.clock
        peer.enabled = True
        await up(200, mark)
        await self.clocks(20 * BIT)
        assert await self.credit() == 2 and await self.lost() == lost + 1, (await self.credit(), await self.lost(), peer.history[-6:])

        self.log("links lost at every point of a NULL: the next one always forms")
        for k in range(1, 9):
            await self.clocks((8 * 3 + k) * BIT - (peer.clock % (8 * BIT)))   # a different bit of the NULL each time
            mark = peer.clock
            peer.enabled = False
            peer._enter('ErrorReset', 'switched off')
            await self.clocks(4 * self.TIMEOUT)
            peer.enabled = True
            await up(200, mark)
            await self.clocks(20 * BIT)
            assert await self.credit() == 2, (k, await self.credit(), peer.history[-6:])
        assert len([e for e in peer.errors if e[2] != 'disconnect']) == 0, peer.errors

        peer.stop()
        await self.unload()


class SwdHostTest(PrismTest):
    ''' SWD host against a target model: the line reset, DPIDR, registers
        written and read back, a WAIT and a FAULT (no data phase), a target
        that is not there, a write with the wrong parity, a request the
        target does not answer; the clocks of every operation counted and
        the line never driven from both ends. '''
    name = "swd_host Chroma (Serial Wire Debug)"
    HALF = int(os.environ.get("SWD_HALF", 3))        # SWCLK half period in clocks

    async def run(self):
        tqv, bench, dut, HALF = self.tqv, self.bench, self.dut, self.HALF
        T = SwdTarget
        await tqv.write_byte_reg(REG_HOST, 0x00)
        target = self.start(SwdTarget(dut))
        await tqv.write_word_reg(REG_CFG1, 8)                                 # in_prev0 <- host_in[0]
        await tqv.write_word_reg(REG_CFG2, (10 << 4) | (11 << 8) | (12 << 12))   # inputs 17-19 = comm[5], [6], [7]: the ACK
        await tqv.write_word_reg(REG_CONST, 0x2002FF00)                       # K3 32, K2 2, K1 0xFF
        await tqv.write_word_reg(REG_PRELOAD, HALF - 1)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: the bytes to send
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        sync = int(os.environ.get("SWD_SYNC", 0))                            # CFG0[19:18]: 0 = two flops, 1 = one, 2 = raw
        await bench.load_chroma(chroma_swd_host, chroma_swd_host_ctrlReg | (sync << 18), chroma_swd_host_pinmuxReg)
        await tqv.write_byte_reg(REG_COMM, 0xFF)                              # the line idles high
        self.host = 0
        await self.clocks(8)
        uo = int(dut.uo_out.value)
        assert (uo >> 1) & 7 == 0b111, bin(uo)                                # SWCLK high, SWDIO high and driven

        async def go(nbits, clocks):
            ''' Start what is set up and wait for its interrupt; the clocks it made '''
            before = target.clocks
            await tqv.write_byte_reg(REG_LIMIT3, nbits - 1)
            await tqv.write_byte_reg(REG_TOGGLE, 0)
            for _ in range(clocks * 2 * HALF // 8 + 60):
                if await bench.irq():
                    break
                await self.clocks(8)
            assert await bench.irq(), f"no interrupt, state {await bench.curr_state()}"
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            assert await bench.curr_state() == 0
            assert target.fights == 0, f"the line was driven from both ends in {target.fights} clocks"
            uo = int(dut.uo_out.value)
            assert (uo >> 1) & 7 == 0b111, bin(uo)                            # back to idle
            return target.clocks - before

        async def raw(value, nbits):
            await tqv.write_byte_reg(REG_COMPARE, 1)
            for k in range((nbits + 7) // 8):
                await tqv.write_byte_reg(REG_FIFO + SHARD1, (value >> (8 * k)) & 0xFF)
            made = await go(nbits, nbits)
            assert made == nbits, f"{made} clocks for {nbits} bits"
            assert fifo_count(await tqv.read_word_reg(REG_FIFO_ST)) == 0

        async def transfer(ap, read, addr, data=0, parity=None):
            ''' (ACK, data read or None, its parity ok); the clocks are checked against the ACK '''
            await tqv.write_byte_reg(REG_COMPARE, 0)
            if (self.host >> 1) != read:
                self.host = (self.host & 1) | (read << 1)
                host = await tqv.read_byte_reg(REG_HOST)
                await tqv.write_byte_reg(REG_HOST, (host & 1) | (read << 1))
            await tqv.write_byte_reg(REG_FIFO + SHARD1, T.request(ap, read, addr))
            if not read:
                for k in range(4):
                    await tqv.write_byte_reg(REG_FIFO + SHARD1, (data >> (8 * k)) & 0xFF)
                await tqv.write_byte_reg(REG_FIFO + SHARD1, T.parity(data) if parity is None else parity)
            made = await go(8, 46)
            got = [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(await tqv.read_word_reg(REG_FIFO_ST)))]
            ack = got[0] >> 5
            assert made == (46 if ack == T.OK else 13), f"{made} clocks, ACK {ack}"
            left = fifo_count(await tqv.read_word_reg(REG_FIFO_ST + SHARD1))
            if ack == T.OK and read:
                assert len(got) == 6 and left == 0, (got, left)
                value = sum(b << (8 * k) for k, b in enumerate(got[1:5]))
                return ack, value, (got[5] >> 7) == T.parity(value)
            assert len(got) == 1, got
            assert left == (0 if ack == T.OK or read else 5), left           # the data of a write not made stays
            if left:
                await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
            return ack, None, None

        self.log("line reset: 56 ones, 8 idle clocks")
        await raw((1 << 56) - 1, 64)
        assert target.resets == 1 and target.state == 'idle'

        self.log("DPIDR")
        ack, value, ok = await transfer(0, 1, 0x0)
        assert (ack, value, ok) == (T.OK, target.dpidr, True), (ack, hex(value or 0), ok)

        self.log("SELECT and CTRL/STAT written, CTRL/STAT read back")
        assert (await transfer(0, 0, 0x8, 0x000000F0))[0] == T.OK
        assert (await transfer(0, 0, 0x4, 0x50000000))[0] == T.OK
        assert target.reg[8] == 0x000000F0 and target.reg[4] == 0x50000000
        assert target.log[-2:] == [('W', 0, 8, 0x000000F0, True), ('W', 0, 4, 0x50000000, True)], target.log[-2:]
        assert await transfer(0, 1, 0x4) == (T.OK, 0x50000000, True)

        self.log("an AP register: every bit pattern, both parities")
        for value in (0x00000000, 0xFFFFFFFF, 0x00000001, 0x80000000, 0xA5A5A5A5, 0x12345678, 0xDEADBEEF):
            assert (await transfer(1, 0, 0xC, value))[0] == T.OK
            assert await transfer(1, 1, 0xC) == (T.OK, value, True), hex(value)

        self.log("WAIT and FAULT: no data")
        entries = len(target.log)
        for ack in (T.WAIT, T.FAULT):
            target.next_ack = ack
            assert await transfer(0, 1, 0x4) == (ack, None, None)
            target.next_ack = ack
            assert await transfer(0, 0, 0x4, 0x11111111) == (ack, None, None)
        assert len(target.log) == entries and target.reg[4] == 0x50000000
        assert await transfer(0, 1, 0x4) == (T.OK, 0x50000000, True)          # and the next one is answered

        self.log("a write with the wrong parity is not taken")
        assert (await transfer(0, 0, 0x4, 0x0F0F0F0F, parity=1))[0] == T.OK
        assert target.log[-1] == ('W', 0, 4, 0x0F0F0F0F, False) and target.reg[4] == 0x50000000

        self.log("a request with the wrong parity is not answered: the ACK reads as 7")
        bad = target.bad
        await tqv.write_byte_reg(REG_COMPARE, 0)
        await tqv.write_byte_reg(REG_FIFO + SHARD1, T.request(0, 1, 0x0) ^ 0x20)
        made = await go(8, 46)
        assert made == 13 and target.bad == bad + 1
        assert [await tqv.read_byte_reg(REG_FIFO)][0] >> 5 == 7
        await raw((1 << 56) - 1, 64)                                          # the way back
        assert target.resets == 2
        assert await transfer(0, 1, 0x0) == (T.OK, target.dpidr, True)

        self.log("no target")
        target.present = False
        assert (await transfer(0, 1, 0x0))[0] == 7
        target.present = True

        self.log("nothing to send: no clock")
        await tqv.write_byte_reg(REG_COMPARE, 1)
        assert await go(8, 8) == 0
        assert target.fights == 0
        await bench.disable()
        dut.ui_in[2].value = 0


class VgaPinsTest(PrismTest):
    ''' The output pin changes for a VGA chroma (2026-09-30): uo_out[0] is in
        the pinmux (PINMUX[23:21]; TinyQV's GPIO output function select routes
        the pin, the bench routes all eight to the PRISM) and the multi-bit
        shift window is six lanes wide (comm[base+5:base], 3-bit lane per pin),
        so an RGB222 byte in comm[5:0] can drive the Tiny VGA PMOD's six
        colour pins at once: R1 G1 B1 on uo_out[2:0], R0 G0 B0 on uo_out[6:4],
        the syncs on uo_out[3] and uo_out[7] from pin_out bits.  The pio chroma
        is loaded only to have a running shard; comm is written by the host. '''
    name = "VGA pins (uo_out[0] in the pinmux, six comm lanes)"

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        COLOUR = ((0, 5), (1, 4), (2, 3), (4, 2), (5, 1), (6, 0))                 # (uo_out pin, comm bit)
        pinmux = PINMUX(*[(uo, 6) for uo, _ in COLOUR], (3, 0), (7, 1))         # colour lanes, syncs = pin_out[0] / [1]
        await bench.load_chroma(chroma_pio, chroma_pio_ctrlReg | CFG_MSHIFT_EN, pinmux)
        assert await tqv.read_word_reg(REG_PINMUX) == pinmux                    # 24 bits read back
        await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS(*COLOUR))
        assert await tqv.read_word_reg(REG_COMM_PINS) == COMM_PINS(*COLOUR)

        def expect(comm):
            uo = 0
            for pin, bit in COLOUR:
                uo |= ((comm >> bit) & 1) << pin
            return uo                                                            # pin_out[1:0] are 0 in state 0

        self.log("six colour lanes follow comm, the sync pins stay at their pin_out bits")
        for comm in (0x00, 0x3F, 0x15, 0x2A, 0x07, 0x38, 0xFF, 0xC0):
            await tqv.write_byte_reg(REG_COUNT2 + 2, comm)                       # COUNTS lane 2 = comm
            await self.clocks(3)
            uo = int(dut.uo_out.value)
            assert uo == expect(comm), (hex(comm), bin(uo), bin(expect(comm)))

        self.log("window base 2: the lanes move up two bits; lanes 6 and 7 read 0")
        await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS((0, 7), (1, 6), (2, 5), (4, 4), (5, 3), (6, 2)))
        await tqv.write_byte_reg(REG_COUNT2 + 2, 0xA4)                           # comm[7:2] = 101001
        await self.clocks(3)
        assert int(dut.uo_out.value) == 0b0100_0101, bin(int(dut.uo_out.value))  # pins 0..2 = 1,0,1; 4..6 = 0,0,1
        await tqv.write_word_reg(REG_COMM_PINS, 2 | (6 << 4) | (7 << 7))         # pins 0 / 1 name lanes 6 / 7
        await self.clocks(3)
        assert int(dut.uo_out.value) & 0b11 == 0

        self.log("pin 0 not driven (code 7) reads 0; a 21-bit pinmux word leaves it on pin_out[0]")
        await tqv.write_word_reg(REG_PINMUX, PINMUX(*[(uo, 6) for uo, _ in COLOUR], (0, 7), (3, 0), (7, 1)))
        await tqv.write_word_reg(REG_COMM_PINS, COMM_PINS(*COLOUR))
        await tqv.write_byte_reg(REG_COUNT2 + 2, 0x3F)
        await self.clocks(3)
        assert int(dut.uo_out.value) == expect(0x3F) & ~1
        await tqv.write_word_reg(REG_PINMUX, chroma_pio_pinmuxReg)               # the chroma's own 21-bit value
        assert await tqv.read_word_reg(REG_PINMUX) == chroma_pio_pinmuxReg
        await self.clocks(3)
        assert int(dut.uo_out.value) & 1 == 0                                    # pin_out[0] of state 0


class VgaTest(PrismTest):
    ''' The VGA pair (2026-09-30): chroma_vga_ln in shard 0 (vertical timing:
        VSync on uo_out[3], the active-lines flag to shard 1 over input 26,
        lines counted from shard 1's per-line semaphore) and chroma_vga_px in
        shard 1 (a line of 160 pixel bytes popped from FIFO B into comm, each
        held 12 clocks, the six colour lanes on uo_out[6:4] / [2:0], HSync on
        uo_out[7], front porch / sync / back porch from timer 2, the counter
        mode and count3).  640x480 timing at three clocks per pixel: 2400
        clocks per line; the test shortens the frame to a few lines with the
        host constants and checks the line timing, the pixel data, black in
        the blanking and the vertical structure over two frames. '''
    name = "vga Chromas (pixel + line shards, fractured)"

    A_LINES, K1, K2, K3 = 4, 1, 2, 4                # active lines; blanking = K3 + 3 lines, vsync 2 lines
    LINE = 2400                                     # clocks per line
    UNIT = 12                                       # clocks per pixel byte (four pixels)
    BYTES = 160

    async def run(self):
        tqv, bench, dut = self.tqv, self.bench, self.dut
        A, K1, K2, K3 = self.A_LINES, self.K1, self.K2, self.K3
        BLANK = K3 + 3
        FRAME = A + BLANK

        await bench.load_fractured(chroma_vga_ln, chroma_vga_ln_ctrlReg, chroma_vga_ln_pinmuxReg,
                                   chroma_vga_px, chroma_vga_px_ctrlReg | CFG_FIFO_SRAM, chroma_vga_px_pinmuxReg)
        await bench.disable()
        fp_si = can.state_with_default_output(chroma_vga_px, 12)               # FP: the state presetting the counter
        # shard 1, the pixel shard
        await tqv.write_word_reg(REG_PRELOAD + SHARD1, self.UNIT - 1)          # count1: the 12-clock unit, free-running
        await tqv.write_byte_reg(REG_COMPARE + SHARD1, self.BYTES - 1)         # count2: the last pop
        await tqv.write_word_reg(REG_CFG3 + SHARD1, CFG3_CNT_EN)               # the CRC register counts hsync units
        await tqv.write_word_reg(REG_CRC_EXP + SHARD1, 23)                     # 24 units of hsync
        await tqv.write_byte_reg(REG_COUNT3 + SHARD1 + 1, 10)                  # count3 limit: 11 units of back porch + the ST_LINE unit
        await tqv.write_word_reg(REG_PRELOAD2 + SHARD1, 47 | T2_RELOAD | T2_STATE(fp_si) | T2_ONESHOT)   # 48-clock front porch
        await tqv.write_word_reg(REG_CONST + SHARD1, 0)                        # K0 = black
        await tqv.write_word_reg(REG_COMM_PINS + SHARD1, COMM_PINS((0, 5), (1, 4), (2, 3), (4, 2), (5, 1), (6, 0)))
        await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
        # shard 0, the line shard
        await tqv.write_word_reg(REG_CFG3, CFG3_CNT_EN)
        await tqv.write_word_reg(REG_CRC, 0)                                   # line counter preset
        await tqv.write_word_reg(REG_CRC_EXP, A - 1)
        await tqv.write_word_reg(REG_CONST, (K3 << 24) | (K2 << 16) | (K1 << 8))

        # two frames of pixels, no byte 0 so the active window is visible
        data = [[((ln * 37 + i * 11) % 63) + 1 for i in range(self.BYTES)] for ln in range(2 * A)]
        for line in data:
            for b in line:
                await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x3FFF == 2 * A * self.BYTES

        colour, hsync, vsync = [], [], []
        async def watch():
            while True:
                await FallingEdge(dut.clk)
                uo = int(dut.uo_out.value)
                c = 0
                for pin, bit in ((0, 5), (1, 4), (2, 3), (4, 2), (5, 1), (6, 0)):
                    c |= ((uo >> pin) & 1) << bit
                colour.append(c)
                hsync.append((uo >> 7) & 1)
                vsync.append((uo >> 3) & 1)
        w = cocotb.start_soon(watch())
        await bench.enable()
        await self.clocks(2 * FRAME * self.LINE + 3 * self.LINE)
        w.kill()

        falls = [i for i in range(1, len(hsync)) if hsync[i - 1] and not hsync[i]]
        rises = [i for i in range(1, len(hsync)) if not hsync[i - 1] and hsync[i]]
        periods = [b - a for a, b in zip(falls, falls[1:])]
        widths = [next(r for r in rises if r > f) - f for f in falls[:-1]]
        self.log(f"hsync: {len(falls)} pulses, periods {sorted(set(periods))}, widths {sorted(set(widths))}")
        assert periods[1:] and all(p == self.LINE for p in periods[1:]), periods
        assert all(wd == 24 * self.UNIT - 1 for wd in widths), widths           # 24 units, less the clock the exit leg takes

        # the active window of every line, from its hsync's rising edge
        starts = []
        for f, nf in zip(falls, falls[1:]):
            r = next(r for r in rises if r > f)
            seg = colour[r:nf]
            nz = [i for i, c in enumerate(seg) if c]
            starts.append((r + nz[0] - r, r + nz[-1] + 1 - r) if nz else None)
        active = [s is not None for s in starts]
        self.log(f"lines after each hsync: {''.join('P' if a else '.' for a in active)}")
        vs_low = [i for i in range(1, len(vsync)) if vsync[i - 1] and not vsync[i]]
        vs_high = [i for i in range(1, len(vsync)) if not vsync[i - 1] and vsync[i]]
        self.log(f"vsync falls at {vs_low}, rises at {vs_high}")

        self.log("pixels: each active line is the 160 pushed bytes, 12 clocks each, black elsewhere")
        spans, i = [], 0
        while i < len(colour):
            if colour[i]:
                j = i
                while j < len(colour) and colour[j]:
                    j += 1
                spans.append((i, j))
                i = j
            else:
                i += 1
        assert len(spans) >= 2 * A, len(spans)
        for ln, (s, e) in enumerate(spans[:2 * A]):
            assert e - s == self.BYTES * self.UNIT, (ln, s, e)
            got = [colour[s + i * self.UNIT + 6] for i in range(self.BYTES)]
            assert got == [b & 0x3F for b in data[ln]], (ln, got[:8], data[ln][:8])
            prev_falls = [f for f in falls if f < s]
            if prev_falls:                                                     # not the first line after enable
                r = next(r for r in rises if r > prev_falls[-1])
                assert s - r == 12 * self.UNIT, (ln, s - r)                    # back porch: 12 units exactly
        assert all(colour[s - 1] == 0 and colour[e] == 0 for s, e in spans[:2 * A])

        self.log("frames: A active lines, then K3 + 3 blank ones; vsync low for two lines after K1 + 1 blank ones")
        runs = []
        for a in active:
            if runs and runs[-1][0] == a:
                runs[-1][1] += 1
            else:
                runs.append([a, 1])
        assert runs[0] == [True, A - 1], runs                                  # the first line precedes the first hsync
        assert runs[1] == [False, BLANK], runs
        assert runs[2] == [True, A], runs
        assert runs[3] == [False, BLANK], runs
        vs_high = [r for r in vs_high if r > vs_low[0]]                        # the pin's reset value is 0: ignore the first rise
        assert len(vs_low) >= 2 and len(vs_high) >= 2
        assert vs_high[0] - vs_low[0] == 2 * self.LINE, (vs_low, vs_high)
        assert vs_low[1] - vs_low[0] == FRAME * self.LINE, (vs_low, vs_high)
        # the falling edge sits at hsync number A + K1 + 1 (falls[0] is the first line's), two clocks after the semaphore
        assert 0 <= vs_low[0] - falls[A + K1] <= 4, (vs_low[0], falls[A + K1])


class Ps2HostTest(PrismTest):
    ''' PS/2 host against a device model: bytes from the device (every
        parity), a wrong parity, a wrong stop bit, a frame that stops (the
        time-out), a glitch on CLK; commands to the device with its
        acknowledge and its 0xFA reply, a device that does not acknowledge,
        no device at all (timer 2), and a command while the device sends. '''
    name = "ps2_host Chroma (PS/2 keyboard / mouse port)"
    HALF = 32                                         # the device's half clock period, in clocks
    TIMEOUT = 256                                     # CLK low for a request; no clock inside a frame
    FIRST = 2000                                      # the device's first clock after a request

    async def run(self):
        tqv, bench, dut, HALF = self.tqv, self.bench, self.dut, self.HALF
        await tqv.write_byte_reg(REG_HOST, 0x00)
        dev = self.start(Ps2Device(dut, HALF, hold=100, first=300, reply=0xFA))
        wait1 = can.state_with_default_output(chroma_ps2_host, 2)             # the state that drives pin_out[2]
        await tqv.write_word_reg(REG_CFG1, 8)                                 # in_prev0 <- host_in[0]
        await tqv.write_word_reg(REG_CFG2, 15 << 4)                           # input 17 = edge pending
        await tqv.write_word_reg(REG_CFG3, CFG3_SMP_EN | CFG3_SMP_SRC(2) | CFG3_SMP_FALL | CFG3_SMP_TIMER)
        await tqv.write_word_reg(REG_CRC_POLY, 0x80)                          # CRC8 with x^8 + x^7: the parity
        await tqv.write_word_reg(REG_CRC_EXP, 0x80)                           # odd
        await tqv.write_word_reg(REG_PRELOAD, self.TIMEOUT - 1)
        await tqv.write_word_reg(REG_PRELOAD2, (self.FIRST - 1) | T2_RELOAD | T2_STATE(wait1) | T2_ONESHOT)
        await tqv.write_byte_reg(REG_COUNT3, 0)
        await tqv.write_word_reg(REG_FIFO_ST, 0)
        await bench.load_chroma(chroma_ps2_host, chroma_ps2_host_ctrlReg, chroma_ps2_host_pinmuxReg)
        FRAME = 11 * 2 * HALF

        async def fifo():
            return [await tqv.read_byte_reg(REG_FIFO) for _ in range(fifo_count(await tqv.read_word_reg(REG_FIFO_ST)))]

        async def errors():
            return await tqv.read_byte_reg(REG_COUNT3)

        async def idle():
            assert await bench.curr_state() == 0
            assert (int(dut.uo_out.value) >> 1) & 3 == 0                      # both lines released

        async def from_device(values, clocks=None):
            dev.send(*values)
            await self.clocks(clocks or len(values) * (FRAME + 4 * HALF) + 200)
            return await fifo()

        async def command(value, clocks=None):
            ''' Send it; True if the interrupt came without an error '''
            before = await errors()
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            parity = (bin(value).count('1') + 1) & 1
            await tqv.write_word_reg(REG_CONST, (parity << 8) | value)
            await tqv.write_byte_reg(REG_TOGGLE, 0)
            await self.clocks(clocks or self.TIMEOUT + 300 + FRAME + 400)
            assert await bench.irq()
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            return await errors() == before

        self.log("bytes from the device, every parity")
        await self.clocks(100)
        await idle()
        values = [0x1C, 0xF0, 0x00, 0xFF, 0x01, 0x80, 0xAA, 0x55]
        got = await from_device(values)
        assert got == values, [hex(v) for v in got]
        assert await bench.irq() and await errors() == 0
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("a wrong parity, a wrong stop bit: nothing in the FIFO")
        for what in ('bad_parity', 'bad_stop'):
            setattr(dev, what, True)
            before = await errors()
            assert await from_device([0x5A]) == []
            assert await errors() == before + 1 and await bench.irq()
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            assert await from_device([0x5B]) == [0x5B]                        # and the next one is taken
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("a frame that stops after 6 bits: the time-out")
        dev.cut = 6
        before = await errors()
        assert await from_device([0x77], clocks=6 * 2 * HALF + self.TIMEOUT + 300) == []
        assert await errors() == before + 1 and await bench.irq()
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
        await idle()
        assert await from_device([0x78]) == [0x78]
        await tqv.write_byte_reg(REG_INT_CLR0, 0x80)

        self.log("a glitch on CLK with DATA high is not a start bit")
        before = await errors()
        dev.clk_low = 1
        await self.clocks(6)
        dev.clk_low = 0
        await self.clocks(200)
        assert await fifo() == [] and await errors() == before and not await bench.irq()
        await idle()

        self.log("commands to the device: acknowledged, and its 0xFA comes back")
        for value in (0xED, 0x02, 0xF4, 0x00, 0xFF):
            assert await command(value), hex(value)
            assert dev.received[-1] == (value, True), dev.received[-1]
            assert dev.holds[-1] >= self.TIMEOUT, dev.holds[-1]              # CLK was held for the whole time-out
            await self.clocks(FRAME + 8 * HALF)
            assert await fifo() == [0xFA]
            await tqv.write_byte_reg(REG_INT_CLR0, 0x80)
            await idle()

        self.log("a device that does not acknowledge")
        dev.ack = False
        dev.reply = None
        assert not await command(0xF5)
        assert dev.received[-1] == (0xF5, True)
        dev.ack = True
        await idle()

        self.log("no device: the first clock never comes")
        dev.present = False
        taken = len(dev.received)
        assert not await command(0xF2, clocks=self.TIMEOUT + self.FIRST + 400)
        assert len(dev.received) == taken
        await idle()
        dev.present = True

        self.log("a command asked for while the device sends: its byte first")
        dev.send(0x2A)
        await self.clocks(5 * 2 * HALF)                                       # in the middle of the frame
        assert await command(0xEE, clocks=FRAME + self.TIMEOUT + 300 + FRAME + 600)
        assert dev.received[-1] == (0xEE, True)
        assert await fifo() == [0x2A]
        await bench.disable()
        await tqv.write_word_reg(REG_CFG3, 0)
        await tqv.write_word_reg(REG_CFG2, 0)
        await tqv.write_word_reg(REG_PRELOAD2, 0)
        dut.ui_in[2].value = 0
        dut.ui_in[3].value = 0
