module ARM_TB ();

  reg clk = 0, rst = 0;

  ARM arm(.clk(clk), .rst(rst));

  always #10 clk = ~clk; //50MHz

  initial begin
    rst = 1;
    #200
    rst = 0;
    #10000
    $stop; 
  end
    
endmodule
