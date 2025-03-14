library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_PS is
    generic(
        CLK_PERIOD: time := 20 ns
    );
end TB_REG_PS;

architecture BHV of TB_REG_PS is
    constant REG_NUMBER: integer := 8;
    
    component REG_PS is
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
    
    signal CLK, EN, SET, RST, LOAD, SHIFT_BIT, D_OUT: std_logic;
    signal D_IN: std_logic_vector(REG_NUMBER - 1 downto 0);
begin
    UUT: REG_PS
    port map(
        CLK => CLK,
        EN => EN,
        SET => SET,
        RST => RST,
        D_IN => D_IN,
        LOAD => LOAD,
        SHIFT_BIT => SHIFT_BIT,
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
        SHIFT_BIT <= '1';
        
        SET <= '0';
        RST <= '1';
        wait for CLK_PERIOD * 5.5;
        
        SET <= '1';
        RST <= '0';
        wait for CLK_PERIOD * 5;
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        LOAD <= '1';
        D_IN <= "01010100";
        wait for CLK_PERIOD; 
        
        EN <= '1';
        SET <= '0';
        RST <= '0';
        LOAD <= '0';
        D_IN <= "01010100";
        wait;
    end process;
end BHV;
