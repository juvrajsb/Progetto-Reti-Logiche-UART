library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_UART is
    generic(
        CLK_PERIOD: time := 20 ns
    );
end TB_UART;

architecture BHV of TB_UART is
    component UART is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(7 downto 0);
            START: in std_logic;
            TX_AVAILABLE: out std_logic;
            D_OUT: out std_logic_vector(7 downto 0);
            READY: out std_logic;
            ERROR: out std_logic;
            LEN: in std_logic;
            PARITY: in std_logic;
            RTS: out std_logic;
            CTS: in std_logic;
            STOP_RCV: in std_logic;
            TX: out std_logic;
            RX: in std_logic
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

    -- Test signals
    signal CLK, RST: std_logic;
    signal D_IN, D_OUT: std_logic_vector(7 downto 0);
    signal START, TX_AVAILABLE: std_logic;
    signal READY, ERROR: std_logic;
    signal LEN, PARITY: std_logic;
    signal RTS, CTS, STOP_RCV: std_logic;
    signal SERIAL_LINE: std_logic := '1';  -- Initialize to idle state

begin
    -- Clock generator
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK
    );

    -- UART instantiation
    UUT: UART
    port map(
        CLK => CLK,
        RST => RST,
        D_IN => D_IN,
        START => START,
        TX_AVAILABLE => TX_AVAILABLE,
        D_OUT => D_OUT,
        READY => READY,
        ERROR => ERROR,
        LEN => LEN,
        PARITY => PARITY,
        RTS => RTS,
        CTS => CTS,
        STOP_RCV => STOP_RCV,
        TX => SERIAL_LINE,
        RX => SERIAL_LINE
    );

    -- Test process
    SIM: process is
    begin
        report "Starting UART Test";
        
        -- Initial Setup
        RST <= '1';
        START <= '0';
        D_IN <= "00000000";
        CTS <= '1';
        LEN <= '1';       -- 8-bit mode
        PARITY <= '0';    -- Even parity
        STOP_RCV <= '0';
        wait for CLK_PERIOD * 5;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Test 1: Basic Data Transmission
        report "Test 1: Starting Basic Transmission";
        D_IN <= "10101111";
        wait for CLK_PERIOD;
        START <= '1';
        wait until TX_AVAILABLE = '0';
        START <= '0';
        
        wait until READY = '1';
        assert (D_OUT = "10101111") 
            report "Test 1: Data mismatch";
            
        wait for CLK_PERIOD * 16;
        
        -- Test 2: Flow Control Test
        report "Test 2: Testing Flow Control";
        STOP_RCV <= '1';
        wait for CLK_PERIOD * 2;
        assert (RTS = '0') 
            report "Test 2: RTS not deasserted";
            
        -- Test 3: Different Data Pattern
        report "Test 3: Testing Different Data Pattern";
        STOP_RCV <= '0';
        wait for CLK_PERIOD * 16;
        
        D_IN <= "11110100";
        wait for CLK_PERIOD;
        START <= '1';
        wait until TX_AVAILABLE = '0';
        START <= '0';
        
        wait until READY = '1';
        assert (D_OUT = "11110100") 
            report "Test 3: Data mismatch";
        
        wait for CLK_PERIOD * 16;
        report "UART Test Complete";
        wait;
    end process;

end BHV;