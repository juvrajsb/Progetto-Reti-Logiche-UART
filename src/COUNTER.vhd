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
        RESTART: in std_logic;
        MOD_PRED: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
        CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
    );
end COUNTER;

architecture RTL of COUNTER is
    component FF_D is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D: in std_logic;
            Q: out std_logic
        );
    end component;
    
    signal RESTART_COUNT, CNT_END: std_logic;
    signal T_SIGNALS, D_SIGNALS, STATE: std_logic_vector(REQUIRED_BITS - 1 downto 0);
begin
    -- Act as a fast counter built with T flip flops yet reset all the counters to '0' when MOD_PRED is reached
    FF_D_GEN: for I in 0 to REQUIRED_BITS - 1 generate
        FF: FF_D
        port map(
            CLK => CLK,
            EN => EN,
            RST => RST,
            SET => '0',
            D => D_SIGNALS(I),
            Q => STATE(I)
        );
    end generate;
    
    T_SIGNALS(0) <= '1';
    D_SIGNALS(0) <= '0' when RESTART_COUNT = '1'
                    else not STATE(0);
    
    SIG_GEN: for I in 1 to REQUIRED_BITS - 1 generate
        T_SIGNALS(I) <= STATE(I - 1) and T_SIGNALS(I - 1);
        D_SIGNALS(I) <= '0' when RESTART_COUNT = '1'
                        else STATE(I) xor T_SIGNALS(I);
    end generate;
    
    CNT_END <= '1' when STATE = MOD_PRED
               else '0';
    RESTART_COUNT <= CNT_END or RESTART;
    
    CNT <= STATE;
end RTL;
