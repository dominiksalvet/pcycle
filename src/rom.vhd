library ieee;
use ieee.std_logic_1164.all;
library altera_mf;
use altera_mf.all;

entity rom is
port(
read_en: 	in std_logic;
addr: 		in std_logic_vector(6 downto 0);
data_out: 	out std_logic_vector(7 downto 0));
end rom;

architecture behavioral of rom is

signal sub_wire0: std_logic_vector(7 downto 0);

component altsyncram
generic(
clock_enable_input_a: string;
clock_enable_output_a: string;
init_file: string;
intended_device_family: string;
lpm_hint: string;
lpm_type: string;
numwords_a: natural;
operation_mode: string;
outdata_aclr_a: string;
outdata_reg_a: string;
widthad_a: natural;
width_a: natural;
width_byteena_a: natural);
port(
clock0: in std_logic;
address_a: in std_logic_vector(6 downto 0);
q_a: out std_logic_vector(7 downto 0));
end component;

begin

data_out <= sub_wire0(7 downto 0);

altsyncram_component: altsyncram
generic map(
clock_enable_input_a => "BYPASS",
clock_enable_output_a => "BYPASS",
init_file => "prg.hex",
intended_device_family => "Cyclone II",
lpm_hint => "ENABLE_RUNTIME_MOD=NO",
lpm_type => "altsyncram",
numwords_a => 128,
operation_mode => "ROM",
outdata_aclr_a => "NONE",
outdata_reg_a => "UNREGISTERED",
widthad_a => 7,
width_a => 8,
width_byteena_a => 1)
port map(
clock0 => read_en,
address_a => addr,
q_a => sub_wire0);

end behavioral;