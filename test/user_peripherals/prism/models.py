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
