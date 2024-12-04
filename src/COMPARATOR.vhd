library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COMPARATOR is
    generic(
        LENGTH: integer := 4
    );
    
    port(
        INPUT_1: in std_logic_vector(LENGTH - 1 downto 0);
        INPUT_2: in std_logic_vector(LENGTH - 1 downto 0);
        EQUAL: out std_logic
    );
end COMPARATOR;

architecture RTL of COMPARATOR is
    signal BIT_EQUALITY: std_logic_vector(LENGTH - 1 downto 0);
    signal TEMP_AND: std_logic_vector(LENGTH - 1 downto 0);
begin
    XOR_GEN: for I in 0 to LENGTH - 1 generate
        BIT_EQUALITY(I) <= not(INPUT_1(I) xor INPUT_2(I));
    end generate;
    
    TEMP_AND(0) <= BIT_EQUALITY(0);
    AND_GEN: for I in 1 to LENGTH - 1 generate
        TEMP_AND(I) <= TEMP_AND(I - 1) and BIT_EQUALITY(I);
    end generate;
    EQUAL <= TEMP_AND(LENGTH - 1);
end RTL;
