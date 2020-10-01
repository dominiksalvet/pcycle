library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram is
port(
reset: 		in std_logic;
clk: 		in std_logic;
write_en: 	in std_logic;
addr: 		in std_logic_vector(2 downto 0);
data_in: 	in std_logic_vector(3 downto 0);
data_out: 	out std_logic_vector(3 downto 0));
end ram;

architecture behavioral of ram is

type ram_memory is array (0 to 7) of std_logic_vector(3 downto 0);
signal ram_data: ram_memory := (others => (others => '0'));

begin

process(clk,reset)
begin
if(reset = '0') then
ram_data <= (others => (others => '0'));
elsif(rising_edge(clk)) then
if(write_en = '1') then
ram_data(conv_integer(addr)) <= data_in;
end if;
end if;
end process;

data_out <= ram_data(conv_integer(addr));

end behavioral;