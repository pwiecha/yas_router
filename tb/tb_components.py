# ------------------- Helper Classes & Components ------------------
# ----------------------- For Yas Rounter Testbench ------------------------
import cocotb
from cocotb_coverage.crv import Randomized
from cocotb.drivers import Driver
from cocotb.triggers import RisingEdge, ReadOnly
import random as r


class YasConfig():
    def __init__(self, ch0_addr=0, ch1_addr=1, ch2_addr=2, crc_en=0):
        self.ch0_addr = ch0_addr
        self.ch1_addr = ch1_addr
        self.ch2_addr = ch2_addr
        self.crc_en = crc_en
        self.addr_map = {0: self.ch0_addr,
                         1: self.ch1_addr,
                         2: self.ch2_addr,
                         3: self.crc_en}


class YasConfigRand(YasConfig, Randomized):
    def __init__(self):
        Randomized.__init__(self)
        YasConfig.__init__(self)

        self.add_rand("ch0_addr", list(range(3)))
        self.add_rand("ch1_addr", list(range(3)))
        self.add_rand("ch2_addr", list(range(3)))
        self.add_rand("crc_en", [0, 1])

        # TODO: remove when CRC is implemented
        self.add_constraint(lambda crc_en: crc_en == 0)


class YasPkt():
    def __init__(self, addr=0, data_size=0, data=[], crc_init=0):
        self.addr = addr
        self.data_size = data_size
        self.crc_init = crc_init
        self.data = data
        self.payload = [self.addr << 6 + self.data_size, *self.data, self.crc]

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
    def __init__(self):
        Randomized.__init__(self)
        YasPkt.__init__(self)

        self.add_rand("addr", list(range(3)))
        self.add_rand("data_size", list(range(1, 64)))

    # populate data list bytewise
    def post_randomize(self):
        self.data = [r.randint(0, 255) for _ in range(self.data_size)]


# TODO: create Bus bundle or use one from cocotb
class ConfigDriver(Driver):
    """ Class for reading/writing yas router config registers """
    def __init__(self, name, dut_clock, dut_data, dut_addr, dut_config_en):
        self.name = name
        self.clock = dut_clock
        self.data_port = dut_data
        self.addr_port = dut_addr
        self.en_port = dut_config_en
        Driver.__init__(self)
        self.reset()

    def reset(self):
        self.log.info(f"{self.name} in reset")
        self.data_port.setimmediatevalue(0)
        self.addr_port.setimmediatevalue(0)
        self.en_port.setimmediatevalue(0)

    @cocotb.coroutine
    def _driver_send(self, config, **kwargs):
        self.log.info(f"{self.name}: configuring router with {config}")
        for addr, val in config.addr_map.items():
            self.en_port <= 1
            self.data_port <= val
            self.addr_port <= addr
            yield RisingEdge(self.clock)
            self.en_port <= 0
            yield RisingEdge(self.clock)
        self.log.info(f"{self.name}: finished configuration")


# optional: send event when pkt sent to track sent pkt count
class InputPktDriver(Driver):
    """ Class for driving input packets to the yas router """
    def __init__(self, name, dut_clock, dut_data, dut_req, dut_ack):
        self.name = name
        self.clock = dut_clock
        self.data_port = dut_data
        self.req_port = dut_req
        self.ack_port = dut_ack
        Driver.__init__(self)
        self._reset()

    def _reset(self):
        self.log.info(f"{self.name} in reset")
        self.data_port.setimmediatevalue(0)
        self.req_port.setimmediatevalue(0)

    @cocotb.coroutine
    def _driver_send(self, pkt):
        self.log.info(f"{self.name}: sending packet {pkt}")
        for pkt_byte in pkt.payload:
            self.req_port <= 1
            self.data_port <= pkt_byte
            yield RisingEdge(self.clock)
            while True:
                yield ReadOnly()
                if self.ack_port == 1:
                    self.req_port <= 0
                    break
                yield RisingEdge(self.clock)
        self.log.info(f"{self.name}: finished sending packet {pkt}")

