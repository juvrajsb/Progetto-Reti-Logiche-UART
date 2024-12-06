library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TRANSMITTER is
    port(
        CLK_X16: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic_vector(7 downto 0);
        START: in std_logic;
        CTS: in std_logic;
        LEN: in std_logic;
        PARITY: in std_logic;
        TX: out std_logic;
        TX_AVAILABLE: out std_logic
    );
end TRANSMITTER;

architecture RTL of TRANSMITTER is
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
    
    component REG_PP is
        generic(
            REG_NUMBER: integer := 8
        );
        
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    component CLK_DIV_16 is
    port(
        CLK_X16: in std_logic;
        RST: in std_logic;
        CLK_X1: out std_logic
    );
    end component;
    
    component PAR_7 is
        port(
            DATA: in std_logic_vector(6 downto 0);
            ODD_MODE: in std_logic;
            PAR_BIT: out std_logic
        );
    end component;
    
    component REG_PS is
        generic(
            REG_NUMBER: integer := 8
        );
        
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            LOAD: in std_logic;
            D_OUT: out std_logic
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
            REF: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
            CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
        );
    end component;
    
    component TX_CONTROLLER is
        generic(
            COUNTER_BITS: integer := 4
        );
        
        port(
            CNT_STATE: in std_logic_vector(COUNTER_BITS - 1 downto 0);
            PS_REG_SHIFT_BIT: in std_logic;
            START: in std_logic;
            CTS: in std_logic;
            CNT_START: out std_logic;
            PS_REG_LOAD: out std_logic;
            BIT_TO_SEND: out std_logic;
            TX_AVAILABLE: out std_logic
        );
    end component;
    
    -- INPUT AND OUTPUT RELATED SIGNALS
    signal START_SAMPLE, CTS_SAMPLE, LEN_SAMPLE, PARITY_SAMPLE, TX_FF_INPUT, TX_AVAILABLE_FF_INPUT: std_logic;
    signal D_IN_SAMPLE: std_logic_vector(7 downto 0);
    
    -- INTERNAL SIGNALS
    signal CLK_X1, PAR_BIT, PS_REG_SHIFT_BIT, PS_REG_LOAD, CNT_START, CNT_ENABLE: std_logic;
    signal CNT_STATE: std_logic_vector(3 downto 0);
    signal PS_REG_DATA: std_logic_vector(8 downto 0);
begin
    -- INPUT AND OUTPUT REGISTERS
    D_IN_REG: REG_PP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        RST => RST,
        D_IN => D_IN,
        D_OUT => D_IN_SAMPLE
    );
    
    START_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => '0',
        RST => RST,
        D => START,
        Q => START_SAMPLE
    );
    
    CTS_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => '0',
        RST => RST,
        D => CTS,
        Q => CTS_SAMPLE
    );
    
    LEN_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => '0',
        RST => RST,
        D => LEN,
        Q => LEN_SAMPLE
    );
    
    PARITY_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => '0',
        RST => RST,
        D => PARITY,
        Q => PARITY_SAMPLE
    );
    
    TX_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => RST,
        RST => '0',
        D => TX_FF_INPUT,
        Q => TX
    );
    
    TX_AVAILABLE_FF: FF_D
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        SET => '0',
        RST => RST,
        D => TX_AVAILABLE_FF_INPUT,
        Q => TX_AVAILABLE
    );
    
    -- CLOCK DIVISION
    CLK_DIV: CLK_DIV_16
    port map(
        CLK_X16 => CLK_X16,
        RST => RST,
        CLK_X1 => CLK_X1
    );

    -- INPUT ELABORATION + SELECTION BASED ON LEN AND PARITY
    PARITY_CALC: PAR_7
    port map(
        DATA => D_IN_SAMPLE(6 downto 0),
        ODD_MODE => PARITY_SAMPLE,
        PAR_BIT => PAR_BIT
    );
    
    PS_REG_DATA <= (PAR_BIT & D_IN_SAMPLE(6 downto 0) & '0') when LEN_SAMPLE = '0' else
                   (D_IN_SAMPLE & '0'); -- '0' is added in both cases to avoid losing least significant bit during transmission
    
    -- SAVE ELABORATED INPUT
    REG: REG_PS
    generic map(
        REG_NUMBER => 9
    )
    port map(
        CLK => CLK_X16,
        EN => CLK_X1,
        RST => RST,
        D_IN => PS_REG_DATA,
        LOAD => PS_REG_LOAD,
        D_OUT => PS_REG_SHIFT_BIT
    );
    
    -- MANAGE TRASMISSION
    CNT_MOD_10: COUNTER
    generic map(
        REQUIRED_BITS => 4
    )
    port map(
        CLK => CLK_X16,
        EN => CNT_ENABLE,
        RST => RST,
        REF => "1001", -- Last number in counter sequence
        CNT => CNT_STATE
    );
    
    CNT_ENABLE <= CLK_X1 and CNT_START;
    
    CONTROLLER: TX_CONTROLLER
    generic map(
        COUNTER_BITS => 4
    )
    port map(
        CNT_STATE => CNT_STATE,
        PS_REG_SHIFT_BIT => PS_REG_SHIFT_BIT,
        START => START_SAMPLE,
        CTS => CTS_SAMPLE,
        CNT_START => CNT_START,
        PS_REG_LOAD => PS_REG_LOAD,
        BIT_TO_SEND => TX_FF_INPUT,
        TX_AVAILABLE => TX_AVAILABLE_FF_INPUT
    );
end RTL;
