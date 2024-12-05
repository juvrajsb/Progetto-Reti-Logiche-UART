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
    
    signal J_SIGNALS, K_SIGNALS: std_logic_vector(REQUIRED_BITS downto 0);
    signal STATE: std_logic_vector(REQUIRED_BITS - 1 downto 0);
    signal RESTART_COUNT: std_logic;
begin
    J_SIGNALS(0) <= '1';
    K_SIGNALS(0) <= '1';
    
    FF_T_GEN: for I in 0 to REQUIRED_BITS - 1 generate
        FF: FF_JK
        port map(
            CLK => CLK,
            EN => EN,
            RST => RST,
            J => J_SIGNALS(I),
            K => K_SIGNALS(I),
            Q => STATE(I)
        );
        
        -- Act as a fast counter built with T flip flops yet reset all the counters to '0' when REF is reached
        J_SIGNALS(I+1) <= (STATE(I) and J_SIGNALS(I) and K_SIGNALS(I)) when RESTART_COUNT = '0' else
                          '0';
        K_SIGNALS(I+1) <= (STATE(I) and J_SIGNALS(I) and K_SIGNALS(I)) when RESTART_COUNT = '0' else
                          '1';
    end generate;
    
    REF_COMPARATOR: COMPARATOR
    generic map(
        LENGTH => REQUIRED_BITS
    )
    port map(
        INPUT_1 => STATE,
        INPUT_2 => REF,
        EQUAL => RESTART_COUNT
    );
    
    CNT <= STATE;
end RTL;
