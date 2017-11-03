----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Event Trigger Module
-- Module Name: Event_Trigger
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module generates the software interrupts and ADC starts of conversion
--  signals. It generates these based on events occurring in the system and
--  can be programmed to occur after 1, 2 or 3 events.
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Event_Trigger is
    Port (  
            TBCLK       :   in  std_logic;
            CTR_PRD     :   in  std_logic;
            CTR_Zero    :   in  std_logic;
            CTR_CMPA    :   in  std_logic;
            CTR_CMPB    :   in  std_logic;
            CTR_dir     :   in  std_logic;
            
            ETSEL       :   in  unsigned (15 downto 0);
            ETPS        :   in  unsigned (15 downto 0);
            
            ETCLR       :   in  unsigned (15 downto 0);
            
            ETFRC       :   in  unsigned (15 downto 0);   
            
            ETFLG       :   out unsigned (15 downto 0);
            
            ePWMxINT    :   out std_logic;
            ePWMxSOCA   :   out std_logic;
            ePWMxSOCB   :   out std_logic
          );
end Event_Trigger;

architecture Behavioral of Event_Trigger is
    
    -- Three buffer signals for the three outputs
    -- One for each SOC and one for the interrupt
    signal EPWMxSOCA_buffer     : std_logic := '0';
    signal EPWMxSOCB_buffer     : std_logic := '0';
    signal EPWMxINT_buffer      : std_logic := '0';
    
    -- One signal for each counter
    -- One for each SOC and one for the interrupt
    -- The counter are all two bit counters and need 2 bit binary signals
    signal SOCACNT              : unsigned ( 1 downto 0) := "00";
    signal SOCBCNT              : unsigned ( 1 downto 0) := "00";
    signal INTCNT               : unsigned ( 1 downto 0) := "00";
    
    -- A signal for the flag output buffer
    signal ETFLG_buffer         : unsigned (15 downto 0) := "0000000000000000";
    
    -- Signals to show that a software forced SOC has occured
    -- These are to ensure that only a pulse is generated on the SOC line
    signal SOCB_Force_set       : std_logic := '0';
    signal SOCA_Force_set       : std_logic := '0';


begin


process(TBCLK)
begin

if (rising_edge(TBCLK)) then

    -- SoC A
    
    -- This section increments the counter for the Start of Conversion A pulse
    -- It Cycles through the control bits to find what the trigger is for the 
    -- SoCA, once found it checks if that is true, if it is then the counter is
    -- incremented by 1

    if (ETSEL(10) = '0' and ETSEL(9) = '0' and ETSEL(8) = '1') then
        if ( CTR_Zero = '1') then
            SOCACNT <= SOCACNT + 1;
        end if;
    elsif (ETSEL(10) = '0' and ETSEL(9) = '1' and ETSEL(8) = '0') then
        if ( CTR_PRD = '1') then
            SOCACNT <= SOCACNT + 1;
        end if;
    elsif (ETSEL(10) = '1' and ETSEL(9) = '0' and ETSEL(8) = '0') then
        if ( CTR_CMPA = '1' and CTR_dir = '1') then     
            SOCACNT <= SOCACNT + 1;
        end if;
    elsif (ETSEL(10) = '1' and ETSEL(9) = '0' and ETSEL(8) = '1') then
        if ( CTR_CMPA = '1' and CTR_dir = '0') then
            SOCACNT <= SOCACNT + 1;
        end if;
    elsif (ETSEL(10) = '1' and ETSEL(9) = '1' and ETSEL(8) = '0') then
        if ( CTR_CMPB = '1' and CTR_dir = '1') then
            SOCACNT <= SOCACNT + 1;
        end if;
    elsif (ETSEL(10) = '1' and ETSEL(9) = '1' and ETSEL(8) = '1') then
        if ( CTR_CMPB = '1' and CTR_dir = '0') then
            SOCACNT <= SOCACNT + 1;
        end if;
    end if;


    -- The same process if then followed for SoC B
    
    if (ETSEL(14) = '0' and ETSEL(13) = '0' and ETSEL(12) = '1') then
        if ( CTR_Zero = '1') then
            SOCBCNT <= SOCBCNT + 1;
        end if;
    elsif (ETSEL(14) = '0' and ETSEL(13) = '1' and ETSEL(12) = '0') then
        if ( CTR_PRD = '1') then
            SOCBCNT <= SOCBCNT + 1;
        end if;
    elsif (ETSEL(14) = '1' and ETSEL(13) = '0' and ETSEL(12) = '0') then
        if ( CTR_CMPA = '1' and CTR_dir = '1') then     
            SOCBCNT <= SOCBCNT + 1;
        end if;
    elsif (ETSEL(14) = '1' and ETSEL(13) = '0' and ETSEL(12) = '1') then
        if ( CTR_CMPA = '1' and CTR_dir = '0') then
            SOCBCNT <= SOCBCNT + 1;
        end if;
    elsif (ETSEL(14) = '1' and ETSEL(13) = '1' and ETSEL(12) = '0') then
        if ( CTR_CMPB = '1' and CTR_dir = '1') then
            SOCBCNT <= SOCBCNT + 1;
        end if;
    elsif (ETSEL(14) = '1' and ETSEL(13) = '1' and ETSEL(12) = '1') then
        if ( CTR_CMPB = '1' and CTR_dir = '0') then
            SOCBCNT <= SOCBCNT + 1;
        end if;
    end if;

    -- The same process is then followed for the interrupt generator

    if (ETSEL(2) = '0' and ETSEL(1) = '0' and ETSEL(0) = '1') then
        if ( CTR_Zero = '1') then
            INTCNT <= INTCNT + 1;
        end if;
    elsif (ETSEL(2) = '0' and ETSEL(1) = '1' and ETSEL(0) = '0') then
        if ( CTR_PRD = '1') then
            INTCNT <= INTCNT + 1;
        end if;
    elsif (ETSEL(2) = '1' and ETSEL(1) = '0' and ETSEL(0) = '0') then
        if ( CTR_CMPA = '1' and CTR_dir = '1') then     
            INTCNT <= INTCNT + 1;
        end if;
    elsif (ETSEL(2) = '1' and ETSEL(1) = '0' and ETSEL(0) = '1') then
        if ( CTR_CMPA = '1' and CTR_dir = '0') then
            INTCNT <= INTCNT + 1;        
        end if;
    elsif (ETSEL(2) = '1' and ETSEL(1) = '1' and ETSEL(0) = '0') then
        if ( CTR_CMPB = '1' and CTR_dir = '1') then
            INTCNT <= INTCNT + 1;        
        end if;
    elsif (ETSEL(2) = '1' and ETSEL(1) = '1' and ETSEL(0) = '1') then
        if ( CTR_CMPB = '1' and CTR_dir = '0') then
            INTCNT <= INTCNT + 1;
        end if;
    end if;



    -- SoC Pulse Generating
    
    -- SoC B
    -- Determine when to trigger the pulse, is the pulse should never be writted
    -- then hold the counter at 00 and the SoC buffer at 0
    -- Otherwise check the control bits to find how many events need to occur
    -- before a pulse is generated
    -- When that many events have happened, reset the counter to 00 and set the output
    -- to 1
    -- On the next clock edge the counter will not show the correct number of events to
    -- trigger the SoC, so it will be set to 0, generating a 1 cycle pulse

    if ( (ETPS(13) = '0' and ETPS(12) = '0') ) then
        SOCBCNT <= "00";
        EPWMxSOCB_buffer <= '0';
    elsif ( ETPS(13) = '0' and ETPS(12) = '1' ) then
        if (SOCBCNT = "01") then
            SOCBCNT <= "00";
            EPWMxSOCB_buffer <= '1';
        else
            EPWMxSOCB_buffer <= '0';
        end if;
    elsif ( ETPS(13) = '1' and ETPS(12) = '0' ) then
        if (SOCBCNT = "10") then
            SOCBCNT <= "00";
            EPWMxSOCB_buffer <= '1';
        else
            EPWMxSOCB_buffer <= '0';
        end if;
    elsif ( ETPS(13) = '1' and ETPS(12) = '1' ) then
        if (SOCBCNT = "11") then
            SOCBCNT <= "00";
            EPWMxSOCB_buffer <= '1';
        else
            EPWMxSOCB_buffer <= '0';
        end if;        
    end if;
    
    
    -- The same process is followed for SoC A 
    
    if ( (ETPS(9) = '0' and ETPS(8) = '0') ) then
        SOCACNT <= "00";
        EPWMxSOCA_buffer <= '0';
    elsif ( ETPS(9) = '0' and ETPS(8) = '1' ) then
        if (SOCACNT = "01") then
            SOCACNT <= "00";
            EPWMxSOCA_buffer <= '1';
        else
            EPWMxSOCA_buffer <= '0';
        end if;
    elsif ( ETPS(9) = '1' and ETPS(8) = '0' ) then
        if (SOCACNT = "10") then
            SOCACNT <= "00";
            EPWMxSOCA_buffer <= '1';
        else
            EPWMxSOCA_buffer <= '0';
        end if;
    elsif ( ETPS(9) = '1' and ETPS(8) = '1' ) then
        if (SOCACNT = "11") then
            SOCACNT <= "00";
            EPWMxSOCA_buffer <= '1';
        else
            EPWMxSOCA_buffer <= '0';
        end if;        
    end if;
    
    -- The same process is then followed for the interrup generator

    if ( (ETPS(1) = '0' and ETPS(0) = '0') ) then
        INTCNT <= "00";
        EPWMxINT_buffer <= '0';
    elsif ( ETPS(1) = '0' and ETPS(0) = '1' ) then
        if (INTCNT = "01") then
            INTCNT <= "00";
            EPWMxINT_buffer <= '1';
        else
            EPWMxINT_buffer <= '0';
        end if;
    elsif ( ETPS(1) = '1' and ETPS(0) = '0' ) then
        if (INTCNT = "10") then
            INTCNT <= "00";
            EPWMxINT_buffer <= '1';
        else
            EPWMxINT_buffer <= '0';
        end if;
    elsif ( ETPS(1) = '1' and ETPS(0) = '1' ) then
        if (INTCNT = "11") then
            INTCNT <= "00";
            
            if ( ETFLG_buffer(0) = '0') then
                EPWMxINT_buffer <= '1';
            end if;    
        else
            EPWMxINT_buffer <= '0';
        end if;        
    end if;
    
    
    -- Flagging
    
    -- If one of the SoC or Interrupt buffers are active then the
    -- respective flag bit needs to be set
      
    if (EPWMxSOCA_buffer = '1') then
        ETFLG_buffer(2) <= '1';
    end if;    
    
    if (EPWMxSOCB_buffer = '1') then
        ETFLG_buffer(3) <= '1';
    end if;  
    
    if (EPWMxINT_buffer = '1') then
        ETFLG_buffer(0) <= '1';
    end if; 
    
    -- If the clear bit is set then the flag bit can be cleared
    
    if ( ETCLR(3) = '1') then
        ETFLG_buffer(2) <= '0';
    end if;    
    
    if (ETCLR(2) = '1') then
        ETFLG_buffer(3) <= '0';
    end if;  
    
    if (ETCLR(0) = '1') then
        ETFLG_buffer(0) <= '0';
    end if; 
    
    -- Forcing
    
    -- If the force bit is set then send one pulse on the interrupt or SoC line
    -- This implementation has the line latched, preventing any other pulses until the
    -- force bit is cleared
    
    if ( ETFRC(3) = '1' ) then
        
        if (SOCB_Force_set = '0') then
            EPWMxSOCB_buffer <= '1';
        else
            EPWMxSOCA_buffer <= '0';
        end if;
        
        SOCB_Force_set <= '1';
    else
        SOCB_Force_set <= '0';    
    end if;
    
    if ( ETFRC(2) = '1' ) then
            
        if (SOCA_Force_set = '0') then
            EPWMxSOCA_buffer <= '1';
        else
            EPWMxSOCA_buffer <= '0';
        end if;
        
        SOCA_Force_set <= '1';
    else
        SOCA_Force_set <= '0';    
    end if;
    
    -- The interrup can be done without the force set signals
    -- Set the flag when the buffer is set and this will eliminate
    -- the propagation delay and generate just one pulse
    if ( ETFRC(0) = '1' ) then
        if (ETFLG_buffer(0) = '0') then
            EPWMxINT_buffer <= '1';
            ETFLG_buffer(0) <= '1';
        else
            EPWMxINT_buffer <= '0';
        end if;
    end if;


    
        
end if;

end process;

ETFLG       <= ETFLG_buffer;
ePWMxINT    <= EPWMxINT_buffer and ETSEL(3) and (not ETFLG_buffer(0));
ePWMxSOCA   <= EPWMxSOCA_buffer and ETSEL(11);
ePWMxSOCB   <= EPWMxSOCB_buffer and ETSEL(15);

end Behavioral;
