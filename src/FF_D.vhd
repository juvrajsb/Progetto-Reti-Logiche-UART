library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_D is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end FF_D;

architecture RTL of FF_D is
begin
    process(CLK, RST) is
    begin
        if RST = '1' then
            Q <= '0';
        else
            if CLK'event and CLK = '1' then
                if EN = '1' then
                    Q <= D;
                end if;
            end if;
        end if;
    end process;
end RTL;
