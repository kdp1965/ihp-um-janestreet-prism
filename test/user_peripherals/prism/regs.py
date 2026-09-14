# Register map and small helpers shared by the PRISM unit tests
# (docs/prism_interface.md is the reference).

PERIPHERAL_NUM        = 8
CFGMEM_PERIPHERAL_NUM = 4

# ---- CFGMEM loader peripheral (holds the PRISM state table) -----------------
CFGMEM_REG_CTRL       = 0x1f            # byte register
CFGMEM_CTRL_ADDR_SEL  = 1 << 4
CFGMEM_CTRL_BUSY      = 1 << 5
CFGMEM_CTRL_BYP_LO    = 1 << 6
CFGMEM_CTRL_BYP_HI    = 1 << 7
def CFGMEM_REG_LO(i): return i * 4
def CFGMEM_REG_HI(i): return 0x20 + i * 4

STEW_WORDS  = 4      # 128-bit STEW (chromas/tinyqv32.cfg)
BANK_STATES = 16     # rows per CFGMEM bank

# ---- PRISM common block ------------------------------------------------------
REG_CTRL       = 0x000       # [31] shard 0 IRQ (RO) [30] enable [29] shard 1 IRQ (RO)
REG_INT_CLR0   = 0x003       # byte write bit 7: clear shard 0 interrupt
REG_INT_CLR1   = 0x007       # byte write bit 7: clear shard 1 interrupt
REG_DBG_CTRL   = (0x004, 0x008)   # per shard
REG_DBG_STATUS = 0x00C            # shard 0 in [12:0], shard 1 in [25:13]
REG_STEW0      = 0x010            # 4 words: STEW of shard 0's current state
REG_INT_STATUS = 0x024
REG_IN_DATA    = 0x03C            # shard 0 input vector (live)
REG_FRAC_CFG   = 0x040
REG_OUT_MASK0  = 0x044
REG_COND_MASK0 = 0x048
REG_OUT_MASK1  = 0x04C
REG_COND_MASK1 = 0x050

CTRL_ENABLE = 0x40000000
IRQ0_MASK   = 0x80000000  # CTRL bit 31: shard 0 interrupt
IRQ1_MASK   = 0x20000000  # CTRL bit 29: shard 1 interrupt

# ---- shard window (shard 0 at 0x100, shard 1 at 0x180) ------------------------
SHARD1      = 0x080       # add to a REG_* below for the shard 1 window
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
REG_FIFO    = 0x120       # byte: write pushes (TX mode), read pops (RX mode)
REG_FIFO_ST = 0x124       # {count[12:8], af[3], ae[2], full[1], empty[0]}; write flushes
REG_CRC_POLY= 0x128
REG_CRC     = 0x12C       # read value, write preset
REG_CRC_EXP = 0x130
REG_CFG2    = 0x134       # input slot selects (4 bits each: inputs 16-19, 28-31)
REG_CONST   = 0x138       # constants K3..K0 (K3 = comm match value)
REG_CFG3    = 0x13C       # [2:0] Manchester receive pin, [3] enable, [7:4] clocks per half bit, [8] shifter input = recovered bit

CFG_FIFO_DIR_TX = 1 << 23
CFG_FIFO_SRAM   = 1 << 31   # this shard's FIFO is its SRAM FIFO
FLAG_CRC_OK     = 1 << 10   # FLAGS: CRC value == CRC_EXPECTED

# ---- debugger ---------------------------------------------------------------
DBG_HALT_REQ   = 0x00001
DBG_STEP       = 0x00002
DBG_BP0_EN     = 0x00004
def DBG_BP0_SI(si):   return (si & 0x1f) << 4
def DBG_BP0_COND(c):  return (c & 3) << 14   # 0 entry, 1 if, 2 else-if, 3 any
def DBG_NEW_SI(si):   return (1 << 18) | ((si & 0x1f) << 19)
DBGS_HALT      = 0x400                        # in a shard's 13-bit status field


# ---- CRC models --------------------------------------------------------------
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
