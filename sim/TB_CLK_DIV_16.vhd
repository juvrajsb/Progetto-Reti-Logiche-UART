library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_CLK_DIV_16 is
    generic(
        CLK_PERIOD: time := 10 ns
    );
end TB_CLK_DIV_16;

architecture BHV of TB_CLK_DIV_16 is
    component CLK_DIV_16
        port(
            CLK_IN: in std_logic;
            RST: in std_logic;
            CLK_OUT: out std_logic
        );
    end component;
    
    component CLK_GEN is
        generic(
            CLK_PERIOD: time;
            CLK_START: time
        );
        
        port(
            CLK: out std_logic
        );
    end component;
    
    signal CLK_IN, RST, CLK_OUT: std_logic;
    signal CLK_ENABLE: std_logic;
begin
    UUT: CLK_DIV_16
        port map (
            CLK_IN => CLK_IN,
            RST => RST,
            CLK_OUT => CLK_OUT
        );
    
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK_IN
    );
    
    SIM: process
    begin
        RST <= '1';
        wait for CLK_PERIOD * 7.5;
        
        RST <= '0';
        wait for CLK_PERIOD * 100;
        
        RST <= '1';
        wait for CLK_PERIOD * 2;
        
        RST <= '0';
        wait;
    end process;
    
    CLK_ENABLE <= CLK_IN and CLK_OUT;
end BHV;