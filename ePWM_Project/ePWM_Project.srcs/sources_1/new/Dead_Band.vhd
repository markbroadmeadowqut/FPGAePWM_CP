----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Dead Band Module
-- Module Name: Dead_Band
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module introduces dead banding between the two ePWM output.
--  The specifics of the dead band generation vary heavily based on how the
--  module is configured. Typically it is used to ensure that whatever the
--  ePWM waveforms are driving cannot be activated simultaneously.
-- 
--  A H-bridge configuration for example will short out if both switch sets are
--  active simultaneously.
--
--
-- Dependencies: 
--  Clock Prescale
--  Action Qualifier
-- 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;



entity Dead_Band is
    Port ( 
            TBCLK               : in std_logic;
            ePWMA_AQ_Output     : in std_logic;
            ePWMB_AQ_Output     : in std_logic;
                        
            DBCTL               : in  unsigned(15 downto 0);                      
            DBRED               : in  unsigned ( 15 downto 0 );
            DBFED               : in  unsigned (15 downto 0);
            
            ePWMA_DB_Output        : out std_logic;
            ePWMB_DB_Output        : out std_logic              
            );
                        
end Dead_Band;

architecture Behavioral of Dead_Band is
    
    -- A signal is needed to show if any of the counters are active
    -- There are four counters, two rising edge and two falling edge
    signal ePWMA_rising_count_active    : std_logic := '0';
    signal ePWMA_falling_count_active   : std_logic := '0';
    signal ePWMB_rising_count_active    : std_logic := '0';
    signal ePWMB_falling_count_active   : std_logic := '0';
    
    -- Signals are needed to show the counter based outputs
    -- Again there are two rising edge outputs and two falling edge outputs
    signal ePWM_A_rising_delay_output   : std_logic := '0';
    signal ePWM_B_rising_delay_output   : std_logic := '0';
    signal ePWM_A_falling_delay_output  : std_logic := '0';
    signal ePWM_B_falling_delay_output  : std_logic := '0';
    
    -- Four counters are also needed
    -- The counters are 10 bit counters, so four 10 bit binary signals are needed
    signal ePWMA_rising_count           : unsigned(9 downto 0) := "0000000000";
    signal ePWMA_falling_count          : unsigned(9 downto 0) := "0000000000";
    signal ePWMB_rising_count           : unsigned(9 downto 0) := "0000000000";
    signal ePWMB_falling_count          : unsigned(9 downto 0) := "0000000000";
    
    -- Two buffer signals are then needed to store the ePWM outputs before directing them
    -- to the module outputs
    signal ePWMA_Buffer                 : std_logic;
    signal ePWMB_Buffer                 : std_logic;

    signal ePWMA_AQ_delayed : std_logic;
    signal ePWMB_AQ_delayed : std_logic;

begin

-- The dead band process will rely on the TB Clock and the two input epwm signals to determine when to operate
-- Counter operation will occur on rising edges of the TB clock, as will output selection
-- Counter triggering will be done on epwm edges, rising edge counts triggered on their rising edges and falling edge counts on the falling edge
process ( TBCLK )

begin

    -- Operate every rising clock edge
    if (rising_edge(TBCLK)) then
    
    
        -- ePWM Delaying
        -- This stores the current ePWM values into the delayed signals
        -- This will not take effect until one clock cycle later, giving us a 1 clock cycle delay
        ePWMA_AQ_delayed <= ePWMA_AQ_Output;
        ePWMB_AQ_delayed <= ePWMB_AQ_Output;
    
    
        -- Counter Triggering
        -- Various dead band effects should be triggered on a rising and falling edge of the input
        -- ePWM signal. This edge detection is done by comparing the current signal value, to the
        -- delayed signal.
    
        -- When the ePWM input signal is rising, the the rising edge delay counter should start
        -- This is done by setting the rising_count_active signal to '1'
        -- A falling edge delayed signal is also set to rise on the rising edge
        -- So the falling delay output is set to '1'
        if ( ePWMA_AQ_Output = '1' and ePWMA_AQ_delayed = '0' ) then 
        
            ePWMA_rising_count_active <= '1';       
            ePWM_A_falling_delay_output <= '1';
            
            if (ePWMA_falling_count_active = '1') then
                ePWMA_falling_count_active <= '0';
                ePWMA_falling_count <= to_unsigned(0,10);
            end if;
            
        
        -- When the ePWM input is dalling the falling edge counter should start
        -- Set the falling_count_active signal to '1'
        -- A rising edge delayed output should also be set to '0' when the input falls
        -- Set the rising delay output to '0'
        elsif (ePWMA_AQ_Output = '0' and ePWMA_AQ_delayed = '1') then
            
            ePWMA_falling_count_active <= '1'; 
            ePWM_A_rising_delay_output <= '0';
            
            if (ePWMA_rising_count_active = '1') then
                ePWMA_rising_count_active <= '0';
                ePWMA_rising_count <= to_unsigned(0,10);
            end if;
            
        end if;
        
        -- The same process is then repeated for ePWM input B
        if (ePWMB_AQ_Output = '1' and ePWMB_AQ_delayed = '0') then
        
            ePWMB_rising_count_active <= '1';       
            ePWM_B_falling_delay_output <= '1';
            
            if (ePWMB_falling_count_active = '1') then
                ePWMB_falling_count_active <= '0';
                ePWMB_falling_count <= to_unsigned(0,10);
            end if;
            

    
        elsif (ePWMB_AQ_Output = '0' and ePWMB_AQ_delayed = '1') then 
            
            ePWMB_falling_count_active <= '1';       
            ePWM_B_rising_delay_output <= '0';
            
            if (ePWMB_rising_count_active = '1') then
                ePWMB_rising_count_active <= '0';
                ePWMB_rising_count <= to_unsigned(0,10);
            end if;
            
        end if;
    
        -- Ensure the counters are reset when the counter active signal is not enabled
        if (ePWMA_falling_count_active = '0') then
            ePWMA_falling_count <= to_unsigned(0,10);
        end if;
        if (ePWMA_rising_count_active = '0') then
            ePWMA_rising_count <= to_unsigned(0,10);
        end if;
        if (ePWMB_falling_count_active = '0') then
            ePWMB_falling_count <= to_unsigned(0,10);
        end if;
        if (ePWMB_rising_count_active = '0') then
            ePWMB_rising_count <= to_unsigned(0,10);
        end if;
        
        
        -- Counter Operation
        
        
        -- ePWMA causing a rising edge delay
        
        -- The rising edge counter should activate when the rising count active signal has been set to '1'
        -- The procedure check is the ePWMA rising edge counter is at the rising delay period
        -- If it is then the counter is reset to zero, the counter active signal is cleared and the output ePWM is set
        -- A rising edge delay drives the output high after a given delay, it is cleared to a low state at the same time as the input
        -- If the delay is longer than the ePWM active time, then the input will already have been cleared, in this case the output should
        -- not be set, if the input signal is still high then the output can also be driven high
        -- If the counter has not overflowed then the counter can be incremented by 1
         
        if (ePWMA_rising_count_active = '1' ) then
        
            if ( ePWMA_rising_count = DBRED ) then
                ePWMA_rising_count <= to_unsigned(0,10);
                ePWMA_rising_count_active <= '0';
                
                if ( ePWMA_AQ_Output = '1') then
                    ePWM_A_rising_delay_output <= '1';
                end if;
            
            else
                ePWMA_rising_count <= ePWMA_rising_count + 1;
            
            end if;
        
        end if;
    
    
        -- The same process is followed for the falling edge delay counter
        -- The only difference is how the output is driven
        -- The falling edge delay drives the output low after the counter overloads
        -- The input signal will fall to zero when this counter begins, so if the input
        -- is now at '1' then the output should not be driven to '0'
        -- If the input is still at zero then output can be driven low
    
        if (ePWMA_falling_count_active = '1' ) then
        
        
            if ( ePWMA_falling_count = DBFED ) then
                ePWMA_falling_count <= to_unsigned(0,10);
                ePWMA_falling_count_active <= '0';
                
                if (ePWMA_AQ_Output = '0') then
                    ePWM_A_falling_delay_output <= '0';
                end if;
                
            else
                ePWMA_falling_count <= ePWMA_falling_count + 1;
            
            end if;
        
        end if;
        
        -- The same process is followed for the ePWM B input signals
        
        if (ePWMB_rising_count_active = '1' ) then
            
            
            if ( ePWMB_rising_count = DBRED ) then
                ePWMB_rising_count <= to_unsigned(0,10);
                ePWMB_rising_count_active <= '0';
                
                if (ePWMB_AQ_Output = '1') then
                    ePWM_B_rising_delay_output <= '1';
                end if;
             
            else
                ePWMB_rising_count <= ePWMB_rising_count + 1;
                
            end if;
            
        end if;
            
        -- The same process is followed again for the ePWM B falling edge delay    
            
        if (ePWMB_falling_count_active = '1') then
             
    
            if ( ePWMB_falling_count = DBFED ) then
                ePWMB_falling_count <= to_unsigned(0,10);
                ePWMB_falling_count_active <= '0';
                
                if (ePWMB_AQ_Output = '0') then
                    ePWM_B_falling_delay_output <= '0';
                end if;
                                
            else
                ePWMB_falling_count <= ePWMB_falling_count + 1;
                  
            end if;
                
        end if;


        -- Output Selection
    
        -- The output is selected through the use of the switching diagram in the TI datasheet
        -- All possible outputs are continuously generated through the counter system
        -- The swicthes are represented as bits in the control register, where switch 0 is bit 0
        -- switch 1 is bit 1 etc
        -- The switching diagram is followed, and the appropriate outputs are selected and
        -- loaded into the output buffer
         
        -- Output A selection
         
        if ( DBCTL(1) = '0') then
            ePWMA_Buffer <= ePWMA_AQ_Delayed;
        else
             
            if ( DBCTL(2) = '0' ) then
                if (DBCTL(4) = '0') then
                    ePWMA_Buffer <= ePWM_A_rising_delay_output;
                     
                else
                    ePWMA_Buffer <= ePWM_B_rising_delay_output;
                end if;
                 
            else
                if (DBCTL(4) = '0') then
                    ePWMA_Buffer <= not ePWM_A_rising_delay_output;
                             
                else
                    ePWMA_Buffer <= not ePWM_B_rising_delay_output;
                end if;
            end if;
        end if;    
        
        -- Output B selection
             
        if ( DBCTL(0) = '0') then
                ePWMB_Buffer <= ePWMB_AQ_Delayed;
            else
                 
                if ( DBCTL(3) = '0' ) then
                    if (DBCTL(5) = '0') then
                        ePWMB_Buffer <= ePWM_A_falling_delay_output;
                         
                    else
                        ePWMB_Buffer <= ePWM_B_falling_delay_output;
                    end if;
                     
                else
                    if (DBCTL(5) = '0') then
                        ePWMB_Buffer <= not ePWM_A_falling_delay_output;
                                 
                    else
                        ePWMB_Buffer <= not ePWM_B_falling_delay_output;
                    end if;
                end if;
            end if;         
       
        end if;
    

end process;

-- Load the output buffer into the output signal
ePWMA_DB_Output <= ePWMA_Buffer;
ePWMB_DB_Output <= ePWMB_Buffer;

end Behavioral;
