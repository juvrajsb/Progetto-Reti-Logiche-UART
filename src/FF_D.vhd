library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_D is
    port(
        CLK: in std_logic;
        RST: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end FF_D;

architecture BHV of FF_D is
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            -- Syncronous reset
            if RST='1' then
                Q <= '0';
            else
                Q <= D;
            end if;
        end if;
    end process;
end BHV;
