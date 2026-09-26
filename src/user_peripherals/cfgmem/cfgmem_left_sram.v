/*
    Copyright 2026 Ken Pettit

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

// CFGMEM_IHP_LEFT16_SRAM: CFGMEM_IHP_LEFT16 with its Metal4 rails on the
// IHP SRAM's supply columns, for CFGMEMS_LEFT[1].cfgmem_lo's spot above
// SRAM[1] (macros/CFGMEM_IHP_LEFT16_SRAM, DFFRAM make left_cmos5l_sram).
// Same netlist and ports as CFGMEM_IHP_LEFT16, so the model just wraps that
// one; synthesis reads it as a black box (EXTRA_VERILOG_MODELS).
/// sta-blackbox
module CFGMEM_IHP_LEFT16_SRAM
#(
    parameter WSIZE = 32,
    parameter COUNT = 16
 )
(
    input   wire                 WE0,
    input   wire [15:0]          WROW,
    input                        EN0,
    input                        BYP,
    input   wire [3:0]           A0,
    input   wire [31:0]          Di0,
    output  wire [31:0]          Do0
);
    CFGMEM_IHP_LEFT16 #(.WSIZE(WSIZE), .COUNT(COUNT)) cfgmem
    (
        .WE0  ( WE0  ),
        .WROW ( WROW ),
        .EN0  ( EN0  ),
        .BYP  ( BYP  ),
        .A0   ( A0   ),
        .Di0  ( Di0  ),
        .Do0  ( Do0  )
    );
endmodule
