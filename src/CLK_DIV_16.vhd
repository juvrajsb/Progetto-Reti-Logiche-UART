library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_DIV_16 is
    port(
        CLK_IN: in std_logic;
        RST: in std_logic;
        ENABLE: out std_logic
    );
end CLK_DIV_16;

architecture RTL of CLK_DIV_16 is
    component COUNTER is
        generic(
            REQUIRED_BITS: integer := 4
        );
        
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            RESTART: in std_logic;
            MOD_PRED: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
            CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
        );
    end component;
    
    signal CNT: std_logic_vector(3 downto 0);
begin
    CNT_MOD_16: COUNTER
    generic map(
        REQUIRED_BITS => 4
    )
    port map(
        CLK => CLK_IN,
        EN => '1',
        RST => RST,
        RESTART => '0',
        MOD_PRED => "1111",
        CNT => CNT
    );
    
    ENABLE <= '1' when CNT = "0001"
               else '0';
end RTL;
