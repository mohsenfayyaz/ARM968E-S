`include "configs.v"

module ID_Stage_Reg(
  input clk, rst,
  input [`ADDRESS_LEN - 1:0] pc_in,
  output [`ADDRESS_LEN - 1:0] pc,
  
  input S, B, MEM_W_EN, MEM_R_EN, WB_EN, imm,
  input [`ADDRESS_LEN - 1:0] Val_Rn, Val_Rm,
  input [23:0] Signed_imm_24,
  input [3:0] Dest, EXE_CMD, src1, src2,
  input [11:0] Shift_operand, 
  input flush,
  input Z_in, C_in, V_in, N_in,
  
  output S_out, B_out, MEM_W_EN_out, MEM_R_EN_out, WB_EN_out, imm_out,
  output [`ADDRESS_LEN - 1:0] Val_Rn_out, Val_Rm_out,
  output [23:0] Signed_imm_24_out,
  output [3:0] Dest_out, EXE_CMD_out, src1_out, src2_out,
  output [11:0] Shift_operand_out,
  output Z, C, V, N,
  
  // SRAM
  input freeze
);

  Flushable_Freezable_Register #(`ADDRESS_LEN) pc_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(pc), .d(pc_in));
  Flushable_Freezable_Register #(`ADDRESS_LEN) val_rn_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(Val_Rn_out), .d(Val_Rn));
  Flushable_Freezable_Register #(`ADDRESS_LEN) val_rm_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(Val_Rm_out), .d(Val_Rm));   
  Flushable_Freezable_Register #(24) imm24_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(Signed_imm_24_out), .d(Signed_imm_24));
  Flushable_Freezable_Register #(12) shift_operand_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(Shift_operand_out), .d(Shift_operand));
  Flushable_Freezable_Register #(4) dst_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(Dest_out), .d(Dest));
  Flushable_Freezable_Register #(1) imm_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(imm_out), .d(imm));
  Flushable_Freezable_Register #(1) s_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(S_out), .d(S));
  Flushable_Freezable_Register #(1) b_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(B_out), .d(B));
  Flushable_Freezable_Register #(4) exe_cmd_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(EXE_CMD_out), .d(EXE_CMD));
  Flushable_Freezable_Register #(1) mem_w_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(MEM_W_EN_out), .d(MEM_W_EN));
  Flushable_Freezable_Register #(1) mem_r_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(MEM_R_EN_out), .d(MEM_R_EN));
  Flushable_Freezable_Register #(1) wb_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(WB_EN_out), .d(WB_EN));

  Flushable_Freezable_Register #(4) status_regs (.q({Z, C, V, N}), .d({Z_in, C_in, V_in, N_in}), .flush(flush), .freeze(freeze), .clk(clk), .rst(rst));
  
  Flushable_Freezable_Register #(4) src1_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(src1_out), .d(src1));
  Flushable_Freezable_Register #(4) src2_register (.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .q(src2_out), .d(src2));
  
endmodule