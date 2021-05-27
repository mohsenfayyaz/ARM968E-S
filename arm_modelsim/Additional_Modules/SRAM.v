`include "configs.v"
`timescale 1ns/1ns

module SRAM(
    input CLK,
    input RST,
    input SRAM_WE_N,
    input [16:0] SRAM_ADDR,  //  17 Bits (was 19)
    inout signed [31:0] SRAM_DQ  //  Data 32 Bits
);

    reg [31:0] memory[0:511]; // 65535

    assign #30 SRAM_DQ = SRAM_WE_N ? memory[SRAM_ADDR]: 32'bz;

    always @(posedge CLK) begin
        if(~SRAM_WE_N) begin
            // $display("WRITE mem[%d] = %d", SRAM_ADDR, SRAM_DQ);
            memory[SRAM_ADDR] <= SRAM_DQ;  // write in SRAM
        end
    end
endmodule