`include "configs.v"

module Regular_Register 
# (
    parameter SIZE = `ADDRESS_LEN;
)
(
    output reg [SIZE - 1 : 0 ] q,
    input [SIZE - 1 : 0 ] d,
    input clk,
    input rst
);
    always @(posedge clk,posedge rst)
        if (rst) q <= 0;
        else q <= d;
endmodule