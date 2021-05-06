`include "configs.v"

module Exe_Stage_Reg(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output reg[`ADDRESS_LEN - 1:0] pc,
  
  input [`ADDRESS_LEN - 1:0] ALU_Res, Val_Rm,
  input MEM_W_EN, MEM_R_EN, WB_EN,
  input [3:0] Dest,
  
  output MEM_W_EN_out, MEM_R_EN_out, WB_EN_out,
  output [`ADDRESS_LEN - 1:0] ALU_Res_out, Val_Rm_out,
  output [3:0] Dest_out
);
  
  Regular_Register #(`ADDRESS_LEN) pc_register (.q(pc), .d(pc_mux_out), .clk(clk), .rst(rst));
  Regular_Register #(`ADDRESS_LEN) r2 (.q(ALU_Res_out), .d(ALU_Res), .clk(clk), .rst(rst));
  Regular_Register #(`ADDRESS_LEN) r3 (.q(Val_Rm_out), .d(Val_Rm), .clk(clk), .rst(rst));
  Regular_Register #(4) r4 (.q(Dest_out), .d(Dest), .clk(clk), .rst(rst));
  Regular_Register #(3) r5 (.q({MEM_W_EN_out, MEM_R_EN_out, WB_EN_out}), .d({MEM_W_EN, MEM_R_EN, WB_EN}), .clk(clk), .rst(rst));
  
endmodule