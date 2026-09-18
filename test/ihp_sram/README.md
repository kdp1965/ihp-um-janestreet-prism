# IHP SRAM behavioural models (vendored)

Copies of `libs.ref/sg13cmos5l_sram/verilog/` from the pinned
ihp-sg13cmos5l snapshot (IHP-Open-PDK, commit ae7613984daf), Apache-2.0,
"Copyright 2023 IHP PDK Authors".  The cocotb tests simulate the PRISM's
SRAM FIFO with them, and the GitHub test job has no PDK checkout, so the
test makefiles take `SRAM_MODEL_DIR` from here by default.  Refresh these
files when the PDK snapshot changes.
