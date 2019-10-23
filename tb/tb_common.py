# ------------------- Helper Functions, Coroutines & Classes ------------------
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

#--------------------------------------------------
@cocotb.coroutine
def wait_clock_cycles(clock, no_of_clock_cycles):
    for cycle in range(no_of_clock_cycles):
        yield RisingEdge(clock)

def create_clock(clk, clk_freq, logger):
    clk_period = int(1e9/clk_freq)  # convert to period in ns
    if clk_period % 2 != 0:
        clk_period += 1
        logger.info("Create clock function: adding 1 unit to clock period for it to be even")

    cocotb.fork(Clock(clk, clk_period, units='ns').start())

@cocotb.coroutine
def reset_dut(dut):
    dut.rst_n <= 0
    yield wait_clock_cycles(dut.clk, 5)
    dut.rst_n <= 1

class ArgParser(object):
    """ Command line arguments (SIM_ARGS) parser """
    def __init__(self, logger, plusargs, **kwargs):
        class_name = self.__class__.__name__

        # Default keys
        setattr(self, "CLK_RATE", int(1e6))
        setattr(self, "DEBUG", False)

        # Instantiation arguments
        for key in kwargs.keys():
            key_type = kwargs[key][1]
            setattr(self, key, key_type(kwargs[key][0]))

        # Command line arguments
        for key in plusargs.keys():
            if key not in self.__dict__:
                logger.warning((f"{class_name}: skipping unrecognized command-line "
                                f"argument {key}, define it at class instantiation first"))
            else:
                key_type = type(self.__dict__[key])
                try:
                    if key_type == int:
                        # enable scientific notation
                        setattr(self, key, key_type(float(plusargs[key])))
                    elif key_type == bool:
                        # Non-empty strings defaults to True
                        if plusargs[key] == "0" or plusargs[key] == "False":
                            setattr(self, key, False)
                        else:
                            setattr(self, key, True)
                    else:
                        logger.info(f"setting key {key} of type {key_type} to {plusargs[key]} {key_type(plusargs[key])}")
                        setattr(self, key, key_type(plusargs[key]))
                except ValueError:
                    raise TestFailure(f"{class_name}: cannot convert {key} to type {key_type}")

        # Print all keys to the console
        logger.info(80*"=")
        logger.info(f"{class_name} parameters:")
        for key, value in self.__dict__.items():
            logger.info(f"{key}: {value}")

        logger.info(80*f"=")
