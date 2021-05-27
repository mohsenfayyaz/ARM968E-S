`include "configs.v"

module Mem_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  input MEM_R_EN, MEM_W_EN,
  input [`ADDRESS_LEN - 1:0] ALU_Res,
  input [`WORD_LEN - 1:0] Val_Rm,
  output [`WORD_LEN - 1:0] memory_out,
  
  output SRAM_WE_N, output [16:0] SRAM_ADDR, inout [31:0] SRAM_DQ, output SRAM_ready  // SRAM BUS & Control Signals
);
  
  assign pc = pc_in;
  wire[3:0] SRAM_ignored_signals;
  
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
        .ready(SRAM_ready),

        // SRAM
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_UB_N(SRAM_ignored_signals[0]),
        .SRAM_LB_N(SRAM_ignored_signals[1]),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_ignored_signals[2]),
        .SRAM_OE_N(SRAM_ignored_signals[3])
      );
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
