--------------------------------------------------------------------------------
-- Company:       NYU Abu Dhabi
-- Engineers:     Aman Sunesh, Demarce Williams
--
-- Create Date:   23/02/2025 12:48:43
-- Design Name:   FSM Traffic Light Controller Implementation
-- Module Name:   FSM_tb - Testbench
-- Project Name:  Advanced Digital Logic Lab 2 Part 2 - FSM Implementation
-- Target Device: FPGA
-- Tool Versions: Xilinx
-- Description: 
-- VHDL Testbench for the FSM module. This testbench simulates various scenarios 
-- for the traffic light controller, including normal operation, sensor activation,
-- individual pedestrian requests, simultaneous requests, and error conditions.
--
-- Dependencies:
-- Standard IEEE 1164 logic libraries.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_tb is
end FSM_tb;

architecture sim of FSM_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component FSM is
    generic (
      G_sec_05 : integer := 25000000
    );
    port(
      in_clk         : in std_logic;
      in_sensor_main : in std_logic;
      in_main_walk   : in std_logic;
      in_side_walk   : in std_logic;
      out_main_red   : out std_logic;
      out_main_yellow: out std_logic;
      out_main_green : out std_logic;
      out_side_red   : out std_logic;
      out_side_yellow: out std_logic;
      out_side_green : out std_logic;
      out_main_walk  : out std_logic;
      out_side_walk  : out std_logic
    );
  end component;

  -- Signals for inputs to the FSM
  signal clk_tb         : std_logic := '0';
  signal sensor_main_tb : std_logic := '0';
  signal main_walk_tb   : std_logic := '0';
  signal side_walk_tb   : std_logic := '0';
  
  -- Signals for outputs from the FSM
  signal main_red_tb      : std_logic;
  signal main_yellow_tb   : std_logic;
  signal main_green_tb    : std_logic;
  signal side_red_tb      : std_logic;
  signal side_yellow_tb   : std_logic;
  signal side_green_tb    : std_logic;
  signal main_walk_out_tb : std_logic;
  signal side_walk_out_tb : std_logic;

  -- Clock period definition 
  constant clk_period : time := 20 ns;
  
begin

  -- Instantiate the FSM Unit Under Test (UUT)
  uut: FSM 
    generic map (
      G_sec_05 => 25   -- Use a simulation-friendly value instead of 25e6
		-- Overrides the default value; for simulation purposes, the timing is scaled down.
    )
    port map (
      in_clk         => clk_tb,
      in_sensor_main => sensor_main_tb,
      in_main_walk   => main_walk_tb,
      in_side_walk   => side_walk_tb,
      out_main_red   => main_red_tb,
      out_main_yellow=> main_yellow_tb,
      out_main_green => main_green_tb,
      out_side_red   => side_red_tb,
      out_side_yellow=> side_yellow_tb,
      out_side_green => side_green_tb,
      out_main_walk  => main_walk_out_tb,
      out_side_walk  => side_walk_out_tb
    );

  -- Clock Process: Generates a periodic clock signal
  clk_process: process
  begin
    while true loop
      clk_tb <= '0';
      wait for clk_period/2;
      clk_tb <= '1';
      wait for clk_period/2;
    end loop;
  end process;

  -- Stimulus Process: Applies the test cases sequentially
  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Scenario a: All inputs off (normal operation mode)
    --------------------------------------------------------------------
    sensor_main_tb <= '0';
    main_walk_tb   <= '0';
    side_walk_tb   <= '0';
    wait for 300 ms; 

	 --------------------------------------------------------------------
    -- Scenario b: Main street sensor is on (extend main green phase)
    --------------------------------------------------------------------
    sensor_main_tb <= '1';
    wait for 100 ms;
    sensor_main_tb <= '0';
    wait for 300 ms;
	 
    --------------------------------------------------------------------
    -- Scenario c: Only main_walk pressed individually
    --------------------------------------------------------------------
    sensor_main_tb <= '0';  -- sensor off
    main_walk_tb   <= '1';  -- press main walk
    side_walk_tb   <= '0';
    wait for 100 ms;         
    main_walk_tb   <= '0';
    wait for 300 ms;        

    --------------------------------------------------------------------
    -- Scenario d: Only side_walk pressed individually
    --------------------------------------------------------------------
    sensor_main_tb <= '0';  -- sensor off
    main_walk_tb   <= '0';
    side_walk_tb   <= '1';  -- press side walk
    wait for 100 ms;        
    side_walk_tb   <= '0';
    wait for 300 ms;    

    --------------------------------------------------------------------
    -- Scenario e: Both walk buttons pushed simultaneously
    --------------------------------------------------------------------
    sensor_main_tb <= '0';
    main_walk_tb   <= '1';
    side_walk_tb   <= '1';
    wait for 100 ms;
    sensor_main_tb <= '0';
    main_walk_tb   <= '0';
    side_walk_tb   <= '0';
    wait for 300 ms;	 
	 
	 
	 --------------------------------------------------------------------
    -- Scenario f: side_walk pressed while sensor is on
    --------------------------------------------------------------------
    sensor_main_tb <= '1';  -- sensor off
    main_walk_tb   <= '0';
    side_walk_tb   <= '1';  -- press side walk
    wait for 100 ms;        
    side_walk_tb   <= '0';
    wait for 300 ms;        
	 
	 --------------------------------------------------------------------
    -- Scenario g: main_walk pressed while sensor is on
    --------------------------------------------------------------------
    sensor_main_tb <= '1';  -- sensor off
    main_walk_tb   <= '1';
    side_walk_tb   <= '0';  -- press side walk
    wait for 100 ms;        
    side_walk_tb   <= '0';
    wait for 300 ms;        

    
    --------------------------------------------------------------------
    -- Scenario :h Both walk buttons pushed and sensor on simultaneously
    --------------------------------------------------------------------
    sensor_main_tb <= '1';
    main_walk_tb   <= '1';
    side_walk_tb   <= '1';
    wait for 100 ms;
    sensor_main_tb <= '0';
    main_walk_tb   <= '0';
    side_walk_tb   <= '0';
    wait for 300 ms;
    
    --------------------------------------------------------------------
    -- Scenario i: "X" error assigned for the sensor
    --------------------------------------------------------------------
    sensor_main_tb <= 'X';
    wait for 100 ms;
    sensor_main_tb <= '0';
    wait for 300 ms;
    
    --------------------------------------------------------------------
    -- Scenario j: "X" error assigned for both walk buttons
    --------------------------------------------------------------------
    main_walk_tb <= 'X';
    side_walk_tb <= 'X';
    wait for 100 ms;
    main_walk_tb <= '0';
    side_walk_tb <= '0';
    wait for 300 ms;
    
    wait;  -- End simulation
  end process;

end sim;
