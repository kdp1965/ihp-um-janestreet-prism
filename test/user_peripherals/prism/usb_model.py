# USB low-speed line model for the PRISM USB device chroma tests.
#
# Bit-level helpers (CRC5 / CRC16, bit stuffing, NRZI) and a cocotb host
# that drives D+ / D- on two ui_in pins, one bit per BIT clocks, and decodes
# the device's replies from two uo_out pins while its output-enable pin is
# high.  Low speed: idle J = D+ low / D- high, K = the opposite, SE0 = both
# low; NRZI: a 0 bit toggles the line, a 1 holds it; a 0 is stuffed after
# six consecutive 1s; sync = 0x80 (KJKJKJKK), EOP = SE0 for 2 bits then J.

try:
    from cocotb.triggers import RisingEdge
except ImportError:          # pure helpers are usable without cocotb
    RisingEdge = None

PID_OUT, PID_IN, PID_SETUP = 0xE1, 0x69, 0x2D
PID_DATA0, PID_DATA1 = 0xC3, 0x4B
PID_ACK, PID_NAK, PID_STALL = 0xD2, 0x5A, 0x1E


def crc5(bits):
    """USB CRC5 (poly x^5+x^2+1, init 11111) over the bit list, returns the
       5 bits to append (inverted remainder, MSB of the polynomial first)."""
    crc = 0x1F
    for b in bits:
        fb = ((crc >> 4) & 1) ^ b
        crc = ((crc << 1) & 0x1F) ^ (0x05 if fb else 0)
    crc ^= 0x1F
    return [(crc >> (4 - i)) & 1 for i in range(5)]


def crc16(data):
    """USB CRC16 (poly x^16+x^15+x^2+1, init all ones, inverted), reflected
       implementation; returns the two bytes to append, low byte first."""
    crc = 0xFFFF
    for byte in data:
        for i in range(8):
            fb = (crc ^ (byte >> i)) & 1
            crc >>= 1
            if fb:
                crc ^= 0xA001
    crc ^= 0xFFFF
    return [crc & 0xFF, crc >> 8]


def crc16_reflected_residual():
    """What prism_crc.v (mode 16, reflected, init ones, poly 0xA001) holds
       after the payload and its CRC16 have been shifted through."""
    crc = 0xFFFF
    payload = [0x12, 0x34, 0x56]
    for byte in payload + crc16(payload):
        for i in range(8):
            fb = (crc ^ (byte >> i)) & 1
            crc >>= 1
            if fb:
                crc ^= 0xA001
    return crc


def bytes_to_bits(data):
    return [(b >> i) & 1 for b in data for i in range(8)]


def token_bits(pid, addr, endp):
    field = [(addr >> i) & 1 for i in range(7)] + [(endp >> i) & 1 for i in range(4)]
    return bytes_to_bits([0x80, pid]) + field + crc5(field)


def data_bits(pid, payload):
    return bytes_to_bits([0x80, pid] + list(payload) + crc16(payload))


def handshake_bits(pid):
    return bytes_to_bits([0x80, pid])


def stuff(bits):
    """Insert a 0 after six consecutive 1s (the sync is never stuffed)."""
    out, ones = [], 0
    for b in bits:
        out.append(b)
        if b:
            ones += 1
            if ones == 6:
                out.append(0)
                ones = 0
        else:
            ones = 0
    return out


def unstuff(bits):
    out, ones = [], 0
    skip = False
    for b in bits:
        if skip:
            skip = False
            ones = 0
            continue
        out.append(b)
        if b:
            ones += 1
            if ones == 6:
                skip = True
        else:
            ones = 0
    return out


def nrzi(bits, start_k=False):
    """Line levels (1 = K) for the bit list, starting from J."""
    level = 1 if start_k else 0
    out = []
    for b in bits:
        if not b:
            level ^= 1
        out.append(level)
    return out


class UsbHost:
    """Drives the device's D+ / D- inputs and reads its D+ / D- / OE outputs."""

    def __init__(self, dut, bit_clocks, dp_in=4, dm_in=5, dp_out=2, dm_out=3, oe_out=4):
        self.dut = dut
        self.bit = bit_clocks
        self.dp_in, self.dm_in = dp_in, dm_in
        self.dp_out, self.dm_out, self.oe_out = dp_out, dm_out, oe_out
        self.host_dp, self.host_dm = 0, 1
        self.task = None
        self.idle()

    def start(self):
        import cocotb
        self.task = cocotb.start_soon(self.mirror())

    def stop(self):
        if self.task is not None:
            self.task.kill()
            self.task = None

    async def mirror(self):
        """The bus: while the device drives (OE), its inputs see its own
           levels, as through the external buffers; otherwise the host's."""
        while True:
            await RisingEdge(self.dut.clk)
            dp, dm, oe = self.device_lines()
            if oe:
                self.dut.ui_in[self.dp_in].value = dp
                self.dut.ui_in[self.dm_in].value = dm
            else:
                self.dut.ui_in[self.dp_in].value = self.host_dp
                self.dut.ui_in[self.dm_in].value = self.host_dm

    def drive(self, dp, dm):
        self.host_dp, self.host_dm = dp, dm
        self.dut.ui_in[self.dp_in].value = dp
        self.dut.ui_in[self.dm_in].value = dm

    def idle(self):
        self.drive(0, 1)                      # J

    async def clocks(self, n):
        for _ in range(n):
            await RisingEdge(self.dut.clk)

    async def send(self, bits):
        """One packet: sync .. data already in `bits`; stuffing, NRZI, EOP here."""
        for level in nrzi(stuff(bits)):
            self.drive(level, 1 - level)
            await self.clocks(self.bit)
        self.drive(0, 0)                      # EOP: SE0 for two bits
        await self.clocks(2 * self.bit)
        self.idle()
        await self.clocks(self.bit)

    def device_lines(self):
        v = int(self.dut.uo_out.value)
        return (v >> self.dp_out) & 1, (v >> self.dm_out) & 1, (v >> self.oe_out) & 1

    async def receive(self, timeout_bits=20):
        """Wait for the device to drive a packet, decode it, return the bytes
           (sync stripped) or None on timeout.  Samples mid-bit from the first
           K, resynchronising on every transition."""
        # wait for OE and the first K
        for _ in range(timeout_bits * self.bit):
            dp, dm, oe = self.device_lines()
            if oe and dp == 1 and dm == 0:
                break
            await RisingEdge(self.dut.clk)
        else:
            return None
        levels = []
        clocks_since_edge = 0
        last = 1
        sample_at = self.bit // 2
        reason = ""
        while True:
            await RisingEdge(self.dut.clk)
            dp, dm, oe = self.device_lines()
            if dp == 0 and dm == 0:                  # SE0: EOP
                reason = "SE0"
                break
            if not oe:
                reason = "OE dropped"
                break
            clocks_since_edge += 1
            if dp != last:
                last = dp
                clocks_since_edge = 0
            if clocks_since_edge % self.bit == sample_at:   # every bit after the last edge
                levels.append(dp)
        # wait for the device to return to J and release
        for _ in range(4 * self.bit):
            await RisingEdge(self.dut.clk)
            if not self.device_lines()[2]:
                break
        self.dut._log.info(f"    USB RX: {len(levels)} levels, end by {reason}: {''.join(str(l) for l in levels)}")
        # NRZI decode: bit = 1 if same as previous level (previous of first = J = 0)
        bits, prev = [], 0
        for lv in levels:
            bits.append(1 if lv == prev else 0)
            prev = lv
        bits = unstuff(bits)
        nbytes = len(bits) // 8
        data = [sum(bits[8 * k + i] << i for i in range(8)) for k in range(nbytes)]
        if data and data[0] == 0x80:
            data = data[1:]
        return data
