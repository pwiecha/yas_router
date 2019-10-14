from cocotb_test.run import run
import pytest
import os


os.environ["SIM"] = 'questa'

@pytest.mark.skipif(os.getenv("SIM") == "ghdl", reason="Verilog not suported")
def test_dff_verilog():
    run(verilog_sources=["dff.v"], toplevel="dff_test", module="dff_cocotb")  # sources  # top level HDL  # name of cocotb test module

os.environ["VERILOG_SOURCES"] = "dff.v"
os.environ["MODULE"] = "dff_cocotb"
os.environ["TOPLEVEL"] = "dff_test"
os.environ["TOPLEVEL_LANG"] = "verilog"
def test_dff_verilog2():
    run()

if __name__ == "__main__":
    test_dff_verilog()
    test_dff_verilog2()
