----------------------------------------------------------------------------------
-- Company: NYU Abu Dhabi
-- Engineer: Aman Sunesh, Demarce Willliams
-- 
-- Create Date:    00:16:42 10/02/2025
-- Design Name:    FSM Tail Light Testbench
-- Module Name:    Testbench - Behavioral
-- Project Name:   Tail_Light
-- Target Device:  
-- Tool versions:  Xilinx
-- Description: 
-- This testbench verifies the FSM for the tail light controller. It applies 
-- 10 test cases:
--    a) Only rts on
--    b) Only lts on
--    c) Only haz on
--    d) rts and lts on
--    e) rts and haz on
--    f) lts and haz on
--    g) rts, lts, and haz on
--    h) rts set to 'X'
--    i) lts set to 'X'
--    j) haz set to 'X'
-- A clock signal is generated to drive the FSM.
--
-- Dependencies:
-- Standard IEEE 1164 logic libraries.
--
-- Revision:
-- Revision 0.01 - File Created
--
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following if you use numeric operations
-- use IEEE.NUMERIC_STD.ALL;

entity Testbench is
end Testbench;

architecture behavior of Testbench is

	 -- Component Declaration for the Unit Under Test (UUT)
	 component FSM
		  port(
				rts : in  std_logic;
				lts : in  std_logic;
				haz : in  std_logic;
				clk : in  std_logic;
				la  : out std_logic;
				lb  : out std_logic;
				lc  : out std_logic;
				ra  : out std_logic;
				rb  : out std_logic;
				rc  : out std_logic;
				err : out std_logic
		  );
	 end component;
		 
    -- Input signals for the FSM
    signal rts_tb : std_logic := '0';
    signal lts_tb : std_logic := '0';
    signal haz_tb : std_logic := '0';
    signal clk_tb : std_logic := '0';

    -- Output signals from the FSM
    signal la_tb : std_logic;
    signal lb_tb : std_logic;
    signal lc_tb : std_logic;
    signal ra_tb : std_logic;
    signal rb_tb : std_logic;
    signal rc_tb : std_logic;
	 signal err_tb : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: FSM port map (
        rts => rts_tb,
        lts => lts_tb,
        haz => haz_tb,
        clk => clk_tb,
        la  => la_tb,
        lb  => lb_tb,
        lc  => lc_tb,
        ra  => ra_tb,
        rb  => rb_tb,
        rc  => rc_tb,
		  err => err_tb
    );

    -- Clock Process: Generates a periodic clock signal
    clk_process: process
    begin
			clk_tb <= '0';
			wait for clk_period/2;
			clk_tb <= '1';
			wait for clk_period/2;
    end process clk_process;

    -- Stimulus Process: Applies the 10 test cases sequentially
    stim_proc: process
    begin
        -- Hold the initial state for 100 ns
        wait for 100 ns;
        
        ------------------------------------------------------------------------------
        -- Test case a: Only rts on (rts = '1'; lts = '0'; haz = '0')
        ------------------------------------------------------------------------------
        rts_tb <= '1';  lts_tb <= '0';  haz_tb <= '0';
        wait for 250 ns;
        
        ------------------------------------------------------------------------------
        -- Test case b: Only lts on (rts = '0'; lts = '1'; haz = '0')
        ------------------------------------------------------------------------------
        rts_tb <= '0';  lts_tb <= '1';  haz_tb <= '0';
        wait for 225 ns;
        
        ------------------------------------------------------------------------------
        -- Test case c: Only haz on (rts = '0'; lts = '0'; haz = '1')
        ------------------------------------------------------------------------------
        rts_tb <= '0';  lts_tb <= '0';  haz_tb <= '1';
        wait for 200 ns;
        
        ------------------------------------------------------------------------------
        -- Test case d: rts and lts on (rts = '1'; lts = '1'; haz = '0')
        ------------------------------------------------------------------------------
        rts_tb <= '1';  lts_tb <= '1';  haz_tb <= '0';
        wait for 175 ns;
        
        ------------------------------------------------------------------------------
        -- Test case e: rts and haz on (rts = '1'; lts = '0'; haz = '1')
        ------------------------------------------------------------------------------
        rts_tb <= '1';  lts_tb <= '0';  haz_tb <= '1';
        wait for 150 ns;
        
        ------------------------------------------------------------------------------
        -- Test case f: lts and haz on (rts = '0'; lts = '1'; haz = '1')
        ------------------------------------------------------------------------------
        rts_tb <= '0';  lts_tb <= '1';  haz_tb <= '1';
        wait for 125 ns;
        
        ------------------------------------------------------------------------------
        -- Test case g: rts, lts, and haz on (rts = '1'; lts = '1'; haz = '1')
        ------------------------------------------------------------------------------
        rts_tb <= '1';  lts_tb <= '1';  haz_tb <= '1';
        wait for 100 ns;
        
        ------------------------------------------------------------------------------
        -- Test case h: Error on rts (rts = 'X'; others off)
        ------------------------------------------------------------------------------
        rts_tb <= 'X';  lts_tb <= '0';  haz_tb <= '0';
        wait for 75 ns;
        
        ------------------------------------------------------------------------------
        -- Test case i: Error on lts (lts = 'X'; others off)
        ------------------------------------------------------------------------------
        rts_tb <= '0';  lts_tb <= 'X';  haz_tb <= '0';
        wait for 50 ns;
        
        ------------------------------------------------------------------------------
        -- Test case j: Error on haz (haz = 'X'; others off)
        ------------------------------------------------------------------------------
        rts_tb <= '0';  lts_tb <= '0';  haz_tb <= 'X';
        wait for 25 ns;
       
		wait;
    end process stim_proc;

end behavior;
