library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.SIM_UTILS.ALL;

entity TB_RX_SAMPLER is
    generic(
        CLK_PERIOD: time := 10 ns  -- For 16x oversampling
    );
end TB_RX_SAMPLER;

architecture BHV of TB_RX_SAMPLER is
    component RX_SAMPLER is
        port(
            CLK: in std_logic;
            RST: in std_logic;
            RX: in std_logic;
            SAMPLED_BIT: out std_logic;
            LOAD: out std_logic;
            FRAME_ERROR: out std_logic;
            RX_END: out std_logic
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
    signal CLK, RST, RX, SAMPLED_BIT, LOAD, FRAME_ERROR, RX_END: std_logic;
begin
    -- Clock generator instantiation
    CLOCK_GENERATOR: CLK_GEN
    generic map(
        CLK_PERIOD => CLK_PERIOD,
        CLK_START  => 0 ns
    )
    port map(
        CLK => CLK
    );
    
    -- Device Under Test instantiation
    UUT: RX_SAMPLER
    port map(
        CLK => CLK,
        RST => RST,
        RX => RX,
        SAMPLED_BIT => SAMPLED_BIT,
        LOAD => LOAD,
        FRAME_ERROR => FRAME_ERROR,
        RX_END => RX_END
    );
    
    -- Test stimulus process
    SIM: process is
        -- Test data constants
        constant TEST_BYTE1 : std_logic_vector(7 downto 0) := "10110101";
        constant TEST_BYTE2 : std_logic_vector(7 downto 0) := "11000011";
    begin
        -- Initial reset
        RST <= '1';
        RX <= '1';
        wait for CLK_PERIOD * 16;
        wait until rising_edge(CLK);
        RST <= '0';
        wait for CLK_PERIOD * 16;
        
        -- Test Case 1: Single byte transmission
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => TEST_BYTE1,
            LEN => '1',
            PARITY => '0',
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 2: Back-to-back bytes
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => TEST_BYTE1,
            LEN => '1',
            PARITY => '0',
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => TEST_BYTE2,
            LEN => '1',
            PARITY => '0',
            BAD_STOP_BIT => false,
            BAD_PARITY => false,
            RX => RX
        );
        wait for CLK_PERIOD * 16;
        
        -- Test Case 3: Test with noise
        RX <= '0';  -- Start bit
        wait for CLK_PERIOD * 16/4;
        RX <= '1';  -- Noise pulse
        wait for CLK_PERIOD * 16/4;
        
        -- Test case 4: Test with frame error
        SEND_BYTE(
            CLK_PERIOD => CLK_PERIOD,
            DATA => TEST_BYTE2,
            LEN => '1',
            PARITY => '0',
            BAD_STOP_BIT => true,
            BAD_PARITY => false,
            RX => RX
        );
        
        wait;
    end process;
end BHV;
