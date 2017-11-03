----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Time Base Module
-- Module Name: Time_Base
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module is the time base for the ePWM system, it generates the counter
--  signals used as the reference for the ePWM signals.
--  It also handles synchronisation pulses to synchronise with other ePWM modules. 
--
--
-- Dependencies: 
--  Clock Prescale
-- 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Entity Decleration
entity Time_Base is
    Port ( 
           TBCLK            :   in  STD_LOGIC;  

           TBCTL            :   in  unsigned (15 downto 0);
           TBSTS            :   in  unsigned (15 downto 0);
           TBPHS            :   in  unsigned (15 downto 0);
           TBPRD            :   in  unsigned (15 downto 0); 
           
           EPWMxSYNCI       :   in  std_logic;
           EPWMxSYNCO       :   out std_logic;
           
           CMPB             :   in  unsigned ( 15 downto 0 );
                     
           TBCTR            :   out unsigned (15 downto 0); 
           
           CTR_Zero         :   out std_logic;
           CTR_PRD          :   out std_logic;
           CTR_dir          :   out std_logic
           );
end Time_Base;

architecture Behavioral of Time_Base is
       
    -- A signal to buffer the counter direction
    -- It will be used internally to manage the counter and connected to
    -- an output signal for other sub modules to use
    signal CTR_dir_Buffer 		: 	std_logic := '0';
        
    -- A signal to buffer the counter value
    -- It will be read from, and written to, internally and connected to an output signal
    signal TBCTR_Buffer         :   unsigned (15 downto 0) := to_unsigned(0,16);
    
    -- Two signal buffers to show when the counter is zero or the period
    -- They will be written to in the program and then connected to an output signal
    signal CTR_Zero_Buffer      :   std_logic := '0';
    signal CTR_PRD_Buffer       :   std_logic := '0';
    
    -- A signal to show if the program has been initialised
    -- This will be used at start-up and then set to 1 to show initailisation has ocurred
    signal Initialised          :   std_logic := '0';
    
    -- A signal to enable the period register shadowing
    -- This signal will act as the active period register
    signal TBPRD_Active         :   unsigned ( 15 downto 0) := TBPRD;
     
    -- A signal used as a buffer for the output synchronisation signal
    -- It will be operated on within the program and connected to an output signal 
    signal EPWMxSYNCO_Buffer    :   std_logic := '0';

    -- A signal to prevent continuous synchronisation if the synch input is held
    signal SYNC_Activated       :   std_logic := '0';
    
begin


process (TBCLK)


begin
    
    -- Operate on every rising edge
    if rising_edge(TBCLK) then
        
    
            -- TBPRD Shadowing
            
            -- If PRDLD, TBCTL bit 3, is set to 0 then the shadow register is enabled
            -- Only update TBPRD_active when the counter is at 0
            -- If PRDLD is at 1 then update TBPRD immediately
            
            if ( (TBCTL(3) = '0') and (TBCTR_Buffer = to_unsigned(0,16)) ) then
                TBPRD_active <= TBPRD;
            elsif (TBCTL(3) = '1') then
                TBPRD_active <= TBPRD;
            end if;
    
    
            -- Time Base Counter Operation
            
            
            -- Initialisation Routine
            
            -- If initialised is '0' then the system needs initialising and this routine will do that
            if ( Initialised = '0' ) then
                -- If the counter is configured as a down counter the counter will start at the period and count down
                -- The counter buffer needs to be set to the period and the direction set to down, '0'
                if (TBCTL(1) = '0' and TBCTL(0) = '1') then
                    
                    TBCTR_Buffer <= TBPRD;
                    CTR_dir_Buffer <= '0';
                
                -- If the counter is configured as an up, or up down, counter then it will start at 0 and count to the period
                -- The counter buffer needs to be set to 0 and the direction set to up, '1'
                else
                    -- The to_unsigned function converts a decimal to an unsigned binary
                    TBCTR_Buffer <= (to_unsigned(0,16));
                    CTR_dir_Buffer <= '1';
                end if;
                
                -- The start variable needs to be set to '1' to represent that the program is initialised
                Initialised <= '1';
            
            
            -- Synchronisation Routine
            
            -- If the program recieves an input synch pulse then this will run
            elsif ( EPWMxSYNCI = '1' and SYNC_Activated = '0') then
                
                -- If the control register directs the phase register to be used at the counter starting point
                -- Set the counter buffer to the phase value
                if ( TBCTL(2) = '1' ) then
                    
                    -- If the phase register is less than the period then store it as the current counter value
                    -- If not, then ignore the phase register and use the default values
                    if (TBPHS <= TBPRD) then
                        TBCTR_Buffer <= TBPHS;
                    elsif (TBCTL(1) = '0' and TBCTL(0) = '1') then
                        TBCTR_Buffer <= TBPRD;
                    else
                        TBCTR_Buffer <= to_unsigned(0,16);   
                    end if;
                    
                    -- Set the direction, down for a down counter, up for an up counter, and based on the control register for an up down counter
                    if (TBCTL(1) = '0' and TBCTL(0) = '1') then
                        CTR_dir_Buffer <= '0';
                    elsif (TBCTL(1) = '0' and TBCTL(0) = '0') then
                        CTR_dir_Buffer <= '1';
                    else
                        if (TBCTL(13) = '1') then
                            CTR_dir_Buffer <= '1';
                        else
                            CTR_dir_Buffer <= '0';
                        end if;
                    end if;
                
                -- If the phase register isn't used and this is a down counter set the counter to the period and direction to down
                elsif ( TBCTL(2) = '0' and TBCTL(1) = '0' and TBCTL(0) = '1') then
                    
                    -- Use the user controlled register to ensure an accurate response                    
                    TBCTR_Buffer <= TBPRD;
                    CTR_dir_Buffer <= '0';
                    
                -- If the phase register isn't used and this is an up counter set the counter to 0 and direction to up    
                elsif (TBCTL(2) = '0' and TBCTL(1) = '0' and TBCTL(0) = '0') then
                    -- The to_unsigned function converts a decimal to an unsigned binary
                    TBCTR_Buffer <= (to_unsigned(0,16));
                    CTR_dir_Buffer <= '1';
                    
                -- If the phase register isn't used and this is an up down counter set the counter to 0 and direction based on the control register
                elsif (TBCTL(2) = '0' and TBCTL(1) = '1' and TBCTL(0) = '0') then   
                    TBCTR_Buffer <= (to_unsigned(0,16));
                    if (TBCTL(13) = '1') then
                        CTR_dir_Buffer <= '1';
                    else
                        CTR_dir_Buffer <= '0';
                    end if;
                end if;
            
                -- Set the SYNCH activated signal to '1' to allow the counter to operate
                SYNC_Activated <= '1';
                
                -- Force an immediate loading of the period into the shadow register when a synch occurs
                TBPRD_active <= TBPRD;

            
            -- Standard Operation
            
            -- If the program is initialised and not at a synch pulse then the rest of program can run
            else 
                 
                -- Up Counter Mode
                
                if (TBCTL(1) = '0' and TBCTL(0) = '0') then
                
                    -- In up mode the counter goes from zero to the period and overloads back to 0
                    -- We can check if the counter is at the period, if it is then the counter can be reset back to 0
                    -- If it is not at the period then it can be incremented by 1
                    if (TBCTR_Buffer = TBPRD_active) then
                        TBCTR_Buffer <= (to_unsigned(0,16));    
                    else
                        TBCTR_Buffer <= (TBCTR_Buffer + 1);   
                    end if;
                    
                    -- Ensure the direction is set to 1
                    CTR_dir_buffer <= '1';
                    
                end if;
                
                -- Down Counter Mode
                
                if (TBCTL(1) = '0' and TBCTL(0) = '1') then
                    
                    -- In down mode the counter goes from the period to 0 and overloads back to the period
                    -- If the counter is at 0 then it can be reset to the period
                    -- If it is not at 0 then it can be decrented by 1
                    if ( TBCTR_Buffer = (to_unsigned(0,16))) then
                        TBCTR_Buffer <= TBPRD_active;

                    else
                        TBCTR_Buffer <= (TBCTR_Buffer - 1);
                    end if;
                    
                    -- Ensure the direction is set to 0
                    CTR_dir_buffer <= '0';
                    
                end if;
                
                -- Up Down Counter Mode
                
                if (TBCTL(1) = '1' and TBCTL(0) = '0') then
                    
                    -- In up down mode the counter goes from 0 ( assumed starting point, this can be different on a phase synchronisation )
                    -- It then counts to the period (initial direction can also be changed on a synch input) and reverses direction to count
                    -- back to 0
                    
                    -- If the direction is to count up, then we can check if the counter is at the period
                    -- If it is then the counter should be decreased by 1 and have the direction reversed
                    -- Doing this ensures that the correct direction is maintained and that the counter only holds a value for 1 clock pulse
                    
                    -- If it is not at the period then the counter can be incremented by 1
                    
                    if (CTR_dir_Buffer = '1') then
                                          
                        if (TBCTR_Buffer = TBPRD_active) then

                            TBCTR_Buffer <= (TBCTR_Buffer - 1);
                            CTR_dir_Buffer <= not CTR_dir_Buffer;
                            
                        else 
                            TBCTR_Buffer <= (TBCTR_Buffer + 1);
                        end if;
                    
                    -- If direction is to count down then we can check if the counter is at 0
                    -- If it is then the counter can be incremented by 1 and the direction can be reversed
                    
                    -- If it is not then the counter can be decremented by 1
                    
                    else
                        if (TBCTR_Buffer = (to_unsigned(0,16))) then
                            TBCTR_Buffer <= (TBCTR_Buffer + 1);
                            CTR_dir_Buffer <= not CTR_dir_Buffer;
                            
                        else
                            TBCTR_Buffer <= (TBCTR_Buffer - 1);
                        end if;
                        
                    end if;

                end if;
                
                -- If the SYNCH input is not active then ensure that the SYNCH activated signal is 0
                if (EPWMxSYNCI = '0') then
                    SYNC_Activated <= '0';
                end if;
                
            end if;
        

            -- A pulse needs to be sent when the counter is at 0 and the period
            -- This is used for logic throught the ePWM program
            
            -- If the counter is at 0, or the period, then set the respective signal buffer to '1'
            -- if it isn't at 0 or the period, then the respective buffers should be set to 0
            if (TBCTR_Buffer = to_unsigned(0,16) and (Initialised = '1')) then
                CTR_Zero_Buffer <= '1';
            else
                CTR_Zero_Buffer <= '0';
            end if;
            
            if (TBCTR_Buffer = TBPRD_active and (Initialised = '1')) then
                CTR_PRD_Buffer <= '1';
            else
                CTR_PRD_Buffer <= '0';
            end if;
            
            
            
            -- Synchronisation Outputs
            
            -- Read SYNCOSEL, TBCTL bits 5 and 4, and set the output synch pulse based on
            -- the input pulse, the counter reaching 0, or the counter reaching compare B
            if (TBCTL(5) = '0' and TBCTL(4) = '0') then
                EPWMxSYNCO_Buffer <= EPWMxSYNCI;
            elsif (TBCTL(5) = '0' and TBCTL(4) = '1') then    
                if (TBCTR_Buffer = to_unsigned(0,16)) then
                    EPWMxSYNCO_Buffer <= '1';
                else
                    EPWMxSYNCO_Buffer <= '0';
                end if;
            elsif (TBCTL(5) = '1' and TBCTL(4) = '0') then    
                if (TBCTR_Buffer = CMPB) then
                    EPWMxSYNCO_Buffer <= '1';
                else
                    EPWMxSYNCO_Buffer <= '0';
                end if;
            end if;    
        
        end if; 
    

end process;

-- Assign the internal buffer signals to their corresponding output signals
TBCTR       <=  TBCTR_Buffer;
CTR_Zero    <=  CTR_Zero_Buffer;
CTR_PRD     <=  CTR_PRD_Buffer;
CTR_dir     <=  CTR_dir_Buffer;
EPWMxSYNCO  <=  EPWMxSYNCO_Buffer;

end Behavioral;