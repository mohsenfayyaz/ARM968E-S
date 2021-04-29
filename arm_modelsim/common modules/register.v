`include "configs.v"

module Register 
(
    output reg [`ADDRESS_LEN - 1 : 0 ] q,
    input [`ADDRESS_LEN - 1 : 0 ] d,
    input freeze,
    input clk,
    input rst
);
    always @(posedge clk,posedge rst)
        if (rst) q <= 0;
        else if (!freeze) q <= d;
endmodule