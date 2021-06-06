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

  wire [16:0] cache_address;
  
  wire [31:0] address_1024;
  assign address_1024 = address - 1024;
  assign cache_address = address_1024[17:2]; // not sure about this ?????????????????
  
  wire [63:0] cache_write_data;
  wire [31:0] cache_read_data;
  wire cache_write_en, cache_read_en, cache_invoke;
  wire cache_hit;
  wire sram_second_ready;
  
  Cache cache(
    .clk(clk), .rst(rst),
    .address(cache_address),
    .write_data(cache_write_data),
  
    .read_en(cache_read_en),
    .write_en(cache_write_en),
    .invoke_set_en(cache_invoke),
  
    .read_data(cache_read_data),
    .hit(cache_hit)
  );
  
  // Controller Regs
  wire[2:0] ps, ns;
  parameter S_IDLE = 3'b000, S_CACHE_READ = 3'b001, S_SRAM_READ_1 = 3'b010, S_SRAM_READ_2 = 3'b011, S_SRAM_WRITE = 3'b100, S_CACHE_WRITE = 3'b101; // States
  Regular_Register #(.SIZE(3)) ps_reg(.q(ps), .d(ns), .clk(clk), .rst(rst));    
    
    
    // ns Reg
  assign ns = (ps == S_IDLE && MEM_R_EN) ? S_CACHE_READ :
              (ps == S_CACHE_READ && ~cache_hit) ? S_SRAM_READ_1 :
              (ps == S_CACHE_READ && cache_hit) ? S_IDLE :
              (ps == S_SRAM_READ_1 && sram_ready) ? S_CACHE_WRITE :
              //(ps == S_SRAM_READ_2 && sram_ready) ? S_CACHE_WRITE :
              (ps == S_CACHE_WRITE) ? S_CACHE_READ :
              (ps == S_IDLE && MEM_W_EN) ? S_SRAM_WRITE :
              (ps == S_SRAM_WRITE && sram_ready) ? S_IDLE :
              ps; 
              
  assign sram_second_ready = (ps == S_SRAM_READ_1) && sram_ready;
   
  assign rdata = (ps == S_CACHE_READ && cache_hit) ? cache_read_data :
                 32'bz;
                 
  assign ready = ((ps == S_IDLE) && (MEM_R_EN || MEM_W_EN)) ? 1'b0 :
                  (ps == S_SRAM_WRITE && sram_ready == 1'b1) ? 1'b1 :
                  (ps == S_CACHE_READ && cache_hit) || (ps == S_IDLE);
  
//  assign sram_address = (ps == S_SRAM_READ_1) ? {address[31:3], 1'b0, address[1:0]} :
//                        (ps == S_SRAM_READ_2) ? {address[31:3], 1'b1, address[1:0]} :
//                        (ps == S_SRAM_WRITE) ? address :
//                        32'bz;
  
  assign sram_address = (ps == S_SRAM_READ_1) ? address :
                        (ps == S_SRAM_WRITE) ? address :
                        64'bz;
  
  assign sram_write_data = (ps == S_SRAM_WRITE) ? writeData : 
                            //32'bz;
                            64'bz;
  
  assign sram_write_en = (ps == S_SRAM_WRITE);
                         
  assign sram_read_en = (ps == S_SRAM_READ_1 || ps == S_SRAM_READ_2);
  
  Freezable_Register #(.SIZE(64)) cache_write_data_reg0(.q(cache_write_data), .d(sram_read_data), .freeze(~(ps == S_SRAM_READ_1 && sram_ready)), .clk(clk), .rst(rst));
  //Freezable_Register #(.SIZE(32)) cache_write_data_reg1(.q(cache_write_data[63:32]), .d(sram_read_data), .freeze(~(ps == S_SRAM_READ_2 && sram_ready)), .clk(clk), .rst(rst)); 
  
  assign cache_read_en = (ps == S_CACHE_READ);
  assign cache_write_en = (ps == S_CACHE_WRITE);
  assign cache_invoke = (ps == S_SRAM_WRITE);
             
endmodule