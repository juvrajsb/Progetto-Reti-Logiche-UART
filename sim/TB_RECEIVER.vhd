library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_RECEIVER is
    generic(
        CLK_PERIOD: time := 10 ns
    );
end TB_RECEIVER;

architecture BHV of TB_RECEIVER is
    component RECEIVER is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            RX: in std_logic;
            PARITY: in std_logic;
            LEN: in std_logic;
            STOP_RCV: in std_logic;
            D_OUT: out std_logic_vector(7 downto 0);
            READY: out std_logic;
            ERROR: out std_logic;
            RTS: out std_logic
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
    
    -- Test signals
    signal CLK, RST, RX, PARITY, LEN, STOP_RCV: std_logic;
    signal D_OUT: std_logic_vector(7 downto 0);
    signal READY, ERROR, RTS: std_logic;
begin
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START => 0 ns
    )
    port map(
        CLK => CLK
    );
    
    UUT: RECEIVER
    port map(
        CLK => CLK,
        RST => RST,
        RX => RX,
        PARITY => PARITY,
        LEN => LEN,
        STOP_RCV => STOP_RCV,
        D_OUT => D_OUT,
        READY => READY,
        ERROR => ERROR,
        RTS => RTS
    );
    
    SIM: process is
        procedure SEND_BYTE(
            DATA: in std_logic_vector(7 downto 0);
            BAD_STOP_BIT: boolean;
            BAD_PARITY: boolean
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
    begin
        -- Initial setup
        RST <= '1';
        RX <= '1';
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        STOP_RCV <= '0';
        wait for CLK_PERIOD * 7.5;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Test Case 1: Valid 7-bit data with even parity
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE("01010101", false, false);
        wait for CLK_PERIOD * 16;
        
        -- Test Case 2: Frame error test
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE("01010101", true, false);  -- With bad stop bit
        wait for CLK_PERIOD * 16;
        
        -- Test Case 3: Parity error test
        LEN <= '0';     -- 7-bit mode
        PARITY <= '0';  -- Even parity
        SEND_BYTE("01010101", false, true);  -- With bad parity
        wait for CLK_PERIOD * 16;
        
        -- Test Case 4: Switch to 8-bit mode
        LEN <= '1';
        PARITY <= '0';
        wait for CLK_PERIOD * 16;
        SEND_BYTE("10101010", false, false);
        wait for CLK_PERIOD * 16;
        
        -- Test Case 5: Switch to 7-bit mode with odd parity
        LEN <= '0';     -- Back to 7-bit mode
        PARITY <= '1';  -- Odd parity
        wait for CLK_PERIOD * 16;
        SEND_BYTE("01010101", false, false);
        wait for CLK_PERIOD * 16;
        
        -- Test Case 6: Rapid transitions
        LEN <= '0';     -- 7-bit mode
        PARITY <= '1';  -- Odd parity
        SEND_BYTE("10101010", false, false);
        SEND_BYTE("01010101", false, false);  -- Back-to-back transmission
        wait for CLK_PERIOD * 16;
        
        wait;
    end process;
end BHV;
