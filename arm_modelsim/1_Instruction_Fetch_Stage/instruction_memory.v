`include "configs.v"

module InstructionMemory 
(
    output reg [`ADDRESS_LEN - 1 : 0 ] q,
    input [`ADDRESS_LEN - 1 : 0 ] d
);
    
always @(*)begin
    if (d[`ADDRESS_LEN - 1:2] == 32'b0)
        q = 32'b1110_00_1_1101_0_0000_0000_000000010101; 
    else if (d[`ADDRESS_LEN - 1:2] == 32'd1)
        q = 32'b1110_00_1_1101_0_0000_0001_101000000001;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd2)
        q = 32'b1110_00_1_1101_0_0000_1101_110000000010;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd3)
        q = 32'b1110_01_0_1111_0_0000_0000_000000000000;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd4)
        q = 32'b1110_01_0_1111_0_0001_0000_000000000000;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd5)
        q = 32'b1110_01_0_1111_1_0000_0000_000000000000;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd6)
        q = 32'b1110_01_0_1111_1_0000_0001_000000000000;
    else if (d[`ADDRESS_LEN - 1:2] == 32'd7)
        q = 32'b1110_10_1_0_111111111111111111111111;
    else
        q = 32'b0000_00_0_0000_0_0000_0000_000000000000;
end 


endmodule