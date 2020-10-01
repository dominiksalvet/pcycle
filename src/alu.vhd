library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
port(
opcode: 	in std_logic_vector(2 downto 0);
operand1: 	in std_logic_vector(3 downto 0);
operand2: 	in std_logic_vector(3 downto 0);		-- bitove operace - adresa bitu operand2(1 downto 0)
result: 	buffer std_logic_vector(3 downto 0);
status: 	out std_logic_vector(2 downto 0));		-- CF - status(2), ZF - status(1), SKIP - status(0)
end alu;

architecture behavioral of alu is

signal cf_auxiliary: std_logic_vector(4 downto 0);

begin

result <= 
operand1(3 downto 1) & '1' when opcode = "010" and operand2(1 downto 0) = "00" else
operand1(3 downto 2) & '1' & operand1(0) when opcode = "010" and operand2(1 downto 0) = "01" else
operand1(3) & '1' & operand1(1 downto 0) when opcode = "010" and operand2(1 downto 0) = "10" else
'1' & operand1(2 downto 0) when opcode = "010" and operand2(1 downto 0) = "11" else
operand1(3 downto 1) & '0' when opcode = "011" and operand2(1 downto 0) = "00" else
operand1(3 downto 2) & '0' & operand1(0) when opcode = "011" and operand2(1 downto 0) = "01" else
operand1(3) & '0' & operand1(1 downto 0) when opcode = "011" and operand2(1 downto 0) = "10" else
'0' & operand1(2 downto 0) when opcode = "011" and operand2(1 downto 0) = "11" else
cf_auxiliary(3 downto 0) when opcode = "100" else
cf_auxiliary(3 downto 0) when opcode = "101" else
operand1 xor operand2 when opcode = "110"
else operand1 nand operand2;

cf_auxiliary <=
('0' & operand1) + ('0' & operand2) when opcode = "100"
else ('0' & operand1) - ('0' & operand2);

status(2) <= cf_auxiliary(4);

status(1) <= not (result(0) or result(1) or result(2) or result(3));

status(0) <= 
operand1(conv_integer(operand2(1 downto 0))) when opcode = "000" else
not operand1(conv_integer(operand2(1 downto 0))) when opcode = "001" else '0';

end behavioral;