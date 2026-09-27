# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/ethtx_verify (fetched from the simulated
# QSPI flash, data in PSRAM A), which sends 10BASE-T frames from PSRAM: the
# TX DMA copies each frame from a slot of RAM B into FIFO B (SRAM[1]) and
# the eth_tx chroma, fractured on shard 1, puts it on uo_out[1] (TXD) with
# uo_out[2] (TX_EN).  The program reports over the debug UART and announces
# every frame with an "ETH FRAME len=N seed=SS" line; this side decodes the
# line with eth_model.EthDecoder, checks each frame byte for byte (preamble,
# SFD, frame, FCS) and that TX_EN stays low for at least the 96-bit
# inter-frame gap between frames.
#
#   make -f test_prog.mk PROG=ethtx_verify        (or: make ethtx_verify)

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
BIT = 6                                # clocks per bit (the chroma's half-bit timer: 3)
IFG_BITS = 96
TX_EN = 2


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
    """The program's eth_byte(): broadcast destination, source
       02:00:00:00:00:seed, EtherType 0x88B5, then a pattern (no FCS)."""
    head = [0xFF] * 6 + [0x02, 0, 0, 0, 0, seed & 0xFF] + [0x88, 0xB5]
    return head + [(seed + i * 13 + (i >> 4)) & 0xFF for i in range(14, n)]


async def gap_monitor(dut, gaps):
    """Clocks TX_EN stays low between the end of one frame and the next."""
    low = None
    prev = int(dut.uo_out.value) >> TX_EN & 1
    while True:
        await RisingEdge(dut.clk)
        en = int(dut.uo_out.value) >> TX_EN & 1
        if prev and not en:
            low = 0
        elif not en and low is not None:
            low += 1
        elif en and not prev and low is not None:
            gaps.append(low)
        prev = en


@cocotb.test()
async def test_ethtx_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    dec = None
    gaps = []
    expected = []
    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line == "ETH READY":
            # the chroma owns the pins from here on: TX_EN must be low
            assert (int(dut.uo_out.value) >> TX_EN & 1) == 0, "TX_EN high before the first frame"
            dec = eth.EthDecoder(dut, BIT)
            dec.start()
            cocotb.start_soon(gap_monitor(dut, gaps))
        m = re.match(r"ETH FRAME len=(\d+) seed=([0-9A-F]{2})$", line)
        if m:
            expected.append(eth_frame(int(m.group(1)), int(m.group(2), 16)))
        if line.startswith("ETHTX_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "ETHTX_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    assert dec is not None, "the program never got ready"
    dec.stop()
    dut._log.info(f"line: {len(dec.frames)} frames of {[len(f) for f in dec.frames]} bytes, "
                  f"{dec.pulses} link pulses, gaps {gaps} clocks")
    assert len(dec.frames) == len(expected), f"{len(dec.frames)} frames on the line, {len(expected)} announced"
    for k, (got, frame) in enumerate(zip(dec.frames, expected)):
        want = [0x55] * 7 + [0xD5] + frame + eth.crc32(frame)
        bad = [i for i, (a, b) in enumerate(zip(got, want)) if a != b]
        assert got == want, (f"frame {k + 1}: {len(got)} bytes on the line, {len(want)} expected, "
                             f"first differences at {bad[:6]}")
    assert dec.pulses == 0, "link pulses with the timer off"
    assert gaps and min(gaps) >= IFG_BITS * BIT, f"inter-frame gaps {gaps} clocks, {IFG_BITS * BIT} needed"
