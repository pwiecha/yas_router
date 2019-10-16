import cocotb_test
from cocotb_test.run import run
import sys, os
import pytest

# Aliases
updir = os.path.dirname
join = os.path.join

# Change this to change simulator or set SIM variable in run shell
os.environ["SIM"] = "icarus"

# Pathing
cwd = os.getcwd()
tbd = join(updir(cwd), "tb/")
rtld = join(updir(cwd), "rtl/")
rtl_files = [join(rtld, "config_regs.v")]

# Simulator specific
compile_args = []
simulator = os.getenv("SIM", "icarus") # defaults to icarus when none set
if simulator == "icarus":
    icarus_cmd_file = join(cwd, "iverilog_precision")
    compile_args = [f"-c{icarus_cmd_file}"]
elif simulator == "questa":
    compile_args = ["-timescale", "1ns/1ns"]

# Tests to run
def test_basic():
    run(
        verilog_sources=rtl_files, # always a list
        toplevel="config_regs",
        module="tb_config_regs",
        compile_args=compile_args,
        python_search=[tbd])

