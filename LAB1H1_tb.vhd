LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LAB1H1_tb IS
END LAB1H1_tb;

ARCHITECTURE arch_LAB1H1_tb OF LAB1H1_tb IS

  -- Component Declaration for the Design Under Test (DUT)
  COMPONENT LAB1H1 IS
    generic(  
      constant CTRL_max : natural;
      constant sec_pulse_max : natural);
    PORT (  
      CLK   : in std_logic;
      RESET : in std_logic;
      SEG   : out std_logic_vector(7 downto 0);
      AN    : out STD_LOGIC_VECTOR (7 downto 0));
  END COMPONENT LAB1H1;
 
  CONSTANT SIM_SEC_PERIOD : time := 10 us; --Period time for 100khz instead of 1Hz 
 
  SIGNAL clk_tb_signal   : STD_LOGIC := '0';
  SIGNAL reset_tb_signal : STD_LOGIC;
  SIGNAL seg_tb_signal   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL an_tb_signal    : STD_LOGIC_VECTOR(7 DOWNTO 0);
 
  CONSTANT Seg_0 : std_logic_vector(7 downto 0) := "11000000"; -- '0'
  CONSTANT Seg_1 : std_logic_vector(7 downto 0) := "11111001"; -- '1'
  CONSTANT Seg_2 : std_logic_vector(7 downto 0) := "10100100"; -- '2'
  CONSTANT Seg_5 : std_logic_vector(7 downto 0) := "10010010"; -- '5'
  CONSTANT Seg_9 : std_logic_vector(7 downto 0) := "10010000"; -- '9'

  CONSTANT AN_0 : std_logic_vector(7 downto 0) := "11111110"; --First Display active
  CONSTANT AN_1 : std_logic_vector(7 downto 0) := "11111101"; --Second Display active

BEGIN

  uut_comp: COMPONENT LAB1H1
    generic map (
      CTRL_max => 24,
      sec_pulse_max => 999
    )
    PORT MAP(
      CLK => clk_tb_signal,
      RESET => reset_tb_signal,
      SEG => seg_tb_signal,
      AN => an_tb_signal
    );

  clk_proc: PROCESS
  BEGIN
  	clk_tb_signal <= '0';
  	WAIT FOR 5 ns; 
  	clk_tb_signal <= '1';
  	WAIT FOR 5 ns;
  END PROCESS clk_proc;

  -- Main Test Process
  test_proc: PROCESS
  BEGIN
 
    reset_tb_signal <= '0';
    WAIT FOR 200 ns; -- Hold reset for 20 clock cycles
    reset_tb_signal <= '1';
    WAIT FOR 10 ns; -- Wait one clock cycle for reset to release



    WAIT UNTIL an_tb_signal = AN_0; -- Wait for ones digit
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on ones digit (AN0) fail at 0s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1; -- Wait for tens digit
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on tens digit (AN1) fail at 0s" SEVERITY ERROR;


    WAIT FOR SIM_SEC_PERIOD; -- Wait for one simulated second (10 us)
    WAIT UNTIL an_tb_signal = AN_0;
    ASSERT (seg_tb_signal = SEG_1)
      REPORT "Error: '1' on ones digit (AN0) fail at 1s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1;
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on tens digit (AN1) fail at 1s" SEVERITY ERROR;

 
    -- Wait 8 more "seconds" to get to 9s.
    WAIT FOR 8 * SIM_SEC_PERIOD; 

    WAIT UNTIL an_tb_signal = AN_0;
    ASSERT (seg_tb_signal = SEG_9)
      REPORT "Error: '9' on ones digit (AN0) fail at 9s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1;
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on tens digit (AN1) fail at 9s" SEVERITY ERROR;
      
    -- Wait one more "second" for rollover to 10
    WAIT FOR SIM_SEC_PERIOD;
    WAIT UNTIL an_tb_signal = AN_0;
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on ones digit (AN0) fail at 10s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1;
    ASSERT (seg_tb_signal = SEG_1)
      REPORT "Error: '1' on tens digit (AN1) fail at 10s" SEVERITY ERROR;


    -- Wait 49 more "seconds" to get to 59s.
    WAIT FOR 49 * SIM_SEC_PERIOD;
    WAIT UNTIL an_tb_signal = AN_0;
    ASSERT (seg_tb_signal = SEG_9)
      REPORT "Error: '9' on ones digit (AN0) fail at 59s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1;
    ASSERT (seg_tb_signal = SEG_5)
      REPORT "Error: '5' on tens digit (AN1) fail at 59s" SEVERITY ERROR;

    -- Wait one more "second" for rollover to 00
    WAIT FOR SIM_SEC_PERIOD;

    WAIT UNTIL an_tb_signal = AN_0;
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on ones digit (AN0) fail at 60s" SEVERITY ERROR;
    WAIT UNTIL an_tb_signal = AN_1;
    ASSERT (seg_tb_signal = SEG_0)
      REPORT "Error: '0' on tens digit (AN1) fail at 60s" SEVERITY ERROR;


    REPORT "Test completed successfully!" SEVERITY NOTE;
     WAIT FOR 3 ns;
     WAIT;
  END PROCESS test_proc;

END arch_LAB1H1_tb;
