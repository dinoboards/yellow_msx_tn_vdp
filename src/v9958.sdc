//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-06-21 01:16:09
create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add
# create_clock -name clk_50 -period 20 -waveform {0 10} [get_ports {clk_50}] -add

create_generated_clock -name clk_135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk_135}]
# disable to enable both pal and ntsc configs to use only DVI - so no audio clock established
# create_generated_clock -name clk_audio -source [get_ports {clk}] -master_clock clk -divide_by 612 -multiply_by 1 -add [get_nets {clk_audio}]
create_generated_clock -name clk_sck -source [get_ports {clk}] -master_clock clk -divide_by 150 -multiply_by 5 -add [get_nets {clk_sck}]

create_generated_clock -name clk_sdramp -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -duty_cycle 50 -phase 180 -add [get_nets {clk_sdramp}]
create_generated_clock -name clk_sdram -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -add [get_nets {clk_sdram}]

