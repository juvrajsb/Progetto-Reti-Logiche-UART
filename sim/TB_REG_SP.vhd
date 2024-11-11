library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_SP is
end TB_REG_SP;

architecture BHV of TB_REG_SP is
    constant CLK_PERIOD: time := 20 ns;
    constant REG_NUMBER: integer := 8;
    
    component REG_SP is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            LOAD: in std_logic;
            D_IN: in std_logic;
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    signal CLK, EN, RST, LOAD, D_IN: std_logic;
    signal D_OUT: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    UUT: REG_SP
    port map(
        CLK => CLK,
        EN => EN,
        RST => RST,
        LOAD => LOAD,
        D_IN => D_IN,
        D_OUT => D_OUT
    );
    
    CLK_GEN: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    SIM: process is
    begin
        RST <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        LOAD <= '1';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '1';
        RST <= '0';
        LOAD <= '1';
        D_IN <= '0';
        wait for CLK_PERIOD;
        
        EN <= '1';
        RST <= '0';
        LOAD <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD;
        
        EN <= '0';
        RST <= '0';
        LOAD <= '1';
        D_IN <= '0';
        wait for CLK_PERIOD;
        
        EN <= '1';
        RST <= '0';
        LOAD <= '1';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '1';
        RST <= '0';
        LOAD <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '1';
        RST <= '0';
        LOAD <= '1';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        wait; 
    end process;
end BHV;
