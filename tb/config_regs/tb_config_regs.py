#---------- Config regs submodule containing
#      directed and constrained random tests ----------
# Cocotb imports
import cocotb
from cocotb.clock import Timer
from cocotb.triggers import RisingEdge
from cocotb.result import TestFailure, TestSuccess
from cocotb_coverage.coverage import *

# Generic imports
import sys, os
import random
import itertools

# Local modules
sys.path.append(os.path.dirname(__file__) + '/../')
import tb_common

@cocotb.test()
def randomized_test(dut):
    """ Randomized config regs read/write test """
    # Enable logger
    log = cocotb.logging.getLogger("cocotb.test")
    args = tb_common.ArgParser(
        log, cocotb.plusargs,
        COLLECT_COVERAGE=(True, bool))

    tb_common.create_clock(dut.clk, args.CLK_RATE, log)

    @cocotb.coroutine
    def check_config_regs_randomized(dut, log):

        @cocotb.coroutine
        def set_config_reg(dut, addr, data, log):
            yield RisingEdge(dut.clk)
            if args.DEBUG:
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
            data = random.randint(0,1) # random implementation is inclusive
        else: #channel addresses
            data = random.randint(0,2)

        yield set_config_reg(dut, addr, data, log)
        sample_coverage(addr, data) #Gather coverage
        if args.DEBUG:
            log.info(f"Reading data back: {int(addr_map[addr])} from reg addr {addr}\n")
        if int(addr_map[addr]) != data:
            log.error(f"Readback failure, data mismatch")
            return 1
        else:
            return 0

    # Coverage
    channel_addr_data_product = itertools.product(range(0,3), range(0,3)) #cartesian product for channel addresses
    ConfigRegsCoverage = coverage_section(
            CoverPoint("top.config.crc_en", bins = [(3,0), (3,1)]),
            CoverPoint("top.config.channel_addr", bins = list(channel_addr_data_product))
    )
    @ConfigRegsCoverage
    #Empty function to gather coverage
    def sample_coverage(addr, data):
        pass

    # TEST BODY
    yield tb_common.reset_dut(dut)
    failed_test_ids = []
    for i in range(10):
        test_result = yield check_config_regs_randomized(dut, log)
        if test_result:
            failed_test_ids.append(i)

    coverage_db.report_coverage(log.info, bins=True)
    coverage = coverage_db["top"].coverage*100/coverage_db["top"].size
    # coverage_db.export_to_yaml(os.getenv("COVERAGE_RESULTS_FILENAME", "results_coverage.yml")) # TODO wait for cocotb-coverage 1.0.5 release
    error_cnt = len(failed_test_ids)
    if error_cnt == 0:
        raise TestSuccess(f"\nSummary: coverage achieved: {coverage:.2f}%")
    else:
        raise TestFailure(f"There were {error_cnt} readback failures, failed_test_ids: {failed_test_ids}")

