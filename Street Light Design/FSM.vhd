---------------------------------------------------------------------------------------
-- Company:       NYU Abu Dhabi
-- Engineers:     Aman Sunesh, Demarce Williams
--
-- Create Date:   23/02/2025 12:48:43
-- Design Name:   FSM Traffic Light Controller Implementation
-- Module Name:   FSM - Behavioral
-- Project Name:  Advanced Digital Logic Lab 2 Part 2 - FSM Implementation
-- Target Device: FPGA
-- Tool Versions: Xilinx
-- Description: 
-- VHDL code for a finite state machine (FSM) that controls various outputs.
-- The design supports pedestrian walk requests and traffic light sequences.
-- An error condition is flagged when any sensor input is undefined.
--
-- Dependencies:
-- Standard IEEE 1164 logic libraries and IEEE.NUMERIC_STD for arithmetic operations.
---------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is 
	generic (
	 G_sec_05 : integer := 25000000  -- Default: 25e6 for FPGA
	                                    -- This generic parameter allows us to adjust the timing 
                                       -- (e.g., for simulation vs. actual hardware) without modifying the
                                       -- internal implementation of the FSM.
	);

	PORT (
		in_clk         : IN std_logic;       -- Main system clock
		in_sensor_main : IN std_logic;       -- Sensor input for main road detection
		in_main_walk   : IN std_logic;       -- Pedestrian walk request for main road
		in_side_walk   : IN std_logic;       -- Pedestrian walk request for side road
		out_main_red   : OUT std_logic;      -- Main road red light output
		out_main_yellow: OUT std_logic;      -- Main road yellow light output
		out_main_green : OUT std_logic;      -- Main road green light output
		out_side_red   : OUT std_logic;      -- Side road red light output
		out_side_yellow: OUT std_logic;      -- Side road yellow light output
		out_side_green : OUT std_logic;      -- Side road green light output
		out_main_walk  : OUT std_logic;      -- Pedestrian walk signal for main road
		out_side_walk  : OUT std_logic       -- Pedestrian walk signal for side road
	);
end FSM;

architecture Behavioral of FSM is

	-- FSM State Declaration
	TYPE state_type IS (
		main_red,              -- Main road red light active
		main_green_1st,        -- First portion of main road green phase
		main_green_2nd,        -- Second portion of main road green phase
		main_green_1st_extended,-- Extended main road green phase when sensor triggers
		main_yellow,           -- Main road yellow light phase
		side_red,              -- Side road red light active
		side_green_1st,        -- First portion of side road green phase
		side_green_2nd,        -- Second portion of side road green phase
		side_yellow            -- Side road yellow light phase
	);
	SIGNAL state, next_state : state_type := main_red;   -- Current and next state


	-- Derived timing constants using the generic

	-- Derived timing constants from the generic. These determine how long
	-- each state lasts.
	constant sec_05 : integer := G_sec_05;           -- 0.5 second period (in clock cycles)
	constant sec_1  : integer := 2 * G_sec_05;         -- 1 second period
	constant sec_2  : integer := 2 * sec_1;            -- 2 second period
	constant sec_3  : integer := 3 * sec_1;            -- 3 second period
	constant sec_5  : integer := 5 * sec_1;            -- 5 second period
	constant sec_8  : integer := 8 * sec_1;            -- 8 second period


	-- Signals for clock dividers

	-- These signals are used for dividing the main clock for various timing 
	-- operations such as state duration and blinking intervals.
	signal clk_count_state : integer range 0 to sec_8;   -- Counter for state duration
	signal clk_count_blink : integer range 0 to sec_05;    -- Counter for blinking interval
	signal clk_count_reset1: integer range 0 to sec_2;     -- Counter for clearing main walk request
	signal clk_count_reset2: integer range 0 to sec_2;     -- Counter for clearing side walk request


	-- This signal flags an error if any sensor input is undefined.
	signal error_detected : std_logic := '0';


	-- Signals for registers
	
	-- reg_main_walk and reg_side_walk hold the pedestrian request status.
   -- reg_blink is used to generate a blinking signal for the walk outputs.
	signal reg_main_walk, reg_side_walk, reg_blink : std_logic := '0';


begin


-- This process monitors the sensor and walk request inputs. If any of them
-- is undefined ('X'), error_detected is set to '1'.
process(in_sensor_main, in_main_walk, in_side_walk)
begin
    if (in_sensor_main = 'X' or in_main_walk = 'X' or in_side_walk = 'X') then
        error_detected <= '1';
    else
        error_detected <= '0';
    end if;
end process;


-- This process divides the main clock to generate time intervals for each
-- state based on the desired period (2s, 8s, 5s, 3s).
PROCESS (in_clk)
BEGIN
    if (rising_edge(in_clk)) then
        CASE state IS
            -- States with 2s periods
            WHEN main_green_2nd | main_yellow | side_green_2nd | side_yellow =>
                if (clk_count_state = sec_2) then
                    state <= next_state;
                    clk_count_state <= 0;
                else
                    clk_count_state <= clk_count_state + 1;
                end if;
				-- States with 8s periods
            WHEN main_green_1st | side_green_1st  =>
                if (clk_count_state = sec_8) then
                    state <= next_state;
                    clk_count_state <= 0;
                else
                    clk_count_state <= clk_count_state + 1;
                end if;
				-- States with 5s periods
            WHEN main_green_1st_extended  =>
                if (clk_count_state = sec_5) then
                    state <= next_state;
                    clk_count_state <= 0;
                else
                    clk_count_state <= clk_count_state + 1;
                end if;
				-- States with 3s periods
            WHEN side_red | main_red =>
                if (clk_count_state = sec_3) then
                    state <= next_state;
                    clk_count_state <= 0;
                else
                    clk_count_state <= clk_count_state + 1;
                end if;
        END CASE;
    end if;
END PROCESS;



-- This process generates the blink signal for pedestrian walk lights.
-- In specific states (main_green_2nd, main_yellow, side_green_2nd, side_yellow),
-- it toggles reg_blink every sec_05 clock cycles. Otherwise, it resets reg_blink.
PROCESS (in_clk)
BEGIN
    if (rising_edge(in_clk)) then
        if (state = main_green_2nd OR state = main_yellow OR state = side_green_2nd OR state = side_yellow) then
            if (clk_count_blink = sec_05) then  
                reg_blink <= NOT reg_blink;  -- Toggle the blink register
                clk_count_blink <= 0;  -- Reset counter after blinking
            else
                clk_count_blink <= clk_count_blink + 1;  -- Increment counter
            end if;
        else
            reg_blink <= '0';  -- No blinking in other states
            clk_count_blink <= 0;  -- Ensure counter is reset outside blinking states
        end if;
    end if;
END PROCESS;



-- This process sets reg_main_walk when the main walk button is pressed.
-- It clears the request when the FSM is in the side_yellow state after a delay.
PROCESS (in_clk)
BEGIN
    if (rising_edge(in_clk)) then
		  -- If the main walk button is pressed, set the main walk register to '1'
        if (in_main_walk = '1') then
            reg_main_walk <= '1'; 
       
		  -- Otherwise, if the FSM is in the side_yellow state (indicating the cycle is finishing for the side road)
        elsif (state = side_yellow) then
			   -- Increment the reset counter for the main walk request
            clk_count_reset1 <= clk_count_reset1 + 1;
           
				-- Once the counter reaches (sec_2 - 1) clock cycles, clear the main walk register 
            -- and reset the counter to 0
            if (clk_count_reset1 = sec_2 - 1) then
                reg_main_walk <= '0';
                clk_count_reset1 <= 0;  
            end if;
        end if;
    end if;
END PROCESS;


-- This process sets reg_side_walk when the side walk button is pressed.
-- It clears the request when the FSM is in the main_yellow state after a delay.
PROCESS (in_clk)
BEGIN
    if (rising_edge(in_clk)) then
		  -- If the side walk button is pressed, set the side walk register to '1'
        if (in_side_walk = '1') then
            reg_side_walk <= '1';
       
			-- Otherwise, if the FSM is in the main_yellow state (indicating the cycle is finishing for the main road)
			elsif (state = main_yellow) then
				-- Increment the reset counter for the side walk request
            clk_count_reset2 <= clk_count_reset2 + 1;
           
				-- Once the counter reaches (sec_2 - 1) clock cycles, clear the side walk register 
            -- and reset the counter to 0
            if (clk_count_reset2 = sec_2 - 1) then
                reg_side_walk <= '0';
                clk_count_reset2 <= 0;  
            end if;
        end if;
    end if;
END PROCESS;


-- Next State Transitions

-- This process determines the next state based on the current state and
-- the inputs from sensors and pedestrian requests.
PROCESS (state, in_sensor_main, reg_main_walk, reg_side_walk)
BEGIN
    CASE state IS
        WHEN side_red =>
            if (reg_main_walk = '1' and reg_side_walk = '0') then
                next_state <= main_red;
            else
                next_state <= main_green_1st;
            end if;

        WHEN main_red =>
            if (reg_side_walk = '1' and reg_main_walk = '0') then
                next_state <= side_red;
            else
                next_state <= side_green_1st;
            end if;

        WHEN main_green_1st =>
            if (in_sensor_main = '1') then
                next_state <= main_green_1st_extended;
            else
                next_state <= main_green_2nd;
            end if;

        WHEN main_green_1st_extended =>
            next_state <= main_green_2nd;

        WHEN main_green_2nd =>
            next_state <= main_yellow;

        WHEN main_yellow =>
            next_state <= main_red;

        WHEN side_green_1st =>
            next_state <= side_green_2nd;

        WHEN side_green_2nd =>
            next_state <= side_yellow;

        WHEN side_yellow =>
            next_state <= side_red;
    END CASE;
END PROCESS;



-- This process drives the output signals based on the current state,
-- pedestrian request registers, and error conditions.
-- If an error is detected, all outputs are forced to red.
PROCESS (state, reg_side_walk, reg_main_walk, error_detected, reg_blink)
BEGIN

	if (error_detected = '1') then
	  -- Force all red lights when an error is detected
	  out_main_red    <= '1';
	  out_main_yellow <= '0';
	  out_main_green  <= '0';
	  out_side_red    <= '1';
	  out_side_yellow <= '0';
	  out_side_green  <= '0';
	  out_main_walk   <= '0';
	  out_side_walk   <= '0';
	 
	else		
		-- Default assignments
		out_main_red <= '0';
		out_main_yellow <= '0';
		out_main_green <= '0';
		out_side_red <= '0';
		out_side_yellow <= '0';
		out_side_green <= '0';
		out_main_walk <= '0';
		out_side_walk <= '0';

		CASE state IS
				  WHEN main_green_1st | main_green_1st_extended =>
						out_main_green <= '1';
						-- Activate side pedestrian walk only if a request exists.
						if (reg_side_walk = '1') then
							 out_side_walk <= '1';
						end if;
						out_side_red <= '1';

				  WHEN main_green_2nd=>
						out_main_green <= '1';
						-- Blink side pedestrian walk only if a request exists.
						if (reg_side_walk = '1') then
							 out_side_walk <= reg_blink;
						end if;
						out_side_red <= '1';

				  WHEN main_yellow =>
						out_main_yellow <= '1';
						-- Blink the side walk signal only if a request exists.
						if (reg_side_walk = '1') then
							 out_side_walk <= reg_blink;
						end if;
						out_side_red <= '1';

				  WHEN side_green_1st =>
						out_side_green <= '1';
						out_main_red <= '1';
				  
						-- Activate side pedestrian walk only if a request exists.
						if (reg_main_walk = '1') then
							out_main_walk <= '1'; -- Walk signal activates for the main road
						end if;
				  WHEN side_green_2nd =>
						out_side_green <= '1';

					  -- Blink side pedestrian walk only if a request exists.
						if (reg_main_walk = '1') then
							out_main_walk <= reg_blink; -- Walk signal activates for the main road
						end if;

						out_main_red <= '1';

				  WHEN side_yellow =>
						out_side_yellow <= '1';

						-- Blink side pedestrian walk only if a request exists.
						if (reg_main_walk = '1') then
							out_main_walk <= reg_blink; -- Walk signal activates for the main road
						end if;
						
						out_main_red <= '1';

				  WHEN main_red =>
						out_main_red <= '1';
						out_side_red <= '1';

				  WHEN side_red =>
						out_side_red <= '1';
						out_main_red <= '1';
			END CASE;
		END IF;
END PROCESS;

end Behavioral;