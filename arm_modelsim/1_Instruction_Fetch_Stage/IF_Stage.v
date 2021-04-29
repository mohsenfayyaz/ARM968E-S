`include "configs.v"

module IF_Stage(
  input clk, rst, freeze, branch_taken, 
  input[`ADDRESS_LEN - 1:0] branch_address,
  output[`ADDRESS_LEN - 1:0] pc, instruction
);


wire [ADDRESS_SIZE - 1 : 0] pc_in;
wire [ADDRESS_SIZE - 1 : 0] next_pc;

Mux #(`ADDRESS_LEN) pc_mux
(
    .first(next_pc),
    .second(branch_address),
    .select(branch_taken),
    .out(pc_in)
);

Register pc_register
(
    .q(pc),
    .d(pc_in),
    .freeze(freeze),
    .clk(clk),
    .rst(rst)
);

InstructionMemory instruction_mem
(
    .q(instruction),
    .d(pc)
);
  

assign next_pc = pc + 4;
  
  
endmodule