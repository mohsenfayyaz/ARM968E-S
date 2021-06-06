`include "configs.v"

module Flushable_Freezable_Register 
# (parameter SIZE = `ADDRESS_LEN)
(
    output reg [SIZE - 1:0] q,
    input [SIZE - 1:0] d,
    input clk,
    input rst, 
    input freeze, flush
);
    always @(posedge clk,posedge rst) begin
      if (rst) q <= 0;
      else if (!freeze) begin
        if (!flush) q <= d;
        else q <= 0;
      end
    end
endmodule
