library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_CLK_DIV_16 is
end TB_CLK_DIV_16;

architecture behavior of TB_CLK_DIV_16 is
    component CLK_DIV_16
        port(
            CLK    : in  std_logic;
            RST    : in  std_logic;
            CLK_DIV  : out std_logic
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    
    signal CLK    : std_logic := '0';
    signal RST    : std_logic := '0';
    signal CLK_DIV  : std_logic;
    
begin
    UUT: CLK_DIV_16
        port map (
            CLK    => CLK,
            RST    => RST,
            CLK_DIV  => CLK_DIV
        );

    CLK_PROCESS: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    STIM_PROC: process
    begin
        RST <= '1';
        wait for CLK_PERIOD*10;
        RST <= '0';
        
        wait for CLK_PERIOD*100;
        
        RST <= '1';
        wait for CLK_PERIOD*2;
        RST <= '0';
        
        wait for CLK_PERIOD*100;
        
        wait;
    end process;

end behavior;