library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_PAR_7 is
end TB_PAR_7;

architecture BHV of TB_PAR_7 is
    component PAR_7 is
        port(
            DATA: in std_logic_vector(6 downto 0);
            ODD_MODE: in std_logic;
            PAR_BIT: out std_logic
        );
    end component;
    
    signal DATA: std_logic_vector(6 downto 0);
    signal ODD_MODE, PAR_BIT: std_logic;
begin
    UUT: PAR_7
    port map(
        DATA => DATA,
        ODD_MODE => ODD_MODE,
        PAR_BIT => PAR_BIT
    );
    
    SIM: process is
    begin
        -- Even parity
        ODD_MODE <= '0';
        
        DATA <= "0000000";
        wait for 20 ns;
        
        DATA <= "0010000";
        wait for 20 ns;
        
        DATA <= "0010100";
        wait for 20 ns;
        
        DATA <= "1100100";
        wait for 20 ns;
        
        DATA <= "1111111";
        wait for 20 ns;
        
        wait for 100 ns;
        
        -- Odd parity
        ODD_MODE <= '1';
        
        DATA <= "0000000";
        wait for 20 ns;
        
        DATA <= "0010000";
        wait for 20 ns;
        
        DATA <= "0010100";
        wait for 20 ns;
        
        DATA <= "1100100";
        wait for 20 ns;
        
        DATA <= "1111111";
        wait for 20 ns;
        
        wait;
    end process;
end BHV;
