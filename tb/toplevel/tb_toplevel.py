# ----- Yas router toplevel testbench -----
# Cocotb imports
import cocotb
from cocotb.triggers import RisingEdge
# Local modules
sys.path.append(os.path.dirname(__file__) + '/../')
import tb_common
import tb_components

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
    config = YasConfigRand()
    config.randomize()
    config_driver = ConfigDriver(name="config_driver",
                                 dut_clock=dut.clk,
                                 dut_data=dut.config_data,
                                 dut_addr=dut.config_addr,
                                 dut_config_en=dut.config_en)


    # TEST BODY
    config_driver.reset()
    yield tb_common.reset_dut(dut)
    yield config_driver.send(config)
    yield RisingEdge(dut.clk)

