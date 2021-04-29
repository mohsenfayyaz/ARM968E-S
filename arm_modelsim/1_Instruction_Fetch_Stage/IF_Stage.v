`include "configs.v"

module IF_Stage(
  input clk, rst, freeze, branch_taken, 
  input[`ADDRESS_LEN - 1:0] branch_address,
  output[`ADDRESS_LEN - 1:0] pc_out, instruction_out
);


wire [ADDRESS_SIZE - 1 : 0] pc;
wire [ADDRESS_SIZE - 1 : 0] next_pc;

Mux #(`ADDRESS_LEN) pc_mux
(
    .first(next_pc),
    .second(branch_address),
    .select(branch_taken),
    .out(pc)
);

Freezable_Register pc_register
(
    .q(pc_out),
    .d(pc),
    .freeze(freeze),
    .clk(clk),
    .rst(rst)
);

InstructionMemory instruction_mem
(
    .q(instruction_out),
    .d(pc)
);
  

assign next_pc = pc + 4;
  
  
endmodule