----------------------------------------------------------------------------------
-- Developed by Conor Peers 
-- 
-- Create Date: 2017
-- Design Name: ePWM User
-- Module Name: User
-- Project Name: ePWM System
-- Target Devices: ARTY Development Board
-- Tool Versions: 
-- Description: 
--  This module is used as a simulation for the user that would eventually have
--  the ePWM as part of a larger project. It creates a single ePWM module, and
--  provides all of the registers that it needs to operate.
--
--  To use this system three trial configurations are provided, uncomment the
--  appropriate configuration and the corresponding ePWM components. The first
--  is required for trial configuration 1 (single phase), the other two are also
--  needed for the the two three phase configurations.
--
-- Dependencies: 
--  ePWM
--
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity User is
  Port (
        clk : in std_logic;
        
        io_7 : in std_logic := '1';
        
        io_26 : out std_logic;
        io_27 : out std_logic;
        io_34 : out std_logic;
        io_35 : out std_logic;
        io_40 : out std_logic;
        io_41 : out std_logic;
                        
                        
        led0_b : out std_logic; 
        led1_b : out std_logic; 
        led2_b : out std_logic; 
        led3_b : out std_logic
        
        );
end User;

architecture Behavioral of User is
    
    -- Signals to holw the output ePWM signals
    signal ePWM_A_1           :   std_logic := '0';
    signal ePWM_B_1         :   std_logic := '0';
 
    signal ePWM_A_2           :   std_logic := '0';
    signal ePWM_B_2           :   std_logic := '0';
    
    signal ePWM_A_3           :   std_logic := '0';
    signal ePWM_B_3           :   std_logic := '0';
    
    
    -- Signals to hold the synchronisation signals
    -- The input signal can be commented out and used as an external input,
    -- comment out this line and add a port decleration with this exact name.
    -- Or add a line after the port map connecting the synch input to something
    -- in the port decleration, thereby driving the internal signal with the
    -- external signal.
    signal EPWMxSYNCI       :   std_logic := '0';
    signal EPWMxSYNCO       :   std_logic;
    signal EPWMxSYNCO_2       :   std_logic;
    signal EPWMxSYNCO_3       :   std_logic;
    
    
    
   -- Signals that can be used for the trip zone
   -- These signals are for simulation purposes
   -- To add real hardware interrupts, add a port decleration
   -- with these exact names and comment these out.
   -- Or add a line after the port map, connecting on of these
   -- to any input decleration, essentially permanently drive one of these
   -- with an external input.
   signal TZ1               :   std_logic := '1';
   signal TZ2               :   std_logic := '1';
   signal TZ3               :   std_logic := '1';
   signal TZ4               :   std_logic := '1';
   signal TZ5               :   std_logic := '1';
   signal TZ6               :   std_logic := '1'; 
   
    
    
    -- Signals to hold the interrupt and SOC signals
    signal TZ_Interrupt_2     :   std_logic;                              
    signal EPWMxINT_2         :   std_logic;
    signal EPWMxSOCA_2        :   std_logic;
    signal EPWMxSOCB_2        :   std_logic;
    signal TZ_Interrupt_3     :   std_logic;                              
    signal EPWMxINT_3         :   std_logic;
    signal EPWMxSOCA_3        :   std_logic;
    signal EPWMxSOCB_3        :   std_logic;
    signal TZ_Interrupt     :   std_logic;                              
    signal EPWMxINT         :   std_logic;
    signal EPWMxSOCA        :   std_logic;
    signal EPWMxSOCB        :   std_logic;
    
    
   
    
--     Registers (Trial Simulation 1 Configuration)
    
    
    -- Time Base registers
    signal TBCTL            :   unsigned ( 15 downto 0 ) := "000" & "000" & "0000" & "00" & "10" & "01";
    signal TBSTS            :   unsigned ( 15 downto 0 );
    signal TBPHS_1            :   unsigned ( 15 downto 0 ) := "0000000000000000";
    signal TBPRD            :   unsigned ( 15 downto 0 ) := "0000000000110001";  


    -- Counter Compare Registers
    signal CMPCTL           :   unsigned (15 downto 0) := "000000000" & "1" & "0" & "1" & "00" & "00";
    signal CMPA_1             :   unsigned (15 downto 0) := "0000000000100111";
    signal CMPB_1             :   unsigned (15 downto 0) := "0000000000000000";


    -- Action Qualifier registers
    signal AQCTLA           :   unsigned ( 15 downto 0) := "0000" & "00" & "00" & "01" & "00" & "10" & "00";
    signal AQCTLB           :   unsigned ( 15 downto 0 ) := "0000" & "00" & "00" & "00" & "00" & "10" & "00";
    signal AQSFRC           :   unsigned ( 15 downto 0 ) := "00000000" & "00" & "0" & "00" & "0" & "00";
    signal AQCSFRC          :   unsigned ( 15 downto 0 ) := "000000000000" & "00" & "00" ;
    
    
    -- Dead Band registers
    signal DBRED            :   unsigned (15 downto 0) := "0000000000000001";
    signal DBFED            :   unsigned (15 downto 0) := "0000000000000010";
    signal DBCTL            :   unsigned (15 downto 0) := "0000000000001011";
    
      
    -- Trip Zone registers
    signal TZSEL            :   unsigned (15 downto 0) := "00" & "000000" & "00" &"000000";
    signal TZCTL            :   unsigned (15 downto 0) := "000000000000" & "00" & "00";
    signal TZEINT           :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";
    signal TZFLG            :   unsigned (15 downto 0):= "0000000000000" & "000";
    signal TZCLR            :   unsigned (15 downto 0):= "0000000000000" & "000";
    signal TZFRC            :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";
    
    
    -- Event Trigger registers
    signal ETSEL            :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";
    signal ETPS             :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";  
    signal ETCLR            :   unsigned (15 downto 0) := "0000000000000000";
    signal ETFRC            :   unsigned (15 downto 0) := "0000000000000000"; 
    SIGNAL ETFLG            :   unsigned (15 downto 0);
    
        
--    -- Registers (Trial Simulation 2 Configuration)


---- Time Base registers
--signal TBCTL            :   unsigned ( 15 downto 0 ) := "000" & "000" & "0000" & "00" & "10" & "00";
--signal TBSTS            :   unsigned ( 15 downto 0 );
--signal TBSTS_2            :   unsigned ( 15 downto 0 );
--signal TBSTS_3            :   unsigned ( 15 downto 0 );
--signal TBPHS_1          :   unsigned ( 15 downto 0 ) := "0000000000000000";
--signal TBPHS_2          :   unsigned ( 15 downto 0 ) := "0000000000000000";
--signal TBPHS_3          :   unsigned ( 15 downto 0 ) := "0000000000000000";
--signal TBPRD            :   unsigned ( 15 downto 0 ) := "0000000000011101";  


---- Counter Compare Registers
--signal CMPCTL           :   unsigned (15 downto 0) := "000000000" & "1" & "0" & "1" & "00" & "00";
--signal CMPA_1           :   unsigned (15 downto 0) := "0000000000000000";
--signal CMPB_1           :   unsigned (15 downto 0) := "0000000000001010";

--signal CMPA_2           :   unsigned (15 downto 0) := "0000000000001010";
--signal CMPB_2           :   unsigned (15 downto 0) := "0000000000010100";

--signal CMPA_3           :   unsigned (15 downto 0) := "0000000000010100";
--signal CMPB_3           :   unsigned (15 downto 0) := "0000000000000000";
---- Action Qualifier registers
--signal AQCTLA           :   unsigned ( 15 downto 0) := "0000" & "00" & "01" & "00" & "10" & "00" & "00";
--signal AQCTLB           :   unsigned ( 15 downto 0 ) := "0000" & "00" & "10" & "00" & "01" & "00" & "00";
--signal AQSFRC           :   unsigned ( 15 downto 0 ) := "00000000" & "00" & "0" & "00" & "0" & "00";
--signal AQCSFRC          :   unsigned ( 15 downto 0 ) := "000000000000" & "00" & "00" ;


---- Dead Band registers
--signal DBRED            :   unsigned (15 downto 0) := "0000000000000000";
--signal DBFED            :   unsigned (15 downto 0) := "0000000000000000";
--signal DBCTL            :   unsigned (15 downto 0) := "0000000000000000";

  
---- Trip Zone registers
--signal TZSEL            :   unsigned (15 downto 0) := "00" & "000000" & "00" &"000001";
--signal TZCTL            :   unsigned (15 downto 0) := "000000000000" & "00" & "00";
--signal TZEINT           :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";
--signal TZFLG            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFLG_2            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFLG_3            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZCLR            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFRC            :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";


---- Event Trigger registers
--signal ETSEL            :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";
--signal ETPS             :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";  
--signal ETCLR            :   unsigned (15 downto 0) := "0000000000000000";
--signal ETFRC            :   unsigned (15 downto 0) := "0000000000000000"; 
--SIGNAL ETFLG            :   unsigned (15 downto 0);
--SIGNAL ETFLG_2            :   unsigned (15 downto 0);
--SIGNAL ETFLG_3            :   unsigned (15 downto 0);
    
    
    -- Registers (Trial Simulation 3 Configuration)


---- Time Base registers
--signal TBCTL            :   unsigned ( 15 downto 0 ) := "000" & "000" & "0000" & "01" & "11" & "00";
--signal TBSTS            :   unsigned ( 15 downto 0 );
--signal TBSTS_2            :   unsigned ( 15 downto 0 );
--signal TBSTS_3            :   unsigned ( 15 downto 0 );
--signal TBPHS_1            :   unsigned ( 15 downto 0 ) := "0000000000000000";
--signal TBPHS_2           :   unsigned ( 15 downto 0 ) := "0000000000010110";
--signal TBPHS_3            :   unsigned ( 15 downto 0 ) := "0000000000001100";

--signal TBPRD            :   unsigned ( 15 downto 0 ) := "0000000000011101";  


---- Counter Compare Registers
--signal CMPCTL           :   unsigned (15 downto 0) := "000000000" & "1" & "0" & "1" & "00" & "00";
--signal CMPA_1           :   unsigned (15 downto 0) := "0000000000000000";
--signal CMPB_1           :   unsigned (15 downto 0) := "0000000000001010";

--signal CMPA_2           :   unsigned (15 downto 0) := "0000000000000000";
--signal CMPB_2           :   unsigned (15 downto 0) := "0000000000001010";

--signal CMPA_3           :   unsigned (15 downto 0) := "0000000000000000";
--signal CMPB_3           :   unsigned (15 downto 0) := "0000000000001010";

---- Action Qualifier registers
--signal AQCTLA           :   unsigned ( 15 downto 0) := "0000" & "00" & "01" & "00" & "00" & "00" & "10";
--signal AQCTLB           :   unsigned ( 15 downto 0 ) := "0000" & "00" & "10" & "00" & "00" & "00" & "01";
--signal AQSFRC           :   unsigned ( 15 downto 0 ) := "00000000" & "00" & "0" & "00" & "0" & "00";
--signal AQCSFRC          :   unsigned ( 15 downto 0 ) := "000000000000" & "00" & "00" ;


---- Dead Band registers
--signal DBRED            :   unsigned (15 downto 0) := "0000000000000000";
--signal DBFED            :   unsigned (15 downto 0) := "0000000000000000";
--signal DBCTL            :   unsigned (15 downto 0) := "0000000000000000";


---- Trip Zone registers
--signal TZSEL            :   unsigned (15 downto 0) := "00" & "000000" & "00" &"000001";
--signal TZCTL            :   unsigned (15 downto 0) := "000000000000" & "00" & "00";
--signal TZEINT           :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";
--signal TZFLG            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFLG_2            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFLG_3            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZCLR            :   unsigned (15 downto 0):= "0000000000000" & "000";
--signal TZFRC            :   unsigned (15 downto 0):= "0000000000000" & "00" & "0";


---- Event Trigger registers
--signal ETSEL            :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";
--signal ETPS             :   unsigned (15 downto 0) := "0000" & "0000" & "0000" & "0000";  
--signal ETCLR            :   unsigned (15 downto 0) := "0000000000000000";
--signal ETFRC            :   unsigned (15 downto 0) := "0000000000000000"; 
--SIGNAL ETFLG            :   unsigned (15 downto 0);    
--SIGNAL ETFLG_2            :   unsigned (15 downto 0);    
--SIGNAL ETFLG_3            :   unsigned (15 downto 0);    


    
    
    
   -- The ePWM Components 
    
    component ePWM
 Port(
                            clk             :   in  std_logic;
                            
                            -- Time Base Registers
                            TBCTL           :   in  unsigned (15 downto 0);
                            TBSTS           :   in  unsigned (15 downto 0);
                            TBPHS           :   in  unsigned (15 downto 0);
                            TBPRD           :   in  unsigned (15 downto 0);
                            
                            -- Counter Compare Registers
                            CMPCTL          :   in  unsigned (15 downto 0);
                            CMPA            :   in  unsigned (15 downto 0);
                            CMPB            :   in  unsigned (15 downto 0);
                            
                            -- Action Qualifier Registers
                            AQCTLA          :   in  unsigned (15 downto 0);
                            AQCTLB          :   in  unsigned (15 downto 0);
                            AQSFRC          :   in  unsigned (15 downto 0);
                            AQCSFRC         :   in  unsigned (15 downto 0);
                            
                            -- Dead Band Registers
                            DBRED           :   in  unsigned (15 downto 0);
                            DBFED           :   in  unsigned (15 downto 0);
                            DBCTL           :   in  unsigned (15 downto 0);
                            
                            -- Trip Zone Registers
                            TZSEL           :   in  unsigned (15 downto 0);
                            TZCTL           :   in  unsigned (15 downto 0);
                            TZEINT          :   in  unsigned (15 downto 0);
                            TZFLG           :   out unsigned (15 downto 0);
                            TZCLR           :   in  unsigned (15 downto 0);
                            TZFRC           :   in  unsigned (15 downto 0);
                            
                            -- Event Trigger Registers
                            ETSEL           :   in  unsigned (15 downto 0);
                            ETPS            :   in  unsigned (15 downto 0);
                            ETCLR           :   in  unsigned (15 downto 0);
                            ETFRC           :   in  unsigned (15 downto 0);
                            ETFLG           :   out unsigned (15 downto 0);
                                    
                                    
                            -- Synchs and Interrupts
                            EPWMxSYNCI      :   in  std_logic;
                            EPWMxSYNCO      :   out std_logic;                 
                    
                            TZ_Interrupt    :   out std_logic;
                            EPWMxINT        :   out std_logic;
                            EPWMxSOCA       :   out std_logic;
                            EPWMxSOCB       :   out std_logic;
                    
                    
                    
                            -- Trip Signals
                            TZ1             :   in  std_logic;
                            TZ2             :   in  std_logic;
                            TZ3             :   in  std_logic;
                            TZ4             :   in  std_logic;
                            TZ5             :   in  std_logic;
                            TZ6             :   in  std_logic;
                            
                            -- Output ePWM Signals
                            ePWM_A          :   out std_logic;
                            ePWM_B          :   out std_logic
             
                            ); end component;
    

begin

-- Create the instance of the ePWM component, this is the part that
-- would have to be duplicated to add more ePWM's

U1 : ePWM Port Map (
                    clk             => clk,
                    
                    -- Time Base Registers
                    TBCTL           => TBCTL,
                    TBSTS           => TBSTS,
                    TBPHS           => TBPHS_1,
                    TBPRD           => TBPRD,
                    
                    -- Counter Compare Registers
                    CMPCTL          => CMPCTL,
                    CMPA            => CMPA_1,
                    CMPB            => CMPB_1,
                    
                    -- Actioin Qualifier Registers
                    AQCTLA          => AQCTLA,
                    AQCTLB          => AQCTLB,
                    AQSFRC          => AQSFRC,
                    AQCSFRC         => AQCSFRC,
                    
                    -- Dead Band Registers
                    DBRED           => DBRED,
                    DBFED           => DBFED,
                    DBCTL           => DBCTL,
                    
                    -- Trip Zone Registers
                    TZSEL           => TZSEL,
                    TZCTL           => TZCTL,
                    TZEINT          => TZEINT,
                    TZFLG           => TZFLG,
                    TZCLR           => TZCLR,
                    TZFRC           => TZFRC,
                    
                    -- Event Trigger Registers
                    ETSEL           => ETSEL,
                    ETPS            => ETPS,
                    ETCLR           => ETCLR,
                    ETFRC           => ETFRC,
                    ETFLG           => ETFLG,
                    
                    -- Synchronisation Signals
                    EPWMxSYNCI      => EPWMxSYNCI,
                    EPWMxSYNCO      => EPWMxSYNCO,
                    
                    -- Interrupts and SOC's
                    TZ_Interrupt    => TZ_Interrupt,
                    EPWMxINT        => EPWMxINT,
                    EPWMxSOCA       => EPWMxSOCA,
                    EPWMxSOCB       => EPWMxSOCB,
                    
                    -- Trip Signals
                    TZ1             => TZ1, --io_7, -- this is used to control the trip signals, it is held to a digital 1 in this case
                    TZ2             => TZ2,
                    TZ3             => TZ3,
                    TZ4             => TZ4,
                    TZ5             => TZ5,
                    TZ6             => TZ6,
                                        
                    -- Output ePWM Signals
                    ePWM_A          => ePWM_A_1,
                    ePWM_B          => ePWM_B_1                    
                    );

--U2 : ePWM Port Map (
--                    clk             => clk,
                    
--                    -- Time Base Registers
--                    TBCTL           => TBCTL,
--                    TBSTS           => TBSTS_2,
--                    TBPHS           => TBPHS_2,
--                    TBPRD           => TBPRD,
                    
--                    -- Counter Compare Registers
--                    CMPCTL          => CMPCTL,
--                    CMPA            => CMPA_2,
--                    CMPB            => CMPB_2,
                    
--                    -- Actioin Qualifier Registers
--                    AQCTLA          => AQCTLA,
--                    AQCTLB          => AQCTLB,
--                    AQSFRC          => AQSFRC,
--                    AQCSFRC         => AQCSFRC,
                    
--                    -- Dead Band Registers
--                    DBRED           => DBRED,
--                    DBFED           => DBFED,
--                    DBCTL           => DBCTL,
                    
--                    -- Trip Zone Registers
--                    TZSEL           => TZSEL,
--                    TZCTL           => TZCTL,
--                    TZEINT          => TZEINT,
--                    TZFLG           => TZFLG_2,
--                    TZCLR           => TZCLR,
--                    TZFRC           => TZFRC,
                    
--                    -- Event Trigger Registers
--                    ETSEL           => ETSEL,
--                    ETPS            => ETPS,
--                    ETCLR           => ETCLR,
--                    ETFRC           => ETFRC,
--                    ETFLG           => ETFLG_2,
                    
--                    -- Synchronisation Signals
--                    EPWMxSYNCI      => EPWMxSYNCO,
--                    EPWMxSYNCO      => EPWMxSYNCO_2,
                    
--                    -- Interrupts and SOC's
--                    TZ_Interrupt    => TZ_Interrupt_2,
--                    EPWMxINT        => EPWMxINT_2,
--                    EPWMxSOCA       => EPWMxSOCA_2,
--                    EPWMxSOCB       => EPWMxSOCB_2,
                    
--                    -- Trip Signals
--                    TZ1             => TZ1,--io_7,--io_28, --TZ1,
--                    TZ2             => TZ2,
--                    TZ3             => TZ3,
--                    TZ4             => TZ4,
--                    TZ5             => TZ5,
--                    TZ6             => TZ6,
                                        
--                    -- Output ePWM Signals
--                    ePWM_A          => ePWM_A_2,
--                    ePWM_B          => ePWM_B_2                    
--                    );

--U3 : ePWM Port Map (
--                    clk             => clk,
                    
--                    -- Time Base Registers
--                    TBCTL           => TBCTL,
--                    TBSTS           => TBSTS_3,
--                    TBPHS           => TBPHS_3,
--                    TBPRD           => TBPRD,
                    
--                    -- Counter Compare Registers
--                    CMPCTL          => CMPCTL,
--                    CMPA            => CMPA_3,
--                    CMPB            => CMPB_3,
                    
--                    -- Actioin Qualifier Registers
--                    AQCTLA          => AQCTLA,
--                    AQCTLB          => AQCTLB,
--                    AQSFRC          => AQSFRC,
--                    AQCSFRC         => AQCSFRC,
                    
--                    -- Dead Band Registers
--                    DBRED           => DBRED,
--                    DBFED           => DBFED,
--                    DBCTL           => DBCTL,
                    
--                    -- Trip Zone Registers
--                    TZSEL           => TZSEL,
--                    TZCTL           => TZCTL,
--                    TZEINT          => TZEINT,
--                    TZFLG           => TZFLG_3,
--                    TZCLR           => TZCLR,
--                    TZFRC           => TZFRC,
                    
--                    -- Event Trigger Registers
--                    ETSEL           => ETSEL,
--                    ETPS            => ETPS,
--                    ETCLR           => ETCLR,
--                    ETFRC           => ETFRC,
--                    --ETFLG           => ETFLG,
                    
--                    -- Synchronisation Signals
--                    EPWMxSYNCI      => EPWMxSYNCO,
--                    EPWMxSYNCO      => EPWMxSYNCO_3,
                    
--                    -- Interrupts and SOC's
--                    TZ_Interrupt    => TZ_Interrupt_3,
--                    EPWMxINT        => EPWMxINT_3,
--                    EPWMxSOCA       => EPWMxSOCA_3,
--                    EPWMxSOCB       => EPWMxSOCB_3,
                    
--                    -- Trip Signals
--                    TZ1             => TZ1,--io_7,--io_28, --TZ1,
--                    TZ2             => TZ2,
--                    TZ3             => TZ3,
--                    TZ4             => TZ4,
--                    TZ5             => TZ5,
--                    TZ6             => TZ6,
                                        
--                    -- Output ePWM Signals
--                    ePWM_A          => ePWM_A_3,
--                    ePWM_B          => ePWM_B_3                    
--                    );
                    

io_26 <= ePWM_A_1;
io_27 <= ePWM_B_1;

io_34 <= ePWM_A_2;
io_35 <= ePWM_B_2;

io_40 <= ePWM_A_3;
io_41 <= ePWM_B_3;


end Behavioral;