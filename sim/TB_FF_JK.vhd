library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FF_JK is
    generic(
        CLK_PERIOD: time := 10 ns
    );
end TB_FF_JK;

architecture BHV of TB_FF_JK is
    component FF_JK is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            J: in std_logic;
            K: in std_logic;
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
    
    signal CLK, EN, RST, J, K, Q: std_logic;
begin
    UUT: FF_JK
    port map(
        CLK => CLK,
        EN => EN,
        RST => RST,
        J => J,
        K => K,
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
        RST <= '1';
        wait for CLK_PERIOD * 9.4;
        
        EN <= '1';
        RST <= '0';
        J <= '1';
        K <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        J <= '1';
        K <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        J <= '1';
        K <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        J <= '0';
        K <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        J <= '1';
        K <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '0';
        RST <= '0';
        J <= '1';
        K <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '1';
        J <= '1';
        K <= '0';
        wait;
    end process;
end BHV;
