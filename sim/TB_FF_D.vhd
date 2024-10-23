library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FF_D is
end TB_FF_D;

architecture BHV of TB_FF_D is
    constant CLK_PERIOD: time := 1 ns;
    
    component FF_D is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            D: in std_logic;
            Q: out std_logic
        );
    end component;
    
    signal CLK, RST, D, Q: std_logic;
begin
    UUT: FF_D
    port map(
        D => D,
        CLK => CLK,
        RST => RST,
        Q => Q
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
        wait for CLK_PERIOD * 9.4;
        RST <= '0';
        
        wait for CLK_PERIOD * 20;
        D <= '0';
        
        wait for CLK_PERIOD * 5;
        D <= '1';
        
        wait for CLK_PERIOD * 5;
        RST <= '1';
        
        wait;
    end process;
end BHV;
