# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/sdk_check, which drives the PRISM through
# the tinyQV-sdk driver built for this design (PRISM_CONFIG_JANESTREET).
# This side decodes the UART the uart_tx chroma emits on uo_out[1] (8N1,
# 64 clocks per bit) and checks the program's debug UART report.
#
#   make -f test_prog.mk PROG=sdk_check        (or: make sdk_check)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from test_util import reset
from test_cfgmem_verify import read_debug_line, uo_out_int, CLK_PERIOD_NS

BIT_PERIOD = 64
DATA = [0x55, 0xA3, 0x0F]


def crc8_lsb_first(data, poly=0x07):
    crc = 0
    for d in data:
        for b in range(8):
            fb = ((crc >> 7) & 1) ^ ((d >> b) & 1)
            crc = ((crc << 1) ^ (poly if fb else 0)) & 0xFF
    return crc


async def uart_rx(dut, rx_bytes):
    """8N1 receiver on uo_out[1], sampling mid-bit from the start edge.
    The line is low until the chroma is loaded (and after the fractured
    experiment), so a start bit only counts after an idle-high level and a
    frame with a bad stop bit is dropped."""
    idle = False
    while True:
        await RisingEdge(dut.clk)
        if uo_out_int(dut) & 0x2:
            idle = True
            continue
        if not idle:
            continue
        byte = 0
        ok = True
        for i in range(9):
            for k in range(BIT_PERIOD if i else BIT_PERIOD + BIT_PERIOD // 2):
                await RisingEdge(dut.clk)
            bit = (uo_out_int(dut) >> 1) & 1
            if i < 8:
                byte |= bit << i
            else:
                ok = bit == 1
        idle = False
        if ok:
            rx_bytes.append(byte)
        dut._log.info(f"UART RX: {byte:02X}" + ("" if ok else " (framing, dropped)"))


@cocotb.test()
async def test_sdk_check(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    rx_bytes = []
    cocotb.start_soon(uart_rx(dut, rx_bytes))

    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line.startswith("SDK_CHECK END"):
            break
        assert len(lines) < 400, "runaway program output"

    assert lines[0] == "SDK_CHECK START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    # The message and its CRC trailer came out of the UART pin (later bytes
    # are the breakpoint / ws2812 experiments and are not checked)
    expected = DATA + [crc8_lsb_first(DATA)]
    assert rx_bytes[:4] == expected, f"UART received {rx_bytes} expected {expected}"

    await ClockCycles(dut.clk, 100)
