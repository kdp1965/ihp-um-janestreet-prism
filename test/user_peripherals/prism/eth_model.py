# 10BASE-T line model for the PRISM Ethernet transmitter tests: a
# Manchester decoder on the device's TXD / TX_EN outputs, and the Ethernet
# CRC32.  Bit time = BIT clocks; a 1 is low then high, a 0 high then low;
# TP_IDL (both halves high) ends the frame.

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
