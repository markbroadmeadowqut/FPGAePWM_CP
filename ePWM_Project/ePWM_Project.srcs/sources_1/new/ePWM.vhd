----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM Whole Entity
-- Module Name: ePWM
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module is the combination of all of the ePWM modules
--  It is to be added as a component to a user generated program that will
--  supply the various registers and inputs.
--
--  This module would be added to other programs and used to as an individual
--  ePWM module. Multiple could be used depending on the situation.
--
-- Dependencies: 
--  All
--
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



entity ePWM is
    port(
        clk             : in std_logic;

        -- Time Base Registers
        TBCTL           : in unsigned (15 downto 0);
        TBSTS           : in unsigned (15 downto 0);
        TBPHS           : in unsigned (15 downto 0);
        TBPRD           : in unsigned (15 downto 0);
        
        -- Counter Compare Registers
        CMPCTL          : in unsigned (15 downto 0);
        CMPA            : in unsigned (15 downto 0);
        CMPB            : in unsigned (15 downto 0);
        
        -- Action Qualifier Registers
        AQCTLA          : in unsigned (15 downto 0);
        AQCTLB          : in unsigned (15 downto 0);
        AQSFRC          : in unsigned (15 downto 0);
        AQCSFRC         : in unsigned (15 downto 0);
        
        -- Dead Band Registers
        DBRED           : in unsigned (15 downto 0);
        DBFED           : in unsigned (15 downto 0);
        DBCTL           : in unsigned (15 downto 0);

        -- Trip Zone Registers
        TZSEL           : in unsigned (15 downto 0);
        TZCTL           : in unsigned (15 downto 0);
        TZEINT          : in unsigned (15 downto 0);
        TZFLG           : out unsigned (15 downto 0);
        TZCLR           : in unsigned (15 downto 0);
        TZFRC           : in unsigned (15 downto 0);
        
        -- Event Trigger Registers
        ETSEL           : in unsigned (15 downto 0);
        ETPS            : in unsigned (15 downto 0);
        ETCLR           : in unsigned (15 downto 0);
        ETFRC           : in unsigned (15 downto 0);
        ETFLG           : out unsigned (15 downto 0);
        
        
        -- Synch input and output
        EPWMxSYNCI      : in std_logic;
        EPWMxSYNCO      : out std_logic;
        
        -- Interrupts and SOC signals
        TZ_Interrupt    : out std_logic;
        EPWMxINT        : out std_logic;
        EPWMxSOCA       : out std_logic;
        EPWMxSOCB       : out std_logic;
        
        -- Trip Zone Input Signals
        TZ1             : in std_logic;
        TZ2             : in std_logic;
        TZ3             : in std_logic;
        TZ4             : in std_logic;
        TZ5             : in std_logic;
        TZ6             : in std_logic;
        
        -- Output ePWM Waves
        ePWM_A          : out std_logic;
        ePWM_B          : out std_logic
         
        );
end epwm;

architecture Behavioral of ePWM is

        
    -- Signals used as wires to link the sub modules together
    signal TBCTR_Wire               :   unsigned (15 downto 0);
    signal TBCLK_Wire               :   std_logic;
    signal CTR_dir_Wire             :   std_logic;
    signal CTR_PRD_Wire             :   std_logic;
    signal CTR_Zero_Wire            :   std_logic;
    signal CTR_CMPA_Wire            :   std_logic;
    signal CTR_CMPB_Wire            :   std_logic;
      
    signal ePWMA_AQ_Output_Wire     : std_logic := '0';
    signal ePWMB_AQ_Output_Wire     : std_logic := '0';   
    signal ePWMA_DB_Output_Wire     : std_logic;
    signal ePWMB_DB_Output_Wire     : std_logic;
    
    
    
-- Sub modules to be instantiated as components in the larger ePWM entity    
    
component Clock_Prescale Port (     
                                    clk                 : in    STD_LOGIC;
                                    TBCTl               : in    unsigned (15 downto 0);
                                    TBCLK               : out   STD_LOGIC
                                    ); end component;
                                    
    
component Time_Base Port (          
                                    TBCLK               :   in  STD_LOGIC;  
                        
                                    TBCTL               :   in  unsigned (15 downto 0);
                                    TBSTS               :   in  unsigned (15 downto 0);
                                    TBPHS               :   in  unsigned (15 downto 0);
                                    TBPRD               :   in  unsigned (15 downto 0); 
                                   
                                    EPWMxSYNCI          :   in  std_logic;
                                    EPWMxSYNCO          :   out std_logic;
                                   
                                    CMPB                :   in  unsigned ( 15 downto 0 );
                                             
                                    TBCTR               :   out unsigned (15 downto 0); 
                                   
                                    CTR_Zero            :   out std_logic;
                                    CTR_PRD             :   out std_logic;
                                    CTR_dir             :   out std_logic                                  
                                    ); end component;
                                    
                                    
                                   
component Counter_Compare Port (    
                                    TBCLK               :   in  std_logic;
                                    CMPA                :   in  unsigned ( 15 downto 0 );
                                    CMPB                :   in  unsigned ( 15 downto 0 );
                                    CMPCTL              :   in  unsigned ( 15 downto 0 );
                                               
                                    TBCTR               :   in  unsigned ( 15 downto 0 );
                                          
                                    CTR_PRD             :   in  std_logic;
                                    CTR_Zero            :   in  std_logic;
                                               
                                    CTR_CMPA            :   out std_logic;
                                    CTR_CMPB            :   out std_logic
                                    ); end component;
           
                                
component Action_Qualifier Port (   
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
                                    ); end component;                                                                     
                                    
                                    
component Dead_Band is Port (       TBCLK               : in std_logic;
                                    ePWMA_AQ_Output     : in std_logic;
                                    ePWMB_AQ_Output     : in std_logic;
                                                
                                    DBCTL               : in  unsigned(15 downto 0);                      
                                    DBRED               : in  unsigned ( 15 downto 0 );
                                    DBFED               : in  unsigned (15 downto 0);
                                    
                                    ePWMA_DB_Output     : out std_logic;
                                    ePWMB_DB_Output     : out std_logic   
                                    ); end component; 
                                                                            
                                    
component Trip_Zone is Port (  
                                    clk                 :   in  std_logic;
                                    TZ1                 :   in std_logic;
                                    TZ2                 :   in std_logic;
                                    TZ3                 :   in std_logic;
                                    TZ4                 :   in std_logic;
                                    TZ5                 :   in std_logic;
                                    TZ6                 :   in std_logic;
                                      
                                    TZSEL               :   in  unsigned (15 downto 0);
                                    TZCTL               :   in  unsigned (15 downto 0);
                                    TZEINT              :   in  unsigned (15 downto 0);
                                              
                                    TZCLR               :   in  unsigned (15 downto 0);
                                    TZFRC               :   in  unsigned (15 downto 0);
                                      
                                    CTR_Zero            :   in  std_logic;
                                    
                                    ePWMA_DB_Output     :   in std_logic;
                                    ePWMB_DB_Output     :   in std_logic;
                                    
                                    TZFLG               :   out unsigned (15 downto 0) := "0000000000000000";
                                    
                                    ePWMA_TZ_Output     :   out std_logic;
                                    ePWMB_TZ_Output     :   out std_logic;
                                    
                                    TZ_Interrupt        :   out std_logic := '0'                                   
                                    ); end component; 
                                                                        
                                      
component Event_Trigger is Port (  
                                    TBCLK               :   in std_logic;
                                    CTR_PRD             :   in std_logic;
                                    CTR_Zero            :   in std_logic;
                                    CTR_CMPA            :   in std_logic;
                                    CTR_CMPB            :   in std_logic;
                                    CTR_dir             :   in std_logic;
                                  
                                    ETSEL               :   in unsigned (15 downto 0);
                                    ETPS                :   in unsigned (15 downto 0);
                                  
                                    ETCLR               :   in unsigned (15 downto 0);
                                  
                                    ETFRC               :   in unsigned (15 downto 0);   
                                  
                                    ETFLG               :   out unsigned (15 downto 0);
                                  
                                    ePWMxINT            :   out std_logic;
                                    ePWMxSOCA           :   out std_logic;
                                    ePWMxSOCB           :   out std_logic
                                    ); end component;                                                                                              
   
   
                                
begin

-- Create the instances of the components, 1 of each, connected with the wires where needed

U1 : Clock_Prescale     PORT MAP (      
                                    clk                 => clk,
                                    TBCTL               => TBCTL,
                                    TBCLK               => TBCLK_Wire
                                    );

U2 : Time_Base          PORT MAP (          
                                    TBCLK               => TBCLK_Wire,
                                   
                                    TBCTL               => TBCTL,
                                    TBSTS               => TBSTS,
                                    TBPHS               => TBPHS,
                                    TBPRD               => TBPRD,
                                   
                                    EPWMxSYNCI          => EPWMxSYNCI,
                                    EPWMxSYNCO          => EPWMxSYNCO,
                                   
                                    CMPB                => CMPB,
                                   
                                    TBCTR               => TBCTR_Wire,
                                   
                                    CTR_Zero            => CTR_Zero_Wire,
                                    CTR_PRD             => CTR_PRD_Wire,
                                    CTR_dir             => CTR_dir_Wire
                                    );
                          
U3 : Counter_Compare    PORT MAP (     
                                    TBCLK               => TBCLK_Wire,
                                    CMPA                => CMPA,
                                    CMPB                => CMPB,
                                    CMPCTL              => CMPCTL,
                                    
                                    TBCTR               => TBCTR_Wire,
                                    
                                    CTR_PRD             => CTR_PRD_Wire,
                                    CTR_Zero            => CTR_Zero_Wire,
                                    
                                    CTR_CMPA            => CTR_CMPA_Wire,
                                    CTR_CMPB            => CTR_CMPB_Wire
                                    );
                                
U4 : Action_Qualifier   PORT MAP (    
                                    TBCLK               => TBCLK_Wire,

                                    AQCTLA              => AQCTLA,
                                    AQCTLB              => AQCTLB,
                                    AQSFRC              => AQSFRC,
                                    AQCSFRC             => AQCSFRC,
                                    
                                    CTR_PRD             => CTR_PRD_Wire,
                                    CTR_Zero            => CTR_Zero_Wire,
                                    CTR_CMPA            => CTR_CMPA_Wire,
                                    CTR_CMPB            => CTR_CMPB_Wire,
                                    CTR_dir             => CTR_dir_Wire,
                                    
                                    ePWMA_AQ_Output     => ePWMA_AQ_Output_Wire,
                                    ePWMB_AQ_Output     => ePWMB_AQ_Output_Wire
                                    );
                                    
U5 : Dead_Band          PORT MAP (           
                                    TBCLK               => TBCLK_Wire,
                                    ePWMA_AQ_Output     => ePWMA_AQ_Output_Wire,
                                    ePWMB_AQ_Output     => ePWMB_AQ_Output_Wire,
                                    
                                    DBCTL               => DBCTL,
                                    
                                    DBRED               => DBRED,
                                    DBFED               => DBFED,
                                    
                                    ePWMA_DB_Output     => ePWMA_DB_Output_Wire,
                                    ePWMB_DB_Output     => ePWMB_DB_Output_Wire
                                    
                                    );     
                        
                                                          
U6 : Trip_Zone          PORT MAP (           
                                    clk                 => clk,
                                    TZ1                 => TZ1,
                                    TZ2                 => TZ2,
                                    TZ3                 => TZ3,
                                    TZ4                 => TZ4,
                                    TZ5                 => TZ5,
                                    TZ6                 => TZ6,
                                    
                                    TZSEL               => TZSEL,
                                    TZCTL               => TZCTL,
                                    TZEINT              => TZEINT,
                                    TZCLR               => TZCLR,
                                    TZFRC               => TZFRC,
                                    CTR_Zero            => CTR_Zero_Wire,
                                    
                                    ePWMA_DB_Output     => ePWMA_DB_Output_Wire,
                                    ePWMB_DB_Output     => ePWMB_DB_Output_Wire,
                                    
                                    TZFLG               => TZFLG,
                                    ePWMA_TZ_Output     => ePWM_A,
                                    ePWMB_TZ_Output     => ePWM_B,
                                    TZ_Interrupt        => TZ_Interrupt
                                    );  
                                                                     
                          
                                    
U7 : Event_Trigger      PORT MAP (   
                                    TBCLK               => TBCLK_Wire,
                                    CTR_PRD             => CTR_PRD_Wire,
                                    CTR_Zero            => CTR_Zero_Wire,
                                    CTR_CMPA            => CTR_CMPA_Wire,
                                    CTR_CMPB            => CTR_CMPB_Wire,
                                    CTR_dir             => CTR_dir_Wire,
                                  
                                    ETSEL               => ETSEL,
                                    ETPS                => ETPS,                                  
                                    ETCLR               => ETCLR,
                                    ETFRC               => ETFRC,
                                    ETFLG               => ETFLG,
                                  
                                    ePWMxINT            => EPWMxINT,
                                    ePWMxSOCA           => EPWMxSOCA,
                                    ePWMxSOCB           => EPWMxSOCB
                                    );                                  
                                
END Behavioral;