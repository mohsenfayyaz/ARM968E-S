module Hazard_Detection_Unit(
    input [3:0] MEM_Dest, EXE_Dest, src1 /*Rn Address*/, src2 /*Rm or Rd Address(When Mem_W)*/,
    input MEM_WB_EN, EXE_WB_EN, Two_src,
    
    output Hazard
);

  assign Hazard = (
              (EXE_WB_EN && (src1 == EXE_Dest))
            | (MEM_WB_EN && (src1 == MEM_Dest))
            | (EXE_WB_EN && Two_src && (src2 == EXE_Dest))
            | (MEM_WB_EN && Two_src && (src2 == MEM_Dest))
            ) ? 1'b1
            : 1'b0;

endmodule