library IEEE;
use IEEE.std_logic_1164.all;

-- library ecp5um;
-- use ecp5um.components.all;

library work;
	use work.bb_components.all;

entity toplevel is
    generic(
        CLK_FREQUENCY : positive := 50000000
    );
    port(
        clk : in  std_ulogic;

        uart0_txd : out std_ulogic;
        uart0_rxd : in  std_ulogic;


        disp   : out std_ulogic_vector(13 downto 0);
        led   : out std_ulogic_vector(7 downto 0)
        );
end entity toplevel;

architecture behaviour of toplevel is
    signal mclk : std_ulogic;
    signal reset_n : std_ulogic;
    signal toggle_led : std_ulogic := '0';
    signal counter : integer range 0 to CLK_FREQUENCY;

	signal spi_sclk : std_ulogic;
	signal spi_ts : std_ulogic;

begin
    process(mclk)
    begin
        if rising_edge(mclk) then
            counter <= counter + 1;
            if counter = CLK_FREQUENCY then
                toggle_led <= not toggle_led;
                counter <= 0;
            end if;
        end if;
    end process;

    led(0) <= not toggle_led;
    led(1) <= uart0_rxd;
    led(2) <= '0';
	led(3) <= '1';
	led(4) <= '1';
	led(5) <= '1';
	led(6) <= '1';
	led(7) <= '1';

	disp <= (others => '1');

	-- gsr_inst: GSR port map (reset_n);

--	lvds_inst: lvdsob port map (uart0_rxd, toggle_led, uart0_txd);

clk_pll1: pll_mac
    port map (
        CLKI    =>  clk,
        CLKOP   =>  open,
        CLKOS   =>  mclk, -- 25 Mhz
        CLKOS2  =>  open,
        CLKOS3  =>  open,
        LOCK    =>  open
	);

	-- osc_inst: OSCG port map (osc => mclk);

	-- mclk <= clk;
-- User SPI access via USRMCLK ECP5 primitive:
--	usrmclk_inst: USRMCLK
--		port map (usrmclki => spi_sclk, usrmclkts => spi_ts);

    -- Wrap TX to RX
    uart0_txd <= uart0_rxd;
end architecture behaviour;
