library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RECEIVER is
    port(
        CLK: in std_logic;
        RST: in std_logic;
        RX: in std_logic;
        PARITY: in std_logic;    -- '0' for even parity, '1' for odd parity
        LEN: in std_logic;       -- '0' for 7 bits, '1' for 8 bits
        STOP_RCV: in std_logic;  -- Stop receiving
        D_OUT: out std_logic_vector(7 downto 0);
        READY: out std_logic;    -- Data ready flag
        ERROR: out std_logic;    -- Combined error flag
        RTS: out std_logic      -- Request to send
    );
end RECEIVER;

architecture RTL of RECEIVER is
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

    component REG_SP is
        generic(
            REG_NUMBER: integer := 8
        );
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic;
            LOAD: in std_logic;
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;

    component REG_PP is
        generic(
            REG_NUMBER: integer := 8
        );
        port(
            CLK: in std_logic;
            EN: in std_logic;
            SET: in std_logic;
            RST: in std_logic;
            D_IN: in std_logic_vector(REG_NUMBER - 1 downto 0);
            D_OUT: out std_logic_vector(REG_NUMBER - 1 downto 0)
        );
    end component;

    component PAR_7 is
        port(
            DATA: in std_logic_vector(6 downto 0);
            ODD_MODE: in std_logic;
            PAR_BIT: out std_logic
        );
    end component;

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

    signal SAMPLED_BIT, LOAD_BIT, RX_END, FRAME_ERROR: std_logic;
    signal SP_DATA: std_logic_vector(7 downto 0);
    signal CALCULATED_PARITY: std_logic;
    signal PARITY_ERROR, PARITY_CHECK_ENABLE: std_logic;
    signal RX_SYNC: std_logic;

begin
    INPUT_SYNC: FF_D
    port map(
        CLK => CLK,
        EN => '1',
        SET => '0',
        RST => RST,
        D => RX,
        Q => RX_SYNC
    );

    SAMPLER: RX_SAMPLER
    port map(
        CLK => CLK,
        RST => RST,
        RX => RX_SYNC,
        SAMPLED_BIT => SAMPLED_BIT,
        LOAD => LOAD_BIT,
        FRAME_ERROR => FRAME_ERROR,
        RX_END => RX_END
    );

    SHIFT_REG: REG_SP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK,
        EN => '1',
        SET => '0',
        RST => RST,
        D_IN => SAMPLED_BIT,
        LOAD => LOAD_BIT,
        D_OUT => SP_DATA
    );

    OUTPUT_REG: REG_PP
    generic map(
        REG_NUMBER => 8
    )
    port map(
        CLK => CLK,
        EN => RX_END,
        SET => '0',
        RST => RST,
        D_IN => SP_DATA,
        D_OUT => D_OUT
    );

    PARITY_CALC: PAR_7
    port map(
        DATA => SP_DATA(6 downto 0),
        ODD_MODE => PARITY,
        PAR_BIT => CALCULATED_PARITY
    );

    -- Error detection and control logic
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                ERROR <= '0';
                READY <= '0';
                RTS <= '0';
            else
                -- Parity error detection
                PARITY_ERROR <= (CALCULATED_PARITY xnor SP_DATA(7)) and (not LEN);
                
                -- Combined error flag
                ERROR <= FRAME_ERROR or PARITY_ERROR;
                
                -- Data ready flag
                READY <= RX_END;-- and not ERROR; -- We could uncomment depeding on the user
                
                -- Request to send
                RTS <= not STOP_RCV;
            end if;
        end if;
    end process;

end RTL;