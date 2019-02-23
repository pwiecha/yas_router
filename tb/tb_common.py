# ------------------- Helper Functions, Coroutines & Classes ------------------
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Timer

#--------------------------------------------------
@cocotb.coroutine
def wait_clock_cycles(clock, no_of_clock_cycles):
    for cycle in range(no_of_clock_cycles):
        yield RisingEdge(clock)

@cocotb.coroutine
def reset_dut(dut, CLOCK_PERIOD):
    dut.rst_n <= 0
    yield Timer(CLOCK_PERIOD*5, units="ns")
    dut.rst_n <= 1
