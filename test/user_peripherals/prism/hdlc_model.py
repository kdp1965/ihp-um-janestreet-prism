# HDLC line model for the PRISM HDLC chromas (chroma_hdlc_rx / chroma_hdlc_tx):
# the FCS, zero insertion, frame building, a line driver (clock + data into
# ui_in) and a line decoder (clock + data from uo_out).
#
# Synchronous HDLC / SDLC: flags 0x7E, a 0 inserted after five ones between
# the flags, seven ones = abort, bytes LSB first, FCS = CRC-16 / X.25
# (reflected 0x1021 = 0x8408, preset 0xFFFF, complemented, low byte first).
# The data changes on the clock's falling edge and is sampled on its rising
# edge.

from cocotb.triggers import RisingEdge

FLAG = [0, 1, 1, 1, 1, 1, 1, 0]
POLY = 0x8408


def crc_run(bits, crc=0xFFFF):
    ''' The reflected CRC-16 register (as prism_crc.v runs it) over bits '''
    for b in bits:
        fb = (crc ^ b) & 1
        crc >>= 1
        if fb:
            crc ^= POLY
    return crc


def byte_bits(data):
    return [(b >> k) & 1 for b in data for k in range(8)]


def fcs16(data):
    ''' The FCS a transmitter appends (CRC-16 / X.25, check 0x906E) '''
    return crc_run(byte_bits(data)) ^ 0xFFFF


# The receiver chroma commits a closing flag's first six bits (0 and five
# ones) before the sixth one shows it is a flag, so a good frame leaves its
# CRC register at the X.25 residue 0xF0B8 run on through those bits.
RESIDUE = crc_run([0, 1, 1, 1, 1, 1], 0xF0B8)


def with_fcs(data, bad=False):
    f = fcs16(data) ^ (0x0100 if bad else 0)
    return list(data) + [f & 0xFF, f >> 8]


def stuff(bits):
    ''' Zero insertion: a 0 after every five ones in a row '''
    out, ones = [], 0
    for b in bits:
        out.append(b)
        ones = ones + 1 if b else 0
        if ones == 5:
            out.append(0)
            ones = 0
    return out


def frame_bits(data, bad_fcs=False, fcs=True):
    ''' A frame's line bits between its flags (stuffed) '''
    body = with_fcs(data, bad=bad_fcs) if fcs else list(data)
    return stuff(byte_bits(body))


def decode(raw):
    ''' Line bits -> [(bytes, fcs_ok, aligned)] for every frame between two
        flags (empty frames between idle flags are skipped), and the number
        of aborts seen inside frames. '''
    frames, aborts = [], 0
    bits, ones, in_frame = [], 0, False
    for b in raw:
        if b:
            ones += 1
            if ones == 7:
                if in_frame and len(bits) > 6:
                    aborts += 1
                in_frame, bits = False, []
            elif ones <= 6:
                bits.append(1)
        else:
            if ones == 5:                   # a stuff bit
                ones = 0
                continue
            if ones == 6:                   # a flag: its 0 and six ones are in bits
                body = bits[:-7]
                if in_frame and body:
                    data = [sum(body[i + k] << k for k in range(8)) for i in range(0, len(body) - 7, 8)]
                    ok = len(body) % 8 == 0 and len(data) >= 3 and fcs16(data[:-2]) == data[-2] | (data[-1] << 8)
                    frames.append((data, ok, len(body) % 8 == 0))
                bits, in_frame, ones = [], True, 0
                continue
            ones = 0
            bits.append(0)
    return frames, aborts


class HdlcLine:
    ''' Drives a receive clock and data into ui_in: each bit is half a period
        with the clock low (the data changes as it falls) and half high. '''

    def __init__(self, dut, clk_pin, data_pin, half=16):
        self.dut, self.clk_pin, self.data_pin, self.half = dut, clk_pin, data_pin, half
        self.dut.ui_in[clk_pin].value = 1
        self.dut.ui_in[data_pin].value = 1

    async def send(self, bits):
        for b in bits:
            self.dut.ui_in[self.clk_pin].value = 0
            self.dut.ui_in[self.data_pin].value = b
            for _ in range(self.half):
                await RisingEdge(self.dut.clk)
            self.dut.ui_in[self.clk_pin].value = 1
            for _ in range(self.half):
                await RisingEdge(self.dut.clk)

    async def flags(self, n):
        await self.send(FLAG * n)

    async def mark(self, n):
        await self.send([1] * n)


class HdlcMonitor:
    ''' Samples a transmit clock and data on uo_out: one bit per rising edge
        of the clock, kept in self.raw (start() / stop()). '''

    def __init__(self, dut, clk_pin, data_pin):
        self.dut, self.clk_pin, self.data_pin = dut, clk_pin, data_pin
        self.raw, self.running = [], False
        self.edges = []                     # clock cycle of every rising edge (bit timing)

    async def run(self):
        prev, cycle = None, 0               # the first sample is the reference (the clock may be high already)
        while self.running:
            await RisingEdge(self.dut.clk)
            cycle += 1
            uo = int(self.dut.uo_out.value)
            c = (uo >> self.clk_pin) & 1
            if c and prev == 0:
                self.raw.append((uo >> self.data_pin) & 1)
                self.edges.append(cycle)
            prev = c

    def frames(self):
        return decode(self.raw)
