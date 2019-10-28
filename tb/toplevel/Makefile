include ../Makefile.common.inc

VERILOG_SOURCES += $(wildcard $(RTL_DIR)/*.v)

TOPLEVEL := yas_router_top
MODULE := tb_toplevel

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
