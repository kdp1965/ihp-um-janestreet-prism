/*
    Copyright 2026 Ken Pettit

    This file is part of the DFFRAM Memory Compiler.
    See https://github.com/Cloud-V/DFFRAM for further info.

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

// 16 x 32 Config MEM
/// sta-blackbox
module CFGMEM_IHP_LEFT16
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
    reg  [31:0]          cfgmem[15:0];
    reg  [15:0]          le;
    reg                  we_dly;
    wire [31:0]          Do_int;

    // Decoder for outputs
    assign Do_int = EN0 ? cfgmem[A0] : 32'h0;
    assign Do0    = BYP ? Di0 : Do_int;
    assign le  = WROW & {16{WE0}};

    always @*
    begin
        int i;
        if (le[0])
            cfgmem[0] <= Di0;

        for (i = 1; i < 16; i = i + 1)
        begin
            if (le[i])
                cfgmem[i] <= cfgmem[i-1];
        end
    end
endmodule

