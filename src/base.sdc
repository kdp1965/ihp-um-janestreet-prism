read_sdc $::env(SCRIPTS_DIR)/base.sdc

# Add duty cycle uncertainty - due to the high capacitance of the TT mux 
# we're pretty uncertain about the duty cycle
set_clock_uncertainty 2.5 -rise_from clk -fall_to clk
set_clock_uncertainty 2 -fall_from clk -rise_to clk

# Fix reset delay
set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {rst_n}

# Longer delays for input IOs as we expect to drive them on clock falling edge
# Note "setup" is actually 1 clock cycle minus setup, so this requires a setup
# period of 35% of the clock cycle
set input_setup_delay_value [expr $::env(CLOCK_PERIOD) * 0.65]
set input_hold_delay_value [expr $::env(CLOCK_PERIOD) * 0.2]
set_input_delay -clock [get_clocks $::env(CLOCK_PORT)] -max $input_setup_delay_value {uio_in ui_in}
set_input_delay -clock [get_clocks $::env(CLOCK_PORT)] -min $input_hold_delay_value {uio_in ui_in}

# Longer output delay on bidi IOs to improve coherence
set output_setup_delay_value [expr $::env(CLOCK_PERIOD) * 0.65]
set output_hold_delay_value 1
set_output_delay -clock [get_clocks $::env(CLOCK_PORT)] -max $output_setup_delay_value {uio_out[7] uio_out[6] uio_out[5] uio_out[4] uio_out[2] uio_out[1] uio_out[0] uio_oe}
set_output_delay -clock [get_clocks $::env(CLOCK_PORT)] -min $output_hold_delay_value {uio_out uio_oe}

# Lower delay on SPI clock output because it can be driven at negedge for timing tweaking
set spi_clk_setup_delay_value [expr $::env(CLOCK_PERIOD) * 0.2]
set_output_delay -clock [get_clocks $::env(CLOCK_PORT)] -max $spi_clk_setup_delay_value {uio_out[3]}

# Delays on user outputs
set_output_delay -clock [get_clocks $::env(CLOCK_PORT)] -min 1 {uo_out}
set_output_delay -clock [get_clocks $::env(CLOCK_PORT)] -max 2 {uo_out}

# ---- project additions ------------------------------------------------------
# PRISM inputs in raw mode go from the pin straight into the decision trees
# (an asynchronous relationship by choice: the 1-flop / 2-flop modes exist
# for synchronous use).  Do not time their setup against the falling-edge
# input model; hold is still checked.
set_false_path -setup -from [get_ports {ui_in[*]}]

# The fracture configuration bit only changes while the PRISM is disabled;
# it fans out to the bank-select and output masking logic, so give it two
# cycles rather than let it dominate the state -> SIT -> state loop.
set_multicycle_path -setup 2 -through [get_nets {i_peripherals.i_prism.i_prism.cfg_fractured}]
set_multicycle_path -hold 1 -through [get_nets {i_peripherals.i_prism.i_prism.cfg_fractured}]

# The CFGMEM macros' Di0 inputs are the programming shift chain (loader data
# into row 0, and lo -> hi through the bypass mux used for readback).  They
# only move while the PRISM is disabled, so the lo -> hi -> PRISM arc that
# STA otherwise times through two macros is not a functional path.
set_false_path -through [get_pins -hierarchical *cfgmem_*/Di0*]

# CFGMEM loader configuration bits: the host / PRISM row-address select, the
# host row address and the two bypass bits only change while the PRISM is
# disabled (programming and readback), so their fan-out into the macro
# address and bypass muxes is not a single-cycle path at run time.
set loader_nets {i_peripherals.cfgmem_addr_sel i_peripherals.cfgmem_byp_lo i_peripherals.cfgmem_byp_hi}
for {set i 0} {$i < 4} {incr i} {
    lappend loader_nets "i_peripherals.cfgmem_addr\[$i\]"
}
foreach net $loader_nets {
    set_multicycle_path -setup 2 -through [get_nets $net]
    set_multicycle_path -hold 1 -through [get_nets $net]
}
