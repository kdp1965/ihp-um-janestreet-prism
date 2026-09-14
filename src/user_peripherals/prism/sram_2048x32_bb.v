// Black-box declarations of the IHP single-port SRAM macros the PRISM SRAM
// FIFO (prism_sram_fifo.v) can use (SRAM_AW 11 / 10), for synthesis.  Simulation uses the PDK's
// behavioural model instead (RM_IHPSG13_1P_2048x32_c2_bm_bist.v with
// FUNCTIONAL defined), so this file is only read when SIM is not defined.
`ifndef SIM
(* blackbox *)
module RM_IHPSG13_1P_2048x32_c2_bm_bist
(
    input  wire        A_CLK,
    input  wire        A_MEN,
    input  wire        A_WEN,
    input  wire        A_REN,
    input  wire [10:0] A_ADDR,
    input  wire [31:0] A_DIN,
    input  wire        A_DLY,
    output wire [31:0] A_DOUT,
    input  wire [31:0] A_BM,
    input  wire        A_BIST_CLK,
    input  wire        A_BIST_EN,
    input  wire        A_BIST_MEN,
    input  wire        A_BIST_WEN,
    input  wire        A_BIST_REN,
    input  wire [10:0] A_BIST_ADDR,
    input  wire [31:0] A_BIST_DIN,
    input  wire [31:0] A_BIST_BM
);
endmodule

(* blackbox *)
module RM_IHPSG13_1P_1024x32_c2_bm_bist
(
    input  wire        A_CLK,
    input  wire        A_MEN,
    input  wire        A_WEN,
    input  wire        A_REN,
    input  wire  [9:0] A_ADDR,
    input  wire [31:0] A_DIN,
    input  wire        A_DLY,
    output wire [31:0] A_DOUT,
    input  wire [31:0] A_BM,
    input  wire        A_BIST_CLK,
    input  wire        A_BIST_EN,
    input  wire        A_BIST_MEN,
    input  wire        A_BIST_WEN,
    input  wire        A_BIST_REN,
    input  wire  [9:0] A_BIST_ADDR,
    input  wire [31:0] A_BIST_DIN,
    input  wire [31:0] A_BIST_BM
);
endmodule
`endif
