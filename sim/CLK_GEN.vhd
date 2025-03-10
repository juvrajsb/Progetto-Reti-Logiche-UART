library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_GEN is
    generic(
        CLK_PERIOD: time;
        CLK_START: time
    );
    
    port(
        CLK: out std_logic
    );
end CLK_GEN;

architecture BHV of CLK_GEN is
begin
    CLK_GEN: process is
    begin
        CLK <= '0';
        wait for CLK_START;
        
        loop
            CLK <= '1';
            wait for CLK_PERIOD / 2;
            
            CLK <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;
end BHV;
