# PRISM peripheral, Phase 0: interface budget, config bits, memory map

Working document for the changes listed in `changes.md`.  Everything here is
a proposal to be edited; the numbers that are fixed by hardware already in
place are marked as such.

Fixed by the current core / cfg (`chromas/tinyqv32.cfg`): 32 inputs and 21
outputs per shard, 6 input muxes of 5 bits, two LUT3 decision trees, two
LUT2 conditional outputs, 32 states (16 per shard when fractured), 128-bit
STEW in the CFGMEM macros, 512-byte register region at 0x8000200.

## 1. Outputs per shard (21)

From `changes.md` item 12, with the spares filled in as suggestions.

| bit | name | notes |
|---|---|---|
| 0 | pin_out[0] | muxable to uo_out[7:1] |
| 1 | pin_out[1] | muxable to uo_out[7:1] |
| 2 | pin_out[2] | muxable to uo_out[7:1] |
| 3 | pin_out[3] | muxable to uo_out[7:1] |
| 4 | OUT_LATCH | re-capture the in_prev flops selected by the firing tree (edge-detect ack); also usable in the default word for free-running capture |
| 5 | OUT_FIFO_WR_RD | FIFO push of comm (RX mode) / pop into comm (TX mode), per CFG0 fifo_dir (Phase 4) |
| 6 | OUT_COUNT1_INC_DEC | count1 step, direction from config (count up / down) |
| 7 | OUT_COUNT1_CLEAR_LOAD | clear, or load from preload, per config |
| 8 | OUT_SHIFT | shift the 24/32-bit or the 8-bit shifter (config selects which) |
| 9 | OUT_COUNT2_INC | |
| 10 | OUT_COUNT2_DEC | |
| 11 | OUT_COUNT2_CLEAR | |
| 12 | OUT_CRC_CLEAR | reset CRC to init value |
| 13 | OUT_CRC_UPDATE | feed the shifter's current bit (or byte) into the CRC |
| 14 | OUT_HOST_INTERRUPT | set the shard's sticky interrupt flag once per assertion (edge-detected in the peripheral, not re-armed every clock the state persists); two interrupt lines to the host, one per shard |
| 15 | OUT_SEMA_CLEAR / OUT_FIFO_PUSH_POP | fractured: clear the semaphore the other shard set for us (setting it towards the other shard rides on OUT_SEMA_SET).  Unfractured (shard 0): bit 5 strobes FIFO A (0) or FIFO B (1), i.e. push / pop with A = RX, B = TX; see 4b |
| 16 | OUT_COMM_LOAD | load comm from preload[7:0], or from constant K[{out20, out18}] with CFG0[30] (4h) |
| 17 | OUT_LOAD_CRC | load the selected shifter from the CRC: the wide shifter takes all 32 bits, comm takes one byte per load in wire order and the CRC advances to the next byte (4h) |
| 18 | OUT_K_SEL0 | constant select bit 0 for OUT_COMM_LOAD when CFG0[30] is set (4h) |
| 19 | OUT_SEMA_SET / OUT_FLAG2 | fractured: set the sticky semaphore seen by the other shard.  Also the value OUT_LATCH stores in flag2 with CFG0[29] (4h) |
| 20 | OUT_K_SEL1 | constant select bit 1 (4h) |

Chroma-visible change vs today: OUT_SHIFT moves from 6 to 8 and the count
controls are renumbered; the four test chromas and `chromas/*.v` need their
`out_data[]` assignments updated when this lands (mechanical).

## 2. Inputs per shard (32)

Bits 0-15 keep today's meaning so the existing chromas stay valid; new
features take 16 and up.

| bit | name | source |
|---|---|---|
| 0-6 | pin_in[6:0] | ui_in[6:0] via the per-shard raw / 1-flop / 2-flop select (item 13) |
| 7 | shift_data | serial-out bit of the selected shifter |
| 8-9 | host_in[1:0] | host handshake bits |
| 10 | count1_term | count1 == 0 counting down; count1 == preload (or natural roll-over) counting up (item 3) |
| 11 | count2_cmp | count2 >= count2_compare |
| 12-13 | latched_in[1:0] | {shift_data, cond_out[0]} captured by OUT_LATCH (the SPI slave and encoder chromas rely on it), or the latched outputs with CFG0[7] |
| 14 | shift_term | shift count reached the configured length (with the "load sets count to 1" mode, items 4/5) |
| 15 | count2_eq_comm | count2 == comm_data |
| 16-19 | slots, default in_prev[3:0] | input slots (4h): CFG2 picks in_prev[k], a comm bit, comm == K3 or flag2; default = the edge-capture flops (sources CFG1[15:0], see 4g) |
| 20 | fifo flag slot E | own FIFO: empty by default; CFG1[25:24] selects almost-empty / full / almost-full |
| 21 | fifo flag slot F | own FIFO: full by default; CFG1[27:26] selects almost-full / empty / almost-empty |
| 22 | crc_ok | CRC residue equals the expected / magic value |
| 23 | count1_wrap | count1 rolled over (count-up natural mode) |
| 24 | sema_in | sticky semaphore set by the other shard's OUT_SEMA_SET, cleared by this shard's OUT_SEMA_CLEAR (same-cycle winner = CFG0[24]); implemented Phase 2 |
| 25 | other_shard_halt | the other shard is halted (debugger); implemented Phase 2 |
| 26-27 | FIFO B flag slots E / F | shard 0 unfractured: two of shard 1's FIFO flags, selects CFG1[29:28] / [31:30]; 0 otherwise |
| 28-31 | slots, default 0 | input slots (4h): CFG2[31:16], same menu |

Note on the trees: tree 0 reads muxes 0-2, tree 1 reads 3-5, cond 0 reads
muxes 1 and 4, cond 1 reads 3 and 5 (RTL wiring, matched by the cfg).

## 3. Per-shard configuration bits (non-state-specific)

Held in the shard's CFG0 / CFG1 registers (section 4).  Today's 14 control
bits are kept where they are; `fifo_24` (bit 11) is freed by item 2.

CFG0 (existing layout, extended):

| bits | name | notes |
|---|---|---|
| 1:0 | shift_in_sel | which ui_in feeds the shifter |
| 3:2 | shift_out_sel | which uo_out carries shift_data |
| 5:4 | cond_out_sel | which uo_out carries cond_out[0] |
| 6 | load4 | 8-bit comm load from preload (renamed in item 2 cleanup) |
| 7 | latch_in_out | in[13:12] = latched outputs instead of latched inputs |
| 8 | shift_en | |
| 9 | shift_dir | 0 = MSB first, 1 = LSB first |
| 10 | shift_wide | 0 = 8-bit comm shifter, 1 = 24/32-bit shifter (was shift_24_en) |
| 11 | count_width | 0 = 24-bit, 1 = 32-bit (item 3; was fifo_24) |
| 12 | count2_dec_en | |
| 13 | latch_en | OUT_LATCH enable (was latch3) |
| 24 | sema_set_wins | semaphore set beats clear in the same cycle (else clear wins) |
| 14 | count_up | count1 counts up (item 3) |
| 15 | wrap_at_preload | count-up roll-over at preload instead of natural (item 3) |
| 16 | shift_load_one | 24/32-bit shift load sets shift count to 1 (item 4) |
| 17 | comm_load_one | 8-bit comm load sets its count to 1 (item 5) |
| 19:18 | in_sync_sel | 0 = 2 flops (today), 1 = 1 flop, 2 = raw (item 13) |
| 21:20 | crc_mode | 0 = off, 1 = CRC8, 2 = CRC16, 3 = CRC32 (item 8) |
| 22 | crc_reflect | bit order into the CRC |
| 23 | fifo_dir | OUT_FIFO_WR_RD pushes (TX) or pops (RX) |
| 25 | crc_init_ones | |
| 26 | crc_xor_out | |
| 27 | crc_src | 0 = shifter input bit, 1 = shifter output bit |
| 28 | shift_in_cond | the shifter shifts in cond_out[0] instead of a pin: an FSM-decoded bit (NRZI, Manchester) or a constant (4h) |
| 29 | flag_latch | OUT_LATCH stores {cond_out[1], cond_out[0]} in latched_in and output 19 in flag2: three FSM-settable flags (4h) |
| 30 | comm_load_k | OUT_COMM_LOAD takes constant K[{out20, out18}] from CONST instead of preload[7:0] (4h) |
| 31 | fifo_sram | this shard's FIFO is the 8 KB SRAM FIFO (4i); one per PRISM, shard 0 wins if both ask |

CFG1 (as built):

| bits | name | notes |
|---|---|---|
| 3:0 | in_prev0_src | PRISM input number the flop follows: 0-6 = ui_in pin (after the sync select), 8 = host_in[0], 9 = host_in[1]; anything else reads 0 |
| 7:4 | in_prev1_src | |
| 11:8 | in_prev2_src | |
| 15:12 | in_prev3_src | |
| 19:16 | fifo_ae_level | almost-empty when count <= level |
| 23:20 | fifo_af_level | almost-full when count >= 16 - level |
| 25:24 | fifo_flag20 | input 20 (empty side): bit 0 = almost-, bit 1 = other side |
| 27:26 | fifo_flag21 | input 21 (full side): bit 0 = almost-, bit 1 = other side |
| 29:28 | fifo_b_flag26 | input 26, FIFO B (shard 0 unfractured), empty side |
| 31:30 | fifo_b_flag27 | input 27, FIFO B, full side |

The flag slots let any two of a FIFO's four flags reach the two inputs
(a pusher wants full / almost-full, a popper empty / almost-empty) while
the reset value keeps the original meaning, empty on 20 and full on 21.

CFG2 (+0x34, per shard, 4h): eight 4-bit input slot selects, [3:0] ..
[15:12] for inputs 16-19 and [19:16] .. [31:28] for inputs 28-31.  Codes:
0 = the slot's default (in_prev[k] for 16-19, 0 for 28-31), 1-4 =
in_prev[0..3], 5-12 = comm[0..7], 13 = comm == K3, 14 = flag2.  The comm
bits let the decision trees decode a received byte (a USB PID, a
command) without a match register per value.

CONST (+0x38, per shard, 4h): four constants K0 [7:0] .. K3 [31:24].
With CFG0[30] OUT_COMM_LOAD loads comm from K[{out20, out18}] (sync
words, handshake codes, addresses); K3 is also the comm match value.

Common (not per shard): enable, fractured, interrupt enables/status, output
masks for fractured mode, debug controls (already in the core).

## 4. Memory map (512-byte region at 0x8000200), item 10

All registers word aligned at +4 offsets.  Sub-word reads return the
addressed byte lane in the low bits of the read data (TinyQV convention,
same as the CFGMEM control byte), so packed registers can be read and
written one byte at a time.

Common block 0x000-0x0FF:

| offset | register |
|---|---|
| 0x00 | CTRL: [30] enable, [31] shard 0 interrupt (RO), [29] shard 1 interrupt (RO); byte 0x03 write with bit 7 = shard 0 interrupt clear (kept: a single byte store is what chromas like PCM/ADPCM rely on), byte 0x07 = shard 1 interrupt clear.  Shard interrupts are TinyQV user interrupts 8 and 9 |
| 0x04 | DBG_CTRL0 (shard 0, exists) |
| 0x08 | DBG_CTRL1 (shard 1, exists) |
| 0x0C | STATUS (curr/next SI, halt, break, per shard; exists) |
| 0x10-0x1C | STEW of shard 0's current state (exists) |
| 0x20 | ID word |
| 0x24 | INT_STATUS (read): [1:0] shard interrupts, [3:2] semaphore as seen by shard 0 / shard 1 |
| 0x30 | DEBUG_DOUT (exists) |
| 0x34 | DECISION (exists) |
| 0x38 | OUT_DATA (exists) |
| 0x3C | IN_DATA (exists) |
| 0x40 | FRAC_CFG (exists) |
| 0x44-0x50 | fracture output / cond masks (exist; could move into the shard windows) |
| 0x60-0xFC | spare |

Shard windows, identical layout, shard 0 at 0x100, shard 1 at 0x180
(Phase 2 implemented +0x00..+0x18 for both shards in `prism_periph.v`, each
with its own `prism_datapath`; the rest is reserved for later phases).
Unfractured, shard 0 is the whole machine and shard 1's datapath idles
(its registers stay accessible).  Fractured, each shard's own output vector
drives its own datapath, so OUT_SHIFT from shard 1 shifts shard 1's
registers only:

| offset | register |
|---|---|
| +0x00 | CFG0: datapath configuration (chroma `ctrl_reg`, bit map in section 3) |
| +0x04 | PINMUX: uo_out[7:1] source selects (chroma `pinmux_reg`, 3 bits per pin: 0-3 this shard's pin_out[n], 4/5 its cond_out[n], 6 its shift_data, 7 = this shard does not drive the pin).  A pin claimed by shard 0 goes to shard 0, otherwise to shard 1; a pin freezes while its owning shard is halted |
| +0x08 | PRELOAD (32-bit) |
| +0x0C | COUNT1 (24/32-bit; read = count, write = load) |
| +0x10 | COUNTS packed: byte 0 COUNT2, byte 1 COMPARE, byte 2 COMM, byte 3 {comm_count[2:0], shift_count[4:0]} (RO); word or byte writes load the first three |
| +0x14 | HOST_IN[1:0]; byte +0x15 write = toggle host_in[0] and clear the interrupt |
| +0x18 | FLAGS (RO): count1_term, count1_wrap, count2_cmp, count2_eq_comm, shift_term, shift_data, latched_in[1:0] |
| +0x1C | CFG1: `in_prev` pin selects, FIFO thresholds (later; the input sync mode landed in CFG0[19:18]) |
| +0x20 | FIFO data (byte lane 0) |
| +0x24 | FIFO status: count, empty, full; write = flush |
| +0x28 | CRC ctrl: init value select, poly select |
| +0x2C | CRC value (read; write = preset) |
| +0x30 | CRC expected |
| +0x34 | CFG2: input slot selects for inputs 16-19 and 28-31 (4 bits each), section 4h |
| +0x38 | CONST: K0..K3 (K3 also the comm match value), section 4h |
| +0x3C | CFG3: Manchester bit recoverer ([2:0] pin, [3] enable, [7:4] clocks per half bit, [8] shifter input = recovered bit), section 4k; edge-clocked sampler ([16] enable, [21:17] clock input, [23:22] 0 rising / 1 falling / 2 either, actions on the edge [24] shift, [25] count2 + 1, [26] in_prev capture, [27] count1 clear / load, [28] flag2 swaps rising and falling), section 4p |
| +0x40 | PRELOAD2: timer 2, [23:0] period (input 28 ticks every PRELOAD2 + 1 clocks, 0 = off), [24] restart the count on entry into state [29:25] (retriggerable timeout), [30] one-shot (with [24]: one tick per entry), section 4l |
| +0x44 | TRACE_CFG (write-only, 21 bits): [0] enable (one shard traces at a time, shard 0 wins), [1] both SRAMs as one buffer, [6] into the other shard's SRAM (this shard's SRAM FIFO keeps running), [3:2] trigger (0 now, 1 in state [12:8], 2 that state taking a jump, 3 an edge on PRISM input [20:16]; [5:4] 0 rising, 1 falling, 2 either), section 4m |
| +0x4C | CONST_TAB: the 16x8 latch FIFO as addressable constants, section 4n: [0] enable (OUT_COMM_LOAD loads the row at the 4-bit index; {OUT_K_SEL1, OUT_K_SEL0} = how the index moves on each load: 0 clear, 1 + 1, 2 + add_to_idx [10:8], 3 = idx_load [7:4], or + idx_load with [1]), [2] post (the row before the move; default after), [19:16] the index (a write sets it, reads back live) |
| +0x48 | TRACE_CTRL: write [0] arm (flushes the SRAM FIFO), [1] stop; read [0] armed, [1] running, [2] done, [3] big, [4] active.  Entry (16 bits) = [4:0] SI, [10:5] LUT mux inputs, [11] tree 0 matched, [12] tree 1 taken, [13] executing; the traced SRAM's FIFO then serves the entries as bytes through +0x20 of the window that reads that SRAM (count = FIFO bytes / 2) |
| +0x4C-0x7C | spare |

The SDK (`prism.h`, item 11) then needs only a base per shard and the
common block; the per-config remap is the base addresses plus a feature
mask.

## 4a. Debugger: LUT-conditional breakpoints (item 7, Phase 3)

Each shard's debug control word (0x04 shard 0, 0x08 shard 1) gained a
2-bit condition per breakpoint:

| bits | field | meaning |
|---|---|---|
| 0 | halt_req | level: halt (rising edge) and hold |
| 1 | step | rising edge: execute one transition |
| 2, 3 | bp_en0, bp_en1 | breakpoint enables |
| 8:4, 13:9 | bp_si0, bp_si1 | breakpoint state index |
| 15:14, 17:16 | bp_cond0, bp_cond1 | 0 = on entry (as before), 1 = in the state when tree 0 ("if") matches, 2 = when tree 1 ("else if" / "else") is taken (matches while tree 0 does not; a plain `else` compiles to an always-true tree 1), 3 = when either is taken, i.e. the state exits |
| 18 | new_si | write-only: load the SI from bits 23:19 |

Read back = {debug_si[22:18], control[17:0]}.  Status (0x0C) is unchanged.

Semantics of a conditional break: in the cycle the selected decision tree
first matches while the FSM sits in `bp_si`, the core forces `next_si =
curr_si`, holds the loop bookkeeping, and raises the shard's halt line
combinationally.  The peripheral gates every datapath action, pin latch,
semaphore and interrupt edge with that line, so the transition's outputs
(counter clears, shifts, loads) do not happen: the value that satisfied
the condition is still there to read.  A single step then performs the
transition with its outputs and halts in the target state.  Keep
`halt_req` set while stepping: without it (or an active breakpoint) the
FSM resumes after a step that lands on a non-breakpoint state.  Release
from any breakpoint halt: clear the enable, pulse `halt_req`.

The halt line is now combinational for that one cycle, which also removed
the extra registered `halt_r` term from the datapath enable: a single step
now applies the stepped state's datapath outputs (previously the step
cycle was gated off, so stepping through a counting state never counted).

## 4b. FIFO and CRC per shard (items 8, 9, Phase 4)

As built in `prism_fifo.v` / `prism_crc.v`, one of each per shard:

FIFO: 16 x 8 bits, standard cells.  Direction is CFG0[23] `fifo_dir`:
RX (0) the FSM pushes `comm` with OUT_FIFO_WR_RD and the host pops by
reading +0x20; TX (1) the host pushes by writing +0x20 and OUT_FIFO_WR_RD
pops the head into `comm` (a load: comm_count follows `comm_load_one`).
Push on full and pop on empty are ignored.  +0x24 reads
{count[21:8], almost_full[3], almost_empty[2], full[1], empty[0]}; any
write flushes.  CFG1[19:16] / [23:20] are the almost-empty (count <=)
and almost-full (count >= 16 - level) levels.  Inputs 20 empty, 21 full,
26 almost_full, 27 almost_empty.  Contents survive PRISM disable, so a TX
FIFO can be filled before the FSM starts.

CRC: 32-bit bit-serial LFSR, programmable polynomial (+0x28), width from
CFG0[21:20] `crc_mode` (8 / 16 / 32), CFG0[22] `crc_reflect` (shift right,
reflected polynomial; width independent so USB CRC5 = poly 0x14 also
works), CFG0[25] `crc_init_ones` (OUT_CRC_CLEAR presets all ones or zero),
CFG0[27] `crc_src` (0 = the shifter's input bit, 1 = its output bit; take
it in the same cycle as OUT_SHIFT), CFG0[26] `crc_xor_out` (complement
when loaded into a shifter).  +0x2C reads the value, a write presets it;
+0x30 is the expected value; input 22 `crc_ok` = value == expected over the
width.  New output 17 OUT_LOAD_CRC loads the selected shifter (comm or
count1, per `shift_wide`) from the CRC so the checksum can be sent; through
comm each load takes the next byte in wire order (low byte first for
reflected CRCs, high byte first otherwise) and advances the CRC register,
so CRC16 / CRC32 go out in 2 / 4 loads (4h).

Two FIFOs for shard 0 (unfractured, 2026-09-13): shard 1's FIFO and its
OUT_SEMA_CLEAR output are idle while unfractured, so shard 0 owns both
FIFOs: A = its own, B = shard 1's, which the host still configures
(direction CFG0[23], levels CFG1) and serves (+0x20 / +0x24) through the
shard 1 window at 0x180.  OUT_FIFO_WR_RD strobes A when output 15, now
OUT_FIFO_PUSH_POP, is 0 and B when it is 1, each per its own direction
(push comm into an RX FIFO, pop a TX FIFO into comm).  With the usual
arrangement, A = RX and B = TX, bit 15 reads as push (0) / pop (1), and a
single-FIFO chroma (bit 15 never set) behaves exactly as before whatever
the host does with B.  A pop loads comm from the selected FIFO's head.
Shard 0 inputs 26 and 27 are two of FIFO B's flags, chosen by CFG1[31:28]
the same way inputs 20 and 21 choose the own FIFO's (section 3).
Fractured, everything is per shard as before and bit 15 is the semaphore
clear again.  `chroma_fifo_loop` (unit test) moves bytes from B (TX) to A
(RX) and counts them in count2.

Chromas: `chroma_spislave` pushes received bytes into the RX FIFO and runs
a CRC8 over the received bits; `chroma_uart_tx` is an 8N1 transmitter fed
from the TX FIFO that appends the CRC8 on request.

## 4c. Host software (item 11, Phase 5)

The tinyQV-sdk driver (`prism.h` / `prism.c`) covers this design with
`-DPRISM_CONFIG=PRISM_CONFIG_JANESTREET` (`prism_cfg_janestreet.h` holds the
register map above; `tinyQV-js.a` or `prism_js.o`).  The sky25a API is kept:
per-shard calls act on `prism_set_shard()`, `prism_set_ctrl()` writes the
shard's CFG0 plus the common enable, `prism_load_chroma_ex()` adds the pin
mux and `prism_load_shards()` fractures with two chromas.  `test/programs/
sdk_check` runs that driver on the RTL (`make sdk_check` in `test/`).

## 4d. Floorplan and timing (item 1, Phase 6)

Plan of record (2026-09-13): the eight macros sit along the top of the
tile as one 2x2 block per bank.  Bank A (lo macros): lo2/lo3 (`CFGMEM_IHP16`,
control pins west, facing the left margin) at x = 101.44 um and lo0/lo1
(`CFGMEM_IHP_LEFT16`, control pins east, facing the inter-bank channel) at
451.44 um.  Bank B (hi macros): hi2/hi3 (pins west, facing the channel) at
951.44 um and hi0/hi1 (pins east, facing the right margin) at 1301.44 um.
The top row is upright (`N`, data pins down) at y = 619.92 um (row 163) and
the second row flipped (`FS`, data pins up) at y = 510.30 um (row 134), so
both rows' 70 data pins face the 6-row channel between them and the whole
lower ~60% of the tile (rows 0-133) stays free for future macros (an SRAM
is planned).  The programming chain of each bank stays inside its block
(section 4f).  x positions are 1.44 + 50k um so the macro stripes land on
tile PDN stripes; the stripe step accepts R0 and MX since a vertical flip
keeps the pin columns.  The earlier two-column layout (x = 751.44 /
1351.44 um, four macros per column facing two 44-row cell areas) is kept
for comparison in the table below.  The stripe-extension step is now a LibreLane plugin
(`librelane_plugin_prism_pdn.py`) inserted through `meta.substituting_steps`
in `src/config.json`, so the stock Tiny Tapeout harden connects the macro
power too (`make harden-tt` runs exactly that).

Timing after Phases 1-4 roughly doubled the cell count (13.7k -> 26.9k,
utilization 34% -> 46%).  Decisions taken to close the typical corner,
which is the one the flow treats as fatal:

- `ui_in` setup paths are false paths (hold still checked): in raw mode
  the pins feed the decision trees combinationally by choice, and the TT
  input model leaves only 35% of the period for that.
- `cfg_fractured` gets a 2-cycle multicycle path: it only changes while
  the PRISM is disabled, and it was the head of the worst slow-corner path
  (bank-select mux -> CFGMEM read -> decision -> state).
- The peripherals' reset is re-registered on the rising edge
  (`rst_peri_n` in project.v): the ~1500 PRISM flops behind it gave the
  negedge `rst_reg_n` tree only a half cycle, the tightest internal path.
- `MAX_TRANSITION_CONSTRAINT` 0.75 ns, `MAX_FANOUT_CONSTRAINT` 8 and
  `PNR_CORNERS` = typ + slow so the resizer repairs the slow corner too
  (the fatal check stays on the PDK's `TIMING_VIOLATION_CORNERS`).
- The CFGMEM programming chain inputs (`Di0`) are false paths, and the
  loader's host/PRISM address select, host row address and bank bypass
  bits get 2-cycle multicycle paths: all of them only change while the
  PRISM is disabled, and each headed a worst path (through a macro read
  and the decision trees) in some floorplan.

Floorplan experiments (all with the exceptions above, physical signoff
clean in every case; "PRISM path" = state register -> macro read ->
decision -> datapath register at typ / slow):

| floorplan                       | typ WNS | PRISM path      | GRT overflow | DRT iters |
|---------------------------------|---------|-----------------|--------------|-----------|
| two columns (previous)          | +1.18   | +1.60 / -5.63   | 2296         | 12        |
| 1x4 rows stacked at the top     | +0.97   | +1.21 / -6.32   | 2061         | 10        |
| 2x2 block per bank (POR)        | +0.91   | +1.07 / -6.41   | 2149         | 13        |

The stacked and 2x2 layouts leave the lower ~60% of the tile free for
future macros; the two-column layout keeps each bank's four words closest
to the logic between the columns, which is where its PRISM-path margin
comes from.  Typ WNS is the CPU's QSPI clock output path in the stacked
and 2x2 runs.  The 2x2 layout was chosen for the open area.

### 4d.1 Floorplan with the SRAM (2026-09-14)

Adding the 1024x32 SRAM (section 4i) broke every floorplan that had
routed before, and the reasons turned out to be structural rather than a
matter of density:

- **A CFGMEM column is a routing wall.**  Global-routing overflow maps
  (`global_route -congestion_report_file` on the pre-route ODB, binned
  50 um) of the reference two-column run and of every SRAM layout put all
  the overflow over the LEFT16 column and its cell strips, none in the
  open half of the tile.  The macro blocks Metal2 completely and its Metal3
  route-through is chopped into short pieces, so east-west crossings only
  fit in the 166 um strips between the four macros.  Any logic on the far
  side of a column from the channel (TinyQV, the SRAM wrapper) pays for
  that; spreading the placement (target density 40) made it worse.
- **The SRAM is a wall on every layer.**  Its LEF obstructs Metal1-3 fully
  and Metal4 everywhere except its own 2.81 um power columns (0.26 um
  margin), so nothing crosses it, and a stripe over it must sit inside a
  column of the same polarity.  The columns alternate VDD/VSS every 5.62 um
  (11.24 um per polarity) in two 16-column halves, the right one 0.67 um
  off the left one's grid, around a ~57 um irregular centre band.  Its 190
  signal pins are Metal2 on one long face (`FS` puts them on top).
- **The first SRAM FIFO wrapper was the area problem**, not the SRAM:
  1380 cells / 20k um2 (section 4i); the word-assembly rewrite is 9.7k.

Column layouts with the SRAM flush left (wrapper above it, pins on top):

| layout (LEFT16 column x, SRAM x)             | GRT overflow | DRT                          |
|----------------------------------------------|--------------|------------------------------|
| 751 / 3.36, byte-queue wrapper               | 4354         | 33k 22k 19k 8.8k 6.4k (stopped) |
| 751 / 3.36, word wrapper                     | 8179         | not run                      |
| 451 / 3.36 (31 um corridor to the SRAM)      | 2237         | plateau ~105: all shorts inside the SRAM, the corridor overflowed and the router forced wires through the macro |
| 501 / 3.36 (81 um corridor)                  | 1803         | 24354 11729 10634 772 39 20 11 11 0 |

The 501 layout routes; its typ setup slack is +0.79 ns.  It is kept as
the fallback (`src/config_left501.json`).

**Band layout on the SRAM's grid (user's plan).**  To put the 2x2 band
back at the top with the SRAM underneath, the tile stripes have to run
through the SRAM on its columns and through the CFGMEM macros on their
rails at the same x.  Both macro types were regenerated in DFFRAM with
`PDN_VPITCH` 44.96 (= 4 x 11.24) and `PDN_VSPACING` 3.52 (VGND 5.62 um
from VPWR), rails at 11.44 / 17.06 + 44.96k from the macro origin, one
minute per macro, DRC/LVS clean.  The tile uses the same pitch and
spacing with `FP_PDN_VOFFSET` 6.15, so the first VPWR stripe is at 9.03 um
= the SRAM at x 3.36 plus its first VDD column; CFGMEM macros then go at
x = -2.41 + 44.96k and the SRAM at 3.36 + 11.24i.  With that, ten stripe
pairs cross the SRAM: four exact, five nudged 0.67-0.83 um (still
overlapping the rail above by 1.3-1.4 um of its 2.1), two redrawn on the
nearest centre-band column (~10 um; the rail above them is fed through
the macro's Metal1 row rails instead).  The stripe step (`odb_stripes.py`)
collects SRAM columns and all rails first, keeps redrawn stripes 0.24
um clear of opposite-polarity rails, treats any stripe overlapping the
SRAM as crossing it, and skips a rail stripe that would cross the SRAM
off-column.

The SRAM has three regions with separate internal meshes: two bit-cell
arrays (`VDDARRAY!`/`VSS!` columns, with the periphery's `VDD!` columns
below them on the same x) and, between them, a ~40 um band of the
macro's own standard cells (four full-height `VDD!` columns and the
`VSS!` columns beside them).  Moving every tile stripe onto its nearest
column left the band with two VPWR but one VGND, and the right array's
edge with a VGND but no VPWR (the partner of each had landed in the
other region).  The step therefore allocates both nets at once per
macro: nearest free column first, then a stripe whose partner sits in
another region gets a partner on the adjacent column of its own region,
and the band always gets at least two VPWR/VGND pairs.  On the 512x32
that is 4 + 2 + 5 pairs, 11 stripes per net for the 10 the grid gives
(Uri: any number of full-height power pins is fine).

The step ends with a tidy pass, because the abstract LEF turns every
Metal4 VPWR/VGND box into a PORT rect and the Tiny Tapeout pin check
(`tt/precheck/pin_check.py`) rejects a power port rect that stops more
than 10 um from the bottom or the top edge.  pdngen leaves three
partial-height segments between the four macros of each CFGMEM column at
every rail x (the full-height rail stripe is drawn next to them, once per
macro), and beside the IHP16 column it adds a channel-repair VGND stripe
at x 1700.64 in four pieces: the 2 um halo starts the short rows there at
x 1680, past the grid VGND stripe at 1678.17, so those 98 rows had no
other VGND feed.  Before the tidy pass the final LEF had 94 of 141 power
port rects failing that rule.  Now each stripe x keeps exactly one
full-height box and one pin box; the repair stripe is extended to full
height with rail vias on the rows it newly crosses (40 pin boxes per net).  Placement rules learned: no sliver channel next to a macro
(SRAM at 7.21 left 3.84 um to the core edge: PDN-0179), keep the SRAM out
of the tile pin zone x 29.76-191.04 (Metal4 pin stubs on a 3.84 um pitch
that no 44.96 grid interleaves with), and 2 um horizontal macro halo
(KLayout NW.b: n-well spacing 1.24 um where cells abut the SRAM).

| band variant                                                 | GRT overflow |
|--------------------------------------------------------------|--------------|
| SRAM at 187 (pocket to its west filled with TinyQV)          | 13764        |
| SRAM flush left, both rows facing the 22.68 um gap           | 5341         |
| SRAM bottom right (1284.72), lower row pins facing down      | 3643         |

| 60 um gap, column D lower macro facing the gap               | 4483 (10% more wire: the band ate 65k um2 of cell area) |
| as row 3 but only column D's lower macro facing the gap (v6)  | 2884, DRT to 0 in 12 iterations, KLayout DRC 0, LVS clean, typ +0.38 ns / hold +0.002 ns |

Row 3 (v4) ran detailed routing to a plateau of 357 violations, every one
of them inside the SRAM footprint: the hi programming chain from column
D's downward-facing lower macro to column C dived through the SRAM because
the corridor above it also held the wrapper and the SRAM pins.  Nothing
else in the band layout was left unrouted, hence v6.

**Plan of record (2026-09-14 evening): the two-column layout on the
44.96 um grid.**  LEFT16 column at x 537.11 (117 um corridor to the
SRAMs), IHP16 column at 1346.39 (478 um channel), `FP_PDN_VOFFSET` 6.15,
2 um horizontal halo, KLayout DRC instead of Magic DRC (`src/config.json`;
the tile-level keys come from tt_tool).  First with one 1024x32 SRAM flush
left: GRT overflow 1734, DRT 24445 12066 10839 1093 73 0 (five
iterations), typ setup +0.59 ns, KLayout DRC 0 items over 333 rules, LVS
"circuits match uniquely" with all counts zero.  Then, for Ethernet
receive and transmit at once, two 512x32 SRAMs (one FIFO per shard,
section 4i) stacked flush left with their pin faces toward each other,
(3.36, 3.78) `FS` and (3.36, 340.20) `N` (294.84 until the tracer; section 4m), both wrappers in the 145 um gap:
GRT 2560, DRT 26348 13229 11974 1492 289 12 3 3 0, typ setup +0.68 ns,
hold +0.06 ns, slow-corner WNS -6.82 (all three better than with the
single macro), KLayout DRC 0, LVS clean.  All the 1P x32 macros share the
416.64 um width and the same power-column positions, so the stripes on
the lower macro's columns serve the upper one; the stripe step must
only ever delete vias that sit on stripes it actually removes, or the
second macro's pass strips the rows above the stack of their power (the
IR-drop connectivity check catches that).  Magic's
extraction still reports 22 "illegal overlap between obsm4 and metal4":
the VPWR stripes crossing the LEF keep-out bar at each VDD column's
VDD!/VDDARRAY! break (LEF y 39-45), where the GDS has no metal at all, so
`ERROR_ON_ILLEGAL_OVERLAPS` is 0 with that reason in the config.  The
band layouts are kept in `src/config_band*.json` for the day a CONST SRAM
needs the space; the regenerated macros and the grid serve both.

**Band v6 recipe (kept for a rainy day).**  If a later addition (PRISM
tracing into the SRAM, a CONST lookup SRAM) pushes the column POR off the
routing cliff, the band layout is the fallback and `src/config_band_v6.json`
holds it verbatim: CFGMEM 2x2 band at the top on the 44.96 um grid, rows
619.92 (N) and 510.30, columns 87.51 / 447.19 / 941.75 / 1301.43 (the POR
bank assignment of section 4d); the lower row upright (`N`, pins facing
down into the logic) except column D, whose lower macro is flipped (`FS`,
pins into the 22.68 um gap) because the SRAM sits below it; SRAM bottom
right at (1284.72, 3.78) `FS`; `FP_PDN_VOFFSET` 6.15, `FP_PDN_VSPACING`
3.52, 2 um halo, KLayout DRC.  Things that made it worse and need not be
retried: the SRAM anywhere but a corner (pocket), both rows facing the gap
(the POR arrangement), a 60 um gap, and a lower target density.  Run it
directly with `python -m librelane ... src/config_band_v6.json` (the file
carries the tile keys tt_tool merges for `make harden-tt`).

**Signoff with the SRAM.**  Magic DRC reports 2.2 million violations
inside the macro (it has no notion of the bit cells) and is not what the
Tiny Tapeout precheck runs for ihp-sg13cmos5l; the precheck runs the
PDK's KLayout deck, so the local flow does too (`RUN_MAGIC_DRC` 0,
`RUN_KLAYOUT_DRC` 1 with the IHP-Open-PDK dev-branch runset).  That deck
is clean on every FEOL table with the SRAM in the tile.  netgen writes the
SRAM's `VDD!`/`VSS!`/`VDDARRAY!` names into its LVS JSON with a stray
backslash, which made the LibreLane LVS step die in the JSON parser;
`librelane_plugin_prism_pdn.py` gives that step a repairing loader.  The
column-grid run above is the first clean DRC + LVS with the SRAM in the
tile.  The precheck's pin check also needs every VPWR/VGND port rect on
Metal4, at least 2.1 um wide and within 10 um of both edges; the local
flow does not run it, so check `runs/wokwi/final/lef` for short power
rects after any PDN change (see the tidy pass above).

### 4d.2 Floorplan experiment: a macro in the top row (2026-09-16, run 14)

Tried after run 13: `CFGMEMS_LEFT[1].cfgmem_lo` moved out of the left
column to the top row at (941.75, 619.92) N (pins south, on the 44.96
um stripe grid between `LEFT[1].cfgmem_hi` and `CFGMEMS[3].cfgmem_hi`),
and `CFGMEMS_LEFT[0].cfgmem_hi` raised 9 rows to y 291.06 so its channel
grew to 200 um.  Global routing liked it: wirelength 2.83 M um (3.01 in
run 13), Metal3 usage 71.4% / overflow 2438 (76.6% / 5621), Metal2
overflow 795 (1590), and the Metal3 demand map (`tools/route_heat.py`)
flatter, its busiest bin 15% lower.  Detailed routing did not: the
count tracked run 13 to iteration 12, then fell behind (342 flat for
three passes, a 1112 bounce on the wide ripup against run 13's 639, 93
at iteration 32 where run 13 had 6), with a persistent set of Metal4
signal shorts run 13 never showed.  The power stripes over the moved
macro were checked and sit exactly on its rails, so those shorts are
routing, most likely the split lo/hi pair's mux nets crossing the top
stripe.  Stopped at iteration 32 and reverted to the run 13 floorplan;
the global-routing gain says the idea has merit, but not in this form.

## 4e. Bank addressing when unfractured (timing)

Unfractured, shard 1's state index register tracks the low bits of
shard 0's (`next_si[1] = next_si[0][3:0]`), so bank B is always addressed
by shard 1's register and bank A by shard 0's: no mux on either row
address, and `cfg_fractured` is off the address path.  Shard 0's SI MSB
then selects which bank's STEW feeds the decision trees, a mux whose
select is a registered bit.  Consequences: STATUS shows shard 1's SI
following shard 0 while unfractured, and shard 1's debugger has no
effect until the PRISM is fractured.  The unit test forces states 4, 15,
20 and 31 through the debugger and checks the STEW read back from the
right bank.

## 4f. CFGMEM programming chains (per bank)

Each bank's four macros form a shift chain that stays inside the bank's
macro block: host word -> lo0 -> lo1 -> lo2 -> lo3 and host word -> hi0 ->
hi1 -> hi2 -> hi3 (macro i's `Di0` is macro i-1's `Do0`).  A macro's `Do0`
is its addressed row, or its `Di0` while the bank's bypass bit (control
byte bit 6 for lo, bit 7 for hi) is set, so with the bypass set every macro
of the chain sees the host word and is shifted with its own write strobe
(0x00 + 4i for lo i, 0x20 + 4i for hi i).  Loading is therefore one write
per word with the bank's bypass set, in any macro order.  Reads return each
macro's own `Do0` (0x00 + 4i = lo i, 0x20 + 4i = hi i) at the row selected
by the control byte when address-select is set, with the bypass clear.
With the bypass clear a shift of macro i copies macro i-1's addressed row
into row 0 of macro i, which `cfgmem_verify` uses to walk both chains.
Only the chain input word of each bank leaves the block, so the 2x2 macro
blocks need no lo-to-hi data wiring.

## 4g. in_prev edge capture (decision 2, 2026-09-13)

Each shard has four edge-capture flops on inputs 16-19.  CFG1[4i+3:4i]
names the edge-capable input flop i follows: a ui_in pin (0-6, after the
shard's sync select) or a host_in bit (8, 9).  A flop captures its source
in exactly the cycle a decision tree whose muxes read that source fires
and the transition is executed: tree 0 when it matches, tree 1 when it
matches and tree 0 does not (the else-if is actually taken).  Nothing is
captured while the shard is halted or in the cycle a conditional
breakpoint fires, and a single step captures on that one executed cycle,
so the debugger sees the same sequence as free running.  Transitions
taken by the auto-loop (`inc` / `loop_si`) do not capture, since no tree
read the input.

The idiom: `if (pin ^ in_prev0) -> next` fires once per transition of the
pin, because the jump re-captures in_prev0 to the pin's new value.  Two
edge-capable inputs can be watched from one state through tree 0 and tree
1 (`chroma_edge` in the unit test counts ui_in[2] transitions in count2 and
host_in[0] toggles in count1 this way).  A flop whose source is not read by
the firing tree keeps its value, so several states can share one edge
condition without re-arming each other.  Program the CFG1 sources before
enabling the PRISM: a flop only changes on a capture, so a source changed
while running leaves the old value behind until the next firing tree that
reads the new source (and with the reset source 0, the first jump of any
tree whose spare mux selects input 0 loads every flop with ui_in[0]).
OUT_LATCH and `latched_in` (inputs 12-13) are unchanged.

## 4h. USB low-speed device chroma: the stretch-goal evaluation (2026-09-14)

`chromas/chroma_usb_ls.v` with the host model `test/user_peripherals/prism/
usb_model.py` is the first stretch-goal chroma, written to find what the
core lacks.  It is a 1.5 Mbit/s device on ui_in[4:5] and uo_out[2:4]
(D+, D-, output enable for external tri-state buffers), 40 clocks per bit
at the test clock.  It receives SETUP / OUT tokens and DATA packets (NRZI
decode, bit un-stuffing, CRC16 residual check, payload and CRC pushed to
FIFO A), answers with ACK, answers IN from the response the CPU queued in
FIFO B (PID, payload, CRC16) or with NAK, and handles the host's ACK.  The
test runs a GET_DESCRIPTOR setup, a NAKed IN, a 4-byte IN response and a
bit-stuffed OUT.  `TESTCASE=test_usb_device` runs just this test.

Features added to make it fit (all in the register maps above):

- shifter input from cond_out[0] (CFG0[28]): the FSM computes the NRZI
  bit (`D- == in_prev1`) in the sampling state and shifts it in;
- FSM flags: OUT_LATCH stores the two conditional outputs and output 19
  (CFG0[29]) - the receive / transmit phase lives in them;
- constant table CONST with OUT_COMM_LOAD select (CFG0[30]): sync 0x80,
  ACK 0xD2, NAK 0x5A without a state sequence per byte;
- input slots CFG2: the trees read comm[3:0] to decode the PID and flag2;
- CRC byte transmit through comm (not used by this chroma, the CPU
  supplies the response CRC; needed for Ethernet FCS and a full USB TX).

What the chroma does with the datapath: count1 is the half-bit timer
(two terminal counts per bit so samples land on bit centres), count2 the
consecutive-ones counter for stuffing (compare = 6), the shifter's own
count gives byte boundaries, the CRC unit checks CRC16 with the residual
0xB001, FIFO A receives, FIFO B transmits (the two-FIFO mode of 4b), the
line level of the transmitter is a J / K pair of states with the level
also on the conditional outputs so the last bit can be held from flag F0.

Findings, in order of weight:

1. **States: 32 of 32.**  Receive engine 6, dispatch 6, EOP 3, transmit
   engine 12, hold and EOP 5.  Two things cost the most: every condition
   beyond two per state costs a state (three-way decisions are split), and
   the transmit engine is duplicated per line level because outputs are
   per state.  A third decision tree, or an output word that could depend
   on a flag, would each save about six states here.
2. **Not implemented for lack of room:** address match on tokens (the
   comm == K3 input exists), CRC5 on tokens (the CRC unit has one
   configuration; a second polynomial / width set selectable by an output
   is the fix), DATA0 / DATA1 toggle tracking, resynchronisation on edges
   during a packet (a wait state would need three conditions: timer,
   edge, SE0; real hardware needs it for the +/-1.5% clock tolerance),
   the TX CRC16 (the CPU computes it; the CRC byte transmit is there).
3. **The auto-loop rule shapes wait states:** a state entered by `inc`
   returns to the inc state when no tree fires, so a wait state must
   never be an inc target.  Chroma authors need this in the manual.
4. **A per-shard register table** (VID / PID, descriptors, MAC / IP
   addresses) with an FSM-stepped index would let the device answer
   GET_DESCRIPTOR without the CPU; CONST is the 4-byte version of it, and
   the SRAM is the natural backing for a longer one.
5. **Counters were enough** for USB: bit timer, stuff counter, shift
   count.  A third counter was not needed here; Ethernet may still want
   one for frame bytes unless the SRAM pointer serves.
6. The input synchroniser delay matters when the FSM reads its own drive
   back (the hold state first tried that and locked on the old level);
   flags or state are the right source for a level the FSM set itself.

## 4i. SRAM FIFOs: one 512x32 macro per shard (2026-09-14)

`prism_sram_fifo.v` puts a byte FIFO on an IHP single-port SRAM macro,
instantiated inside the PRISM peripheral.  Parameter `SRAM_FIFO` (define
`PRISM_SRAM_FIFO` in peripherals.v) is the number of them: 2 is the plan
of record, one per shard on `RM_IHPSG13_1P_512x32_c2_bm_bist` (2 KB each,
`SRAM_AW` 9), so an Ethernet receiver in one shard and a transmitter in
the other each own a full-rate buffer; 1 keeps the earlier single shared
FIFO (shard 0 wins if both ask; `SRAM_AW` 10 or 11 for the 1024x32 /
2048x32 macro); 0 builds without any macro.  A shard makes its SRAM FIFO
its FIFO with CFG0[31]: the shard's push / pop strobes, head byte, count
and flags then come from the SRAM FIFO and its flop FIFO idles, so a
chroma sees no difference except the depth (status count field widened
to [21:8]) and the almost-empty / almost-full levels, which are in
64-byte units.  With the two-FIFO mode of 4b, unfractured shard 0 reaches
shard 1's SRAM as FIFO B, so one shard can hold a 2 KB RX buffer and a
2 KB TX buffer at once.

Inside: four bytes per word, whole-word accesses only.  Pushes assemble
a word in a register and the fourth byte writes it (writes have the
port); a cached head word means pops within a word cost no access.  A
pop that leaves the word reads the next one at once (one clock later if
a word is being written that clock) and reports `empty` for the two or
three clocks until the data is back; while the reader is inside the word
still being assembled the head comes straight from that register, and a
write to the reader's word refreshes the cache.  Words complete at most
every four clocks, so no write is ever queued and a push is refused only
when `full`.  (The first version kept a four-entry byte queue with
per-byte writes and merges: 20k um2 of cells, more than both flop FIFOs;
this one is about 10k.)
The read data of the macro is registered (one clock).  The unit test
(`SramFifoTest`) pushes and pops through the shard windows, fills both
SRAM FIFOs at once and flushes one, and runs the fifo_loop chroma in
both directions across many word boundaries.

Simulation uses the PDK's behavioural model with `FUNCTIONAL` defined
(A_DLY tied high, BIST tied off); synthesis sees the black box in
`sram_2048x32_bb.v`.  The macro's power hookup and placement are in 4d /
section 7: two-column CFGMEM layout, SRAM on the left with the tile
stripes drawn on its own tracks.

## 4j. Ethernet transmitter chroma: the second stretch-goal evaluation (2026-09-14)

`chromas/chroma_eth_tx.v` with the decoder model `test/user_peripherals/
prism/eth_model.py` sends 10BASE-T frames from the SRAM FIFO (4i): TXD on
uo_out[1] from cond_out[0], TX_EN on uo_out[2], six clocks per bit at the
test clock (three per half bit, count1 as the half-bit timer with preload
2).  Manchester coding costs no decision: the line is the LUT
`shift_data ^ first_half`, so a bit is two states that advance on the
timer, and the shift, pop and CRC update ride on those transitions.  The
frame is four 0x55 from constant K0, four bytes from the FIFO (the host
queues 55 55 55 D5 in front of the frame), the frame bytes with the CRC32
running on every bit, the four FCS bytes from the CRC unit through comm
(one OUT_LOAD_CRC per byte, low byte first), TP_IDL for two bit times,
the host interrupt.  count2 counts bytes or half bits in each phase
against compare = 3.  A toggle of host_in[0] starts a frame and a toggle
of host_in[1] sends a link pulse, both through the in_prev edge capture.
Sixteen states.  The test sends a 64-byte and a 300-byte frame (the
latter streamed from the SRAM FIFO, which refills its head word in the
gaps) and a link pulse; the decoder checks every byte and the FCS.

Findings:

1. **Transmit fits with room to spare**: 16 of 32 states, and the datapath
   kept up at six clocks per bit with a byte pop every 48 clocks, so a
   hardware Manchester encoder is not needed for transmit.
2. **The CRC must be updated mid-bit**: updating at the end of the bit,
   in the same transition that loads the first FCS byte, hands the load
   the value before the last bit.  Mid-bit updates are the natural fix
   and cost nothing.
3. **One preload is one timer**: the 16 ms link-pulse interval cannot live
   in count1 while count1 is the half-bit timer, so the CPU asks for
   pulses.  A second preload, or a free-running timer input, would let
   the chroma keep the link alive alone.  The same applies to the 9.6 us
   inter-frame gap.  (Answered: PRELOAD2, section 4l; the inter-frame gap
   can use count1, which is idle between frames.)
4. **count2 as the phase counter** worked because every phase happens to
   be four long (preamble halves, FCS bytes, TP_IDL half bits); a second
   compare value or a third counter would remove that coincidence.
5. **The 32-bit CRC mode is a CFG0 bit that is easy to miss**: the first
   run produced a 16-bit FCS padded with 0xFF.  The chroma CFG0 constants
   deserve named fields in the compiler's cfg.
6. Receive is the open question: classifying 3- versus 6-clock edge
   intervals with two-flop synchronised inputs and one decision per clock
   is where a hardware decoder or a faster clock would be needed.
   (Answered in 4k with the Manchester bit recoverer.)

## 4k. Ethernet receiver: the stretch goal closed in RTL (2026-09-14)

Receive needed two small datapath additions (section 4j, finding 6):

- **A Manchester bit recoverer per shard** (`prism_mrx.v`, CFG3 at +0x3C:
  [2:0] the PRISM input carrying the line, [3] enable, [7:4] clocks per
  half bit, [8] shifter input = the recovered bit).  It runs on the PRISM
  clock; an edge on the synchronised line is accepted when three quarters
  of a bit (hb + hb/2 clocks) have passed since the last accepted edge, so
  the boundary transition between two equal bits is skipped and every
  mid-bit edge re-times the decoder; the level after the accepted edge is
  the bit.  Its "bit valid" is CFG2 slot code 15 and stays set until the
  FSM's shift consumes it, so a two-state receive loop never misses a bit.
  About 25 flops per shard; the FSM keeps every decision (SFD, bytes,
  CRC, end of frame).
- **The shifter can take that bit as its input**, and with the reflected
  CRC32 taking the shifter input bit, one transition per received bit
  does shift + CRC + count.

`chromas/chroma_eth_rx.v` is four states: WAIT (a bit: shift and reload
the idle timer; idle: keep comm clear from K0 = 0), CHK (comm[7:6] = 1, 1:
the SFD just ended, so clear the CRC and the bit counter), DWAIT (a bit:
shift, CRC, count, reload the timer; timer terminal: end of frame, host
interrupt, clear comm), DCHK (eight bits: push comm into the FIFO).  The
preamble / SFD needs no comparator: 0x55 .. 0xD5 sent LSB first are
strictly alternating until the two 1s that end the SFD, and comm[7:6] are
inputs through slot codes 12 and 11.  The FCS is checked by the host
(or a chroma) through `crc_ok`: CRC_EXPECTED = 0xDEBB20E3, the CRC32
residue after data + FCS.  A partial last byte is dropped; a link pulse
is one bit that never becomes an SFD and times out.

Tests: `EthernetRxTest` (link pulse ignored, a 64-byte frame, a 300-byte
frame from a line 8% slower than the clock, a corrupted FCS reported) and
`EthernetLoopTest`: eth_tx in shard 0 on SRAM 0 and eth_rx in shard 1 on
SRAM 1, fractured, with TXD looped into ui_in[3] by the bench; the host
queues a frame in shard 0 and reads it back from shard 1 with crc_ok.
That is the stretch goal in RTL: transmit and receive at once on one
PRISM with the two SRAM FIFOs.  Still to do: the FPGA / board level
(differential receiver and driver behind the magnetics), destination
filtering (software or the CONST table), and the 16 ms link pulses (a
second timer, finding 3 of 4j).

## 4l. The second timer: PRELOAD2 (2026-09-14)

A free-running 24-bit timer per shard (`PRELOAD2` at +0x40): it reloads
itself and raises PRISM input 28 for one clock every PRELOAD2 + 1 clocks
(0 = off).  Input 28 was a spare whose CFG2 default was a constant 0; the
tick is now that default, so no slot code and no output bit were needed.
Nothing in the FSM starts or reloads it, which is the point: it paces
things while count1 is busy.  `chroma_eth_tx` sends a link pulse on the
tick as well as on the host's toggle (`nlp_tick | (host1 ^ in_prev1)`;
the compiler wants the bitwise form, `||` with a `!=` inside is rejected),
so with PRELOAD2 = 959999 at 60 MHz the link stays alive with no CPU
help, and a frame in flight simply ignores ticks (the FSM is not in IDLE).
Test: four pulses in four periods, none with the timer off, a frame
transmitted intact with the timer ticking.  SDK: `prism_set_timer2()`.

Restart on state entry (2026-09-15): with PRELOAD2[24] the count also
restarts from the period whenever the shard enters state PRELOAD2[29:25]
(the core's next SI is that state and the current SI is not: the first
clock of a visit, so a state that loops on itself restarts it once, and
a debugger step into the state restarts it too), which makes the tick a
retriggerable timeout - "nothing for N clocks since the last entry into
RX_BIT" - with no STEW bits and no chroma code, since input 28 is the
tick as before.  Without [30] the timer free-runs after the timeout
(a tick every period until the next entry); with [30] (one-shot) it
ticks once per timeout and then waits for the next entry, so a burst of
entries closer than the period ends in exactly one tick.  Writing a
period of 0 stops and clears it.  Test: `test_timer2` replays the
counter and its tick clock by clock against a model of the register for
free-running, restart and one-shot, on shard 0 (pin edges entering
CNT_PIN) and on shard 1 while fractured (host toggles entering
CNT_HOST).  SDK: `prism_set_timer2_retrigger(clocks, state, one_shot)`.

If a future feature does need an FSM output rather than an input, the
escape hatch is to widen the STEW with instantiated latches strobed by
the existing WROW lines: not as dense as the CFGMEM bits, but a couple of
outputs times three branches is a few dozen latches per shard.

## 4m. Trace: execution capture into the SRAMs (2026-09-15)

Each shard has a tracer (`prism_periph.v`, registers +0x44 / +0x48).
From its trigger on, every clock's `{executing, tree 1 taken, tree 0
matched, the six selected LUT mux input bits, SI[4:0]}` - a 16-bit entry,
two per SRAM word - is written into an SRAM by the SRAM's trace port
(`prism_trace_port.v`, next to the macro) until the buffer is full (1024
entries on the 512x32; `2^(SRAM_AW+1)`), and the host reads the entries
back.  The 21 outputs of a traced clock are not stored: they follow from
the entry and the chroma the host loaded (state outputs at STEW bits
[61:41], tree 1 outputs [82:62], tree 0 outputs [103:83]; while halted
the outputs were the debugger's), and `prism_trace_outputs()` in the SDK
rebuilds them; the test checks that rebuild against the real outputs on
every traced clock.  The triggers: at once; in a given state; that state
taking either jump (a decision tree fires while the shard executes, so a
halted shard does not trigger); or an edge (rising, falling, either) on
any of the 32 PRISM inputs.  Entry 0 is the trigger cycle itself: in the
"state" case the first cycle in the state, in the "jump" case the cycle
the tree fires (its match bit set, entry 1 is the target state), in the
"edge" case the cycle the input changed.

Storage: one shard traces at a time.  Shard s traces into SRAM s while
its `TRACE_CFG[0]` is set (shard 0 wins if both shards enable: shard 1's
tracer then reports inactive until shard 0's is switched off); with
`TRACE_CFG[1]` as well it takes both SRAMs as one 2048-entry buffer
(entries 0..1023 in SRAM 0); with `TRACE_CFG[6]` ("other", 2026-09-15)
it traces into the other shard's SRAM instead of its own, so a chroma
streaming a frame from its SRAM FIFO (Ethernet TX, or RX filling it) can
be traced while it does so, the entries then read through the other
shard's window.  A single 16-bit bus and three strobes, registered once
at the top of the peripheral from the tracing shard's signals, reach the
SRAM trace ports; "other" only changes which SRAM's port takes them and
which SRAM's `full` the shard watches.  Arming flushes the traced SRAM's
FIFO and pushes into a traced SRAM are dropped, so a chroma cannot
stream from the SRAM being traced into - use the flop FIFO, or the other
SRAM.

Host sequence: TRACE_CFG (trigger, storage), TRACE_CTRL = 1 (arm: the
buffer restarts at entry 0 and the SRAM's FIFO is flushed), wait for done
(or stop with TRACE_CTRL = 2, which keeps what was recorded, an odd
count included), then read the entries as FIFO bytes.  At the end of a
capture the trace port hands the buffer to the SRAM FIFO wrapper
(`prism_sram_fifo.v` `load`: count x 2 bytes from word 0 become its
contents), and while an SRAM holds a finished trace the window that reads
that SRAM sees it as its SRAM FIFO in RX mode whatever CFG0 says, so
`FIFO_STATUS` shows count x 2 bytes and each read of +0x20 pops the next
byte, entry by entry, low byte first; with both SRAMs, entries 1024 and
up come through shard 1's window.  Until the
capture is done the window's FIFO works as configured (a chroma on the
flop FIFO runs untouched while it is being traced); pushes into a traced
SRAM are dropped.  Switching the trace off, or arming again, gives the
window its FIFO back.  SDK: `prism_trace_config()`, `prism_trace_arm()`,
`prism_trace_wait()`, `prism_trace_read()` (four pops), `prism_trace_off()`,
`PRISM_TRACE_SI/MUX/OUT()`.

Why the entries are 16 bits and the readout goes through the FIFO: the
tile has one horizontal routing layer (Metal3) and it was at 71% before
the tracer.  The first version stored 32-bit entries `{out, mux, SI}` and
had TRACE_ADDR / TRACE_DATA registers with a prefetched read path from
the SRAMs back into each shard: some 150 nets per shard between the shard
logic (right of centre, next to the CFGMEM columns) and the SRAMs at the
far left, and the placer dragged both shards 200-340 um towards the
SRAMs (global-route wirelength 2.75M -> 3.30M um, overflow 4378 ->
19735, Metal3 at 89%, with or without flops on the SRAM port: the pull is
connectivity, not timing).  Reading through the FIFO wrapper instead
brought the shards back to their places but 46 crossing nets per shard
still left the overflow at 13434 with Metal3 at 81%, the extra demand
spread over the whole left two thirds of the tile by the
routability-driven placer.  Dropping the outputs from the entry (they are
a function of the STEW) halved the bus and doubled the depth, but with
both shards tracing at once (16 data bits and three strobes per shard,
two buses) the overflow was still 6664 and detailed routing plateaued
near 2000 violations.  So one shard traces at a time: a single 16-bit bus
with three strobes crosses the tile, from flops, with `full` coming
back, and the counter and the word packing sit next to the SRAM in the
trace port.  The last stalls (single shard, 16 bits: detailed routing
oscillating between 35 and 90 violations) were at the exits of the gaps
between the LEFT16 column's macros (x 840-870, y 105-240 and x 735-810,
y 465-600): everything from the SRAM side funnels through those gaps,
and 21 more nets in that bundle were enough.  To pay for them the SRAM
FIFO wrapper's almost-empty / almost-full levels (8 bits out) and flags
(2 back) per shard no longer cross: the shard compares its own CFG1
levels against the count that crosses anyway, and the flop FIFO storage
became latch rows (fewer cells in the shard region).

Cost: per shard a 21-bit configuration latch register (write-only) and
some 10 flops of state; one set of 16 + 3 bus flops; per SRAM the trace
port (an 11-bit counter, a 16-bit holding register) and the write mux on
the macro port; the core exports its SI, mux outputs and tree results
(`trace_*` ports).  Synthesized area 286k um2 against 281k before the
tracer, after the flop FIFOs became latch rows (section 4b note) and the
wrapper's flag comparisons moved to the shard.

Closing the tile with the tracer took ten hardens (2026-09-15, log in
this section and 4d.1): the routing limit of this floorplan is the pair
of gaps between the macros of each CFGMEM column and the corridor between
the two SRAMs.  The final recipe, all in `src/config.json`: SRAM 1 at y
340.20 (corridor 145 um), routing obstructions over both SRAM interiors
on Metal2-4 with 2.6 um free at the pin faces (the global router had
planned two corridor nets through the macros), the macro LEFs
regenerated with no pin clearance towards the macro interior (a 0.02 um
Metal3 spacing item at a WROW pin), and `PL_RESIZER_SETUP_SLACK_MARGIN`
0.25 ns (run 9 closed physically but 3.6 ps short at the typical corner
on a shard-flop-to-SRAM-pin path).  Run 10: routing 0, KLayout DRC 0,
LVS clean, IR drop 0.78 / 0.40 mV, typical setup +0.50 ns / hold +0.21
ns, fast-corner hold +0.03 ns, 80 power ports legal; one antenna net left
after the three repair passes (a warning, not a precheck item).  Run 11
(the "other SRAM" option and the timer restart, 2026-09-15): routing 0
in 20 iterations, one antenna re-route pass, antenna 0, KLayout DRC 0,
LVS clean, IR drop 0.86 / 0.65 mV, typical setup +0.59 ns / hold +0.25
ns, fast-corner hold +0.08 ns, 80 power ports legal; +11k um2 of
standard cells over run 10 (2.8%, mostly antenna cells and hold
buffers; the logic itself is 1.8k um2), the same slow-corner setup
warning as run 10 (-7.3 ns at 125 C / 1.08 V against the 14 ns TT
constraint).  Test:
`test_trace` checks every trigger, the stop (odd count), both SRAMs as
one buffer (all 1024 entries of SRAM 0 and the first of SRAM 1 through
shard 1's window), the FIFO around a trace, shard 0 tracing into SRAM 1
while its SRAM 0 FIFO keeps its bytes (the entries through shard 1's
window, a push into SRAM 1 dropped), shard 0 then shard 1 tracing the
same kind of edge while fractured (shard 0 wins while both enable), and
the host's output reconstruction, all against a golden record of the
core taps sampled every clock.

## 4n. Constant table: the latch FIFO as addressable constants (2026-09-15)

When a shard streams from its SRAM FIFO (CFG0[31]) its 16x8 latch FIFO
sits idle; `CONST_TAB` (+0x4C) turns those 16 rows into constants a
chroma indexes - a MAC address, an IP header, a fixed reply - without
spending states on OUT_K_SEL bit patterns for every byte.  With
CONST_TAB[0] set, OUT_COMM_LOAD loads comm from the row at a 4-bit
index (flops) instead of preload[7:0] or K[]; the two constant-select
outputs become the index mode for that load: `{OUT_K_SEL1, OUT_K_SEL0}`
= 0 clears the index, 1 adds one, 2 adds `add_to_idx` (CONST_TAB[10:8]),
3 loads `idx_load` (CONST_TAB[7:4]) - or adds it with CONST_TAB[1], so
a chroma that needs two strides and no jump can have them.  Every load
moves the index (add 0 if it must not).  The byte loaded is the row
*after* the move, so "clear" reads row 0, "+1" the next row, "load"
the row jumped to, all in the same load; CONST_TAB[2] (post) reads the
row *before* the move instead, for chromas that want a plain
post-increment walk.  The index wraps modulo 16.  A write to CONST_TAB
also sets the index from [19:16] (the host's reset before a run), and
[19:16] read back live.  The comm match against K3 (CONST[31:24]) is
untouched, and CONST's K[] loads still work with the table off.

The table is loaded the way the flop FIFO is: select it (CFG0[31] = 0)
in TX mode, flush, push 16 bytes, then select the SRAM FIFO again - the
latch rows keep their contents (`prism_const_table_load()` does exactly
that and restores CFG0).  In table mode the FIFO's head is the indexed
row, so with the flop FIFO selected the host sees a row at +0x20: the
row at the index while the shard is not executing (disabled or halted)
or with post set, otherwise the row the executing shard's current
outputs would load next (an idle chroma's outputs say "clear": row 0).
The FIFO pointers are not otherwise touched, so a chroma using the
table must not also pop that FIFO.  Cost: a 4-bit register and adder per shard and a second
select on the existing 16:1 head mux (`prism_fifo.v` `tab_en`,
`tab_idx`).  Test: `test_const_table` with `chroma_const_tab` (six
loads: clear, +1, +1, +add, load/add idx_load, +1; pushed into the SRAM
FIFO and read back) checks pre and post update, the add-idx_load
option, wrap-around, a preset index, the read-back, the host's view of
a row, and the same loads from K[] with the table off.  SDK:
`prism_const_table_load()`, `prism_const_table()`,
`prism_const_table_index()`, `PRISM_CTAB_*`.

Hardening (2026-09-15/16): run 12, the first with the table, stopped at
6 shorts after 60 router passes, all in one 30 x 35 um pocket of shard
1's constant / CFG2 logic.  The pocket was only 37% utilized; what
filled it was 59 antenna diodes, 16 of them on two mux-select nets,
crowding the pin access of the cells between them (the diode total was
the same as run 11's, about 11k; the placement had simply landed them
together).  `tools/route_heat.py` and `tools/cell_density.py` (maps of
Metal2/3 demand from the routing guides and of cell density from an
.odb) showed the general pressure to be the two channel-height stripes
of the band between the CFGMEM columns, at 60% utilization against the
55% target, with Metal3 the only horizontal signal layer (the PDK's
LibreLane default excludes Metal1, `RT_MIN_LAYER`, and Tiny Tapeout
reserves TopMetal1).  Fix: pad the diodes.  LibreLane's `DIODE_PADDING`
turned out to have no effect here - it is declared for the routing
steps, but the 10.9k heuristic diodes are legalized by a
DetailedPlacement sub-step that never sees it (run 13a was bit-identical
to run 12) - so the config now sets `DPL_CELL_PADDING` 2 (one site each
side) with a `CELL_PAD_EXCLUDE` list of 28 star-only patterns that
strips the padding from every master except `sg13cmos5l_antennanp`
(checked against all 87 library masters; star-only because the Tcl and
Python matchers differ on anything else).  Run 13: routing 0 in 37
passes plus a clean antenna re-route, KLayout DRC 0, LVS clean, antenna
0, IR drop 0.67 mV, typical setup +0.33 ns / hold +0.27 ns, fast hold
+0.10 ns, 80 power ports legal, the same slow-corner setup warning as
before (-7.7 ns at 125 C / 1.08 V against the 14 ns constraint); 1202
hold buffers this time (280 in run 11), std-cell area 418.8k um2.  The
worst typical path is state flops -> CFGMEM decoder -> decision-tree
logic, as before, not the table's adder and row select.

## 4o. I2C master chroma (2026-09-16)

`chromas/chroma_i2c_master.v`: an I2C controller for a board with two
external open-drain (tri-state) buffers.  Each line gets one PRISM
output meaning "pull the line low" - 1 = the buffer drives the line
low, 0 = released - so the idle value of an unset output releases the
bus, and the line levels come back on ui_in pins:

| signal | pin | function |
|---|---|---|
| pin_out[0] | uo_out[1] | SCL pull-low |
| cond_out[0] | uo_out[2] | SDA pull-low (the data bit is `cond_out[0] = 1; if (shift_data) cond_out[0] = 0`) |
| in[0] | ui_in[0] | SDA level, also the shifter's input (shift_in_sel = 0) |
| in[1] | ui_in[1] | SCL level (unused so far: no clock stretching) |

Host side, shard 0 unfractured so it owns both FIFOs (as the fifo_loop
chroma does): FIFO B (shard 1's window, CFG0 fifo_dir = TX) holds the
bytes to send, the first one the address with R/W = 0; CONST K0 holds
the address with R/W = 1 for a read; COMPARE (+0x11) the number of
bytes to read, 0 for none; CFG2[3:0] = 14 puts flag2 on input 16 (the
FSM's "read phase" flag, set with OUT_LATCH / OUT_FLAG2 when it loads
K0); PRELOAD = the SCL phase length minus one (212 at 64 MHz for about
100 kHz).  host_in[0] = 1 starts a transaction: START, every FIFO B
byte followed by the slave's ACK, then if COMPARE is not 0 a repeated
START (the first START if FIFO B was empty), K0, and COMPARE bytes read
into FIFO A (own, RX) with ACK, NAK on the last, STOP, host interrupt;
count2 counts the bytes read.  The FSM waits in DONE until host_in[0]
drops.  A NAK from the slave aborts with a STOP: the unsent bytes stay
in FIFO B and nothing lands in FIFO A, which is the host's error flag
(no status register bit was needed).

Timing: count1 paces every phase (PRELOAD + 1 clocks).  A transmitted
bit is three phases - SCL low with the bit set, SCL high, SCL low with
the bit still held, then the shift - so SDA never moves within a phase
of an SCL edge and the period is 3 x (PRELOAD + 1).  Received bits are
sampled at the end of SCL high (the shift takes the synchronized SDA);
the ACK the same way.  The state machine is 25 states (IDLE, START1/2,
TX_LOW/HIGH/FALL/CHECK, ACK_LOW/HIGH/FALL, ACK_NEXT1/2, NAK_FALL,
RS_LOW/HIGH, RX_LOW/HIGH/CHECK, MACK_LOW/HIGH/FALL, STOP_LOW/HIGH/REL,
DONE); decision states carry at most two explicit targets (the
compiler's INC / loop_si rule), and every wait state is entered by an
explicit jump.  Left out: clock stretching (SCL_in is wired but not
read), multi-master arbitration, and FIFO A back-pressure (the host
sizes COMPARE to the 16 bytes).

Test: `test_i2c_master` with the `I2cSlave` model in `models.py`, which
resolves the two lines every clock from the master's pull-lows and its
own, drives them into ui_in, decodes START / STOP / bytes, ACKs its
address and serves read data until the master NAKs.  Checked: a 3-byte
write, a 3-byte read (ACK, ACK, NAK), a register-address write with a
repeated START and a 2-byte read, a write and a read to an absent
address (NAK, STOP, the leftover byte in FIFO B, nothing in FIFO A),
the completion interrupt / DONE / IDLE sequence, and the SCL period.

## 4p. Edge-clocked sampler (2026-09-16)

The generalisation of the Manchester recoverer's trick: CFG3[27:16]
names one PRISM input (any of the 32, [21:17]) and an edge polarity
([23:22]: rising, falling, either), and on every such edge the shard's
datapath performs the chosen actions with no state transition: shift
the shifter with its configured input ([24]), count2 + 1 ([25]),
capture all four in_prev flops ([26]), count1 clear / load ([27]).
With [28] the FSM's flag2 swaps rising and falling, so one flag turns a
bidirectional protocol's sampling edge (an I2C target receives on SCL
rising and must change its outgoing bit after SCL falling; SPI slaves
likewise per mode).
The actions OR into the FSM's own outputs (one shift if both ask in
the same clock) and, like them, only act while the shard executes, so
a debugger halt freezes the sampler too.  A sticky "edge pending" flag
is set by the edge and cleared when the FSM shifts or latches
(OUT_SHIFT / OUT_LATCH), or when the sampler or the PRISM is switched
off; it is input slot code 15, shared with the recoverer's bit valid
(the two are ORed; a shard uses one or the other), and FLAGS[11] for
the host.  Cost per shard: a 32:1 mux, two flops and a few gates,
about 40 cells, and the CFG3 latches.

What it buys: a clocked slave protocol no longer spends its states on
the bit loop (wait for the edge, shift, wait for the other edge,
count); the FSM acts at byte boundaries on shift_term or count2.  The
SPI slave chroma's seven states would become about three, an I2C
slave's receive and transmit loops collapse to one wait each, and the
USB chroma's missing "resynchronise on edges" is the count1-reload
action.  The bit is also taken on the edge clock itself instead of two
to three clocks later (synchroniser plus decision), so the same
protocols run about two to three times faster; a state that no longer
has to watch the clock input keeps one input-mux slot free (the
wire_map limit).  Masters that generate their own clock gain nothing.

Test: `test_sampler` drives a clock on ui_in[1] and data on ui_in[3]
under an idle chroma: bytes shifted on rising and on falling edges,
edges counted on either polarity, a 4-clock clock period, count1
reloaded from PRELOAD and in_prev captured on an edge (white-box), the
pending flag in FLAGS and its clearing by the uart_tx chroma's shift.
SDK: `prism_set_sampler(input, edge, actions)`, `PRISM_CFG3_SMP_*`,
`PRISM_FLAG_SMP_PENDING`; `prism_set_manchester()` keeps the sampler
bits and vice versa.  Harden run 15 (sampler + I2C chroma, no other
RTL change): routing 0 in 30 passes plus a clean re-route, KLayout DRC
0, LVS clean, antenna 0, typical setup +0.62 ns / hold +0.27 ns, fast
hold +0.09 ns, 80 power ports legal, std-cell area 422.2k um2 (+3.4k
over run 13, of which the sampler is a small part: this placement
needed 243 hold buffers against run 13's 1202).

## 4q. I2C slave chroma on the sampler (2026-09-16)

`chromas/chroma_i2c_slave.v`, the sampler's first consumer: 13 states
against 25 for the master, and none of them a bit loop.  SDA comes in on
ui_in[0] (the shifter input), SCL on ui_in[1] (the sampler's clock), and
one output, cond_out[0] on uo_out[2], pulls SDA low through the external
open-drain buffer.  CFG3 = sampler on input 1, rising, shift + count2,
flag2 swaps the edge; CFG2 puts comm == K3, flag2 and comm[0] on inputs
17-19 (0x5ED0) with input 16 left as in_prev[0]; CONST holds the 7-bit
address in K3, 0xFF in K1 and 0 in K0; COMPARE = 7; FIFO A (own, RX)
receives what the master writes, FIFO B (shard 1's, TX) holds what it
reads; the host interrupt fires at a STOP and when the master NAKs the
last byte of a read.

How the states divide the work.  IDLE tracks SDA through in_prev[0]
with the tree-fire capture (a self-jump on every change) and takes SDA
falling while SCL is high as START: comm <= K0, count2 clear, flag2 <=
0.  ADDR_WAIT fires when count2 reaches 7 (COMPARE) and comm == K3: the
seven address bits are compared before the R/W bit arrives, so one
constant serves both directions; ADDR_RW takes the eighth bit and
latches comm[0] into flag2 (read = 1), which from then on makes the
sampler shift on SCL falling edges.  ACK1-3 hold SDA low through the
ninth clock; at its falling edge a write clears comm and count2 and
goes to the receive pair, a read pops FIFO B (or loads K1 = 0xFF).
Receive is two states that alternate every clock through the auto-loop
(A: SDA moved while SCL high, or eight edges in; B: re-capture SDA while
SCL low), because a wait state has two trees and this one needs four
conditions; RESYNC then tells a STOP (SDA high: interrupt, IDLE) from a
repeated START (re-initialise, ADDR_WAIT).  "Eight bits in" is
`count2_cmp & shift_term`, since shift_term alone is also true before
the first shift.  Transmit is one wait state with the bit on cond_out
(`1; if (shift_data) 0`), MACK1 reads the master's ACK at SCL high (NAK:
flag2 <= 0, interrupt, IDLE) and MACK_ACK pops the next byte at SCL
low, where the datapath's pop-over-shift priority discards the sampler's
shift of that same clock.

One compiler fix on the way (yosys-prism, `prism.cc`
`parseLogicExpression`): a bit-level operand inside `&&` / `||` / `!`
(`(sda ^ in_prev0) && scl`, `!(a | b)`, `x == 2'd1 || y`) used to assert
with "unexpected node type"; it now reduces the operand to a boolean the
way identifiers already were, and the slave's conditions are written in
that natural form.  Checked by compiling the slave both ways and diffing
the generated tables (identical), and by rebuilding every chroma
(unchanged).

Test: `test_i2c_slave` with the `I2cMaster` model in `models.py`
(open-drain resolution every clock, `send_start` / `write_byte` /
`read_byte` / `send_stop`): a 3-byte write, a NAK for another address, a
3-byte read ending in NAK, 0xFF from an empty FIFO B, a register write
with a repeated START and a 2-byte read, and the same at an 8-clock
half period (4 MHz SCL at 64 MHz).  Harden run 16 (the edge-swap bit is
the only RTL change since run 15): routing 0 in 19 passes, the fastest
of any run, plus a clean re-route; KLayout DRC 0, LVS clean, antenna 0,
80 power ports legal; timing and area in the memory notes and the run's
metrics.

## 5. FIFO storage, item 9: SRAM spike result

`RM_IHPSG13_2P_64x32_c2` is reachable from the cmos5l PDK
(`libs.ref/sg13cmos5l_sram` is a symlink to the sg13g2 SRAM library) with
LEF, GDS, three lib corners, Verilog and CDL views.  Its GDS uses Metal1 to
Metal4 only (no Metal5 / TopMetal), so the layers fit the CMOS5L stack.  It
is a true dual-port (A and B ports) 64 x 32 macro of 702.83 x 74.87 um,
about 52,600 um2, 1.8 CFGMEM16 macros' worth of area each.

The problem is power.  Its VDD!, VSS! and VDDARRAY! pins are 40 vertical
Metal4 stripes each, 4.42 um wide on a 17.68 um pitch, interleaved so that
VDD and VSS alternate every 8.84 um, with VDDARRAY occupying the top part of
the VDD columns.  The Tiny Tapeout cmos5l tile has a single-layer PDN of
Metal4 stripes on a 50 um pitch (VPWR/VGND 4.1 um apart) and nothing routable
above Metal4, so the CFGMEM trick (macro stripes on the tile grid, extended
to full height) does not apply: the SRAM stripes cannot be made to coincide
with the tile pairs, and both polarities reach the macro edges so no edge
strap can pick one up.  Connecting it would need off-grid Metal4 stripes and
a scheme for the third supply, neither of which the TT chip assembly is
known to accept.

Decision: small standard-cell (flop) FIFOs per shard for now, 16 to 32
bytes, roughly 3 to 6 k um2 each.  If area is left at the end, a small SRAM
macro may go in as an experiment (see section 7), on the chance the design
is selected for manufacture.  If deeper
buffering turns out to matter (frames, not bytes), the DFFRAM.librelane flow
in this workspace can build a small register-file macro with TT-compatible
power stripes the same way the CFGMEM macros were built.

## 6. Decisions (2026-09-12)

1. Outputs are renumbered in one step: break every chroma, fix them all at
   once together with the datapath refactor.
2. `in_prev` replaces `latched_in`.  A LUT3 can only evaluate one edge
   compare, so `in_prev` simply carries the latched value of whichever
   latchable input (ui_in pin or host_in) that decision tree is decoding.
3. Cross-shard signalling: yes, a sticky semaphore in each direction, set by
   the sending shard's OUT_SEMA_SET and cleared by the receiving shard's
   OUT_SEMA_CLEAR.  Same-cycle set/clear priority is a per-shard config bit.
4. A third counter is not needed yet; output 17 stays spare.
5. Interrupt clear stays a byte write (0x03 for shard 0); it is what the
   PCM/ADPCM style chromas depend on.  Interrupts are per shard: two
   interrupt lines back to the host.
6. Host interrupt is a dedicated output (14), not the old COUNT2_CLEAR +
   COUNT2_INC coincidence, which was a 2-tile size workaround.

## 7. SRAM power hookup, second look

Passing the standard 50 um stripe pairs through the macro does not work in
general: a VPWR/VGND pair needs 6.2 um plus clearance and the gaps between
the macro's own Metal4 columns are 4.42 um, and the 17.68 um column period
against the 50 um stripe pitch lets at most 4 of the 14 crossing pairs land
one stripe on a matching column with the other in a gap (best placements at
x = 985.8 or 1003.5 um).  Flattened, the macro's Metal4 is only the vertical
power columns (no horizontal straps), so nothing else is in the way.

A hand-built comb does look feasible: let pdngen carve the tile stripes
around the macro as it does today, then in a scripted step add short Metal4
stubs on every VDD column below the macro and a Metal3 VDD bus under them
(Via3 at the stubs), a second, lower Metal3 bus for the VSS columns with
longer stubs, and the same above the macro for VDDARRAY (tied to VDD) and
VSS.  The buses cross the neighbouring tile stripes, which are strapped with
Via3 at the right polarity.  It needs about 8 to 10 um of halo above and
below, roughly 160 stubs and vias per macro, and a DRC/LVS run to prove it.
Whether the IHP SRAM is valid on CMOS5L silicon at all (same front end as
sg13g2, but no known Tiny Tapeout use) is the remaining unknown.
