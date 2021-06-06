`include "configs.v"

module Exe_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  // Input
  input S, Branch_Tacken /*B*/, MEM_W_EN, MEM_R_EN, WB_EN, imm,
  input [`ADDRESS_LEN - 1:0] Val1 /*Val_Rn*/, Val_Rm,
  input [23:0] Signed_imm_24,
  input [3:0] Dest, EXE_CMD,
  input [11:0] Shift_operand,
  input C, V, Z, N,
  // Forward
  input [`ADDRESS_LEN - 1:0] go_ALU_Res, b_WB_Value,
  input [1:0] Sel_src1, Sel_src2,
  
  // Output
  output MEM_W_EN_out, MEM_R_EN_out, WB_EN_out,
  output [`ADDRESS_LEN - 1:0] ALU_Res, Val_Rm_out,
  output [3:0] Dest_out,
  output C_out, V_out, Z_out, N_out,
  output [`ADDRESS_LEN - 1:0] Branch_Address
);
  
  assign pc = pc_in;
  assign MEM_R_EN_out = MEM_R_EN;
	assign MEM_W_EN_out = MEM_W_EN;
  assign WB_EN_out = WB_EN;
	assign Branch_Tacken_out = Branch_Tacken;
	assign Dest_out = Dest;
	assign S_out = S;
	
	wire is_mem;
	assign is_mem = MEM_R_EN | MEM_W_EN;
	
	wire [`ADDRESS_LEN - 1:0] Signed_EX_imm24;
	assign Signed_EX_imm24 = {{6{Signed_imm_24[23]}}, Signed_imm_24, 2'b0};
	assign Branch_Address = Signed_EX_imm24 + pc_in;
	
	wire [`ADDRESS_LEN - 1:0] val2;
	
	// Forwarding Wires
	wire [`ADDRESS_LEN - 1:0] Val1_mux, Val2_mux;
	assign Val_Rm_out = Val2_mux;
	
	Mux4 #(`WORD_LEN) Mux_1(.first(Val1), .second(go_ALU_Res), .third(b_WB_Value), .fourth(32'b0), .select(Sel_src1), .out(Val1_mux));
	Mux4 #(`WORD_LEN) Mux_2(.first(Val_Rm), .second(go_ALU_Res), .third(b_WB_Value), .fourth(32'b0), .select(Sel_src2), .out(Val2_mux));
	
  Val2_Generator val2_generator(
      .Val_Rm(Val2_mux), .Shift_operand(Shift_operand), 
      .imm(imm), .is_mem(is_mem), 
      // Output
      .Val2(val2)
	);
  
  
	ALU alu(
      .Val1(Val1_mux), .Val2(val2), 
      .EXE_CMD(EXE_CMD), 
      .C_in(C),
      // Output
			.ALU_Res(ALU_Res), 
			.C(C_out), .V(V_out), .Z(Z_out), .N(N_out)
	);
  
endmodule
