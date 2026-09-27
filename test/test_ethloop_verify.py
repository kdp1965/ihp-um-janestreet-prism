# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/ethloop_verify (fetched from the simulated
# QSPI flash, data in PSRAM A), a 10BASE-T loopback from PSRAM to PSRAM:
# TX DMA -> FIFO B (SRAM[1]) -> eth_tx (shard 1) -> uo_out[1] / uo_out[2] ->
# this bench's wire -> ui_in[3] -> recoverer + eth_rx (shard 0) -> FIFO A ->
# RX DMA -> RX ring in RAM B.  The program compares every received frame with
# its source and checks the receiver's CRC; this side closes the wire (TXD
# while TX_EN, else idle low) and decodes the line to cross-check the frames
# announced with "ETH FRAME len=N seed=SS".
#
#   make -f test_prog.mk PROG=ethloop_verify        (or: make ethloop_verify)

import os
import re
import sys

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, First
from test_util import reset

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "user_peripherals", "prism"))
import eth_model as eth                                     # noqa: E402

CLK_PERIOD_NS = 15.624                 # 64 MHz
DEBUG_UART_BIT_NS = CLK_PERIOD_NS * 16 # debug UART is 4 Mbaud at 64 MHz
CHAR_TIMEOUT_NS = 40_000_000           # 40 ms of silence = program is stuck
BIT = 6                                # clocks per bit
TXD, TX_EN, RXD = 1, 2, 3              # uo_out[1], uo_out[2], ui_in[3]


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


def eth_frame(n, seed):
    """The program's eth_byte() (see ethtx_verify), no FCS."""
    head = [0xFF] * 6 + [0x02, 0, 0, 0, 0, seed & 0xFF] + [0x88, 0xB5]
    return head + [(seed + i * 13 + (i >> 4)) & 0xFF for i in range(14, n)]


async def wire(dut):
    """The twisted pair: TXD while TX_EN is high, else idle low, onto ui_in[3]."""
    while True:
        await RisingEdge(dut.clk)
        try:
            v = int(dut.uo_out.value)
        except ValueError:
            continue
        rxd = (v >> TXD) & 1 if (v >> TX_EN) & 1 else 0
        base = int(dut.ui_in_base.value)
        new = (base | (1 << RXD)) if rxd else (base & ~(1 << RXD))
        if new != base:
            dut.ui_in_base.value = new


@cocotb.test()
async def test_ethloop_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    dec = None
    expected = []
    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line == "ETH READY":
            assert (int(dut.uo_out.value) >> TX_EN & 1) == 0, "TX_EN high before the first frame"
            cocotb.start_soon(wire(dut))
            dec = eth.EthDecoder(dut, BIT, txd=TXD, tx_en=TX_EN)
            dec.start()
        m = re.match(r"ETH FRAME len=(\d+) seed=([0-9A-F]{2})$", line)
        if m:
            expected.append(eth_frame(int(m.group(1)), int(m.group(2), 16)))
        if line.startswith("ETHLOOP_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "ETHLOOP_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    assert dec is not None, "the program never got ready"
    dec.stop()
    dut._log.info(f"line: {len(dec.frames)} frames of {[len(f) for f in dec.frames]} bytes, {dec.pulses} link pulses")
    assert len(dec.frames) == len(expected), f"{len(dec.frames)} frames on the line, {len(expected)} announced"
    for k, (got, frame) in enumerate(zip(dec.frames, expected)):
        assert got == [0x55] * 7 + [0xD5] + frame + eth.crc32(frame), f"frame {k + 1} differs on the line"
    assert dec.pulses == 0, "link pulses with the timer off"
