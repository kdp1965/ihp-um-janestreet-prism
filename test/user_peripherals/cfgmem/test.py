
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Edge

from tqv import TinyQV

PERIPHERAL_NUM = 4

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 16, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset
    await tqv.reset()

    dut._log.info("Testing CFGMEM")

    # Test register write and read back
    # Write a value to the config array 
    dut._log.info("Testing PRISM state information integrity")
    for i in range(1):
        for d in range(2):
            # Take CFGMEM lo out of bypass mode
            await tqv.write_byte_reg(0x1f, 0)

            # Write to CFGMEM lo #0
            await tqv.write_word_reg(i*4, 0x00008080)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00007070)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00006060)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00005050)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00004040)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00003030)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00002020)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4, 0x00001010)
            await ClockCycles(dut.clk, 32)

            # Put CFGMEM lo in bypass mode (control byte: [7] byp_hi [6] byp_lo [5] busy [4] addr_sel [3:0] addr)
            await tqv.write_byte_reg(0x1f, 0x40)

            # Write to CFGMEM hi #0
            await tqv.write_word_reg(i*4 + 0x20, 0x80808080)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x70707070)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x60606060)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x50505050)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x40404040)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x30303030)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x20202020)
            await ClockCycles(dut.clk, 32)
            await tqv.write_word_reg(i*4 + 0x20, 0x10101010)
            await ClockCycles(dut.clk, 32)
        

    # Wait for two clock cycles to see the output values, because ui_in is synchronized over two clocks,
    # and a further clock is required for the output to propagate.

    # Put CFGMEM hi in bypass mode
    await tqv.write_byte_reg(0x1f, 0x80)

    # 0x10101010 should be read back from register 8
    await tqv.write_byte_reg(0x1f, 0x80)
    assert await tqv.read_word_reg(0) == 0x1010
    await tqv.write_byte_reg(0x1f, 0x93)
    assert await tqv.read_word_reg(0) == 0x4040
    await tqv.write_byte_reg(0x1f, 0x9F)
    assert await tqv.read_word_reg(0) == 0x8080

    # Take CFGMEM hi out of bypass mode
    await tqv.write_byte_reg(0x1f, 0x1F)
    assert await tqv.read_word_reg(0x20) == 0x80808080
    await ClockCycles(dut.clk, 200)


