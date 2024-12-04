library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_SP is
    generic(
        REG_NUMBER: integer := 8
    );
    
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic;
        LOAD: in std_logic;
        D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
    );
end REG_SP;

architecture RTL of REG_SP is
    signal STATE: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    process(CLK, RST) is
    begin
        if RST = '1' then
            STATE <= (others => '0');
        else
            if CLK'event and CLK = '1' then
                if EN = '1' then
                    if LOAD = '1' then
                        STATE <= D_IN & STATE(REG_NUMBER - 1 downto 1);
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    D_OUT <= STATE;
end RTL;
