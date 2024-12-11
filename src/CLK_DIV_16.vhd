library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_DIV_16 is
    port(
        CLK_IN: in std_logic;
        RST: in std_logic;
        CLK_OUT: out std_logic
    );
end CLK_DIV_16;

architecture RTL of CLK_DIV_16 is
    component FF_D is
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D: in std_logic;
            Q: out std_logic
        );
    end component;
    
    signal FLIP_FLOP_Q: std_logic_vector(0 to 3);  -- FF Output
    signal FLIP_FLOP_D: std_logic_vector(0 to 3);  -- FF Input
begin
    -- Generate slow clock
    FLIP_FLOP_D(0) <= not FLIP_FLOP_Q(0);
    FLIP_FLOP_D(1) <= not FLIP_FLOP_Q(1);
    FLIP_FLOP_D(2) <= not FLIP_FLOP_Q(2);
    FLIP_FLOP_D(3) <= not FLIP_FLOP_Q(3);
    
    FF0: FF_D port map(
        CLK => CLK_IN,
        EN => '1',
        SET => '0',
        RST => RST,
        D => FLIP_FLOP_D(0),
        Q => FLIP_FLOP_Q(0)
    );
    
    FF1: FF_D port map(
        CLK => FLIP_FLOP_Q(0),
        EN => '1',
        SET => '0',
        RST => RST,
        D => FLIP_FLOP_D(1),
        Q => FLIP_FLOP_Q(1)
    );
    
    FF2: FF_D port map(
        CLK => FLIP_FLOP_Q(1),
        EN => '1',
        SET => '0',
        RST => RST,
        D => FLIP_FLOP_D(2),
        Q => FLIP_FLOP_Q(2)
    );
    
    FF3: FF_D port map(
        CLK => FLIP_FLOP_Q(2),
        EN => '1',
        SET => '0',
        RST => RST,
        D => FLIP_FLOP_D(3),
        Q => FLIP_FLOP_Q(3)
    );
    
    CLK_OUT <= FLIP_FLOP_Q(3) and FLIP_FLOP_Q(2) and FLIP_FLOP_Q(1) and FLIP_FLOP_Q(0);
end RTL;