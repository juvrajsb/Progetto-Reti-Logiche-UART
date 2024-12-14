library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FF_D is
    generic(
        CLK_PERIOD: time := 10 ns
    );
end TB_FF_D;

architecture BHV of TB_FF_D is
    component FF_D is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D: in std_logic;
            Q: out std_logic
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
    
    signal CLK, EN, SET, RST, D, Q: std_logic;
begin
    UUT: FF_D
    port map(
        CLK => CLK,
        EN => EN,
        SET => SET,
        RST => RST,
        D => D,
        Q => Q
    );
    
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK
    );
    
    SIM: process is
    begin
        SET <= '1';
        RST <= '0';
        wait for CLK_PERIOD * 5;
        
        SET <= '0';
        RST <= '1';
        wait for CLK_PERIOD * 9.5;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '0';
        SET <= '0';
        RST <= '0';
        D <= '0';
        wait for CLK_PERIOD * 5;
        
        SET <= '0';
        RST <= '1';
        wait;
    end process;
end BHV;
