# Builds the cfgmem_verify RISC-V test program for the cocotb program
# testbench.  Output: test/cfgmem_verify.hex (loaded into the simulated
# QSPI flash by test_prog.mk PROG=cfgmem_verify).
#
# Modeled on tinyQV-sdk/example-sim-project: links start.o + tinyQV-sim.a
# against memmap_sim (32KB flash at 0, 8KB PSRAM A/B).

PROJECT_NAME    ?= cfgmem_verify
OUT_DIR         ?= ../..
RISCV_TOOLCHAIN ?= /opt/tinyQV
TINYQV_SDK      ?= $(HOME)/Documents/Other/TinyTapeout/TinyQV/tinyQV-sdk
CHROMA_DIR      ?= ../../../chromas/output
OBJDIR          ?= obj

CC      = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-gcc
LD      = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-ld
OBJCOPY = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-objcopy

SRCS        = main.c
CHROMA_SRCS = chroma_gpio24.c
vpath %.c $(CHROMA_DIR)

OBJS = $(addprefix $(OBJDIR)/,$(SRCS:.c=.o) $(CHROMA_SRCS:.c=.o))

CFLAGS = -O2 -I$(TINYQV_SDK) -I.. -march=rv32ec_zicsr_zcb_zicond_zilsd -mabi=ilp32e \
         -mno-strict-align -nostdlib -nostartfiles -ffreestanding \
         -ffunction-sections -fdata-sections -Wall -Werror -MMD -MP

all: $(OUT_DIR)/$(PROJECT_NAME).hex

clean:
	rm -rf $(OBJDIR) $(OUT_DIR)/$(PROJECT_NAME).hex

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	@echo "Compiling $(notdir $<)..."
	@$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/$(PROJECT_NAME).elf: $(OBJS)
	@echo "Linking $@..."
	@$(LD) $^ $(TINYQV_SDK)/start.o $(TINYQV_SDK)/tinyQV-sim.a \
	    $(RISCV_TOOLCHAIN)/riscv32-unknown-elf/lib/libc.a \
	    $(RISCV_TOOLCHAIN)/lib/gcc/riscv32-unknown-elf/*/libgcc.a \
	    -T ../memmap_sim --gc-sections -Map=$(OBJDIR)/$(PROJECT_NAME).map -o $@

$(OBJDIR)/$(PROJECT_NAME).bin: $(OBJDIR)/$(PROJECT_NAME).elf
	@echo "Creating $@..."
	@$(OBJCOPY) $< -O binary $@

$(OUT_DIR)/$(PROJECT_NAME).hex: $(OBJDIR)/$(PROJECT_NAME).bin
	@echo "Creating $@..."
	@od -An -t x1 -w4 -v $< > $@

.PHONY: all clean

-include $(wildcard $(OBJDIR)/*.d)
