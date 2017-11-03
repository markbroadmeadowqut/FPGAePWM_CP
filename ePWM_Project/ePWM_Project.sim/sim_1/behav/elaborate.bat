@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto 0c9f66c754dc400bb07ca1f4e18e7d9d -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot ePWM_Simulation_behav xil_defaultlib.ePWM_Simulation -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
