# Makefile for building PRISM Chroma personalities

TOPDIR = $(shell pwd)

YOSYS_DIR ?= ../../yosys-prism
YOSYS := $(YOSYS_DIR)/yosys
#CFG := $(TOPDIR)/tinyqv_lut3.cfg
CFG := $(TOPDIR)/tinyqv32.cfg

CHROMAS := $(basename $(notdir $(wildcard chroma*.v)))

# Pattern rule to build .lst and .tab from .v
%.lst %.tab: %.v
	@echo "Building Chroma: $*"
	$(YOSYS) -q -p \
		'read_verilog $<; synth; synth_prism -cfg $(CFG) -top $* -list output/$*.lst -tab output/$*.tab -cfile output/$*.c -py output/$*.py'
	@# keep the cocotb copy in sync (test/user_peripherals/prism imports these)
	@cp output/$*.py ../test/user_peripherals/prism/$*.py

# Default target
all: init $(foreach c,$(CHROMAS),$(c).lst $(c).tab)

init:
	@mkdir -p output

clean:
	rm -f *.lst *.tab

# Regenerate the PRISM's STEW decode (prism.v) from the config's field table
stew-map:
	python3 stew_map.py $(CFG) ../src/user_peripherals/prism/prism.v

yosys: yosys_fetch
	make -C $(YOSYS_DIR) -j8


yosys_fetch:
	@if [ ! -d $(YOSYS_DIR) ]; then \
	git clone --recursive https://github.com/kdp1965/yosys-prism $(YOSYS_DIR); fi

# vim: noet
