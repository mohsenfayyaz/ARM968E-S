`include "configs.v"

module Status_Register (
    input clk, rst,
    input S,
    input C, V, Z, N,
    output reg C_out, V_out, Z_out, N_out
);

	always@(negedge clk, posedge rst) begin
		if (rst) {C_out, V_out, Z_out, N_out} <= 4'b0;
		else if (S) {C_out, V_out, Z_out, N_out} <= {C, V, Z, N};
	end
	
endmodule