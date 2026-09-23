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
REG_IN_DATA    = 0x03C            # shard 0 input vector
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
REG_FIFO_ST = 0x124       # {count[21:8], word bytes[7:6], push busy[5], word full[4], af[3], ae[2], full[1], empty[0]}; write flushes
FIFO_ST_WORD_FULL = 1 << 4  # 32-bit mode: the RX word register holds a complete word (also the shard's interrupt)
FIFO_ST_PUSH_BUSY = 1 << 5  # 32-bit mode: the TX push machine is still feeding a word in
def FIFO_ST_WORD_BYTES(st): return 4 if st & FIFO_ST_WORD_FULL else (st >> 6) & 3   # bytes in the RX word register
REG_FIFO32  = 0x154       # 32-bit FIFO access (CFG3_FIFO32): write pushes four bytes, read takes a complete word
REG_CRC_POLY= 0x128
REG_CRC     = 0x12C       # read value, write preset
REG_CRC_EXP = 0x130
REG_CFG2    = 0x134       # input slot selects (4 bits each: inputs 16-19, 28-31)
REG_CONST   = 0x138       # constants K3..K0 (K3 = comm match value)
REG_CFG3    = 0x13C       # [2:0] Manchester receive pin, [3] enable, [7:4] clocks per half bit, [8] shifter input = recovered bit
                          # [9] double-edge sampling (hb = half clocks per half bit), [27:16] edge-clocked sampler (CFG3_SMP_*)
CFG3_MRX_DDR   = 1 << 9   # recoverer samples the pin on both clock edges
CFG3_FIFO32    = 1 << 11  # 32-bit FIFO access through REG_FIFO32
CFG3_SMP_EN    = 1 << 16  # sampler enable
def CFG3_SMP_SRC(n): return (n & 0x1f) << 17   # the PRISM input whose edge clocks it
CFG3_SMP_RISE  = 0 << 22
CFG3_SMP_FALL  = 1 << 22
CFG3_SMP_ANY   = 2 << 22
CFG3_SMP_SHIFT = 1 << 24  # actions on the edge: shift the shifter
CFG3_SMP_CNT2  = 1 << 25  #   count2 + 1
CFG3_SMP_LATCH = 1 << 26  #   capture the in_prev flops
CFG3_SMP_TIMER = 1 << 27  #   count1 clear / load
CFG3_SMP_INV   = 1 << 28  # flag2 swaps rising and falling (a bidirectional protocol's two edges)
REG_PRELOAD2= 0x140       # timer 2 period (24 bits): input 28 ticks every PRELOAD2 + 1 clocks; 0 = off
T2_RELOAD    = 1 << 24    # restart the count on entry into state T2_STATE(si): retriggerable timeout
def T2_STATE(si): return (si & 0x1f) << 25
T2_ONESHOT   = 1 << 30    # with T2_RELOAD: one tick per entry, then wait for the next entry
REG_CTAB    = 0x14C       # constant table: the latch FIFO as addressable constants (CT_*); [19:16] = the index
REG_COMM_PINS = 0x150     # multi-bit shift lanes: [2:0] window base (comm[base+3:base]), [2k+5:2k+4] lane of uo_out[k+1] (pinmux code 6); was one comm bit per pin [3(k-1)]
def COMM_PINS(*pairs):
    '''(uo_out pin, comm bit) pairs -> COMM_PINS: the bits must fit one 4-bit window'''
    bits = [b for _, b in pairs]
    base = min(4, min(bits)) if bits else 0                 # windows start at 0..4
    assert all(base <= b <= base + 3 for b in bits), "comm bits must fit a 4-bit window"
    v = base
    for uo, b in pairs:
        v |= (b - base) << (4 + 2 * (uo - 1))
    return v
CT_EN        = 1 << 0     # OUT_COMM_LOAD loads comm from the table row at the index
CT_LOAD_ADDS = 1 << 1     # index mode 3 ({K_SEL1, K_SEL0} = 3) adds idx_load instead of loading it
CT_POST      = 1 << 2     # the byte loaded is the row before the index moves (default: after)
def CT_LOAD(n): return (n & 0xf) << 4
def CT_ADD(n):  return (n & 0x7) << 8
def CT_IDX(n):  return (n & 0xf) << 16    # a write sets the index
REG_TRACE_CFG  = 0x144    # trace configuration (TRC_*), write-only
REG_TRACE_CTRL = 0x148    # write TRC_ARM / TRC_STOP; read TRC_ST_*
                          # readout: the traced SRAM's FIFO wrapper serves the 16-bit entries as bytes (low
                          # byte first) through REG_FIFO of the window that reads that SRAM (RX mode forced)

# ---- trace ------------------------------------------------------------------
TRC_EN         = 1 << 0   # this shard's trace owns its SRAM (the SRAM FIFO is held flushed)
TRC_BIG        = 1 << 1   # both SRAMs as one 1024-entry buffer (shard 0 first)
TRC_OTHER      = 1 << 6   # into the other shard's SRAM (this shard's SRAM FIFO keeps running)
TRC_TRIG_NOW   = 0 << 2   # trigger at once
TRC_TRIG_STATE = 1 << 2   # in state TRC_STATE(si)
TRC_TRIG_JUMP  = 2 << 2   # state TRC_STATE(si) taking either jump
TRC_TRIG_EDGE  = 3 << 2   # an edge on PRISM input TRC_INPUT(n)
TRC_EDGE_RISE  = 0 << 4
TRC_EDGE_FALL  = 1 << 4
TRC_EDGE_ANY   = 2 << 4
def TRC_STATE(si): return (si & 0x1f) << 8
def TRC_INPUT(n):  return (n & 0x1f) << 16
TRC_ARM  = 1
TRC_STOP = 2
TRC_ST_ARMED   = 1 << 0
TRC_ST_RUNNING = 1 << 1
TRC_ST_DONE    = 1 << 2
TRC_ST_BIG     = 1 << 3
TRC_ST_ACTIVE  = 1 << 4
TRC_ENTRIES    = 1024     # per SRAM (2 bytes each); both SRAMs = 2048
# entry (16 bits) = [4:0] SI, [10:5] LUT mux inputs, [11] tree 0 matched, [12] tree 1 taken, [13] executing
TRC_E_MATCH0 = 1 << 11
TRC_E_MATCH1 = 1 << 12
TRC_E_EXEC   = 1 << 13
def trace_entry(si, mux, match, ex): return (ex << 13) | ((match & 3) << 11) | ((mux & 0x3f) << 5) | (si & 0x1f)
def trace_si(e):  return e & 0x1f
def trace_mux(e): return (e >> 5) & 0x3f

def stew_of(chroma, si):
    ''' The 128-bit STEW of state si from a chroma word list (highest state
        first, MSW first) '''
    b = (len(chroma) // STEW_WORDS - 1 - si) * STEW_WORDS
    return (chroma[b] << 96) | (chroma[b + 1] << 64) | (chroma[b + 2] << 32) | chroma[b + 3]

# Where the three 21-bit output vectors sit in the STEW comes from the chroma
# compiler's config (chromas/tinyqv32.cfg), the same table prism.v's decode is
# generated from, so the layout is never repeated here.
def _stew_output_positions():
    import os, sys
    chromas = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "chromas")
    sys.path.insert(0, chromas)
    from stew_map import parse_items
    _, _, _, fields = parse_items(open(os.path.join(chromas, "tinyqv32.cfg")).read())
    outs = [pos for typ, pos in fields if typ == "out"]
    return {"tree0": outs[0], "tree1": outs[1], "default": outs[2]}
STEW_OUT_POS = _stew_output_positions()

def stew_field(stew, positions):
    ''' Gather a field from a STEW word: bit i of the result is STEW bit positions[i] '''
    return sum(((stew >> p) & 1) << i for i, p in enumerate(positions))

def trace_outputs(e, chroma):
    ''' The 21 outputs the shard drove in a traced clock, from the entry and
        the chroma (the tree 0, tree 1 or default output vector of the traced
        state, wherever the STEW layout puts them); None while halted '''
    if not e & TRC_E_EXEC:
        return None
    stew = stew_of(chroma, trace_si(e))
    leg = "tree0" if e & TRC_E_MATCH0 else "tree1" if e & TRC_E_MATCH1 else "default"
    return stew_field(stew, STEW_OUT_POS[leg])

CFG_FIFO_DIR_TX = 1 << 23
CFG_COMM_LOAD_K = 1 << 30   # OUT_COMM_LOAD loads K[{out20, out18}] from CONST
CFG_MSHIFT_EN   = 1 << 2    # comm shifts {out20, out18} + 1 bits per OUT_SHIFT (PIO-like)
CFG_SHIFT_DIR_LSB = 1 << 9  # shifter LSB first
CFG_FIFO_SRAM   = 1 << 31   # this shard's FIFO is its SRAM FIFO
FLAG_CRC_OK     = 1 << 10   # FLAGS: CRC value == CRC_EXPECTED
FLAG_SMP_PENDING = 1 << 11  # FLAGS: sampler edge not yet consumed by the FSM (OUT_SHIFT / OUT_LATCH)

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
