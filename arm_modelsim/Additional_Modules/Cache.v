module Cache(
  input clk, rst,
  input [16:0] address,
  input [63:0] write_data,
  
  input read_en,
  input write_en,
  input invoke_set_en,  // Make It Invalid
  
  output [31:0] read_data,
  output hit
  
);

  wire [9:0] tag;
  wire offset;
  wire [5:0] index;
  
  assign tag = address[16:7];
  assign index = address[6:1];
  assign offset = address[0];
  
  // arrays for the data being saved in associated blocks in each index and set
  reg [31:0] data_set_0 [0:1][0:63];
  reg [31:0] data_set_1 [0:1][0:63];
  
  // arrays for tags associtaed with given indices
  reg [9:0] tag_set_0 [0:63];
  reg [9:0] tag_set_1 [0:63];
  
  // arrays for valid bits corresponding to indices
  reg valid_set_0 [0:63];
  reg valid_set_1 [0:63];
 
  // lru bit
  reg lru [0:63];
   
  // initialize all the valid bits with zero
  integer i;
  initial begin
    for (i = 0; i <= 63; i = i + 1) begin
      valid_set_0[i] = 1'b0;
      valid_set_1[i] = 1'b0;
      tag_set_0[i] = 10'b0;
      tag_set_1[i] = 10'b0;
      lru[i] = 1'b0;
    end
  end
  
  
  // computing the hit bit for each set
  wire set_1_hit_result, set_2_hit_result;
  assign set_1_hit_result = (tag_set_0[index] == tag) && valid_set_0[index];
  assign set_2_hit_result = (tag_set_1[index] == tag) && valid_set_1[index];
  
  assign hit = set_1_hit_result || set_2_hit_result;
  
  // finding the acquired value from two sets
  // Read
  Mux #(.WIDTH(32)) data_mux(
    .first(data_set_0[offset][index]), 
    .second(data_set_1[offset][index]),
    .select(~set_1_hit_result),
    .out(read_data) 
  );
  
  // modifying the lru bit upon reading a set
  always @(*) begin
    if (read_en && hit)
      lru[index] = set_1_hit_result ? 1'b0: 1'b1; // 0 for the first set and 1 for the second set
    else
      lru[index] = lru[index];
  end
  
  // Invalidation
  always @(*) begin
    if (invoke_set_en && hit) begin
      if (set_1_hit_result == 1'b1) begin
        valid_set_0[index] = 1'b0;
        lru[index] = 1'b1;
      end
      else if(set_2_hit_result == 1'b1) begin
        valid_set_1[index] = 1'b0;
        lru[index] = 1'b0;
      end
    end
  end
  
  // Write
  always @(posedge clk) begin
    if (write_en) begin
      if (lru[index] == 1'b0) begin
        $display("CACHE WRITE mem[%d] = %d, %d", index, write_data[63:32], write_data[31:0]);
        data_set_1[1][index] <= write_data[63:32];
        data_set_1[0][index] <= write_data[31:0];
        tag_set_1[index] <= tag;
        valid_set_1[index] <= 1'b1;
        //lru[index] = 1'b1;
      end
      else if (lru[index] == 1'b1) begin
        $display("CACHE WRITE mem[%d] = %d, %d", index, write_data[63:32], write_data[31:0]);
        data_set_0[1][index] <= write_data[63:32];
        data_set_0[0][index] <= write_data[31:0];
        tag_set_0[index] <= tag;
        valid_set_0[index] <= 1'b1;
        //lru[index] = 1'b0;
      end
    end
  end
  
  
  
endmodule
