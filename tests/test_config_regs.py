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

compile_args = []
if simulator == "icarus":
    compile_args = ["-c", f"{cwd}/iverilog_precision"]

rtl_path = cwd + "/../rtl/"
rtl_files = ["config_regs.v"]
rtl_list = [rtl_path+f for f in rtl_files]

def test_basic():
    run(
        #simulator=cocotb_test.simulator.Icarus, # cannot pass a string, only sim obj
        verilog_sources=rtl_list, # always a list
        toplevel="config_regs",
        module="tb_config_regs",
        compile_args=compile_args)


if __name__ == "__main__":
    test_basic()
