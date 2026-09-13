Changes we need to make to the PRISM peripheral for Jane Street 8x4 entry.

1.  Move the top CFGMEM16 macros to the top of the tile and evenly distribute the two in the middle.  This will make more space for
    stdcells inbetween the macros so they can be closer to where their CFGMEM16 data pins are located.
    
2.  Change the 24-bit counter/shift/FIFO.  Let's remove the wierd 3-byte FIFO mode completely (we will add real FIFOs).  This was a 
    trick I was playing to make the original prism peripheral fit within the 2-tile competition limit.

3.  Change the 24-bit counter/shift so that it can support 32-bit counter/shift OR the current 24-bit modes.  It should be able to shift
    left or right in either 32 or 24 bit modes.  Add a "count up" config option (via non-state specific config bits) so the counter can
    count up instead of down.  In this mode, there should be an additional config bit that determines if the roll-over to zero happens
    either when the count is equal to the preload (preload should also scale to 32 bits) or just naturally when the counter gets to
    either 0xFFFFFF (24-bit mode) or 0xFFFFFFFF (32-bit mode).

4.  Change the 5-bit counter that counts 24-bit shifts so it has a config bit (could reuse the fifo_24 bit, etc.) so that it has a
    mode where a shift 'load' resets the count to 1.  Currently it must roll over from 5'1F to zero.  But some protocols that do
    shifting load a new value, and the shift-out bit (LSB/MSB depending on shift direction) shoots to the output pin immediately.
    This counts as the first bit.  Yet the counter is at zero.

5.  The 8-bit comm shift register should probably also have the same 'set count to 1' on load as #4.

6.  When the PRISM is fractured, each decision tree should have it's own set of 24/32 bit count/shift, 8-bit comm register,
    8-bit counter/shift, preload, etc.  The output bits that control those should be aware of which shard is driving the output
    and direct it to the appropriate set of registers.  In other words prism_out_data should be a vector of 2 (one for each shard)
    and "out[6]" should shift the 8 or 24/32 bit shift register for either the shard0 or the shard1 register depending on which
    shard drove that output.  When I am in non-fractured mode, this means the 2nd set of peripheral registers become un-reachable,
    but I think that is ok.  Or if later I think they are needed / useful, perhaps then I re-map one of the 21 outputs to be a
    "register bank select" which affects both the output registers as well as the set of compare inputs (zero, match, etc.), though
    that seems maybe a bit much to keep track of.

7.  With the sky25a PRISM, I realized the debugger really needs a way for a breakpoint to also include an option to break when
    "state = bp_state AND LUT[x] == 1", that way I can set breakpoints within the 'if' condition.  Currently I have to single step
    in any given state, waiting for counts to pass by until the 'if' condition is fulfilled.  But sometimes that is hundred or 
    thousands of steps.  In that mode, I would need to ensure that while the LUT is matching, during the break, I need the outputs
    to not affect the counters / clears / fifo PUSH/PULL, etc.  Otherwise the condition leading to the break would disappear (i.e.
    if I let the "JUMP OUTPUTS" to affect the external regs.)

8.  Add CRC8/CRC16/CRC32 calculation units to each shard.

9.  Add FIFO to each SHARD.  I am actually debating if one of the smaller IHP SRAMS (perhaps RM_IHPSG13_2P_64x32_c2) could be used for
    this.  It is not clear if those can be pulled into a cmos5l / TinyTapeout design, though they have a symlink to those macros in
    the IHP cmos5l libs.ref, so perhaps?

10. Change the memory map so access to each shard's set of registers (24/32 bit count, comm, 8-bit count, preload, etc.) are at 
    uniform locations between the two shards.  Like have each of them occupy a space like 0x100-0x17F (shard 0) and 0x180-0x1FF
    (shard 1) and within  those spaces, the "preload" reg is at the same offset, 8-bit count at a different offset (but the same
    across the to shards), etc.  This would keep the lower address region for common control bits like enable, fractured,
    interrupts, etc.

11. The prism.c / prism.h in the tinyQV-sdk will need to be updated so it understands a "PRISM_CONFIG" define and re-maps
    the memory map depending if it is sky25a, Jane Street, etc. as I'm sure there may be other versions later (I already have
    another version that was a Wokwi entered 8-state x 22 STEW bit PRISM with a single 15-bit counter, fracturable to a 7-bit
    and an 8-bit counter).  Yeah, that was all hand entered in schematic form in Wokwi and I have the silicon on sky25b on my
    desk.  Haven't tested it yet.

12. Output pin functions:

    0: pin_out[0]  muxable to uo_out[7:1]
    1: pin_out[1]  muxable to uo_out[7:1]
    2: pin_out[2]  muxable to uo_out[7:1]
    3: pin_out[3]  muxable to uo_out[7:1]
    4: OUT_LATCH   LATCHes decoded input for "if a != a_prev" (host_in, pin_in) for edge detection
    5: OUT_FIFO_WR_RD
    6: OUT_COUNT1_INC_DEC
    7: OUT_COUNT1_CLEAR_LOAD
    8: OUT_SHIFT (shift 24/32 or 8)
    9: OUT_COUNT2_INC
    10: OUT_COUNT2_DEC
    11: OUT_COUNT2_CLEAR
    12: OUT_CRC_CLEAR
    13: OUT_CRC_UPDATE
    14: OUT_HOST_INTERRUPT
    15:
    16:
    17:
    18:
    19:
    20:

13. Add a per-shard config option to feed the PRISM either the synchronized ui_in (2 flops, as today, from project.v) or the
    raw pins, so protocols clocked from outside (SPI slave, I2C, PS/2) don't pay the 2-clock input delay.  Needs the raw ui_in
    passed down to the PRISM peripheral next to the synchronized copy, and a per-shard in_data vector (each shard picks its
    own).  Consider a 3-way choice (raw / 1 flop / 2 flops) so latency can be traded against metastability risk per protocol.
    The edge-capture (in_prev) flops must sit after this mux.  Once this exists the extra STATE_DELAY2 in chroma_gpio24 can go.

14. I'm sure I will think of more.
