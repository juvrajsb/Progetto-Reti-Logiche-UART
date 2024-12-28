library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_PS is
    generic(
        REG_NUMBER: integer := 8
    );
    
    port(
        CLK: in std_logic;
        EN: in std_logic;
        SET: in std_logic;
        RST: in std_logic;
        D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
        LOAD: in std_logic;
        SHIFT_BIT: in std_logic;
        D_OUT: out std_logic
    );
end REG_PS;

architecture RTL of REG_PS is
    signal STATE: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            if SET = '1' then
                STATE <= (others => '1');
            elsif RST = '1' then
                STATE <= (others => '0');
            elsif EN = '1' then
                if LOAD = '1' then
                    STATE <= D_IN;
                else
                    -- Right shift
                    STATE <= SHIFT_BIT & STATE(REG_NUMBER - 1 downto 1);
                end if;
            end if;
        end if;
    end process;
    
    D_OUT <= STATE(0);
end RTL;
