`include "configs.v"

module WB_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  input [`ADDRESS_LEN - 1:0] ALU_Res, data_memory_out,
  input MEM_R_EN, WB_EN,
  input Dest,
  
  output [3:0] Dest_out,
  output [`ADDRESS_LEN - 1:0] WB_Value,
  output WB_WB_EN
  
);
  
  Mux #(`ADDRESS_LEN) wb_mux
  (
      .first(data_memory_out),
      .second(ALU_Res),
      .select(MEM_R_EN),
      .out(WB_Value)
  );
  
  assign Dest_out = Dest;
	assign WB_WB_EN = WB_EN;
  
endmodule
