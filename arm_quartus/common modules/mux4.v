module Mux4
#(parameter WIDTH = 8)
(
    input wire [WIDTH - 1:0] first,
    input wire [WIDTH - 1:0] second,
    input wire [WIDTH - 1:0] third,
    input wire [WIDTH - 1:0] fourth,
    input [1:0] select,
    
    output wire [WIDTH - 1:0] out
);
    assign out = (select == 2'b00) ? first : 
                 (select == 2'b01) ? second :
                 (select == 2'b10) ? third :
                 fourth;
                 
endmodule