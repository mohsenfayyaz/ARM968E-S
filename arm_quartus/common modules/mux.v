module Mux
#(parameter WIDTH = 8)
(
    input wire [WIDTH - 1:0] first,
    input wire [WIDTH - 1:0] second,
    input select,
    output wire [WIDTH - 1:0] out
);
    assign out = (~select) ? first : second;
endmodule