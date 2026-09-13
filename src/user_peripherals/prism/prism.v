// Copyright (c) Ken Pettit
// SPDX-License-Identifier: Apache-2.0
// ------------------------------------------------------------------------------
//
//  File        : prism.sv
//  Revision    : 1.2
//  Author      : Ken Pettit
//  Created     : 05/09/2015
//
// ------------------------------------------------------------------------------
//
// Description:  
//    This is a Programmable Reconfigurable Indexed State Machine (PRISM)
//
//                        /\           
//                       /  \           
//                   ..-/----\-..       
//               --''  /      \  ''--   
//                    /________\        
//
// Modifications:
//
//    Author  Date      Rev  Description
//    ======  ========  ===  ================================================
//    KP      05/09/15  1.0  Initial version
//    KP      12/07/17  1.1  Modified the input stage to use muxed inputs
//                           with config space select bits, added AND/OR/XOR
//                           and invert capability, added dual compare logic,
//                           added state transition outputs and conditional
//                           outputs, added SI loop mode when si_inc active.
//    KP      12/13/17  1.2  Added Reconfigurability / Fracturability.
//
// ------------------------------------------------------------------------------


/*
=====================================================================================

    Theory of operation:
                                                                        
    +-------------+     +--------------------------------------------------+
    |   Current   |  5  | State Information Table (SIT)                    |
    | State Index +--/->|                                                  |
    |    (SI)     |     | Output: STate Execution Word (STEW)              |
    +-------------+     ++--------+---------+--------------+-+-------------+
         ^ Next SI       |        |LUT      |NewSI         | |
         |               |        |Data     |              | | Transition
         |               |        |(8)      | 5  |\        | |   Outputs     |\  
         |     Input     |        |         +-/->|1|       | +-------------->|1| Output Values
         |     Select    |        |              | +----+  |  State Outputs  | +--------------> 
         |     Muxes (6) |        v    CurrSI -->|0|    |  +---------------->|0|
         |           -->|\      +-------+        |/     |                    |/ 
         |            o | |  3  |       |         |     |                     |
         |    Inputs  o | +--/->|  LUT  +---------*-----|---------------------+
         |            o | |     |       | New State?    |                   
         |           -->|/      +-------+               |
         |                                              |
         +----------------------------------------------+
                                                
    1.  The current State Index (SI) is used as the address to a RAM (State Information Table - SIT)                                            
    2.  The RAM output word is the STate Execution Word (STEW).
    3.  While in the current state (SI), output values are driven from STEW bits.
    4.  Four (6) inputs are MUXed from the 32 available via STEW bits and sent to the LUTs.
    5.  The 3-input LUTs are programmed from 8 STEW bits each to give a "Goto New State?" decision.
    6.  If the LUT output is HIGH, the FSM goes to the NewSI (from the STEW) state.
    7.  During a transition to a NewSI state, the output values are driven with "Transition" values.
    8.  Also (not shown) are a limited number of Conditional Outputs. In any given state, a 
        conditional output will be determined only by the input values base on a LUT.
    9.  The PRISM is Fracturable, meaning it can be fractured into two (somewhat) independent shards
        (state machines), each with it's own SI.  The SI[0] FSM will have 1/2 of the states and
        the SI[1] will have the remainder (on a power of 2 basis).  If there were 24 states, then:

           SI[0] - 16 states
           SI[1] - 8  states
                                                                                         
    10. In the fractured mode, there are output mask bit registers that assign
        outputs to specific shard. 
    11. The FSM (or each shard) can be debugged.  There are 2 breakpoints for each
        that stop the FSM at a specified state.  Also, the FSM can be halted via
        register interface and single stepped.
=====================================================================================
*/
module prism
 #(
   parameter  DEPTH          = 32,                 // Total number of available states (both banks)
   parameter  INPUTS         = 32,                 // Total number of Input to the module
   parameter  OUTPUTS        = 21,                 // Nuber of FSM outputs
   parameter  COND_OUT       = 2,                  // Number of conditional outputs
   parameter  COND_LUT_SIZE  = 2,                  // Size (inputs) for COND decision tree LUT
   parameter  STATE_INPUTS   = 6,                  // Number of parallel state input muxes
   parameter  DUAL_COMPARE   = 1,                  // 1 = two decision trees (if / else if / else)
   parameter  FRACTURABLE    = 1,                  // 1 = can split into two DEPTH/2 state shards
   parameter  LUT_SIZE       = 3,
   parameter  INCLUDE_DEBUG  = 1,
   parameter  STEW_WIDTH     = 128,                // Width of the CFGMEM STEW ports (4 x 32)
   parameter  SI_BITS        = DEPTH > 32 ? 6 :
                               DEPTH > 16 ? 5 :
                               DEPTH > 8  ? 4 :
                               DEPTH > 4  ? 3 :
                               DEPTH > 2  ? 2 : 1,
   parameter  INPUT_BITS     = INPUTS > 32 ? 6 :
                               INPUTS > 16 ? 5 :
                               INPUTS > 8  ? 4 :
                               INPUTS > 4  ? 3 :
                               INPUTS > 2  ? 2 : 1,
   parameter  COND_LUT_BITS  = 2**COND_LUT_SIZE,
   parameter  RAM_WIDTH      = STATE_INPUTS   * INPUT_BITS       + // Input mux sel bits
                               (2**LUT_SIZE)  * (DUAL_COMPARE+1) + // AND/OR Invert per jump state
                               SI_BITS        * (DUAL_COMPARE+1) + // JumpTo state bits
                               OUTPUTS        * (DUAL_COMPARE+2) + // Output Bits 
                               COND_LUT_BITS  * COND_OUT         + // Conditional output bits
                               1,                                  // Increment bit
   parameter  W_ADDR         = 9,                  // Debug bus address width (512 byte region)
   // State table banks: bank A holds states 0..DEPTH_HALF-1, bank B the rest.
   // Unfractured, the SI MSB selects the bank; fractured, shard 0 runs from
   // bank A and shard 1 from bank B, each with its own state index.
   parameter  DEPTH_HALF     = DEPTH > 256 ? 256 : DEPTH > 128 ? 128 : DEPTH > 64 ? 64 : DEPTH > 32 ? 32 : 
                               DEPTH > 16 ? 16 : DEPTH > 8 ? 8 : DEPTH > 4 ? 4 : DEPTH > 2 ? 2 : 1,
   parameter  DEPTH_REM      = DEPTH - DEPTH_HALF,
   parameter  DH_BITS        = DEPTH_HALF == 256 ? 8 : DEPTH_HALF == 128 ? 7 : DEPTH_HALF == 64 ? 6 :
                               DEPTH_HALF == 32 ? 5 : DEPTH_HALF == 16 ? 4 : DEPTH_HALF == 8 ? 3 : 
                               DEPTH_HALF == 4 ? 2 : 1,
   parameter  DR_BITS        = DEPTH_REM == 256 ? 8 : DEPTH_REM == 128 ? 7 : DEPTH_REM == 64 ? 6 :
                               DEPTH_REM == 32 ? 5 : DEPTH_REM == 16 ? 4 : DEPTH_REM == 8 ? 3 : 
                               DEPTH_REM == 4 ? 2 : 1
  )
  (
   // Timing inputs
   input   wire                  clk,              // System clock 
   input   wire                  rst_n,            // TRUE when receiving Bit 0
   input   wire                  fsm_enable,       // Enable signal

   // Symbol and other state detect inputs (one vector per shard; shard 1's
   // is only used when fractured)
   input   wire [INPUTS-1:0]     in_data,          // Shard 0 (or whole FSM) inputs
   input   wire [INPUTS-1:0]     in_data_1,        // Shard 1 inputs

   // Output data, one vector per shard so the peripheral can steer each
   // shard's outputs to its own datapath.  Unfractured, everything is on
   // out_data / cond_out and the shard 1 vectors are zero.
   output  wire [OUTPUTS-1:0]    out_data,         // Shard 0 (or whole FSM) outputs
   output  wire [COND_OUT-1:0]   cond_out,         // Shard 0 conditional outputs
   output  wire [OUTPUTS-1:0]    out_data_1,       // Shard 1 outputs (fractured)
   output  wire [COND_OUT-1:0]   cond_out_1,       // Shard 1 conditional outputs

   // ============================
   // Latch programming bus
   // ============================
`ifndef SYNTH_FPGA
   input  wire [31:0]            latch_data,
   input  wire                   latch_wr,
`endif

   // ============================
   // Debug bus for programming
   // ============================
   input  wire [W_ADDR-1:0]      debug_addr,         // Debug address
   input  wire                   debug_wr,           // Active HIGH write strobe
   input  wire [31:0]            debug_wdata,        // Debug write data
   output wire [31:0]            debug_rdata,        // Debug read data
   output wire                   debug_halt_either,
   output wire [1:0]             debug_halt_shard,   // Per-shard halt state

   // ============================
   // State Information Table (CFGMEM macros, TTSKY approach)
   // ============================
   output  wire [DH_BITS-1:0]    sit_addr_a,         // Row address for bank A (lo macros)
   output  wire [DR_BITS-1:0]    sit_addr_b,         // Row address for bank B (hi macros)
   input   wire [STEW_WIDTH-1:0] stew_a,             // STEW from bank A
   input   wire [STEW_WIDTH-1:0] stew_b              // STEW from bank B
  );

   localparam W_PAR_IN    = INPUT_BITS;
   localparam CMP_SEL_SIZE= 2**LUT_SIZE;
   localparam W_DBG_CTRL  = SI_BITS*2 + 4;
   localparam LUT_INOUT_SIZE = 1 + LUT_SIZE;
   localparam FRACTURE_DECISION_SIZE = (DUAL_COMPARE + 1)*LUT_INOUT_SIZE;

   /* 
   =================================================================================
   Debug Bus Register Map (byte offsets within the PRISM peripheral region; the
   peripheral itself owns 0x00-0x03, 0x20-0x2b):

   0x04: debug_ctrl0 (shard 0)  {bp_si1, bp_si0, bp_en1, bp_en0, step, halt_req}
         write bit SI_BITS*2+4 = load new SI from bits [SI_BITS*3+4 : SI_BITS*2+5]
         read:  {debug_si[0], debug_ctrl0}
   0x08: debug_ctrl1 (shard 1)  same layout, read {debug_si[1], debug_ctrl1}
   0x0c: Current State info (read)
              { pad, debug_break_active[1], debug_halt[1], next_si[1], curr_si[1],
                     debug_break_active[0], debug_halt[0], next_si[0], curr_si[0] }
   0x10: STEW of shard 0's current state, bits [31:0]   (read)
   0x14: STEW [63:32]
   0x18: STEW [95:64]
   0x1c: STEW [127:96]
   0x30: debug_dout  - outputs driven while halted (captured at halt, writable)
   0x34: decision_tree_data (read)  {cmp_match, lut_inputs} per shard / tree
   0x38: out_data (read)
   0x3c: in_data  (read)
   0x40: fracture config  [0] cfg_fractured
   0x44: cfg_data_out_mask[0]     0x48: cfg_cond_out_mask[0]
   0x4c: cfg_data_out_mask[1]     0x50: cfg_cond_out_mask[1]
   ===================================================================================== 
   */
   localparam [W_ADDR-1:0] REG_DBG_CTRL0   = 'h04;
   localparam [W_ADDR-1:0] REG_DBG_CTRL1   = 'h08;
   localparam [W_ADDR-1:0] REG_STATUS      = 'h0c;
   localparam [W_ADDR-1:0] REG_STEW0       = 'h10;
   localparam [W_ADDR-1:0] REG_DEBUG_DOUT  = 'h30;
   localparam [W_ADDR-1:0] REG_DECISION    = 'h34;
   localparam [W_ADDR-1:0] REG_OUT_DATA    = 'h38;
   localparam [W_ADDR-1:0] REG_IN_DATA     = 'h3c;
   localparam [W_ADDR-1:0] REG_FRAC_CFG    = 'h40;
   localparam [W_ADDR-1:0] REG_OUT_MASK0   = 'h44;
   localparam [W_ADDR-1:0] REG_COND_MASK0  = 'h48;
   localparam [W_ADDR-1:0] REG_OUT_MASK1   = 'h4c;
   localparam [W_ADDR-1:0] REG_COND_MASK1  = 'h50;

   wire                       prism_rst_n;
   reg                        cfg_fractured;
   wire                       fractured;

   // Signal declarations
   reg   [SI_BITS-1:0]        curr_si[1:0];         // Current State Index value
   wire  [SI_BITS-1:0]        next_si[1:0];         // Next State Index value
   reg   [SI_BITS-1:0]        loop_si[FRACTURABLE:0];    // Loop State Index value
   reg                        loop_valid[FRACTURABLE:0]; // Indiactes if loop_si value is valid
   reg   [SI_BITS-1:0]        debug_si[1:0];        // SI while halted / single stepping

   // Signals to create parallel input muxes
   wire  [W_PAR_IN-1:0]       input_mux_sel [ FRACTURABLE:0 ] [ STATE_INPUTS-1:0 ];
   wire                       input_mux_out [ FRACTURABLE:0 ] [ STATE_INPUTS-1:0 ];

   // RAM interface signals for output values
   wire  [OUTPUTS-1:0]        state_outputs [ FRACTURABLE:0 ];                // Output values from RAM
   wire  [OUTPUTS-1:0]        jump_outputs  [ FRACTURABLE:0 ] [ DUAL_COMPARE:0 ]; // Jumpto transition Output values

   // RAM interface signals for SI control
   wire  [SI_BITS-1:0]        jump_to [ FRACTURABLE:0 ] [ DUAL_COMPARE:0 ];      // SI Jump to address
   wire                       inc_si  [ FRACTURABLE:0 ];                       // SI Inc signal

   // Compare signals from RAM
   wire  [CMP_SEL_SIZE-1:0]   cmp_sel [ FRACTURABLE:0 ] [ DUAL_COMPARE:0 ];
		
   // Signals for doing input compare and muxing
   wire  [DUAL_COMPARE:0]     compare_match [ FRACTURABLE:0 ];
   wire  [LUT_SIZE-1:0]       lut_inputs    [ FRACTURABLE:0 ] [ DUAL_COMPARE:0 ];

   // Conditional out control signals
   wire  [COND_LUT_BITS-1:0]  cond_cfg    [ FRACTURABLE:0 ] [ COND_OUT-1:0 ];
   wire  [1:0]                cond_in     [ FRACTURABLE:0 ] [ COND_OUT-1:0 ];
   wire                       cond_out_c  [ FRACTURABLE:0 ] [ COND_OUT-1:0 ];
   wire                       cond_out_m  [ FRACTURABLE:0 ] [ COND_OUT-1:0 ];

   // Output data masking
   wire  [OUTPUTS-1:0]        out_data_c [ FRACTURABLE:0 ];
   wire  [OUTPUTS-1:0]        out_data_m [ FRACTURABLE:0 ];
   wire  [OUTPUTS-1:0]        out_data_fsm;        // FSM outputs
   
   // Memory control signals
   wire  [RAM_WIDTH-1:0]      ram_dout_c [ 1:0 ];              // Bank A / bank B STEW
   wire  [RAM_WIDTH-1:0]      ram_dout   [ FRACTURABLE:0 ];    // STEW per shard
   wire  [RAM_WIDTH-1:0]      stew       [ FRACTURABLE:0 ];    // State Execution Word

   // Config data
   reg   [OUTPUTS-1:0]        cfg_data_out_mask [ FRACTURABLE:0 ];
   reg   [COND_OUT-1:0]       cfg_cond_out_mask [ FRACTURABLE:0 ];

   // PRISM readback data (SI, etc.)
   reg  [31:0]                debug_rdata_prism;  // Peripheral read data
   reg  [31:0]                decision_tree_data;
   wire [31:0]                in_data_32;
   wire [31:0]                out_data_32;
   wire [127:0]               stew0_128;
   wire [31:0]                status_32;
   reg  [OUTPUTS-1:0]         debug_dout;         // Outputs while halted

   // Debug control registers (one per shard)
   wire [W_DBG_CTRL-1:0]      debug_ctrl0;
   wire [W_DBG_CTRL-1:0]      debug_ctrl1;
   wire                       debug_ctrl0_en;
   wire                       debug_ctrl1_en;
   wire                       debug_halt_req[1:0];
   wire                       debug_step_si[1:0];
   wire                       debug_bp_en0[1:0];
   wire                       debug_bp_en1[1:0];
   wire  [SI_BITS-1:0]        debug_bp_si0[1:0];
   wire  [SI_BITS-1:0]        debug_bp_si1[1:0];
   wire                       debug_new_si;
   wire  [SI_BITS-1:0]        debug_new_siv;
   wire                       debug_entry[1:0];

   // Debug control regs
   reg  [1:0]                 debug_halt;
   reg  [1:0]                 debug_step_pending;
   reg  [1:0]                 debug_resume_pending;
   reg  [1:0]                 debug_halt_req_p1;
   reg  [1:0]                 debug_step_si_last;
   reg  [1:0]                 debug_break_active[1:0];

   assign prism_rst_n = rst_n & fsm_enable;
   assign fractured   = (FRACTURABLE != 0) && cfg_fractured;

   /* 
   =================================================================================
   State Information Table: the STEWs come from the CFGMEM macros.  Bank A (lo
   macros) is addressed by shard 0, bank B (hi macros) by shard 1 when
   fractured, or by shard 0's low SI bits when running as one FSM.
   =================================================================================
   */
   assign sit_addr_a   = curr_si[0][DH_BITS-1:0];
   assign sit_addr_b   = fractured ? curr_si[1][DR_BITS-1:0] : curr_si[0][DR_BITS-1:0];
   assign ram_dout_c[0] = stew_a[RAM_WIDTH-1:0];
   assign ram_dout_c[1] = stew_b[RAM_WIDTH-1:0];

   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin: GEN_RAM_DOUT
      if (f == 0)
      begin : SHARD0
         // Unfractured: SI MSB selects the bank (only if there is a bank B)
         assign ram_dout[0] = fractured ? ram_dout_c[0] :
                              (DEPTH_REM > 0 && curr_si[0][SI_BITS-1]) ? ram_dout_c[1] : ram_dout_c[0];
      end
      else
      begin : SHARD1
         assign ram_dout[f] = fractured ? ram_dout_c[1] : {RAM_WIDTH{1'b0}};
      end
   end

   /* 
   =================================================================================
   Assign signals from generated / instantiated RAM
   =================================================================================
   */
   localparam INPUT_SEL_SIZE  = STATE_INPUTS * W_PAR_IN;
   
   localparam INPUT_SEL_START = 1;
   localparam JUMP_TO_START   = INPUT_SEL_SIZE + INPUT_SEL_START;
   localparam OUTPUTS_START   = JUMP_TO_START  + SI_BITS*(DUAL_COMPARE+1);
   localparam CMP_SEL_START   = OUTPUTS_START  + OUTPUTS*(DUAL_COMPARE+2); 
   localparam COND_START      = CMP_SEL_START  + CMP_SEL_SIZE*(DUAL_COMPARE+1);

`ifdef DEBUG_PRISM_STEW
   initial begin
      $display("RAM_WIDTH       = %d", RAM_WIDTH);
      $display("RAM_DEPTH       = %d", DEPTH);
      $display("INPUT_SEL_START = %d", INPUT_SEL_START);
      $display("OUTPUTS_START   = %d", OUTPUTS_START);
      $display("JUMP_TO_START   = %d", JUMP_TO_START); 
      $display("CMP_SEL_START   = %d", CMP_SEL_START);
      $display("COND_START      = %d", COND_START);
      $display("W_ADDR          = %d", W_ADDR);
   end
`endif

   // Assign stew either as registered or non-registered ram_dout
   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin: GEN_STEW
      assign stew[f] = ram_dout[f][RAM_WIDTH-1:0];
   end

   // Now map the stew to the individual fields
   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin: GEN_CTRL
      for (genvar cmp = 0; cmp < DUAL_COMPARE+1; cmp++)
      begin : OPCODE_ASSIGN_GEN
         // Assign JumpTo bits
         assign jump_to[f][cmp]       = stew[f][SI_BITS           + JUMP_TO_START + SI_BITS*(DUAL_COMPARE-cmp) -1      -: SI_BITS];

         // Assign jump_outputs
         assign jump_outputs[f][cmp]  = stew[f][OUTPUTS           + OUTPUTS_START + OUTPUTS*((DUAL_COMPARE-cmp)+1) -1  -: OUTPUTS];

         // Assign cmp_sel bits
         assign cmp_sel[f][cmp]       = stew[f][CMP_SEL_SIZE*(cmp+1)-1+ CMP_SEL_START -: CMP_SEL_SIZE];
      end

      // Assign conditional output bits
      for (genvar cond = 0; cond < COND_OUT; cond++)
      begin : COND_ASSIGN_GEN
         assign cond_cfg[f][cond]     = stew[f][COND_LUT_BITS*cond + COND_START +: COND_LUT_BITS]; 
      end

      // Assign output bits
      assign state_outputs[f]         = stew[f][OUTPUTS     + OUTPUTS_START-1 -: OUTPUTS];

      // Assign Input mux selection bits
      for (genvar inp = 0; inp < STATE_INPUTS; inp++)
      begin: GEN_IN_MUX_SEL
         assign input_mux_sel[f][inp] = stew[f][INPUT_SEL_START + W_PAR_IN * (inp+1) - 1 -: W_PAR_IN];
      end

      // Assign increment bit
      assign inc_si[f]                = stew[f][0];
   end

   /* 
   =================================================================================
   Clocked State Block for state machine SI
   =================================================================================
   */
   always @(posedge clk or negedge prism_rst_n)
   begin
      if (~prism_rst_n)
      begin
         curr_si[0] <= 'h0;
         curr_si[1] <= 'h0;
      end
      else
      begin
         curr_si[0] <= next_si[0];
         curr_si[1] <= next_si[1];
      end
   end

   /* 
   =================================================================================
   Logic for next SI (shard 1 follows shard 0's STEW when not fracturable)
   =================================================================================
   */
   for (genvar s = 0; s <= 1; s++)
   begin: GEN_NEXT_SI
      localparam F = FRACTURABLE ? s : 0;
      assign next_si[s] = debug_halt[s] ? debug_si[s] : 
                          compare_match[F][0] ? jump_to[F][0] :
                          DUAL_COMPARE && compare_match[F][DUAL_COMPARE] ? jump_to[F][DUAL_COMPARE] :
                          inc_si[F] ? curr_si[s] + 1'b1 :
                          loop_valid[F] ? loop_si[F] :
                          curr_si[s];
   end
   assign debug_halt_either = debug_halt[0] | debug_halt[1];
   assign debug_halt_shard  = debug_halt;

   /* 
   =================================================================================
   Logic for loop_si
   =================================================================================
   */
   always @(posedge clk or negedge prism_rst_n)
   begin
      integer f;

      if (~prism_rst_n)
      begin
         for (f = 0; f <= FRACTURABLE; f++)
         begin
            loop_valid[f] <= 1'b0;
            loop_si[f]    <= 'h0;
         end
      end
      else
      begin
         for (f = 0; f <= FRACTURABLE; f++)
         begin
            if (compare_match[f][0] || compare_match[f][DUAL_COMPARE])
               loop_valid[f] <= 1'b0;

            else if (inc_si[f] && ~loop_valid[f])
            begin
               loop_valid[f] <= 1'b1;
               loop_si[f]    <= curr_si[f];
            end
         end
      end
   end
   
   /* 
   =================================================================================
   Create a mux for each STATE_INPUT
   =================================================================================
   */
   wire  [INPUTS-1:0]         in_data_s [FRACTURABLE:0];   // Per-shard input vectors
   assign in_data_s[0] = in_data;
   generate
      if (FRACTURABLE)
      begin : GEN_IN_DATA_1
         assign in_data_s[FRACTURABLE] = in_data_1;
      end
      for (genvar f = 0; f <= FRACTURABLE; f++)
      begin: GEN_INPUT_MUX
         for (genvar inp = 0; inp < STATE_INPUTS; inp++)
         begin : STATE_IN_MUX_GEN
            assign input_mux_out[f][inp] = in_data_s[f][input_mux_sel[f][inp]];
         end
      end
   endgenerate

   /* 
   =================================================================================
   For each decision tree, Generate a LUT.  Tree 0 uses muxes 0..LUT_SIZE-1,
   tree 1 uses muxes STATE_INPUTS-LUT_SIZE..STATE_INPUTS-1.
   =================================================================================
   */
   generate
   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin: GEN_LUTS_F
      for (genvar cmp = 0; cmp < DUAL_COMPARE+1; cmp++)
      begin : CMP_INST
         // Map MUX outputs to lut inputs
         for (genvar inp = 0; inp < LUT_SIZE; inp++)
         begin: GEN_LUT_INPUTS
            assign lut_inputs[f][cmp][inp] = input_mux_out[f][cmp*(STATE_INPUTS-LUT_SIZE)+inp];
         end
         
         assign compare_match[f][cmp] = cmp_sel[f][cmp][lut_inputs[f][cmp]];
      end
   end
   endgenerate

   /* 
   =================================================================================
   Assign the output values.
   =================================================================================
   */
   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin: GEN_OUT_DATA
      // Assign outputs based on state compare
      assign out_data_c[f] = compare_match[f][0] ? jump_outputs[f][0] : DUAL_COMPARE && 
            compare_match[f][DUAL_COMPARE] ? jump_outputs[f][DUAL_COMPARE] : state_outputs[f];

      // If fractured, mask output bits based on config settings
      assign out_data_m[f] = fractured ? out_data_c[f] & cfg_data_out_mask[f] : out_data_c[f];
   end

   assign out_data_fsm = !fsm_enable ? {OUTPUTS{1'b0}} :
                         fractured   ? out_data_m[FRACTURABLE] | out_data_m[0] :
                                       out_data_m[0];

   // Per-shard output vectors.  A halted shard presents debug_dout (limited
   // to its own outputs when fractured); shard 1 is silent unless fractured.
   wire  [OUTPUTS-1:0]        out_data_s [1:0];
   assign out_data_s[0] = !fsm_enable ? {OUTPUTS{1'b0}} :
                          (INCLUDE_DEBUG && debug_halt[0]) ?
                             (fractured ? debug_dout & cfg_data_out_mask[0] : debug_dout) :
                          out_data_m[0];
   assign out_data_s[1] = (!fsm_enable || !fractured) ? {OUTPUTS{1'b0}} :
                          (INCLUDE_DEBUG && debug_halt[1]) ? debug_dout & cfg_data_out_mask[FRACTURABLE] :
                          out_data_m[FRACTURABLE];
   assign out_data   = out_data_s[0];
   assign out_data_1 = out_data_s[1];

   /* 
   =================================================================================
   Assign the conditional outputs (cond 0 = muxes 1 & 4, cond 1 = muxes 3 & 5)
   =================================================================================
   */
   for (genvar f = 0; f <= FRACTURABLE; f++)
   begin : COND_FRAC_GEN
      for (genvar cond = 0; cond < COND_OUT; cond++)
      begin : COND_OUT_GEN
         if (cond == 0) begin : C0
           assign cond_in[f][cond][0] = input_mux_out[f][1];
           assign cond_in[f][cond][1] = input_mux_out[f][4];
         end
         else begin : C1
           assign cond_in[f][cond][0] = input_mux_out[f][3];
           assign cond_in[f][cond][1] = input_mux_out[f][5];
         end

         // Drive the conditional output based on enable and ao_sel 
         assign cond_out_c[f][cond] = cond_cfg[f][cond][cond_in[f][cond][COND_LUT_SIZE-1:0]];

         // Assign masked registers based on fractured state
         assign cond_out_m[f][cond] = fractured ? cond_out_c[f][cond] & cfg_cond_out_mask[f][cond] :
                                                  cond_out_c[f][cond];
      end
   end

   for (genvar cond = 0; cond < COND_OUT; cond++)
   begin : COND_OUT_GEN
      // Assign final conditional outputs
      assign cond_out[cond]   = !fsm_enable ? 1'b0 : cond_out_m[0][cond];
      assign cond_out_1[cond] = (!fsm_enable || !fractured) ? 1'b0 : cond_out_m[FRACTURABLE][cond];
   end  

   /* 
   =================================================================================
   Fracture configuration registers (plain flops, written from the debug bus)
   =================================================================================
   */
   always @(posedge clk or negedge rst_n)
   begin
      integer f;

      if (~rst_n)
      begin
         cfg_fractured <= 1'b0;
         for (f = 0; f <= FRACTURABLE; f++)
         begin
            cfg_data_out_mask[f] <= 'h0;
            cfg_cond_out_mask[f] <= 'h0;
         end
      end
      else if (FRACTURABLE && debug_wr)
      begin
         if (debug_addr == REG_FRAC_CFG)
            cfg_fractured <= debug_wdata[0];

         if (debug_addr == REG_OUT_MASK0)
            cfg_data_out_mask[0] <= debug_wdata[OUTPUTS-1:0];
         if (debug_addr == REG_COND_MASK0)
            cfg_cond_out_mask[0] <= debug_wdata[COND_OUT-1:0];
         if (debug_addr == REG_OUT_MASK1)
            cfg_data_out_mask[FRACTURABLE] <= debug_wdata[OUTPUTS-1:0];
         if (debug_addr == REG_COND_MASK1)
            cfg_cond_out_mask[FRACTURABLE] <= debug_wdata[COND_OUT-1:0];
      end
   end

   /*
   ===================================================================================== 
   Instantiate the debug_ctrl registers (one per shard)
   ===================================================================================== 
   */
   assign debug_ctrl0_en = INCLUDE_DEBUG && (debug_addr == REG_DBG_CTRL0);
   assign debug_ctrl1_en = INCLUDE_DEBUG && (debug_addr == REG_DBG_CTRL1);

`ifndef SYNTH_FPGA
   prism_latch_reg
   #(
      .WIDTH   ( W_DBG_CTRL )
    )
   i_debug_ctrl0
   (
      .rst_n    ( rst_n                      ),
      .enable   ( debug_ctrl0_en             ),
      .wr       ( latch_wr                   ),
      .data_in  ( latch_data[W_DBG_CTRL-1:0] ),
      .data_out ( debug_ctrl0                )
   );

   prism_latch_reg
   #(
      .WIDTH   ( W_DBG_CTRL )
    )
   i_debug_ctrl1
   (
      .rst_n    ( rst_n                      ),
      .enable   ( debug_ctrl1_en             ),
      .wr       ( latch_wr                   ),
      .data_in  ( latch_data[W_DBG_CTRL-1:0] ),
      .data_out ( debug_ctrl1                )
   );
`else
   reg  [W_DBG_CTRL-1:0]      debug_ctrl0_reg;
   reg  [W_DBG_CTRL-1:0]      debug_ctrl1_reg;
   always @(posedge clk or negedge rst_n)
      if (~rst_n)
      begin
         debug_ctrl0_reg <= 'h0; 
         debug_ctrl1_reg <= 'h0; 
      end
      else
      begin
         if (debug_ctrl0_en && debug_wr)
            debug_ctrl0_reg <= debug_wdata[W_DBG_CTRL-1:0];
         if (debug_ctrl1_en && debug_wr)
            debug_ctrl1_reg <= debug_wdata[W_DBG_CTRL-1:0];
      end
   assign debug_ctrl0 = debug_ctrl0_reg;
   assign debug_ctrl1 = debug_ctrl1_reg;
`endif

   /*
   ===================================================================================== 
   Register READ
   ===================================================================================== 
   */
   localparam STATUS_W = 2*(SI_BITS*2 + 3);
   assign in_data_32  = {{(32-INPUTS){1'b0}}, in_data};
   assign out_data_32 = {{(32-OUTPUTS){1'b0}}, out_data_s[0] | out_data_s[1]};
   assign stew0_128   = {{(128-RAM_WIDTH){1'b0}}, ram_dout[0]};
   assign status_32   = {{(32-STATUS_W){1'b0}},
                         debug_break_active[1], debug_halt[1], next_si[1], curr_si[1],
                         debug_break_active[0], debug_halt[0], next_si[0], curr_si[0]};

   always @*
   begin
      debug_rdata_prism = 32'h0;

      case (debug_addr)
         REG_DBG_CTRL0:   debug_rdata_prism = {{(32-SI_BITS-W_DBG_CTRL){1'b0}}, debug_si[0], debug_ctrl0};
         REG_DBG_CTRL1:   debug_rdata_prism = {{(32-SI_BITS-W_DBG_CTRL){1'b0}}, debug_si[1], debug_ctrl1};
         REG_STATUS:      debug_rdata_prism = status_32;
         REG_STEW0:       debug_rdata_prism = stew0_128[31:0];
         REG_STEW0 + 4:   debug_rdata_prism = stew0_128[63:32];
         REG_STEW0 + 8:   debug_rdata_prism = stew0_128[95:64];
         REG_STEW0 + 12:  debug_rdata_prism = stew0_128[127:96];
         REG_DEBUG_DOUT:  debug_rdata_prism = {{(32-OUTPUTS){1'b0}}, debug_dout};
         REG_DECISION:    debug_rdata_prism = decision_tree_data;
         REG_OUT_DATA:    debug_rdata_prism = out_data_32;
         REG_IN_DATA:     debug_rdata_prism = in_data_32;
         REG_FRAC_CFG:    debug_rdata_prism = {31'h0, cfg_fractured};
         REG_OUT_MASK0:   debug_rdata_prism = {{(32-OUTPUTS){1'b0}}, cfg_data_out_mask[0]};
         REG_COND_MASK0:  debug_rdata_prism = {{(32-COND_OUT){1'b0}}, cfg_cond_out_mask[0]};
         REG_OUT_MASK1:   debug_rdata_prism = {{(32-OUTPUTS){1'b0}}, cfg_data_out_mask[FRACTURABLE]};
         REG_COND_MASK1:  debug_rdata_prism = {{(32-COND_OUT){1'b0}}, cfg_cond_out_mask[FRACTURABLE]};
         default:         debug_rdata_prism = 32'h0; 
      endcase
   end
   assign debug_rdata = debug_rdata_prism;

   always @*
   begin
      integer f, cmp;

      // Default to zero
      decision_tree_data = 32'h0;

      // Add decision tree data
      for (f = 0; f <= FRACTURABLE; f++)
         for (cmp = 0; cmp <= DUAL_COMPARE; cmp++)
            decision_tree_data[f*FRACTURE_DECISION_SIZE + (cmp+1)*LUT_INOUT_SIZE-1 -: LUT_INOUT_SIZE] = {compare_match[f][cmp], lut_inputs[f][cmp]};
   end

   /* 
   =================================================================================
   Debug print the state changes
   =================================================================================
   */

`ifdef DEBUG_PRISM_TRANSITIONS
   always @(curr_si[0] or out_data)
      $display("SI=%02x   OutData=%06X   Jump0 Out=%06X   JumpTo 0=%3d  LUT_in=%X  CMP=%d", 
            curr_si[0], out_data, jump_outputs[0][0], jump_to[0][0], lut_inputs[0][0], compare_match[0][0]);
`endif

   /* 
   =================================================================================
   Assign debug control register bits
   =================================================================================
   */
   // Control for fracture unit 0
   assign debug_halt_req[0] = debug_ctrl0[0];
   assign debug_step_si[0]  = debug_ctrl0[1];
   assign debug_bp_en0[0]   = debug_ctrl0[2];
   assign debug_bp_en1[0]   = debug_ctrl0[3];
   assign debug_bp_si0[0]   = debug_ctrl0[SI_BITS  +4-1 -: SI_BITS];
   assign debug_bp_si1[0]   = debug_ctrl0[SI_BITS*2+4-1 -: SI_BITS];

   // Control for fracture unit 1
   assign debug_halt_req[1] = debug_ctrl1[0];
   assign debug_step_si[1]  = debug_ctrl1[1];
   assign debug_bp_en0[1]   = debug_ctrl1[2];
   assign debug_bp_en1[1]   = debug_ctrl1[3];
   assign debug_bp_si0[1]   = debug_ctrl1[SI_BITS  +4-1 -: SI_BITS];
   assign debug_bp_si1[1]   = debug_ctrl1[SI_BITS*2+4-1 -: SI_BITS];

   // New SI load rides on the debug_ctrl write data (not stored in the register)
   assign debug_new_si      = debug_wdata[SI_BITS*2+4];
   assign debug_new_siv     = debug_wdata[SI_BITS*3+5-1 -: SI_BITS];

   /* 
   =================================================================================
   Debugger code (one debugger per shard; shard 1 only meaningful when fractured)
   =================================================================================
   */
   for (genvar s = 0; s <= 1; s++)
   begin : GEN_DEBUG_ENTRY
      assign debug_entry[s] = debug_step_pending[s] || 
                       (debug_bp_en0[s] && !debug_break_active[s][0] && !debug_resume_pending[s] && (debug_bp_si0[s] == next_si[s])) ||
                       (debug_bp_en1[s] && !debug_break_active[s][1] && !debug_resume_pending[s] && (debug_bp_si1[s] == next_si[s])) ||
                       (debug_halt_req[s] & !debug_halt_req_p1[s]);
   end

   always @(posedge clk or negedge prism_rst_n)
   begin
      integer f;

      if (~prism_rst_n)
      begin
         debug_halt           <= 2'h0;
         debug_step_pending   <= 2'h0;
         debug_resume_pending <= 2'h0;
         debug_halt_req_p1    <= 2'h0;
         debug_step_si_last   <= 2'h0;
         debug_dout           <= 'h0;
         for (f = 0; f <= 1; f++)
         begin
            debug_si[f]           <= 'h0;
            debug_break_active[f] <= 2'h0;
         end
      end
      else
      begin
         // Debug output register write
         if (INCLUDE_DEBUG && debug_wr && debug_addr == REG_DEBUG_DOUT)
            debug_dout <= debug_wdata[OUTPUTS-1:0];

         for (f = 0; f <= 1; f++)
         begin
            // Create rising edge detector for debug_step_si
            debug_step_si_last[f] <= debug_step_si[f];

            // New SI load from debug interface (write to this shard's debug_ctrl)
            if (INCLUDE_DEBUG && debug_wr && debug_new_si &&
                debug_addr == (f == 0 ? REG_DBG_CTRL0 : REG_DBG_CTRL1))
            begin
               debug_si[f] <= debug_new_siv;
            end

            // Test for single-step request
            else if (debug_halt[f] && debug_step_si[f] && !debug_step_si_last[f] && !debug_step_pending[f])
            begin
               // Disable halt and enable step_pending
               debug_halt[f]         <= 1'b0;
               debug_step_pending[f] <= 1'b1;
               debug_break_active[f] <= 2'b0;
            end

            // Test if we need to halt the FSM
            else if (INCLUDE_DEBUG && debug_entry[f])
            begin
               // Halt the FSM
               debug_halt[f]         <= 1'b1;
               debug_si[f]           <= next_si[f];
               debug_step_pending[f] <= 1'b0;
               if (!(debug_wr && debug_addr == REG_DEBUG_DOUT))
                  debug_dout <= out_data_fsm;

               // If halt requested, clear debug_break_active
               if (debug_halt_req[f])
                  debug_break_active[f] <= 2'h0;
               else
               begin
                  // Test if we broke because of breakpoint 0
                  if (debug_bp_en0[f] && !debug_break_active[f][0] && (debug_bp_si0[f] == curr_si[f]))
                     debug_break_active[f][0] <= 1'b1;
                  else
                     debug_break_active[f][0] <= 1'b0;

                  // Test if we broke because of breakpoint 1
                  if (debug_bp_en1[f] && !debug_break_active[f][1] && (debug_bp_si1[f] == curr_si[f]))
                     debug_break_active[f][1] <= 1'b1;
                  else
                     debug_break_active[f][1] <= 1'b0;
               end
            end

            // Test if we need to resume the FSM
            else if (debug_halt[f] && !debug_halt_req[f] && !debug_break_active[f][0] && !debug_break_active[f][1])
            begin
               debug_halt[f]         <= 1'b0;
               debug_step_pending[f] <= 1'b0;
               debug_break_active[f] <= 2'b0;
            end

            // Test for resume from halt request
            debug_halt_req_p1[f]    <= debug_halt_req[f];
            debug_resume_pending[f] <= debug_halt_req_p1[f] & !debug_halt_req[f];
            if (debug_halt_req_p1[f] & !debug_halt_req[f])
            begin
               debug_halt[f]         <= 1'b0;
               debug_break_active[f] <= 2'b0;
            end
         end
      end
   end

endmodule // prism
