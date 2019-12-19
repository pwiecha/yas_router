# yas_router
Yet Another Simple Router - a COCOTB verification example of the Verilog RTL simple router model. Feel free to use this to kickstart your verification environment.

This is a work in progress. 

__Requirements:__ 

| Package       | Usage         |
| ------------- | ------------- |
| __cocotb__    | writing testbenches in Python   |
| __cocotb-coverage__   | functional coverage definitions, gathering and metrics   |
| __cocotb-test__ | __Optional__ for running testcases using __pytest__ framework. Makefiles are provided as an alternative |
| __pytest__    |  __Optional__ for running testcases together with __cocotb-test__   |
| __iverilog__    |  Free digital hardware simulator (or use any commercial one)   |

__Running examples__:
Folder tests contain an example of how to run your testcases using pytest framework. Cocotb-test and pytest packages are used for that.
`cd tests` + `pytest` or `pytest <test_name>` to run all or just a specific test / set of tests. Refer to pytest documentation on how to select tests to run.

Alternatively there are makefiles provided:
`cd tb/config_regs` + `make` to run with default arguments.

You can also provide additional args like this: `make SIM=questa SIM_ARGS="+FOO +BAR=5"`. `SIM` (simulator) supports e.g. `icarus, questa, vcs, xcelium`. You can use `SIM_ARGS` to pass additional arguments, in this example `FOO` is set to `1` (`+FOO` == `+FOO=1`) and `BAR` is set to `5`. Take a look at testcases and `ArgParser` from `tb_common` on how to define and use these arguments in your testbenches.


__Initial Router Specification:__  

1x3 Router  
1 input channel  
3 output channels  

1 clock clk  
active low async reset rst_n  
Data_in data [7:0]  
Data_in_req data_req  
Data_ack data_ack  
Same IF for output
Minimal Register interface  


Packet format [header / size / data / CRC], header first  
HEADER MSB [HEADER|SIZE] LSB :     
2b (address), 6b payload size (bytes)  

1-63bytes data  (size+1, pkts have a minimum of 1 byte of data, does not include CRC byte)

8bit CRC (calculated over everything)  

Bad address or CRC - packet discarded  
Channel addresses configurable via registers  
Multiple channels can have the same address  

Config  
Simple interface for programming (addr, data, enable)  
Each channel has configurable address (1) via registers  
CRC check on / off  
