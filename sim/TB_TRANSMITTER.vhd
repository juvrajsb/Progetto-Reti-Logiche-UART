library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_TRANSMITTER is
end TB_TRANSMITTER;

architecture BHV of TB_TRANSMITTER is
    constant CLK_PERIOD: time := 1 ns;

    component TRANSMITTER is
            port(
                CLK_X16: in std_logic;
                RST: in std_logic;
                D_IN: in std_logic_vector(7 downto 0);
                START: in std_logic;
                CTS: in std_logic;
                LEN: in std_logic;
                PARITY: in std_logic;
                TX: out std_logic;
                BUSY: out std_logic
            );
    end component;
    
    signal CLK_X16, RST, START, CTS, LEN, PARITY, TX, BUSY: std_logic;
    signal D_IN: std_logic_vector(7 downto 0);
begin
    UUT: TRANSMITTER
    port map(
        CLK_X16 => CLK_X16,
        RST => RST,
        D_IN => D_IN,
        START => START,
        CTS => CTS,
        LEN => LEN,
        PARITY => PARITY,
        TX => TX,
        BUSY => BUSY
    );
    
    CLK_GEN: process is
    begin
        CLK_X16 <= '0';
        wait for CLK_PERIOD / 2;
        
        CLK_X16 <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    SIM: process is
    begin
        -- RESET
        RST <= '1';
        wait for (CLK_PERIOD * 16) * 5;
        
        -- TESTS
        RST <= '0';
        D_IN <= "00000000";
        START <= '0';
        CTS <= '1';
        LEN <= '1';
        PARITY <= '0';

        wait for (CLK_PERIOD * 16);
        
        RST <= '0';
        D_IN <= "01000101";
        START <= '1';
        CTS <= '1';
        LEN <= '1';
        PARITY <= '1';
        wait for(CLK_PERIOD * 16) * 9;
        
        RST <= '0';
        D_IN <= "01111001";
        START <= '1';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '0';
        wait for (CLK_PERIOD * 16) * 5;
        
        RST <= '0';
        D_IN <= "01110001";
        START <= '1';
        CTS <= '0';
        LEN <= '0';
        PARITY <= '1';
        wait for (CLK_PERIOD * 16) * 7;
        
        RST <= '0';
        D_IN <= "01110001";
        START <= '0';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '1';
        wait for (CLK_PERIOD * 16);
        
        RST <= '0';
        D_IN <= "01110001";
        START <= '1';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '1';
        wait for (CLK_PERIOD * 16);
        
        wait;
    end process;
end BHV;
