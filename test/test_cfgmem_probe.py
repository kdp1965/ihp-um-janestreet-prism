# Debug aid for the cfgmem_verify program: runs it for a bounded number of
# clocks and logs every CFGMEM peripheral bus access and loader FSM
# transition, plus anything the program prints on the debug UART.
#
#   make -f test_prog.mk PROG=cfgmem_verify MODULE=test_cfgmem_probe WAVES=0

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from test_util import reset
from test_cfgmem_verify import read_debug_line, CLK_PERIOD_NS

MAX_CYCLES = int(os.environ.get("PROBE_CYCLES", "200000"))
MAX_EVENTS = int(os.environ.get("PROBE_EVENTS", "400"))


def ival(sig):
    try:
        return int(sig.value)
    except ValueError:
        return -1


@cocotb.test()
async def test_cfgmem_probe(dut):
    clock = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    await reset(dut, latency=1)

    cm = dut.user_project.i_peripherals.i_cfgmem
    events = 0

    async def uart_lines():
        while True:
            line = await read_debug_line(dut)
            dut._log.info(f"PROG: {line}")

    cocotb.start_soon(uart_lines())

    last_state = ival(cm.state)
    cycle = 0
    while cycle < MAX_CYCLES and events < MAX_EVENTS:
        await RisingEdge(dut.clk)
        cycle += 1
        wn = ival(cm.data_write_n)
        rn = ival(cm.data_read_n)
        st = ival(cm.state)
        if wn != 3:
            dut._log.info(f"@{cycle:7d} CFGMEM WR addr={ival(cm.address):#04x} "
                          f"data={ival(cm.data_in):#010x} wn={wn}")
            events += 1
        if rn != 3:
            dut._log.info(f"@{cycle:7d} CFGMEM RD addr={ival(cm.address):#04x} "
                          f"data_out={ival(cm.data_out):#010x} rn={rn} "
                          f"ready={ival(cm.data_ready)}")
            events += 1
        if st != last_state:
            dut._log.info(f"@{cycle:7d} CFGMEM FSM state {last_state}->{st} "
                          f"index={ival(cm.index)} we_lo={ival(cm.cfgmem_we_lo):#x} "
                          f"we_hi={ival(cm.cfgmem_we_hi):#x} ctrl_addr={ival(cm.cfgmem_addr)}")
            last_state = st
            events += 1
    dut._log.info(f"probe done after {cycle} cycles, {events} events")
