# Sample testbench for a Tiny Tapeout project

This is a sample testbench for a Tiny Tapeout project. It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.
See below to get started or for more information, check the [website](https://tinytapeout.com/hdl/testing/).

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to point to your Verilog files.
2. Edit [tb.v](tb.v) and replace `tt_um_example` with your module name.

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/{your_module_name}.v` to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

## How to view the VCD file

Using GTKWave
```sh
gtkwave tb.vcd tb.gtkw
```

Using Surfer
```sh
surfer tb.vcd
```

## RISC-V program tests (system level)

`test_prog.mk` runs a compiled RISC-V program on the full design: the
program is served from a simulated QSPI flash and the two simulated PSRAMs
(`sim_qspi.v`, wired up in `tb_qspi.v`), exactly like the QSPI PMOD on the
board.  Programs live in `programs/<name>/` and build with the tinyQV-sdk
toolchain (`/opt/tinyQV`, `TINYQV_SDK` in the program Makefile) into
`<name>.hex`; `test_<name>.py` is the matching cocotb test.

```sh
make cfgmem_verify          # build programs/cfgmem_verify and run it on the RTL
# or, step by step:
make -C programs/cfgmem_verify
make -f test_prog.mk PROG=cfgmem_verify
```

`programs/tqv_prism.h` holds the CFGMEM / PRISM register map and access
helpers shared by the programs.  `programs/memmap_sim` is the linker script
for the simulated memories (32KB flash, 2 x 8KB PSRAM).

`cfgmem_verify` shifts patterns into every CFGMEM macro and reads every row
back, chains the lo macros into the hi macros through the macro data path,
loads `chromas/output/chroma_gpio24.c` into the PRISM state table and runs
it against 74165/74595 shift-register models on the PMOD pins.  Results come
back over the debug UART (uo_out[6], 4 Mbaud) as one line per check.

### Debugging aids

- The PRISM unit test is one cocotb test per subject (`test.py` lists
  them: registers, state table, one per chroma, fractured), each starting
  from reset, so `TESTCASE=test_usb_device MODULE=user_peripherals.prism.test
  make -f test_basic.mk` runs a single one (`make -f test_basic.mk clean`
  first if a program test built `sim_build` last).  The test classes live in
  `user_peripherals/prism/prism_tests.py`, the bench (clock, bus, CFGMEM and
  chroma loading) in `bench.py`, the external device models in `models.py`
  and the register map in `regs.py`.
- `PRISM_TRACE=1` (with the PRISM unit test) logs every state change of
  shard 0 with the input word, outputs, counters and latched inputs;
  `PRISM_TRACE_MAX` caps the number of lines.
- `test_cfgmem_probe.py` (see its header) logs CFGMEM bus accesses.
