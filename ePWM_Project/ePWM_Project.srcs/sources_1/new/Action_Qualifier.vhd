----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Action Qualifier Module
-- Module Name: Action_Qualifier
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module is the action qualifier for the ePWM system, it reflects the
--  compare signals to the output as specific actions. It can act on a CMPA or B,
--  or the counter being equal to zero or the period. Different actions can
--  also be generated based on the counter direction.
--
--  This module creates the initial ePWM waveforms.
--
--
-- Dependencies: 
--  Clock Prescale
--  Time Base
--  Counter Compare
-- 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Action_Qualifier is
    Port (  
            TBCLK               :   in  std_logic;
    
            AQCTLA              :   in  unsigned ( 15 downto 0 );
            AQCTLB              :   in  unsigned ( 15 downto 0 );
            AQSFRC              :   in  unsigned ( 15 downto 0 );
            AQCSFRC             :   in  unsigned ( 15 downto 0 );
            
            CTR_PRD             :   in  std_logic;
            CTR_Zero            :   in  std_logic;
            CTR_CMPA            :   in  std_logic;
            CTR_CMPB            :   in  std_logic;
            CTR_dir             :   in  std_logic;
            
            ePWMA_AQ_Output     :   out std_logic := '0';
            ePWMB_AQ_Output     :   out std_logic := '0'
            );
            
end Action_Qualifier;

architecture Behavioral of Action_Qualifier is


    -- Two signals to act as buffers for the ePWM output
    -- This allows the control program to operate on the buffers, 
    -- which are then connected to the output signals
    -- This also allows the current ePWM values to be written to and read from
    -- as a result the value can be toggled if that is what the control register dictates
    signal ePWM_A_Buffer    : std_logic := '0';
    signal ePWM_B_Buffer    : std_logic := '0';
    
    
    -- The continuous software force register has a shadowing option, the signle event register doesn't
    -- To account for the shadowed register an internal active register needs to be created
    signal AQCSFRC_Active   : unsigned ( 15 downto 0 );
    
    -- An initialised signal will ensure it is loaded on start up
    signal Initialised      : std_logic := '0';
    
    -- A signal will be used to indicate a single software event should occur
    -- The software forced routine will activate when OTSFB, bit 5 of AQSFRC, goes high
    -- The single event will occur and this signal will then go high
    -- This signal will reset only when OTSFB goes low, at which point another event can be triggered
    signal OTSFB_Triggered  : std_logic := '0';
    -- There is another signal for OTSFA
    signal OTSFA_Triggered  : std_logic := '0';


begin

process(TBCLK)

begin

    -- Operate every rising clock edge
    if (rising_edge(TBCLK)) then
        
        -- Software forced register shadowing
        
        -- If the program is just starting up then load the register
        if (Initialised = '0') then
            AQCSFRC_Active <= AQCSFRC;
            Initialised <= '1';
        end if;
        
        -- Use the AQSFRC register bits to determine when to load the register
        -- "00" for at zero, "01" for at the period, "10" for at either, "11" for immediately
        if ( (CTR_Zero = '1') and ( (AQSFRC(7) = '0' and AQSFRC(6) = '0') or (AQSFRC(7) = '1' and AQSFRC(6) = '0'))) then
            AQCSFRC_Active <= AQCSFRC;
        elsif ( (CTR_PRD = '1') and ( (AQSFRC(7) = '1' and AQSFRC(6) = '0') or (AQSFRC(7) = '1' and AQSFRC(6) = '0'))) then
            AQCSFRC_Active <= AQCSFRC;
        elsif ( AQSFRC(7) = '1' and AQSFRC(6) = '1' ) then
            AQCSFRC_Active <= AQCSFRC;
        end if;

        
        -- Action Qualifying ( Not Software Forced )
        
        -- If the counter direction is UP then these are the corresponding actions
        -- A compare event can then occur within this
        if ( CTR_dir = '1') then
        
            -- If the counter has reached compare A
            if (CTR_CMPA = '1') then
    
                -- Based on the control register bits, bits 5 and 4 for an up counter reaching compare A
                -- drive the output to a certain value
                -- "00" do nothing, "01" drive low, "10" drive high, "11", toggle
                if (AQCTLA(5) = '0' and AQCTLA(4) = '1') then
                    ePWM_A_Buffer <= '0';
                elsif (AQCTLA(5) = '1' and AQCTLA(4) = '0') then
                    ePWM_A_Buffer <= '1';
                elsif (AQCTLA(5) = '1' and AQCTLA(4) = '1') then
                    ePWM_A_Buffer <= not ePWM_A_Buffer;
                end if;
                
                -- Repeat the process to drive the signal appropriately
                if (AQCTLB(5) = '0' and AQCTLB(4) = '1') then
                    ePWM_B_Buffer <= '0';
                elsif (AQCTLB(5) = '1' and AQCTLB(4) = '0') then
                    ePWM_B_Buffer <= '1';
                elsif (AQCTLB(5) = '1' and AQCTLB(4) = '1') then
                    ePWM_B_Buffer <= not ePWM_B_Buffer;
                end if;
                
            end if;
            
            -- The same process is followed for a compare B event, however the control register bits are changed
            if (CTR_CMPB = '1') then
                
                -- Repeat the process to drive the signal appropriately
                if (AQCTLA(9) = '0' and AQCTLA(8) = '1') then
                    ePWM_A_Buffer <= '0';
                elsif (AQCTLA(9) = '1' and AQCTLA(8) = '0') then
                    ePWM_A_Buffer <= '1';
                elsif (AQCTLA(9) = '1' and AQCTLA(8) = '1') then
                    ePWM_A_Buffer <= not ePWM_A_Buffer;
                end if;
                
                -- Repeat the process to drive the signal appropriately
                if (AQCTLB(9) = '0' and AQCTLB(8) = '1') then
                    ePWM_B_Buffer <= '0';
                elsif (AQCTLB(9) = '1' and AQCTLB(8) = '0') then
                    ePWM_B_Buffer <= '1';
                elsif (AQCTLB(9) = '1' and AQCTLB(8) = '1') then
                    ePWM_B_Buffer <= not ePWM_B_Buffer;
                end if;
                
            end if;
            
        -- The process is repeated for if the counter is counting down    
        else
        
            if (CTR_CMPA = '1') then
            
                -- Repeat the process to drive the signal appropriately
                if (AQCTLA(7) = '0' and AQCTLA(6) = '1') then
                    ePWM_A_Buffer <= '0';
                elsif (AQCTLA(7) = '1' and AQCTLA(6) = '0') then
                    ePWM_A_Buffer <= '1';
                elsif (AQCTLA(7) = '1' and AQCTLA(6) = '1') then
                    ePWM_A_Buffer <= not ePWM_A_Buffer;
                end if;
                
                -- Repeat the process to drive the signal appropriately
                if (AQCTLB(7) = '0' and AQCTLB(6) = '1') then
                    ePWM_B_Buffer <= '0';
                elsif (AQCTLB(7) = '1' and AQCTLB(6) = '0') then
                    ePWM_B_Buffer <= '1';
                elsif (AQCTLB(7) = '1' and AQCTLB(6) = '1') then
                    ePWM_B_Buffer <= not ePWM_B_Buffer;
                end if;
                
            end if;
            
            if (CTR_CMPB = '1') then
                 
                -- Repeat the process to drive the signal appropriately           
                if (AQCTLA(11) = '0' and AQCTLA(10) = '1') then
                    ePWM_A_Buffer <= '0';
                elsif (AQCTLA(11) = '1' and AQCTLA(10) = '0') then
                    ePWM_A_Buffer <= '1';
                elsif (AQCTLA(11) = '1' and AQCTLA(10) = '1') then
                    ePWM_A_Buffer <= not ePWM_A_Buffer;
                end if;
                
                -- Repeat the process to drive the signal appropriately
                if (AQCTLB(11) = '0' and AQCTLB(10) = '1') then
                    ePWM_B_Buffer <= '0';
                elsif (AQCTLB(11) = '1' and AQCTLB(10) = '0') then
                    ePWM_B_Buffer <= '1';
                elsif (AQCTLB(11) = '1' and AQCTLB(10) = '1') then
                    ePWM_B_Buffer <= not ePWM_B_Buffer;
                end if;
                
            end if;
                   
        end if;
         
        -- If the counter is at the period then the appropriate bits can be compared and the signal driven    
        if (CTR_PRD = '1') then
        
            if (AQCTLA(3) = '0' and AQCTLA(2) = '1') then
                ePWM_A_Buffer <= '0';
            elsif (AQCTLA(3) = '1' and AQCTLA(2) = '0') then
                ePWM_A_Buffer <= '1';
            elsif (AQCTLA(3) = '1' and AQCTLA(2) = '1') then
                ePWM_A_Buffer <= not ePWM_A_Buffer;
            end if;
            
            if (AQCTLB(3) = '0' and AQCTLB(2) = '1') then
                ePWM_B_Buffer <= '0';
            elsif (AQCTLB(3) = '1' and AQCTLB(2) = '0') then
                ePWM_B_Buffer <= '1';
            elsif (AQCTLB(3) = '1' and AQCTLB(2) = '1') then
                ePWM_B_Buffer <= not ePWM_B_Buffer;
            end if;
        
        end if;    
        
        -- If the counter is at zero then the appropriate bits can be compared and the signal driven        
        if (CTR_Zero = '1') then
        
            if (AQCTLA(1) = '0' and AQCTLA(0) = '1') then
                ePWM_A_Buffer <= '0';
            elsif (AQCTLA(1) = '1' and AQCTLA(0) = '0') then
                ePWM_A_Buffer <= '1';
            elsif (AQCTLA(1) = '1' and AQCTLA(0) = '1') then
                ePWM_A_Buffer <= not ePWM_A_Buffer;
            end if;
            
            if (AQCTLB(1) = '0' and AQCTLB(0) = '1') then
                ePWM_B_Buffer <= '0';
            elsif (AQCTLB(1) = '1' and AQCTLB(0) = '0') then
                ePWM_B_Buffer <= '1';
            elsif (AQCTLB(1) = '1' and AQCTLB(0) = '1') then
                ePWM_B_Buffer <= not ePWM_B_Buffer;
            end if;
                        
        end if;    
        
        
        
        -- Action Qualifying ( Software Forced ) ( Single Event)
        
        -- If the triggering signal is at 0, then an event on B can occur when OTSFB goes high
        if ( AQSFRC(5) = '1' and OTSFB_Triggered = '0' ) then
            -- Act on output B based on AQSFRC bits 4 and 3, "00" do nothing, "01" set low
            -- "10" set high, "11" toggle
            
            if ( AQSFRC(4) = '0' and AQSFRC(3) = '1' ) then
                ePWM_B_Buffer <= '0';
            elsif ( AQSFRC(4) = '0' and AQSFRC(3) = '1' ) then
                ePWM_B_Buffer <= '1';
            elsif ( AQSFRC(4) = '0' and AQSFRC(3) = '1' ) then
                ePWM_B_Buffer <= not ePWM_B_Buffer;
            end if;
            
            -- Set OTSFB_Triggered to '1' to indicate the event has occurred
            OTSFB_Triggered <= '1';
        end if;
        
        -- Repeat for OTSFA
        if ( AQSFRC(2) = '1' and OTSFA_Triggered = '0' ) then
            -- Act on output B based on AQSFRC bits 4 and 3, "00" do nothing, "01" set low
            -- "10" set high, "11" toggle
            
            if ( AQSFRC(1) = '0' and AQSFRC(0) = '1' ) then
                ePWM_A_Buffer <= '0';
            elsif ( AQSFRC(1) = '0' and AQSFRC(0) = '1' ) then
                ePWM_A_Buffer <= '1';
            elsif ( AQSFRC(1) = '0' and AQSFRC(0) = '1' ) then
                ePWM_A_Buffer <= not ePWM_A_Buffer;
            end if;
            
            -- Set OTSFA_triggered to '1' to indicate the event has occurred
            OTSFA_Triggered <= '1';
        end if;
        
        -- Reset the OTSFx variables if the control register goes low
        if ( AQSFRC(5) = '0' ) then
            OTSFB_Triggered <= '0';
        end if;
        
         if ( AQSFRC(2) = '0' ) then
           OTSFA_Triggered <= '0';
        end if;
        
        
        -- Action Qualifying ( Software Forced ) ( Continuous Event)
        
        -- If the active continuous software force register triggers an event then act on the output
        if ( AQCSFRC_Active(3) = '0' and AQCSFRC_Active(2) = '1') then
            ePWM_B_Buffer <= '0';
        elsif ( AQCSFRC_Active(3) = '1' and AQCSFRC_Active(2) = '0') then
            ePWM_B_Buffer <= '1';
        end if;
        
        if ( AQCSFRC_Active(1) = '0' and AQCSFRC_Active(0) = '1') then
            ePWM_A_Buffer <= '0';
        elsif ( AQCSFRC_Active(1) = '1' and AQCSFRC_Active(0) = '0') then
            ePWM_A_Buffer <= '1';
        end if;
        
         
    end if;
end process;

-- The ePWM buffers can now be written to the ePWM outputs
ePWMA_AQ_Output <= ePWM_A_Buffer;
ePWMB_AQ_Output <= ePWM_B_Buffer;

end Behavioral;