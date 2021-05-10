`include "configs.v"

module Register_File (
    input clk, rst, 
    input [3:0] src1, src2, dest_wb, 
    input signed [`ADDRESS_LEN - 1:0] result_wb, 
    input wb_en,
    output [`ADDRESS_LEN - 1:0] reg1, reg2
);

  reg signed [`ADDRESS_LEN - 1:0] registers[0:14];

  assign reg1 = registers[src1];
  assign reg2 = registers[src2];

  integer i;
  always@(negedge clk,posedge rst) begin
    if (rst) begin
      for (i = 0; i < 15; i = i + 1)
        registers[i] <= i;
      end
    else if (wb_en) begin
      registers[dest_wb] <= result_wb;
      $display("WRITE regs[%d] = %d", dest_wb, result_wb);
      if(dest_wb == 32'd6)
        for(i = 0; i < 15; i = i + 1)
          if(i == dest_wb)
            $display("Reg[%d] = %d", i, result_wb);
          else
            $display("Reg[%d] = %d", i, registers[i]);
    end
  end

endmodule