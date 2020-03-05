# Don't change this. The actual clock frequency isn't this high, we just make it this high to get safe timing.
create_clock -period 10.000 -name board_checkout_clock -waveform {0.000 5.000} [get_pins u_startup/CFGMCLK]

######## ADD I/Os BELOW HERE ############

## SPI flash
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports {SPI_CS_B[0]}]
set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS33} [get_ports {SPI_MOSI}]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS33} [get_ports {SPI_MISO}]

## I2C
set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports {SCL[0]}]
set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33} [get_ports {SDA[0]}]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS33} [get_ports {SCL[1]}]
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports {SDA[1]}]


## LEDs (these are inverted, so backwards counting!)
set_property -dict {PACKAGE_PIN M5 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN N5 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN P6 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]

set_property INTERNAL_VREF 0.9 [get_iobanks 14]
set_property INTERNAL_VREF 0.9 [get_iobanks 15]
set_property INTERNAL_VREF 0.9 [get_iobanks 16]
set_property INTERNAL_VREF 0.9 [get_iobanks 34]
set_property INTERNAL_VREF 0.9 [get_iobanks 35]

## Clock signal
# clock 0 is TOF_CLK
set_property -dict {PACKAGE_PIN H4 IOSTANDARD HSTL_I_18} [get_ports {CLK[0]}]
# clock 1 is DAQ_CLK
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {CLK[1]}]
# diff clock is OSC_P
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVDS_25} [get_ports {DIFF_CLK_P[0]}]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVDS_25} [get_ports {DIFF_CLK_N[0]}]


######## ADD CLOCKS BELOW HERE ############

create_clock -period 12.500 -name daq_clk_pin -waveform {0.000 6.250} -add [get_ports {CLK[1]}]
create_clock -period 25.000 -name tof_clk_pin -waveform {0.000 12.500} -add [get_ports {CLK[0]}]
create_clock -period 5.000 -name sys_clk_pin -waveform {0.000 2.500} -add [get_ports {DIFF_CLK_P[0]}]

# Make sure to set datapath constraints for ALL board clocks against board_checkout_clock
set_max_delay -datapath_only -from [get_clocks board_checkout_clock] -to [get_clocks sys_clk_pin] 10.000
set_max_delay -datapath_only -from [get_clocks sys_clk_pin] -to [get_clocks board_checkout_clock] 10.000
set_max_delay -datapath_only -from [get_clocks board_checkout_clock] -to [get_clocks daq_clk_pin] 10.000
set_max_delay -datapath_only -from [get_clocks daq_clk_pin] -to [get_clocks board_checkout_clock] 10.000
set_max_delay -datapath_only -from [get_clocks board_checkout_clock] -to [get_clocks tof_clk_pin] 10.000
set_max_delay -datapath_only -from [get_clocks tof_clk_pin] -to [get_clocks board_checkout_clock] 10.000

######### DONE USER STUFF ###############

# Xilinx debug stuff
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets sysclk_BUFG]
