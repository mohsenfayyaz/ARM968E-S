`include "configs.v"

module WB_Stage(
  input clk, rst,
  
  input [`ADDRESS_LEN - 1:0] ALU_Res, data_memory_out,
  input MEM_R_EN,
  output [`ADDRESS_LEN - 1:0] WB_Value
);
  
  Mux #(`ADDRESS_LEN) wb_mux(
      .first(ALU_Res),
      .second(data_memory_out),
      .select(MEM_R_EN),
      .out(WB_Value)
  );
  
endmodule
