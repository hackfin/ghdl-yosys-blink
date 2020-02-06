# ghdl-yosys-blink

Blink an LED on an FPGA using ghdl, yosys and nextpnr - a completely
Open Source VHDL synthesis flow.

## Supported Hardware

Right now only Lattice ECP5 boards are supported, but you should be able
to use anything that yosys and nextpnr supports. I've personally tested
the Lattice ECP5-EVN board and the OrangeCrab.

This fork supports the Versa ECP5 board with some added workarounds to include
black box modules and vendor primitives. As there's currently no support for
wrapping generics of black boxes, you should read on below about the black box
specifics in this fork.

For the ECP5 versa board, the orange LED should blink once every second.

## Prerequisites

You can install the latest versions of GHDL, ghdlsynth-beta, yosys, prjtrellis
and nextpnr if you want, but thanks to the GHDL Docker project we have Docker
images for everything!

It also works fine with podman if you prefer that to Docker.

## Building

```
make
make prog
```

## Inclusion of Black box vendor primitives

Currently, ghdl synthesis does not wrap Verilog generics for black boxes.

So the current strategy to support synthesis of large projects seems to be:

 - Write all your VHDL code as vendor independent as possible, a priori try to
  avoid `library ecp5um;`
 - For all black box primitives (FPGA cells) that use generics, write a Verilog
 wrapper or generate one
 - Create a black boxes VHDL package to declare a custom black box, like

    ```
    package bb_components is 
    	component pll is
    		port (
    			CLKI: in  std_logic; 
    			CLKOP: out  std_logic; 
    			CLKOS: out  std_logic; 
    			CLKOS2: out  std_logic; 
    			CLKOS3: out  std_logic; 
    			LOCK: out  std_logic);
    	end component pll;
    end bb_components;
    ```
 - Use this package in your code:
   `library work; use work.bb_components.all;`
   Instanciate the desired component in your VHDL code.
 
 - During elaboration, GHDL will show a notice that the instance of this component
   'pll' is not bound. It will therefore have to be included separately using
   a `read_verilog pll.v` statement in the yosys command script.
   See also Makefile.

If the modules are correctly resolved, you will see them in the design
hierarchy:

```
3.3.1. Analyzing design hierarchy..
Top module:  \toplevel_25000000
Used module:     \pll
```

