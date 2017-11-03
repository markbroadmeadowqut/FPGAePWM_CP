@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xsim ePWM_Simulation_behav -key {Behavioral:sim_1:Functional:ePWM_Simulation} -tclbatch ePWM_Simulation.tcl -view C:/Users/Conor/Documents/ePWM_Project/User_Test.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Clock_Prescale_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Time_Base_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Counter_Compare_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Dead_Band_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Trip_Zone_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Event_Trigger_Simulation.wcfg -view C:/Users/Conor/Documents/ePWM_Project/Action_Qualifier_Simulation.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
