
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Edge
from user_peripherals.prism.chroma_ws2812 import *
from user_peripherals.prism.chroma_spislave import *
from user_peripherals.prism.chroma_encoder import *
from user_peripherals.prism.chroma_gpio24 import *
from user_peripherals.prism.encoder import *

from tqv import TinyQV

PERIPHERAL_NUM = 8

# CFGMEM peripheral (holds the PRISM state table); see src/user_peripherals/cfgmem
CFGMEM_PERIPHERAL_NUM = 4
CFGMEM_REG_CTRL       = 0x1f            # byte register
CFGMEM_CTRL_ADDR_SEL  = 1 << 4
CFGMEM_CTRL_BUSY      = 1 << 5
CFGMEM_CTRL_BYP_LO    = 1 << 6
CFGMEM_CTRL_BYP_HI    = 1 << 7
def CFGMEM_REG_LO(i): return i * 4

# PRISM peripheral registers (docs/prism_interface.md): common block + shard 0 window
REG_CTRL    = 0x000       # [31] interrupt (RO) [30] enable; byte 0x003 bit 7 clears the interrupt
REG_CFG0    = 0x100       # chroma ctrl_reg
REG_PINMUX  = 0x104       # chroma pinmux_reg
REG_PRELOAD = 0x108
REG_COUNT1  = 0x10C
REG_COUNT2  = 0x110       # byte lanes: +0 count2, +1 compare, +2 comm
REG_COMPARE = 0x111
REG_COMM    = 0x112
REG_HOST    = 0x114       # host_in[1:0]
REG_TOGGLE  = 0x115       # byte write: toggle host_in[0], clear interrupt
REG_FLAGS   = 0x118
SHARD1      = 0x080       # add to a REG_* above for the shard 1 window (0x180)
IRQ0_MASK   = 0x80000000  # CTRL bit 31: shard 0 interrupt
IRQ1_MASK   = 0x20000000  # CTRL bit 29: shard 1 interrupt
REG_INT_CLR1   = 0x007    # byte write bit 7: clear shard 1 interrupt
REG_INT_STATUS = 0x024
REG_FRAC_CFG   = 0x040
REG_OUT_MASK0  = 0x044
REG_COND_MASK0 = 0x048
REG_OUT_MASK1  = 0x04C
REG_COND_MASK1 = 0x050

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 16, units="ns")
    cocotb.start_soon(clock.start())

    # Setup simulated external devices
    input_value = 0xA5A5A5  # whatever test value you want
    output_shift = 0
    output_value = 0
    input_shift = input_value
    spi_data = []
    spi_rx_data = []
    grb = 0
    chroma = ''
    spi_transfer = False
    spi_byte_done = False
    rx_byte = 0

    async def simulate_74165():
        nonlocal input_shift
        val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
        prev_val = int(val_str, 2)
        while True:
            # Wait for rising edge of uo_out[7] (shift clock)
            await RisingEdge(dut.clk)
            if chroma != 'gpio24':
               continue;

            # Get uo_out as an integer safely ('x' -> 0)
            val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
            curr_val = int(val_str, 2)

            # Check for clear or clock
            if (curr_val & 2) == 0:
                # Load new value
                input_shift = input_value
            elif ((prev_val ^ curr_val) & (1 << 7)) and (curr_val & (1 << 7)):
                # Shift left
                input_shift = (input_shift << 1) & 0xFFFFFF
            else:
               prev_val = curr_val
               continue
            prev_val = curr_val

            # Set ui_in[0] to MSB
            dut.ui_in[0].value = (input_shift >> 23) & 1

    async def simulate_74595():
        nonlocal output_shift, output_value
        val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
        prev_val = int(val_str, 2)

        while True:
            # Wait for either posedge uo_out[7] (shift clk) or posedge uo_out[2] (store)
            await RisingEdge(dut.clk)
            if chroma != 'gpio24':
               continue;

            val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
            curr_val = int(val_str, 2)
            if curr_val & 4 != 0:
                # On store, latch output
                output_value = output_shift
            elif ((prev_val ^ curr_val) & (1 << 7)) and (curr_val & (1 << 7)):
                # On shift, shift in from uo_out[3]
                bit = int(dut.uo_out[5].value)
                output_shift = ((output_shift << 1) | bit) & 0xFFFFFF
            prev_val = curr_val

    async def delay(clocks):
        for i in range(clocks):
            await RisingEdge(dut.clk)

    async def simulate_spimaster():
        nonlocal spi_data, spi_rx_data, chroma, spi_transfer, rx_byte, spi_byte_done
        val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
        prev_val = int(val_str, 2)
        baud = 16
        rx_byte = 0

        while True:
            # Wait for either posedge uo_out[7] (shift clk) or posedge uo_out[2] (store)
            await RisingEdge(dut.clk)
            if chroma != 'spislave':
               continue
            if not spi_transfer:
               continue

            # Drop chip select
            dut.ui_in[0].value = 0

            # Send all data in spi_data
            for next_byte in spi_data:
                rx_byte = 0
                for b in range(8): 
                    # Pulse SCLK high and set next MOSI bit
                    await delay(baud)
                    bit = (next_byte >> 7) & 1
                    next_byte = next_byte << 1
                    dut.ui_in[2].value = bit
                    dut.ui_in[1].value = 1
                
                    # Drive SCLK low
                    await delay(baud)
                    dut.ui_in[1].value = 0
                
                    # Read MISO line
                    bit = dut.uo_out[2].value
                    rx_byte = (rx_byte << 1) | bit

                dut._log.info(f"    RX: {rx_byte:02X}")
                spi_rx_data.append(rx_byte)
                spi_byte_done = True
                while spi_byte_done:
                    await RisingEdge(dut.clk)

            # Raise chip select
            await delay(baud)
            dut.ui_in[0].value = 1

            # Clear spi_transfer so we don't send over and over
            spi_transfer = False;

    async def simulate_ws2822_slave():
        nonlocal chroma, grb
        val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
        prev_val = int(val_str, 2) & 2
        baud = 16
        grb  = 0
        clk_count = 0
        bit_count = 0;

        armed = False
        while True:
            # Wait for either posedge uo_out[7] (shift clk) or posedge uo_out[2] (store)
            await RisingEdge(dut.clk)
            if chroma != 'ws2812':
               armed = False
               continue

            # (Re)arm the frame decoder whenever a ws2812 run starts, so a
            # transfer left half-way by an earlier run cannot leak bits in
            if not armed:
               armed = True
               val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
               prev_val = int(val_str, 2) & 2
               clk_count = 0
               grb = 0
               continue

            # Keep track of the number of clocks between edges
            clk_count += 1

            # Test for change in WS2812 data line
            val_str = dut.uo_out.value.binstr.replace('x', '0').replace('z', '0')
            val = int(val_str, 2) & 2
            if val == prev_val:
               continue

            # Test if the count exceeded the "reset bus" value
            if clk_count >= 1280 and prev_val == 0:
               clk_count = 0 
               grb = 0
               prev_val = val
               continue
            elif prev_val == 0:
               prev_val = val
               clk_count = 0
               continue

            # Test for transition from HIGH to LOW
            if prev_val != 0:
               # Shift the grb data
               grb <<= 1

               # Test for a '1' bit
               if clk_count >= 35:
                  grb |= 1

            prev_val = val

    async def cfgmem_wait():
        '''Wait for the CFGMEM shift-load FSM (control byte bit 5 = busy)'''
        for _ in range(8):
            if (await cfg.read_byte_reg(CFGMEM_REG_CTRL) & CFGMEM_CTRL_BUSY) == 0:
                return
        assert False, "CFGMEM loader stuck busy"

    async def cfgmem_read_lo(inst, row):
        '''Read row `row` of lo macro `inst` through the bypassed hi macro'''
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_HI | CFGMEM_CTRL_ADDR_SEL | row)
        return await cfg.read_word_reg(inst * 4)

    STEW_WORDS  = 4      # 128-bit STEW (chromas/tinyqv32.cfg)
    BANK_STATES = 16     # rows per CFGMEM bank

    async def cfgmem_read_hi(inst, row):
        '''Read row `row` of hi macro `inst`'''
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_ADDR_SEL | row)
        return await cfg.read_word_reg(inst * 4)

    async def load_banks(lo_words, hi_words):
        '''
           Loads the PRISM State Information Table (the CFGMEM macros).
           lo_words / hi_words list the states of bank A / bank B highest
           state first, 4 words per state, MSW first; word 0 -> macro 3 ...
           word 3 -> macro 0.  Bank B is written through the bypassed lo
           macros first, then bank A, so state s ends up in row s of its bank.
        '''
        # First reset the PRISM
        await tqv.write_word_reg(0x00, 0x00000000)
        await delay(64)
        assert (await tqv.read_word_reg(0x0) & 0xFFFF) == 0x00000000

        if hi_words:
            await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
            for i, wv in enumerate(hi_words):
                j = i % STEW_WORDS
                await cfg.write_word_reg(0x20 + (STEW_WORDS - 1 - j) * 4, wv)
                await cfgmem_wait()
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)
        for i, wv in enumerate(lo_words):
            j = i % STEW_WORDS
            await cfg.write_word_reg(CFGMEM_REG_LO(STEW_WORDS - 1 - j), wv)
            await cfgmem_wait()

        # Validate a few rows of each bank (row 0 = last words written)
        for words, rd in ((lo_words, cfgmem_read_lo), (hi_words, cfgmem_read_hi)):
            if not words:
                continue
            states = len(words) // STEW_WORDS
            for s_idx in (0, 1, states - 1):
                base = (states - 1 - s_idx) * STEW_WORDS
                for j in range(STEW_WORDS):
                    got = await rd(STEW_WORDS - 1 - j, s_idx)
                    assert got == words[base + j], f"row {s_idx} word {j}: {got:#x} != {words[base+j]:#x}"
        # Hand the row address back to PRISM
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

    def bank_rows(chroma):
        ''' The 16 lowest states of a 32-state chroma table (one bank) '''
        return chroma[-BANK_STATES * STEW_WORDS:]

    async def program_shard(base, ctrl_reg, pinmux_reg):
        await tqv.write_word_reg(REG_CFG0 + base, ctrl_reg)
        await tqv.write_word_reg(REG_PINMUX + base, pinmux_reg)
        assert await tqv.read_word_reg(REG_CFG0 + base) == ctrl_reg
        assert await tqv.read_word_reg(REG_PINMUX + base) == pinmux_reg

    async def load_chroma(chroma, ctrl_reg, pinmux_reg):
        ''' Unfractured: one 32-state chroma, shard 0 configuration '''
        states = len(chroma) // STEW_WORDS
        if states > BANK_STATES:
            await load_banks(chroma[(states - BANK_STATES) * STEW_WORDS:],
                             chroma[:(states - BANK_STATES) * STEW_WORDS])
        else:
            await load_banks(chroma, [])
        await tqv.write_word_reg(REG_FRAC_CFG, 0)
        await program_shard(0, ctrl_reg, pinmux_reg)

        # Now enable PRISM
        await tqv.write_word_reg(0x0, 0x40000000)

    async def load_fractured(chroma_a, ctrl_a, pinmux_a, chroma_b, ctrl_b, pinmux_b):
        ''' Fractured: chroma A (16 states) in shard 0, chroma B in shard 1 '''
        await load_banks(bank_rows(chroma_a), bank_rows(chroma_b))
        await tqv.write_word_reg(REG_FRAC_CFG, 1)
        await tqv.write_word_reg(REG_OUT_MASK0, 0x1FFFFF)
        await tqv.write_word_reg(REG_OUT_MASK1, 0x1FFFFF)
        await tqv.write_word_reg(REG_COND_MASK0, 0x3)
        await tqv.write_word_reg(REG_COND_MASK1, 0x3)
        await program_shard(0, ctrl_a, pinmux_a)
        await program_shard(SHARD1, ctrl_b, pinmux_b)

        # Now enable PRISM
        await tqv.write_word_reg(0x0, 0x40000000)

    async def test_chroma_gpio24():
        nonlocal input_value, chroma

        await load_chroma(chroma_gpio24, chroma_gpio24_ctrlReg, chroma_gpio24_pinmuxReg)
        
        # Put 24-bit OUTPUT data in the 24-bit Shift register
        await tqv.write_word_reg(REG_PRELOAD, 0x00F05077)
        
        # Set an input value in the testbench
        input_value = 0x00BEEF
        dut.ui_in[0].value = 0

        chroma = 'gpio24'

        # Set a breakpoint in the PRISM debugger
        await tqv.write_word_reg(0x04, 0x00000034)
        
        # Start a transfer
        dut._log.info(f"    Starting GPIO24 shift operation")
        await tqv.write_word_reg(REG_HOST, 3)
        await tqv.write_word_reg(REG_HOST, 2)

        # Delay a bit to give FSM time to break
        for i in range(40):
            await RisingEdge(dut.clk)

        dut._log.info(f"    Testing if PRISM halted at breakpoint")
        dbg_status = await tqv.read_word_reg(0x0C)
        assert (dbg_status & 0x1f) == 3          # curr_si (5 bits)
        assert (dbg_status & 0x400) == 0x400      # halt (bit 10)

        # Issue a single step request
        dut._log.info(f"    Single stepping PRISM")
        await tqv.write_word_reg(0x04, 0x00000036)

        dut._log.info(f"    Testing if PRISM stepped ")
        dbg_status = await tqv.read_word_reg(0x0C)
        assert (dbg_status & 0x1f) == 4          # STATE_DELAY2 (compiler index 4)

        # Clear the interrupt caused by halt
        await tqv.write_byte_reg(0x03, 0x000000C0)

        # Resume the execution
        await tqv.write_word_reg(0x04, 0x00000001)
        await tqv.write_word_reg(0x04, 0x00000000)

        for i in range(200):
            await RisingEdge(dut.clk)
        
        # See if we got the input value
        dut._log.info(f"    Testing input read value")
        assert await tqv.read_word_reg(REG_COUNT1) == 0x0000BEEF
        dut._log.info(f"    Testing output store value")
        assert output_value == 0x00F05077

    async def test_chroma_spislave():
        nonlocal spi_data, spi_rx_data, chroma, spi_transfer, spi_byte_done

        # Reset PRISM
        await tqv.write_word_reg(0x00, 0x00000000)
        chroma = ''

        # Set CS high (ui_in[0])
        dut.ui_in[0].value = 1
        dut.ui_in[1].value = 0
        dut.ui_in[2].value = 0
        
        # Load the chroma
        await load_chroma(chroma_spislave, chroma_spislave_ctrlReg, chroma_spislave_pinmuxReg)

        # Bytes the master sends, and the bytes the slave answers with
        spi_data = [0xF5, 0x27]
        tx_bytes = [0x67, 0xF3]
        chroma = 'spislave'

        # TX bytes are staged in preload[7:0]; the chroma loads comm from it
        # at the first SCLK of each byte
        await tqv.write_word_reg(REG_PRELOAD, tx_bytes[0])

        # Start a transfer; the master model pauses after every byte until
        # the host has read comm, cleared the interrupt and staged the next byte
        spi_transfer = True
        for n, rx in enumerate(spi_data):
            while not spi_byte_done:
                await RisingEdge(dut.clk)
            for i in range(50):
                await RisingEdge(dut.clk)
            dut._log.info(f"    Testing received byte {n}")
            assert await tqv.read_byte_reg(REG_COMM) == rx
            assert await tqv.read_word_reg(0) & 0x80000000 != 0
            await tqv.write_byte_reg(0x03, 0xC0)
            if n + 1 < len(tx_bytes):
                # Stage the next TX byte before releasing the master
                await tqv.write_word_reg(REG_PRELOAD, tx_bytes[n + 1])
            spi_byte_done = False

        # Wait for transfer to complete
        while spi_transfer == True:
            await RisingEdge(dut.clk)

        # Test if we received the bytes we expected
        assert spi_rx_data[0] == 0x67
        assert spi_rx_data[1] == 0xF3

        # Every byte's interrupt was seen and cleared in the loop above, so
        # nothing may be pending now (checks the byte-write clear path)
        dut._log.info(f"    Testing if Interrupt is clear after service")
        assert await tqv.read_word_reg(0) & 0x80000000 == 0

    # ===================================================================================
    # Test the WS2812 Chroma
    # ===================================================================================
    async def test_chroma_ws2812():
        nonlocal input_value, chroma

        # Reset PRISM
        await tqv.write_word_reg(0x00, 0x00000000)
        chroma = ''

        await tqv.write_byte_reg(REG_HOST, 0x00)
        await load_chroma(chroma_ws2812, chroma_ws2812_ctrlReg, chroma_ws2812_pinmuxReg)
        await run_ws2812(0, IRQ0_MASK)

    async def run_ws2812(base, irq_mask):
        ''' Drive the ws2812 chroma in the shard whose window is at base '''
        nonlocal chroma

        # Program the count2_compare with 0.8uS count (64Mhz / 1.25Mhz = 51)
        await tqv.write_byte_reg(REG_COMPARE + base, 51)

        # Program the comm_data register with 0.4uS count (64Mhz /2.5Mhz = 26)
        await tqv.write_byte_reg(REG_COMM + base, 26)

        # Program count1_preload register with GRB data to send
        await tqv.write_word_reg(REG_PRELOAD + base, 0x00FF5367)

        chroma = 'ws2812'

        # Set host bit 0 to start transfer
        await tqv.write_byte_reg(REG_HOST + base, 0x01)

        for i in range(6000):
            await RisingEdge(dut.clk)

        # Test if the interrupt was set
        dut._log.info(f"    Testing if Interrupt was set")
        assert await tqv.read_word_reg(0) & irq_mask != 0

        # Test if data was received
        assert grb == 0xFF5367

        # Write new data using auto-toggle of host_in[0]
        dut._log.info(f"    Writing new data using auto-toggle")
        await tqv.write_word_reg(REG_PRELOAD + base, 0x0036FE0C)
        await tqv.write_byte_reg(REG_TOGGLE + base, 0x00)

        dut._log.info(f"    Testing if Interrupt was cleared")
        assert await tqv.read_word_reg(0) & irq_mask != 0

        dut._log.info(f"    Testing if host_in[0] toggled")
        assert await tqv.read_byte_reg(REG_HOST + base) == 0

    # ===================================================================================
    # Test the Encoder Chroma
    # ===================================================================================
    async def test_chroma_encoder(clocks_per_phase, encoder0):
        nonlocal input_value, chroma

        # Reset PRISM
        await tqv.write_word_reg(0x00, 0x00000000)
        chroma = ''

        await tqv.write_byte_reg(REG_HOST, 0x00)
        await load_chroma(chroma_encoder, chroma_encoder_ctrlReg, chroma_encoder_pinmuxReg)
        await run_encoder(0, clocks_per_phase, encoder0)

    async def run_encoder(base, clocks_per_phase, encoder0):
        ''' Drive the encoder chroma in the shard whose window is at base '''
        nonlocal chroma

        # Program the count1_preload with debounce count (128 for shorter test)
        await tqv.write_byte_reg(REG_PRELOAD + base, 128)

        # Not really needed, but for completeness
        chroma = 'encoder'

        # twist the encoder knob
        dut._log.info("    Checking encoder 0")
        for i in range(clocks_per_phase * 2 * 20):
            await encoder0.update(1)

        # Read the count2 count
        dut._log.info("    Testing count2 value")
        count = await tqv.read_byte_reg(REG_COUNT2 + base)
        assert count == 20

        # twist the encoder knob the other way
        dut._log.info("    Checking encoder 0")
        for i in range(clocks_per_phase * 2 * 12):
            await encoder0.update(-1)

        dut._log.info("    Testing count2 value")
        count = await tqv.read_byte_reg(REG_COUNT2 + base)
        assert count == 9

    # ===================================================================================
    # Fractured: encoder in shard 0 (ui_in[1:0], no output pins) and ws2812 in
    # shard 1 (uo_out[1], host_in, interrupt), each on its own datapath
    # ===================================================================================
    async def test_fractured(clocks_per_phase, encoder0):
        nonlocal chroma

        await tqv.write_word_reg(0x00, 0x00000000)
        chroma = ''
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await tqv.write_byte_reg(REG_HOST + SHARD1, 0x00)
        await load_fractured(chroma_encoder, chroma_encoder_ctrlReg, chroma_encoder_pinmuxReg,
                             chroma_ws2812,  chroma_ws2812_ctrlReg,  chroma_ws2812_pinmuxReg)

        dut._log.info("    Shard 0: encoder")
        await run_encoder(0, clocks_per_phase, encoder0)

        # Let the encoder's last debounced step land, then remember its position
        await ClockCycles(dut.clk, 512)
        pos0 = await tqv.read_byte_reg(REG_COUNT2)

        dut._log.info("    Shard 1: ws2812")
        await run_ws2812(SHARD1, IRQ1_MASK)

        # Shard 0's count2 (encoder position) must be untouched by shard 1's run
        dut._log.info("    Testing shard isolation")
        assert await tqv.read_byte_reg(REG_COUNT2) == pos0
        assert await tqv.read_word_reg(0) & IRQ0_MASK == 0
        assert await tqv.read_word_reg(REG_INT_STATUS) & 0x3 == 0x2

        # Shard 1 interrupt clear through its own INT_CLR byte
        await tqv.write_byte_reg(REG_INT_CLR1, 0x80)
        assert await tqv.read_word_reg(0) & IRQ1_MASK == 0
        await tqv.write_word_reg(REG_FRAC_CFG, 0)

    # Start the simulations
    # Optional execution tracer (PRISM_TRACE=1): log every state change of shard 0
    async def trace_prism():
        import os
        if os.environ.get("PRISM_TRACE", "0") != "1":
            return
        core = dut.user_project.i_peripherals.i_prism.i_prism
        per  = dut.user_project.i_peripherals.i_prism
        sh0  = per.SH[0]
        def iv(sig):
            try: return int(sig.value)
            except ValueError: return -1
        last = None; n = 0; cyc = 0
        every = os.environ.get("PRISM_TRACE_ALL", "0") == "1"
        while n < int(os.environ.get("PRISM_TRACE_MAX", "400")):
            await RisingEdge(dut.clk)
            cyc += 1
            cur = iv(core.curr_si[0])
            if every and chroma == 'gpio24' and cur != 0:
                dut._log.info(f"TRACE @{cyc:6d} si={cur:2d} out={iv(core.out_data):06x} in13={(iv(core.in_data)>>13)&1} "
                              f"lo6={(iv(per.latched_out)>>6)&1} ui0={iv(dut.ui_in)&1} cnt1={iv(sh0.count1):06x} "
                              f"shc={iv(sh0.shift_count)} in14={(iv(core.in_data)>>14)&1}")
                n += 1
                continue
            if cur != last:
                dut._log.info(f"TRACE @{cyc:6d} si {last}->{cur} in={iv(core.in_data):08x} "
                              f"out={iv(core.out_data):06x} cond={iv(core.cond_out)} "
                              f"cnt1={iv(sh0.count1):06x} cnt2={iv(sh0.count2):02x} "
                              f"lin={iv(sh0.latched_in)} ui={iv(dut.ui_in):02x}")
                last = cur; n += 1
    cocotb.start_soon(trace_prism())
    cocotb.start_soon(simulate_74165())
    cocotb.start_soon(simulate_74595())
    cocotb.start_soon(simulate_spimaster())
    cocotb.start_soon(simulate_ws2822_slave())

    clocks_per_phase = 600 
    encoder0 = Encoder(dut.clk, dut.ui_in[0], dut.ui_in[1], clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 8)

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)
    cfg = TinyQV(dut, CFGMEM_PERIPHERAL_NUM)   # STEW loader (no reset: shares the bus)

    # Reset
    await tqv.reset()

    dut._log.info("Testing PRISM")

    # Write values to the count2_compare / count1_preload (PRISM disabled:
    # the state table in the CFGMEM latches is still uninitialised, and an
    # enabled PRISM would drive X into the latched output bits of reg 0)
    await tqv.write_word_reg(0x00, 0x00000000)
    await ClockCycles(dut.clk, 8)
    await tqv.write_word_reg(REG_PRELOAD, 0x0000FA12)
    await ClockCycles(dut.clk, 8)
    await tqv.write_byte_reg(REG_COMPARE, 0x34)
    await ClockCycles(dut.clk, 8)

    dut._log.info("Testing basic control and latch register access")
    assert await tqv.read_byte_reg(REG_COMPARE) == 0x34
    assert await tqv.read_word_reg(REG_PRELOAD) == 0x0000FA12

    # Shard 1 window has its own copies
    dut._log.info("Testing shard 1 register window")
    assert await tqv.read_word_reg(REG_PRELOAD + SHARD1) == 0
    await tqv.write_word_reg(REG_PRELOAD + SHARD1, 0x12345678)
    await tqv.write_byte_reg(REG_COMPARE + SHARD1, 0x56)
    await tqv.write_word_reg(REG_CFG0 + SHARD1, 0x00040100)
    await ClockCycles(dut.clk, 8)
    assert await tqv.read_word_reg(REG_PRELOAD + SHARD1) == 0x12345678
    assert await tqv.read_byte_reg(REG_COMPARE + SHARD1) == 0x56
    assert await tqv.read_word_reg(REG_CFG0 + SHARD1) == 0x00040100
    assert await tqv.read_word_reg(REG_PRELOAD) == 0x0000FA12
    assert await tqv.read_byte_reg(REG_COMPARE) == 0x34
    assert await tqv.read_word_reg(REG_CFG0) == 0
    await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)

    # State information integrity: shift a pattern through all four lo CFGMEM
    # macros that make up the 128-bit STEW and read it back (every macro must
    # hold defined data before the PRISM is enabled, or its outputs go X)
    dut._log.info("Testing PRISM state information integrity")
    await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)
    def pattern(inst, k):
        return ((0x10101010 * k) ^ (0x01000100 * inst)) & 0xFFFFFFFF
    for i in range(2):
        for k in range(1, 9):
            for inst in range(STEW_WORDS):
                await cfg.write_word_reg(CFGMEM_REG_LO(inst), pattern(inst, k))
                await cfgmem_wait()

    # ... and the hi macros (bank B, states 16-31): a garbage STEW can jump
    # there, so they must be defined too.  Written through the bypassed lo macros.
    await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
    for i in range(2):
        for k in range(1, 9):
            for inst in range(STEW_WORDS):
                await cfg.write_word_reg(0x20 + inst * 4, pattern(inst + 4, k))
                await cfgmem_wait()

    # Last words written sit in row 0, the first of the last 8 in row 7
    for inst in range(STEW_WORDS):
        assert await cfgmem_read_lo(inst, 0) == pattern(inst, 8)
        assert await cfgmem_read_lo(inst, 7) == pattern(inst, 1)
        assert await cfgmem_read_hi(inst, 0) == pattern(inst + 4, 8)
        assert await cfgmem_read_hi(inst, 7) == pattern(inst + 4, 1)
    await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

    # Enable bit readback (reg 0 [31:16] carries live status, compare the
    # enable bit and the control bits only)
    await tqv.write_word_reg(0x00, 0x40000000)
    await ClockCycles(dut.clk, 8)
    assert (await tqv.read_word_reg(0x0) & 0x40000000) == 0x40000000
    await tqv.write_word_reg(0x00, 0x00000000)

    # ===========================================================
    # Okay, now load up a real design and see if it does anything
    # This is the 24-Bit GPIO Chroma
    # ===========================================================
    
    import os
    if os.environ.get("PRISM_SKIP_ENCODER", "0") != "1":
        dut._log.info("Testing encoder Chroma")
        await test_chroma_encoder(clocks_per_phase, encoder0)

    dut._log.info("Testing ws2812 Chroma")
    await test_chroma_ws2812()

    dut._log.info("Testing gpio24 Chroma")
    await test_chroma_gpio24()
 
    dut._log.info("Testing spislave Chroma")
    await test_chroma_spislave()

    dut._log.info("Testing fractured PRISM (encoder + ws2812)")
    await test_fractured(clocks_per_phase, encoder0)
    
