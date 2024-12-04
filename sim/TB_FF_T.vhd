library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FF_T is
end TB_FF_T;

architecture BHV of TB_FF_T is
    constant CLK_PERIOD: time := 10 ns;
    
    component FF_T is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            ASYNC_RST: in std_logic;
            SYNC_RST: in std_logic;
            T: in std_logic;
            Q: out std_logic
        );
    end component;
    
    signal CLK, EN, ASYNC_RST, SYNC_RST, T, Q: std_logic;
begin
    UUT: FF_T
    port map(
        CLK => CLK,
        EN => EN,
        ASYNC_RST => ASYNC_RST,
        SYNC_RST => SYNC_RST,
        T => T,
        Q => Q
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
        ASYNC_RST <= '1';
        wait for CLK_PERIOD * 9.4;
        
        EN <= '1';
        ASYNC_RST <= '0';
        SYNC_RST <= '0';
        T <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        ASYNC_RST <= '0';
        SYNC_RST <= '0';
        T <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '0';
        ASYNC_RST <= '0';
        SYNC_RST <= '0';
        T <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        ASYNC_RST <= '0';
        SYNC_RST <= '1';
        T <= '0';
        wait;
    end process;
end BHV;
