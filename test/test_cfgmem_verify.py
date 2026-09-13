# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/cfgmem_verify (fetched from the
# simulated QSPI flash, data in the two simulated PSRAMs) which exercises
# the CFGMEM peripheral, loads the gpio24 chroma into the CFGMEM-backed
# PRISM state table and runs it.  This side models the 74165 (parallel-in
# serial-out, feeding ui_in[0]) and 74595 (serial-in parallel-out on
# uo_out[5]) the chroma drives, and checks the program's debug UART
# report line by line.
#
#   make -f test_prog.mk PROG=cfgmem_verify        (or: make cfgmem_verify)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer, First
from test_util import reset

CLK_PERIOD_NS = 15.624                 # 64 MHz
DEBUG_UART_BIT_NS = CLK_PERIOD_NS * 16 # debug UART is 4 Mbaud at 64 MHz
CHAR_TIMEOUT_NS = 20_000_000           # 20 ms of silence = program is stuck

INPUT_VALUE = 0x00BEEF                 # what the 74165 model presents
EXPECTED_OUTPUT = 0x00F05077           # what the program shifts out


def uo_out_int(dut):
    return int(dut.uo_out.value.binstr.replace('x', '0').replace('z', '0'), 2)


async def read_debug_char(dut):
    """Receive one 8N1 character from the debug UART on uo_out[6]."""
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


class Pmod74165:
    """Parallel-in / serial-out shift register: load on uo_out[1] low,
    shift on rising uo_out[7], Q7 drives ui_in[0]."""

    def __init__(self, dut, value):
        self.dut = dut
        self.value = value
        self.shift = value

    async def run(self):
        dut = self.dut
        prev = uo_out_int(dut)
        while True:
            await RisingEdge(dut.clk)
            cur = uo_out_int(dut)
            if (cur & 0x02) == 0:
                self.shift = self.value
            elif (prev ^ cur) & 0x80 and (cur & 0x80):
                self.shift = (self.shift << 1) & 0xFFFFFF
            else:
                prev = cur
                continue
            prev = cur
            dut.ui_in_base[0].value = (self.shift >> 23) & 1


class Pmod74595:
    """Serial-in / parallel-out shift register: shift uo_out[5] in on rising
    uo_out[7], transfer to the output latch while uo_out[2] is high."""

    def __init__(self, dut):
        self.dut = dut
        self.shift = 0
        self.output = None

    async def run(self):
        dut = self.dut
        prev = uo_out_int(dut)
        while True:
            await RisingEdge(dut.clk)
            cur = uo_out_int(dut)
            if cur & 0x04:
                self.output = self.shift
            elif (prev ^ cur) & 0x80 and (cur & 0x80):
                self.shift = ((self.shift << 1) | ((cur >> 5) & 1)) & 0xFFFFFF
            prev = cur


@cocotb.test()
async def test_cfgmem_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    piso = Pmod74165(dut, INPUT_VALUE)
    sipo = Pmod74595(dut)
    cocotb.start_soon(piso.run())
    cocotb.start_soon(sipo.run())

    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line.startswith("CFGMEM_VERIFY END"):
            break
        assert len(lines) < 400, "runaway program output"

    assert lines[0] == "CFGMEM_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    # The chroma must have shifted the preload word out into the 74595
    dut._log.info(f"74595 captured: {sipo.output:#08x}" if sipo.output is not None
                  else "74595 captured nothing")
    assert sipo.output == EXPECTED_OUTPUT, \
        f"74595 output {sipo.output} != {EXPECTED_OUTPUT:#x}"

    await ClockCycles(dut.clk, 100)
