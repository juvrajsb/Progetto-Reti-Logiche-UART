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
            data: in std_logic_vector(7 downto 0);
            bad_stop_bit: in std_logic := '0'; 
            bad_parity: in std_logic := '0'
        ) is
            variable parity_bit: std_logic;
        begin
            -- Calculate parity (for 7-bit mode)
            parity_bit := data(0) xor data(1) xor data(2) xor data(3) xor 
                         data(4) xor data(5) xor data(6);
            if PARITY = '1' then  -- Odd parity
                parity_bit := not parity_bit;
            end if;
            if bad_parity = '1' then
                parity_bit := not parity_bit;
            end if;
            
            -- Start bit
            RX <= '0';
            wait for CLK_PERIOD * 16;
            
            -- Data bits
            for i in 0 to 7 loop
                if LEN = '0' and i = 7 then
                    RX <= parity_bit;  -- Send parity bit in 7-bit mode
                else
                    RX <= data(i);     -- Send data bit
                end if;
                wait for CLK_PERIOD * 16;
            end loop;
            
            -- Stop bit
            if bad_stop_bit = '1' then
                RX <= '0';  -- Bad stop bit
            else
                RX <= '1';  -- Good stop bit
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
        PARITY <= '0';  -- Even parity
        LEN <= '0';     -- 7-bit mode
        STOP_RCV <= '0';
        wait for CLK_PERIOD * 7.5;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Test Case 1: Valid 7-bit data with even parity
        SEND_BYTE("01010101", '0', '0');
        wait for CLK_PERIOD * 16;
        
        -- Test Case 2: Frame error test
        SEND_BYTE("01010101", '1', '0');  -- With bad stop bit
        wait for CLK_PERIOD * 16;
        
        -- Test Case 3: Parity error test
        SEND_BYTE("01010101", '0', '1');  -- With bad parity
        wait for CLK_PERIOD * 16;
        
        -- Test Case 4: Switch to 8-bit mode
        LEN <= '1';
        wait for CLK_PERIOD * 16;
        SEND_BYTE("10101010", '0', '0');
        wait for CLK_PERIOD * 16;
        
        -- Test Case 5: Test STOP_RCV
        STOP_RCV <= '1';
        wait for CLK_PERIOD * 32;
        SEND_BYTE("11110000", '0', '0');
        wait for CLK_PERIOD * 16;
        STOP_RCV <= '0';
        
        -- Test Case 6: Switch to odd parity
        LEN <= '0';     -- Back to 7-bit mode
        PARITY <= '1';  -- Odd parity
        wait for CLK_PERIOD * 16;
        SEND_BYTE("01010101", '0', '0');
        wait for CLK_PERIOD * 16;
        
        -- Test Case 7: Rapid transitions
        SEND_BYTE("10101010", '0', '0');
        SEND_BYTE("01010101", '0', '0');  -- Back-to-back transmission
        wait for CLK_PERIOD * 16;
        
        -- Test Case 8: Reset during transmission
        SEND_BYTE("11110000", '0', '0');
        wait for CLK_PERIOD * 8;  -- Reset mid-transmission
        RST <= '1';
        wait for CLK_PERIOD * 16;
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        wait;
    end process;
end BHV;