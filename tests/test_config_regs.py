import cocotb_test
from cocotb_test.run import run
import sys, os
import pytest

cwd = os.getcwd()
tb_path = cwd + "/../tb"
sys.path.append(cwd)
sys.path.append(tb_path)

simulator = "icarus"
os.environ["SIM"] = "icarus"

#simulator = "questa"
#os.environ["SIM"] = "questa" # has to be set from environ

# cannot open file for reading problem
if simulator == "icarus":
    extra_args = [f"-c {cwd}/iverilog_precision"]
else:
    extra_args = []

rtl_path = cwd + "/../rtl"
rtl_files = ["config_regs.v"]
rtl_list = [rtl_path+"/"+f for f in rtl_files]

def test_basic():
    run(
        #simulator=cocotb_test.simulator.Icarus, # cannot pass a string, only sim obj
        verilog_sources=rtl_list, # always a list
        toplevel="config_regs",
        module="tb_config_regs",
        extra_args=extra_args)


if __name__ == "__main__":
    test_basic()
