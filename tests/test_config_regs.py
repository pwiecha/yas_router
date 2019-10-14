from cocotb_test.run import run
import sys, os
import pytest

cwd = os.getcwd()
tb_path = cwd + "/../tb"
sys.path.append(cwd)
sys.path.append(tb_path)

#os.environ["SIM"] = "questa"
mysim = os.environ.get("SIM")
if mysim is None or mysim == "icarus":
    try:
        os.environ["EXTRA_ARGS"] += os.pathsep + f"-c {cwd}/iverilog_precision"
    except KeyError:
        os.environ["EXTRA_ARGS"] = f"-c {cwd}/iverilog_precision"

rtl_path = cwd + "/../rtl"
verilog_sources=["config_regs.v"]
rtl_list = [rtl_path+"/"+f for f in verilog_sources]
os.environ["VERILOG_SOURCES"] = os.pathsep.join(rtl_list)
os.environ["MODULE"] = "tb_config_regs"
os.environ["TOPLEVEL"] = "config_regs"
os.environ["TOPLEVEL_LANG"] = "verilog"


def test_1():
    run(
        verilog_sources=f"{rtl_path}/config_regs.v",
        toplevel="config_regs",
        module="tb_config_regs")


if __name__ == "__main__":
    test_1()
