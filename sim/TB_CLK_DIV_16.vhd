library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_CLK_DIV_16 is
end TB_CLK_DIV_16;

architecture BHV of TB_CLK_DIV_16 is
    component CLK_DIV_16
        port(
            CLK_X16: in std_logic;
            RST: in std_logic;
            CLK_X1: out std_logic
        );
    end component;

    constant CLK_PERIOD: time := 10 ns;
    
    signal CLK_X16: std_logic;
    signal RST: std_logic;
    signal CLK_X1: std_logic;
begin
    UUT: CLK_DIV_16
        port map (
            CLK_X16 => CLK_X16,
            RST => RST,
            CLK_X1 => CLK_X1
        );

    CLK_PROCESS: process
    begin
        CLK_X16 <= '0';
        wait for CLK_PERIOD / 2;
        
        CLK_X16 <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    STIM_PROC: process
    begin
        RST <= '1';
        wait for CLK_PERIOD * 10;
        
        RST <= '0';
        wait for CLK_PERIOD * 100;
        
        RST <= '1';
        wait for CLK_PERIOD * 2;
        
        RST <= '0';
        wait;
    end process;
end BHV;