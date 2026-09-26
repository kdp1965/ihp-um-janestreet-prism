# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
WAVES ?= 1
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v peri*.v tinyQV/cpu/*.v tinyQV/peri/uart/uart_tx.v user_peripherals/*/*.v

# The PRISM's SRAM FIFOs: how many (0/1/2) and their address width.  The
# tests read PRISM_SRAM_FIFO from the environment as well (the ones that
# need a FIFO are skipped when there is none), so it is set and exported
# outside the RTL / gate-level branches.
PRISM_SRAM_AW ?= 9
PRISM_SRAM_FIFO ?= 2
export PRISM_SRAM_FIFO

# The PDK's behavioural SRAM models, vendored in ihp_sram/ so the GitHub
# jobs (which have no PDK checkout) can simulate the macro.  The tile
# netlist keeps the SRAMs as black boxes, so the gate-level build needs
# them just as much as the RTL one does.
SRAM_MODEL_DIR ?= $(PWD)/ihp_sram
SRAM_MODELS = $(SRAM_MODEL_DIR)/RM_IHPSG13_1P_core_behavioral_bm_bist.v \
              $(SRAM_MODEL_DIR)/RM_IHPSG13_1P_2048x32_c2_bm_bist.v \
              $(SRAM_MODEL_DIR)/RM_IHPSG13_1P_1024x32_c2_bm_bist.v \
              $(SRAM_MODEL_DIR)/RM_IHPSG13_1P_512x32_c2_bm_bist.v

ifneq ($(GATES),yes)

ifneq ($(SYNTH),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -DSIM
# The PRISM's SRAM FIFO macro: the PDK's behavioural model (FUNCTIONAL)
VERILOG_SOURCES += $(SRAM_MODELS)
COMPILE_ARGS 		+= -DFUNCTIONAL
COMPILE_ARGS 		+= -DPRISM_SRAM_AW=$(PRISM_SRAM_AW) -DPRISM_SRAM_FIFO=$(PRISM_SRAM_FIFO)
COMPILE_ARGS 		+= -DPURE_RTL
COMPILE_ARGS 		+= -I$(SRC_DIR)
COMPILE_ARGS 		+= -I$(addprefix $(SRC_DIR)/,user_peripherals/pwl_synth)

else

SIM_BUILD				= sim_build/synth
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_io/verilog/sg13cmos5l_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/verilog/sg13cmos5l_stdcell.v

NL ?= placement

#VERILOG_SOURCES += ../runs/wokwi/results/synthesis/tt_um_pettit_js_prism.v
VERILOG_SOURCES += ../runs/wokwi/results/$(NL)/tt_um_pettit_js_prism.nl.v
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP16/CFGMEM_IHP16.nl.v
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP_LEFT16/CFGMEM_IHP_LEFT16.nl.v
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP_LEFT16_SRAM/CFGMEM_IHP_LEFT16_SRAM.nl.v
VERILOG_SOURCES += $(SRAM_MODELS)

endif

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
# No USE_POWER_PINS: the CMOS5L cell models take no supply ports at all
# (sg13cmos5l_antennanp is "module sg13cmos5l_antennanp (A);"), so a
# powered netlist cannot elaborate against them.  The gate-level build
# uses the unpowered netlists throughout, tile and macros alike.
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_io/verilog/sg13cmos5l_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/verilog/sg13cmos5l_stdcell.v

# this gets copied in by the GDS action workflow
#VERILOG_SOURCES += ../runs/wokwi/results/placement/tt_um_pettit_js_prism.pnl.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v
# The CFGMEM macros are black boxes in the tile netlist: add their
# netlists (no power ports, like the tile netlist and the cell models).
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP16/CFGMEM_IHP16.nl.v
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP_LEFT16/CFGMEM_IHP_LEFT16.nl.v
VERILOG_SOURCES += $(PWD)/../macros/CFGMEM_IHP_LEFT16_SRAM/CFGMEM_IHP_LEFT16_SRAM.nl.v
# ... and so are the SRAMs
VERILOG_SOURCES += $(SRAM_MODELS)

endif

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE ?= test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
