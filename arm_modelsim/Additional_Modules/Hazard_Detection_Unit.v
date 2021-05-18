module Hazard_Detection_Unit(
    input [3:0] MEM_Dest, EXE_Dest, src1 /*Rn Address*/, src2 /*Rm or Rd Address(When Mem_W)*/,
    input MEM_WB_EN, EXE_WB_EN, Two_src,
    input [3:0] EXE_CMD,  // Bonus
    input FORWARDING_EN, EXE_MEM_R_EN, // FORWARDING
    
    output Hazard
);

  wire has_src1;
  assign has_src1 = ~((EXE_CMD == 4'b0001) || (EXE_CMD == 4'b1001));  // Not MOV, MVN, BRANCH

  assign EXE_Hazard = (
              (EXE_WB_EN && (src1 == EXE_Dest) && has_src1)
            | (EXE_WB_EN && Two_src && (src2 == EXE_Dest))
            ) ? 1'b1
            : 1'b0;
  
  assign MEM_Hazard = (
              (MEM_WB_EN && (src1 == MEM_Dest) && has_src1)
            | (MEM_WB_EN && Two_src && (src2 == MEM_Dest))
            ) ? 1'b1
            : 1'b0;
            
  assign Hazard = ~FORWARDING_EN ? (EXE_Hazard | MEM_Hazard) :
                  EXE_MEM_R_EN ? EXE_Hazard :
                  1'b0;

endmodule