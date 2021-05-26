`include "configs.v"

module SRAM_Controller(
    input clk, 
    input rst,

    // Input from Memory Stage
    input write_en, read_en,
    input [31:0] address,
    input [31:0] writeData,

    // To WB Stage
    output [31:0] readData,

    // To Freeze other Stages
    output ready,

    ////////////////////////    SRAM Interface  ////////////////////////
    inout [31:0] SRAM_DQ,                //  SRAM Data bus 16 Bits
    output [16:0] SRAM_ADDR,              //  SRAM Address bus 18 Bits

    // Active Low Signals
    output SRAM_UB_N,              //  SRAM High-byte Data Mask 
    output SRAM_LB_N,              //  SRAM Low-byte Data Mask 
    output SRAM_WE_N,              //  SRAM Write Enable
    output SRAM_CE_N,              //  SRAM Chip Enable
    output SRAM_OE_N               //  SRAM Output Enable
);
    
    assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b0;  // Active
    
    
endmodule