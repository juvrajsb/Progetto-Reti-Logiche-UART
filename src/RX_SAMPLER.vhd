library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RX_SAMPLER is
    port(
        CLK: in std_logic;
        RST: in std_logic;
        RX: in std_logic;
        SAMPLED_BIT: out std_logic;
        LOAD: out std_logic;
        FRAME_ERROR: out std_logic;
        RX_END: out std_logic
    );
end entity RX_SAMPLER;

architecture RTL of RX_SAMPLER is
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
    
    component COUNTER is
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
    end component;
    
    -- Internal signals
    signal CNT_RESTART, RX_FF1, RX_SYNC : std_logic;
    signal CNT : std_logic_vector(7 downto 0);
begin
    -- Input synchronization
    SYNC_FF1: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        SET => RST,
        RST => '0',
        D => RX,
        Q => RX_FF1
    );
    
    SYNC_FF2: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        SET => RST,
        RST => '0',
        D => RX_FF1,
        Q => RX_SYNC
    );
    
    -- Data sampling
    DELAY_FF_D: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        SET => RST,
        RST => '0',
        D => RX_SYNC,
        Q => SAMPLED_BIT
    );
    
    BIT_TIMER: COUNTER
    generic map(
        REQUIRED_BITS => 8
    )
    port map(
        CLK => CLK,
        EN => '1',
        RST => RST,
        RESTART => CNT_RESTART,
        MOD_PRED => "10011111", -- 159
        CNT => CNT
    );
    
    CNT_RESTART <= '1' when RX_SYNC = '1' and CNT(7 downto 3) = "00000" -- 0 to 7 
                   else '0';
    
    -- Outputs
    LOAD <= '1' when CNT = "00011001" -- 25
                or   CNT = "00101001" -- 41
                or   CNT = "00111001" -- 57
                or   CNT = "01001001" -- 73
                or   CNT = "01011001" -- 89
                or   CNT = "01101001" -- 105
                or   CNT = "01111001" -- 121
                or   CNT = "10001001" -- 137
            else '0';
    
    FRAME_ERROR <= '1' when CNT = "10011001" and RX_SYNC = '0' -- 153
                   else '0';
    
    RX_END <= '1' when CNT = "10011001" -- 153
              else '0';
end architecture RTL;
