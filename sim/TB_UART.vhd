library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.SIM_UTILS.ALL;

entity TB_UART is
    generic(
        constant CLK_PERIOD: time := 67.817 ns;
        constant CLK_PERIOD_B_TOLERANCE: percentage := 2.5;
        constant CLK_B_DELAY_ON_PERIOD: percentage := 50.0
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
    signal LEN, PARITY: std_logic;
    signal CLK_A, RST_A, START_A, TX_AVAILABLE_A, TX_A: std_logic;
    signal D_IN_A: std_logic_vector(7 downto 0);
    signal CLK_B, RST_B, READY_B, ERROR_B, STOP_RCV_B, RTS_B, RX_B: std_logic;
    signal D_OUT_B: std_logic_vector(7 downto 0);
    
    -- Aux signals
    signal SEND_BYTE_SOURCE: std_logic;
    signal ERROR_TEST: boolean;
begin
    -- Clock generators
    CLOCK_GENERATOR_A: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK_A
    );
    
    CLOCK_GENERATOR_B: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD * (1.0 + CLK_PERIOD_B_TOLERANCE / 100.0),
        CLK_START => CLK_PERIOD * (CLK_B_DELAY_ON_PERIOD / 100.0)
    )
    port map(
        CLK => CLK_B
    );
    
    -- UART instantiation
    UUT_A: UART
    port map(
        CLK => CLK_A,
        RST => RST_A,
        D_IN => D_IN_A,
        START => START_A,
        TX_AVAILABLE => TX_AVAILABLE_A,
        D_OUT => open,
        READY => open,
        ERROR => open,
        LEN => LEN,
        PARITY => PARITY,
        RTS => open,
        CTS => RTS_B,
        STOP_RCV => '0',
        TX => TX_A,
        RX => '1'
    );
    
    UUT_B: UART
    port map(
        CLK => CLK_B,
        RST => RST_B,
        D_IN => "00000000",
        START => '0',
        TX_AVAILABLE => open,
        D_OUT => D_OUT_B,
        READY => READY_B,
        ERROR => ERROR_B,
        LEN => LEN,
        PARITY => PARITY,
        RTS => RTS_B,
        CTS => '1',
        STOP_RCV => STOP_RCV_B,
        TX => open,
        RX => RX_B
    );
    
    -- Trasmission source selection
    RX_B <= SEND_BYTE_SOURCE when ERROR_TEST = true
            else TX_A;
    
    -- Test process
    SIM: process is
    begin
        -- Initial reset
        ERROR_TEST <= false;
        
        RST_A <= '1';
        RST_B <= '1';
        
        START_A <= '0';
        LEN <= '0';
        PARITY <= '0';
        D_IN_A <= "00000000";
        STOP_RCV_B <= '0';
        
        wait for CLK_PERIOD * 5;
        RST_A <= '0';
        RST_B <= '0';
        
        -- Test 1: 8N1
        LEN <= '1';
        PARITY <= '0';
        D_IN_A <= "10101111";
        STOP_RCV_B <= '0';
        
        wait until TX_AVAILABLE_A = '1';
        START_A <= '1';
        wait until TX_AVAILABLE_A = '0';
        START_A <= '0';
        
        wait until rising_edge(READY_B);
        
        -- Test 2: 7E1
        LEN <= '0';
        PARITY <= '0';
        D_IN_A <= "10101011";
        STOP_RCV_B <= '0';
        
        START_A <= '1';
        wait until TX_AVAILABLE_A = '0';
        START_A <= '0';
        
        wait until rising_edge(READY_B);
        
        -- Test 3: 7O1 + flow control activated during tranmission
        LEN <= '0';
        PARITY <= '1';
        D_IN_A <= "00101011";
        STOP_RCV_B <= '0';
        
        START_A <= '1';
        wait until TX_AVAILABLE_A = '0';
        START_A <= '0';
        
        wait for CLK_PERIOD * 16;
        STOP_RCV_B <= '1';
        
        wait until rising_edge(READY_B);
        
        -- Test 4: 7O1 + flow control activated before transmission and forced start
        LEN <= '0';
        PARITY <= '1';
        D_IN_A <= "00101011";
        STOP_RCV_B <= '1';
        
        START_A <= '1';
        wait for CLK_PERIOD * 16;
        START_A <= '0';
        
        wait for CLK_PERIOD;
        STOP_RCV_B <= '0';
        
        wait for (CLK_PERIOD * 16) * 10;
        
        -- TESTS WITH ERRORS
        ERROR_TEST <= true;
        
        -- Test 5: 8N1 with frame error
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "00000000",
            LEN => '1',
            PARITY => '0',
            BAD_STOP_BIT => true,
            BAD_PARITY => false,
            RX => SEND_BYTE_SOURCE
        );
        
        -- Test 6: 7E1 with parity error
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "00000000",
            LEN => '0',
            PARITY => '1',
            BAD_STOP_BIT => false,
            BAD_PARITY => true,
            RX => SEND_BYTE_SOURCE
        );
        
        wait;
    end process;
end BHV;
