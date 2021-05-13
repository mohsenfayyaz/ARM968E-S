`include "configs.v"

module IF_Stage_Reg(
  input clk, rst, freeze, flush,
  input[`ADDRESS_LEN - 1:0] pc_in, instruction_in,
  output[`ADDRESS_LEN - 1:0] pc_out, instruction_out
);
  
  Flushable_Freezable_Register #(`ADDRESS_LEN) pc_register
  (
    .d(pc_in),
    .q(pc_out),
    .freeze(freeze),
    .clk(clk),
    .rst(rst), 
    .flush(flush)
  );
  
  
  Flushable_Freezable_Register #(`ADDRESS_LEN) instruction_register
  (
    .q(instruction_out),
    .d(instruction_in),
    .freeze(freeze),
    .clk(clk),
    .rst(rst), 
    .flush(flush)
  );

endmodule
