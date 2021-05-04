module Condition_Check
(
    input [3:0] cond,
    input z, c, v, n, 
    output reg check
);
  
  // Page 6 -> Chart 3
  always @(*) begin
    case(cond)
       4'b0000 : check = z;  // Equal
       4'b0001 : check = ~z;  // Not Equal
       4'b0010 : check = c;  // CS/HS
       4'b0011 : check = ~c;  // CC/LO
       4'b0100 : check = n;  // Minus
       4'b0101 : check = ~n;  // Plus
       4'b0110 : check = v;  // Overflow
       4'b0111 : check = ~v;  // No Overflow
       4'b1000 : check = c & ~z;  // HI Unsigned Higher
       4'b1001 : check = ~c & z;  // LS Unsigned Lower or Same
       4'b1010 : check = (n & v) | (~n & ~v);  // GE signed
       4'b1011 : check = (n & ~v) | (~n & v);  // LT signed
       4'b1100 : check = (~z & ((n & v) | (~n & ~v)));  // GT signed
       4'b1101 : check = (z | ((~v & n) | (v & ~n)));  // LE signed
       4'b1110 : check = 1;  // Always
       4'b1111 : check = 1;  // No Need to Implement
    endcase
  end
    
endmodule