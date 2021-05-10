`include "configs.v"

module ALU(
    input [3:0] EXE_CMD,
    input signed [`WORD_LEN - 1:0] Val1, Val2,
    input C_in,
    output reg signed [`WORD_LEN - 1:0] ALU_Res,
    output reg C, V,
    output Z, N
);

 assign Z = &{~{ALU_Res}};
  assign N = ALU_Res[31];

  always@(*) begin
    {ALU_Res, C, V} = 0; 
    case(EXE_CMD)
        4'b0001: begin // MOV
            ALU_Res = Val2;
        end
        4'b1001: begin // MVN
            ALU_Res = ~Val2;
        end
        4'b0010: begin // ADD
            {C, ALU_Res} = {Val1[31], Val1} + {Val2[31], Val2};
            V = C ^ ALU_Res[31];
        end
        4'b0011: begin // ADC
            {C, ALU_Res} = {Val1[31], Val1} + {Val2[31], Val2} + C_in;
            V = C ^ ALU_Res[31];
        end
        4'b0100: begin // SUB
            {C, ALU_Res} = {Val1[31], Val1} - {Val2[31], Val2};
            V = C ^ ALU_Res[31];
        end
        4'b0101: begin // SBC
            {C, ALU_Res} = {Val1[31], Val1} - {Val2[31], Val2} - {32'b0, ~C_in};
            V = C ^ ALU_Res[31];
        end
        4'b0110: begin // AND
            ALU_Res = Val1 & Val2;
        end
        4'b0111: begin // ORR
            ALU_Res = Val1 | Val2;
        end
        4'b1000: begin // EOR
            ALU_Res = Val1 ^ Val2;
        end
        4'b0100: begin // CMP
            {C, ALU_Res} = {Val1[31], Val1} - {Val2[31], Val2};
            V = C ^ ALU_Res[31];
        end
        4'b0011: begin // TST
            ALU_Res = Val1 & Val2;
        end
        4'b0010: begin // LDR/STR
            {C, ALU_Res} = {Val1[31], Val1} + {Val2[31], Val2};
            V = C ^ ALU_Res[31];
        end
    endcase
    $display("Mohsen: ALU %d,%d,%d = %d,%d", Val1, Val2, C_in, ALU_Res, C);
  end

endmodule