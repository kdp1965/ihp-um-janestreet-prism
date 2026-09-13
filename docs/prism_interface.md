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
| 31 | spare | |

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
