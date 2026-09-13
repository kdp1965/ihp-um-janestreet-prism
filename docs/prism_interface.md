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
| 15 | OUT_SEMA_CLEAR | clear the semaphore the other shard set for us; setting the semaphore towards the other shard rides on this shard's OUT_SEMA_SET (see below) |
| 16 | OUT_MANCHESTER_EN | suggestion: enable the Manchester / NRZI encoder-decoder block if added |
| 17 | OUT_LOAD_CRC | load the selected shifter (comm or count1) from the CRC value to transmit the checksum (Phase 4; the third-counter idea moved to a later spare) |
| 18 | OUT_FIFO_SEL | suggestion: select RX/TX FIFO for bit 5 when both exist |
| 19 | OUT_SEMA_SET | set the sticky semaphore seen by the other shard (set/clear same-cycle priority per shard config bit) |
| 20 | spare | |

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
| 12-13 | in_prev[1:0] | edge-capture flops (replace latched_in): latched copy of whichever latchable input (ui_in, host_in) the decision tree is decoding; a LUT3 can only compare one edge, so one in_prev per tree is the natural count.  Still `latched_in` = {shift_data, cond_out[0]} captured by OUT_LATCH (the SPI slave and encoder chromas rely on it); the source selects come with CFG1 |
| 14 | shift_term | shift count reached the configured length (with the "load sets count to 1" mode, items 4/5) |
| 15 | count2_eq_comm | count2 == comm_data |
| 16-17 | in_prev[3:2] | two more capture flops if a shard needs them (config picks the pins) |
| 18-19 | spare | |
| 20 | fifo_empty | shard FIFO |
| 21 | fifo_full | shard FIFO |
| 22 | crc_ok | CRC residue equals the expected / magic value |
| 23 | count1_wrap | count1 rolled over (count-up natural mode) |
| 24 | sema_in | sticky semaphore set by the other shard's OUT_SEMA_SET, cleared by this shard's OUT_SEMA_CLEAR (same-cycle winner = CFG0[24]); implemented Phase 2 |
| 25 | other_shard_halt | the other shard is halted (debugger); implemented Phase 2 |
| 26-27 | fifo_almost_full / fifo_almost_empty | suggestion, programmable threshold |
| 28-31 | spare | Manchester decoder bit / clock, extra compare |

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
| 31:25 | spare | |

CFG1: four 3-bit `in_prev` pin selects (bits 11:0), FIFO almost-full /
almost-empty thresholds (bits 23:16), rest spare.

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
| +0x34 | OUT_MASK (fractured mode) |
| +0x38 | COND_MASK (fractured mode) |
| +0x3C-0x7C | spare (Manchester block, count3, ...) |

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
{count[12:8], almost_full[3], almost_empty[2], full[1], empty[0]}; any
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
count1, per `shift_wide`) from the CRC so the checksum can be sent.

Chromas: `chroma_spislave` pushes received bytes into the RX FIFO and runs
a CRC8 over the received bits; `chroma_uart_tx` (new) is an 8N1
transmitter fed from the TX FIFO that appends the CRC8 on request.

## 4c. Host software (item 11, Phase 5)

The tinyQV-sdk driver (`prism.h` / `prism.c`) covers this design with
`-DPRISM_CONFIG=PRISM_CONFIG_JANESTREET` (`prism_cfg_janestreet.h` holds the
register map above; `tinyQV-js.a` or `prism_js.o`).  The sky25a API is kept:
per-shard calls act on `prism_set_shard()`, `prism_set_ctrl()` writes the
shard's CFG0 plus the common enable, `prism_load_chroma_ex()` adds the pin
mux and `prism_load_shards()` fractures with two chromas.  `test/programs/
sdk_check` runs that driver on the RTL (`make sdk_check` in `test/`).

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
