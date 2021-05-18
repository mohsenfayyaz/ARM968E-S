module Forwarding_Unit(
  input[3:0] src1, src2, MEM_Dest, WB_Dest,
  input MEM_WB_EN, WB_WB_EN,
  output[1:0] Sel_src1, Sel_src2
);
  
  assign Sel_src1 = 
              (MEM_WB_EN && (src1 == MEM_Dest)) ? 2'b01 :
              (WB_WB_EN && (src1 == WB_Dest)) ? 2'b10 :
              2'b00;
  
  assign Sel_src2 = 
              (MEM_WB_EN && (src2 == MEM_Dest)) ? 2'b01 :
              (WB_WB_EN && (src2 == WB_Dest)) ? 2'b10 :
              2'b00;

endmodule