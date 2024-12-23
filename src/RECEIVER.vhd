library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RECEIVER is
    port(
        CLK: in std_logic;
        RST: in std_logic;
        RX: in std_logic;
        PARITY: in std_logic; -- '0' for even parity, '1' for odd parity
        LEN: in std_logic; -- '0' for 7 bits, '1' for 8 bits
        STOP_RCV: in std_logic; -- Stop receiving
        D_OUT: out std_logic_vector(7 downto 0);
        READY: out std_logic; -- Data ready flag
        ERROR: out std_logic; -- Combined error flag
        RTS: out std_logic -- Request to send
    );
end RECEIVER;

architecture RTL of RECEIVER is
    component RX_SAMPLER is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            RX: in std_logic;
            SAMPLED_BIT: out std_logic;
            LOAD: out std_logic;
            FRAME_ERROR: out std_logic;
            RX_END: out std_logic
        );
    end component;
    
    component REG_SP is
        generic(
            REG_NUMBER: integer := 8
        );
        
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic;
            LOAD: in std_logic;
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    component REG_PP is
        generic(
            REG_NUMBER: integer := 8
        );
        
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    component PAR_7 is
        port(
            DATA: in std_logic_vector(6 downto 0);
            ODD_MODE: in std_logic;
            PAR_BIT: out std_logic
        );
    end component;
    
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
    
    -- Input and output signals
    signal LEN_SAMPLE, PARITY_SAMPLE, STOP_RCV_SAMPLE, READY_FF_INPUT, ERROR_FF_INPUT, RTS_FF_INPUT: std_logic;
    
    -- Internal signals
    signal SAMPLED_BIT, REG_SP_LOAD, RX_END, FRAME_ERROR, CALCULATED_PARITY, PARITY_ERROR, PARITY_CHECK_ENABLE: std_logic;
    signal REG_SP_DATA: std_logic_vector(7 downto 0);
begin
    -- Input and output registers
    LEN_FF: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        RST => RST,
        SET => '0',
        D => LEN,
        Q => LEN_SAMPLE
    );
    
    PARITY_FF: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        RST => RST,
        SET => '0',
        D => PARITY,
        Q => PARITY_SAMPLE
    );
    
    STOP_RCV_FF: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        RST => '0',
        SET => RST,
        D => STOP_RCV,
        Q => STOP_RCV_SAMPLE
    );
    
    D_OUT_REG: REG_PP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK,
        EN => RX_END,
        SET => '0',
        RST => RST,
        D_IN => REG_SP_DATA,
        D_OUT => D_OUT
    );
    
    READY_FF: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        RST => RST,
        SET => '0',
        D => READY_FF_INPUT,
        Q => READY
    );
    
    ERROR_FF: FF_D
    port map(
        CLK => CLK,
        EN => RX_END,
        RST => RST,
        SET => '0',
        D => ERROR_FF_INPUT,
        Q => ERROR
    );
    
    RTS_FF: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        RST => RST,
        SET => '0',
        D => RTS_FF_INPUT,
        Q => RTS
    );
    
    -- STOP_RCV / RTS management
    RTS_FF_INPUT <= not STOP_RCV_SAMPLE;
    
    -- Sampling and data output
    SAMPLER: RX_SAMPLER
    port map(
        CLK => CLK,
        RST => RST,
        RX => RX,
        SAMPLED_BIT => SAMPLED_BIT,
        LOAD => REG_SP_LOAD,
        FRAME_ERROR => FRAME_ERROR,
        RX_END => RX_END
    );
    
    SHIFT_REG: REG_SP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK,
        EN => '1',
        SET => '0',
        RST => RST,
        D_IN => SAMPLED_BIT,
        LOAD => REG_SP_LOAD,
        D_OUT => REG_SP_DATA
    );
    
    PARITY_CALC: PAR_7
    port map(
        DATA => REG_SP_DATA(6 downto 0),
        ODD_MODE => PARITY_SAMPLE,
        PAR_BIT => CALCULATED_PARITY
    );
    
    PARITY_ERROR <= (CALCULATED_PARITY xor REG_SP_DATA(7)) when LEN = '0'
                    else '0';
    ERROR_FF_INPUT <= FRAME_ERROR or PARITY_ERROR;
    READY_FF_INPUT <= RX_END;
end RTL;
