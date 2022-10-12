LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.constant_def.all;
ENTITY stepper_motor_tb IS
END stepper_motor_tb;
 
ARCHITECTURE behavior OF stepper_motor_tb IS 
    COMPONENT stepper_motor
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         en : IN  std_logic;
         out_sig : INOUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal en : std_logic := '0';

	--BiDirs
   signal out_sig : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: stepper_motor PORT MAP (
          clk => clk,
          rst => rst,
          en => en,
          out_sig => out_sig
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
    wait for clk_period;
    rst <= '0';
    en  <= '0';
    wait for clk_period*2;
    rst <= '1';
    wait for clk_period*3;
    rst <= '0';
    en  <= '1';
    wait for clk_period*10000;
   end process;

END;
