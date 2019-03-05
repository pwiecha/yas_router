'''
BSD 2-Clause License

Copyright (c) 2019, TDK Electronics, Pawel Wiecha
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''
#------------ Config regs submodule directed and constrained random tests --------------------------
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.result import TestFailure, TestSuccess
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
            log.info(f"Storing data: {data} in reg addr {addr}")
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
        sample_coverage(addr, data) #Gather coverage
        log.info(f"Reading data back: {int(addr_map[addr])} from reg addr {addr}\n")
        if int(addr_map[addr]) != data:
            raise TestFailure(f"Readback failure, data mismatch")

    # Coverage
    channel_addr_data_product = itertools.product(range(0,3), range(0,3)) #cartesian product for channel addresses
    ConfigRegsCoverage = coverageSection(
            CoverPoint("top.config.crc_en", bins = [(3,0), (3,1)]),
            CoverPoint("top.config.channel_addr", bins = list(channel_addr_data_product))
    )
    @ConfigRegsCoverage
    #Empty function to gather coverage
    def sample_coverage(addr, data):
        pass

    # TEST BODY
    yield reset_dut(dut)
    for i in range(50):
        yield check_config_regs_randomized(dut, log)

    reportCoverage(log.info, bins=True)
    coverage = coverage_db["top"].coverage*100/coverage_db["top"].size
    raise TestSuccess(f"\nSummary: coverage achieved: {coverage:.2f}%")
