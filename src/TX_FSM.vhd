library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity TX_FSM is
    port(
        CLK: in std_logic;
        EN: in std_logic;
        RST: in std_logic;
        PS_REG_SHIFT_BIT: in std_logic;
        START: in std_logic;
        CTS: in std_logic;
        PS_REG_LOAD: out std_logic;
        BIT_TO_SEND: out std_logic
    );
end TX_FSM;

architecture RTL of TX_FSM is
    signal Q: std_logic_vector(3 downto 0); -- Keeps track of FSM's state
begin
    UPDATE_STATE: process(CLK, RST) is
    begin
        if RST='1' then
            Q <= (others => '0');
        elsif CLK'event and CLK='1' then
            if EN='1' then
                if Q="0000" then
                    if START='1' and CTS='1' then
                        Q <= "0001";
                    end if;
                elsif Q/="1001" then
                    -- Q+1 without using arithmetical operators
                    Q(0) <= not Q(0);
                    Q(1) <= Q(1) xor Q(0);
                    Q(2) <= Q(2) xor (Q(1) and Q(0));
                    Q(3) <= Q(3) xor (Q(2) and Q(1) and Q(0));
                else
                    Q <= "0000";
                end if;
            end if;
        end if;
    end process;
    
    -- OUTPUTS ASSIGNMENT
    PS_REG_LOAD <= '1' when Q="0000" else
                   '0';
    
    BIT_TO_SEND <= '1' when Q="0000" else
                   '0' when Q="0001" else
                   PS_REG_SHIFT_BIT;
end RTL;
