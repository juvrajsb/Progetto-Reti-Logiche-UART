library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_PS is
    generic(
        REG_NUMBER: integer := 8
    );
    
    port(
        CLK: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic_vector(REG_NUMBER-1 downto 0);
        LOAD: in std_logic;
        D_OUT: out std_logic
    );
end REG_PS;

architecture BHV of REG_PS is
    -- Q signal keeps track of the registers' state
    signal Q: std_logic_vector(REG_NUMBER-1 downto 0);
begin
    process(CLK) is
    begin
        if CLK'event and CLK='1' then
            -- Syncronous reset
            if RST='1' then
                Q <= (others => '0');
            else
                if LOAD='1' then
                    Q <= D_IN;
                else
                    -- Right shift
                    Q <= '0' & Q(REG_NUMBER-1 downto 1);
                end if;
            end if;
        end if;
    end process;
    
    D_OUT <= Q(0);
end BHV;
