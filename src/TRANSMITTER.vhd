library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TRANSMITTER is
    port(
        CLK_X16: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic_vector(7 downto 0);
        START: in std_logic;
        CTS: in std_logic;
        LEN: in std_logic;
        PARITY: in std_logic;
        TX: out std_logic;
        BUSY: out std_logic
    );
end TRANSMITTER;

architecture RTL of TRANSMITTER is
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
    
    component TX_FSM is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        PS_REG_SHIFT_BIT: in std_logic;
        START: in std_logic;
        CTS: in std_logic;
        PS_REG_LOAD: out std_logic;
        BIT_TO_SEND: out std_logic;
        BUSY: out std_logic
    );
end component;
    signal CLK_X1: std_logic;
    signal PAR_BIT: std_logic;
    signal PS_REG_DATA: std_logic_vector(7 downto 0);
    signal PS_REG_SHIFT_BIT: std_logic;
    signal PS_REG_LOAD: std_logic;
begin
    -- INPUT AND OUTPUT REGISTERS
    
    
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
        DATA => D_IN(6 downto 0),
        ODD_MODE => PARITY,
        PAR_BIT => PAR_BIT
    );
    
    PS_REG_DATA <= (PAR_BIT & D_IN(6 downto 0)) when LEN = '0' else
                   D_IN;
    
    -- SAVE ELABORATED INPUT
    REG: REG_PS
    port map(
        CLK => CLK_X1,
        EN => EN,
        RST => RST,
        D_IN => PS_REG_DATA,
        LOAD => PS_REG_LOAD,
        D_OUT => PS_REG_SHIFT_BIT
    );
    
    -- MANAGE TRASMISSION USING A FSM
    FSM: TX_FSM
    port map(
        CLK => CLK_X1,
        EN => EN,
        RST => RST,
        PS_REG_SHIFT_BIT => PS_REG_SHIFT_BIT,
        START => START,
        CTS => CTS,
        PS_REG_LOAD => PS_REG_LOAD,
        BIT_TO_SEND => TX,
        BUSY => BUSY
    );
end RTL;
