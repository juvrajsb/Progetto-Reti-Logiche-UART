library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_COMPARATOR is
end TB_COMPARATOR;

architecture BHV of TB_COMPARATOR is
    constant LENGTH: integer := 4;

    component COMPARATOR is
        port(
            INPUT_1: in std_logic_vector(LENGTH - 1 downto 0);
            INPUT_2: in std_logic_vector(LENGTH - 1 downto 0);
            EQUAL: out std_logic
        );
    end component;
    
    signal INPUT_1, INPUT_2: std_logic_vector(LENGTH - 1 downto 0);
    signal EQUAL: std_logic;
begin
    UUT: COMPARATOR
    port map(
        INPUT_1 => INPUT_1,
        INPUT_2 => INPUT_2,
        EQUAL => EQUAL
    );
    
    SIM: process is
    begin
        INPUT_1 <= "1010";
        INPUT_2 <= "1010";
        wait for 100 ns;
        
        INPUT_1 <= "1011";
        INPUT_2 <= "1010";
        wait for 100 ns;
        
        INPUT_1 <= "1100";
        INPUT_2 <= "1100";
        wait for 100 ns;
        
        wait;
    end process;
end BHV;
