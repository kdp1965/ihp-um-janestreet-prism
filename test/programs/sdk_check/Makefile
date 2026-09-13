# Builds the sdk_check RISC-V test program: exercises the PRISM through the
# tinyQV-sdk driver built for this design (PRISM_CONFIG_JANESTREET).
# Output: test/sdk_check.hex (make -f test_prog.mk PROG=sdk_check, or
# make sdk_check in test/).
#
# Links prism_js.o from the SDK ahead of tinyQV-sim.a so the archive's
# sky25a prism.o is never pulled in.

PROJECT_NAME    ?= sdk_check
OUT_DIR         ?= ../..
RISCV_TOOLCHAIN ?= /opt/tinyQV
TINYQV_SDK      ?= $(HOME)/Documents/Other/TinyTapeout/TinyQV/tinyQV-sdk
CHROMA_DIR      ?= ../../../chromas/output
OBJDIR          ?= obj

CC      = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-gcc
LD      = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-ld
OBJCOPY = $(RISCV_TOOLCHAIN)/bin/riscv32-unknown-elf-objcopy

SRCS        = main.c
CHROMA_SRCS = chroma_uart_tx.c chroma_encoder.c chroma_ws2812.c
vpath %.c $(CHROMA_DIR)

OBJS = $(addprefix $(OBJDIR)/,$(SRCS:.c=.o) $(CHROMA_SRCS:.c=.o))

CFLAGS = -O2 -DPRISM_CONFIG=PRISM_CONFIG_JANESTREET -I$(TINYQV_SDK) -I.. \
         -march=rv32ec_zicsr_zcb_zicond_zilsd -mabi=ilp32e \
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

$(TINYQV_SDK)/prism_js.o:
	$(MAKE) -C $(TINYQV_SDK) prism_js.o

$(OBJDIR)/$(PROJECT_NAME).elf: $(OBJS) $(TINYQV_SDK)/prism_js.o
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
