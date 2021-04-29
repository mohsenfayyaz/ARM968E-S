`include "configs.v"

module ARM(input clk, rst);
  
  wire freeze, branch_taken, flush;
  wire[`ADDRESS_LEN - 1:0] branch_address, if_pc_out, if_reg_pc_out, if_instruction_out, if_reg_instruction_out;
  
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
  
  
  
  
endmodule