----------------------------------------------------------------------------------                         
-- Company:  Chalmers                                                                                              
-- Engineer:                                                                                               
--                                                                                                         
-- Create Date: 11/12/2025 02:25:02 PM                                                                     
-- Design Name:                                                                                            
-- Module Name: demo - Behavioral                                                                          
-- Project Name:                                                                                           
-- Target Devices:                                                                                         
-- Tool Versions:                                                                                          
-- Description:                                                                                            
--                                                                                                         
-- Dependencies:                                                                                           
--                                                                                                         
-- Revision:                                                                                               
-- Revision 1                                                                          
-- Additional Comments:                                                                                    
--                                                                                                         
----------------------------------------------------------------------------------                         
                                                                                                           
                                                                                                           
library IEEE;                                                                                              
use IEEE.STD_LOGIC_1164.ALL;                                                                               
                                                                                                           
-- Uncomment the following library declaration if using                                                    
-- arithmetic functions with Signed or Unsigned values                                                     
use IEEE.NUMERIC_STD.ALL;
                                                                                
                                                                                                           
-- Uncomment the following library declaration if instantiating                                            
-- any Xilinx leaf cells in this code.                                                                     
--library UNISIM;                                                                                          
--use UNISIM.VComponents.all;                                                                              
                                                                                                           
entity LAB1H1 is     
  generic( 
	constant  CTRL_max :  natural := 250000 - 1; --refresh per 200Hz (250 000) on the displays                                       
  	constant sec_pulse_max :natural := 400 - 1); --refresh per 1Hz (250 000 times 400) for 1 second counter
	                                                                                       
  port ( CLK: in std_logic;
	 RESET: in std_logic;                                                                                                                                      
         SEG: out std_logic_vector(7 downto 0);                                                          
         AN : out STD_LOGIC_VECTOR (7 downto 0));                                                        
end LAB1H1;                                                                                                 
                                                                                                           
architecture Behavioral of LAB1H1 is 
  signal one_digit   : unsigned(3 downto 0);  -- stores digit 0..9
  signal ten_digit    : unsigned(2 downto 0);  -- stores digit 0..5 
  
  signal sec_cnt   : unsigned(3 downto 0);  -- enough for 9 second count to decide what second we are on
  signal ten_sec_cnt   : unsigned(2 downto 0);  -- enough for 5 second count count to decide what 10 second we are on
  signal mux_select : std_logic; 
                                                                                                                                                                                                                                                                                                                                                                                                         
 
 Begin 
COUNTER: PROCESS(CLK, reset) 

   variable CTRL : unsigned(18 downto 0); -- CTRL counts upp to checks the clock every 200 Hz
   variable sec_pulse : unsigned(8 downto 0); -- counts upp to checks the clock every 1 Hz
   
  Begin
    if reset = '0' then --reset all counters and which 7-seg display we select
	  ten_sec_cnt <= (others => '0');
	  sec_pulse := (others => '0');
	  sec_cnt <= (others => '0');
	  mux_select <= '0';
	  CTRL := (others => '0');

    elsif rising_edge(CLK) then
	  if sec_pulse = sec_pulse_max then  --when 1 second has gone by
		sec_pulse := (others => '0');
		if sec_cnt = 9 then --resets when one second counter is 9
		   sec_cnt <= (others => '0');
		   ten_sec_cnt <= ten_sec_cnt + 1; --adds to the 10 seconds counter
			if ten_sec_cnt = 5 then --resets when 10 seconds counter is 5
		   	ten_sec_cnt <= (others => '0');
			end if;
		else
		   sec_cnt <= sec_cnt + 1; --adds to how many seconds we have counted if not 9 seocnds counted
		end if; 

	  end if; --seconds counter
	  
	  if CTRL = CTRL_max then --after 200Hz this is true
		CTRL := (others => '0'); --reset Ctrl
		sec_pulse := sec_pulse + 1; --add to the counter that counts the 1Hz frequency
		mux_select <= not mux_select; -- switichen between the diplays
	  else
		CTRL := CTRL + 1;
	  end if; --mux
    end if; --exiting the clock process
END PROCESS COUNTER;


SecToBits: PROCESS (sec_cnt)  --stores the number data for both displays
  Begin
      ten_digit <= ten_sec_cnt; 
      one_digit <= sec_cnt;
END PROCESS SecToBits;
  
DISPLAY: PROCESS (mux_select, ten_digit, one_digit)
  variable seg_pat10  : std_logic_vector(7 downto 0); --selects the patern for the ten digit numbers
  variable seg_pat1 : std_logic_vector(7 downto 0);  --selects the patern for theone digit numbers  
  
   Begin                                                                                                  
   	CASE one_digit IS --selects the binary data for the first 7-seg
				WHEN "0000" =>
					seg_pat1 :="11000000"; --0
				WHEN "0001" =>
					seg_pat1 :="11111001"; --1
				WHEN "0010" =>
					seg_pat1 :="10100100"; --2
				WHEN "0011" =>
					seg_pat1 :="10110000"; --3
				WHEN "0100" =>
					seg_pat1 :="10011001"; --4
				WHEN "0101" =>
					seg_pat1 :="10010010"; --5
				WHEN "0110" =>
					seg_pat1 :="10000010"; --6
				WHEN "0111" =>
					seg_pat1 :="11111000"; --7
				WHEN "1000" =>
					seg_pat1 :="10000000"; --8
				WHEN "1001" =>
					seg_pat1 :="10010000"; --9
				WHEN others =>
					seg_pat1 :="11111111"; --off
	END CASE;--seg
	CASE ten_digit IS  --selects the binary data for the second 7-seg
				WHEN "000" =>
					seg_pat10 :="11000000"; --0
				WHEN "001" =>
					seg_pat10 :="11111001"; --1
				WHEN "010" =>
					seg_pat10 :="10100100"; --2
				WHEN "011" =>
					seg_pat10 :="10110000"; --3
				WHEN "100" =>
					seg_pat10 :="10011001"; --4
				WHEN "101" =>
					seg_pat10 :="10010010"; --5
				WHEN "110" =>
					seg_pat10 :="10000010"; --6
				WHEN "111" =>
					seg_pat10 :="11111000"; --7
				WHEN others =>
					seg_pat10 :="11111111"; --off
	END CASE; --seg

	if mux_select = '0' then --displays the numbers on first display
	   AN (7 downto 0) <= "11111110";
	   Seg <= seg_pat1(7 downto 0);
	else 
	   AN (7 downto 0) <= "11111101"; --displays the numbers on second display
	   Seg <= seg_pat10(7 downto 0);
	end if; 
	
END PROCESS DISPLAY;   
                                                                                                     
                                                                            
end Behavioral;                                                
