`include "configs.v"

module Mem_Stage_Reg(
  input clk, rst,
  input [`ADDRESS_LEN - 1:0] pc_in,
  output [`ADDRESS_LEN - 1:0] pc,
  
  input [`ADDRESS_LEN - 1:0] ALU_Res,
  input [`WORD_LEN - 1:0] memory_out,
  input MEM_R_EN,WB_EN,
  input [3:0] Dest,
  
  output [`ADDRESS_LEN - 1:0] ALU_Res_out,
  output [`WORD_LEN - 1:0] memory_reg_out,
  output MEM_R_EN_out,WB_EN_out,
  output [3:0] Dest_out
);
  
  Regular_Register #(`ADDRESS_LEN) pc_reg (.q(pc), .d(pc_in), .clk(clk), .rst(rst));
  Register #(`ADDRESS_LEN) ALU_Res_reg(.q(ALU_Res_out), .d(ALU_Res), .clk(clk), .rst(rst));
  Register #(`WORD_LEN) _reg(.q(memory_reg_out), .d(memory_out), .clk(clk), .rst(rst));
  Register #(1) MEM_R_EN_reg(.q(MEM_R_EN_out), .d(MEM_R_EN), .clk(clk), .rst(rst));
  Register #(1) WB_EN_reg(.q(WB_EN_out), .d(WB_EN), .clk(clk), .rst(rst));
  Register #(4) Dest_reg(.q(Dest_out), .d(Dest), .clk(clk), .rst(rst));
  
endmodule