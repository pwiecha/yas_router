# ------------------- Helper Classes & Components ------------------
# ----------------------- For Yas Rounter Testbench ------------------------
from cocotb_coverage.crv import Randomized
from cocotb.drivers import Driver
import random as r

class YasConfig():
    def __init__(self, ch0_addr=0, ch1_addr=1, ch2_addr=2, crc_en=0):
        self.ch0_addr = 0
        self.ch1_addr = 1
        self.ch2_addr = 2
        self.crc_en = 0

    @property
    def ch0_addr(self):
        return self.ch0_addr

    @ch0_addr.setter
    def ch0_addr(self, new_addr):
        self.ch0_addr = new_addr

    @property
    def ch1_addr(self):
        return self.ch1_addr

    @ch1_addr.setter
    def ch1_addr(self, new_addr):
        self.ch1_addr = new_addr

    @property
    def ch2_addr(self):
        return self.ch2_addr

    @ch2_addr.setter
    def ch2_addr(self, new_addr):
        self.ch2_addr = new_addr

    @property
    def crc_en(self):
        return self.crc_en

    @ch0_addr.setter
    def crc_en(self, crc_en):
        self.crc_en = crc_en

class YasConfigRand(YasConfig, Randomized):
    def __init__(self):
        Randomized.__init__(self)
        YasConfig.__init__(self)

        self.add_rand("ch0_addr", list(range(3))
        self.add_rand("ch1_addr", list(range(3))
        self.add_rand("ch2_addr", list(range(3))
        self.add_rand("crc_en", [0, 1])

        #TODO: remove when CRC is implemented

        self.add_constraint(lambda crc_en: crc_en == 0)

class YasPkt():
    def __init__(self, addr=0, data_size=0, data=[], crc_init=0):
        self.addr = addr
        self.data_size = data_size
        self.crc_init = crc_init
        self.data = data
        self.pkt = [self.addr << 6 + self.data_size, *self.data, self.crc]

    @property
    def data(self):
        return self.data

    @data.setter
    def data(self, new_data):
        self.data = new_data
        self.crc = self.calc_crc()

    def calc_crc(self):
        pass

class YasPktRand(YasPkt, Randomized):
    def __init__():
        Randomized.__init__(self)
        YasPkt.__init__(self)

        self.add_rand("addr", list(range(3)))
        self.add_rand("data_size", list(range(1, 64)))

    def post_randomize(self):
        self.data = [r.randint(0, 255) for _ in range(self.data_size)] # populate data list


class InputDriver(Driver):
    """ Class for driving input packets to the yas router """
    def __init__(self, name, dut_clock, dut_data, dut_req, dut_ack):
        self.name = name
        self.clock = dut_clock
        self.data_port = dut_data
        self.req_port = dut_req
        self.ack_port = dut_ack

    def _reset(self):
        self.log.info(f"{self.name} in reset")
        self.data_port.setimmediatevalue(0)
        self.req_port.setimmediatevalue(0)

    @cocotb.coroutine
    def _driver_send(self, pkt;t




