# SPDX-License-Identifier: Apache-2.0
#
# System test: TinyQV runs programs/vga_verify (fetched from the simulated
# QSPI flash, data in PSRAM A), which keeps a small RGB222 frame buffer in
# PSRAM B (160-byte lines, eight per 2 KB slot) and runs the VGA chroma pair:
# chroma_vga_ln on shard 0 (vertical timing, VSync on uo_out[3]) and
# chroma_vga_px on shard 1 (a line of 160 pixel bytes from FIFO B, 12 clocks
# each, on the Tiny VGA PMOD's six colour pins, HSync on uo_out[7]).  Each
# source line is shown four times from one TX DMA copy: three showings
# re-push what they pop (the SRAM FIFO's replay, CFG3[29]) and as the fourth
# begins the line shard interrupts TinyQV, which copies the next line behind
# it.  From the program's "VGA START" line this side samples uo_out for two
# frames and checks the line timing, every pixel against the program's
# pattern and that the second frame repeats the first.
#
#   make -f test_prog.mk PROG=vga_verify        (or: make vga_verify)

import re

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, Timer, First
from test_util import reset

CLK_PERIOD_NS = 15.624                 # 64 MHz
DEBUG_UART_BIT_NS = CLK_PERIOD_NS * 16 # debug UART is 4 Mbaud at 64 MHz
CHAR_TIMEOUT_NS = 40_000_000           # 40 ms of silence = program is stuck

LINE, UNIT, BYTES = 2400, 12, 160      # clocks per line, per pixel byte; bytes per line
K1, K2, K3 = 1, 2, 4                   # the program's vertical constants
COLOUR = ((0, 5), (1, 4), (2, 3), (4, 2), (5, 1), (6, 0))   # (uo_out pin, comm bit)


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


def pixel(ln, i):
    """The program's pixel(): source line ln, byte i, odd values 1..63."""
    return ((ln * 37 + i * 11) & 62) + 1


async def sampler(dut, colour, hsync, vsync):
    while True:
        await FallingEdge(dut.clk)
        uo = int(dut.uo_out.value.binstr.replace('x', '0').replace('z', '0'), 2)
        c = 0
        for pin, bit in COLOUR:
            c |= ((uo >> pin) & 1) << bit
        colour.append(c)
        hsync.append((uo >> 7) & 1)
        vsync.append((uo >> 3) & 1)


@cocotb.test()
async def test_vga_verify(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())

    await reset(dut, latency=1)

    lines = []
    src_lines = None
    colour, hsync, vsync = [], [], []
    while True:
        line = await read_debug_line(dut)
        dut._log.info(f"PROG: {line}")
        lines.append(line)
        m = re.match(r"VGA START lines=(\d+)$", line)
        if m:
            # uo_out[6] is the debug UART's pin and the PMOD's B0: the program
            # hands it to the PRISM for two frames and a bit, then takes it back
            src_lines = int(m.group(1))
            A = 4 * src_lines
            FRAME = A + K3 + 3
            w = cocotb.start_soon(sampler(dut, colour, hsync, vsync))
            while len(colour) < (2 * FRAME + 40) * LINE:                    # the program takes a while to enable the PRISM
                await FallingEdge(dut.clk)
            w.kill()
            # the program keeps the pin for longer than that (its cycle counter
            # is slower than the clock): resume reading once the line has been
            # idle-high for longer than any pixel run
            high = 0
            while high < 20000:
                await FallingEdge(dut.clk)
                high = high + 1 if int(dut.debug_uart_tx.value) == 1 else 0
        if line.startswith("VGA_VERIFY END"):
            break
        assert len(lines) < 200, "runaway program output"

    assert lines[0] == "VGA_VERIFY START"
    assert src_lines is not None, "no VGA START line"
    BLANK = K3 + 3
    # before the PRISM is enabled the pins idle high (UART TX, debug UART): the
    # first black sample is the enable; two frames and a bit from there
    start = colour.index(0)
    n = (2 * FRAME + 3) * LINE
    colour, hsync, vsync = colour[start:start + n], hsync[start:start + n], vsync[start:start + n]
    dut._log.info(f"PRISM enabled {start} clocks after VGA START")

    # line timing from hsync
    falls = [i for i in range(1, len(hsync)) if hsync[i - 1] and not hsync[i]]
    rises = [i for i in range(1, len(hsync)) if not hsync[i - 1] and hsync[i]]
    periods = [b - a for a, b in zip(falls, falls[1:])]
    widths = [next(r for r in rises if r > f) - f for f in falls[:-1]]
    dut._log.info(f"hsync: {len(falls)} pulses, periods {sorted(set(periods))}, widths {sorted(set(widths))}")
    assert periods[1:] and all(p == LINE for p in periods[1:]), sorted(set(periods))
    assert all(wd == 24 * UNIT - 1 for wd in widths), sorted(set(widths))

    # every active line: 160 bytes, 12 clocks each, the source line four times over
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
    zeros = sum(1 for c in colour if c == 0)
    dut._log.info(f"{len(spans)} active lines sampled; {zeros} black samples of {len(colour)}; "
                  f"first 24 colours {colour[:24]}; colours in the first line {sorted(set(colour[:LINE]))[:12]}")
    assert len(spans) >= 2 * A, len(spans)
    for n, (s, e) in enumerate(spans[:2 * A]):
        ln = (n % A) // 4                                                    # source line of this showing
        assert e - s == BYTES * UNIT, (n, s, e)
        got = [colour[s + k * UNIT + 6] for k in range(BYTES)]
        want = [pixel(ln, k) & 0x3F for k in range(BYTES)]
        assert got == want, (n, ln, got[:8], want[:8])
        prev_falls = [f for f in falls if f < s]
        if prev_falls:
            r = next(r for r in rises if r > prev_falls[-1])
            assert s - r == 12 * UNIT, (n, s - r)                          # back porch
    assert all(colour[s - 1] == 0 and colour[e] == 0 for s, e in spans[:2 * A])

    # the vertical structure: A active lines, BLANK blank ones, again
    active = []
    for f, nf in zip(falls, falls[1:]):
        active.append(any(colour[f:nf]))
    runs = []
    for a in active:
        if runs and runs[-1][0] == a:
            runs[-1][1] += 1
        else:
            runs.append([a, 1])
    dut._log.info(f"lines after each hsync: {''.join('P' if a else '.' for a in active)}")
    assert runs[0] == [True, A - 1] and runs[1] == [False, BLANK] and runs[2] == [True, A] and runs[3] == [False, BLANK], runs
    vs_low = [i for i in range(1, len(vsync)) if vsync[i - 1] and not vsync[i]]
    vs_high = [i for i in range(1, len(vsync)) if not vsync[i - 1] and vsync[i]]
    vs_high = [r for r in vs_high if r > vs_low[0]]
    assert vs_high[0] - vs_low[0] == 2 * LINE, (vs_low, vs_high)
    assert vs_low[1] - vs_low[0] == FRAME * LINE, (vs_low, vs_high)

    failures = [l for l in lines if "FAIL" in l]
    assert not failures, f"program reported failures: {failures}"
    assert "fail=0" in lines[-1]
