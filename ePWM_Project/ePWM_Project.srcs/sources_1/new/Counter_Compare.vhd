----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Counter Compare Module
-- Module Name: Counter_Compare
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module is the counter compare for the ePWM system, it compares the counter
--  to the two compare values, outputting a 1 when the comparison is true. 
--
--
-- Dependencies: 
--  Clock Prescale
--  Time Base
-- 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Counter_Compare is
    Port (  
            TBCLK       :   in  std_logic;
            CMPA        :   in  unsigned ( 15 downto 0 );
            CMPB        :   in  unsigned ( 15 downto 0 );
            CMPCTL      :   in  unsigned ( 15 downto 0 );
            
            TBCTR       :   in  unsigned ( 15 downto 0 );
            
            CTR_PRD     :   in  std_logic;
            CTR_Zero    :   in  std_logic;
            
            CTR_CMPA    :   out std_logic;
            CTR_CMPB    :   out std_logic
          );
end Counter_Compare;

architecture Behavioral of Counter_Compare is

    -- Two signals to show if a compare A or compare B event is true
    -- These will acts as buffers so that the logic program can operate
    signal CMPA_True : STD_LOGIC;
    signal CMPB_True : STD_LOGIC;

    -- Two signals are needed to hold the 'active compare registers'
    -- The input register CMPA and CMPB are considered shadow registers
    -- They are then loaded into the active register that is internal to the module
    signal CMPA_Active : unsigned ( 15 downto 0 );
    signal CMPB_Active : unsigned ( 15 downto 0 );
    
    -- Another signal to load the register on start up is also used to ensure that there
    -- is a compare value when the program begins, this is similar to the initialised
    -- signal from the timer base module and is called the same
    signal Initialised : std_logic := '0';
     
begin

process(TBCLK)

begin

-- Operate on every rising clock edge
if (rising_edge(TBCLK)) then
    
    -- Shadowing Process
    
    -- Load to the active register on startup (Start = '0')
    if (Initialised = '0') then
        CMPA_Active <= CMPA;
        CMPB_Active <= CMPB;
        Initialised <= '1';
    end if;
    
    -- If CMPCTL bit 6 is 1 when then the CMPB shadow register is bypassed, load it immediately
    if (CMPCTL(6) = '1') then
        CMPB_Active <= CMPB;
    end if;
    
    -- The same occurs for CMPA on bit 4
    if (CMPCTL(4) = '1') then
        CMPA_Active <= CMPA;
    end if;
    
    -- Load based on the load mode
    -- Bits 3 and 2 are for CMPB, "00" for load at 0, "01" for load at PRD, "10" for load at either
    -- A "11" sequence is to not load at all, this can be achieved by not programming a response for it
    if ( (CTR_Zero = '1') and ( (CMPCTL(3) = '0' and CMPCTL(2) = '0') or (CMPCTL(3) = '1' and CMPCTL(2) = '0') ) ) then
        CMPB_Active <= CMPB;
    elsif ( (CTR_PRD = '1') and ( (CMPCTL(3) = '0' and CMPCTL(2) = '1') or (CMPCTL(3) = '1' and CMPCTL(2) = '0') ) ) then
        CMPB_Active <= CMPB;
    end if;
    
    -- The same process occurs for CMPB using bits 1 and 0    
    if ( (CTR_Zero = '1') and ( (CMPCTL(1) = '0' and CMPCTL(0) = '0') or (CMPCTL(1) = '1' and CMPCTL(1) = '0') ) ) then
        CMPA_Active <= CMPA;
    elsif ( (CTR_PRD = '1') and ( (CMPCTL(1) = '0' and CMPCTL(0) = '1') or (CMPCTL(1) = '1' and CMPCTL(1) = '0') ) ) then
        CMPA_Active <= CMPA;
    end if;
        
        
    -- Compare Process    
        
    -- If the time base counter is at compare A then set CMPA_True to '1'
    -- If it is not then set CMPA_True to '0'
    if (TBCTR = CMPA_Active) then
        CMPA_True <= '1';
    else
        CMPA_True <= '0';
    end if;

    -- If the time base counter is at compare B then set CMPB_True to '1'
    -- If it is not then set CMPB_True to '0'
    if (TBCTR = CMPB_Active) then
        CMPB_True <= '1';
    else
        CMPB_True <= '0';
    end if;
end if;    
    
end process;

-- Pass the CMPx_True signals through to the output signals
CTR_CMPA <= CMPA_True;
CTR_CMPB <= CMPB_True;

end Behavioral;
