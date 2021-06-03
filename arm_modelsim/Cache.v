module Cache(
  input clk, rst,
  input [18:0] address,
  input [31:0] write_data,
  
  input read_en,
  input write_en,
  
  output [31:0] read_data,
  output hit
  
);

endmodule