`include "configs.v"
`timescale 1ns/1ns

module SRAM64(
    input CLK,
    input RST,
    input SRAM_WE_N,
    input [16:0] SRAM_ADDR,  //  17 Bits (was 19)
    inout signed [63:0] SRAM_DQ  //  Data 64 Bits
);

    reg [63:0] memory[0:255]; // 65535

    assign #30 SRAM_DQ = SRAM_WE_N ? memory[SRAM_ADDR]: 64'bz;

    always @(posedge CLK) begin
        if(~SRAM_WE_N) begin
            $display("SRAM WRITE mem[%d] = %d", SRAM_ADDR, SRAM_DQ);
            memory[SRAM_ADDR[16:1]] <= SRAM_DQ;  // write in SRAM
        end
    end
endmodule