----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Trip Zone
-- Module Name: Trip Zone
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  The trip zone madule handles hardware and software trip signals
--  They are an active low state, if any fall to '0' the corresponding one shot 
--  or cycle by cycle trip occurs, diving the signal to the desired state
--
--  A flag is set when the first trip occurs, it can be cleared to re-enable.
--  An interrupt can also be generated, when an interrupt signal is sent, 
--  another cannot be sent until the interrupt flag bit has been cleared.
--  If the interrupt flag bit is cleared but a trip flag on a line that can
--  generate and interrupt is still high, another interrupt will be retriggered.
--
--
-- Dependencies: 
--  None for trip operateion
--  Action Qualifier and Dead Band to pass an ePWM through
--  
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Trip_Zone is
    Port (  
            clk                             :   in  std_logic;
            TZ1, TZ2, TZ3, TZ4, TZ5, TZ6    :   in  std_logic;

            TZSEL                           :   in  unsigned (15 downto 0);
            TZCTL                           :   in  unsigned (15 downto 0);
            TZEINT                          :   in  unsigned (15 downto 0);
            
            TZCLR                           :   in  unsigned (15 downto 0);
            TZFRC                           :   in  unsigned (15 downto 0) := "0000000000000000";

            CTR_Zero                        :   in  std_logic;

            ePWMA_DB_Output                 :   in  std_logic := '0';
            ePWMB_DB_Output                 :   in  std_logic := '0';

            TZFLG                           :   out unsigned (15 downto 0) := "0000000000000000";

            ePWMA_TZ_Output                 :   out std_logic := '0';
            ePWMB_TZ_Output                 :   out std_logic := '0';
            
            TZ_Interrupt                    :   out std_logic := '0'
          );
end Trip_Zone;

architecture Behavioral of Trip_Zone is


    -- Signals to show if the one short and cycle by cycle trips are active
    -- These are 0 at start up, showing that the trip isn't actvive
    signal TZ_One_Shot_Active     :   std_logic := '0';
    signal TZ_Cy_by_Cy_Active     :   std_logic := '0';

    -- A buffer to store the flag signals and allow for the signals to be latched
    signal TZ_Flag_Buffer : std_logic_vector ( 2 downto 0) := "000";

    -- A buffer to manage the interrupt signal
    signal TZ_Interrupt_Buffer : std_logic := '0';
    
    -- A signal to command if an interrupt has already been sent
    -- After one interrupt is sent another cannot be triggered until the clear bit used
    signal TZ_Interrupt_Available : std_logic := '1';

    -- Signals to hold the tripped output states
    -- This will be used to command what output should be used when a trip occurs
    -- If a trip occurs this will become the output, otherwise the input will be passed through
    signal ePWMA_Tripped_Output : std_logic := '0';
    signal ePWMB_Tripped_Output : std_logic := '0';


begin

process(clk)

begin

    -- Run the process ever rising clock edge
    if (rising_edge(clk)) then

       
        -- Determine if a trip is active
        
        -- The one shot trip is active if any of the assigned one shot trip signals are low, this can be found as the signal
        -- or-ed with its respective control bit, if it is to be used then the control will be 1, its inverse is 0, and the input signal
        -- itself will determine if the condition is high or low. If the control bit is 0 then it is not used, its inverse is 1, forcing the
        -- condition to always be 1, regardless of the input
        
        -- If all of these conditions are 1 then a trip has not occured, so set the one shot active signal to 0
        -- Otherwise a trip has occured and the one shot signal should be set to 0
        -- If enabled then the one shot interrupt should also be driven high, if it is not already high
        
        -- The software force bit can also cause a trip
        

        if ( (TZFRC(2)='0') nand  ((TZ6 or (not TZSEL(13))) = '1' and (TZ5 or (not TZSEL(12))) = '1' and (TZ4 or (not TZSEL(11))) = '1' and
            (TZ3 or (not TZSEL(10))) = '1' and (TZ2 or (not TZSEL(9))) = '1' and (TZ1 or (not TZSEL(8))) = '1')) then
        
            TZ_One_Shot_Active <= '1';
            
            if ( TZEINT(2) = '1') then
                TZ_Interrupt_Buffer <= '1';
            end if; 
            
        end if; 
        
        -- The same process can be repeated for cycle by cycle trips

        if ( (TZFRC(1) = '0') nand ( (TZ6 or (not TZSEL(5))) = '1' and (TZ5 or (not TZSEL(4))) = '1' and (TZ4 or (not TZSEL(3))) = '1' and
             (TZ3 or (not TZSEL(2))) = '1' and (TZ2 or (not TZSEL(1))) = '1' and (TZ1 or (not TZSEL(0))) = '1' )) then
        
            TZ_Cy_by_Cy_Active <= '1';
            
            if ( TZEINT(1) = '1') then
                TZ_Interrupt_Buffer <= '1';
            end if; 
                            
        end if; 
        
        
        
        -- Determine the tripped output states
        
        -- If a trip occurs then the output can be driven high, low or be unchanged
        -- Set the tripped output signal appropriately, if the control is 00 or 01 then drive high
        -- If the control is 10 then drive low, if 11 then it is unchanged
        
        -- Follow that logic for the B output
        if ((TZCTL(3) = '0' and TZCTL(2) = '0') or (TZCTL(3) = '0' and TZCTL(2) = '1')) then
            ePWMB_Tripped_Output <= '1';
        elsif (TZCTL(3) = '1' and TZCTL(2) = '0') then
            ePWMB_Tripped_Output <= '0';   
        end if;
        
        -- Follow the same process for the A output using its control bits
        if ((TZCTL(1) = '0' and TZCTL(0) = '0') or (TZCTL(1) = '0' and TZCTL(0) = '1')) then
            ePWMA_Tripped_Output <= '1';
        
        elsif (TZCTL(1) = '1' and TZCTL(0) = '0') then
            ePWMA_Tripped_Output <= '0';           
        end if;
    
    
    
        -- Resetting Procedure
        
        -- The counter is at 0, or the cycle by cycle clear register is set to '1' and the cycle by cycle active signal is '1'
        -- Then disable the cycle by cycle active signal, set it to '0', as long as none of the trip signals are still active
        if ( (( CTR_Zero = '1' ) or (TZCLR(1)='1')) and (TZ_Cy_by_Cy_Active = '1') and 
            ((TZ6 or (not TZSEL(5))) = '1' and (TZ5 or (not TZSEL(4))) = '1' and (TZ4 or (not TZSEL(3))) = '1' and
            (TZ3 or (not TZSEL(2))) = '1' and (TZ2 or (not TZSEL(1))) = '1' and (TZ1 or (not TZSEL(0))) = '1') ) then
            
            
            TZ_Cy_by_Cy_Active <= '0';    

            
        end if;
    
    
        -- If the one shot active signal is at '1' and the one shot clear register is '1'  and the trip signals are not still active,
        -- then reset the one shot active signal
        if ((TZCLR(2)='1') and (TZ_One_Shot_Active = '1') and 
            (((TZ6 or (not TZSEL(13))) = '1' and (TZ5 or (not TZSEL(12))) = '1' and (TZ4 or (not TZSEL(11))) = '1' and
              (TZ3 or (not TZSEL(10))) = '1' and (TZ2 or (not TZSEL(9))) = '1' and (TZ1 or (not TZSEL(8))) = '1' )) ) then
                    
            TZ_One_Shot_Active <= '0';
                
        end if;
        
 
        -- Flag Procedure
        
        -- If one of the active signals or the interrupt is set to '1' then set the corresponding flag bit to '1'
        if ( TZ_One_Shot_Active = '1' ) then
            TZ_Flag_Buffer(2) <= '1';
        end if;
        if ( TZ_Cy_by_Cy_Active = '1' ) then
            TZ_Flag_Buffer(1) <= '1';
        end if;
        if (((TZ_Interrupt_Buffer = '1') or ((TZ_Flag_Buffer(2) = '1') and (TZEINT(2) = '1'))  or ((TZ_Flag_Buffer(1) = '1') and (TZEINT(1) = '1'))) and (TZ_Interrupt_Available = '1')) then
            TZ_Flag_Buffer(0) <= '1';
            TZ_Interrupt_Available <= '0';
            TZ_Interrupt_Buffer <= '0';
        end if;
        
        
        -- Only reset the flag back to '0' when the appropriate clear bit has been set to '1'
        if ( TZCLR(2) = '1' ) then
            TZ_Flag_Buffer(2) <= '0';
        end if;
        if ( TZCLR(1) = '1' ) then
            TZ_Flag_Buffer(1) <= '0';
        end if;
        if (TZCLR(0) = '1' ) then
            TZ_Flag_Buffer(0) <= '0';
            TZ_Interrupt_Available <= '1';
        end if;
    
    end if;
           
end process;

-- Pass the flag buffer into the output flag signals
TZFLG(2) <= TZ_Flag_Buffer(2);
TZFLG(1) <= TZ_Flag_Buffer(1);
TZFLG(0) <= TZ_Flag_Buffer(0);

-- Send the interrupt signal
-- As propogration delay causes the interrupt available signal to go to '0' one clock 
-- pulse after the interrupt buffer goes high, this allows the interrupt signal to be a single pulse wide 
TZ_Interrupt <= (TZ_Interrupt_Buffer ) and TZ_Interrupt_Available;

-- If neither trips have been active the pass the input ePWM signal to the output, otherwise pass the tripped output signal to the output
ePWMA_TZ_Output <= (ePWMA_DB_Output and ((TZ_One_Shot_Active nor TZ_Cy_by_Cy_Active) or (TZCTL(0) and TZCTL(1)) )) or (EPWMA_Tripped_Output and ((TZ_One_Shot_Active or TZ_Cy_by_Cy_Active))) ;
ePWMB_TZ_Output <= (ePWMB_DB_Output and ((TZ_One_Shot_Active nor TZ_Cy_by_Cy_Active) or (TZCTL(2) and TZCTL(3)) )) or (EPWMB_Tripped_Output and ((TZ_One_Shot_Active or TZ_Cy_by_Cy_Active))) ;

end Behavioral;