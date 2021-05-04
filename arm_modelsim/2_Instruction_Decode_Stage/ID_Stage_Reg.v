`include "configs.v"

module ID_Stage_Reg(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output reg[`ADDRESS_LEN - 1:0] pc,
  
  input S, B, MEM_W_EN, MEM_R_EN, WB_EN, imm,
  input [`ADDRESS_LEN - 1:0] Val_Rn, Val_Rm,
  input [23:0] Signed_imm_24,
  input [3:0] Dest, EXE_CMD, src1, src2,
  input [11:0] Shift_operand, flush,
  
  output S_out, B_out, MEM_W_EN_out, MEM_R_EN_out, WB_EN_out, imm_out,
  output [`ADDRESS_LEN - 1:0] Val_Rn_out, Val_Rm_out,
  output [23:0] Signed_imm_24_out,
  output [3:0] Dest_out, EXE_CMD_out, src1_out, src2_out,
  output [11:0] Shift_operand_out
);
  
  wire [`ADDRESS_LEN - 1:0] pc_mux_out, val_Rn_mux_out, val_Rm_mux_out;
  wire [23:0] signed_immediate_mux_out;
  wire [11:0] shift_operand_mux_out;
  wire [3:0] output_dst_mux_out, EXE_CMD_mux_out, src1_mux_out, src2_mux_out;
  wire imm_mux_out, s_mux_out, b_mux_out, MEM_W_EN_mux_out, MEM_R_EN_mux_out, WB_EN_mux_out;

  Mux # (`ADDRESS_LEN) pc_mux (.first(pc),.second(32'b0),.select(flush),.out(pc_mux_out));
  Mux # (`ADDRESS_LEN) val_Rn_mux (.first(Val_Rn),.second(32'b0),.select(flush),.out(val_Rn_mux_out));
  Mux # (`ADDRESS_LEN) val_Rm_mux (.first(Val_Rm),.second(32'b0),.select(flush),.out(val_Rm_mux_out));
  Mux # (24) imm24_mux (.first(Signed_imm_24),.second(24'b0),.select(flush),.out(signed_immediate_mux_out));
  Mux # (4) dst_mux (.first(Dest),.second(4'b0),.select(flush),.out(output_dst_mux_out));
  Mux # (12) shift_operand_mux (.first(Shift_operand),.second(12'b0),.select(flush),.out(shift_operand_mux_out));
  Mux # (1) imm_mux (.first(imm),.second(1'b0),.select(flush),.out(imm_mux_out));
  Mux # (1) s_mux (.first(S),.second(1'b0),.select(flush),.out(s_mux_out));
  Mux # (1) b_mux (.first(B),.second(1'b0),.select(flush),.out(b_mux_out));
  Mux # (4) exe_cmd_mux (.first(EXE_CMD),.second(4'b0),.select(flush),.out(EXE_CMD_mux_out));
  Mux # (1) mem_w_mux (.first(MEM_W_EN),.second(1'b0),.select(flush),.out(MEM_W_EN_mux_out));
  Mux # (1) mem_r_mux (.first(MEM_R_EN),.second(1'b0),.select(flush),.out(MEM_R_EN_mux_out));
  Mux # (1) wb_mux (.first(WB_EN),.second(1'b0),.select(flush),.out(WB_EN_mux_out));
  Mux # (4) src1_mux (.first(src1),.second(4'b0),.select(flush),.out(src1_mux_out));
  Mux # (4) src2_mux (.first(src2),.second(4'b0),.select(flush),.out(src2_mux_out));

  Regular_Register # (`ADDRESS_LEN) pc_register (.q(pc_out), .d(pc_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (`ADDRESS_LEN) val_Rn_register (.q(Val_Rn_out), .d(val_Rn_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (`ADDRESS_LEN) val_Rm_register (.q(Val_Rm_out), .d(val_Rm_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (24) imm24_register (.q(Signed_imm_24_out), .d(signed_immediate_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (4) output_dst_register (.q(Dest_out), .d(output_dst_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (12) shift_operand_register (.q(Shift_operand_out), .d(shift_operand_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) imm_register (.q(imm_out), .d(imm_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) S_register (.q(S_out), .d(s_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) B_register (.q(B_out), .d(b_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (4) EXE_CMD_register (.q(EXE_CMD_out), .d(EXE_CMD_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) MEM_W_EN_register (.q(MEM_W_EN_out), .d(MEM_W_EN_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) MEM_R_EN_register (.q(MEM_R_EN_out), .d(MEM_R_EN_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (1) WB_EN_register (.q(WB_EN_out), .d(WB_EN_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (4) output_src1_register (.q(src1_out), .d(src1_mux_out), .clk(clk), .rst(rst));
  Regular_Register # (4) output_src2_register (.q(src2_out), .d(src2_mux_out), .clk(clk), .rst(rst));
  
endmodule