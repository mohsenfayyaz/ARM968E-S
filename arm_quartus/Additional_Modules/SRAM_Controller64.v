`include "configs.v"

module SRAM_Controller64(
    input clk,
    input rst,

    // Golden Inputs
    input write_en, read_en,
    input [31:0] address,
    input [31:0] writeData,

    // WB
    output signed [63:0] readData,

    // Freeze
    output ready,
    
    // SRAM
    inout signed [63:0] SRAM_DQ,
    output [16:0] SRAM_ADDR,
    output SRAM_UB_N,
    output SRAM_LB_N,
    output SRAM_WE_N,
    output SRAM_CE_N,
    output SRAM_OE_N
);
    
    assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b0;  // Active
    
    // Fix Address
    wire [`ADDRESS_LEN - 1:0] address_1024;
    wire [16:0] physical_address;
    assign address_1024 = address - 1024;
    assign physical_address = address_1024[17:2];  // Memory Adr Starts From 1024 and must be multiplication of 4
    
    // Controller Regs
    wire[1:0] ps, ns;
    parameter S_IDLE = 2'b00, S_READ = 2'b01, S_WRITE = 2'b10;  // States
    Regular_Register #(.SIZE(2)) ps_reg(.q(ps), .d(ns), .clk(clk), .rst(rst));
    
    wire[2:0] counter, next_counter;
    Regular_Register #(.SIZE(3)) counter_reg(.q(counter), .d(next_counter), .clk(clk), .rst(rst));
    
    
    // ns Reg
    assign ns = (ps == S_IDLE && read_en) ? S_READ :
                (ps == S_IDLE && write_en) ? S_WRITE :
                (ps == S_READ && counter != `SRAM_WAIT_CYCLES) ? S_READ :
                (ps == S_WRITE && counter != `SRAM_WAIT_CYCLES) ? S_WRITE :
                S_IDLE;
    
    // Counter
    assign next_counter = (ps == S_READ && counter != `SRAM_WAIT_CYCLES) ? counter + 1 :
                          (ps == S_WRITE && counter != `SRAM_WAIT_CYCLES) ? counter + 1 :
                          3'b0;
    
    assign SRAM_ADDR = physical_address;
    
    assign SRAM_DQ = (ps == S_WRITE && counter != `SRAM_WAIT_CYCLES) ? writeData : 64'bz;
    
    assign SRAM_WE_N = (ps == S_WRITE && counter != `SRAM_WAIT_CYCLES) ? 1'b0 : 1'b1;  // 0 is Active
    
    assign readData = SRAM_DQ;
    
    assign ready = (ps == S_READ && counter != `SRAM_WAIT_CYCLES) ? 1'b0 :
                   (ps == S_WRITE && counter != `SRAM_WAIT_CYCLES) ? 1'b0 :
                   ((ps == S_IDLE) && (read_en || write_en)) ? 1'b0 :
                   1'b1;
    
    always @(posedge clk) begin
      if(read_en && counter == `SRAM_WAIT_CYCLES - 1)
        $display("READ mem[%d] = %d", physical_address, SRAM_DQ);
      if(write_en && counter == `SRAM_WAIT_CYCLES - 1)
        $display("WRITE mem[%d] = %d", physical_address, SRAM_DQ);
    end
    
endmodule