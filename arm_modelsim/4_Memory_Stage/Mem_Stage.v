`include "configs.v"

module Mem_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  input MEM_R_EN, MEM_W_EN,
  input [`ADDRESS_LEN - 1:0] ALU_Res,
  input [`WORD_LEN - 1:0] Val_RM,
  output [`WORD_LEN - 1:0] memory_out
);
  
  assign pc = pc_in;
  Regular_Register #(`ADDRESS_LEN) pc_register (.q(pc), .d(pc_in), .clk(clk), .rst(rst));
  
  Data_Memory(
    .clk(clk), .rst(rst),
    .MEM_R_EN(MEM_R_EN), .MEM_W_EN(MEM_W_EN),
    .ALU_Res(ALU_Res),  // Address
    .Val_RM(Val_RM),  // Writing Value
    .out(memory_out)
  );
  
endmodule
