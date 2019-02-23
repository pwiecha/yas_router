PWD=$(shell pwd)
COCOTB=$(PWD)/../cocotb
PYTHONPATH := ${PYTHONPATH}:$(PWD)/../cocotb-coverage
SRC_DIR = $(PWD)/../../rtl

TOPLEVEL_LANG := verilog

export PYTHONHOME := ${_PYTHONHOME}
export PYTHON_BIN := ${_PYTHON_BIN}
PLUSARGS := ${_QUESTA_BIN_ARGS}

# Icarus hack - define sim timescale to 1ns/1ps, has to be done via cmd_file atm
ifndef SIM
	EXTRA_ARGS += -c $(PWD)/../iverilog_precision
endif
ifeq ($(SIM), icarus)
	EXTRA_ARGS += -c $(PWD)/../iverilog_precision
endif

