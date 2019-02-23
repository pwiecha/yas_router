#------------ Config regs submodule directed and constrained random tests --------------------------
import cocotb
from cocotb.clock import Clock, Timer

@cocotb.test()
def directed_test(dut):
    """ Multi settings test, tweakable signal and config settings"""
    #Enable logger
    log = cocotb.logging.getLogger("cocotb.test")

    CLOCK_PERIOD = 1
    cocotb.fork(Clock(dut.clk, int(CLOCK_PERIOD), units='us').start())

    yield Timer(0)
