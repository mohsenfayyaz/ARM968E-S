`include "configs.v"

module IF_Stage_Reg(
  input clk, rst, freeze, flush,
  input[`ADDRESS_LEN - 1:0] pc_in, instruction_in,
  output reg[`ADDRESS_LEN - 1:0] pc_out, instruction_out
);

wire [`ADDRESS_LEN - 1 : 0] pc;
wire [`ADDRESS_LEN - 1 : 0] instruction;

// PC register
Mux # (`ADDRESS_LEN) pc_mux
(
    .first(pc_in),
    .second({`ADDRESS_LEN{1'b0}}),
    .select(flush),
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
// Instruction register
Mux # (`ADDRESS_LEN) instruction_mux
(
    .first(instruction_in),
    .second({`ADDRESS_LEN{1'b0}}),
    .select(flush),
    .out(instruction)
);
Freezable_Register instruction_register
(
    .q(instruction_out),
    .d(instruction),
    .freeze(freeze),
    .clk(clk),
    .rst(rst)
);

endmodule
