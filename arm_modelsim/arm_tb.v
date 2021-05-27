`include "configs.v"
`timescale 1ns/1ns

module ARM_TB ();

  reg clk = 0, rst = 0, sram_clk = 0;
  wire SRAM_WE_N;
  wire [16:0] SRAM_ADDR;
  wire [31:0] SRAM_DQ;
  
  ARM arm(.clk(clk), .rst(rst), .FORWARDING_EN(1'b1),
    // SRAM
    .SRAM_WE_N(SRAM_WE_N), .SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ)
  );
  
  generate
    if(`USE_SRAM)
      SRAM sram(
        .CLK(sram_clk), .RST(rst),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_ADDR(SRAM_ADDR),  //  17 Bits
        .SRAM_DQ(SRAM_DQ)  //  Data 32 Bits
      );
  endgenerate

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
