library ieee;
use ieee.std_logic_1164.all;

library ecp5um;
use ecp5um.components.all;

package bb_components is 

component pll_mac is
    port (
        clki: in  std_logic; 
        clkop: out  std_logic; 
        clkos: out  std_logic; 
        clkos2: out  std_logic; 
        clkos3: out  std_logic; 
        lock: out  std_logic);
end component pll_mac;


end bb_components;

