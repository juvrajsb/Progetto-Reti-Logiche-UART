library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_COUNTER is
    generic(
        CLK_PERIOD: time := 20ns
    );
end TB_COUNTER;

architecture BHV of TB_COUNTER is
    constant REQUIRED_BITS: integer := 4;

    component COUNTER is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            REF: in std_logic_vector(REQUIRED_BITS - 1 downto 0);
            CNT: out std_logic_vector(REQUIRED_BITS - 1 downto 0)
        );
    end component;
    
    component CLK_GEN is
        generic(
            CLK_PERIOD: time
        );
        
        port(
            CLK: out std_logic
        );
    end component;
    
    signal CLK, EN, RST: std_logic;
    signal REF, CNT: std_logic_vector(REQUIRED_BITS - 1 downto 0);
begin
    UUT: COUNTER
    port map(
        CLK => CLK,
        EN => EN,
        RST => RST,
        REF => REF,
        CNT => CNT
    );
    
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD
    )
    port map(
        CLK => CLK
    );
    
    SIM: process is
    begin       
        RST <= '1';
        wait for CLK_PERIOD * 10;
        
        RST <= '0';
        EN <= '1';
        REF <= "1001";
        wait for CLK_PERIOD * 5;
        
        RST <= '0';
        EN <= '0';
        REF <= "1001";
        wait for CLK_PERIOD;
        
        RST <= '0';
        EN <= '1';
        REF <= "1001";
        wait;
    end process;
end BHV;
