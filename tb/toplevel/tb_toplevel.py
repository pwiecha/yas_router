# ----- Yas router toplevel testbench -----
# Cocotb imports
import cocotb
from cocotb.triggers import RisingEdge
# Local modules
import sys
import os
sys.path.append(os.path.dirname(__file__) + '/../')
import tb_common
import tb_components as tb_comp


@cocotb.test()
def first_test(dut):
    """ First yas router test """
    log = cocotb.logging.getLogger("cocotb.test")

    # CLK_RATE defined by default
    args = tb_common.ArgParser(
        log, cocotb.plusargs,
        COLLECT_COVERAGE=(False, bool))

    tb_common.create_clock(dut.clk, args.CLK_RATE, log)

    # Testbench elements creation and connection
    config = tb_comp.YasConfigRand()
    config.randomize()
    log.info(f"Randomized config: ch0: {config.ch0_addr}, ch1: {config.ch1_addr}, ch2: {config.ch2_addr}, crc_en: {config.crc_en}")
    config_driver = tb_comp.ConfigDriver(name="config_driver",
                                         dut_clock=dut.clk,
                                         dut_data=dut.config_data,
                                         dut_addr=dut.config_addr,
                                         dut_config_en=dut.config_en)

    test_pkt = YasPktRand()
    test_pkt.randomize()

    input_drv = InputPktDriver(name="input_driver",
                               dut_clock=dut.clk,
                               dut_data=dut.data_in,
                               dut_req=dut.data_in_req,
                               dut_ack=dut.data_in_ack)


    # TEST BODY
    config_driver.reset()
    yield tb_common.reset_dut(dut)
    yield config_driver.send(config)
    yield RisingEdge(dut.clk)

