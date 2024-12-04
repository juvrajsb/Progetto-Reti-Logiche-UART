library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_T is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        ASYNC_RST: in std_logic;
        SYNC_RST: in std_logic;
        T: in std_logic;
        Q: out std_logic
    );
end FF_T;

architecture RTL of FF_T is
    signal STATE: std_logic;
begin
    process(CLK, ASYNC_RST) is
    begin
        if ASYNC_RST = '1' then
            STATE <= '0';
        elsif CLK'event and CLK = '1' then
            if EN = '1' then
                if SYNC_RST = '1' then
                    STATE <= '0';
                else
                    if T = '1' then
                        STATE <= not STATE;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    Q <= STATE;
end RTL;
