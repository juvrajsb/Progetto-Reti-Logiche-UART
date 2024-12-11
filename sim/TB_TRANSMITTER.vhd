library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_TRANSMITTER is
    generic(
        CLK_PERIOD: time := 2 ns;
        START_DELAY: time := 2 ns
    );
end TB_TRANSMITTER;

architecture BHV of TB_TRANSMITTER is
    component TRANSMITTER is
            port(
                CLK: in std_logic;
                RST: in std_logic;
                D_IN: in std_logic_vector(7 downto 0);
                START: in std_logic;
                CTS: in std_logic;
                LEN: in std_logic;
                PARITY: in std_logic;
                TX: out std_logic;
                TX_AVAILABLE: out std_logic
            );
    end component;
    
    component CLK_GEN is
        generic(
            CLK_PERIOD: time
        );
        
        port(
            CLK: out std_logic
        );
    end component;
    
    signal CLK, RST, START, CTS, LEN, PARITY, TX, TX_AVAILABLE: std_logic;
    signal D_IN: std_logic_vector(7 downto 0);
begin
    UUT: TRANSMITTER
    port map(
        CLK => CLK,
        RST => RST,
        D_IN => D_IN,
        START => START,
        CTS => CTS,
        LEN => LEN,
        PARITY => PARITY,
        TX => TX,
        TX_AVAILABLE => TX_AVAILABLE
    );
    
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD
    )
    port map(
        CLK => CLK
    );
    
    SIM: process is
    begin
        -- RESET
        RST <= '1';
        D_IN <= "00000000";
        START <= '0';
        CTS <= '1';
        LEN <= '0';
        PARITY <= '0';
        wait for (CLK_PERIOD * 16) * 5;
        RST <= '0';
        
        -- UNATHORIZED START REJECTION TEST
        START <= '1';
        wait for (CLK_PERIOD * 16);
        START <= '0';
        
        -- SIMULATION WITH 8 BIT DATA
        wait for (CLK_PERIOD * 16) * 6;
        LEN <= '1';
        D_IN <= "01000101";
        
        wait for (CLK_PERIOD * 16) + START_DELAY;
        START <= '1';
        wait until TX_AVAILABLE = '0';
        wait for START_DELAY;
        START <= '0';
        
        -- SIMULATION WITH 7 BIT DATA + EVEN PARITY BIT
        D_IN <= "01110001";
        
        wait until TX_AVAILABLE = '1';
        LEN <= '0';
        PARITY <= '0';
        wait for START_DELAY;
        START <= '1';
        wait until TX_AVAILABLE = '0';
        wait for START_DELAY;
        START <= '0';
        
        -- SAME SIMULATION WITH ANTICIPATED START
        wait for (CLK_PERIOD * 16) * 6.5 - START_DELAY;
        START <= '1';
        wait for (CLK_PERIOD * 16) * 4;
        START <= '0';
        
        -- SIMULATION WITH 7 BIT DATA + ODD PARITY BIT + CTS OFF
        wait for (CLK_PERIOD * 16) * 0.5;
        D_IN <= "01110001";
        
        CTS <= '0';
        wait for (CLK_PERIOD * 16) * 30;
        CTS <= '1';
        
        wait until TX_AVAILABLE = '1';
        LEN <= '0';
        PARITY <= '1';
        wait for START_DELAY;
        START <= '1';
        wait until TX_AVAILABLE = '0';
        wait for START_DELAY;
        START <= '0';
        
        wait;
    end process;
end BHV;