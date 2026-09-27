# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/txdma_verify (fetched from the simulated
# QSPI flash, data in PSRAM A), which drives the PRISM TX DMA: frames from
# PSRAM B slots into FIFO B (the SRAM FIFO on SRAM[1]), checked by popping
# them back, and a loopback through the fifo_loop chroma and the RX DMA with
# both DMAs sharing the memory port; then the RX DMA draining an SRAM FIFO
# (FIFO A on SRAM[0]) and both DMAs on their own SRAMs at once (TX into
# SRAM[1], RX out of SRAM[0]).  The program reports over the debug
# UART; this side checks the report and, in the RTL simulation, watches the
# memory-port arbiter in project.v: when both DMAs ask for a free port the
# RX DMA must get it, and an RX request never waits long.
#
#   make -f test_prog.mk PROG=txdma_verify        (or: make txdma_verify)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, Timer, First
from test_util import reset

CLK_PERIOD_NS = 15.624                 # 64 MHz
DEBUG_UART_BIT_NS = CLK_PERIOD_NS * 16 # debug UART is 4 Mbaud at 64 MHz
CHAR_TIMEOUT_NS = 40_000_000           # 40 ms of silence = program is stuck
RX_WAIT_LIMIT = 400                    # clocks: one TX burst plus a CPU transaction


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


async def arbiter_monitor(dut, stats):
    """Samples project.v's DMA arbitration mid-cycle (RTL only)."""
    try:
        top = dut.user_project
        sig = (top.port_grant, top.dma_mem_req, top.txd_mem_req, top.txd_own)
    except AttributeError:
        stats["available"] = False
        return
    stats["available"] = True
    prev = None
    rx_wait = 0
    while True:
        await FallingEdge(dut.clk)
        try:
            g, r, t, o = (int(s.value) for s in sig)
        except ValueError:          # X / Z around reset
            prev = None
            continue
        if prev is not None and prev[0] == 0 and g == 1:
            stats["grants"] += 1
            stats["tx_bursts" if o else "rx_bursts"] += 1
            if prev[1] and prev[2]:
                stats["contended"] += 1
                if o:
                    stats["priority_errors"] += 1
        # an RX request waits while the port is not granted to it
        if r and not (g and not o):
            rx_wait += 1
            stats["rx_wait_max"] = max(stats["rx_wait_max"], rx_wait)
        else:
            rx_wait = 0
        prev = (g, r, t, o)


@cocotb.test()
async def test_txdma_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    stats = dict(grants=0, tx_bursts=0, rx_bursts=0, contended=0, priority_errors=0, rx_wait_max=0)
    cocotb.start_soon(arbiter_monitor(dut, stats))

    lines = []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        if line.startswith("TXDMA_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "TXDMA_VERIFY START"
    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]

    if stats.get("available"):
        dut._log.info(f"arbiter: {stats['grants']} DMA grants ({stats['tx_bursts']} TX, {stats['rx_bursts']} RX), "
                      f"{stats['contended']} with both DMAs asking, longest RX wait {stats['rx_wait_max']} clocks")
        assert stats["tx_bursts"] > 0 and stats["rx_bursts"] > 0, "both DMAs should have used the port"
        assert stats["priority_errors"] == 0, "the TX DMA got a free port while the RX DMA was asking"
        assert stats["rx_wait_max"] <= RX_WAIT_LIMIT, f"an RX request waited {stats['rx_wait_max']} clocks"
