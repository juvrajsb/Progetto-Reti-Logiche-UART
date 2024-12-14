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
        D_OUT: out std_logic
    );
end REG_PS;

architecture RTL of REG_PS is
    component FF_D is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        SET: in std_logic;
        RST: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
    end component;
    
    signal STATE: std_logic_vector(REG_NUMBER - 1 downto 0);
    signal INPUTS: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    INPUTS(REG_NUMBER - 1) <= '1' when LOAD = '0'
                              else D_IN(REG_NUMBER - 1);
    
    FF_D_GEN: for I in REG_NUMBER - 1 downto 0 generate
        FF: FF_D
        port map (
            CLK => CLK,
            EN => EN,
            SET => SET,
            RST => RST,
            D => INPUTS(I),
            Q => STATE(I)
        );
    end generate;
    
    SIG_GEN: for I in REG_NUMBER - 2 downto 0 generate
        INPUTS(I) <= STATE(I+1) when LOAD = '0' else
                     D_IN(I);
    end generate;
    
    D_OUT <= STATE(0);
end RTL;
