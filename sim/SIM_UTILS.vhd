library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package SIM_UTILS is
    subtype percentage is real range 0.0 to 100.0;
    
    procedure SEND_BYTE(
        CLK_PERIOD: in time;
        DATA: in std_logic_vector(7 downto 0);
        LEN: in std_logic;
        PARITY: in std_logic;
        BAD_STOP_BIT: in boolean;
        BAD_PARITY: in boolean;
        signal RX: out std_logic
    );
end package SIM_UTILS;

package body SIM_UTILS is
    procedure SEND_BYTE(
        CLK_PERIOD: in time;
        DATA: in std_logic_vector(7 downto 0);
        LEN: in std_logic;
        PARITY: in std_logic;
        BAD_STOP_BIT: in boolean;
        BAD_PARITY: in boolean;
        signal RX: out std_logic
    ) is
        variable PARITY_BIT: std_logic;
    begin
        -- Calculate parity (for 7-bit mode)
        PARITY_BIT := DATA(0) xor DATA(1) xor DATA(2) xor DATA(3) xor DATA(4) xor DATA(5) xor DATA(6);
        
        if PARITY = '1' then  -- Odd parity
            PARITY_BIT := not PARITY_BIT;
        end if;
        if BAD_PARITY = true then
            PARITY_BIT := not PARITY_BIT;
        end if;
        
        -- Start bit
        RX <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Data bits
        for I in 0 to 7 loop
            if I < 7 then
                RX <= DATA(I); -- Send data bit
            elsif I = 7 then
                if LEN = '1' then
                    RX <= DATA(I);
                else
                    RX <= PARITY_BIT; -- Send parity bit in 7-bit mode
                end if;
            end if;
            wait for CLK_PERIOD * 16;
        end loop;
        
        -- Stop bit
        if BAD_STOP_BIT = true then
            RX <= '0'; -- Bad stop bit
        else
            RX <= '1'; -- Good stop bit
        end if;
        wait for CLK_PERIOD * 16;
        
        -- Return to idle
        RX <= '1';
        wait for CLK_PERIOD * 16;
    end procedure;
end package body SIM_UTILS;
