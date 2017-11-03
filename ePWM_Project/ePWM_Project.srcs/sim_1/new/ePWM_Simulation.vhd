----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.10.2017 12:31:32
-- Design Name: 
-- Module Name: ePWM_Simulation - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ePWM_Simulation is
--  Port ( );
end ePWM_Simulation;

architecture Behavioral of ePWM_Simulation is

signal clk : std_logic := '0';
signal io_26 : std_logic := '0';
signal io_27 : std_logic := '0';
signal led0_b : std_logic := '0';
signal led1_b : std_logic := '0';
signal led2_b : std_logic := '0';
signal led3_b : std_logic := '0';


Component User is
  Port (
        clk : in std_logic;
        
        io_26 : out std_logic;
        io_27 : out std_logic;
        
        led0_b : out std_logic; 
        led1_b : out std_logic; 
        led2_b : out std_logic; 
        led3_b : out std_logic
        
        --Ja_1 : out std_logic;
        --Ja_2 : out std_logic
        );
end component;

begin

UUT : User Port Map(
                    clk => clk,
                    io_26 => io_26,
                    io_27 => io_27,
                    led0_b => led0_b,
                    led1_b => led1_b,
                    led2_b => led2_b,
                    led3_b => led3_b
                    );
                    
                    
clk <= not clk after 5ns;


end Behavioral;
