include ../Makefile.common.inc

VERILOG_SOURCES += $(SRC_DIR)/yas_router_top.v
VERILOG_SOURCES += $(SRC_DIR)/input_logic.v
VERILOG_SOURCES += $(SRC_DIR)/crc8.v
VERILOG_SOURCES += $(SRC_DIR)/fifo_synch.v
VERILOG_SOURCES += $(SRC_DIR)/output_logic.v
VERILOG_SOURCES += $(SRC_DIR)/config_regs.v

TOPLEVEL := yas_router_top
MODULE := tb_toplevel

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
