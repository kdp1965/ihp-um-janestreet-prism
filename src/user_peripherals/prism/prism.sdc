###############################################################################
# Timing Constraints
###############################################################################
create_generated_clock -name clk_prism_div2 -source [get_ports clk] -divide_by 2 [get_pins i_peripherals.i_prism08.CG/GCLK]
