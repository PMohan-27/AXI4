SIM ?= icarus
TOPLEVEL_LANG = verilog
SRC_DIR = $(PWD)/../rtl
PROJECT_SOURCES = axi4-lite.v
WAVES = 1
SIM_BUILD = sim_build/

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/axi4-lite/,$(PROJECT_SOURCES))
COMPILE_ARGS	+= -I$(SRC_DIR)/axi4-lite

TOPLEVEL= axi4_lite
COCOTB_TEST_MODULES=test_axi4_lite

include $(shell cocotb-config --makefiles)/Makefile.sim

