`include "configs.v"

module IF_Stage_Reg(
  input clk, rst, freeze, flush,
  input[`ADDRESS_LEN - 1:0] pc_in, instruction_in,
  output reg[`ADDRESS_LEN - 1:0] pc, instruction
);

endmodule
