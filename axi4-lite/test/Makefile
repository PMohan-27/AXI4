SIM ?= verilator
TOPLEVEL_LANG = verilog
SRC_DIR = $(PWD)/../rtl
PROJECT_SOURCES =  axi_lite_if.sv  axi4_lite_master.sv axi4_lite_top.sv axi4_lite_slave.sv
WAVES = 1
SIM_BUILD = sim_build

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS	+= -I$(SRC_DIR)/axi4-lite

TOPLEVEL= axi4_lite_top
COCOTB_TEST_MODULES=test_axi4_lite
EXTRA_ARGS += --trace --trace-fst --trace-structs --x-initial unique --x-assign unique


include $(shell cocotb-config --makefiles)/Makefile.sim

