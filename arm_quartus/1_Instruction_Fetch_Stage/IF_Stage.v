`include "configs.v"

module IF_Stage(
  input clk, rst, freeze, branch_taken, 
  input[`ADDRESS_LEN - 1:0] branch_address,
  output[`ADDRESS_LEN - 1:0] next_pc, instruction_out
);
  
  wire [`ADDRESS_LEN - 1 : 0] pc;
  wire [`ADDRESS_LEN - 1 : 0] pc_out;

  Mux #(`ADDRESS_LEN) pc_mux
  (
      .first(next_pc),
      .second(branch_address),
      .select(branch_taken),
      .out(pc)
  );

  Flushable_Freezable_Register #(`ADDRESS_LEN) pc_register
  (
      .d(pc),
      .q(pc_out),
      .freeze(freeze),
      .clk(clk),
      .rst(rst), 
      .flush(1'b0)
  );

  Instruction_Memory instruction_mem
  (
      .instruction(instruction_out),
      .address(pc_out)
  );
  
  assign next_pc = pc_out + 4;
  
endmodule