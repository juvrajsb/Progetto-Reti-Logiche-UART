library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TX_CONTROLLER is
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
end TX_CONTROLLER;

architecture RTL of TX_CONTROLLER is
begin
    CNT_START <= (START and CTS) when CNT_STATE = "0000" else
                  '1';
    
    PS_REG_LOAD <= '1' when CNT_STATE = "0000" else
                   '0';
    
    BIT_TO_SEND <= '1' when CNT_STATE = "0000" else
                   '0' when CNT_STATE = "0001" else
                   PS_REG_SHIFT_BIT;
    
    TX_AVAILABLE <= '1' when ((CNT_STATE = "0000" and START = '0') or CNT_STATE = "1001") and CTS = '1' else
                    '0';
end RTL;

