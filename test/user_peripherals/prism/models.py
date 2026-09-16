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
