`include "configs.v"

module Cache_Controller(
  input clk, rst, 
  
  
  // inputs and outputs related to the memory stage
  input [31:0] address, 
  input [31:0] writeData,
  
  input MEM_R_EN, 
  input MEM_W_EN,
  
  output [31:0] rdata,
  output ready,
  
  // inputs and outputs related to the SRAM
  output [31:0] sram_address,
  output [31:0] sram_write_data,
  
  output sram_write_en,
  output sram_read_en,
  input [63:0] sram_read_data, 
  input sram_ready
);

endmodule