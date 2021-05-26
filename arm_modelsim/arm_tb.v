module ARM_TB ();

  reg clk = 0, rst = 0, sram_clk = 0;

  ARM arm(.clk(clk), .rst(rst), .FORWARDING_EN(1'b1));

  always #10 clk = ~clk; //50MHz
  always #20 sram_clk = ~sram_clk; //25MHz

  initial begin
    rst = 1;
    #200
    rst = 0;
    #10000
    $stop; 
  end
    
endmodule
