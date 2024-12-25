library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART is
    port(
        -- System Interface
        CLK: in std_logic;
        RST: in std_logic;
        
        -- Data and Control
        D_IN: in std_logic_vector(7 downto 0);
        START: in std_logic;
        TX_AVAILABLE: out std_logic;
        D_OUT: out std_logic_vector(7 downto 0);
        READY: out std_logic;
        ERROR: out std_logic;
        
        -- Configuration
        LEN: in std_logic;     -- '0' for 7 bits, '1' for 8 bits
        PARITY: in std_logic;  -- '0' for even, '1' for odd
        
        -- Flow Control
        RTS: out std_logic;    -- Request to Send
        CTS: in std_logic;     -- Clear to Send
        STOP_RCV: in std_logic;
        
        -- Physical Interface
        TX: out std_logic;
        RX: in std_logic
    );
end UART;

architecture RTL of UART is
    -- Component declarations
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

begin
    -- Transmitter instantiation
    TX_UNIT: TRANSMITTER
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
    
    -- Receiver instantiation
    RX_UNIT: RECEIVER
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
    
end RTL;