library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_PS is
end TB_REG_PS;

architecture BHV of TB_REG_PS is
    constant CLK_PERIOD: time := 1 ns;
    constant REG_NUMBER: integer := 8;
    
    component REG_PS is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            LOAD: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER-1 downto 0);
            D_OUT: out std_logic
        );
    end component;
    
    signal CLK, RST, LOAD, D_OUT: std_logic;
    signal D_IN: std_logic_vector(REG_NUMBER-1 downto 0);
begin
    UUT: REG_PS
    port map(
        CLK => CLK,
        RST => RST,
        LOAD => LOAD,
        D_IN => D_IN,
        D_OUT => D_OUT
    );
    
    CLK_GEN: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    SIM: process is
    begin
        wait for CLK_PERIOD * 2.3;
        RST <= '1';
        
        wait for CLK_PERIOD * 5;
        RST <= '0';
        LOAD <= '1';
        D_IN <= "10101010";
        
        wait for CLK_PERIOD * 5; 
        LOAD <= '0';
        
        wait for CLK_PERIOD * REG_NUMBER;
        RST <= '0';
        LOAD <= '1';
        D_IN <= "11111111";
        
        wait for CLK_PERIOD * 5;
        LOAD <= '0';
        
        wait for CLK_PERIOD * REG_NUMBER;
        RST <= '1';
        
        wait;
    end process;
end BHV;
