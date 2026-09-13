//  Revision    : 1.2
//  Author      : Ken Pettit
//  Created     : 07/20/2025
//
// ------------------------------------------------------------------------------
//
// Description:  
//    This is a Programmable Reconfigurable Indexed State Machine (PRISM)
//    shfit-register flop based State Information Table (SIT).
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
//    KP      07/20/25  1.0  Initial version
//
// ------------------------------------------------------------------------------

module prism_sr_sit
#(
   parameter  WIDTH       = 44,
   parameter  DEPTH       = 8,
   parameter  A_BITS      = DEPTH > 32 ? 6 :
                            DEPTH > 16 ? 5 : 
                            DEPTH > 8  ? 4 :
                            DEPTH > 4  ? 3 :
                            DEPTH > 2  ? 2 : 1
)
(
   input   wire                  clk,
   input   wire                  rst_n,            // TRUE when receiving Bit 0

   // ============================
   // Periph Bus for programming
   // ============================
   input  wire [5:0]             debug_addr,    // Peripheral address
   input  wire                   debug_wr,      // Active HIGH write strobe
   input  wire [31:0]            debug_wdata,   // Write data
   output reg  [31:0]            debug_rdata,   // Final state readback

   // Read addresses and data
   input   wire [A_BITS-1:0]     raddr1,        // Read address 1
   output  wire [WIDTH-1:0]      rdata1         // Output for SI signal
);

   /* 
   =================================================================================
   NOTE: The assignments below align the periph bus access to the RAM on 128-bit or
         256-bit alignment depending on the width of the RAM as calculated from the
         input parameters.  If a config word width greater than 256 bits is needed,
         then the assignments below will need to be augmented.
   =================================================================================
   */
   localparam  ALIGN = WIDTH > 128 ? 256 : 128;
   localparam  ALIGN_BIT = ALIGN/32;

   // RAM input storage register
   reg  [WIDTH-32-1:0]           stew_msb;                // The State Execution Word

   // The RAM storage
   reg [WIDTH-1:0]               fsm_ram[DEPTH];

   /* 
   =================================================================================
   Generate the debug_rdata read-back from the RAM
   =================================================================================
   */
   always @*
   begin
      case (debug_addr)
      6'h10:   debug_rdata = fsm_ram[DEPTH-1][31:0];
      6'h14:   debug_rdata = {{(64-WIDTH){1'b0}}, fsm_ram[DEPTH-1][WIDTH-1:32]};
      default: debug_rdata = 32'h0;
      endcase
   end

   // Implement the stew write
   always @(posedge clk or negedge rst_n)
   begin : STEW_BITS_GEN
      integer r;

      if (~rst_n)
      begin
         stew_msb <= 'h0;

         for (r = 0; r < DEPTH; r++)
         begin : GEN_CLEAR_SIT
            fsm_ram[r] <= 'h0;
         end
      end
      else
      begin
         if (debug_wr)
            case (debug_addr)

            // Write LSB and perform shift
            6'h10: 
            begin
               // Shift all other stew values through the "ram"
               for (r = 0; r < DEPTH-1; r++)
               begin : GEN_WRITE_SIT
                  fsm_ram[r+1] <= fsm_ram[r];
               end

               // Write to location 0
               fsm_ram[0] <= {stew_msb, debug_wdata};
            end

            // Write MSBs
            6'h14: 
               stew_msb <= debug_wdata[WIDTH-1-32:0];

            default:
               begin
               end
            endcase
      end
   end

   // Implement the async read
   assign rdata1 = fsm_ram[raddr1];

endmodule // periph_sr_sit

