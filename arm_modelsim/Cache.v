module Cache(
  input clk, rst,
  input [18:0] address,
  input [31:0] write_data,
  
  input read_en,
  input write_en,
  input invoke_set,
  
  output [31:0] read_data,
  output hit
  
);

  wire [9:0] tag;
  wire [2:0] offset;
  wire [5:0] index;
  
  assign tag = address[18:9];
  assign index = address[8:3];
  assign offset = address[2:0];
  
  // arrays for the data being saved in associated blocks in each index and set
  reg [31:0] data_set_1 [0:1][0:63];
  reg [31:0] data_set_2 [0:1][0:63];
  
  // arrays for tags associtaed with given indices
  reg [9:0] tag_set_1 [0:63];
  reg [9:0] tag_set_2 [0:63];
  
  // arrays for valid bits corresponding to indices
  reg valid_set_1 [0:63];
  reg valid_set_2 [0:63];
 
  // lru bit
  reg lru [0:63];
   
  // initialize all the valid bits with zero
  integer i;
  initial begin
    for (i = 0; i <= 63; i = i + 1)
      valid_set_1[i] = 1'b0;
      valid_set_2[i] = 1'b0;
      lru[i] = 1'b0;
  end
  
  
  // computing the hit bit for each set
  wire set_1_hit_result, set_2_hit_result;
  assign set_1_hit_result = (tag_set_1[index] == tag) && valid_set_1[index];
  assign set_2_hit_result = (tag_set_2[index] == tag) && valid_set_2[index];
  
  assign hit = set_1_hit_result || set_2_hit_result;
  
  // finding the acquired value from two sets
  
  Mux #(.WIDTH(32)) data_mux(
    .first(data_set_1[offset[2]][index]), 
    .second(data_set_2[offset[2]][index]),
    .select(~set_1_hit_result),
    .out(read_data) 
  );
  
  // modifying the lru bit upon reading a set
  always @(*) begin
    if (read_en)
      lru[index] = set_1_hit_result ? 1'b0: 1'b1; // 0 for the first set and 1 for the second set
    else
      lru[index] = lru[index];
  end
  
  always @(*) begin
    if (invoke_set && hit) begin
      if (set_1_hit_result == 1'b1)
        valid_set_1[index] = 1'b0;
      else if(set_2_hit_result == 1'b1)
        valid_set_2[index] = 1'b0;
    end
  end
  
  always @(*) begin
    if (write_en) begin
      data_set_1[~lru[index]][index] = write_data;
      lru[index] = ~lru[index];
    end
  end
  
  
  
endmodule