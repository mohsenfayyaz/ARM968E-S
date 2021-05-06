`include "configs.v"

/*
Wires Naming Convention:
IF: purple: p_*
ID: green: g_*
Exe: red: r_*
Mem: golden: go_*
WB: blue: b_*
Hazard: yellow: y_*
*/

module ARM(input clk, rst);
  
  // IF ---------- PURPLE
  wire freeze, branch_taken;
  wire[`ADDRESS_LEN - 1:0] if_pc_out, if_reg_pc_out, if_instruction_out, if_reg_instruction_out;
  
  // ID ---------- GREEN
  // Yellow
  wire y_Hazard;
  // From Status Reg Color
  wire Z, C, V, N;  // Status Reg Outputs
  wire Z_in, C_in, V_in, N_in;  // Status Reg Inputs
  wire exe_Z, exe_C, exe_V, exe_N;  // In exe after last layer regs (black)
  // Blue Wires
  wire b_WB_WB_EN;
  wire [3:0] b_WB_Dest;
  wire [`ADDRESS_LEN - 1:0] b_WB_Value, g_pc_out;
  
  wire g_S, g_B, g_MEM_W_EN, g_MEM_R_EN, g_WB_EN;
  wire [3:0] g_EXE_CMD;
  wire [`ADDRESS_LEN - 1:0] g_Val_Rn, g_Val_Rm;
  wire g_imm;
  wire [23:0] g_Signed_imm_24;
  wire [3:0] g_Dest;
  wire [11:0] g_Shift_operand;
  // Yellow
  wire y_Two_src;
  wire [3:0] y_output_src1, y_output_src2;
  
  // EXE ---------- Red
  wire [`ADDRESS_LEN - 1:0] r_pc, r_pc_out;
  wire [3:0] r_output_src1, r_output_src2;
  wire r_S, r_B, r_MEM_W_EN, r_MEM_R_EN, r_WB_EN, r_MEM_W_EN_out, r_MEM_R_EN_out, r_WB_EN_out;
  wire [3:0] r_EXE_CMD;
  wire [`ADDRESS_LEN - 1:0] r_Val_Rn, r_Val_Rm, r_Val_Rm_out;
  wire [`ADDRESS_LEN - 1:0] r_ALU_Res;
  wire r_imm;
  wire [23:0] r_Signed_imm_24;
  wire [3:0] r_Dest, r_Dest_out;
  wire [11:0] r_Shift_operand;
  wire [`ADDRESS_LEN - 1:0] r_Branch_Address;
  
  // 
  
  
  assign freeze = 0;
  assign branch_taken = 0;
  
  IF_Stage if_stage(
    .clk(clk),
    .rst(rst), 
    .freeze(freeze),
    .branch_taken(branch_taken), 
    .branch_address(r_Branch_Address),
    .next_pc(if_pc_out), 
    .instruction_out(if_instruction_out)
  );
  
  IF_Stage_Reg if_stage_reg(
    .clk(clk),
    .rst(rst), 
    .freeze(freeze),
    .flush(r_Branch_Tacken),
    .pc_in(if_pc_out), 
    .instruction_in(if_instruction_out),
    .pc_out(if_reg_pc_out), 
    .instruction_out(if_reg_instruction_out)
  );
  
  ID_Stage id_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(if_reg_pc_out),
    .pc(g_pc_out),
    .instruction(if_instruction_out),
    .Hazard(y_Hazard), 
    .z(Z), .c(C), .v(V), .n(N),
    .WB_WB_EN(b_WB_WB_EN),
    .WB_Dest(b_WB_Dest),
    .WB_Value(b_WB_Value),
    // Outputs
    .S(g_S), .B(g_B),
    .MEM_W_EN(g_MEM_W_EN), .MEM_R_EN(g_MEM_R_EN), .WB_EN(g_WB_EN),
    .EXE_CMD(g_EXE_CMD),
    .Val_Rn(g_Val_Rn), .Val_Rm(g_Val_Rm),
    .imm(g_imm),
    .Signed_imm_24(g_Signed_imm_24),
    .Dest(g_Dest), 
    .Shift_operand(g_Shift_operand),
    .Two_src(y_Two_src),
    .output_src1(y_output_src1), .output_src2(y_output_src2)
  );
  
  ID_Stage_Reg id_stage_reg(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(g_pc_out),
    .S(g_S), .B(g_B), .MEM_W_EN(g_MEM_W_EN), .MEM_R_EN(g_MEM_R_EN), .WB_EN(g_WB_EN), .imm(g_imm),
    .Val_Rn(g_Val_Rn), .Val_Rm(g_Val_Rm),
    .Signed_imm_24(g_Signed_imm_24),
    .Dest(g_Dest), .EXE_CMD(g_EXE_CMD), .src1(y_output_src1), .src2(y_output_src1),
    .Shift_operand(g_Shift_operand), 
    .flush(r_Branch_Tacken),
    .Z_in(Z), .C_in(C), .V_in(V), .N_in(N),
    // Output
    .pc(r_pc),
    .S_out(r_S), .B_out(r_Branch_Tacken), .MEM_W_EN_out(r_MEM_W_EN), .MEM_R_EN_out(r_MEM_R_EN), .WB_EN_out(r_WB_EN), .imm_out(r_imm),
    .Val_Rn_out(r_Val_Rn), .Val_Rm_out(r_Val_Rm),
    .Signed_imm_24_out(r_Signed_imm_24),
    .Dest_out(r_Dest), .EXE_CMD_out(r_EXE_CMD), .src1_out(r_output_src1), .src2_out(r_output_src2),
    .Shift_operand_out(r_Shift_operand),
    .Z(exe_Z), .C(exe_C), .V(exe_V), .N(exe_N)
  );
  
  
  Exe_Stage exe_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(r_pc),
    
    .S(r_S), .Branch_Tacken(r_B) /*B*/, .MEM_W_EN(r_MEM_W_EN), .MEM_R_EN(r_MEM_R_EN), .WB_EN(r_WB_EN), .imm(r_imm),
    .Val1(r_Val_Rn) /*Val_Rn*/, .Val_Rm(r_Val_Rm),
    .Signed_imm_24(r_Signed_imm_24),
    .Dest(r_Dest), .EXE_CMD(r_EXE_CMD),
    .Shift_operand(r_Shift_operand),
    .C(exe_C), .V(exe_V), .Z(exe_Z), .N(exe_N),
  
  // Output
    .pc(r_pc_out),
    .MEM_W_EN_out(r_MEM_W_EN_out), .MEM_R_EN_out(r_MEM_R_EN_out), .WB_EN_out(r_WB_EN_out),
    .ALU_Res(r_ALU_Res), .Val_Rm_out(r_Val_Rm_out),
    .Dest_out(r_Dest_out),
    .C_out(C_in), .V_out(V_in), .Z_out(Z_in), .N_out(N_in),
    .Branch_Tacken_out(r_Branch_Tacken),  // TODO: Check Possible Elimination
    .Branch_Address(r_Branch_Address)
  );
  
  
  
endmodule