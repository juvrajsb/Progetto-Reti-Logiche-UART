library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.SIM_UTILS.ALL;

entity TB_RECEIVER is
    generic(
        CLK_PERIOD: time := 10 ns
    );
end TB_RECEIVER;

architecture BHV of TB_RECEIVER is
    component RECEIVER is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            RX: in std_logic;
            PARITY: in std_logic;
            LEN: in std_logic;
            STOP_RCV: in std_logic;
            D_OUT: out std_logic_vector(7 downto 0);
            READY: out std_logic;
            ERROR: out std_logic;
            RTS: out std_logic
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
    signal CLK, RST, RX, PARITY, LEN, STOP_RCV: std_logic;
    signal D_OUT: std_logic_vector(7 downto 0);
    signal READY, ERROR, RTS: std_logic;
begin
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK
    );
    
    UUT: RECEIVER
    port map(
        CLK => CLK,
        RST => RST,
        RX => RX,
        PARITY => PARITY,
        LEN => LEN,
        STOP_RCV => STOP_RCV,
        D_OUT => D_OUT,
        READY => READY,
        ERROR => ERROR,
        RTS => RTS
    );
    
    SIM: process is
    begin
        -- Initial setup
        RST <= '1';
        RX <= '1';
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        STOP_RCV <= '0';
        wait for CLK_PERIOD * 7.5;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Test Case 1: Valid 7-bit data with even parity
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "01010101",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 2: Frame error test
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "01010101",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => true,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 3: Parity error test
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "01010101",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => true,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 4: Switch to 8-bit mode
        LEN <= '1';
        PARITY <= '0';
        wait for CLK_PERIOD * 16;
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "10101010",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 5: Switch to 7-bit mode with odd parity
        LEN <= '0';     -- Back to 7-bit mode
        PARITY <= '1';  -- Odd parity
        wait for CLK_PERIOD * 16;
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "01010101",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 6: Rapid transitions
        LEN <= '0';     -- 7-bit mode
        PARITY <= '1';  -- Odd parity
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "10101010",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => "01010101",
            LEN => LEN,
            PARITY => PARITY,
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        wait;
    end process;
end BHV;
