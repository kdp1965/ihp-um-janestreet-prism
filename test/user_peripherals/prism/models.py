# External device models for the chroma tests.  Each one is started by the
# test that needs it (PrismTest.start) and stopped when the test ends.

import cocotb
from cocotb.triggers import RisingEdge


def _uo_out(dut):
    ''' uo_out as an integer, X / Z read as 0 '''
    return int(dut.uo_out.value.binstr.replace('x', '0').replace('z', '0'), 2)


class Model:
    def __init__(self, dut):
        self.dut = dut
        self.task = None

    def start(self):
        self.task = cocotb.start_soon(self.run())

    def stop(self):
        if self.task is not None:
            self.task.kill()
            self.task = None

    async def clocks(self, n):
        for _ in range(n):
            await RisingEdge(self.dut.clk)

    async def run(self):
        raise NotImplementedError


class Shift74165(Model):
    ''' Parallel-in serial-out shift register on ui_in[0]: uo_out[1] low
        loads `value`, a rising edge on uo_out[7] shifts (gpio24 chroma) '''

    def __init__(self, dut, value):
        super().__init__(dut)
        self.value = value
        self.shift = value

    async def run(self):
        prev = _uo_out(self.dut)
        while True:
            await RisingEdge(self.dut.clk)
            curr = _uo_out(self.dut)
            if (curr & 2) == 0:
                self.shift = self.value                             # load
            elif ((prev ^ curr) & (1 << 7)) and (curr & (1 << 7)):
                self.shift = (self.shift << 1) & 0xFFFFFF           # shift left
            else:
                prev = curr
                continue
            prev = curr
            self.dut.ui_in[0].value = (self.shift >> 23) & 1        # MSB out


class Shift74595(Model):
    ''' Serial-in parallel-out shift register: a rising edge on uo_out[7]
        shifts uo_out[5] in, uo_out[2] high stores the word (gpio24 chroma) '''

    def __init__(self, dut):
        super().__init__(dut)
        self.shift = 0
        self.value = 0

    async def run(self):
        prev = _uo_out(self.dut)
        while True:
            await RisingEdge(self.dut.clk)
            curr = _uo_out(self.dut)
            if curr & 4:
                self.value = self.shift                             # store
            elif ((prev ^ curr) & (1 << 7)) and (curr & (1 << 7)):
                bit = int(self.dut.uo_out[5].value)
                self.shift = ((self.shift << 1) | bit) & 0xFFFFFF
            prev = curr


class SpiMaster(Model):
    ''' SPI master on ui_in[0] (CS), ui_in[1] (SCLK), ui_in[2] (MOSI), reading
        MISO on uo_out[2].  transfer() sends the bytes; after each byte the
        master pauses (byte_done) until the test calls release(), so the host
        can read comm, clear the interrupt and stage the next TX byte. '''

    def __init__(self, dut, baud=16):
        super().__init__(dut)
        self.baud = baud
        self.tx = []
        self.rx = []
        self.byte_done = False
        self.busy = False
        dut.ui_in[0].value = 1                   # CS idle high
        dut.ui_in[1].value = 0
        dut.ui_in[2].value = 0

    def transfer(self, data):
        self.tx = list(data)
        self.rx = []
        self.busy = True

    async def wait_byte(self):
        while not self.byte_done:
            await RisingEdge(self.dut.clk)

    def release(self):
        self.byte_done = False

    async def wait_done(self):
        while self.busy:
            await RisingEdge(self.dut.clk)

    async def run(self):
        while True:
            await RisingEdge(self.dut.clk)
            if not self.busy:
                continue
            self.dut.ui_in[0].value = 0                              # drop CS
            for byte in self.tx:
                rx = 0
                for _ in range(8):
                    await self.clocks(self.baud)
                    self.dut.ui_in[2].value = (byte >> 7) & 1       # MOSI, then SCLK high
                    byte = (byte << 1) & 0xFF
                    self.dut.ui_in[1].value = 1
                    await self.clocks(self.baud)
                    self.dut.ui_in[1].value = 0                     # SCLK low, read MISO
                    rx = (rx << 1) | int(self.dut.uo_out[2].value)
                self.dut._log.info(f"    RX: {rx:02X}")
                self.rx.append(rx)
                self.byte_done = True
                await self.wait_byte_released()
            await self.clocks(self.baud)
            self.dut.ui_in[0].value = 1                              # raise CS
            self.busy = False

    async def wait_byte_released(self):
        while self.byte_done:
            await RisingEdge(self.dut.clk)


class UartRx(Model):
    ''' 8N1 receiver on uo_out[1]: samples mid-bit from the start edge '''

    def __init__(self, dut, period=64):
        super().__init__(dut)
        self.period = period
        self.bytes = []

    async def run(self):
        period = self.period
        while True:
            await RisingEdge(self.dut.clk)
            if _uo_out(self.dut) & 0x2:
                continue
            byte = 0                                                 # start bit seen
            for i in range(9):
                await self.clocks(period if i else period + period // 2)
                bit = (_uo_out(self.dut) >> 1) & 1
                if i < 8:
                    byte |= bit << i
                else:
                    assert bit == 1, "framing error"
            self.bytes.append(byte)
            self.dut._log.info(f"    UART RX: {byte:02X}")


class Ws2812Slave(Model):
    ''' WS2812 receiver on uo_out[1]: measures the high time of each pulse
        (>= 35 clocks = 1) and shifts the bits into grb; a low of 1280
        clocks or more resets the frame '''

    def __init__(self, dut):
        super().__init__(dut)
        self.grb = 0

    async def run(self):
        prev = _uo_out(self.dut) & 2
        count = 0
        self.grb = 0
        while True:
            await RisingEdge(self.dut.clk)
            count += 1
            val = _uo_out(self.dut) & 2
            if val == prev:
                continue
            if count >= 1280 and prev == 0:                          # bus reset
                count = 0
                self.grb = 0
                prev = val
                continue
            elif prev == 0:                                          # rising edge
                prev = val
                count = 0
                continue
            self.grb <<= 1                                           # falling edge: a bit
            if count >= 35:
                self.grb |= 1
            prev = val


class I2cSlave(Model):
    ''' I2C target behind the i2c_master chroma's two external open-drain
        buffers: uo_out[1] = 1 pulls SCL low, uo_out[2] = 1 pulls SDA low.
        Every clock the model resolves the two lines (master pull-lows, its
        own SDA pull-low, else the pull-ups) and drives them back into
        ui_in[1] (SCL) and ui_in[0] (SDA), then decodes START / STOP /
        bytes, ACKs its address (and every byte written to it), and serves
        `read_data` on reads until the master NAKs.  Events: ('start',),
        ('stop',), ('addr', byte, acked), ('write', byte, acked),
        ('read', byte, master_acked). '''

    def __init__(self, dut, address, scl_in=1, sda_in=0):
        super().__init__(dut)
        self.addr = address
        self.scl_in, self.sda_in = scl_in, sda_in   # ui_in pins carrying the line levels
        self.read_data = []
        self.rx = []
        self.events = []
        self.scl_rises = []                      # clock index of each SCL rising edge
        self.drive_low = False                   # the slave pulling SDA low
        dut.ui_in[sda_in].value = 1
        dut.ui_in[scl_in].value = 1

    async def run(self):
        scl_prev, sda_prev = 1, 1
        phase = 'idle'                           # idle | rx | ack_out | tx | ack_in
        shreg, nbits, clock_i = 0, 0, 0
        addressed = reading = False
        tx_byte, tx_bits = 0, 0
        while True:
            await RisingEdge(self.dut.clk)
            clock_i += 1
            uo = int(self.dut.uo_out.value)
            scl = 0 if (uo >> 1) & 1 else 1
            sda = 0 if ((uo >> 2) & 1 or self.drive_low) else 1
            self.dut.ui_in[self.scl_in].value = scl
            self.dut.ui_in[self.sda_in].value = sda
            if scl and scl_prev:                              # SDA moves while SCL high
                if sda_prev and not sda:                      # START (or repeated START)
                    self.events.append(('start',))
                    phase, shreg, nbits = 'rx', 0, 0
                    addressed = reading = False
                    self.drive_low = False
                    self.addr_byte = True
                elif not sda_prev and sda:                    # STOP
                    self.events.append(('stop',))
                    phase = 'idle'
                    self.drive_low = False
            elif scl and not scl_prev:                        # SCL rising: sample
                self.scl_rises.append(clock_i)
                if phase == 'rx':
                    shreg = ((shreg << 1) | sda) & 0xFF
                    nbits += 1
                elif phase == 'ack_in':                       # the master's ACK of our byte
                    acked = (sda == 0)
                    self.events.append(('read', tx_byte, acked))
                    if not acked:
                        phase = 'idle_wait'
            elif not scl and scl_prev:                        # SCL falling: drive
                if phase == 'rx' and nbits == 8:
                    if self.addr_byte:
                        addressed = ((shreg >> 1) == self.addr)
                        reading = bool(shreg & 1)
                        self.events.append(('addr', shreg, addressed))
                    else:
                        self.rx.append(shreg)
                        self.events.append(('write', shreg, addressed))
                    self.drive_low = addressed                # ACK
                    phase = 'ack_out'
                elif phase == 'ack_out':                      # ACK bit over
                    self.drive_low = False
                    self.addr_byte = False
                    if addressed and reading:
                        tx_byte = self.read_data.pop(0) if self.read_data else 0xFF
                        tx_bits = 8
                        phase = 'tx'
                    else:
                        phase, shreg, nbits = 'rx', 0, 0
                elif phase == 'ack_in':                       # master ACKed (seen on the rising edge): next byte
                    tx_byte = self.read_data.pop(0) if self.read_data else 0xFF
                    tx_bits = 8
                    phase = 'tx'
                if phase == 'tx':
                    if tx_bits > 0:
                        self.drive_low = not ((tx_byte >> (tx_bits - 1)) & 1)
                        tx_bits -= 1
                    else:                                     # 8 bits out: release for the master's ACK
                        self.drive_low = False
                        phase = 'ack_in'
                elif phase == 'idle_wait':                    # NAKed: stay quiet until STOP / START
                    self.drive_low = False
                    phase = 'rx_done'
            scl_prev, sda_prev = scl, sda


class I2cMaster(Model):
    ''' I2C controller for the i2c_slave chroma: drives SCL on ui_in[1] and
        SDA on ui_in[0] as open-drain lines, resolving the slave's SDA
        pull-low on uo_out[2] every clock.  send_start() / write_byte() /
        read_byte() / send_stop() are awaited by the test; `half` is the SCL
        half period in clocks and `hold` the SDA hold after SCL falls. '''

    def __init__(self, dut, half=16, hold=3, scl_in=1, sda_in=0):
        super().__init__(dut)
        self.half, self.hold = half, hold
        self.scl_in, self.sda_in = scl_in, sda_in   # ui_in pins carrying the line levels
        self.scl_low = False                     # the master pulling SCL low
        self.sda_low = False                     # the master pulling SDA low
        self.sda = 1                             # the resolved SDA level
        dut.ui_in[sda_in].value = 1
        dut.ui_in[scl_in].value = 1

    async def run(self):
        while True:
            await RisingEdge(self.dut.clk)
            uo = int(self.dut.uo_out.value)
            self.sda = 0 if (self.sda_low or (uo >> 2) & 1) else 1
            self.dut.ui_in[self.sda_in].value = self.sda
            self.dut.ui_in[self.scl_in].value = 0 if self.scl_low else 1

    async def send_start(self):
        ''' START, or a repeated START when SCL is currently low '''
        if self.scl_low:
            self.sda_low = False
            await self.clocks(self.half)
            self.scl_low = False
            await self.clocks(self.half)
        self.sda_low = True                      # SDA falls while SCL is high
        await self.clocks(self.half)
        self.scl_low = True
        await self.clocks(self.half)

    async def write_byte(self, byte):
        ''' 8 bits MSB first, then the slave's ACK (True) / NAK (False) '''
        for i in range(8):
            self.sda_low = not ((byte >> (7 - i)) & 1)
            await self.clocks(self.half)
            self.scl_low = False
            await self.clocks(self.half)
            self.scl_low = True
            await self.clocks(self.hold)
        self.sda_low = False                     # release for the ACK
        await self.clocks(self.half)
        self.scl_low = False
        await self.clocks(self.half)
        ack = (self.sda == 0)
        self.scl_low = True
        await self.clocks(self.hold)
        return ack

    async def read_byte(self, ack):
        ''' 8 bits from the slave, sampled at the end of SCL high; then ACK (True) / NAK '''
        self.sda_low = False
        value = 0
        for _ in range(8):
            await self.clocks(self.half)
            self.scl_low = False
            await self.clocks(self.half)
            value = (value << 1) | self.sda
            self.scl_low = True
            await self.clocks(self.hold)
        self.sda_low = ack
        await self.clocks(self.half)
        self.scl_low = False
        await self.clocks(self.half)
        self.scl_low = True
        await self.clocks(self.hold)
        self.sda_low = False
        return value

    async def send_stop(self):
        self.sda_low = True                      # SDA low while SCL low ...
        await self.clocks(self.half)
        self.scl_low = False                     # ... SCL up ...
        await self.clocks(self.half)
        self.sda_low = False                     # ... SDA up: STOP
        await self.clocks(self.half)


class QspiSlave(Model):
    ''' SPI target (mode 0) for the spi_master chroma behind external
        tri-state lane buffers: SCLK on uo_out[1], CS_N on uo_out[2], OE on
        uo_out[3] (1 = the master drives IO0..IO3 from uo_out[7:4]); the
        model resolves the four IO levels every clock and drives them back
        into ui_in[4:1].  In single mode the slave drives IO1 (MISO) with
        `tx` bits, MSB first, advancing on SCLK falling edges, and samples
        IO0 (MOSI) on rising edges; in quad mode it samples IO0..IO3 on
        rising edges while OE is high and drives all four lanes with `tx`
        nibbles while OE is low.  Received bytes go to `rx`; `events`
        records the CS edges; `sclks` counts rising edges per frame. '''

    def __init__(self, dut, quad=False):
        super().__init__(dut)
        self.quad = quad
        self.tx = []
        self.rx = []
        self.events = []
        self.sclks = 0
        self.oe_low_edges = 0
        for k in range(1, 5):
            dut.ui_in[k].value = 1

    def _load(self):
        self.cur = self.tx.pop(0) if self.tx else 0xFF
        self.units = 2 if self.quad else 8

    def prime(self):
        ''' Present the first unit of the (new) `tx` data: done at CS low, and by the
            test after reloading `tx` mid-frame (a real slave has its own byte timing) '''
        self.units = 0
        self.out = self._unit() if self.quad else (self._unit() << 1) | 0xD

    def _unit(self):
        ''' The next output unit (bit or nibble) of the current byte, MSB first '''
        if self.units == 0:
            self._load()
        self.units -= 1
        return (self.cur >> (4 * self.units)) & 0xF if self.quad else (self.cur >> self.units) & 1

    async def run(self):
        cs_prev, sclk_prev, oe_prev = 1, 0, 0
        shreg, nbits = 0, 0
        self.out = 0xF
        while True:
            await RisingEdge(self.dut.clk)
            uo = int(self.dut.uo_out.value)
            sclk, cs_n, oe, lanes = (uo >> 1) & 1, (uo >> 2) & 1, (uo >> 3) & 1, (uo >> 4) & 0xF
            if cs_prev and not cs_n:                             # CS falls: new frame
                self.events.append('cs_low')
                shreg, nbits, self.sclks = 0, 0, 0
                self.prime()                                     # first unit ready
            elif not cs_prev and cs_n:
                self.events.append('cs_high')
            if not cs_n:
                if sclk and not sclk_prev:                       # rising: sample the master
                    self.sclks += 1
                    if self.quad:
                        if oe:
                            shreg = ((shreg << 4) | lanes) & 0xFF; nbits += 4
                    else:
                        shreg = ((shreg << 1) | (lanes & 1)) & 0xFF; nbits += 1
                    if nbits >= 8:
                        self.rx.append(shreg); shreg, nbits = 0, 0
                elif not sclk and sclk_prev:                     # falling: present the next unit
                    if self.quad:
                        if not oe_prev:                          # a read-phase edge (not the one OE drops on)
                            self.out = self._unit()
                    else:
                        self.out = (self._unit() << 1) | 0xD
            # the IO levels the master reads back
            if self.quad:
                io = lanes if oe else self.out
            else:
                io = ((lanes & 1) if oe else 1) | (self.out & 0x2) | 0xC   # IO0 from the master, IO1 = MISO, IO2/3 pulled up
            for k in range(4):
                self.dut.ui_in[k + 1].value = (io >> k) & 1
            cs_prev, sclk_prev, oe_prev = cs_n, sclk, oe


class OneWireSlave(Model):
    ''' 1-Wire device (DS18B20-like) for the onewire chroma: the master
        pulls DQ low through uo_out[1] (1 = low), the model resolves the
        line with its own pull-low and drives ui_in[0].  Times are in
        `unit` clocks, the master's count1 unit.  A master low of at least
        `reset_min` units is a reset: `present` devices answer with a
        presence pulse (low from `pres_delay` for `pres_len` units after
        the release).  Every other master falling edge starts a slot: if
        the device has bits to send it drives 0-bits low for `rd_hold`
        units; otherwise it samples the line `sample` units after the edge
        (LSB first, bytes into `rx`), and a received command found in
        `responses` queues that reply. '''

    def __init__(self, dut, unit=8, present=True):
        super().__init__(dut)
        self.unit = unit
        self.present = present
        self.rx = []
        self.resets = 0
        self.responses = {}                      # command byte -> list of reply bytes
        self.tx_bits = []                        # bits queued to send, LSB first
        self.reset_min, self.pres_delay, self.pres_len = 40, 4, 16
        self.sample, self.rd_hold = 5, 4
        self.drive_low = False
        dut.ui_in[0].value = 1

    async def run(self):
        u = self.unit
        low_prev, low_run, t = 0, 0, 0
        shreg, nbits = 0, 0
        pres_at = sample_at = hold_until = None
        while True:
            await RisingEdge(self.dut.clk)
            t += 1
            m_low = (int(self.dut.uo_out.value) >> 1) & 1
            line = 0 if (m_low or self.drive_low) else 1
            self.dut.ui_in[0].value = line
            if m_low:
                low_run += 1
                if low_run == 1 and low_prev == 0:                       # master falling edge
                    if self.tx_bits:                                     # a read slot: drive 0 bits
                        bit = self.tx_bits.pop(0)
                        if bit == 0:
                            self.drive_low, hold_until = True, t + self.rd_hold * u
                        sample_at = None
                    else:
                        sample_at = t + self.sample * u                  # a write slot
            else:
                if low_prev and low_run >= self.reset_min * u:           # reset released
                    self.resets += 1
                    shreg, nbits, sample_at = 0, 0, None
                    self.tx_bits = []
                    if self.present:
                        pres_at = t + self.pres_delay * u
                low_run = 0
            low_prev = m_low
            if pres_at is not None and t >= pres_at:
                self.drive_low, hold_until, pres_at = True, t + self.pres_len * u, None
            if hold_until is not None and t >= hold_until:
                self.drive_low, hold_until = False, None
            if sample_at is not None and t >= sample_at:
                sample_at = None
                shreg = (shreg >> 1) | (line << 7); nbits += 1
                if nbits == 8:
                    self.rx.append(shreg)
                    if shreg in self.responses:
                        for b in self.responses[shreg]:
                            self.tx_bits += [(b >> i) & 1 for i in range(8)]
                    shreg, nbits = 0, 0


class UartTx(Model):
    ''' 8N1 transmitter on ui_in[pin] (idle high) at a bit period that may be
        fractional (a baud-rate error): send() drives start, 8 data bits LSB
        first and a stop bit per byte, bad_stop drives the stop bit low '''

    def __init__(self, dut, pin=0, period=64.0):
        super().__init__(dut)
        self.pin = pin
        self.period = period
        self.dut.ui_in[pin].value = 1

    async def run(self):
        pass

    async def send(self, data, gap=0, bad_stop=False):
        acc = 0.0
        for byte in data:
            bits = [0] + [(byte >> k) & 1 for k in range(8)] + [0 if bad_stop else 1]
            for b in bits:
                self.dut.ui_in[self.pin].value = b
                acc += self.period
                n = int(acc)
                acc -= n
                await self.clocks(n)
            self.dut.ui_in[self.pin].value = 1
            await self.clocks(gap)


class JtagTap(Model):
    ''' JTAG target (IEEE 1149.1 TAP) for the jtag_master chroma: TCK on
        uo_out[1], TMS on uo_out[2], TDI on uo_out[3], TDO on ui_in[2].
        TMS and TDI are taken on TCK rising edges, TDO changes on falling
        edges and shows the bit leaving the register in the shift states
        (1 otherwise, as a pulled-up released pin).  A 4-bit IR (captures
        0001) selects IDCODE (2, 32 bits, also after Test-Logic-Reset), USER
        (3, `user_len` bits: captures its own value, update stores), LONG (4,
        `long_len` bits, the same) and BYPASS (anything else, one bit).
        `trail` lists the TAP states walked, `updates` the (ir, value) of
        every Update-DR, `tcks` counts rising edges and `unstable` the rising
        edges where TMS or TDI differed from the clock before (no setup). '''

    TLR, RTI, SEL_DR, CAP_DR, SH_DR, EX1_DR, PAU_DR, EX2_DR, UPD_DR, \
        SEL_IR, CAP_IR, SH_IR, EX1_IR, PAU_IR, EX2_IR, UPD_IR = range(16)
    NEXT = {TLR: (RTI, TLR), RTI: (RTI, SEL_DR),
            SEL_DR: (CAP_DR, SEL_IR), CAP_DR: (SH_DR, EX1_DR), SH_DR: (SH_DR, EX1_DR),
            EX1_DR: (PAU_DR, UPD_DR), PAU_DR: (PAU_DR, EX2_DR), EX2_DR: (SH_DR, UPD_DR),
            UPD_DR: (RTI, SEL_DR),
            SEL_IR: (CAP_IR, TLR), CAP_IR: (SH_IR, EX1_IR), SH_IR: (SH_IR, EX1_IR),
            EX1_IR: (PAU_IR, UPD_IR), PAU_IR: (PAU_IR, EX2_IR), EX2_IR: (SH_IR, UPD_IR),
            UPD_IR: (RTI, SEL_DR)}
    IR_LEN, IDCODE, USER, LONG = 4, 2, 3, 4

    def __init__(self, dut, idcode=0x1B57A0CF, user_len=20, long_len=300, tdo=2):
        super().__init__(dut)
        self.idcode, self.user_len, self.long_len, self.tdo = idcode, user_len, long_len, tdo
        self.user, self.long = 0x5A5A5, (1 << 299) | 0x123456789ABCDEF
        self.state, self.ir = self.TLR, self.IDCODE
        self.sr, self.sr_len = 0, 1
        self.trail, self.updates = [], []
        self.tcks = self.unstable = 0
        dut.ui_in[tdo].value = 1

    def _dr(self):
        ''' (length, capture value) of the register the IR selects '''
        if self.ir == self.IDCODE:
            return 32, self.idcode
        if self.ir == self.USER:
            return self.user_len, self.user
        if self.ir == self.LONG:
            return self.long_len, self.long
        return 1, 0

    def _rise(self, tms, tdi):
        s = self.state
        if s == self.CAP_DR:
            self.sr_len, self.sr = self._dr()
        elif s == self.CAP_IR:
            self.sr_len, self.sr = self.IR_LEN, 0b0001
        elif s in (self.SH_DR, self.SH_IR):
            self.sr = (self.sr >> 1) | (tdi << (self.sr_len - 1))
        self.state = self.NEXT[s][tms]
        if self.state != s:
            self.trail.append(self.state)
        if self.state == self.TLR:
            self.ir = self.IDCODE
        elif self.state == self.UPD_IR:
            self.ir = self.sr
        elif self.state == self.UPD_DR:
            if self.ir == self.USER:
                self.user = self.sr
            elif self.ir == self.LONG:
                self.long = self.sr
            self.updates.append((self.ir, self.sr))

    async def run(self):
        tck_prev, pins_prev = 0, (0, 0)
        while True:
            await RisingEdge(self.dut.clk)
            uo = int(self.dut.uo_out.value)
            tck, tms, tdi = (uo >> 1) & 1, (uo >> 2) & 1, (uo >> 3) & 1
            if tck and not tck_prev:
                self.tcks += 1
                if (tms, tdi) != pins_prev and self.state in (self.SH_DR, self.SH_IR):
                    self.unstable += 1
                elif tms != pins_prev[0]:
                    self.unstable += 1
                self._rise(tms, tdi)
            elif tck_prev and not tck:
                shifting = self.state in (self.SH_DR, self.SH_IR)
                self.dut.ui_in[self.tdo].value = (self.sr & 1) if shifting else 1
            tck_prev, pins_prev = tck, (tms, tdi)


class SwdTarget(Model):
    ''' ARM Serial Wire Debug target (the DP of ADIv5) for the swd_host
        chroma: SWCLK on uo_out[1], the host's SWDIO on uo_out[2] with its
        output enable on uo_out[3], the line's level back on ui_in[2] (the
        external buffer, and the pull-up when nobody drives).

        The target takes the line on SWCLK rising edges and changes what it
        drives on them.  A line reset is 50 or more ones; a request is start
        1, APnDP, RnW, A2, A3, parity, stop 0, park 1; after one turnaround
        clock the ACK (`next_ack`: 1 OK, 2 WAIT, 4 FAULT, LSB first), then on
        OK the data with its parity: 33 bits out for a read, or after one
        more turnaround clock 33 bits in for a write.  A request with the
        wrong parity or framing is not answered.

        DP registers: 0 DPIDR (read) / ABORT (write), 4 CTRL/STAT, 8 SELECT
        (write) / RESEND, 12 RDBUFF.  `log` lists the transfers as
        ('R' or 'W', AP, address, data, parity ok), `resets` counts the line
        resets, `clocks` the rising edges, `fights` the clocks in which the
        host drove the line while the target did, `bad` the requests not
        answered. '''

    OK, WAIT, FAULT = 1, 2, 4

    def __init__(self, dut, dpidr=0x2BA01477, swclk=1, swdio=2, oe=3, line=2):
        super().__init__(dut)
        self.dpidr = dpidr
        self.swclk, self.swdio, self.oe, self.line = swclk, swdio, oe, line
        self.reg = {4: 0x00000000, 8: 0x00000000, 12: 0x00000000}
        self.ap = {}
        self.next_ack = self.OK
        self.present = True
        self.log, self.bad = [], 0
        self.resets = self.clocks = self.fights = 0
        self.drive = None                 # the level the target drives, None = released
        self.ones = 0
        self.state, self.bits = 'idle', []
        self.out = []
        dut.ui_in[line].value = 1

    @staticmethod
    def request(ap, read, addr):
        ''' The request byte of a transfer '''
        a2, a3 = (addr >> 2) & 1, (addr >> 3) & 1
        parity = (ap + read + a2 + a3) & 1
        return 1 | (ap << 1) | (read << 2) | (a2 << 3) | (a3 << 4) | (parity << 5) | (1 << 7)

    @staticmethod
    def parity(value):
        return bin(value & 0xFFFFFFFF).count('1') & 1

    def _read(self, ap, addr):
        if ap:
            return self.ap.get(addr, 0)
        return self.dpidr if addr == 0 else self.reg.get(addr, 0)

    def _rise(self, level):
        ''' One SWCLK rising edge with `level` on the line '''
        self.clocks += 1
        self.ones = self.ones + 1 if level else 0
        if self.ones == 50:
            self.resets += 1
            self.state, self.bits, self.out, self.drive = 'idle', [], [], None
            return
        if not self.present:
            return
        st = self.state
        if st == 'idle':
            if level:
                self.state, self.bits = 'request', [1]
        elif st == 'request':
            self.bits.append(level)
            if len(self.bits) == 8:
                _, ap, rd, a2, a3, par, stop, park = self.bits
                if par != ((ap + rd + a2 + a3) & 1) or stop != 0 or park != 1:
                    self.bad += 1
                    self.state = 'idle'
                else:
                    self.cur = (ap, rd, (a3 << 3) | (a2 << 2))
                    self.state = 'trn1'
        elif st == 'trn1':                         # the turnaround clock: the ACK starts here
            ack = self.next_ack
            self.next_ack = self.OK
            ap, rd, addr = self.cur
            self.out = [(ack >> k) & 1 for k in range(3)]
            if ack == self.OK and rd:
                value = self._read(ap, addr)
                self.out += [(value >> k) & 1 for k in range(32)] + [self.parity(value)]
                self.log.append(('R', ap, addr, value, True))
            self.after = 'trn2' if ack == self.OK and not rd else 'idle'
            self.drive = self.out.pop(0)
            self.state = 'drive'
        elif st == 'drive':
            if self.out:
                self.drive = self.out.pop(0)
            else:
                self.drive = None                  # released: the turnaround
                self.state, self.bits = self.after, []
                if self.state == 'idle':
                    self.state = 'trn3'
        elif st == 'trn3':                         # the turnaround clock after a read or a refusal
            self.state = 'idle'
        elif st == 'trn2':                         # the turnaround clock before the data of a write
            self.state = 'write'
        elif st == 'write':
            self.bits.append(level)
            if len(self.bits) == 33:
                value = sum(b << k for k, b in enumerate(self.bits[:32]))
                ok = self.bits[32] == self.parity(value)
                ap, rd, addr = self.cur
                if ok:
                    if ap:
                        self.ap[addr] = value
                    elif addr in (4, 8):
                        self.reg[addr] = value
                self.log.append(('W', ap, addr, value, ok))
                self.state = 'idle'

    async def run(self):
        clk_prev = 1
        while True:
            await RisingEdge(self.dut.clk)
            uo = int(self.dut.uo_out.value)
            clk, host, oe = (uo >> self.swclk) & 1, (uo >> self.swdio) & 1, (uo >> self.oe) & 1
            if oe and self.drive is not None:
                self.fights += 1
            level = host if oe else (self.drive if self.drive is not None else 1)
            if clk and not clk_prev:
                self._rise(level)
                level = host if oe else (self.drive if self.drive is not None else 1)
            self.dut.ui_in[self.line].value = level
            clk_prev = clk


class Ps2Device(Model):
    ''' PS/2 device (a keyboard or a mouse) for the ps2_host chroma.  Both
        lines are open collector: the host pulls CLK low with uo_out[1] and
        DATA with uo_out[2], the device with its own outputs, and the
        levels (low if either pulls) come back on ui_in[2] and ui_in[3].

        The device makes the clock, `half` system clocks per half period.
        To the host: `send(byte)` queues a frame, start 0, eight bits LSB
        first, odd parity, stop 1, DATA changing while CLK is high;
        `bad_parity`, `bad_stop` and `cut` (stop after that many bits) make
        the next frame wrong.  From the host: CLK held low for `hold`
        clocks or more, then DATA low with CLK released, is a request; after
        `first` clocks the device clocks ten bits in on rising edges (eight
        data, parity, stop), then pulls DATA low for one more clock, the
        acknowledge (`ack` False leaves that out).  `received` lists (byte,
        parity and stop ok), `holds` the lengths of the host's holds, and
        `reply` is sent back after every byte taken (0xFA from a keyboard). '''

    def __init__(self, dut, half=32, hold=100, first=300, clk=2, data=3, reply=None):
        super().__init__(dut)
        self.half, self.hold, self.first = half, hold, first
        self.clk, self.data = clk, data
        self.reply = reply
        self.queue, self.received, self.holds = [], [], []
        self.bad_parity = self.bad_stop = False
        self.cut = None
        self.ack = True
        self.present = True
        self.sent = 0
        self.clk_low = self.data_low = 0
        dut.ui_in[clk].value = 1
        dut.ui_in[data].value = 1

    def send(self, *values):
        self.queue += list(values)

    def _host(self):
        uo = int(self.dut.uo_out.value)
        return (uo >> 1) & 1, (uo >> 2) & 1

    async def _tick(self, n=1):
        ''' n system clocks with the lines as they are; the host's pulls at the end '''
        for _ in range(n):
            hc, hd = self._host()
            self.dut.ui_in[self.clk].value = 0 if (hc or self.clk_low) else 1
            self.dut.ui_in[self.data].value = 0 if (hd or self.data_low) else 1
            await RisingEdge(self.dut.clk)
        return self._host()

    async def _pulse(self):
        ''' One clock: low for half a period, then high; DATA as it was when CLK rose '''
        self.clk_low = 1
        await self._tick(self.half)
        hc, hd = self._host()
        level = 0 if (hd or self.data_low) else 1
        self.clk_low = 0
        await self._tick(self.half)
        return level

    async def _to_host(self, value):
        bits = [(value >> k) & 1 for k in range(8)]
        parity = (sum(bits) + 1) & 1
        frame = [0] + bits + [parity ^ (1 if self.bad_parity else 0), 0 if self.bad_stop else 1]
        n = len(frame) if self.cut is None else self.cut
        self.bad_parity = self.bad_stop = False
        self.cut = None
        for b in frame[:n]:
            self.data_low = 0 if b else 1
            await self._tick(self.half // 2)       # DATA changes while CLK is high
            self.clk_low = 1
            await self._tick(self.half)
            self.clk_low = 0
            await self._tick(self.half - self.half // 2)
        self.data_low = 0
        self.sent += 1

    async def _from_host(self):
        await self._tick(self.first)
        bits = [await self._pulse() for _ in range(10)]
        value = sum(b << k for k, b in enumerate(bits[:8]))
        ok = bits[8] == ((sum(bits[:8]) + 1) & 1) and bits[9] == 1
        if self.ack:
            self.data_low = 1
        await self._pulse()
        self.data_low = 0
        self.received.append((value, ok))
        if ok and self.reply is not None:
            await self._tick(4 * self.half)
            self.queue.insert(0, self.reply)

    async def run(self):
        held = 0
        while True:
            hc, hd = await self._tick()
            if not self.present:
                held = 0
                continue
            if hc:
                held += 1
                continue
            if held:
                self.holds.append(held)
                if held >= self.hold and hd:       # CLK released with DATA low: the host's request
                    held = 0
                    await self._from_host()
                    continue
                held = 0
            if self.queue and not hd:
                await self._to_host(self.queue.pop(0))
                await self._tick(2 * self.half)
