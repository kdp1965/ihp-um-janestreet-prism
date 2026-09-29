# SpaceWire (ECSS-E-ST-50-12C) models for the PRISM SpaceWire chromas.
#
# SpwDecoder watches a Data-Strobe pair, recovers the bits from the edges of
# D xor S and splits them into characters:
#
#   data     P 0 d0 .. d7   (LSB first)
#   control  P 1 c0 c1      FCT 0 0, EOP 0 1, EEP 1 0, ESC 1 1
#   NULL     ESC FCT;  time-code = ESC + a data character
#
# The parity bit P covers the bits after the flag of the character before,
# itself and the flag of its own character: their count of ones is odd.

import cocotb
from cocotb.triggers import RisingEdge

FCT, EOP, EEP, ESC = 'FCT', 'EOP', 'EEP', 'ESC'
CONTROL = {(0, 0): FCT, (0, 1): EOP, (1, 0): EEP, (1, 1): ESC}


def characters(bits):
    ''' Split a bit list into characters: (events, errors, bits left over).
        Events are 'NULL', 'FCT', 'EOP', 'EEP', ('DATA', byte), ('TIME', byte). '''
    events, errors = [], []
    i, body, esc = 0, [], False           # body: the bits after the flag of the character before
    while True:
        if len(bits) - i < 2:
            break
        n = 10 if bits[i + 1] == 0 else 4
        if len(bits) - i < n:
            break
        p, flag, rest = bits[i], bits[i + 1], bits[i + 2:i + n]
        if (sum(body) + p + flag) % 2 != 1:
            errors.append(f"parity at bit {i} ({'data' if flag == 0 else 'control'} character {len(events)})")
        if flag == 0:
            value = sum(b << k for k, b in enumerate(rest))
            events.append(('TIME', value) if esc else ('DATA', value))
            esc = False
        else:
            c = CONTROL[tuple(rest)]
            if esc:
                if c == FCT:
                    events.append('NULL')
                else:
                    errors.append(f"ESC followed by {c} at bit {i}")
                esc = False
            elif c == ESC:
                esc = True
            else:
                events.append(c)
        body = rest
        i += n
    return events, errors, bits[i:]


class SpwDecoder:
    ''' Watches D on uo_out[d] and S on uo_out[s].  `bits` are the bits in
        wire order, `edges` the clock of every bit's edge, `both` counts the
        clocks in which D and S changed together (never legal), `periods()`
        the clocks between consecutive bits. '''

    def __init__(self, dut, d=1, s=2):
        self.dut, self.d, self.s = dut, d, s
        self.bits, self.edges = [], []
        self.both = 0
        self.clock = 0
        self.task = None

    def start(self):
        self.task = cocotb.start_soon(self.run())

    def stop(self):
        if self.task is not None:
            self.task.kill()
            self.task = None

    def lines(self):
        v = int(self.dut.uo_out.value)
        return (v >> self.d) & 1, (v >> self.s) & 1

    async def run(self):
        d_prev, s_prev = self.lines()
        self.first = (d_prev, s_prev)     # the levels before the first bit
        while True:
            await RisingEdge(self.dut.clk)
            self.clock += 1
            d, s = self.lines()
            if d != d_prev and s != s_prev:
                self.both += 1
            if d != d_prev or s != s_prev:
                self.bits.append(d)
                self.edges.append(self.clock)
            d_prev, s_prev = d, s

    def periods(self, first=0):
        e = self.edges[first:]
        return [b - a for a, b in zip(e, e[1:])]

    def decode(self):
        ''' (events, errors) of everything seen so far; incomplete last character ignored '''
        events, errors, _ = characters(self.bits)
        return events, errors


def escaped(stream, esc=0xF0):
    ''' What the receiver chroma puts in its FIFO for a list of 'EOP', 'EEP' and ('DATA', byte) '''
    out = []
    for e in stream:
        if e == EOP:
            out += [esc, 0x00]
        elif e == EEP:
            out += [esc, 0x01]
        elif isinstance(e, tuple) and e[0] == 'DATA':
            out += [esc, esc] if e[1] == esc else [e[1]]
    return out


class SpwEncoder:
    ''' Drives a Data-Strobe pair (D on ui_in[d], S on ui_in[s]) at `bit`
        clocks per bit.  `queue` holds what to send next: 'NULL', 'FCT',
        'EOP', 'EEP', 'ESC', ('DATA', byte), ('TIME', byte), each optionally
        wrapped as ('BAD', character) to send it with the wrong parity;
        NULLs fill the gaps.  `stop()` freezes the lines (a disconnect),
        `restart()` brings both low for a new link. '''

    BITS = {FCT: [1, 0, 0], EOP: [1, 0, 1], EEP: [1, 1, 0], ESC: [1, 1, 1]}

    def __init__(self, dut, bit=6, d=1, s=2):
        self.dut, self.bit, self.d, self.s = dut, bit, d, s
        self.queue = []
        self.sent = 0                     # characters from the queue that are out
        self.running = False
        self.task = None
        self._levels(0, 0)
        self.body = []

    def _levels(self, d, s):
        self.D, self.S = d, s
        self.dut.ui_in[self.d].value = d
        self.dut.ui_in[self.s].value = s

    def start(self):
        self.running = True
        self.task = cocotb.start_soon(self.run())

    def stop(self):
        self.running = False
        if self.task is not None:
            self.task.kill()
            self.task = None

    def restart(self):
        ''' Both lines low, parity from nothing: the state before a link starts '''
        self.stop()
        self._levels(0, 0)
        self.body = []
        self.queue = []
        self.sent = 0

    async def _bit(self, b):
        if b != self.D:
            self._levels(b, self.S)
        else:
            self._levels(self.D, self.S ^ 1)
        for _ in range(self.bit):
            await RisingEdge(self.dut.clk)

    async def _character(self, c, bad=False):
        if isinstance(c, tuple):
            flag, rest = 0, [(c[1] >> k) & 1 for k in range(8)]
        else:
            flag, rest = 1, self.BITS[c][1:]
        p = (sum(self.body) + flag + 1) % 2          # odd over the body before, P and the flag
        for b in [p ^ (1 if bad else 0), flag] + rest:
            await self._bit(b)
        self.body = rest

    async def run(self):
        while True:
            if self.queue:
                c = self.queue.pop(0)
                bad = isinstance(c, tuple) and c[0] == 'BAD'
                if bad:
                    c = c[1]
                if c == 'NULL':
                    await self._character(ESC, bad)
                    await self._character(FCT)
                elif isinstance(c, tuple) and c[0] == 'TIME':
                    await self._character(ESC)
                    await self._character(('DATA', c[1]), bad)
                else:
                    await self._character(c, bad)
                self.sent += 1
            else:
                await self._character(ESC)
                await self._character(FCT)

    async def send(self, characters):
        ''' Queue them and wait until the last one is out '''
        target = self.sent + len(characters)
        self.queue += list(characters)
        while self.sent < target:
            await RisingEdge(self.dut.clk)
