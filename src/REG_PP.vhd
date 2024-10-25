library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_PP is
    generic(
        REG_NUMBER: integer := 8
    );
    
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic_vector(REG_NUMBER-1 downto 0);
        D_OUT: out std_logic_vector(REG_NUMBER-1 downto 0)
    );
end REG_PP;

architecture RTL of REG_PP is
begin
    process(CLK, RST) is
    begin
        if RST='1' then
            D_OUT <= (others => '0');
        elsif CLK'event and CLK='1' then
            if EN='1' then
                D_OUT <= D_IN;
            end if;
        end if;
    end process;
end RTL;
