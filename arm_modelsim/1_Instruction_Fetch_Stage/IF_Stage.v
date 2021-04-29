`include "configs.v"

module IF_Stage(
  input clk, rst, freeze, branch_taken, 
  input[`ADDRESS_LEN - 1:0] branch_address,
  output[`ADDRESS_LEN - 1:0] pc_out, instruction_out
);


  wire [`ADDRESS_LEN - 1 : 0] pc;
  wire [`ADDRESS_LEN - 1 : 0] next_pc;

  Mux #(`ADDRESS_LEN) pc_mux
  (
      .first(next_pc),
      .second(branch_address),
      .select(branch_taken),
      .out(pc)
  );

  Freezable_Register pc_register
  (
      .d(pc),
      .q(pc_out),
      .freeze(freeze),
      .clk(clk),
      .rst(rst)
  );

  Instruction_Memory instruction_mem
  (
      .instruction(instruction_out),
      .address(pc)
  );
  

  assign next_pc = pc + 4;
  
  
endmodule