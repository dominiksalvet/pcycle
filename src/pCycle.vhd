--doladeni taktu skrze umisteni pinu, orientace MSB u portu
--direktiva k vyberu MSB a LSB
--odstranit / pridat komentare

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pCycle is
port(
reset: 	in std_logic;
clk: 	in std_logic;
port0: 	inout std_logic_vector(3 downto 0);
port1: 	inout std_logic_vector(3 downto 0);
port2: 	inout std_logic_vector(3 downto 0);
port3: 	inout std_logic_vector(3 downto 0);
port4: 	inout std_logic_vector(3 downto 0);
port5: 	inout std_logic_vector(3 downto 0);
port6: 	inout std_logic_vector(3 downto 0);
port7: 	inout std_logic_vector(3 downto 0));
end entity;

architecture behavioral of pCycle is

component cpu is
port(
reset: 	in std_logic;
timing: in std_logic_vector(1 downto 0);
pout: 	out std_logic_vector(3 downto 0);
pid: 	out std_logic_vector(3 downto 0);
pin: 	in std_logic_vector(3 downto 0));
end component;

signal cpu_pin: 		std_logic_vector(3 downto 0);
signal cpu_pout: 		std_logic_vector(3 downto 0);
signal cpu_pid: 		std_logic_vector(3 downto 0);

signal port0_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port1_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port2_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port3_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port4_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port5_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port6_buffer: 	std_logic_vector(3 downto 0) := (others => '0');
signal port7_buffer: 	std_logic_vector(3 downto 0) := (others => '0');

signal clk_divider: 	std_logic_vector(22 downto 0) := (others => '0');
signal internal_clk: 	std_logic_vector(1 downto 0) := "10";

begin

process(clk,reset)
begin
if(reset = '0') then
clk_divider <= (others => '0');
elsif(rising_edge(clk)) then
clk_divider <= clk_divider + 1;
end if;
end process;

process(clk_divider(clk_divider'left),reset)
begin
if(reset = '0') then
internal_clk <= "10";
elsif(rising_edge(clk_divider(clk_divider'left))) then
internal_clk <= internal_clk(0) & internal_clk(1);
end if;
end process;

process(internal_clk(1),reset)
begin
if(reset = '0') then
port0_buffer <= (others => '0');
port1_buffer <= (others => '0');
port2_buffer <= (others => '0');
port3_buffer <= (others => '0');
port4_buffer <= (others => '0');
port5_buffer <= (others => '0');
port6_buffer <= (others => '0');
port7_buffer <= (others => '0');
elsif(rising_edge(internal_clk(1))) then
if(cpu_pid(3) = '1') then
case cpu_pid(2 downto 0) is
when "000" => port0_buffer <= cpu_pout;
when "001" => port1_buffer <= cpu_pout;
when "010" => port2_buffer <= cpu_pout;
when "011" => port3_buffer <= cpu_pout;
when "100" => port4_buffer <= cpu_pout;
when "101" => port5_buffer <= cpu_pout;
when "110" => port6_buffer <= cpu_pout;
when "111" => port7_buffer <= cpu_pout;
end case;
end if;
end if;
end process;

cpu_pin <=
port0 when cpu_pid(2 downto 0) = "000" else
port1 when cpu_pid(2 downto 0) = "001" else
port2 when cpu_pid(2 downto 0) = "010" else
port3 when cpu_pid(2 downto 0) = "011" else
port4 when cpu_pid(2 downto 0) = "100" else
port5 when cpu_pid(2 downto 0) = "101" else
port6 when cpu_pid(2 downto 0) = "110"
else port7;

port0 <= (others => 'Z') when cpu_pid = "0000" else port0_buffer;
port1 <= (others => 'Z') when cpu_pid = "0001" else port1_buffer;
port2 <= (others => 'Z') when cpu_pid = "0010" else port2_buffer;
port3 <= (others => 'Z') when cpu_pid = "0011" else port3_buffer;
port4 <= (others => 'Z') when cpu_pid = "0100" else port4_buffer;
port5 <= (others => 'Z') when cpu_pid = "0101" else port5_buffer;
port6 <= (others => 'Z') when cpu_pid = "0110" else port6_buffer;
port7 <= (others => 'Z') when cpu_pid = "0111" else port7_buffer;

cpu1: cpu port map(
reset => reset,
timing => internal_clk,
pout => cpu_pout,
pid => cpu_pid,
pin => cpu_pin);

end architecture;