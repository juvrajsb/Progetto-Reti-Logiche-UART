library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TRANSMITTER is
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
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    component CLK_DIV_16 is
    port(
        CLK_IN: in std_logic;
        RST: in std_logic;
        CLK_OUT: out std_logic
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
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            LOAD: in std_logic;
            SHIFT_BIT: in std_logic;
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
            RESTART: in std_logic;
            MOD_PRED: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
            CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
        );
    end component;
    
    component TX_CONTROLLER is
        generic(
            COUNTER_BITS: integer := 4
        );
        
        port(
            CNT_STATE: in std_logic_vector(COUNTER_BITS - 1 downto 0);
            START: in std_logic;
            CTS: in std_logic;
            CNT_RUN: out std_logic;
            REG_PS_LOAD: out std_logic;
            TX_AVAILABLE: out std_logic
        );
    end component;
    
    -- INPUT AND OUTPUT RELATED SIGNALS
    signal START_FF_INPUT, START_SAMPLE, CTS_SAMPLE, LEN_SAMPLE, PARITY_SAMPLE, TX_AVAILABLE_FF_INPUT, TX_AVAILABLE_FF_OUT: std_logic;
    signal D_IN_SAMPLE: std_logic_vector(7 downto 0);
    
    -- INTERNAL SIGNALS
    signal CLK_EN, PAR_BIT, MS_BIT, REG_PS_LOAD, CNT_RUN, CNT_ENABLE: std_logic;
    signal CNT_STATE: std_logic_vector(3 downto 0);
    signal REG_PS_DATA: std_logic_vector(8 downto 0);
begin
    -- INPUT AND OUTPUT REGISTERS
    D_IN_REG: REG_PP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D_IN => D_IN,
        D_OUT => D_IN_SAMPLE
    );
    
    START_FF: FF_D
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D => START_FF_INPUT,
        Q => START_SAMPLE
    );
    
    CTS_FF: FF_D
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D => CTS,
        Q => CTS_SAMPLE
    );
    
    LEN_FF: FF_D
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D => LEN,
        Q => LEN_SAMPLE
    );
    
    PARITY_FF: FF_D
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D => PARITY,
        Q => PARITY_SAMPLE
    );
    
    TX_AVAILABLE_FF: FF_D
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => '0',
        RST => RST,
        D => TX_AVAILABLE_FF_INPUT,
        Q => TX_AVAILABLE_FF_OUT
    );
    
    -- CLOCK DIVISION
    CLK_DIV: CLK_DIV_16
    port map(
        CLK_IN => CLK,
        RST => RST,
        CLK_OUT => CLK_EN
    );

    -- INPUT ELABORATION + SELECTION BASED ON LEN AND PARITY
    PARITY_CALC: PAR_7
    port map(
        DATA => D_IN_SAMPLE(6 downto 0),
        ODD_MODE => PARITY_SAMPLE,
        PAR_BIT => PAR_BIT
    );
    
    MS_BIT <= PAR_BIT when LEN_SAMPLE = '0'
              else D_IN_SAMPLE(7);
    REG_PS_DATA <= MS_BIT & D_IN_SAMPLE(6 downto 0) & '0'; -- '0' is added as start bit
    
    -- MANAGE TRASMISSION
    SHIFT_REG: REG_PS
    generic map(
        REG_NUMBER => 9
    )
    port map(
        CLK => CLK,
        EN => CLK_EN,
        SET => RST,
        RST => '0',
        D_IN => REG_PS_DATA,
        LOAD => REG_PS_LOAD,
        SHIFT_BIT => '1',
        D_OUT => TX
    );
    
    CNT_MOD_10: COUNTER
    generic map(
        REQUIRED_BITS => 4
    )
    port map(
        CLK => CLK,
        EN => CNT_ENABLE,
        RST => RST,
        RESTART => '0',
        MOD_PRED => "1001", -- Last number in counter sequence
        CNT => CNT_STATE
    );
    
    CONTROLLER: TX_CONTROLLER
    generic map(
        COUNTER_BITS => 4
    )
    port map(
        CNT_STATE => CNT_STATE,
        START => START_SAMPLE,
        CTS => CTS_SAMPLE,
        CNT_RUN => CNT_RUN,
        REG_PS_LOAD => REG_PS_LOAD,
        TX_AVAILABLE => TX_AVAILABLE_FF_INPUT
    );
    
    CNT_ENABLE <= CLK_EN and CNT_RUN;
    START_FF_INPUT <= START and TX_AVAILABLE_FF_OUT;
    TX_AVAILABLE <= TX_AVAILABLE_FF_OUT;
end RTL;
