----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Clock Presccal Module
-- Module Name: Clock_Prescale
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module has been designed to generate the divided clock used by the
--  other modules in the ePWM system.
--  It will generate all of the divided clocks and select which one to output
--  based on the Time Base Control Register
--
-- It also scales the 100 MHz system clock down to 100 KHz
--
-- Dependencies: 
--  None
-- 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Clock_Prescale is
    Port ( 
           clk      : in    std_logic;
           TBCTL    : in    unsigned (15 downto 0);           
           TBCLK    : out   std_logic          
          );
end Clock_Prescale;

architecture Behavioral of Clock_Prescale is

    -- A signal to scale the 100MHz system clock down to 100Khz
    -- The scaling range is the ((system clock frequency / desired clock frequency) / 2) - 1
    -- For a 100 khz base clock, this value is 499, used here and at line 67
    signal Clock_Scale      : integer range 0 to 499 := 0;

    -- A 8 bit signal used to count at every 100KHz clock pulse and generate the divided clock's
    signal Clock_Counter    : unsigned (7 downto 0) := "00000000";
    
    -- A signal to hold the TBCLK that has been selected from the control register
    signal TBCLK_Buffer     : std_logic := '0';
    


begin

process(clk)

begin
    -- Operate every rising clock edge
    if rising_edge(clk) then
        

        -- Increment the clock scaling integer by 1 every rising system clock edge
        Clock_Scale <= Clock_Scale + 1;
        

        -- If the clock is at its maximum, 499, then reset it to 0 and increment the clock counter
        if (Clock_Scale = 499) then
            Clock_Scale <= 0;
            Clock_Counter <= Clock_Counter + 1;
        end if;
        
        -- Store the correct divided clock into the TBCLK buffer by checking the control bits and storing the corresponding clock
        if ( (TBCTL(12) = '0') and (TBCTL(11) = '0') and (TBCTL(10) = '0') ) then
                
            TBCLK_Buffer <= Clock_Counter(0);   
                    
        elsif ( (TBCTL(12) = '0') and (TBCTL(11) = '0') and (TBCTL(10) = '1') ) then
        
            TBCLK_Buffer <= Clock_Counter(1);
        
        elsif ( (TBCTL(12) = '0') and (TBCTL(11) = '1') and (TBCTL(10) = '0') ) then
        
            TBCLK_Buffer <= Clock_Counter(2);
        
        elsif ( (TBCTL(12) = '0') and (TBCTL(11) = '1') and (TBCTL(10) = '1') ) then
        
            TBCLK_Buffer <= Clock_Counter(3);
        
        elsif ( (TBCTL(12) = '1') and (TBCTL(11) = '0') and (TBCTL(10) = '0') ) then
        
            TBCLK_Buffer <= Clock_Counter(4);
        
        elsif ( (TBCTL(12) = '1') and (TBCTL(11) = '0') and (TBCTL(10) = '1') ) then
        
            TBCLK_Buffer <= Clock_Counter(5);
        
        elsif ( (TBCTL(12) = '1') and (TBCTL(11) = '1') and (TBCTL(10) = '0') ) then
        
            TBCLK_Buffer <= Clock_Counter(6);
        
        elsif ( (TBCTL(12) = '1') and (TBCTL(11) = '1') and (TBCTL(10) = '1') ) then
        
            TBCLK_Buffer <= Clock_Counter(7);
        
        end if;
        
        
        
end if;

end process;

-- Send the TBCLK buffer through to the TBCLK
TBCLK <= TBCLK_Buffer;

end Behavioral;
