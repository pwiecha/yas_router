#------------ Config regs submodule directed and constrained random tests --------------------------
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.result import TestFailure
from cocotb_coverage.coverage import *

import sys, os
import random
import itertools
sys.path.append(os.path.dirname(__file__) + '/../')
from tb_common import *

@cocotb.test()
def randomized_test(dut):
    """ Randomized config regs test """
    #Enable logger
    log = cocotb.logging.getLogger("cocotb.test")

    CLOCK_PERIOD = 1
    cocotb.fork(Clock(dut.clk, int(CLOCK_PERIOD), units='us').start())#1MHz

    @cocotb.coroutine
    def check_config_regs_randomized(dut, log):
        @cocotb.coroutine
        def set_config_reg(dut, addr, data, log):
            yield RisingEdge(dut.clk)
            log.info(f"Setting reg on addr {addr} with data {data}")
            dut.config_addr <= addr
            dut.config_data <= data
            dut.config_en <= 1
            yield RisingEdge(dut.clk)
            dut.config_en <= 0
            yield RisingEdge(dut.clk)

        addr_map = {0:dut.ch0_addr_r, 1:dut.ch1_addr_r, 2:dut.ch2_addr_r, 3:dut.crc_en_r}
        #---------------------------------------------
        # Randomize & set field, then probe a register
        addr = random.randint(0,3)

        if addr == 3: #CRC on/off
            data = random.randint(0,1)
        else: #channel addresses
            data = random.randint(0,2)

        yield set_config_reg(dut, addr, data, log)
        sample_coverage(addr, data)
        if int(addr_map[addr]) == data:
            log.info(f"Readback success on addr {addr}\n")
        else:
            log.info(f"Readback failure, data {data}, readback {int(addr_map[addr])}\n")
            raise TestFailure

    # Coverage
    channel_addr_data_product = itertools.product(range(0,3), range(0,3)) #cartesian product
    ConfigRegsCoverage = coverageSection(
            CoverPoint("top.config.crc_en", bins = [(3,0), (3,1)]),
            CoverPoint("top.config.channel_addr", bins = list(channel_addr_data_product))
    )
    @ConfigRegsCoverage
    #Empty function to catch metrics
    def sample_coverage(addr, data):
        pass

    # TEST BODY
    yield reset_dut(dut)
    for i in range(45):
        yield check_config_regs_randomized(dut, log)

    reportCoverage(log.info, bins=1)
    coverage = coverage_db["top"].coverage*100/coverage_db["top"].size
    log.info(f"Current coverage {coverage:.2f} %")

    #TODO cover all config_regs, generate addresses & values of not yet covered items



