# PRISM: the Programmable Reconfigurable Indexed State Machine

Author: Ken Pettit

PRISM executes a state machine that is loaded at run time.  The state
machine is written as an ordinary Verilog Mealy FSM, a **chroma**, and
compiled by a Yosys backend into a table of 32 **State Execution Words**
(STEWs) of 128 bits plus the configuration words for the datapath.  The
host CPU loads the table, configures the datapath, enables the machine, and
from then on PRISM makes one decision per clock from its 32 inputs and
drives 21 outputs, with no software in the loop.  This document describes
the machine on the IHP CMOS5L 8x4 tile submitted to the Jane Street competition.
The design record with the reasoning behind each feature is
[prism_interface.md](prism_interface.md); the register constants used by
the tests are in `test/user_peripherals/prism/regs.py`.

Variants of the same RTL: the sg13g2 5x4 tile of the ttihp26b shuttle has no
SRAMs (so no SRAM FIFOs, no tracer and no DMA), 64-byte flop FIFOs, and none
of the features added after it: count3, the bit-stuff unit, the sampler's
preset and Data-Strobe clock, the fractured inputs 26-27, uo_out[0] in the
pinmux and the six-lane comm window.

![](prism_periph.png)

## 1. At a glance

| | |
| --- | --- |
| States | 32, in two banks of 16 |
| State word | 128 bits (STEW), from the CFGMEM latch macros |
| Inputs | 32 per shard, 6 input muxes per state |
| Decision | two 3-input LUTs per state: `if` (tree 0), `else if` / `else` (tree 1) |
| Outputs | 21 per shard, a separate set for the resting state and for each of the two branches |
| Conditional outputs | two per shard, each a 2-input LUT of the current inputs |
| Fracture | one 32-state machine, or two independent 16-state shards |
| Per shard | 24/32-bit count1 (counter or wide shifter), 8-bit count2 with compare, 8-bit count3 with a limit from the data, 8-bit comm shifter, 4 constants, constant table, 16-byte FIFO, 2 KB SRAM FIFO, CRC / counter unit, bit-stuff unit, Manchester recoverer, edge sampler, 4 edge-capture flops, timer 2, interrupt |
| Debug | halt, single step, two breakpoints per shard with entry / if / else-if / exit conditions, live and registered readback |
| Trace | 1024 entries per SRAM (2048 with both), entry = state, decision inputs, outcome |
| DMA | RX: a FIFO into a ring of 2 KB slots in PSRAM B; TX: a slot into FIFO B, single copies or a ring; TinyQV interrupts 10 and 11 |
| Host | TinyQV, 512-byte register region at 0x8000200; CFGMEM loader at 0x8000100; DMA registers at 0x8000020 |

## 2. The core

![](prism_submitted.png)

The current **state index** (SI, 5 bits) addresses the State Information
Table; the word that comes back is the STEW for that state.  While the
machine sits in a state the STEW's *default outputs* drive the 21 outputs.
Six 5-bit fields of the STEW select six of the 32 inputs.  Muxes 0-2 feed
tree 0, a 3-input LUT programmed by 8 STEW bits; muxes 3-5 feed tree 1.
Tree 0 is the chroma's `if`: when its LUT is true the machine jumps to the
tree 0 target state and drives the *tree 0 outputs* for that one clock.
Tree 1 is the `else if` (or a plain `else`, compiled as an always-true
LUT): it is taken when it matches and tree 0 does not, with its own target
and its own outputs.  When neither fires the machine stays.  Two more LUTs,
2 inputs each (cond 0 from muxes 1 and 4, cond 1 from muxes 3 and 5), drive
the **conditional outputs**, whose value follows the inputs within the
state; a chroma writes them as `cond_out[0] = 1'b0; if (x) cond_out[0] =
1'b1;`.

The **inc bit** starts or continues the auto-loop: in a state with `inc`
set, "no match" moves to the next state instead of staying, and the first
such state is remembered; a later state without `inc` and no match returns
there.  The compiler emits it for the idiom "a chain of tests with a
trailing `else -> next state`", so a scan over several states costs no
decision tree.

STEW layout (`chromas/tinyqv32.cfg`).  The word is laid out by consumer
rather than by field: each 32-bit CFGMEM bank feeds one part of the machine
(bank 0 the input muxes, bank 1 the decision, banks 2 and 3 the outputs),
and an output's three legs sit in three adjacent bits, so the wires from
the macros end next to the logic that reads them instead of crossing the
tile.

| bits | field |
| --- | --- |
| 0 | inc |
| 30:1 | mux 0 .. mux 5 input selects, 5 bits each |
| 35:31 | tree 1 jump target |
| 40:36 | tree 0 jump target |
| 48:41 | tree 0 LUT3 |
| 56:49 | tree 1 LUT3 |
| 60:57 | cond 0 LUT2 |
| 63:61 | output 4 (OUT_LATCH): {tree 0, tree 1, default} |
| 65:64, 97:96 | cond 1 LUT2, bits 1:0 and 3:2 |
| 95:66 | outputs 0-3, 5, 12-15 and 19, three bits each: {tree 0, tree 1, default} |
| 127:98 | outputs 6-11, 16-18 and 20, three bits each |

The compiler writes the table from this file and `stew_map.py` generates
the RTL's decode from the same file, so the two cannot drift.

## 3. Shards and fracturing

The 32 states live in two banks of 16: bank A (CFGMEM "lo" macros, states
0-15) and bank B ("hi", states 16-31).  **Unfractured** (FRAC_CFG = 0)
shard 0 is the whole machine: its SI selects the bank with its top bit,
shard 1's index register silently tracks shard 0's low bits so both banks
are always addressed without a mux, and shard 1's datapath idles (its
registers stay accessible, and shard 0 can use shard 1's FIFO as a second
FIFO, section 8).  **Fractured** (FRAC_CFG = 1) each bank is an independent
16-state machine with its own SI, its own 32 inputs, its own 21 outputs, its
own datapath, its own interrupt and its own debugger.  A chroma compiled
with `tinyqv32_shard.cfg` (16 states) loads into either bank.

The two shards see each other in four ways:

- **Semaphores**: OUT_SEMA_SET (output 19) in one shard sets a sticky flag
  the other shard reads as input 24 and clears with its OUT_SEMA_CLEAR
  (output 15).  If set and clear meet in the same cycle the receiving
  shard's CFG0[24] decides who wins.  The host reads both flags in
  INT_STATUS[3:2].
- **Input 25**: the other shard is halted (registered).
- **Inputs 26 and 27**: fractured, each shard sees the other's pin_out[1]
  and pin_out[2], registered: two levels an FSM holds up for its neighbour
  where the semaphore is an event (the VGA line shard's "active lines"
  flag, a SpaceWire receiver's "a link is coming in").
- **Pins**: each shard's PINMUX names a source for every uo_out[7:0] pin, or
  code 7 for "not mine".  A pin claimed by shard 0 goes to shard 0,
  otherwise to shard 1, otherwise to GPIO; a pin freezes while its owning
  shard is halted.

The output and conditional-output masks at 0x44-0x50 gate which of a
shard's outputs reach its datapath while fractured; they reset to zero, so
a fractured configuration must set them.

## 4. Inputs

Every shard has the same 32 inputs.  Bits 0-15 keep the meaning of the
original two-tile PRISM so old chromas read the same; 16 and up carry the
newer features.

![](inputs.png)

| input | meaning |
| --- | --- |
| 0-6 | ui_in[6:0], after the shard's synchroniser select: CFG0[19:18] = 0 two flops, 1 one flop, 2 raw |
| 7 | shift_data: the serial-out bit of the selected shifter (the bit on the pin while the stuff unit transmits, section 6) |
| 8, 9 | host_in[1:0], written by the host (a byte write to +0x15 toggles bit 0 and clears the interrupt) |
| 10 | count1_term: count1 reached 0 counting down, or the preload / roll-over counting up |
| 11 | count2_cmp: count2 >= COMPARE |
| 12, 13 | latched_in: {shift_data, cond_out[0]} captured by OUT_LATCH, or the latched outputs with CFG0[7], or two FSM flags with CFG0[29] |
| 14 | shift_term: the shift count reached the configured length |
| 15 | count2 == comm |
| 16-19 | input slots, default the four edge-capture flops in_prev[3:0] (section 4.1) |
| 20, 21 | own FIFO flags: empty and full by default, CFG1[25:24] / [27:26] pick almost-empty / almost-full / the other side |
| 22 | crc_ok: the CRC equals CRC_EXPECTED; in counter mode, count >= CRC_EXPECTED |
| 23 | count1_wrap: count1 rolled over counting up |
| 24 | semaphore set by the other shard |
| 25 | the other shard is halted |
| 26, 27 | shard 0 unfractured: FIFO B's flags (CFG1[29:28] / [31:30]); fractured: the other shard's pin_out[1] and pin_out[2], one clock old |
| 28-31 | input slots; defaults: 28 the timer 2 tick (section 7), 29 count3 >= limit, 30 the stuff unit dropped a bit (receive) or is holding one (transmit), 31 the stuff unit's next move is a stuff bit |

**Input slots** (CFG2, four bits per slot for inputs 16-19 and 28-31) let a
chroma bring other signals into a state's decision: code 0 the slot's
default, 1-4 in_prev[0..3], 5-12 comm[0..7] (so the decision trees decode a
received byte, a USB PID or a command, without a match register per value),
13 comm == K3, 14 flag2, 15 the Manchester bit-valid / sampler edge-pending
flag.  The compiler parks a state's unused muxes on input 31, never on a
pin, so a spare mux cannot fire an edge capture (section 4.1).

### 4.1 Edge capture (in_prev)

Four flops per shard follow a source each names in CFG1[15:0] (four bits
per flop: 0-6 a ui_in pin after the synchroniser, 8 or 9 a host_in bit).  A
flop captures its source in exactly the cycle a decision tree whose muxes
read that source fires and the transition executes, so `if (pin ^ in_prev0)
-> next` fires once per transition of the pin and re-arms itself.  Two
edges can be watched from one state through tree 0 and tree 1; a flop whose
source the firing tree did not read keeps its value, so several states can
share an edge condition.  Nothing captures while halted, a single step
captures once, and auto-loop transitions never capture.  Program the
sources before enabling: a flop only changes on a capture.  OUT_LATCH
(output 4) and CFG3[26] (the sampler) can capture all four at once.

## 5. Outputs

![](outputs.png)

| output | name | effect |
| --- | --- | --- |
| 0-3 | pin_out[3:0] | pin values, routed to uo_out[7:0] by PINMUX |
| 4 | OUT_LATCH | capture the in_prev flops, latched_in or the FSM flags |
| 5 | OUT_FIFO_WR_RD | push comm into an RX FIFO / pop a TX FIFO into comm (direction CFG0[23]) |
| 6 | OUT_COUNT1_INC_DEC | step count1, direction CFG0[14] |
| 7 | OUT_COUNT1_CLEAR_LOAD | clear count1, or load it from PRELOAD (CFG0[6]) |
| 8 | OUT_SHIFT | shift the selected shifter (CFG0[10]: comm or count1) |
| 9, 10 | OUT_COUNT2_INC / DEC | count2 + 1 / - 1; both in one clock clear it |
| 11 | OUT_COUNT3 | count3 command, with pin_out[3] as the second bit under CFG0[12]: 01 + 1, 10 clear, 11 limit <= comm |
| 12 | OUT_CRC_CLEAR | preset the CRC (counter mode: preset the count) |
| 13 | OUT_CRC_UPDATE | feed the shifter's current bit into the CRC (counter mode: + 1) |
| 14 | OUT_HOST_INTERRUPT | raise the shard's interrupt, once per assertion |
| 15 | OUT_SEMA_CLEAR / OUT_FIFO_PUSH_POP | fractured: clear the semaphore; unfractured shard 0: output 5 acts on FIFO A (0) or FIFO B (1) |
| 16 | OUT_COMM_LOAD | load comm from PRELOAD[7:0], a constant K (CFG0[30]) or the constant table |
| 17 | OUT_LOAD_CRC | load the selected shifter from the CRC, one byte per load through comm (counter mode: - 1) |
| 18, 20 | OUT_K_SEL0 / 1 | which constant OUT_COMM_LOAD takes, or the table's index step; in multi-bit shift mode the width - 1; with a count3 limit load, mask the byte (18) or take a constant (20) |
| 19 | OUT_SEMA_SET / OUT_FLAG2 | fractured: set the other shard's semaphore; with CFG0[29] the value OUT_LATCH stores in flag2 |

Each pin of uo_out[7:0] has a 3-bit PINMUX field ([3k-1:3k-3] for
uo_out[k], [23:21] for uo_out[0]): 0-3 the shard's pin_out[n], 4 and 5 its
conditional outputs, 6 the shifter's serial bit (or a lane of the comm
window in multi-bit mode, or the stuffed bit while the stuff unit
transmits), 7 not driven by this shard.  uo_out[0] is TinyQV's UART TX
unless its GPIO function select is set to PRISM; a chroma's 21-bit
`pinmux_reg` leaves that field at 0, which the UART default keeps off the
pin.

## 6. The datapath

Each shard has its own copy (`prism_datapath.v`), driven by its own outputs
and configured by its CFG0 (the chroma's `ctrl_reg`).

**count1** is a 24-bit register, 32 bits with CFG0[11], that is either a
counter or the wide shift register.  As a counter it steps on output 6, down
by default or up with CFG0[14]; output 7 clears it or loads it from PRELOAD
(CFG0[6]); count1_term (input 10) marks zero counting down, or the preload
(CFG0[15]) or the natural roll-over (input 23, count1_wrap) counting up; the
host reads the count at +0x0C and a write loads it.  As the wide shifter
(CFG0[10]) it shifts on output 8, MSB or LSB first (CFG0[9]), taking its
input from the pin CFG0[1:0] names, from cond_out[0] (CFG0[28]: a bit the
FSM decoded, NRZI or Manchester) or from the Manchester recoverer; a load
can count as the first bit already shifted (CFG0[16]) so shift_term marks
the last.  OUT_LOAD_CRC can load all 32 bits from the CRC.

![](8bit_counter.png)

**count2** is an 8-bit up / down counter (output 9 + 1, output 10 - 1,
both together clear it) compared against the COMPARE byte (input 11,
count2 >= COMPARE) and against comm (input 15, equality).

**count3** is an 8-bit counter that only counts up, with a limit the
machine takes from the data: its command is {pin_out[3] with CFG0[12],
output 11}, 01 = + 1, 10 = clear, 11 = limit <= comm (and the count
restarts), so a chroma clears, loads the length byte it has just received
into the limit, and counts; count3 >= limit (input 29 by default, FLAGS[12])
rises on exactly that step.  With OUT_K_SEL0 the load keeps only the comm
bits outside the mask byte (a length field narrower than the byte, CAN's
DLC); with OUT_K_SEL1 it takes the constant K2 or K3 instead.  The host
reads and writes the count, the limit and the mask at COUNT3 (+0x58).
Without CFG0[12] pin_out[3] stays a pin and output 11 alone counts up.

![](comm_register.png)

**comm** is the 8-bit communication shifter: it shifts on output 8 when
CFG0[10] selects it, MSB or LSB first, from the same input choices as
count1; it is what the FIFOs push and pop, what OUT_COMM_LOAD fills, and
what OUT_LOAD_CRC loads one CRC byte at a time.  A 3-bit shift count marks
the byte boundary on shift_term, and a load or a FIFO pop can count as the
first bit (CFG0[17]).  With CFG0[2] (**multi-bit shift**) each OUT_SHIFT
moves {OUT_K_SEL1, OUT_K_SEL0} + 1 bits at once from pins CFG0[1:0] .. + 3,
and COMM_PINS (+0x50) names a 6-bit window of comm (comm[base + 5:base],
base 0-2) and a lane of it for every output pin with pinmux code 6, so a
byte plays out as four bit pairs, two nibbles or six colour bits at once,
PIO style; the shift count advances by the width so shift_term still marks
the byte.

**Bit stuffing** (CFG3[14]): count2 becomes a run counter of the equal bits
the shifter moves, and COMPARE + 1 the run length that calls for a stuff
bit.  Receiving, the bit after a full run is the stuff bit: that clock's
shift, CRC update, count3 step and FIFO operation are cancelled, and input
30 says a bit was dropped until the next shift.  Transmitting (CFG3[15]), a
FIFO pop, a CRC load or a comm load counts as a move too; after a full run
the shifter holds for one bit time while the pin (pinmux code 6) shows the
complement of the last bit, input 31 says the next move will be a stuff bit
and input 30 that one is being held; input 7 is then the bit on the pin.
OUT_CRC_CLEAR restarts the run (a CAN bus is recessive before the start of
frame), and the FSM's count2 outputs are ignored while the unit is on.  The
unit stuffs after a run of either value, as CAN does; HDLC, which stuffs
only after ones, counts them in count2 from the chroma instead.

**Constants**: CONST (+0x38) holds K0..K3; with CFG0[30] OUT_COMM_LOAD
loads K[{OUT_K_SEL1, OUT_K_SEL0}] (sync words, handshake codes), and K3 is
also the byte comm is compared with for slot code 13.  **Constant table**:
when a shard runs on its SRAM FIFO its 16-byte latch FIFO becomes an
indexed table of 16 rows (CONST_TAB, +0x4C): OUT_COMM_LOAD loads the row at a
4-bit index, and the two K-select outputs say how the index moves on each
load (clear, + 1, + add_to_idx, load idx_load), pre or post; a MAC address
or a fixed reply costs no states.

**Latches and flags**: OUT_LATCH stores {shift_data, cond_out[0]} in
latched_in (inputs 12-13); with CFG0[7] those inputs show two latched
outputs instead; with CFG0[29] OUT_LATCH stores {cond_out[1], cond_out[0]}
there and output 19 in flag2 (slot code 14), three flags a chroma sets and
tests.  CFG3[28] lets flag2 swap the sampler's edge.

The host sees the datapath in COUNTS (+0x10: count2, COMPARE, comm, and the
shift counts), COUNT3 (+0x58) and FLAGS (+0x18: count1_term, count1_wrap,
count2_cmp, count2 == comm, shift_term, shift_data, latched_in, FIFO empty
and full, crc_ok, sampler edge pending, count3 >= limit).  While a shard is
disabled its counters (count1, count2, count3 and the shift counts) are held
at zero and a host write to them is lost; comm, the limit, the mask, the
configuration registers and the FIFO contents keep their values.  A chroma
that needs a count-down timer therefore loads it in its first state rather
than relying on a value written before the enable.

## 7. Timers

**count1** in counter mode is the general timer: load it from PRELOAD,
count down, watch input 10.  Counting up with wrap at PRELOAD (CFG0[14] and
[15]) it is a free-running bit clock instead: input 10 ticks every
PRELOAD + 1 clocks with no output spent, and the edge-clocked sampler can
re-phase it on the line's edges (section 11), which is how the UART
receiver, the CAN node and the SpaceWire transmitter keep their bit timing
in one wait state per bit.

**Timer 2** (PRELOAD2, +0x40) is a free-running 24-bit timer with no FSM
output: it reloads itself and raises input 28 for one clock every period + 1
clocks (0 = off), pacing things while count1 is busy (Ethernet link pulses
every 16 ms need no CPU).  With PRELOAD2[24] the count restarts whenever the
shard enters state PRELOAD2[29:25], which makes the tick a retriggerable
timeout ("nothing for N clocks since the last entry into RX_BIT") with no
STEW bits; with [30] as well it ticks once per timeout and waits for the
next entry.

## 8. FIFOs

Each shard has a **16-byte FIFO** built from latch rows.  CFG0[23] sets its
direction: RX (0), the FSM pushes comm with output 5 and the host pops by
reading +0x20; TX (1), the host pushes by writing +0x20 and output 5 pops
the head into comm.  A push on full and a pop on empty are ignored, and two
pushes of different values must be three clocks apart (the latch rows
share one write bus).  FIFO_STATUS (+0x24) reads the count and the flags,
and any write flushes.  The almost-empty and almost-full levels are
CFG1[19:16] / [23:20] in bytes (almost-empty when count <= level,
almost-full when count >= 16 - level); inputs 20 and 21 show two of the
four flags, chosen by CFG1[27:24].  Contents survive PRISM disable, so a TX
FIFO can be filled before the machine starts.

**Two FIFOs for one machine**: unfractured, shard 0 owns both FIFOs, A its
own and B shard 1's (configured and served by the host through the shard 1
window).  Output 15 says which one output 5 strobes, each per its own
direction, so with A = RX and B = TX output 15 reads as "push / pop", and
inputs 26-27 show B's flags.  Single-FIFO chromas (output 15 = 0) behave as
before.

**SRAM FIFOs**: with CFG0[31] a shard's FIFO is a 2 KB FIFO on its own IHP
512x32 SRAM macro (`prism_sram_fifo.v`), four bytes per word with a cached
head word, the same push / pop / flags interface, the count field widened,
and the levels in 64-byte units.  An Ethernet receiver in one shard and a
transmitter in the other each get a full-frame buffer; unfractured, shard 0
reaches shard 1's SRAM as FIFO B.

**Line replay** (CFG3[29], SRAM FIFO only): a pop while cond_out[0] is
high pushes the popped byte back in at the tail, so a FIFO holding exactly
one line plays it again in order.  The VGA pixel chroma shows each source
line four times from one fetch this way, consuming it on the fourth pass
while the TX DMA copies the next line in behind it; the DMA's tap yields
for the clock of a re-push (section 9.2).

**32-bit access** (CFG3[11], FIFO32 at +0x54): the host moves words.  TX: a
word written there is pushed a byte at a time, low byte first, one every
fourth clock, waiting on a full FIFO; FIFO_STATUS[5] is busy meanwhile and a
word written while busy is dropped, so poll it when the FIFO may be full
(straight-line code never sees it: four pushes take 13 clocks, TinyQV's
instructions 16).  RX: a pop machine takes four bytes as soon as the FIFO
holds them, low byte first, into a word register; FIFO_STATUS[4] and the
shard's interrupt say the word is complete, and a read of FIFO32 takes it.
A byte read of +0x20 while the word register holds anything is served from
its low byte, the rest shift down and the machine refills the top, so byte
order is the same however word and byte reads are mixed; a short message's
stragglers show in FIFO_STATUS (the count, or [7:6] after byte reads) and
are read as bytes.

## 9. DMA

Two DMA engines move frames between the PRISM's FIFOs and the QSPI PSRAM
without the host touching a byte: the **RX DMA** (`prism_dma.v`) drains a
receive FIFO into a ring of 2 KB slots in RAM B, and the **TX DMA**
(`prism_txdma.v`) fills FIFO B from such a slot, one frame at a time or from
a ring of its own.  Both sit next to TinyQV rather than inside the PRISM (a
first version inside the PRISM ran its 32-bit data and 25-bit address buses
through the CFGMEM mouths and tripled the global-routing overflow), and only
byte-serial taps cross the tile: the FIFO head, a few flags and a pop strobe
one way; a byte, a push strobe and a room flag the other.

**The memory port.**  Each engine operates through a second master on TinyQV's
QSPI memory port.  An engine takes the port when the CPU has no memory
transaction in flight and is not inside a continued transfer, keeps it for
one burst of up to eight 32-bit words (32 bytes, 64 SPI clocks, inside the
over, and code fetched from flash runs between bursts.  The two engines share
the added master port, the RX DMA with higest priority, and the owner keeps it
until its request drops, so a waiting RX burst goes after at most one TX burst.  
At 10 Mb/s with a 60MHz system clock, the receive side holds the port about 10 %
of the time in 32-byte bursts (15 % in chain mode, below).

The registers are TinyQV internal peripheral registers (word access), not
PRISM ones: DMA_CFG 0x8000020, DMA_STATUS 0x8000024, TXDMA 0x8000028,
TXRING_CFG 0x800002C and TXRING_STATUS 0x8000034.  The RX DMA raises TinyQV
user interrupt 10 per frame and the TX DMA interrupt 11; the SDK's
`enable_interrupt(10)` / `enable_interrupt(11)` (csr.h) unmask them and the
handlers are `tqv_user_interrupt10()` / `tqv_user_interrupt11()`.  The SDK
has no DMA calls yet: the programs under `test/programs` (dma_verify,
txdma_verify, ethtx_verify, ethloop_verify, ethring_verify, vga_verify)
define the registers themselves and are the reference drivers.

### 9.1 RX DMA: a receive FIFO into a ring in PSRAM B

The engine pops one byte per clock from the selected FIFO (A or B,
DMA_CFG[1]) into a word register; each full word is one 32-bit PSRAM write.
A burst starts when the FIFO reaches its almost-full level (CFG1[23:20] of
the receiving shard: on the 16-byte flop FIFO the level is in bytes and
almost-full means count >= 16 - level, so a level of 4 bursts at 12 bytes)
or when a frame ends; the last one to three bytes of a frame go out as byte
writes.

**The ring.**  2^K slots of 2 KB (K = DMA_CFG[6:4]) from a base in RAM B
given in 2 KB units (DMA_CFG[22:11]): slot i is at 0x1800000 + (base + i)
x 2048.  Word 0 of a slot is the frame header: [10:0] the length in bytes
(frame plus FCS), [15] the frame did not fit and was cut at 2040 bytes,
[16] crc_ok, the receiving shard's crc_ok flag latched when the frame
ended, so the host never races the next frame's CRC preset.  Word 1 is
left alone (section 9.3 uses it) and the frame starts at byte 8, word
aligned.  The engine owns `head`: it fills slot head, and at the frame end
writes the header, advances head and raises its interrupt.  Software owns
`tail`: a slot is free again once tail has passed it.  A frame that starts
while (head + 1) mod 2^K == tail is consumed and dropped with the overflow
flag set, so a full ring never stalls the chroma: the bytes are still
popped.

**Frame end.**  Either the receiving shard's OUT_HOST_INTERRUPT (with
DMA_CFG[3]; the eth_rx chroma raises it after a frame's last byte, and the
pulse then goes to the engine instead of latching the shard's own
interrupt, so that shard no longer interrupts the host) or a write of
DMA_STATUS[31] by software.  The engine closes the frame when the FIFO next
reads empty after the pulse, not after a byte count: on the 16-byte flop
FIFO that is a few hundred clocks, inside 10BASE-T's minimum frame spacing,
and back-to-back frames keep their boundaries.  An SRAM FIFO in RX mode
works with the engine too, but its almost-full level counts 64-byte units
of free space, so up to about 1 KB can still be queued when a frame ends
and the next frame's first bytes would land in the same slot: receive frame
traffic on the flop FIFO.

**Chain mode** (DMA_CFG[7]): when FIFO B is idle (the transmitter on the
SRAM FIFO, or no transmitter) a mover in the PRISM pops A and pushes B
whenever A holds a byte and B has room, one byte every third clock; the
engine drains B (shard select 1, B's almost-full level as the trigger) and
the frame end comes from shard 0.  The two 16-byte FIFOs act as one 32-byte
one.  The TX DMA, which also pushes B, does not run with chain mode.

| DMA_CFG (0x8000020, read / write) | |
| --- | --- |
| [0] | enable; writing 0 resets head, tail and the flags |
| [1] | shard: 0 drains FIFO A, 1 FIFO B |
| [2] | interrupt enable: TinyQV interrupt 10 while the irq flag is set |
| [3] | frame end = the receiving shard's host interrupt |
| [6:4] | K: 2^K slots |
| [7] | chain: FIFO A drains into FIFO B by itself |
| [22:11] | ring base in RAM B, 2 KB units |

| DMA_STATUS (0x8000024) | read | write |
| --- | --- | --- |
| [7:0] | head | |
| [15:8] | tail | the new tail, taken when [24] is set |
| [16] | irq: a frame has landed | 1 clears it |
| [17] | overflow: a frame was dropped | 1 clears it |
| [18] | busy: a frame is being written | |
| [19] | dropping: the current frame is being consumed | |
| [24] | | load tail from [15:8] |
| [30:20] | slot offset of the next byte (8 = nothing of a frame yet) | |
| [31] | | end the current frame |

**Software.**  Configure the receiving shard first: its FIFO in RX mode
(CFG0[23] = 0), the almost-full level in CFG1[23:20], and a chroma that
pushes bytes and pulses output 14 at the end of each frame.  One write to
DMA_CFG with enable, shard, K, base, the hardware frame end and the
interrupt enable then starts the engine, and nothing is needed per frame.
The handler (or a polling loop) reads DMA_STATUS, processes every slot from
tail up to head (the header gives length and crc_ok, the frame is at byte
8), and writes DMA_STATUS once with [24] and the new tail in [15:8] plus
[16] to clear the interrupt; [17] reports an overflow and a 1 clears it.
Keep tail moving: the ring holds 2^K - 1 frames and the engine drops the
ones that find it full.  Frames the hardware cannot end (a chroma without
a host interrupt, or a FIFO drained as a byte stream) are ended with
DMA_STATUS[31].  DMA_CFG = 0 stops the engine and resets the ring.
dma_verify (chain mode, software frame ends, a two-slot ring) and
ethring_verify (eth_rx on shard 0, hardware frame ends, eight slots) show
both ways.

### 9.2 TX DMA: a slot of PSRAM B into FIFO B

The copy engine fills FIFO B, shard 1's FIFO, which must be its SRAM FIFO
(CFG0[31]) in TX mode (CFG0[23] = 1): the SRAM FIFO takes a push every
clock, and FIFO B is the TX FIFO of the unfractured chromas and of a
fractured transmitter on shard 1 while the RX DMA drains A.  It reads
32-bit words in bursts of up to eight inside one QSPI transaction, starts a
burst only while FIFO B has room for all of it (32 free bytes), so the push
side never holds the PSRAM's CS low, and pushes the bytes of each word one
per clock.  The tap pauses in a clock the FIFO re-pushes a byte itself (the
VGA line replay, CFG3[29]).

**One copy** (TXDMA): the host names the slot, the length and where in the
slot the copy starts, and starts the chroma itself (the host_in toggle at
+0x15 of shard 1, or whatever the chroma waits for).  The skip bit starts
the copy at slot byte 4, the RX DMA's slot format, so a received slot goes
back out as it is; the start block names one of eight 256-byte records in a
slot, which is how the VGA frame buffer keeps eight 160-byte lines per slot
and copies one per line interrupt (prism_interface.md section 4b.12).  The
host does not push FIFO B itself while a copy runs.

| TXDMA (0x8000028) | write | read |
| --- | --- | --- |
| [11:0] | frame length in bytes (0 to 2048) | bytes still to push |
| [23:12] | slot: RAM B address 0x1800000 + slot x 2048 | slot |
| [24] | skip the slot header: the copy starts at slot byte 4 (at most 2044 bytes then) | skip |
| [25] | interrupt enable: TinyQV interrupt 11 while done | interrupt enable |
| [28:26] | start block: the copy starts block x 256 bytes into the slot (plus 4 with skip) | block |
| [30] | acknowledge: clear done | done |
| [31] | start a copy with these settings (ignored while busy or while the ring is on) | busy |

**Software.**  Build the frame in a 2 KB slot of RAM B (0x1800000 + slot x
2048), write TXDMA with start, the slot, the length and the flags, then
start the chroma.  Done ([30], interrupt 11 if enabled) says the whole
frame is in FIFO B; the chroma's own host interrupt says it has been sent.
Acknowledge with [30], and the next copy can go as soon as busy drops.  A
copy that finds FIFO B too full simply waits for the chroma to pop
(txdma_verify fills 2044 bytes and shows a further copy resuming once 64
bytes are popped).

### 9.3 TX ring: frames back to back with no host work per frame

With single copies the next frame can only enter FIFO B after the chroma
has sent the current one, so the host's turnaround sets the gap between
frames (about 5000 clocks with the code in flash, eight times Ethernet's
minimum).  The ring moves that sequencing into the engine.  It works with
any transmitting chroma that ends its frame when FIFO B runs empty and
raises its host interrupt then (eth_tx), with no chroma change.

The ring is 2^K slots of RAM B (K = 1 to 4, from a base in 2 KB units) in
the RX DMA's slot format: word 0 holds the byte count L (at most 2044) and
the engine sends L bytes from slot byte 4.  For eth_tx, whose first four
preamble bytes come from its K0 constant, the host writes 55 55 55 D5 into
word 1 and the frame without its FCS from byte 8, with L = frame + 4.  A
slot the RX DMA filled already has the frame at byte 8 and L = frame + FCS
= frame + 4, so writing 55 55 55 D5 into its spare word 1 is all it takes
to forward it: the ring sends the preamble tail and the frame and stops
before the received FCS, and eth_tx appends a new one.  For each slot from
tail to head the engine reads L, copies the frame, and starts the chroma by
toggling shard 1's host_in[0] once the inter-frame gap since the previous
frame's end has passed and 16 words (or the whole frame) are in.  Shard 1's
host interrupt then ends the frame: it goes to the engine, not the host;
tail advances, the frame-sent flag rises (interrupt 11 when enabled), the
gap timer starts and the next slot is copied at once.  FIFO B holds one
frame at a time, since the chroma ends a frame on an empty FIFO.  TXDMA
single copies are ignored while the ring is on.

| TXRING_CFG (0x800002C, read / write) | |
| --- | --- |
| [0] | enable; writing 0 resets head, tail and the frame-sent flag (a copy under way still finishes: flush FIFO B after it) |
| [3:1] | K: 2^K slots, K = 1 to 4; head == tail means empty |
| [6] | interrupt enable: TinyQV interrupt 11 while the frame-sent flag is set |
| [17:8] | inter-frame gap in clocks, from a frame's end to the next start |
| [27:20] | ring base in RAM B, 2 KB units: slot i at 0x1800000 + (base + i) x 2048 |

| TXRING_STATUS (0x8000034) | read | write |
| --- | --- | --- |
| [3:0] | head | the new head, taken when [24] is set |
| [11:8] | tail | |
| [16] | frame sent | 1 clears it |
| [17] | a frame is on its way | |
| [24] | | load head from [3:0] |

**Software.**  Put shard 1's FIFO on its SRAM in TX mode and start the
chroma in its idle state; enable the ring with K, the base, the gap (96 bit
times for Ethernet: 96 x the clocks per bit) and the interrupt enable.  From
then on the host's only work is filling slots and advancing head: fill slot
head (word 0 = L, word 1 = the preamble tail, the frame from byte 8), then
write TXRING_STATUS with [24] and the new head; several filled slots can be
released with one head write.  The ring queues 2^K - 1 frames, so head must
not be advanced onto tail; the tail field says which slots are free again,
and the frame-sent flag (cleared by writing [16]) paces a producer that
waits for room.  TXRING_CFG = 0 followed by a flush of FIFO B (any write to
shard 1's FIFO_STATUS) returns the chroma's interrupt to the host.
ethring_verify queues six frames with one head write, forwards a received
slot by writing its word 1, and checks that none of shard 1's end-of-frame
interrupts reach the host while the ring is on.

**Full duplex.**  eth_rx on shard 0 with the flop FIFO A and the RX DMA,
eth_tx on shard 1 with FIFO B on SRAM[1] and the TX ring: received frames
land in RAM B with their length and crc_ok, frames to send leave from RAM
B, and the CPU handles headers, never bytes.  The tests are `make
dma_verify`, `make txdma_verify`, `make ethtx_verify`, `make
ethloop_verify` and `make ethring_verify`, programs run on TinyQV in the
cocotb bench with its QSPI flash and PSRAM models.

## 10. CRC unit and counter mode

A bit-serial CRC per shard (`prism_crc.v`): width from CFG0[21:20] (8, 16
or 32 bits; 0 = off), a programmable polynomial (CRC_POLY, +0x28), reflected
(LSB first, CFG0[22]) or not, preset to zero or all ones (CFG0[25]) by
output 12, fed one bit per output 13 with the bit the shifter is receiving
or transmitting that clock (CFG0[27]), complemented on output (CFG0[26]).
The host reads or presets the value at +0x2C; input 22 (crc_ok, also
FLAGS[10]) says the value equals CRC_EXPECTED (+0x30), the residue after
data plus checksum, so a receiver checks a frame with one input.  To
transmit a checksum, output 17 loads the selected shifter from the CRC: the
wide shifter takes all 32 bits, comm takes one byte per load in wire order
and the register advances, so CRC16 / CRC32 go out in 2 / 4 loads.  CRC-8
0x07, CRC-16/CCITT 0x1021, CRC-16/X.25 0x8408 (reflected, HDLC), CRC-16/USB
0xA001 (reflected), USB CRC5 0x14, CRC-32 0xEDB88320 (reflected, Ethernet)
and CAN's CRC-15 (0x8B32 in the 16-bit mode, the polynomial shifted up one
bit) have all run, and a parity bit is a CRC-8 with the polynomial 0x80
(SpaceWire).

**Counter mode** (CFG3[10], with the CRC off): the same 32-bit register is
an up / down counter on the same strobes, output 12 presets it, 13 counts
up, 17 counts down (both in one cycle: hold; no shifter load), and input 22
becomes the unsigned compare count >= CRC_EXPECTED.  The host reads or
presets the count at +0x2C and sets the compare at +0x30.  One adder and one
comparator per shard; no extra flops.

## 11. Receiving clocked and self-clocked lines

**Manchester bit recoverer** (`prism_mrx.v`, CFG3[9:0]): names a pin
([2:0]), the clocks per half bit ([7:4]) and an enable ([3]); an edge on the
line is accepted when three quarters of a bit have passed since the last
accepted edge, so the boundary transition between equal bits is skipped
and every mid-bit edge re-times the decoder; the level after the accepted
edge is the bit.  With [8] the shifter takes that bit as its input, and
"bit valid" is slot code 15, sticky until the FSM's shift consumes it, so a
two-state receive loop never misses a bit.  With [9] the pin is sampled on
both clock edges and [7:4] counts half clocks per half bit (6 at 64 MHz, 5
at 50 MHz), doubling the edge resolution; 10BASE-T receive keeps its margin
down to a 50 MHz tile clock.

**Edge-clocked sampler** (CFG3[28:16]): names any PRISM input ([21:17]) and
an edge ([23:22]: rising, falling, either, or either edge of that input xor
the next one up among inputs 0-7, the bit clock of a Data-Strobe pair such
as SpaceWire's), and on every such edge the datapath acts with no state
transition: shift ([24]), count2 + 1 ([25]), capture the in_prev flops
([26]), count1 clear / load ([27]).  With CFG3[13:12] = k (1 to 3) the
timer action presets count1 to PRELOAD >> k instead of loading it: when
count1 counts up and wraps at PRELOAD its terminal count is a periodic bit
clock, and each edge puts the next tick 1 - 2^-k of a bit later (k = 2
samples 75 % into the bit, as CAN asks; k = 1 mid-bit for a UART), so a
receiver re-synchronises on every edge with no state spent.  A clocked
slave protocol no longer spends states on its bit loop; the FSM acts at
byte boundaries on shift_term or count2.  With [28] flag2 swaps rising and
falling, so one FSM flag turns a bidirectional protocol's sampling edge
(an I2C target receives on SCL rising and drives after SCL falling).  A
sticky "edge pending" flag (slot code 15, FLAGS[11]) is cleared by the
FSM's OUT_SHIFT or OUT_LATCH.

## 12. Interrupts

Each shard has one interrupt line to the host (TinyQV user interrupts 8
and 9, CTRL[31] and [29], INT_STATUS[1:0]).  It is set by output 14 once per
assertion (a state that holds it does not re-arm it), by a debugger halt, and
in 32-bit RX mode while a complete word waits in FIFO32.  It is cleared by
a byte write with bit 7 to 0x003 (shard 0) or 0x007 (shard 1), by the
host_in toggle write (+0x15), or by disabling PRISM; the word-ready source
clears when the word is read.

The DMA engines have two more lines: the RX DMA raises TinyQV user
interrupt 10 when a frame has landed in its ring, and the TX DMA interrupt
11 when a copy is done or a ring frame has been sent (section 9).  While
the RX DMA takes its frame ends from a shard's output 14 (DMA_CFG[3]), or
while the TX ring is on, that shard's output 14 goes to the engine instead
of the host and the shard no longer interrupts.

## 13. Debugger

Each shard has a debug control word (0x04 shard 0, 0x08 shard 1):

| bits | field | meaning |
| --- | --- | --- |
| 0 | halt_req | halt (on the rising edge) and hold |
| 1 | step | rising edge: execute one transition |
| 2, 3 | bp_en0, bp_en1 | breakpoint enables |
| 8:4, 13:9 | bp_si0, bp_si1 | breakpoint state |
| 15:14, 17:16 | bp_cond0, bp_cond1 | 0 on entry, 1 when tree 0 matches in the state, 2 when tree 1 is taken, 3 when either is, that is on exit |
| 18 | new_si | write-only: load the state index from bits 23:19 |

A conditional breakpoint fires in the cycle the selected tree first matches
while the machine sits in the state, before the transition's outputs
happen, so the value that satisfied the condition is still there to read;
a single step then performs the transition with its outputs and halts in
the target.  Keep halt_req set while stepping.  STATUS (0x0C) shows, per
shard, the current and next state index, the halt and which breakpoint hit;
0x10-0x1C read back the four words of shard 0's current STEW; 0x34 the
decision inputs and LUT results; 0x38 the outputs; 0x3C the input vector.
While a shard is halted its datapath, pins, semaphores and interrupt edge
are frozen with it.

## 14. Trace

Each shard has a tracer (TRACE_CFG +0x44, TRACE_CTRL +0x48).  From its
trigger on, every clock's `{executing, tree 1 taken, tree 0 matched, the
six selected input bits, SI}` is written as a 16-bit entry, two per SRAM
word, into an SRAM until the buffer is full: 1024 entries on one SRAM,
2048 with both as one buffer (TRACE_CFG[1]), and with TRACE_CFG[6] into the
other shard's SRAM so a chroma streaming from its own SRAM FIFO can be
traced while it does so.  Triggers: at once; in a given state; that state
taking either jump; or an edge (rising, falling, either) on any of the 32
inputs.  Entry 0 is the trigger cycle.  Arm with TRACE_CTRL = 1 (the traced
SRAM's FIFO is flushed), wait for done (or stop with 2), then read the
entries as FIFO bytes through the window that reads that SRAM: while an
SRAM holds a finished trace the window sees it as its SRAM FIFO in RX mode,
count = entries x 2, each read of +0x20 the next byte, low byte first.  The
21 outputs of a traced clock are not stored: they follow from the entry and
the loaded chroma (the STEW's three output fields), and the SDK rebuilds
them.  One shard traces at a time; shard 0 wins if both enable.

## 15. CFGMEM: the state table and how it is loaded

The table is eight latch-array macros, 16 rows x 32 bits each, generated by
a DFFRAM-derived flow (`CFGMEM_IHP16` and its left-hand mirror
`CFGMEM_IHP_LEFT16`, one of them the `CFGMEM_IHP_LEFT16_SRAM` variant whose
rails sit on the SRAM's supply columns; the views are in `macros/`), placed
as two columns beside the standard cells.  Four macros make bank A (states
0-15: row s of macros lo0..lo3 is state s's STEW, lo0 the low word) and
four bank B (hi0..hi3, states 16-31).  Every clock the machine reads a
whole 128-bit row from each bank through the macros' read ports; latch
arrays rather than flops because a row is read every clock and written
only when a chroma is loaded, and a latch bit is far smaller than a flop
with its write mux.

The CPU loads them through the CFGMEM loader peripheral at 0x8000100.  Its
control byte at 0x1F is `[3:0]` row address, `[4]` address select (the host
addresses the row instead of the machine), `[5]` busy (read-only: the
loader's shift takes 49 clocks, more than a back-to-back store), `[6]`
bypass lo, `[7]` bypass hi.  The macros of a bank form two shift chains, one
per macro column (host word -> macro 0 -> 1 and host word -> macro 2 -> 3,
so no download wire crosses the tile), and each macro's output is its
addressed row, or its input while the bank's bypass bit is set, so under
bypass every macro sees the host word.  Loading is
therefore: set the bank's bypass bit, then for each state from the highest
down, write its four words, most significant first, to the macro ports
(`0x00 + 4i` for lo i, `0x20 + 4i` for hi i, word 0 to macro 3 down to word
3 to macro 0), waiting on busy between writes; each write shifts the chain
one row, so state 0 ends in row 0.  Clear the control byte afterwards to
hand the row address back to the machine.  Reads with the bypass clear and
address select set return each macro's row at the addressed index, which
is how a loaded table is verified.  The compiler's `.py` / `.c` output is
the word list in this order, so `prism_load_chroma()` is a loop.

## 16. Register map

All registers are word aligned at +4 offsets; a byte read returns the
addressed byte lane in the low bits, so packed registers can be read and
written a byte at a time.  Offsets are from 0x8000200.

### 16.1 Common block

| offset | register |
| --- | --- |
| 0x00 | CTRL: [30] enable, [31] shard 0 interrupt (RO), [29] shard 1 interrupt (RO); byte 0x03 write with bit 7 clears shard 0's interrupt, byte 0x07 shard 1's |
| 0x04, 0x08 | DBG_CTRL shard 0 / shard 1 (section 13); read back = {state index[23:19], control[17:0]} |
| 0x0C | STATUS: shard 0 in [12:0], shard 1 in [25:13], each {break[1:0], halt, next SI[4:0], current SI[4:0]} |
| 0x10-0x1C | the four words of shard 0's current STEW |
| 0x20 | ID |
| 0x24 | INT_STATUS: [1:0] shard interrupts, [3:2] semaphores as seen by shard 0 / shard 1 |
| 0x30 | DEBUG_DOUT: the outputs a halted shard presents |
| 0x34 | DECISION: LUT inputs and results |
| 0x38 | OUT_DATA: the live output vector |
| 0x3C | IN_DATA: shard 0's input vector |
| 0x40 | FRAC_CFG: [0] fractured |
| 0x44, 0x48 | shard 0 output mask, conditional-output mask (fractured) |
| 0x4C, 0x50 | shard 1 output mask, conditional-output mask |

### 16.2 Shard window (shard 0 at 0x100, shard 1 at 0x180)

| offset | register |
| --- | --- |
| +0x00 | CFG0: datapath configuration, the chroma's `ctrl_reg` (section 16.3) |
| +0x04 | PINMUX: uo_out[7:1] sources in [20:0], 3 bits per pin, the chroma's `pinmux_reg`; [23:21] uo_out[0] |
| +0x08 | PRELOAD (32 bits) |
| +0x0C | COUNT1: read the count, write loads it (while the shard is enabled) |
| +0x10 | COUNTS: byte 0 count2, byte 1 COMPARE, byte 2 comm, byte 3 {comm_count[2:0], shift_count[4:0]} (RO); bytes 0-2 writable |
| +0x14 | HOST: host_in[1:0]; a byte write to +0x15 toggles host_in[0] and clears the interrupt |
| +0x18 | FLAGS (RO): [0] count1_term, [1] count1_wrap, [2] count2_cmp, [3] count2 == comm, [4] shift_term, [5] shift_data, [7:6] latched_in, [8] FIFO empty, [9] FIFO full, [10] crc_ok / count >= compare, [11] sampler edge pending, [12] count3 >= limit |
| +0x1C | CFG1: [15:0] in_prev sources, [19:16] / [23:20] FIFO almost-empty / almost-full levels (bytes; 64-byte units on an SRAM FIFO), [25:24] / [27:26] input 20 / 21 flag selects, [29:28] / [31:30] inputs 26 / 27 (FIFO B) |
| +0x20 | FIFO: byte write pushes (TX), byte read pops (RX) |
| +0x24 | FIFO_STATUS: {count[21:8], word bytes[7:6], push busy[5], word full[4], almost_full[3], almost_empty[2], full[1], empty[0]}; any write flushes |
| +0x28 | CRC_POLY |
| +0x2C | CRC: value; write presets (counter mode: the count) |
| +0x30 | CRC_EXPECTED (counter mode: the compare value) |
| +0x34 | CFG2: input slot selects, 4 bits each, inputs 16-19 in [15:0] and 28-31 in [31:16] |
| +0x38 | CONST: K0 [7:0] .. K3 [31:24] |
| +0x3C | CFG3: Manchester recoverer [9:0], counter mode [10], 32-bit FIFO access [11], sampler preset k [13:12], bit-stuff unit [14] enable / [15] transmit, edge-clocked sampler [28:16], SRAM FIFO replay [29] |
| +0x40 | PRELOAD2: timer 2 [23:0] period, [24] restart on entry into state [29:25], [30] one-shot |
| +0x44 | TRACE_CFG (write-only): [0] enable, [1] both SRAMs, [6] other shard's SRAM, [3:2] trigger (0 now, 1 in state [12:8], 2 that state jumping, 3 an edge on input [20:16], [5:4] 0 rising 1 falling 2 either) |
| +0x48 | TRACE_CTRL: write [0] arm, [1] stop; read [0] armed, [1] running, [2] done, [3] big, [4] active |
| +0x4C | CONST_TAB: [0] enable, [1] add idx_load, [2] post, [7:4] idx_load, [10:8] add_to_idx, [19:16] index |
| +0x50 | COMM_PINS: [2:0] window base (comm[base + 5:base]), [3k+6:3k+4] lane 0-5 for uo_out[k] |
| +0x54 | FIFO32: 32-bit FIFO access (section 8) |
| +0x58 | COUNT3: [7:0] count3, [15:8] limit, [23:16] mask (byte lanes writable; a disable clears the count, not the limit or the mask) |

### 16.3 CFG0, the chroma's control word

| bits | name | meaning |
| --- | --- | --- |
| 1:0 | shift_in_sel | the ui_in pin that feeds the shifter (multi-bit mode: pins sel .. sel + 3) |
| 2 | mshift_en | multi-bit comm shift, {out20, out18} + 1 bits per shift |
| 6 | clr_not_load | output 7 clears count1 instead of loading it |
| 7 | latch_in_out | inputs 13:12 show latched outputs instead of latched inputs |
| 8 | shift_en | shifting enabled |
| 9 | shift_dir | 0 MSB first, 1 LSB first |
| 10 | shift_wide | output 8 shifts count1 (1) or comm (0) |
| 11 | count32 | count1 is 32 bits (0: 24) |
| 12 | count3_en | pin_out[3] is count3's second command bit, not a pin |
| 13 | latch_en | OUT_LATCH enabled |
| 14 | count_up | count1 counts up |
| 15 | wrap_preload | counting up rolls over at PRELOAD instead of naturally |
| 16 | shift_load_one | a wide-shifter load counts as the first shift |
| 17 | comm_load_one | a comm load or pop counts as the first shift |
| 19:18 | in_sync_sel | pin synchroniser: 0 two flops, 1 one flop, 2 raw |
| 21:20 | crc_mode | 0 off, 1 CRC-8, 2 CRC-16, 3 CRC-32 |
| 22 | crc_reflect | LSB first into the CRC |
| 23 | fifo_dir | 0 RX (FSM pushes, host pops), 1 TX (host pushes, FSM pops) |
| 24 | sema_set_wins | semaphore set beats clear in the same cycle |
| 25 | crc_init_ones | preset to all ones |
| 26 | crc_xor_out | complement on OUT_LOAD_CRC |
| 27 | crc_src | 0 the shifter's input bit, 1 its output bit |
| 28 | shift_in_cond | the shifter's input is cond_out[0] |
| 29 | flag_latch | OUT_LATCH stores {cond_out[1], cond_out[0]} in latched_in and output 19 in flag2 |
| 30 | comm_load_k | OUT_COMM_LOAD takes constant K[{out20, out18}] |
| 31 | fifo_sram | this shard's FIFO is its SRAM FIFO |

## 17. Chromas

A chroma is a Verilog module with the fixed ports `clk, rst_n, fsm_enable,
in_data[31:0], out_data[20:0], cond_out[1:0], ctrl_reg[31:0],
pinmux_reg[20:0]`: a state register, a `case` on it, `if / else if / else`
transitions on the inputs, and constant assignments to the outputs in each
state.  The compiler is a Yosys backend
([yosys-prism](https://github.com/kdp1965/yosys-prism), `synth_prism -cfg
chromas/tinyqv32.cfg`): it maps the FSM onto the STEW fields, checks that
each state's conditions fit the six muxes and two trees, emits the `inc`
loop idiom, and writes the table as a Python list, a C array and a
columnar listing, together with the `ctrl_reg` and `pinmux_reg` values the
chroma declared.  Rules it enforces: one wire per output bit, constants in
the always block (an input-dependent conditional output is written as a
default plus an `if`), and a trailing `else -> next state` behind at least
one condition always compiles to the auto-loop.

    module chroma_uart_tx ( input clk, rst_n, fsm_enable, input [31:0] in_data,
                            output [20:0] out_data, output reg [1:0] cond_out,
                            output reg [31:0] ctrl_reg, output reg [20:0] pinmux_reg );
       ...
       STATE_IDLE:
          if (!fifo_empty)            // input 20
          begin
             fifo_pop = 1'b1;         // output 5: comm <= FIFO head
             count1_load = 1'b1;      // output 7: bit timer from PRELOAD
             next_state = STATE_START;
          end
       ...

The library in `chromas/`, every one with a cocotb test against a model of
the far end:

| chroma | what it does |
| --- | --- |
| gpio24 | 24-bit GPIO expander: 74165 in, 74595 out |
| spislave | SPI slave with a CRC-8 trailer |
| spi_master | SPI master, single or quad lane |
| uart_tx | 8N1 transmitter from the TX FIFO, CRC-8 on request |
| i2c_master | I2C controller through external open-drain buffers |
| i2c_slave | I2C target on the edge-clocked sampler |
| onewire | 1-Wire master |
| ws2812 | WS2812 LED transmitter |
| encoder | quadrature encoder decode |
| pio | 4-channel logic analyser and 2-lane waveform generator (multi-bit shift) |
| usb_ls | USB low-speed device: NRZI, bit unstuffing, CRC-5 / CRC-16, DATA0 / DATA1 |
| eth_tx | 10BASE-T transmitter from the SRAM FIFO, CRC-32 FCS, link pulses on timer 2 |
| eth_rx | 10BASE-T receiver on the Manchester recoverer, FCS checked by crc_ok |
| uart_rx | 8N1 receiver on the periodic bit clock, re-phased mid-bit by the sampler; CRC-8 over the data |
| can_rx, can_tx | CAN 2.0A node when fractured: the receiver (ACK, CRC-15, the bit clock re-phased to sample at 75 %) and the transmitter (arbitration, the stuff unit, the ACK check) |
| hdlc_rx, hdlc_tx | synchronous HDLC: flags, zero insertion / deletion counted in count2, CRC-16 / X.25 |
| jtag_master | JTAG controller: TAP walks and IR / DR scans from FIFO B, TDO back into FIFO A |
| swd_host | ARM SWD host: requests, turnarounds, the ACK, reads and writes |
| ps2_host | PS/2 port: receives a keyboard's or mouse's bytes and sends it commands |
| spw_tx, spw_rx | SpaceWire link, the passive end: Data-Strobe on the sampler, NULLs, FCT credit over the semaphore, the errors and the restart, the link started by the chromas themselves |
| vga_px, vga_ln | 160 x 120 RGB222 frame buffer at 640 x 480 timing on the Tiny VGA PMOD, the lines fetched from the PSRAM by the TX DMA and replayed from the SRAM FIFO |
| fifo_loop, edge, const_tab, counter, count3 | unit tests of the two-FIFO mode, the edge capture, the constant table, the counter mode and count3 |

The tests (`test/user_peripherals/prism/`) load each chroma through the
CFGMEM loader exactly as software does, and run unchanged on the gate-level
netlist.  Host software uses `prism.h` from the
[tinyQV-sdk](https://github.com/kdp1965/tinyQV-sdk) with `PRISM_CONFIG`
janestreet: chroma loading, the datapath registers, FIFO and CRC access,
the sampler, the recoverer, timer 2, the constant table, the debugger and
the tracer, including the reconstruction of a trace's outputs.
