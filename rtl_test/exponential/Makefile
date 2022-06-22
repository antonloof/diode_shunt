<<<<<<< HEAD
# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../../rtl/hyperbolic_exp_cordic.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = hyperbolic_exp_cordic

# MODULE is the basename of the Python test file
MODULE = test_hyperbolic_exp_cordic

# include cocotb's make rules to take care of the simulator setup
=======
# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

WAVES = 1
VERILOG_SOURCES += $(PWD)/../../rtl/hyperbolic_exp_cordic.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = hyperbolic_exp_cordic

# MODULE is the basename of the Python test file
MODULE = test_hyperbolic_exp_cordic

# include cocotb's make rules to take care of the simulator setup
>>>>>>> 95e5358249cf2458d7ee60220327f8728685483d
include $(shell cocotb-config --makefiles)/Makefile.sim