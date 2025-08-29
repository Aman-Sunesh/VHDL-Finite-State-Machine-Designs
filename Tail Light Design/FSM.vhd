----------------------------------------------------------------------------------
-- Company: NYU Abu Dhabi
-- Engineer: Aman Sunesh, Demarce Williams
-- 
-- Create Date:    12:48:43 10/02/2025 
-- Design Name:    FSM Tail Light Controller
-- Module Name:    FSM - Behavioral 
-- Project Name:   Advanced Digital Logic Lab 2 - Tail Light Implementation
-- Target Device:  FPGA 
-- Tool versions:  Xilinx
-- Description: 
-- VHDL code for a finite state machine (FSM) that controls the tail-light outputs.
-- The design supports individual left/right turn signal modes as well as hazard mode.
-- An error output (err) is asserted when any input is undefined or when both turn signals
-- are active while the FSM is in the idle state.
--
-- Dependencies: 
-- Standard IEEE 1164 logic libraries and IEEE.NUMERIC_STD for arithmetic operations.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration for the tail-light
ENTITY FSM IS
  PORT(rts,lts,haz : IN std_logic;
             clk : IN std_logic;       -- Main system Clock
             la,lb,lc : OUT std_logic; -- Left tail lights
             ra,rb,rc : OUT std_logic; -- Right tail lights
				 err : OUT std_logic); -- Error output (mapped to LED3 - P6)
END FSM;


-- Architecture defining the behaviour of the tail-light
ARCHITECTURE Behavioral OF FSM IS
	TYPE state_type IS (idle,l1,l2,l3,r1,r2,r3,lr3);
	SIGNAL state,next_state : state_type;
	signal clk_en : std_logic := '0';   -- Slower clock enable for FSM updates
	signal counter : integer := 0;      -- Counter for dividing input clock
	constant count_2Hz : integer := 25_000_000;  -- For turn signal blinking
	constant count_4Hz : integer := 12_500_000;  -- For turn signal blinking

BEGIN


 -- clock_divider PROCESS:
 -- This process runs on the rising_edge of clk, and toggles clk_en at either
 -- 2 Hz or 4 Hz, depending on the haz input.
  
 clock_divider : PROCESS(clk)
   variable target_count : integer;
 BEGIN
   IF rising_edge(clk) THEN
      -- Decide on the target count based on hazard input:
     if haz = '1' then
        target_count := count_2Hz;
     else
        target_count := count_4Hz;
     end if;
     
	  -- Increment the counter, toggle clk_en once we reach the target count
     if counter >= target_count then
        counter <= 0;
        clk_en <= not clk_en;
     else
        counter <= counter + 1;
     end if;
   END IF;
 END PROCESS clock_divider;



-- State Logic Process; sequential
 -- Updates the current state on the rising edge of clk_en.
 
 state_register : PROCESS(clk_en)
 BEGIN
   IF rising_edge(clk_en) THEN
     state <= next_state;
   END IF;
 END PROCESS state_register;



-- Next State Logic Process; combinational
 -- Determines the next state based on current state, lts, rts, and haz.
  
  next_state_logic : PROCESS(state, lts, rts, haz)
  BEGIN
    -- Checking for undefined inputs 
    if (lts = 'X' or rts = 'X' or haz = 'X') then
         next_state <= idle;
    else
      CASE state IS
        WHEN idle =>
          -- In idle, if both turn signals are on, this is an error.
          if (lts = '1' and rts = '1') then
               next_state <= idle;  -- Remain in idle so the error is flagged.
          elsif haz = '1' then
               next_state <= lr3;
          elsif (lts = '0' and rts = '1') then
               next_state <= r1;
          elsif (lts = '1' and rts = '0') then
               next_state <= l1;
          else
               next_state <= idle;
          end if;
          
        WHEN l1 =>
          if haz = '1' then
               next_state <= lr3;
          else
               next_state <= l2;
          end if;
          
        WHEN l2 =>
          if haz = '1' then
               next_state <= lr3;
          else
               next_state <= l3;
          end if;
          
        WHEN l3 =>
          next_state <= idle;
          
        WHEN r1 =>
          if haz = '1' then
               next_state <= lr3;
          else
               next_state <= r2;
          end if;
          
        WHEN r2 =>
          if haz = '1' then
               next_state <= lr3;
          else
               next_state <= r3;
          end if;
          
        WHEN r3 =>
          next_state <= idle;
          
        WHEN lr3 =>
          next_state <= idle;
      END CASE;
    end if;
  END PROCESS next_state_logic;



-- State Machine Outputs Process; combinational
-- Controls the tail-light outputs and error signal based on the current state.

output_logic : PROCESS (state, lts, rts, haz)
BEGIN
	-- First we check for error conditions:
	-- (i) When in idle, if both turn signals are high.
	-- (ii) When any input is undefined ('X')
	if ((state = idle and lts = '1' and rts = '1') 
	or (lts = 'X' or rts = 'X' or haz = 'X')) then
		err <= '1';
		-- In the error state, we turn off all tail-light outputs
		lc <= '0';
		lb <= '0';
		la <= '0';
		ra <= '0';
		rb <= '0';
		rc <= '0';	
	else
		err <= '0';
		CASE state IS
			-- In this case, output assignments are soleley based on the state (Moore-type FSM)
			WHEN idle =>
				lc<='0';
				lb<='0';
				la<='0';
				ra<='0';
				rb<='0';
				rc<='0';
			WHEN l1 =>
				lc<='0';
				lb<='0';
				la<='1';
				ra<='0';
				rb<='0';
				rc<='0';
			WHEN l2 =>
				lc<='0';
				lb<='1';
				la<='1';
				ra<='0';
				rb<='0';
				rc<='0';
			WHEN l3 =>
				lc<='1';
				lb<='1';
				la<='1';
				ra<='0';
				rb<='0';
				rc<='0';
			WHEN r1 =>
				lc<='0';
				lb<='0';
				la<='0';
				ra<='1';
				rb<='0';
				rc<='0';
			WHEN r2 =>
				lc<='0';
				lb<='0';
				la<='0';
				ra<='1';
				rb<='1';
				rc<='0';
			WHEN r3 =>
				lc<='0';
				lb<='0';
				la<='0';
				ra<='1';
				rb<='1';
				rc<='1';
			WHEN lr3 =>
				lc<='1';
				lb<='1';
				la<='1';
				ra<='1';
				rb<='1';
				rc<='1';
		END CASE;
	END IF;
END PROCESS output_logic;

END Behavioral;