# CAN 2.0A bus model for the PRISM CAN chromas (cocotb).
#
# The bus is a wired AND: recessive (1) unless someone drives dominant (0).
# CanBus drives the frames of a remote node on ui_in[rxd] one clock at a
# time and ANDs the PRISM's "drive dominant" output (uo_out[txd], 1 =
# dominant) into the line, so the receiver sees its own ACK and the model
# sees whether the ACK slot was acknowledged.

from cocotb.triggers import RisingEdge


def crc15(bits):
    ''' CAN CRC-15 (polynomial 0x4599, init 0) over unstuffed bits '''
    crc = 0
    for b in bits:
        fb = ((crc >> 14) & 1) ^ b
        crc = (crc << 1) & 0x7FFF
        if fb:
            crc ^= 0x4599
    return crc


def stuff(bits):
    ''' Insert a complementary bit after five equal ones (SOF .. CRC) '''
    out, run, prev = [], 0, None
    for b in bits:
        out.append(b)
        if b == prev:
            run += 1
        else:
            run, prev = 1, b
        if run == 5:
            out.append(1 - b)
            run, prev = 1, 1 - b
    return out


def frame_bits(ident, data, rtr=False, bad_crc=False, dlc=None):
    ''' Standard data frame as (stuffed bits SOF..CRC, unstuffed header+data bits, crc);
        dlc overrides the DLC field (9-15 mean 8 bytes on the wire) '''
    if dlc is None:
        dlc = len(data) if not rtr else data
    body = [0] + [(ident >> k) & 1 for k in range(10, -1, -1)] + [int(rtr), 0, 0]
    body += [(dlc >> k) & 1 for k in range(3, -1, -1)]
    if not rtr:
        for byte in data:
            body += [(byte >> k) & 1 for k in range(7, -1, -1)]
    crc = crc15(body)
    if bad_crc:
        crc ^= 0x0001
    stuffed = stuff(body + [(crc >> k) & 1 for k in range(14, -1, -1)])
    return stuffed, body, crc


def expected_bytes(body):
    ''' What the RX chroma pushes: header bits 0-7, 8-15, 11-18, then the data bytes '''
    def val(bits):
        v = 0
        for b in bits:
            v = (v << 1) | b
        return v
    out = [val(body[0:8]), val(body[8:16]), val(body[11:19])]
    for k in range(19, len(body), 8):
        out.append(val(body[k:k + 8]))
    return out


def state_with_default_output(chroma, out_bit):
    """ The compiler's index of the state whose default outputs drive out_bit """
    from user_peripherals.prism.regs import stew_of, stew_field, STEW_OUT_POS
    for si in range(32):
        if stew_field(stew_of(chroma, si), STEW_OUT_POS["default"]) & (1 << out_bit):
            return si
    raise ValueError("no state drives output %d" % out_bit)


class CanBus:
    def __init__(self, dut, rxd=0, txd=1, bit_clocks=64):
        self.dut = dut
        self.rxd = rxd
        self.txd = txd
        self.bit_clocks = bit_clocks
        self.idle()

    def idle(self):
        self.dut.ui_in[self.rxd].value = 1

    def our_dominant(self):
        return (int(self.dut.uo_out.value) >> self.txd) & 1

    async def drive(self, bits, watch=None):
        ''' Drive bits at the bit rate; returns the PRISM's dominant drive seen
            at 3/4 of each bit whose index is in watch '''
        seen = {}
        for i, b in enumerate(bits):
            for k in range(self.bit_clocks):
                self.dut.ui_in[self.rxd].value = b & (1 - self.our_dominant())
                if watch and i in watch and k == (3 * self.bit_clocks) // 4:
                    seen[i] = self.our_dominant()
                await RisingEdge(self.dut.clk)
        self.idle()
        return seen

    async def send(self, ident, data, rtr=False, bad_crc=False, ifs=3, dlc=None):
        ''' Send one frame (the remote node leaves the ACK slot recessive) and
            return whether the PRISM acknowledged it '''
        stuffed, body, crc = frame_bits(ident, data, rtr, bad_crc, dlc)
        tail = [1, 1, 1] + [1] * 7 + [1] * ifs        # CRC delimiter, ACK slot, ACK delimiter, EOF, IFS
        ack_slot = len(stuffed) + 1
        seen = await self.drive(stuffed + tail, watch={ack_slot})
        return bool(seen.get(ack_slot, 0))


def pack_frame(ident, data):
    ''' The transmitter's FIFO image: the 19 header bits then the data bits,
        MSB first, the last byte padded with ones; returns (bytes, bit count) '''
    _, body, _ = frame_bits(ident, data)
    bits = body[:]
    n = len(bits)
    while len(bits) % 8:
        bits.append(1)
    out = []
    for k in range(0, len(bits), 8):
        v = 0
        for b in bits[k:k + 8]:
            v = (v << 1) | b
        out.append(v)
    return out, n


class CanNode:
    ''' The remote node when the PRISM transmits: mirrors the PRISM's TXD
        (uo_out[txd], 1 = recessive) onto ui_in[rxd] as a wired AND with its
        own drive, syncs to the SOF edge, samples 75 % into each bit,
        destuffs, decodes the frame and drives the ACK slot dominant.  jam =
        a raw bit index at which it drives dominant instead (lost arbitration
        for a transmitter sending recessive there). '''

    def __init__(self, dut, rxd=3, txd=2, ack_pin=1, bit_clocks=64):
        self.dut, self.rxd, self.txd, self.ack_pin, self.bit_clocks = dut, rxd, txd, ack_pin, bit_clocks

    def tx_pin(self):
        return (int(self.dut.uo_out.value) >> self.txd) & 1

    def ack_pin_dom(self):
        return (int(self.dut.uo_out.value) >> self.ack_pin) & 1

    async def receive(self, ack=True, jam=None, timeout=40000):
        ''' Returns dict(ident, data, crc_ok, stuffed) or None on timeout '''
        dut, N = self.dut, self.bit_clocks
        line_drive = 1
        # wait for the SOF edge
        for _ in range(timeout):
            dut.ui_in[self.rxd].value = self.tx_pin() & (1 - self.ack_pin_dom())
            if self.tx_pin() == 0:
                break
            await RisingEdge(dut.clk)
        else:
            return None
        raw, unstuffed = [], []
        run, prev = 0, None
        total = None                  # unstuffed bits before the CRC delimiter
        ack_idx, delim_idx = None, None
        n = 0
        result = None
        while True:
            phase, idx = n % N, n // N
            drive = 1
            if jam is not None and idx == jam:
                drive = 0
            if ack and ack_idx is not None and idx == ack_idx:
                drive = 0
            dut.ui_in[self.rxd].value = self.tx_pin() & (1 - self.ack_pin_dom()) & drive
            if phase == (3 * N) // 4:
                b = self.tx_pin() & drive
                raw.append(b)
                if delim_idx is None:               # still in the stuffed part
                    if run == 5:                    # this raw bit is a stuff bit
                        run, prev = 1, b
                    else:
                        unstuffed.append(b)
                        if b == prev:
                            run += 1
                        else:
                            run, prev = 1, b
                        if len(unstuffed) == 19:
                            dlc = int("".join(map(str, unstuffed[15:19])), 2)
                            total = 19 + 8 * min(dlc, 8) + 15
                        if total is not None and len(unstuffed) == total:
                            delim_idx = idx + 1
                            ack_idx = idx + 2
                elif idx >= ack_idx + 8:            # ACK delimiter + 7 EOF bits seen
                    break
                if jam is not None and idx >= jam + 2:
                    break
            n += 1
            await RisingEdge(dut.clk)
            if n > timeout:
                break
        dut.ui_in[self.rxd].value = 1
        if total is None or delim_idx is None:
            return {"lost": True, "raw": raw}
        ident = int("".join(map(str, unstuffed[1:12])), 2)
        dlc = int("".join(map(str, unstuffed[15:19])), 2)
        data = [int("".join(map(str, unstuffed[19 + 8 * k: 27 + 8 * k])), 2) for k in range(min(dlc, 8))]
        crc_ok = crc15(unstuffed[:19 + 8 * min(dlc, 8)]) == int("".join(map(str, unstuffed[-15:])), 2)
        return {"ident": ident, "dlc": dlc, "data": data, "crc_ok": crc_ok, "stuffed": len(raw), "raw": raw}

    async def mirror(self, clocks):
        ''' A passive bus for the loopback: ui_in[rxd] = TXD & ~ACK for `clocks` cycles '''
        for _ in range(clocks):
            self.dut.ui_in[self.rxd].value = self.tx_pin() & (1 - self.ack_pin_dom())
            await RisingEdge(self.dut.clk)
        self.dut.ui_in[self.rxd].value = 1
