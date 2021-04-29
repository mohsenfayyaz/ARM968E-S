`include "configs.v"

module Freezable_Register 
#(parameter SIZE = `ADDRESS_LEN)
(
    input clk,
    input rst,
    input freeze,
    input[SIZE - 1 : 0 ] d,
    output reg[SIZE - 1 : 0 ] q
);
    always @(posedge clk, posedge rst)
        if (rst) q <= 0;
        else if (!freeze) q <= d;
endmodule