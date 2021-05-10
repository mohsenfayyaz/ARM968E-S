`include "configs.v"

module Mem_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  input MEM_R_EN, MEM_W_EN,
  input [`ADDRESS_LEN - 1:0] ALU_Res,
  input [`WORD_LEN - 1:0] Val_Rm,
  output [`WORD_LEN - 1:0] memory_out
);
  
  assign pc = pc_in;
  
  Data_Memory data_memory(
    .clk(clk), .rst(rst),
    .MEM_R_EN(MEM_R_EN), .MEM_W_EN(MEM_W_EN),
    .ALU_Res(ALU_Res),  // Address
    .Val_Rm(Val_Rm),  // Writing Value
    .out(memory_out)
  );
  
endmodule
