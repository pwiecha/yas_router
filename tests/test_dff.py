from cocotb_test.run import run
import pytest
import os


os.environ["SIM"] = 'questa'

@pytest.mark.skipif(os.getenv("SIM") == "ghdl", reason="Verilog not suported")
def test_dff_verilog():
    run(verilog_sources=["dff.v"], toplevel="dff_test", module="dff_cocotb")  # sources  # top level HDL  # name of cocotb test module

if __name__ == "__main__":
    test_dff_verilog()
