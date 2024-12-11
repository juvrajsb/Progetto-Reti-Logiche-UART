library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TX_CONTROLLER is
    generic(
        COUNTER_BITS: integer := 4
    );
    
    port(
        CNT_STATE: in std_logic_vector(COUNTER_BITS - 1 downto 0);
        START: in std_logic;
        CTS: in std_logic;
        CNT_RUN: out std_logic;
        PS_REG_LOAD: out std_logic;
        TX_AVAILABLE: out std_logic
    );
end TX_CONTROLLER;

architecture RTL of TX_CONTROLLER is
begin
    CNT_RUN <= (START and CTS) when CNT_STATE = "0000" else
               '1';
    
    PS_REG_LOAD <= (START and CTS) when CNT_STATE = "0000" else
                   '0';
    
    TX_AVAILABLE <= '1' when ((CNT_STATE = "0000" and START = '0') or CNT_STATE = "1001") and CTS = '1' else
                    '0';
end RTL;

