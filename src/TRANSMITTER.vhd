library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TRANSMITTER is
    port(
        CLK: in std_logic;
        DIN: in std_logic_vector(7 downto 0);
        START: in std_logic;
        CTS: in std_logic;
        LEN: in std_logic;
        PARITY: in std_logic;
        TX: out std_logic
    );
end TRANSMITTER;

architecture RTL of TRANSMITTER is
    component PAR_7 is
        port(
            DATA: in std_logic_vector(6 downto 0);
            ODD_MODE: in std_logic;
            PAR_BIT: out std_logic
        );
    end component;
    
    signal PAR_BIT: std_logic;
    signal TX_DATA: std_logic_vector(7 downto 0);
begin
    PARITY_CALC: PAR_7
    port map(
        DATA => DIN(6 downto 0),
        ODD_MODE => PARITY,
        PAR_BIT => PAR_BIT
    );
    
    -- Input selection
    TX_DATA <= (PAR_BIT & DIN(6 downto 0)) when LEN='0' else
               DIN;
end RTL;
