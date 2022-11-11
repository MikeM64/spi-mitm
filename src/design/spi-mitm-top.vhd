--
-- SPI MITM - ISE Port
--
-- (c) MikeM64 - 2022
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--library UNISIM;
--use UNISIM.vcomponents.all;

entity spi_mitm_top is
    Port (
        -- Controller 0 SPI Port
        controller0_spi_ce_i    : in    std_logic;
        controller0_spi_clk_i   : in    std_logic;
        controller0_spi_cipo_o  : out   std_logic;
        controller0_spi_copi_i  : in    std_logic;
        -- Peripheral SPI Port
        peripheral_spi_ce_o     : out   std_logic;
        peripheral_spi_clk_o    : out   std_logic;
        peripheral_spi_cipo_i   : in    std_logic;
        peripheral_spi_copi_o   : out   std_logic;
        -- Controller 1 SPI
        controller1_spi_ce_io   : inout std_logic;
        controller1_spi_clk_io  : inout std_logic;
        controller1_spi_cipo_o  : out   std_logic;
        controller1_spi_copi_io : inout std_logic;
        -- SPI Enable; 0 == Controller 0, 1 == Controller 1
        controller1_spi_en_i    : in    std_logic;
        -- Interrupt pin enable; 0 == interrupt pins enabled, 1 == interrupt pins disabled
        controller1_int_en_i    : in    std_logic;
        -- Interrupt pins
        controller0_be_int_o    : out   std_logic;
        controller0_sb_int_o    : out   std_logic;
        peripheral_be_int_i     : in    std_logic;
        peripheral_sb_int_i     : in    std_logic;
        -- Logic Analyzer Tap Pins
        logic_analyzer_ce_o     : out   std_logic;
        logic_analyzer_clk_o    : out   std_logic;
        logic_analyzer_cipo_o   : out   std_logic;
        logic_analyzer_copi_o   : out   std_logic;
        logic_analyzer_be_int_o : out   std_logic;
        logic_analyzer_sb_int_o : out   std_logic);
end spi_mitm_top;

architecture Behavioral of spi_mitm_top is

signal peripheral_spi_copi_s: std_logic;

begin

--OBUF_peripheral_spi_copi_o : OBUF
--    generic map (
--        DRIVE => 8,
--        IOSTANDARD => "DEFAULT",
--        SLEW => "SLOW")
--    port map (
--        O => peripheral_spi_copi_o, -- Buffer output (connect directly to top-level port)
--        I => peripheral_spi_copi_s -- Buffer input
--    );

spi_mtim_mux_proc: process(controller1_spi_en_i, controller1_int_en_i, controller0_spi_ce_i,
                           controller0_spi_clk_i, controller0_spi_copi_i,
                           peripheral_spi_cipo_i, controller1_spi_ce_io,
                           controller1_spi_clk_io, controller1_spi_copi_io,
                           peripheral_be_int_i, peripheral_sb_int_i, peripheral_spi_copi_s)

variable spi_ce_tap_v, spi_clk_tap_v, spi_cipo_tap_v,
        spi_copi_tap_v, spi_be_int_tap_v, spi_sb_int_tap_v: std_logic;

begin

spi_be_int_tap_v := peripheral_be_int_i;

--controller0_be_int_o <= spi_be_int_tap_v when controller1_int_en_i = '0' else '1';
if controller1_int_en_i = '0' then
    controller0_be_int_o <= spi_be_int_tap_v;
else
    controller0_be_int_o <= '1';
end if;

logic_analyzer_be_int_o <= spi_be_int_tap_v;

spi_sb_int_tap_v := peripheral_sb_int_i;

--controller0_sb_int_o <= spi_sb_int_tap_v when controller1_int_en_i = '0' else '1';
if controller1_int_en_i = '0' then
    controller0_sb_int_o <= spi_sb_int_tap_v;
else
    controller0_sb_int_o <= '1';
end if;

logic_analyzer_sb_int_o <= spi_sb_int_tap_v;

--spi_ce_tap_v := controller0_spi_ce_i when controller1_spi_en_i = '0' else controller1_spi_ce_io;
if controller1_spi_en_i = '0' then
    spi_ce_tap_v := controller0_spi_ce_i;
else
    spi_ce_tap_v := controller1_spi_ce_io;
end if;

peripheral_spi_ce_o <= spi_ce_tap_v;
logic_analyzer_ce_o <= spi_ce_tap_v;

--spi_clk_tap_v := controller0_spi_clk_i when controller1_spi_en_i = '0' else controller1_spi_clk_io;
if controller1_spi_en_i = '0' then
    spi_clk_tap_v := controller0_spi_clk_i;
else
    spi_clk_tap_v := controller1_spi_clk_io;
end if;
peripheral_spi_clk_o <= spi_clk_tap_v;
logic_analyzer_clk_o <= spi_clk_tap_v;

if controller1_spi_en_i = '0' then
    controller1_spi_ce_io <= controller0_spi_ce_i;
    controller1_spi_clk_io <= controller0_spi_clk_i;
    controller1_spi_copi_io <= controller0_spi_copi_i;
else
    controller1_spi_ce_io <= 'Z';
    controller1_spi_clk_io <= 'Z';
    controller1_spi_copi_io <= 'Z';
end if;

--spi_copi_tap_v := controller0_spi_copi_i when controller1_spi_en_i = '0' else controller1_spi_copi_io;
if controller1_spi_en_i = '0' then
    spi_copi_tap_v := controller0_spi_copi_i;
else
    spi_copi_tap_v := controller1_spi_copi_io;
end if;
peripheral_spi_copi_s <= spi_copi_tap_v;
logic_analyzer_copi_o <= peripheral_spi_copi_s;
peripheral_spi_copi_o <= peripheral_spi_copi_s;

spi_cipo_tap_v := peripheral_spi_cipo_i;
logic_analyzer_cipo_o <= spi_cipo_tap_v;

--controller1_spi_cipo_o <= spi_cipo_tap_v when controller1_spi_en_i = '1' else '0';
if controller1_spi_en_i = '1' then
    controller1_spi_cipo_o <= spi_cipo_tap_v;
else
    controller1_spi_cipo_o <= '0';
end if;

--controller0_spi_cipo_o <= spi_cipo_tap_v when controller1_spi_en_i = '0' else '0';
if controller1_spi_en_i = '0' then
    controller0_spi_cipo_o <= spi_cipo_tap_v;
else
    controller0_spi_cipo_o <= '0';
end if;


end process spi_mtim_mux_proc;

end Behavioral;
