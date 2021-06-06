`include "configs.v"
`timescale 1ns/1ns

module SRAM64(
    input CLK,
    input RST,
    input SRAM_WE_N,
    input [16:0] SRAM_ADDR,  //  17 Bits (was 19)
    inout signed [63:0] SRAM_DQ  //  Data 64 Bits (Write 32 Least Significant Bits When WE)
);

    reg [31:0] memory[0:127]; // 65535

    assign #30 SRAM_DQ = SRAM_WE_N ? {memory[{SRAM_ADDR[16:1], 1'b1}], memory[{SRAM_ADDR[16:1], 1'b0}]}: 64'bz;

    always @(posedge CLK) begin
        if(~SRAM_WE_N) begin
            $display("SRAM WRITE mem[%d] = %d", SRAM_ADDR, SRAM_DQ);
            memory[SRAM_ADDR] <= SRAM_DQ[31:0];  // write in SRAM
        end
    end
endmodule