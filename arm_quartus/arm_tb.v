`include "configs.v"
`timescale 1ns/1ns

module arm_tb (output smart_quartus, input quartus_clk);

  reg clk = 0, rst = 0, sram_clk = 0;
  wire SRAM_WE_N;
  wire [16:0] SRAM_ADDR;
  wire [31:0] SRAM_DQ;
  wire [63:0] SRAM_DQ64;
  wire smart_quartus_wire;
  assign smart_quartus = smart_quartus_wire;
  
  arm arm(.clk(quartus_clk), .rst(rst), .FORWARDING_EN(1'b1),
    // SRAM
    .SRAM_WE_N(SRAM_WE_N), .SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ), .SRAM_DQ64(SRAM_DQ64),
	 .smart_quartus(smart_quartus_wire)
  );
  
  

  always #10 clk = ~clk; //50MHz
  always #20 sram_clk = ~sram_clk; //25MHz

  initial begin
    rst = 1;
    #200
    rst = 0;
    #30000
    $stop; 
  end
    
endmodule
