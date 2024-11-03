library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_TRANSMITTER is
end TB_TRANSMITTER;

architecture BHV of TB_TRANSMITTER is
    constant CLK_PERIOD: time := 20 ns;

    component TRANSMITTER is
            port(
                CLK: in std_logic;
                EN: in std_logic;
                RST: in std_logic;
                D_IN: in std_logic_vector(7 downto 0);
                START: in std_logic;
                CTS: in std_logic;
                LEN: in std_logic;
                PARITY: in std_logic;
                TX: out std_logic
            );
    end component;
    
    signal CLK, EN, RST, START, CTS, LEN, PARITY, TX: std_logic;
    signal D_IN: std_logic_vector(7 downto 0);
begin
    UUT: TRANSMITTER
    port map(
        CLK => CLK,
        EN => EN,
        RST => RST,
        D_IN => D_IN,
        START => START,
        CTS => CTS,
        LEN => LEN,
        PARITY => PARITY,
        TX => TX
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
        -- RESET
        RST <= '1';
        wait for CLK_PERIOD * 5;
        
        -- TESTS
        EN <= '1';
        RST <= '0';
        D_IN <= "00000000";
        START <= '0';
        CTS <= '1';
        LEN <= '1';
        PARITY <= '0';

        wait for CLK_PERIOD;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "01000101";
        START <= '1';
        CTS <= '1';
        LEN <= '1';
        PARITY <= '1';
        wait for CLK_PERIOD * 9;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "01111001";
        START <= '1';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "01110001";
        START <= '1';
        CTS <= '0';
        LEN <= '0';
        PARITY <= '1';
        wait for CLK_PERIOD * 7;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "01110001";
        START <= '0';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '1';
        wait for CLK_PERIOD;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "01110001";
        START <= '1';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '1';
        wait for CLK_PERIOD;
        
        wait;
    end process;
end BHV;
