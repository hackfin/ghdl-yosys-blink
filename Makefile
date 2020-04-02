# Use local tools
#GHDL      = ghdl
#GHDLSYNTH = ghdl.so
#YOSYS     = yosys
#NEXTPNR   = nextpnr-ecp5
#ECPPACK   = ecppack
#OPENOCD    = openocd

include docker.mk

# OrangeCrab with ECP85
#GHDLARGS=-gCLK_FREQUENCY=50000000
#LPF=constraints/orange-crab.lpf
#PACKAGE=CSFBGA285
#NEXTPNR_FLAGS=--um5g-85k --freq 50
#OPENOCD_JTAG_CONFIG=openocd/olimex-arm-usb-tiny-h.cfg
#OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-85F.cfg

# ECP5-EVN
# GHDL_GENERICS=-gCLK_FREQUENCY=12000000
# LPF=constraints/ecp5-evn.lpf
# PACKAGE=CABGA381
# NEXTPNR_FLAGS=--um5g-85k --freq 12
# OPENOCD_JTAG_CONFIG=openocd/ecp5-evn.cfg
# OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-85F.cfg

# Versa ECP5(G)

CLK_FREQ = 12500000

GHDL_GENERICS=-gCLK_FREQUENCY=$(CLK_FREQ)
LPF=constraints/versa.lpf
PACKAGE=CABGA381
NEXTPNR_FLAGS=--um5g-45k --freq 100
OPENOCD_JTAG_CONFIG=openocd/ecp5-versa.cfg
OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-45F.cfg

GHDL_LIBFLAGS = -Plib
GHDL_LIB_ABSOLUTE_DIR = $(HOME)/vhdl/lib-devel/
DIAMOND_LIB_ABSOLUTE_DIR = /data/src/diamond_lib

GHDL_FLAGS = --std=93c --workdir=work $(GHDL_LIBFLAGS)

all: vhdl_blink.bit

show:
	$(GHDL) --version

lib:
	mkdir $@

lib/ecp5um-std93.cf: $(GHDL_LIB_ABSOLUTE_DIR)/lattice/ecp5u/components.vhdl | lib
	$(GHDL) -i --workdir=$(dir $@) --work=ecp5um \
		$< 


vhdl_blink.json: black_boxes.vhdl vhdl_blink.vhdl 
	$(YOSYS) -m $(GHDLSYNTH) -p \
		"ghdl $(GHDL_FLAGS) $(GHDL_GENERICS) $^ -e toplevel; \
		read_verilog pll_mac.v; \
		synth_ecp5 -top toplevel -json $@" 2>&1 | tee report.txt

vhdl_blink_out.config: vhdl_blink.json $(LPF)
	$(NEXTPNR) --json $< --lpf $(LPF) --textcfg $@ $(NEXTPNR_FLAGS) --package $(PACKAGE)

vhdl_blink.bit: vhdl_blink_out.config
	$(ECPPACK) --svf vhdl_blink.svf $< $@

vhdl_blink.svf: vhdl_blink.bit

prog: vhdl_blink.svf
	$(OPENOCD) -f $(OPENOCD_JTAG_CONFIG) -f $(OPENOCD_DEVICE_CONFIG) -c "transport select jtag; init; svf $<; exit"

clean:
	@rm -f work-obj08.cf *.bit *.json *.svf *.config

.PHONY: clean prog
.PRECIOUS: vhdl_blink.json vhdl_blink_out.config vhdl_blink.bit
