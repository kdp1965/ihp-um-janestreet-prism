USER_PERIPHERALS = \
	uart \
	prism.test \
	cfgmem.test \

.PHONY: all $(USER_PERIPHERALS)

%-results.xml:
	make -f test_$*.mk clean
	make -f test_$*.mk
	mv results.xml $@
	mv sim_build/rtl/tb.fst $*-rtl.fst || true
	mv sim_build/gl/tb.fst $*-gl.fst || true

peri-%.xml:
	make -f test_basic.mk clean
	MODULE=user_peripherals.$* make -f test_basic.mk || true
	if [ ! -f results.xml ]; then echo '<failure message="$* failed (crashed)" />' > results.xml; fi
	mv results.xml $@
	mv sim_build/rtl/tb.fst $*-rtl.fst || true
	mv sim_build/gl/tb.fst $*-gl.fst || true

all: clean basic-results.xml prog-results.xml $(USER_PERIPHERALS:%=peri-%.xml)
	cat *results.xml peri-*.xml > results.xml

$(USER_PERIPHERALS): %: peri-%.xml

clean:
	rm *results.xml peri-*.xml *.fst sim_build/rtl/tb.fst sim_build/gl/tb.fst || true

# RISC-V program tests: build test/programs/<name> into <name>.hex and run it
# on the RTL through test_prog.mk (simulated QSPI flash + 2 PSRAMs).
#   make cfgmem_verify
PROGRAMS = cfgmem_verify sdk_check

.PHONY: $(PROGRAMS) $(PROGRAMS:%=%-hex)

$(PROGRAMS:%=%-hex):
	$(MAKE) -C programs/$(@:%-hex=%)

$(PROGRAMS): %: %-hex
	make -f test_prog.mk clean
	make -f test_prog.mk PROG=$@
