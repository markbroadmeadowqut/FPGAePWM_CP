## Clock signal
 
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -period 10.0 -name sys_clk_pin -waveform {0.0 5.0} -add [get_ports clk]


set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { io_26 }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=ck_io[26]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { io_27 }]; #IO_L16N_T2_A15_D31_14 Sch=ck_io[27]

set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { io_34 }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=ck_io[26]
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { io_35 }]; #IO_L16N_T2_A15_D31_14 Sch=ck_io[27]

set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { io_40 }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=ck_io[26]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { io_41 }]; #IO_L16N_T2_A15_D31_14 Sch=ck_io[27]

set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { io_7 }]; #IO_L16N_T2_A15_D31_14 Sch=ck_io[27]

set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {led0_b}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {led1_b}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {led2_b}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {led3_b}]

set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { SW_reset }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]

#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { ja_1 }]; #[1] }]; #IO_0_15 Sch=ja[1]
#set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { ja_2 }]; #[2] }]; #IO_L4P_T0_15 Sch=ja[2]