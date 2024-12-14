library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_D is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        SET: in std_logic;
        RST: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end FF_D;

architecture RTL of FF_D is
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            if SET = '1' then
                Q <= '1';
            elsif RST = '1' then
                Q <= '0';
            elsif EN = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end RTL;
