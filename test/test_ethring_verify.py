# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/ethring_verify, which drives the TX DMA's
# ring (frames back to back with no host work per frame) and checks the RX
# DMA's per-frame status (crc_ok in the slot header) over the 10BASE-T
# loopback of ethloop_verify, with 32 KB PSRAMs (SIM_RAM_BITS=15).  This side:
#   - closes the wire (TXD while TX_EN, else idle low, onto ui_in[3]);
#   - decodes the line and checks every announced frame ("ETH FRAME ...");
#   - checks that TX_EN stays low for the 96-bit inter-frame gap (and not
#     much more) between the ring burst's frames;
#   - on "ETH INJECT" takes the wire over and sends three frames straight
#     into ui_in[3] at the minimum gap, the second with a wrong FCS.
#
#   make ethring_verify   (or: make -f test_prog.mk PROG=ethring_verify SIM_RAM_BITS=15)

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
IFG = 96 * BIT                         # minimum inter-frame gap, clocks
IFG_SLACK = 300                        # the ring may start a little late (copy, arbitration)
BURST = 6                              # frames in the ring burst
TXD, TX_EN, RXD = 1, 2, 3              # uo_out[1], uo_out[2], ui_in[3]
INJECT = [(100, 0xA1, False), (80, 0xA2, True), (60, 0xA3, False)]   # (length, seed, bad FCS)


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


class BenchEncoder(eth.EthEncoder):
    """eth_model's encoder on tb_qspi, whose ui_in is a wire: drive ui_in_base."""

    def _drive(self, level):
        v = int(self.dut.ui_in_base.value)
        v = (v | (1 << self.rxd)) if level else (v & ~(1 << self.rxd))
        self.dut.ui_in_base.value = v


async def wire(dut, state):
    """The twisted pair, while the loop is closed: TXD while TX_EN, else idle low."""
    while True:
        await RisingEdge(dut.clk)
        if not state["loop"]:
            continue
        try:
            v = int(dut.uo_out.value)
        except ValueError:
            continue
        rxd = (v >> TXD) & 1 if (v >> TX_EN) & 1 else 0
        base = int(dut.ui_in_base.value)
        new = (base | (1 << RXD)) if rxd else (base & ~(1 << RXD))
        if new != base:
            dut.ui_in_base.value = new


async def inject(dut, state):
    """Three frames straight into ui_in[3], the minimum gap apart."""
    state["loop"] = False
    enc = BenchEncoder(dut, BIT, rxd=RXD)
    for n, seed, bad in INJECT:
        payload = eth_frame(n, seed)
        fcs = [b ^ 0xFF for b in eth.crc32(payload)] if bad else None
        await enc.frame(payload, fcs=fcs)                  # ends with TP_IDL and 4 bit times low
        await enc.idle(IFG - 4 * BIT)
    state["loop"] = True
    state["injected"] = True


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
async def test_ethring_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    state = {"loop": True, "injected": False}
    dec = None
    gaps = []
    expected = []
    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line == "ETH READY":
            assert (int(dut.uo_out.value) >> TX_EN & 1) == 0, "TX_EN high before the first frame"
            cocotb.start_soon(wire(dut, state))
            cocotb.start_soon(gap_monitor(dut, gaps))
            dec = eth.EthDecoder(dut, BIT, txd=TXD, tx_en=TX_EN)
            dec.start()
        if line == "ETH INJECT":
            cocotb.start_soon(inject(dut, state))
        m = re.match(r"ETH FRAME len=(\d+) seed=([0-9A-F]{2})$", line)
        if m:
            expected.append(eth_frame(int(m.group(1)), int(m.group(2), 16)))
        if line.startswith("ETHRING_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "ETHRING_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]
    assert state["injected"], "the injection never finished"

    assert dec is not None, "the program never got ready"
    dec.stop()
    dut._log.info(f"line: {len(dec.frames)} frames of {[len(f) for f in dec.frames]} bytes, "
                  f"{dec.pulses} link pulses, TX_EN low between frames {gaps} clocks")
    assert len(dec.frames) == len(expected), f"{len(dec.frames)} frames on the line, {len(expected)} announced"
    for k, (got, frame) in enumerate(zip(dec.frames, expected)):
        assert got == [0x55] * 7 + [0xD5] + frame + eth.crc32(frame), f"frame {k + 1} differs on the line"
    assert dec.pulses == 0, "link pulses with the timer off"
    burst_gaps = gaps[:BURST - 1]
    assert len(burst_gaps) == BURST - 1
    assert all(IFG <= g <= IFG + IFG_SLACK for g in burst_gaps), \
        f"ring burst gaps {burst_gaps} clocks, {IFG} to {IFG + IFG_SLACK} expected"
