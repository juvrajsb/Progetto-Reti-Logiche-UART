library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_SP is
    generic(
        CLK_PERIOD: time := 20 ns
    );
end TB_REG_SP;

architecture BHV of TB_REG_SP is
    constant REG_NUMBER: integer := 8;
    
    component REG_SP is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic;
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;
    
    component CLK_GEN is
        generic(
            CLK_PERIOD: time;
            CLK_START: time
        );
        
        port(
            CLK: out std_logic
        );
    end component;
    
    signal CLK, EN, SET, RST, D_IN: std_logic;
    signal D_OUT: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    UUT: REG_SP
    port map(
        CLK => CLK,
        EN => EN,
        SET => SET,
        RST => RST,
        D_IN => D_IN,
        D_OUT => D_OUT
    );
    
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK
    );
    
    SIM: process is
    begin
        SET <= '1';
        RST <= '0';
        wait for CLK_PERIOD * 5.5;
        
        SET <= '0';
        RST <= '1';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '1';
        RST <= '0';
        D_IN <= '0';
        wait for CLK_PERIOD;
        
        EN <= '0';
        SET <= '0';
        RST <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D_IN <= '0';
        wait for CLK_PERIOD;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '0';
        SET <= '0';
        RST <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        D_IN <= '1';
        wait for CLK_PERIOD; 
        
        wait; 
    end process;
end BHV;
