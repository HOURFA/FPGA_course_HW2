library IEEE;
use ieee.std_logic_1164.all;
package constant_def is
    constant target_speed    : STD_LOGIC_VECTOR (6 downto 0) := "1100100" ;     --100
    constant speed_th_75     : STD_LOGIC_VECTOR (6 downto 0) := "1001011" ;
    constant speed_th_105    : STD_LOGIC_VECTOR (6 downto 0) := "1101001" ;
    constant speed_th_95     : STD_LOGIC_VECTOR (6 downto 0) := "1011111" ;
    constant max_speed       : integer := 10;
    constant sec_speed       : integer := 7;
    constant mid_speed       : integer := 5;
    constant min_speed       : integer := 3;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.constant_def.all;

entity stepper_motor is
    Port ( clk      : in STD_LOGIC;
           rst      : in STD_LOGIC;
           en       : in STD_LOGIC;
           pwm      : out STD_LOGIC;
           out_sig  : inout STD_LOGIC_VECTOR (6 downto 0));
end stepper_motor;



architecture Behavioral of stepper_motor is

type speed_control_FSM is (high_speed,speedup,speeddown,steady,idle);
signal FSM                  : speed_control_FSM;
signal cnt1_en,cnt2_en      : std_logic;
signal cnt1,cnt2            : integer;
signal cnt1_max, cnt2_max   : integer; 

begin
out_process  : process(rst,clk,cnt1_en,cnt2_en)
begin
    pwm <= cnt1_en;
    if rst = '1' then
        out_sig <= (others => '0');
    else
        if rising_edge(clk) then
            if cnt1_en = '1' then
                out_sig <= out_sig + '1';
            elsif cnt2_en = '1' then
                out_sig <= out_sig - '1';
            end if;
        end if;
    end if;
end process;

FSM_process  : process(en,rst,out_sig,FSM)
begin
    if rst = '1' then
        FSM <= idle;
    else
        case FSM is
            when idle           =>
                if en = '1' then
                    FSM <= high_speed;
                else
                    FSM <= idle ;
                end if;
            when high_speed    =>
                if out_sig > speed_th_75 then
                    FSM <= speedup;
                else
                    FSM <= high_speed;
                end if;
            when speedup        =>
                if out_sig > target_speed then
                    if out_sig < speed_th_105 then
                        FSM <= steady;
                    else
                        FSM <= speeddown;
                    end if;                       
                else
                    FSM <= speedup;
                end if;
            when speeddown      =>
                if out_sig < target_speed then
                    if out_sig > speed_th_95 then
                        FSM <= steady;
                    else
                        FSM <= speedup;
                    end if;                      
                else
                    FSM <= speeddown;
                end if;
            when steady         =>
                if out_sig > speed_th_95 and out_sig < speed_th_105 then
                    FSM <= steady;
                elsif out_sig > speed_th_95 then
                    FSM <= speeddown;
                elsif out_sig < speed_th_105 then
                    FSM <= speedup;
                end if;
            when others         =>
                FSM <= idle ;
        end case;
    end if;
end process;


cnt1_process : process(en,clk,rst,cnt1_max,FSM,cnt1_en,cnt1)
begin
    if rst = '1' then
        cnt1 <= 0;
        cnt2_en <= '0';
    else
        case FSM is
            when idle           =>
            when high_speed     => cnt1_max <= max_speed;
            when speedup        => cnt1_max <= sec_speed;
            when speeddown      => cnt1_max <= min_speed;
            when steady         => cnt1_max <= mid_speed;
            when others         =>
        end case;
        if en = '1' and cnt1_en = '1' then
            cnt2_en <= '0';
            if rising_edge(clk)then
                if cnt1 < cnt1_max then
                    cnt1 <= cnt1 + 1;
                else
                    cnt2_en <= '1';
                end if;
            end if;
        else
            cnt1 <= 0;
        end if;
    end if;
end process;

cnt2_process : process(en,clk,rst,cnt2_max,FSM,cnt2_en,cnt2)
begin
    if rst = '1' then
        cnt2 <= 0;
        cnt1_en <= '1';
    else
        case FSM is
            when idle           =>
            when high_speed     => cnt2_max <= (10-max_speed);
            when speedup        => cnt2_max <= (10-sec_speed);
            when speeddown      => cnt2_max <= (10-min_speed);
            when steady         => cnt2_max <= (10-mid_speed);
            when others         =>
        end case;
        if en = '1' and cnt2_en = '1' then
            cnt1_en <= '0';
            if rising_edge(clk)then
                if cnt2 < cnt2_max then
                    cnt2 <= cnt2 + 1;
                else
                    cnt1_en <= '1';        
                end if;
            end if;
        else
            cnt2 <= 0;
        end if;
    end if;
end process;

end Behavioral;
