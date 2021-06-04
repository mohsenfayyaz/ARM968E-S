`include "configs.v"

module Mem_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  input MEM_R_EN, MEM_W_EN,
  input [`ADDRESS_LEN - 1:0] ALU_Res,
  input [`WORD_LEN - 1:0] Val_Rm,
  output [`WORD_LEN - 1:0] memory_out,
  
  output SRAM_WE_N, output [16:0] SRAM_ADDR, inout [31:0] SRAM_DQ, output CACHE_SRAM_ready  // SRAM BUS & Control Signals
  //output read // cache ready 
);
  
  // the wires in this part relate the cache controller to the sram controller
  assign pc = pc_in;
  wire[3:0] SRAM_ignored_signals;
  wire [31:0] sram_address;
  wire [31:0] sram_write_data;

  wire sram_write_en, sram_read_en;
  wire [31:0] sram_read_data; 
  wire sram_read;
  
  generate
    if(`USE_SRAM)
      SRAM_Controller sram_controller(
        .clk(clk), .rst(rst),

        // Golden Inputs
        .write_en(MEM_W_EN), .read_en(MEM_R_EN),
        .address(ALU_Res),
        .writeData(Val_Rm),

        // WB
        .readData(memory_out),

        // Freeze
        .ready(CACHE_SRAM_ready),

        // SRAM
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_UB_N(SRAM_ignored_signals[0]),
        .SRAM_LB_N(SRAM_ignored_signals[1]),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_ignored_signals[2]),
        .SRAM_OE_N(SRAM_ignored_signals[3])
      );
    else if(`USE_CACHE) begin
      SRAM_Controller sram_controller(
        .clk(clk), .rst(rst),

        // Golden Inputs
        .write_en(sram_write_en), .read_en(sram_read_en), // ???????
        .address(sram_address),
        .writeData(sram_write_data),

        // WB
        .readData(sram_read_data),

        // Freeze
        .ready(sram_ready),

        // SRAM
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_UB_N(SRAM_ignored_signals[0]),
        .SRAM_LB_N(SRAM_ignored_signals[1]),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_ignored_signals[2]),
        .SRAM_OE_N(SRAM_ignored_signals[3])
      );
      Cache_Controller cache_controller(
        .clk(clk), .rst(rst), 
        .address(ALU_Res), 
        .writeData(Val_Rm), 
        .MEM_R_EN(MEM_R_EN),
        .MEM_W_EN(MEM_W_EN),
        .rdata(memory_out),
        .ready(CACHE_SRAM_ready), 
        .sram_address(sram_address),
        .sram_write_data(sram_write_data),
        .sram_write_en(sram_write_en),
        .sram_read_en(sram_read_en),
        .sram_read_data(sram_read_data), 
        .sram_ready(sram_ready)
      );
    end
    else begin
      Data_Memory data_memory(
        .clk(clk), .rst(rst),
        .MEM_R_EN(MEM_R_EN), .MEM_W_EN(MEM_W_EN),
        .ALU_Res(ALU_Res),  // Address
        .Val_Rm(Val_Rm),  // Writing Value
        .out(memory_out)
      );
      assign SRAM_ready = 1'b1;
    end
  endgenerate
  
  
endmodule
