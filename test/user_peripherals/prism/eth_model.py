# 10BASE-T line models for the PRISM Ethernet tests: a Manchester decoder
# on the device's TXD / TX_EN outputs, a Manchester encoder driving a ui_in
# pin, and the Ethernet CRC32.  Bit time = BIT clocks; a 1 is low then
# high, a 0 high then low; TP_IDL (both halves high) ends the frame.

try:
    from cocotb.triggers import RisingEdge
except ImportError:
    RisingEdge = None


def crc32(data):
    """Ethernet FCS (reflected 0xEDB88320, init and xor all ones), the
       four bytes to append, low byte first."""
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0xEDB88320 if crc & 1 else 0)
    crc ^= 0xFFFFFFFF
    return [(crc >> (8 * i)) & 0xFF for i in range(4)]


class EthDecoder:
    """Watches uo_out[txd] while uo_out[tx_en] is high and decodes frames."""

    def __init__(self, dut, bit_clocks, txd=1, tx_en=2):
        self.dut = dut
        self.bit = bit_clocks
        self.txd, self.tx_en = txd, tx_en
        self.frames = []          # list of byte lists (preamble included)
        self.pulses = 0           # link pulses seen (TX_EN high, no data)
        self.task = None

    def lines(self):
        v = int(self.dut.uo_out.value)
        return (v >> self.txd) & 1, (v >> self.tx_en) & 1

    def start(self):
        import cocotb
        self.task = cocotb.start_soon(self.run())

    def stop(self):
        if self.task is not None:
            self.task.kill()
            self.task = None

    async def run(self):
        half = self.bit // 2
        while True:
            # wait for TX_EN
            while True:
                await RisingEdge(self.dut.clk)
                if self.lines()[1]:
                    break
            # sample each half bit at its middle; a bit with equal halves ends
            # the frame (TP_IDL) or is a link pulse when it is the first bit
            bits = []
            clocks = 0
            while True:
                first = []
                second = []
                for k in range(self.bit):
                    await RisingEdge(self.dut.clk)
                    clocks += 1
                    txd, en = self.lines()
                    if not en:
                        break
                    (first if k < half else second).append(txd)
                if len(second) < half:
                    break                       # TX_EN dropped
                f = 1 if sum(first) * 2 > len(first) else 0
                s = 1 if sum(second) * 2 > len(second) else 0
                if f == s:
                    break                       # no mid-bit transition: TP_IDL or pulse
                bits.append(s)
            if bits:
                data = [sum(bits[8 * k + i] << i for i in range(8)) for k in range(len(bits) // 8)]
                self.frames.append(data)
                self.dut._log.info(f"    ETH RX: {len(bits)} bits, {len(data)} bytes")
            else:
                self.pulses += 1
                self.dut._log.info(f"    ETH RX: link pulse ({clocks} clocks)")
            # wait for TX_EN to drop before looking for the next frame
            while self.lines()[1]:
                await RisingEdge(self.dut.clk)


class EthEncoder:
    """Drives ui_in[rxd] with 10BASE-T frames and link pulses.  A frame is
       the preamble, SFD, payload and FCS, Manchester coded at `bit` clocks
       per bit, then TP_IDL (high for two bit times) and idle low.  `stretch`
       > 0 inserts one extra clock every `stretch` half bits, a line that is
       slower than the device clock by 1 / (2 * stretch).  `bit_clocks` may
       be fractional (5 = 2.5 clocks per half bit, a 10 Mb/s line at 50 MHz):
       the half bits then alternate lengths to keep the average."""

    def __init__(self, dut, bit_clocks, rxd=3, stretch=0):
        self.dut = dut
        self.bit = bit_clocks
        self.rxd = rxd
        self.stretch = stretch
        self._n = 0
        self._acc = 0.0

    def _drive(self, level):
        v = int(self.dut.ui_in.value)
        v = (v | (1 << self.rxd)) if level else (v & ~(1 << self.rxd))
        self.dut.ui_in.value = v

    async def _half(self, level):
        self._drive(level)
        self._acc += self.bit / 2
        n = int(self._acc)
        self._acc -= n
        self._n += 1
        if self.stretch and self._n % self.stretch == 0:
            n += 1
        for _ in range(n):
            await RisingEdge(self.dut.clk)

    async def idle(self, clocks):
        self._drive(0)
        for _ in range(clocks):
            await RisingEdge(self.dut.clk)

    async def frame(self, payload, preamble=7, fcs=None):
        data = [0x55] * preamble + [0xD5] + payload + (crc32(payload) if fcs is None else fcs)
        for byte in data:
            for i in range(8):
                bit = (byte >> i) & 1
                await self._half(1 - bit)
                await self._half(bit)
        for _ in range(4):                    # TP_IDL: two bit times high
            await self._half(1)
        await self.idle(int(self.bit * 4))

    async def link_pulse(self):
        await self._half(1)
        await self._half(1)
        await self.idle(int(self.bit * 4))
