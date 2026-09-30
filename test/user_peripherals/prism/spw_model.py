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

    def restart(self):
        ''' Forget what was seen: a new link (call it with both lines low) '''
        self.bits, self.edges = [], []
        self.both = 0
        self.first = self.lines()

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


class SpwPeer:
    ''' The other end of a SpaceWire link, the one that starts it: the link
        state machine of ECSS-E-ST-50-12C with its transmitter on ui_in[d],
        ui_in[s] and its receiver on uo_out[rd], uo_out[rs].

          ErrorReset   6.4 us, transmitter and receiver off
          ErrorWait   12.8 us, receiver on
          Ready        -> Started at once (LinkStart)
          Started      NULLs; got a NULL -> Connecting; 12.8 us -> ErrorReset
          Connecting   FCTs and NULLs; got an FCT -> Run; 12.8 us -> ErrorReset
          Run          data under credit; any error -> ErrorReset

        Errors: disconnect (no edge for `disconnect` clocks after the first
        bit), parity, ESC followed by anything but an FCT or data, an FCT or
        a data / EOP / EEP character before the state that may take it, more
        data than the credit given.  `history` lists (clock, state, why);
        `packets` the packets received, each a list of bytes ending in 'EOP'
        or 'EEP'; `send(...)` queues data / EOP / EEP to go out under the
        credit the FCTs received have given; `grant` FCTs are sent when the
        link connects, `give(n)` sends more. '''

    STATES = ('ErrorReset', 'ErrorWait', 'Ready', 'Started', 'Connecting', 'Run')

    def __init__(self, dut, bit=6, clock_mhz=60.0, d=1, s=2, rd=1, rs=2, grant=1, disconnect=51):
        self.dut, self.bit = dut, bit
        self.d, self.s, self.rd, self.rs = d, s, rd, rs
        self.t_reset = int(round(6.4 * clock_mhz))
        self.t_wait = int(round(12.8 * clock_mhz))
        self.disconnect = disconnect
        self.grant = grant
        self.enabled = True
        self.history = []
        self.packets = []
        self.errors = []
        self.clock = 0
        self.queue = []                   # N-chars waiting for credit
        self.bad_parity = 0               # characters to send with the wrong parity
        self.task = None
        self._lines(0, 0)
        self._enter('ErrorReset', 'start')

    # ---- lines and states
    def _lines(self, d, s):
        self.D, self.S = d, s
        self.dut.ui_in[self.d].value = d
        self.dut.ui_in[self.s].value = s

    def _enter(self, state, why=''):
        self.state, self.since = state, self.clock
        self.history.append((self.clock, state, why))
        if state == 'ErrorReset':
            self.tx_bits, self.tx_body, self.tx_phase = [], [], 0
            self.fct_due = 0
            self.tx_credit = 0            # characters we may still send
            self.rx_credit = 0            # characters we have asked for
            self.rx_on = False
            self.packet = []
        if state == 'ErrorWait':
            self.rx_on = True
            self.rx_bits, self.rx_body, self.rx_esc = [], [], False
            self.got_null = False
            self.first_bit = False
            self.quiet = 0
        if state == 'Connecting':
            self.fct_due = self.grant

    def start(self):
        self.task = cocotb.start_soon(self.run())

    def stop(self):
        if self.task is not None:
            self.task.kill()
            self.task = None

    def runs(self, since=0):
        ''' Clocks at which the link reached Run '''
        return [c for c, st, _ in self.history if st == 'Run' and c >= since]

    def send(self, characters):
        self.queue += list(characters)

    def give(self, fcts=1):
        self.fct_due += fcts

    # ---- transmitter: one bit per `bit` clocks
    def _next_character(self):
        if self.state == 'Started' or (self.state in ('Connecting', 'Run') and not self.fct_due
                                       and not (self.state == 'Run' and self.queue and self.tx_credit)):
            return [ESC, FCT]
        if self.fct_due:
            self.fct_due -= 1
            self.rx_credit += 8
            return [FCT]
        self.tx_credit -= 1
        return [self.queue.pop(0)]

    def _bits_of(self, c):
        if isinstance(c, tuple):
            flag, rest = 0, [(c[1] >> k) & 1 for k in range(8)]
        else:
            flag, rest = 1, SpwEncoder.BITS[c][1:]
        p = (sum(self.tx_body) + flag + 1) % 2
        if self.bad_parity:
            self.bad_parity -= 1
            p ^= 1
        self.tx_body = rest
        return [p, flag] + rest

    def _transmit(self):
        if self.state not in ('Started', 'Connecting', 'Run'):
            if self.S:                                # reset: S first, then D, never both
                self._lines(self.D, 0)
            elif self.D:
                self._lines(0, 0)
            return
        self.tx_phase = (self.tx_phase + 1) % self.bit
        if self.tx_phase != 1 % self.bit:
            return
        if not self.tx_bits:
            for c in self._next_character():
                self.tx_bits += self._bits_of(c)
        b = self.tx_bits.pop(0)
        if b != self.D:
            self._lines(b, self.S)
        else:
            self._lines(self.D, self.S ^ 1)

    # ---- receiver
    def _error(self, what):
        self.errors.append((self.clock, self.state, what))
        self._enter('ErrorReset', what)

    def _character(self):
        ''' One character off rx_bits if it is complete: its event, or None '''
        b = self.rx_bits
        if len(b) < 2:
            return None
        n = 10 if b[1] == 0 else 4
        if len(b) < n:
            return None
        p, flag, rest = b[0], b[1], b[2:n]
        del b[:n]
        if (sum(self.rx_body) + p + flag) % 2 != 1:
            return 'parity'
        self.rx_body = rest
        if flag == 0:
            value = sum(x << k for k, x in enumerate(rest))
            if self.rx_esc:
                self.rx_esc = False
                return ('TIME', value)
            return ('DATA', value)
        c = CONTROL[tuple(rest)]
        if self.rx_esc:
            self.rx_esc = False
            return 'NULL' if c == FCT else 'escape'
        if c == ESC:
            self.rx_esc = True
            return 'ESC'
        return c

    def _receive(self, d, s, d_prev, s_prev):
        if not self.rx_on:
            return
        if d != d_prev and s != s_prev:
            return self._error('D and S together')
        if d != d_prev or s != s_prev:
            self.first_bit = True
            self.quiet = 0
            self.rx_bits.append(d)
        elif self.first_bit:
            self.quiet += 1
            if self.quiet >= self.disconnect:
                return self._error('disconnect')
        while True:
            e = self._character()
            if e is None:
                return
            if e in ('parity', 'escape'):
                return self._error(e)
            if e == 'ESC':
                continue
            if e == 'NULL':
                self.got_null = True
                continue
            if e == FCT:
                if self.state not in ('Connecting', 'Run'):
                    return self._error('FCT in ' + self.state)
                self.tx_credit += 8
                if self.state == 'Connecting':
                    self._enter('Run', 'FCT')
                continue
            if isinstance(e, tuple) and e[0] == 'TIME':
                if self.state != 'Run':
                    return self._error('time-code in ' + self.state)
                continue
            if self.state != 'Run':                   # data, EOP, EEP
                return self._error('N-char in ' + self.state)
            if self.rx_credit == 0:
                return self._error('credit')
            self.rx_credit -= 1
            if e in (EOP, EEP):
                self.packets.append(self.packet + [e])
                self.packet = []
            else:
                self.packet.append(e[1])

    # ---- the state machine, one step per clock
    async def run(self):
        uo = int(self.dut.uo_out.value)
        d_prev, s_prev = (uo >> self.rd) & 1, (uo >> self.rs) & 1
        while True:
            await RisingEdge(self.dut.clk)
            self.clock += 1
            uo = int(self.dut.uo_out.value)
            d, s = (uo >> self.rd) & 1, (uo >> self.rs) & 1
            self._receive(d, s, d_prev, s_prev)
            d_prev, s_prev = d, s
            age = self.clock - self.since
            if self.state == 'ErrorReset':
                if age >= self.t_reset and self.enabled:
                    self._enter('ErrorWait')
            elif self.state == 'ErrorWait':
                if age >= self.t_wait:
                    self._enter('Ready')
            elif self.state == 'Ready':
                self._enter('Started')
            elif self.state == 'Started':
                if self.got_null:
                    self._enter('Connecting', 'NULL')
                elif age >= self.t_wait:
                    self._enter('ErrorReset', 'no NULL in 12.8 us')
            elif self.state == 'Connecting':
                if age >= self.t_wait:
                    self._enter('ErrorReset', 'no FCT in 12.8 us')
            self._transmit()
