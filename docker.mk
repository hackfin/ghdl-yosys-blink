# Use Docker images
DOCKER=docker
#DOCKER=podman
#
PWD = $(shell pwd)
DOCKERARGS = run --rm -v $(PWD):/src \
	-v $(DIAMOND_LIB_ABSOLUTE_DIR):/src/diamond_lib \
	-v $(GHDL_LIB_ABSOLUTE_DIR):/src/lib-devel \
	-w /src


GHDL      = $(DOCKER) $(DOCKERARGS) ghdl/synth:beta ghdl
GHDLSYNTH = ghdl
YOSYS     = $(DOCKER) $(DOCKERARGS) ghdl/synth:beta yosys
NEXTPNR   = $(DOCKER) $(DOCKERARGS) ghdl/synth:nextpnr-ecp5 nextpnr-ecp5
ECPPACK   = $(DOCKER) $(DOCKERARGS) ghdl/synth:trellis ecppack
OPENOCD   = $(DOCKER) $(DOCKERARGS) --device /dev/bus/usb ghdl/synth:prog openocd


