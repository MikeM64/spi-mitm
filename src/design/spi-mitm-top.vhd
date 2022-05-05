--
-- SPI MITM
--
-- (c) MikeM64 - 2022
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity spi_mitm_top is
    Port (
        -- Syscon SPI Port
        syscon_spi_ce_i         : in    std_logic;
        syscon_spi_clk_i        : in    std_logic;
        syscon_spi_cipo_o       : out   std_logic;
        syscon_spi_copi_i       : in    std_logic;
        -- Cell SPI Port
        cell_spi_ce_o           : out   std_logic;
        cell_spi_clk_o          : out   std_logic;
        cell_spi_cipo_i         : in    std_logic;
        cell_spi_copi_o         : out   std_logic;
        -- Intercept SPI
        intercept_spi_ce_io     : inout std_logic;
        intercept_spi_clk_io    : inout std_logic;
        intercept_spi_cipo_o    : out   std_logic;
        intercept_spi_copi_io   : inout std_logic;
        intercept_spi_en_i      : in    std_logic;
        intercept_int_en_i      : in    std_logic;
        -- Interrupt pins
        syscon_be_int_o         : out   std_logic;
        syscon_sb_int_o         : out   std_logic;
        cell_be_int_i           : in    std_logic;
        cell_sb_int_i           : in    std_logic;
        -- Logic Analyzer Tap Pins
        logic_analyzer_ce_o     : out   std_logic;
        logic_analyzer_clk_o    : out   std_logic;
        logic_analyzer_cipo_o   : out   std_logic;
        logic_analyzer_copi_o   : out   std_logic;
        logic_analyzer_be_int_o : out   std_logic;
        logic_analyzer_sb_int_o : out   std_logic);
end spi_mitm_top;

architecture Behavioral of spi_mitm_top is

signal cell_spi_copi_s: std_logic;

begin

OBUF_cell_spi_copi_o : OBUF
    generic map (
        DRIVE => 8,
        IOSTANDARD => "DEFAULT",
        SLEW => "SLOW")
    port map (
        O => cell_spi_copi_o, -- Buffer output (connect directly to top-level port)
        I => cell_spi_copi_s -- Buffer input
    );

spi_mtim_mux_proc: process(intercept_spi_en_i, intercept_int_en_i, syscon_spi_ce_i,
                           syscon_spi_clk_i, syscon_spi_copi_i,
                           cell_spi_cipo_i, intercept_spi_ce_io,
                           intercept_spi_clk_io, intercept_spi_copi_io,
                           cell_be_int_i, cell_sb_int_i, cell_spi_copi_s)

variable spi_ce_tap_v, spi_clk_tap_v, spi_cipo_tap_v,
        spi_copi_tap_v, spi_be_int_tap_v, spi_sb_int_tap_v: std_logic;

begin

spi_be_int_tap_v := cell_be_int_i;
syscon_be_int_o <= spi_be_int_tap_v when intercept_int_en_i = '0' else '1';
logic_analyzer_be_int_o <= spi_be_int_tap_v;

spi_sb_int_tap_v := cell_sb_int_i;
syscon_sb_int_o <= spi_sb_int_tap_v when intercept_int_en_i = '0' else '1';
logic_analyzer_sb_int_o <= spi_sb_int_tap_v;

spi_ce_tap_v := syscon_spi_ce_i when intercept_spi_en_i = '0' else intercept_spi_ce_io;
cell_spi_ce_o <= spi_ce_tap_v;
logic_analyzer_ce_o <= spi_ce_tap_v;

spi_clk_tap_v := syscon_spi_clk_i when intercept_spi_en_i = '0' else intercept_spi_clk_io;
cell_spi_clk_o <= spi_clk_tap_v;
logic_analyzer_clk_o <= spi_clk_tap_v;

if intercept_spi_en_i = '0' then
    intercept_spi_ce_io <= syscon_spi_ce_i;
    intercept_spi_clk_io <= syscon_spi_clk_i;
    intercept_spi_copi_io <= syscon_spi_copi_i;
else
    intercept_spi_ce_io <= 'Z';
    intercept_spi_clk_io <= 'Z';
    intercept_spi_copi_io <= 'Z';
end if;

spi_copi_tap_v := syscon_spi_copi_i when intercept_spi_en_i = '0' else intercept_spi_copi_io;
cell_spi_copi_s <= spi_copi_tap_v;
logic_analyzer_copi_o <= cell_spi_copi_s;

spi_cipo_tap_v := cell_spi_cipo_i;
logic_analyzer_cipo_o <= spi_cipo_tap_v;
intercept_spi_cipo_o <= spi_cipo_tap_v when intercept_spi_en_i = '1' else '0';
syscon_spi_cipo_o <= spi_cipo_tap_v when intercept_spi_en_i = '0' else '0';

end process spi_mtim_mux_proc;

end Behavioral;
