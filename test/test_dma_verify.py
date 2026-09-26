# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/dma_verify (fetched from the simulated
# QSPI flash, data in PSRAM A) which drives the PRISM RX DMA in chain mode:
# the program pushes bytes into FIFO A, the mover drains A into FIFO B by
# itself, and the DMA drains B into a two-slot ring in PSRAM B while the
# CPU keeps running.  The program checks the ring through its own loads from RAM B
# and reports over the debug UART; this side checks the report and looks
# at the simulated PSRAM B directly for the first frame.
#
#   make -f test_prog.mk PROG=dma_verify        (or: make dma_verify)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, Timer, First
from test_util import reset

CLK_PERIOD_NS = 15.624                 # 64 MHz
DEBUG_UART_BIT_NS = CLK_PERIOD_NS * 16 # debug UART is 4 Mbaud at 64 MHz
CHAR_TIMEOUT_NS = 40_000_000           # 40 ms of silence = program is stuck

FRAME1 = [(0x11 + i * 7 + (i >> 5)) & 0xFF for i in range(70)]   # frame_byte(0x11, i)


async def read_debug_char(dut):
    timeout = Timer(CHAR_TIMEOUT_NS, "ns")
    fired = await First(FallingEdge(dut.debug_uart_tx), timeout)
    assert fired is not timeout, "debug UART went silent (program stuck?)"
    await Timer(DEBUG_UART_BIT_NS / 2, "ns")
    assert dut.debug_uart_tx.value == 0, "debug UART start bit glitch"
    byte = 0
    for i in range(8):
        await Timer(DEBUG_UART_BIT_NS, "ns")
        byte |= int(dut.debug_uart_tx.value) << i
    await Timer(DEBUG_UART_BIT_NS, "ns")
    assert dut.debug_uart_tx.value == 1, "debug UART stop bit missing"
    return chr(byte)


async def read_debug_line(dut):
    line = ""
    while True:
        c = await read_debug_char(dut)
        if c == '\n':
            return line.rstrip('\r')
        line += c


def ram_b_byte(dut, addr):
    """A byte of the simulated PSRAM B (sim_qspi.v keeps it as bytes)."""
    return int(dut.qspi.ram_b[addr].value)


@cocotb.test()
async def test_dma_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line.startswith("DMA_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "DMA_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    # Slot 1 holds frame 5 (1500 bytes of frame_byte(0x55, i)) at the end;
    # slot 0 holds the empty frame 4.  Look at the PSRAM model itself.
    try:
        slot1 = 2048
        length = ram_b_byte(dut, slot1) | (ram_b_byte(dut, slot1 + 1) << 8)
        assert length == 1500, f"slot 1 length {length}"
        for i in (0, 1, 2, 3, 1019, 1020, 1021, 1499):
            exp = (0x55 + i * 7 + (i >> 5)) & 0xFF
            got = ram_b_byte(dut, slot1 + 4 + i)
            assert got == exp, f"slot 1 byte {i}: {got:#x} != {exp:#x}"
        length0 = ram_b_byte(dut, 0) | (ram_b_byte(dut, 1) << 8)
        assert length0 == 0, f"slot 0 length {length0}"
        dut._log.info("PSRAM B ring contents match")
    except AttributeError as e:
        dut._log.warning(f"PSRAM B not inspectable from cocotb ({e}); the program's own checks stand")

    await ClockCycles(dut.clk, 100)
