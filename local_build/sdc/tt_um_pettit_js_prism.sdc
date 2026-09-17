###############################################################################
# Created by write_sdc
###############################################################################
current_design tt_um_pettit_js_prism
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 14.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  -hold 2.5000
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  -setup 2.5000
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  -hold 2.0000
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  -setup 2.0000
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ena}]
set_input_delay 1.5000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[0]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[0]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[1]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[1]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[2]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[2]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[3]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[3]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[4]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[4]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[5]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[5]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[6]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[6]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {ui_in[7]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {ui_in[7]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[0]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[0]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[1]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[1]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[2]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[2]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[3]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[3]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[4]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[4]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[5]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[5]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[6]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[6]}]
set_input_delay 2.8000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_in[7]}]
set_input_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_in[7]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[0]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[1]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[2]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[3]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[4]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[4]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[5]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[5]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[6]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[6]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_oe[7]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_oe[7]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[0]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[1]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[2]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[3]}]
set_output_delay 2.8000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[4]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[4]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[5]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[5]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[6]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[6]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uio_out[7]}]
set_output_delay 9.1000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uio_out[7]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[0]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[1]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[2]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[3]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[4]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[4]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[5]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[5]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[6]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[6]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -min -add_delay [get_ports {uo_out[7]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -max -add_delay [get_ports {uo_out[7]}]
set_multicycle_path -hold\
    -through [list [get_nets {i_peripherals.cfgmem_addr[0]}]\
           [get_nets {i_peripherals.cfgmem_addr[1]}]\
           [get_nets {i_peripherals.cfgmem_addr[2]}]\
           [get_nets {i_peripherals.cfgmem_addr[3]}]\
           [get_nets {i_peripherals.cfgmem_addr_sel}]\
           [get_nets {i_peripherals.cfgmem_byp_hi}]\
           [get_nets {i_peripherals.cfgmem_byp_lo}]] 1
set_multicycle_path -setup\
    -through [list [get_nets {i_peripherals.cfgmem_addr[0]}]\
           [get_nets {i_peripherals.cfgmem_addr[1]}]\
           [get_nets {i_peripherals.cfgmem_addr[2]}]\
           [get_nets {i_peripherals.cfgmem_addr[3]}]\
           [get_nets {i_peripherals.cfgmem_addr_sel}]\
           [get_nets {i_peripherals.cfgmem_byp_hi}]\
           [get_nets {i_peripherals.cfgmem_byp_lo}]] 2
set_false_path -setup\
    -from [list [get_ports {ui_in[0]}]\
           [get_ports {ui_in[1]}]\
           [get_ports {ui_in[2]}]\
           [get_ports {ui_in[3]}]\
           [get_ports {ui_in[4]}]\
           [get_ports {ui_in[5]}]\
           [get_ports {ui_in[6]}]\
           [get_ports {ui_in[7]}]]
set_false_path\
    -through [list [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_hi/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS[2].cfgmem_lo/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_hi/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS[3].cfgmem_lo/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_hi/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[0].cfgmem_lo/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_hi/Di0[9]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[0]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[10]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[11]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[12]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[13]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[14]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[15]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[16]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[17]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[18]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[19]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[1]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[20]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[21]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[22]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[23]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[24]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[25]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[26]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[27]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[28]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[29]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[2]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[30]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[31]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[3]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[4]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[5]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[6]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[7]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[8]}]\
           [get_pins {i_peripherals.CFGMEMS_LEFT[1].cfgmem_lo/Di0[9]}]]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0060 [get_ports {uio_oe[7]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[6]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[5]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[4]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[3]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[2]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[1]}]
set_load -pin_load 0.0060 [get_ports {uio_oe[0]}]
set_load -pin_load 0.0060 [get_ports {uio_out[7]}]
set_load -pin_load 0.0060 [get_ports {uio_out[6]}]
set_load -pin_load 0.0060 [get_ports {uio_out[5]}]
set_load -pin_load 0.0060 [get_ports {uio_out[4]}]
set_load -pin_load 0.0060 [get_ports {uio_out[3]}]
set_load -pin_load 0.0060 [get_ports {uio_out[2]}]
set_load -pin_load 0.0060 [get_ports {uio_out[1]}]
set_load -pin_load 0.0060 [get_ports {uio_out[0]}]
set_load -pin_load 0.0060 [get_ports {uo_out[7]}]
set_load -pin_load 0.0060 [get_ports {uo_out[6]}]
set_load -pin_load 0.0060 [get_ports {uo_out[5]}]
set_load -pin_load 0.0060 [get_ports {uo_out[4]}]
set_load -pin_load 0.0060 [get_ports {uo_out[3]}]
set_load -pin_load 0.0060 [get_ports {uo_out[2]}]
set_load -pin_load 0.0060 [get_ports {uo_out[1]}]
set_load -pin_load 0.0060 [get_ports {uo_out[0]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ena}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_n}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[7]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[6]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[5]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[4]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[3]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[2]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[1]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {ui_in[0]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[7]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[6]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[5]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[4]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[3]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[2]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[1]}]
set_driving_cell -lib_cell sg13cmos5l_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {uio_in[0]}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 8.0000 [current_design]
