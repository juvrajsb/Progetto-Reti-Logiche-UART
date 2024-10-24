library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PAR_7 is
    port(
        DATA: in std_logic_vector(6 downto 0);
        ODD_MODE: in std_logic;
        PAR_BIT: out std_logic
    );
end PAR_7;

architecture RTL of PAR_7 is
    signal TEMP_1_1, TEMP_1_2, TEMP_1_3, TEMP_2_1, TEMP_2_2: std_logic;
begin
    -- XOR between couple of bits to calculate the parity bit (even mode)
    TEMP_1_1 <= DATA(0) xor DATA(1);
    TEMP_1_2 <= DATA(2) xor DATA(3);
    TEMP_1_3 <= DATA(4) xor DATA(5);
    -- TEMP_1_4 not needed: use directly DATA(6)
    
    TEMP_2_1 <= TEMP_1_1 xor TEMP_1_2;
    TEMP_2_2 <= TEMP_1_3 xor DATA(6);
    
    -- Invert the result if ODD_MODE is on
    PAR_BIT <= (TEMP_2_1 xor TEMP_2_2) xor ODD_MODE;
end RTL;
