library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu is
port(
reset: 		in std_logic;
timing: 	in std_logic_vector(1 downto 0);
pout: 		buffer std_logic_vector(3 downto 0);
pid: 		buffer std_logic_vector(3 downto 0);
pin: 		in std_logic_vector(3 downto 0));
end entity;

architecture behavioral of cpu is

component alu is
port(
opcode: 	in std_logic_vector(2 downto 0);
operand1: 	in std_logic_vector(3 downto 0);
operand2: 	in std_logic_vector(3 downto 0);
result: 	out std_logic_vector(3 downto 0);
status: 	out std_logic_vector(2 downto 0));
end component;

component rom is
port(
addr: 		in std_logic_vector(6 downto 0);
read_en: 	in std_logic;
data_out: 	out std_logic_vector(7 downto 0));
end component;

component ram is
port(
reset: 		in std_logic;
clk: 		in std_logic;
write_en: 	in std_logic;
addr: 		in std_logic_vector(2 downto 0);
data_in: 	in std_logic_vector(3 downto 0);
data_out: 	out std_logic_vector(3 downto 0));
end component;

signal alu_status: 		std_logic_vector(2 downto 0);
signal alu_opcode: 		std_logic_vector(2 downto 0);
signal alu_result: 		std_logic_vector(3 downto 0);

signal ram_write_en: 	std_logic;
signal ram_data_out: 	std_logic_vector(3 downto 0);
signal sfrs_write_en: 	std_logic;
signal sfrs_data_out: 	std_logic_vector(3 downto 0);

signal pc_reg: 			std_logic_vector(6 downto 0) := (others => '0');
signal ir_reg: 			std_logic_vector(7 downto 0) := (others => '0');
signal a_reg: 			std_logic_vector(3 downto 0) := (others => '0');
signal scr_reg: 		std_logic_vector(3 downto 0) := (others => '0');
type high_ram_memory 	is array (0 to 3) of std_logic_vector(3 downto 0);
signal high_ram_data: 	high_ram_memory := (others => (others => '0'));

signal a_reg_bus: 		std_logic_vector(3 downto 0);
signal operand_bus: 	std_logic_vector(3 downto 0);
signal data_memory_bus: std_logic_vector(3 downto 0);

signal a_reg_write_en: 	std_logic;
signal scr_cf_set: 		std_logic;
signal scr_zf_set: 		std_logic;

begin

process(timing(1),reset)
begin
if(reset = '0') then
a_reg <= (others => '0');
pc_reg <= (others => '0');
elsif(rising_edge(timing(1))) then
if(ir_reg(7) = '1') then
pc_reg <= ir_reg(6 downto 0);
elsif(alu_status(0) = '1') then
pc_reg <= pc_reg + 2;
else pc_reg <= pc_reg + 1;
end if;
if(a_reg_write_en = '1') then
a_reg <= a_reg_bus;
end if;
end if;
end process;

sfrs: process(timing(1),reset)
begin
if(reset = '0') then
pid <= (others => '0');
pout <= (others => '0');
scr_reg <= (others => '0');
high_ram_data <= (others => (others => '0'));
elsif(rising_edge(timing(1))) then
if(sfrs_write_en = '1') then
case ir_reg(2 downto 0) is
when "111" => pid <= a_reg;
when "110" => null;
when "101" => pout <= a_reg;
when "100" => scr_reg <= a_reg;
when others => high_ram_data(conv_integer(ir_reg(1 downto 0))) <= a_reg;
end case;
end if;
if(scr_cf_set = '1') then
scr_reg(3) <= alu_status(2);
end if;
if(scr_zf_set = '1') then
scr_reg(2) <= alu_status(1);
end if;
end if;
end process;

sfrs_data_out <=
pid when ir_reg(2 downto 0) = "111" else 
pin when ir_reg(2 downto 0) = "110" else 
pout when ir_reg(2 downto 0) = "101" else
scr_reg when ir_reg(2 downto 0) = "100" else
high_ram_data(conv_integer(ir_reg(1 downto 0)));

alu_opcode <=
ir_reg(6 downto 4) when ir_reg(7 downto 6) = "01" else
'0' & ir_reg(3 downto 2) when ir_reg(7 downto 4) = "0000"
else "111";

ram_write_en <=
'1' when ir_reg(7 downto 4) = "0011" and
ir_reg(3) = '0'
else '0';

sfrs_write_en <=
'1' when ir_reg(7 downto 4) = "0011" and
ir_reg(3) = '1'
else '0';

a_reg_bus <=
operand_bus when ir_reg(7 downto 4) = "0010" or
ir_reg(7 downto 4) = "0001"
else alu_result;

a_reg_write_en <=
'0' when ir_reg(7 downto 2) = "000000" or
ir_reg(7 downto 2) = "000001" or
ir_reg(7 downto 4) = "0011" or
ir_reg(7) = '1'
else '1';

operand_bus <=	
ir_reg(3 downto 0) when ir_reg(7 downto 4) = "0000" or
ir_reg(7 downto 4) = "0001" else data_memory_bus;

scr_cf_set <=
'1' when ir_reg(7 downto 4) = "0100" or
ir_reg(7 downto 4) = "0101"
else '0';

scr_zf_set <=
'0' when ir_reg(7) = '1' or
ir_reg(7 downto 2) = "000000" or
ir_reg(7 downto 2) = "000001" or
ir_reg(7 downto 4) = "0001" or
ir_reg(7 downto 4) = "0011"
else '1';

data_memory_bus <=
ram_data_out when ir_reg(3) = '0'
else sfrs_data_out;

alu1: alu port map(
operand1 => a_reg,
operand2 => operand_bus,
opcode => alu_opcode,
result => alu_result,
status => alu_status);

ram1: ram port map(
reset => reset,
clk => timing(1),
write_en => ram_write_en,
addr => ir_reg(2 downto 0),
data_in => a_reg,
data_out => ram_data_out);

rom1: rom port map(
read_en => timing(0),
addr => pc_reg,
data_out => ir_reg);

end architecture;