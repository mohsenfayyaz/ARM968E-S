`include "configs.v"

module Data_Memory(
    input clk, rst,
    input MEM_R_EN, MEM_W_EN,
    input [`ADDRESS_LEN - 1:0] ALU_Res,  // Address
    input signed [`WORD_LEN - 1:0] Val_Rm,  // Writing Value
    
    output [`WORD_LEN - 1:0] out
);
    // Data
    reg signed [`WORD_LEN - 1:0] regs [0:`MEMORY_SIZE - 1];
    
    // Fix Address
    wire [`ADDRESS_LEN - 1:0] ALU_Res_1024;
    wire [`ADDRESS_LEN - 3:0] address;
    assign ALU_Res_1024 = ALU_Res - 1024;
    assign address = ALU_Res_1024[`ADDRESS_LEN - 1:2];  // Memory Adr Starts From 1024 and must be multiplication of 4
    
    assign out = regs[address];  // READ
    
    integer j;
    initial begin
      for(j = 0; j < `MEMORY_SIZE; j = j + 1)
      regs[j] = 0;
    end
    
    integer i;
    always @(posedge clk) begin : Write
      if(MEM_W_EN == 1)begin
        regs[address] = Val_Rm;
        $display("WRITE mem[%d] = %d", address, Val_Rm);
        for(i = 0; i < 11; i = i + 1)
          $display("Mem[%d] = %d", i, regs[i]);
      end
    end
    
    
    always @(*) begin : Read_Print
      if(MEM_R_EN == 1) begin
        $display("READ mem[1%d] = %d", address, regs[address]);
      end
    end

endmodule