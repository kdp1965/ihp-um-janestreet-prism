# PRISM peripheral unit tests (cocotb).  One cocotb test per subject; each
# resets the shared bench (bench.py) and runs one PrismTest class from
# prism_tests.py.  Run all with `make prism.test` in test/, or one with
# `TESTCASE=test_usb_device MODULE=user_peripherals.prism.test make -f test_basic.mk`.
# PRISM_TRACE=1 logs every state change of shard 0 (PRISM_TRACE_MAX=n).

import cocotb

from user_peripherals.prism.bench import PrismBench
from user_peripherals.prism.prism_tests import (
    RegisterTest, StewIntegrityTest, EncoderTest, Ws2812Test, Gpio24Test,
    SpiSlaveTest, UartTxTest, FifoLoopTest, SramFifoTest, EdgeTest, UsbDeviceTest, EthernetTxTest, EthernetRxTest, EthernetLoopTest, FracturedTest,
    TraceTest, Timer2Test, ConstTableTest)


async def run(dut, test_class):
    bench = await PrismBench.get(dut)
    await bench.reset()
    await test_class(bench).execute()


@cocotb.test()
async def test_registers(dut):
    await run(dut, RegisterTest)

@cocotb.test()
async def test_stew_integrity(dut):
    await run(dut, StewIntegrityTest)

@cocotb.test()
async def test_encoder(dut):
    await run(dut, EncoderTest)

@cocotb.test()
async def test_ws2812(dut):
    await run(dut, Ws2812Test)

@cocotb.test()
async def test_gpio24(dut):
    await run(dut, Gpio24Test)

@cocotb.test()
async def test_spislave(dut):
    await run(dut, SpiSlaveTest)

@cocotb.test()
async def test_uart_tx(dut):
    await run(dut, UartTxTest)

@cocotb.test()
async def test_fifo_loop(dut):
    await run(dut, FifoLoopTest)

@cocotb.test()
async def test_sram_fifo(dut):
    await run(dut, SramFifoTest)

@cocotb.test()
async def test_edge(dut):
    await run(dut, EdgeTest)

@cocotb.test()
async def test_usb_device(dut):
    await run(dut, UsbDeviceTest)

@cocotb.test()
async def test_ethernet_tx(dut):
    await run(dut, EthernetTxTest)

@cocotb.test()
async def test_ethernet_rx(dut):
    await run(dut, EthernetRxTest)

@cocotb.test()
async def test_ethernet_loop(dut):
    await run(dut, EthernetLoopTest)

@cocotb.test()
async def test_fractured(dut):
    await run(dut, FracturedTest)

@cocotb.test()
async def test_trace(dut):
    await run(dut, TraceTest)

@cocotb.test()
async def test_timer2(dut):
    await run(dut, Timer2Test)

@cocotb.test()
async def test_const_table(dut):
    await run(dut, ConstTableTest)
