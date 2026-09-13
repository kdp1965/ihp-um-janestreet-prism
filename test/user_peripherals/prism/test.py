
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Edge
from user_peripherals.prism.chroma_ws2812 import *
from user_peripherals.prism.chroma_spislave import *
from user_peripherals.prism.chroma_encoder import *
from user_peripherals.prism.chroma_gpio24 import *
from user_peripherals.prism.chroma_uart_tx import *
from user_peripherals.prism.chroma_fifo_loop import *
from user_peripherals.prism.chroma_edge import *
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
REG_CFG1    = 0x11C       # [15:0] in_prev sources, [23:16] FIFO levels, [31:24] FIFO flag selects
REG_IN_DATA = 0x03C       # shard 0 input vector (live)
REG_FIFO    = 0x120       # byte: write pushes (TX mode), read pops (RX mode)
REG_FIFO_ST = 0x124       # {count[12:8], af[3], ae[2], full[1], empty[0]}; write flushes
REG_CRC_POLY= 0x128
REG_CRC     = 0x12C       # read value, write preset
REG_CRC_EXP = 0x130
CFG_FIFO_DIR_TX = 1 << 23

def crc_bits(bits, poly=0x07, width=8, init=0):
    ''' Bit model of prism_crc.v, non-reflected: feed bits in wire order '''
    mask = (1 << width) - 1
    crc = init
    for b in bits:
        fb = ((crc >> (width - 1)) & 1) ^ b
        crc = ((crc << 1) ^ (poly if fb else 0)) & mask
    return crc

def crc_bytes_msb_first(data, **kw):
    return crc_bits([(d >> (7 - i)) & 1 for d in data for i in range(8)], **kw)

def crc_bytes_lsb_first(data, **kw):
    return crc_bits([(d >> i) & 1 for d in data for i in range(8)], **kw)
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
REG_DBG_CTRL   = (0x004, 0x008)   # per shard
REG_DBG_STATUS = 0x00C            # shard 0 in [12:0], shard 1 in [25:13]
DBG_HALT_REQ   = 0x00001
DBG_STEP       = 0x00002
DBG_BP0_EN     = 0x00004
def DBG_BP0_SI(si):   return (si & 0x1f) << 4
def DBG_BP0_COND(c):  return (c & 3) << 14   # 0 entry, 1 if, 2 else-if, 3 any
def DBG_NEW_SI(si):   return (1 << 18) | ((si & 0x1f) << 19)
REG_STEW0      = 0x010            # 4 words: STEW of shard 0's current state
DBGS_HALT      = 0x400

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

    uart_rx_bytes = []
    async def simulate_uart_rx():
        ''' 8N1 receiver on uo_out[1]: sample mid-bit from the start edge '''
        nonlocal chroma, uart_rx_bytes
        period = 64
        while True:
            await RisingEdge(dut.clk)
            if chroma != 'uart_tx':
                continue
            if int(dut.uo_out.value) & 0x2:
                continue
            # start bit seen: sample the 8 data bits and the stop bit
            byte = 0
            for i in range(9):
                for k in range(period if i else period + period // 2):
                    await RisingEdge(dut.clk)
                bit = (int(dut.uo_out.value) >> 1) & 1
                if i < 8:
                    byte |= bit << i
                else:
                    assert bit == 1, "framing error"
            uart_rx_bytes.append(byte)
            dut._log.info(f"    UART RX: {byte:02X}")

    async def test_chroma_uart_tx():
        nonlocal chroma, uart_rx_bytes

        await tqv.write_word_reg(0x00, 0x00000000)
        chroma = ''
        await tqv.write_byte_reg(REG_HOST, 0x00)
        await load_chroma(chroma_uart_tx, chroma_uart_tx_ctrlReg, chroma_uart_tx_pinmuxReg)

        # bit period 64 clocks (preload = period - 2), CRC8 poly 0x07
        await tqv.write_word_reg(REG_PRELOAD, 62)
        await tqv.write_word_reg(REG_CRC_POLY, 0x07)
        uart_rx_bytes = []
        chroma = 'uart_tx'

        data = [0x55, 0xA3, 0x0F]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO, b)
        for i in range(3 * 10 * 64 + 400):
            await RisingEdge(dut.clk)
        assert uart_rx_bytes == data, uart_rx_bytes
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_word_reg(REG_CRC) == crc_bytes_lsb_first(data)

        # Ask for the CRC trailer
        dut._log.info(f"    Requesting CRC trailer")
        await tqv.write_word_reg(REG_HOST, 1)
        for i in range(10 * 64 + 400):
            await RisingEdge(dut.clk)
        assert uart_rx_bytes == data + [crc_bytes_lsb_first(data)], uart_rx_bytes
        assert await tqv.read_word_reg(0) & IRQ0_MASK != 0
        dbg_status = await tqv.read_word_reg(REG_DBG_STATUS)
        assert (dbg_status & 0x1f) == 9                                        # WAIT_ACK

    async def test_chroma_fifo_loop():
        ''' Unfractured: shard 0 owns both FIFOs.  A (its own) is RX, B (shard 1's)
            is TX; the chroma moves every byte the host pushes into B over to A,
            OUT_FIFO_PUSH_POP picking the FIFO that OUT_FIFO_WR_RD strobes. '''
        nonlocal chroma

        chroma = ''                     # stop the UART monitor before TXD drops
        await tqv.write_word_reg(0x00, 0x00000000)
        await load_chroma(chroma_fifo_loop, chroma_fifo_loop_ctrlReg, chroma_fifo_loop_pinmuxReg)
        await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)          # FIFO B: host writes
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1

        data = [0x5A, 0x01, 0xFE, 0x80, 0x7F, 0x33]
        for b in data:
            await tqv.write_byte_reg(REG_FIFO + SHARD1, b)
        for i in range(100):
            await RisingEdge(dut.clk)
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1      # B drained ...
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x1F == len(data), f"{st:#x}"                      # ... into A
        for b in data:
            assert await tqv.read_byte_reg(REG_FIFO) == b
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data)

        # More than A can hold: the FSM stops on fifo_a_full and resumes as the
        # host drains A; the bytes arrive in order
        dut._log.info(f"    FIFO A full back-pressure")
        for b in range(20):
            await tqv.write_byte_reg(REG_FIFO + SHARD1, 0xC0 + b)
        for i in range(200):
            await RisingEdge(dut.clk)
        assert (await tqv.read_word_reg(REG_FIFO_ST) >> 8) & 0x1F == 16
        assert (await tqv.read_word_reg(REG_FIFO_ST + SHARD1) >> 8) & 0x1F == 4
        for b in range(20):
            for i in range(20):
                await RisingEdge(dut.clk)
            assert await tqv.read_byte_reg(REG_FIFO) == 0xC0 + b
        assert await tqv.read_word_reg(REG_FIFO_ST + SHARD1) & 0x1 == 1
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == len(data) + 20

        await tqv.write_word_reg(0x00, 0x00000000)

    async def test_chroma_edge():
        ''' in_prev edge capture: in_prev[0] follows ui_in[2] (input 2) and
            in_prev[1] follows host_in[0] (input 8), sources set in CFG1.  The
            chroma counts pin transitions in count2 and host toggles in count1.
            A flop captures its source only when a decision tree reading that
            source fires and the jump executes, so the debugger halt / step must
            be honoured. '''
        nonlocal chroma

        chroma = ''
        await tqv.write_word_reg(0x00, 0x00000000)
        dut.ui_in[2].value = 0
        await tqv.write_byte_reg(REG_HOST, 0x00)
        # Sources go in before the chroma runs: a flop only changes on a capture,
        # so a source changed afterwards leaves the old value behind (with the
        # reset source 0 and CSB high, tree 1's first jump would have set every
        # flop to 1 and the pin condition would fire until the next capture)
        await tqv.write_word_reg(REG_CFG1, (2 << 0) | (8 << 4))
        await load_chroma(chroma_edge, chroma_edge_ctrlReg, chroma_edge_pinmuxReg)
        for i in range(20):
            await RisingEdge(dut.clk)
        assert await tqv.read_byte_reg(REG_COUNT2) == 0
        assert await tqv.read_word_reg(REG_COUNT1) == 0

        n = 0
        for gap in (8, 5, 30, 4, 12, 9, 6, 40, 4, 7):
            dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)
            n += 1
            for i in range(gap):
                await RisingEdge(dut.clk)
        for i in range(30):
            await RisingEdge(dut.clk)
        assert await tqv.read_byte_reg(REG_COUNT2) == n
        assert await tqv.read_word_reg(REG_COUNT1) == 0

        dut._log.info(f"    host_in[0] toggles through tree 1")
        for m in range(5):
            await tqv.write_byte_reg(REG_TOGGLE, 0x00)
        for i in range(30):
            await RisingEdge(dut.clk)
        assert await tqv.read_word_reg(REG_COUNT1) == 5
        assert await tqv.read_byte_reg(REG_COUNT2) == n

        dut._log.info(f"    debugger halt / step")
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
        for i in range(10):
            await RisingEdge(dut.clk)
        assert (await tqv.read_word_reg(REG_DBG_STATUS) & 0x1f) == 0            # WAIT
        dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)                       # edge while halted
        for i in range(30):
            await RisingEdge(dut.clk)
        assert await tqv.read_byte_reg(REG_COUNT2) == n                        # not consumed
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ | DBG_STEP)     # WAIT -> CNT_PIN, captures
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
        assert (await tqv.read_word_reg(REG_DBG_STATUS) & 0x1f) == 1
        assert await tqv.read_byte_reg(REG_COUNT2) == n
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ | DBG_STEP)     # CNT_PIN -> WAIT, counts
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
        assert (await tqv.read_word_reg(REG_DBG_STATUS) & 0x1f) == 0
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ | DBG_STEP)     # nothing pending: stays
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
        assert (await tqv.read_word_reg(REG_DBG_STATUS) & 0x1f) == 0
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        await tqv.write_word_reg(REG_DBG_CTRL[0], 0)                           # resume
        for i in range(20):
            await RisingEdge(dut.clk)
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 1
        dut.ui_in[2].value = 1 - int(dut.ui_in[2].value)
        for i in range(30):
            await RisingEdge(dut.clk)
        assert await tqv.read_byte_reg(REG_COUNT2) == n + 2
        assert await tqv.read_word_reg(REG_COUNT1) == 5
        dut.ui_in[2].value = 0
        await tqv.write_word_reg(REG_CFG1, 0)
        await tqv.write_word_reg(0x00, 0x00000000)

        # Acknowledge: the FSM clears the CRC and idles
        await tqv.write_word_reg(REG_HOST, 0)
        await tqv.write_byte_reg(0x03, 0x80)
        for i in range(20):
            await RisingEdge(dut.clk)
        dbg_status = await tqv.read_word_reg(REG_DBG_STATUS)
        assert (dbg_status & 0x1f) == 0
        assert await tqv.read_word_reg(REG_CRC) == 0
        assert await tqv.read_word_reg(0) & IRQ0_MASK == 0
        chroma = ''

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
        '''Read row `row` of lo macro `inst` (bypass off)'''
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_ADDR_SEL | row)
        return await cfg.read_word_reg(inst * 4)

    STEW_WORDS  = 4      # 128-bit STEW (chromas/tinyqv32.cfg)
    BANK_STATES = 16     # rows per CFGMEM bank

    async def cfgmem_read_hi(inst, row):
        '''Read row `row` of hi macro `inst` (bypass off)'''
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_ADDR_SEL | row)
        return await cfg.read_word_reg(0x20 + inst * 4)

    async def load_banks(lo_words, hi_words):
        '''
           Loads the PRISM State Information Table (the CFGMEM macros).
           lo_words / hi_words list the states of bank A / bank B highest
           state first, 4 words per state, MSW first; word 0 -> macro 3 ...
           word 3 -> macro 0.  Each bank's macros form a chain (host -> 0
           -> 1 -> 2 -> 3); with the bank's bypass bit set every macro sees
           the host word and is shifted with its own strobe.  State s ends
           up in row s of its bank.
        '''
        # First reset the PRISM
        await tqv.write_word_reg(0x00, 0x00000000)
        await delay(64)
        assert (await tqv.read_word_reg(0x0) & 0xFFFF) == 0x00000000

        if hi_words:
            await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_HI)
            for i, wv in enumerate(hi_words):
                j = i % STEW_WORDS
                await cfg.write_word_reg(0x20 + (STEW_WORDS - 1 - j) * 4, wv)
                await cfgmem_wait()
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
        for i, wv in enumerate(lo_words):
            j = i % STEW_WORDS
            await cfg.write_word_reg(CFGMEM_REG_LO(STEW_WORDS - 1 - j), wv)
            await cfgmem_wait()
        await cfg.write_byte_reg(CFGMEM_REG_CTRL, 0)

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

        # CRC8 (poly 0x07) over the received bits; received bytes land in
        # the RX FIFO (fifo_dir = 0)
        await tqv.write_word_reg(REG_CRC_POLY, 0x07)
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1

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

        # Received bytes were pushed into the RX FIFO: pop them by reading
        dut._log.info(f"    Testing RX FIFO and CRC8")
        st = await tqv.read_word_reg(REG_FIFO_ST)
        assert (st >> 8) & 0x1F == len(spi_data), f"{st:#x}"
        for rx in spi_data:
            assert await tqv.read_byte_reg(REG_FIFO) == rx
        assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1 == 1
        assert await tqv.read_word_reg(REG_CRC) == crc_bytes_msb_first(spi_data)

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

        # ---- LUT-conditional breakpoint (changes.md item 7) -------------
        # The auto-toggle above started a second transfer (0x36FE0C, first bit
        # 0).  Break in SEND_T0_LOW (compiler row 4) when its "if" fires,
        # i.e. count2 >= compare (51): the FSM must stop with count2 == 51,
        # the transition's count2_clear / shift held off.
        shard = 0 if base == 0 else 1
        dbg   = REG_DBG_CTRL[shard]
        def st():
            return (dbg_status >> (13 * shard)) & 0x1fff
        bp = DBG_BP0_EN | DBG_BP0_SI(4) | DBG_BP0_COND(1)
        await tqv.write_word_reg(dbg, bp)
        for i in range(400):
            await RisingEdge(dut.clk)

        dut._log.info(f"    Testing LUT-conditional breakpoint (shard {shard})")
        dbg_status = await tqv.read_word_reg(REG_DBG_STATUS)
        assert (st() & 0x1f) == 4, f"status {dbg_status:#x}"
        assert st() & DBGS_HALT
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 51
        shc_before = (await tqv.read_word_reg(REG_COUNT2 + base) >> 24) & 0x1f

        # Single step (halt_req held so the FSM stays halted afterwards):
        # the transition and its outputs happen now
        dut._log.info(f"    Stepping out of the conditional breakpoint")
        await tqv.write_word_reg(dbg, bp | DBG_HALT_REQ)
        await tqv.write_word_reg(dbg, bp | DBG_HALT_REQ | DBG_STEP)
        dbg_status = await tqv.read_word_reg(REG_DBG_STATUS)
        assert (st() & 0x1f) == 6, f"status {dbg_status:#x}"      # CHECK_SHIFT_COUNT
        assert st() & DBGS_HALT
        assert await tqv.read_byte_reg(REG_COUNT2 + base) == 0     # count2_clear acted
        shc_after = (await tqv.read_word_reg(REG_COUNT2 + base) >> 24) & 0x1f
        assert shc_after == ((shc_before + 1) & 0x1f), f"{shc_before} -> {shc_after}"  # shift acted

        # Release: breakpoint off, halt_req dropped
        await tqv.write_word_reg(dbg, DBG_HALT_REQ)
        await tqv.write_word_reg(dbg, 0)
        for i in range(6000):
            await RisingEdge(dut.clk)
        dbg_status = await tqv.read_word_reg(REG_DBG_STATUS)
        assert not (st() & DBGS_HALT)
        assert await tqv.read_word_reg(0) & irq_mask != 0

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
    cocotb.start_soon(simulate_uart_rx())

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

    # FIFO in TX mode: host pushes, reads do not pop, status write flushes;
    # CRC registers.  Both with the PRISM disabled, on both shards.
    dut._log.info("Testing FIFO and CRC registers")
    for base in (0, SHARD1):
        await tqv.write_word_reg(REG_CFG0 + base, CFG_FIFO_DIR_TX)
        assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x1F01 == 0x0001   # empty, count 0
        for b in (0x11, 0x22, 0x33):
            await tqv.write_byte_reg(REG_FIFO + base, b)
        st = await tqv.read_word_reg(REG_FIFO_ST + base)
        assert (st >> 8) & 0x1F == 3 and st & 0x3 == 0, f"{st:#x}"
        assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11
        assert await tqv.read_byte_reg(REG_FIFO + base) == 0x11               # TX: no pop on read
        for b in range(13):
            await tqv.write_byte_reg(REG_FIFO + base, 0x40 + b)
        st = await tqv.read_word_reg(REG_FIFO_ST + base)
        assert (st >> 8) & 0x1F == 16 and st & 0x2, f"{st:#x}"                  # full
        await tqv.write_byte_reg(REG_FIFO + base, 0xEE)                        # dropped
        assert (await tqv.read_word_reg(REG_FIFO_ST + base) >> 8) & 0x1F == 16
        await tqv.write_word_reg(REG_FIFO_ST + base, 0)                        # flush
        assert await tqv.read_word_reg(REG_FIFO_ST + base) & 0x1F01 == 0x0001
        await tqv.write_word_reg(REG_CRC_POLY + base, 0x04C11DB7)
        await tqv.write_word_reg(REG_CRC_EXP + base, 0xDEBB20E3)
        assert await tqv.read_word_reg(REG_CRC_POLY + base) == 0x04C11DB7
        assert await tqv.read_word_reg(REG_CRC_EXP + base) == 0xDEBB20E3
        await tqv.write_word_reg(REG_CFG0 + base, 0)
    # the other shard's FIFO must be untouched by the flush above
    assert await tqv.read_word_reg(REG_FIFO_ST) & 0x1F01 == 0x0001

    # FIFO flag input slots: inputs 20 / 21 show two of the own FIFO's four flags
    # and, for shard 0 unfractured, 26 / 27 two of FIFO B's.  Slot select: bit 0
    # = almost- flag, bit 1 = the other side (20 / 26 default empty, 21 / 27 full)
    dut._log.info("Testing FIFO flag input selects")
    await tqv.write_word_reg(REG_FRAC_CFG, 0)
    await tqv.write_word_reg(REG_CFG0 + SHARD1, CFG_FIFO_DIR_TX)
    await tqv.write_word_reg(REG_CFG1 + SHARD1, (4 << 16) | (13 << 20))       # B: ae = count <= 4, af = count >= 3
    for b in range(3):
        await tqv.write_byte_reg(REG_FIFO + SHARD1, b)                        # B holds 3: ae = af = 1
    async def flag_slots():
        v = await tqv.read_word_reg(REG_IN_DATA)
        return ((v >> 20) & 1, (v >> 21) & 1, (v >> 26) & 1, (v >> 27) & 1)
    def sel4(x): return (x << 24) | (x << 26) | (x << 28) | (x << 30)
    await tqv.write_word_reg(REG_CFG1, sel4(0))
    assert await flag_slots() == (1, 0, 0, 0)          # A empty / A full / B empty / B full
    await tqv.write_word_reg(REG_CFG1, sel4(2))
    assert await flag_slots() == (0, 1, 0, 0)          # A full / A empty / B full / B empty
    await tqv.write_word_reg(REG_CFG1, sel4(1))
    assert await flag_slots() == (1, 0, 1, 1)          # A ae / A af / B ae / B af
    await tqv.write_word_reg(REG_CFG1, sel4(3))
    assert await flag_slots() == (0, 1, 1, 1)          # A af / A ae / B af / B ae
    await tqv.write_word_reg(REG_FRAC_CFG, 1)
    assert await flag_slots() == (0, 1, 0, 0)          # fractured: B's slots read 0
    await tqv.write_word_reg(REG_FRAC_CFG, 0)
    await tqv.write_word_reg(REG_CFG1, 0)
    await tqv.write_word_reg(REG_FIFO_ST + SHARD1, 0)
    await tqv.write_word_reg(REG_CFG1 + SHARD1, 0)
    await tqv.write_word_reg(REG_CFG0 + SHARD1, 0)

    # State information integrity: shift a pattern through all four lo CFGMEM
    # macros that make up the 128-bit STEW and read it back (every macro must
    # hold defined data before the PRISM is enabled, or its outputs go X)
    dut._log.info("Testing PRISM state information integrity")
    await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_LO)
    def pattern(inst, k):
        return ((0x10101010 * k) ^ (0x01000100 * inst)) & 0xFFFFFFFF
    for i in range(2):
        for k in range(1, 9):
            for inst in range(STEW_WORDS):
                await cfg.write_word_reg(CFGMEM_REG_LO(inst), pattern(inst, k))
                await cfgmem_wait()

    # ... and the hi macros (bank B, states 16-31): a garbage STEW can jump
    # there, so they must be defined too (their own chain: bypass hi).
    await cfg.write_byte_reg(CFGMEM_REG_CTRL, CFGMEM_CTRL_BYP_HI)
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

    # Unfractured STEW fetch from both banks: halt the debugger, force the
    # state index and read the STEW the core sees.  States 16..31 come from
    # the hi macros (shard 1's SI tracks shard 0's low bits), 0..15 from lo.
    # Row r of the second pattern pass holds pattern(., 8 - r), rows 8..15
    # the first pass shifted up: row 8 + r holds pattern(., 8 - r).
    dut._log.info("Testing unfractured STEW fetch from both banks")
    await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ)
    await tqv.write_word_reg(0x00, 0x40000000)
    await ClockCycles(dut.clk, 8)
    for si, exp in ((20, lambda inst: pattern(inst + 4, 4)), (31, lambda inst: pattern(inst + 4, 1)),
                    (4,  lambda inst: pattern(inst, 4)),     (15, lambda inst: pattern(inst, 1))):
        await tqv.write_word_reg(REG_DBG_CTRL[0], DBG_HALT_REQ | DBG_NEW_SI(si))
        await ClockCycles(dut.clk, 8)
        st = await tqv.read_word_reg(REG_DBG_STATUS)
        assert (st & 0x1f) == si and (st & DBGS_HALT), f"si {si}: status {st:#x}"
        for inst in range(STEW_WORDS):
            got = await tqv.read_word_reg(REG_STEW0 + 4 * inst)
            assert got == exp(inst), f"state {si} STEW word {inst}: {got:#010x} != {exp(inst):#010x}"
    await tqv.write_word_reg(REG_DBG_CTRL[0], 0)
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

    dut._log.info("Testing uart_tx Chroma")
    await test_chroma_uart_tx()

    dut._log.info("Testing fifo_loop Chroma (shard 0 owns both FIFOs)")
    await test_chroma_fifo_loop()

    dut._log.info("Testing edge Chroma (in_prev capture)")
    await test_chroma_edge()

    dut._log.info("Testing fractured PRISM (encoder + ws2812)")
    await test_fractured(clocks_per_phase, encoder0)
    
