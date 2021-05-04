`include "configs.v"

module ARM(input clk, rst);
  
  // IF ---------- PURPLE
  wire freeze, branch_taken, flush;
  wire[`ADDRESS_LEN - 1:0] branch_address, if_pc_out, if_reg_pc_out, if_instruction_out, if_reg_instruction_out;
  
  // ID ---------- GREEN
  // Yellow
  wire y_Hazard;
  // From Status Reg Color
  wire Z, C, V, N;
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
  
  // EXE ----------
  
  
  assign freeze = 0;
  assign branch_taken = 0;
  assign branch_address = 32'b0;
  assign flush = 0;
  
  IF_Stage if_stage(
    .clk(clk),
    .rst(rst), 
    .freeze(freeze),
    .branch_taken(branch_taken), 
    .branch_address(branch_address),
    .pc_out(if_pc_out), 
    .instruction_out(if_instruction_out)
  );
  
  IF_Stage_Reg if_stage_reg(
    .clk(clk),
    .rst(rst), 
    .freeze(freeze),
    .flush(flush),
    .pc_in(if_pc_out), 
    .instruction_in(if_instruction_out),
    .pc_out(if_reg_pc_out), 
    .instruction_out(if_reg_instruction_out)
  );
  
  ID_Stage id_stage(
    // Inputs
    .clk(clk),
    .rst(rst),
    .pc_in(if_reg_pc_out),
    .pc(g_pc_out),
    .instruction(if_instruction_out),
    .Hazard(y_Hazard), 
    .z(z), .c(C), .v(V), .n(N),
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
  
  
  
  
endmodule