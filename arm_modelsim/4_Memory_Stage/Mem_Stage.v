`include "configs.v"

module Mem_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc
);
  
  assign pc = pc_in;
  
  Regular_Register #(`ADDRESS_LEN) pc_register (.q(pc), .d(pc_in), .clk(clk), .rst(rst));
  
endmodule
