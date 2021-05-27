`include "configs.v"

/*
Wires Naming Convention:
IF: purple: p_*
ID: green: g_*
Exe: red: r_*
Mem: golden: go_*
WB: blue: b_*
Hazard: yellow: y_*
Forwarding: dark blue: db_*
*/

module ARM(input clk, rst,
           input FORWARDING_EN,
           output SRAM_WE_N, output [16:0] SRAM_ADDR, inout [31:0] SRAM_DQ);
  
  // IF ---------- PURPLE
  wire[`ADDRESS_LEN - 1:0] p_pc_out, p_instruction;
  
  // ID ---------- GREEN
  wire[`ADDRESS_LEN - 1:0] g_instruction;
  wire g_S, g_B, g_MEM_W_EN, g_MEM_R_EN, g_WB_EN;
  wire [3:0] g_EXE_CMD;
  wire [`ADDRESS_LEN - 1:0] g_pc, g_Val_Rn, g_Val_Rm;
  wire g_imm;
  wire [23:0] g_Signed_imm_24;
  wire [3:0] g_Dest;
  wire [11:0] g_Shift_operand;
 
 
  // Status Reg ---------- No Name Color!
  wire Z, C, V, N;  // Status Reg Outputs
  wire Z_in, C_in, V_in, N_in;  // Status Reg Inputs
  wire exe_Z, exe_C, exe_V, exe_N;  // In exe after ID regs (black)
  
  // Hazard ---------- Yellow
  wire y_Two_src;
  wire [3:0] y_output_src1, y_output_src2;
  wire y_Hazard;  // AKA Freeze
  
  // EXE ---------- Red
  wire [`ADDRESS_LEN - 1:0] r_pc, r_pc_out;
  wire r_S, r_MEM_W_EN, r_MEM_R_EN, r_WB_EN, r_MEM_W_EN_out, r_MEM_R_EN_out, r_WB_EN_out;
  wire [3:0] r_EXE_CMD;
  wire [`ADDRESS_LEN - 1:0] r_Val_Rn, r_Val_Rm, r_Val_Rm_out;
  wire [`ADDRESS_LEN - 1:0] r_ALU_Res;
  wire r_imm;
  wire [23:0] r_Signed_imm_24;
  wire [3:0] r_Dest, r_Dest_out;
  wire [11:0] r_Shift_operand;
  wire r_Branch_Tacken;
  wire [`ADDRESS_LEN - 1:0] r_Branch_Address;
  
  // Mem ---------- Golden (go)
  wire [`ADDRESS_LEN - 1:0] go_pc, go_pc_out;
  wire go_MEM_W_EN, go_MEM_R_EN, go_WB_EN;
  wire [`ADDRESS_LEN - 1:0] go_ALU_Res;
  wire [`ADDRESS_LEN - 1:0] go_Val_Rm;
  wire [3:0] go_Dest;
  wire [`WORD_LEN - 1:0] go_memory_out;
  
  // WB ---------- Blue
  wire [`ADDRESS_LEN - 1:0] b_pc, b_ALU_Res;
  wire [`WORD_LEN - 1:0]b_memory_out;
  wire b_WB_WB_EN;
  wire [3:0] b_WB_Dest;
  wire [`ADDRESS_LEN - 1:0] b_WB_Value, g_pc_out;
  
  wire [3:0] bonus_EXE_CMD;  // For MVE MVN in Hazard
  
  // Forwarding --------- Dark Blue
  wire [3:0] db_src1, db_src2;
  wire [1:0] db_Sel_src1, db_Sel_src2;
  
  // SRAM
  wire SRAM_ready;
  wire SRAM_Freeze_Signal;
  assign SRAM_Freeze_Signal = ~SRAM_ready;
  
  IF_Stage if_stage(
    // Inputs
    .clk(clk),
    .rst(rst), 
    .freeze(y_Hazard),
    .branch_taken(r_Branch_Tacken), 
    .branch_address(r_Branch_Address),
    // Outputs
    .next_pc(p_pc_out), 
    .instruction_out(p_instruction)
  );
  
  IF_Stage_Reg if_stage_reg(
    // Inputs
    .clk(clk),
    .rst(rst), 
    .freeze(y_Hazard),
    .flush(r_Branch_Tacken),
    .pc_in(p_pc_out), 
    .instruction_in(p_instruction),
    // Outputs
    .pc_out(g_pc), 
    .instruction_out(g_instruction)
  );
  
  ID_Stage id_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(g_pc),
    .instruction(g_instruction),
    .Hazard(y_Hazard), 
    .z(Z), .c(C), .v(V), .n(N),
    .WB_WB_EN(b_WB_WB_EN),
    .WB_Dest(b_WB_Dest),
    .WB_Value(b_WB_Value),
    // Outputs
    .pc(g_pc_out),
    .S(g_S), .B(g_B),
    .MEM_W_EN(g_MEM_W_EN), .MEM_R_EN(g_MEM_R_EN), .WB_EN(g_WB_EN),
    .EXE_CMD(g_EXE_CMD),
    
    .BEFORE_MUX_EXE_CMD(bonus_EXE_CMD),
    
    .Val_Rn(g_Val_Rn), .Val_Rm(g_Val_Rm),
    .imm(g_imm),
    .Signed_imm_24(g_Signed_imm_24),
    .Dest(g_Dest), 
    .Shift_operand(g_Shift_operand),
    .Two_src(y_Two_src),
    .output_src1(y_output_src1), .output_src2(y_output_src2 /*Actually Black*/)
  );
  
  ID_Stage_Reg id_stage_reg(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(g_pc_out),
    .S(g_S), .B(g_B), .MEM_W_EN(g_MEM_W_EN), .MEM_R_EN(g_MEM_R_EN), .WB_EN(g_WB_EN), .imm(g_imm),
    .Val_Rn(g_Val_Rn), .Val_Rm(g_Val_Rm),
    .Signed_imm_24(g_Signed_imm_24),
    .Dest(g_Dest), .EXE_CMD(g_EXE_CMD), .src1(y_output_src1), .src2(y_output_src2),
    .Shift_operand(g_Shift_operand), 
    .flush(r_Branch_Tacken),
    .Z_in(Z), .C_in(C), .V_in(V), .N_in(N),
    // Output
    .pc(r_pc),
    .S_out(r_S), .B_out(r_Branch_Tacken), .MEM_W_EN_out(r_MEM_W_EN), .MEM_R_EN_out(r_MEM_R_EN), .WB_EN_out(r_WB_EN), .imm_out(r_imm),
    .Val_Rn_out(r_Val_Rn), .Val_Rm_out(r_Val_Rm),
    .Signed_imm_24_out(r_Signed_imm_24),
    .Dest_out(r_Dest), .EXE_CMD_out(r_EXE_CMD), .src1_out(db_src1), .src2_out(db_src2),
    .Shift_operand_out(r_Shift_operand),
    .Z(exe_Z), .C(exe_C), .V(exe_V), .N(exe_N)
  );
  
  Hazard_Detection_Unit hazard_detection_unit(
    // Inputs
    .MEM_Dest(go_Dest), .EXE_Dest(r_Dest), .src1(y_output_src1) /*Rn Address*/, .src2(y_output_src2 /*Actually Black*/) /*Rm or Rd Address(When Mem_W)*/,
    .MEM_WB_EN(go_WB_EN), .EXE_WB_EN(r_WB_EN), .Two_src(y_Two_src),
    .EXE_CMD(bonus_EXE_CMD),  // BONUS
    .FORWARDING_EN(FORWARDING_EN), .EXE_MEM_R_EN(r_MEM_R_EN),
    // Outputs
    .Hazard(y_Hazard)
  );
  
  
  Exe_Stage exe_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(r_pc),
    
    .S(r_S), .Branch_Tacken(r_Branch_Tacken) /*B*/, .MEM_W_EN(r_MEM_W_EN), .MEM_R_EN(r_MEM_R_EN), .WB_EN(r_WB_EN), .imm(r_imm),
    .Val1(r_Val_Rn) /*Val_Rn*/, .Val_Rm(r_Val_Rm),
    .Signed_imm_24(r_Signed_imm_24),
    .Dest(r_Dest), .EXE_CMD(r_EXE_CMD),
    .Shift_operand(r_Shift_operand),
    .C(exe_C), .V(exe_V), .Z(exe_Z), .N(exe_N),
    // Forward
    .go_ALU_Res(go_ALU_Res), .b_WB_Value(b_WB_Value),
    .Sel_src1(db_Sel_src1), .Sel_src2(db_Sel_src2),
  
  // Output
    .pc(r_pc_out),
    .MEM_W_EN_out(r_MEM_W_EN_out), .MEM_R_EN_out(r_MEM_R_EN_out), .WB_EN_out(r_WB_EN_out),
    .ALU_Res(r_ALU_Res), .Val_Rm_out(r_Val_Rm_out),
    .Dest_out(r_Dest_out),
    .C_out(C_in), .V_out(V_in), .Z_out(Z_in), .N_out(N_in),
    .Branch_Address(r_Branch_Address)
  );
  
  
  Exe_Stage_Reg exe_stage_reg(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(r_pc_out),
    .ALU_Res(r_ALU_Res), .Val_Rm(r_Val_Rm_out),
    .MEM_W_EN(r_MEM_W_EN_out), .MEM_R_EN(r_MEM_R_EN_out), .WB_EN(r_WB_EN_out),
    .Dest(r_Dest_out),
  
    // output
    .pc(go_pc),
    .MEM_W_EN_out(go_MEM_W_EN), .MEM_R_EN_out(go_MEM_R_EN), .WB_EN_out(go_WB_EN),
    .ALU_Res_out(go_ALU_Res), .Val_Rm_out(go_Val_Rm),
    .Dest_out(go_Dest)
  );
  
  Status_Register status_register(
    // Inputs
    .clk(clk), .rst(rst),
    .S(r_S),
    .C(C_in), .V(V_in), .Z(Z_in), .N(N_in),
    // Outputs
    .C_out(C), .V_out(V), .Z_out(Z), .N_out(N)
  );
  
  Mem_Stage mem_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(go_pc),
    .MEM_W_EN(go_MEM_W_EN), .MEM_R_EN(go_MEM_R_EN),
    .ALU_Res(go_ALU_Res),
    .Val_Rm(go_Val_Rm),
    
    // Outputs
    .pc(go_pc_out),
    .memory_out(go_memory_out),
    
    // SRAM
    .SRAM_WE_N(SRAM_WE_N), .SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ), .SRAM_ready(SRAM_ready)
  );
  
  Mem_Stage_Reg mem_stage_reg(
    // Inputs
    .clk(clk), .rst(rst),
    .pc_in(go_pc_out),
    .ALU_Res(go_ALU_Res),
    .memory_out(go_memory_out),
    .MEM_R_EN(go_MEM_R_EN), .WB_EN(go_WB_EN),
    .Dest(go_Dest),
    // Outputs
    .pc(b_pc),
    .ALU_Res_out(b_ALU_Res),
    .memory_reg_out(b_memory_out),
    .MEM_R_EN_out(b_MEM_R_EN), .WB_EN_out(b_WB_WB_EN),
    .Dest_out(b_WB_Dest)
  );
  
  WB_Stage wb_stage(
    // Inputs
    .clk(clk), .rst(rst),
    .ALU_Res(b_ALU_Res), .data_memory_out(b_memory_out),
    .MEM_R_EN(b_MEM_R_EN),
    // Outputs
    .WB_Value(b_WB_Value)
  );
  
  
  Forwarding_Unit forwarding_unit(
    .src1(db_src1), .src2(db_src2), .MEM_Dest(go_Dest), .WB_Dest(b_WB_Dest),
    .MEM_WB_EN(go_WB_EN), .WB_WB_EN(b_WB_WB_EN), .FORWARDING_EN(FORWARDING_EN),
    // Output
    .Sel_src1(db_Sel_src1), .Sel_src2(db_Sel_src2)
  );
  
  
  
endmodule