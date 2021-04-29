`include "configs.v"

module RegisterFile (
    input clk, rst, 
    input [3:0] src1, src2, dest_wb, 
    input [`ADDRESS_LEN - 1: 0] result_wb, 
    input writeback_enable,
    output [`ADDRESS_LEN - 1: 0] reg1, reg2
);

reg [`ADDRESS_LEN - 1 : 0] registers[0 : `REG_COUNT - 1];

assign reg1 = registers[src1];
assign reg2 = registers[src2];

integer i;
always@(negedge clk,posedge rst) begin
    if (rst) begin
        for (i = 0; i < REG_COUNT; i = i + 1)
            registers[i] <= i;
    end
    else if (writeback_enable) begin
        registers[dst_wb] <= result_wb;
    end
end
    
endmodule