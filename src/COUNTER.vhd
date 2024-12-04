library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COUNTER is
    generic(
        REQUIRED_BITS: integer := 4
    );
    
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        REF: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
        CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
    );
end COUNTER;

architecture RTL of COUNTER is
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
    
    component COMPARATOR is
        generic(
            LENGTH: integer := 8
        );
        
        port(
            INPUT_1: in std_logic_vector(LENGTH - 1 downto 0);
            INPUT_2: in std_logic_vector(LENGTH - 1 downto 0);
            EQUAL: out std_logic
        );
    end component;
    
    signal TRIGGER_SIGNALS: std_logic_vector(REQUIRED_BITS downto 0);
    signal STATE: std_logic_vector(REQUIRED_BITS - 1 downto 0);
    signal SYNC_RST: std_logic;
begin
    TRIGGER_SIGNALS(0) <= '1';
    
    FF_T_GEN: for I in 0 to REQUIRED_BITS - 1 generate
        FF: FF_T
        port map(
            CLK => CLK,
            EN => EN,
            ASYNC_RST => RST,
            SYNC_RST => SYNC_RST,
            T => TRIGGER_SIGNALS(I),
            Q => STATE(I)
        );
        
        TRIGGER_SIGNALS(I+1) <= STATE(I) and TRIGGER_SIGNALS(I);
    end generate;
    
    REF_COMPARATOR: COMPARATOR
    generic map(
        LENGTH => REQUIRED_BITS
    )
    port map(
        INPUT_1 => STATE,
        INPUT_2 => REF,
        EQUAL => SYNC_RST
    );
    
    CNT <= STATE;
end RTL;
