import cocotb_test
from cocotb_test.run import run
import sys, os
import pytest
import random

# Aliases
updir = os.path.dirname
join = os.path.join

# Change this to change simulator or set SIM variable in run shell
os.environ["SIM"] = "icarus"

# Pathing
testsd = updir(os.path.abspath(__file__))
tbd = join(updir(testsd), "tb/")
rtld = join(updir(testsd), "rtl/")
rtl_files = [join(rtld, "config_regs.v")]

# Simulator specific
compile_args = []
simulator = os.getenv("SIM", "icarus") # defaults to icarus when none set
if simulator == "icarus":
    icarus_cmd_file = join(testsd, "iverilog_precision")
    compile_args = [f"-c{icarus_cmd_file}"]
elif simulator == "questa":
    compile_args = ["-timescale", "1ns/1ns"]

# Tests to run
@pytest.mark.parametrize('seed', random.sample(range(0, 10000), 4))
def test_basic(seed):
    extra_env = {"COVERAGE_RESULTS_FILENAME": join(testsd, "sim_build", "config_regs_coverage_seed"+str(seed)+".yaml")}
    run(
        verilog_sources=rtl_files, # always a list
        toplevel="config_regs",
        module="tb_config_regs",
        compile_args=compile_args,
        python_search=[tbd, join(tbd, "config_regs/")],
        seed=str(seed),
        extra_env=extra_env)
