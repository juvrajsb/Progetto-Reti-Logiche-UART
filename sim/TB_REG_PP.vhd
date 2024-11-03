library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_PP is
end TB_REG_PP;

architecture BHV of TB_REG_PP is
    constant CLK_PERIOD: time := 10 ns;
    constant REG_NUMBER: integer := 8;
    
    component REG_PP is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    signal CLK, EN, RST: std_logic;
    signal D_IN, D_OUT: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    UUT: REG_PP
    port map(
        CLK => CLK,
        EN => EN,
        RST => RST,
        D_IN => D_IN,
        D_OUT => D_OUT
    );
    
    CLK_GEN: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    SIM: process is
    begin
        RST <= '1';
        wait for CLK_PERIOD * 10;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "10000011";
        wait for CLK_PERIOD * 8;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "10000000";
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '0';
        D_IN <= "11111111";
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        RST <= '1';
        D_IN <= "11111111";
        wait for CLK_PERIOD * 5;
        
        EN <= '0';
        RST <= '0';
        D_IN <= "10000000";
        wait;
    end process;
end BHV;
