library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_JK is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        J: in std_logic;
        K: in std_logic;
        Q: out std_logic
    );
end FF_JK;

architecture RTL of FF_JK is
    signal STATE: std_logic;
begin
    process(CLK, RST) is
    begin
        if RST = '1' then
            STATE <= '0';
        elsif CLK'event and CLK = '1' then
            if EN = '1' then
                if J = '0' and K = '0' then
                    STATE <= STATE;
                elsif J = '0' and K = '1' then
                    STATE <= '0';
                elsif J = '1' and K = '0' then
                    STATE <= '1';
                elsif J = '1' and K = '1' then
                    STATE <= not STATE;
                end if;
            end if;
        end if;
    end process;
    
    Q <= STATE;
end RTL;
