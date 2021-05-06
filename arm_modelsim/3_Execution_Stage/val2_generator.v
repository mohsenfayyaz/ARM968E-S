`include "configs.v"

module Val2_Generator(
  input [31:0] Val_Rm,
  input [11:0] Shift_operand,
  input imm, is_mem,
  output [31:0] Val2
);
  
  // 32-bit immediate
  wire [3:0] rotate_imm;
  wire [7:0] immed_8;
  assign immed_8 = Shift_operand[7:0];
  assign rotate_imm = Shift_operand[11:8];
  reg [31:0] immed_8_rotated;  // Rotate Right Twice the rotate_imm
  // Immediate shifts
  wire [4:0] shift_imm;
  wire [1:0] shift_type; 
  assign shift = Shift_operand[6:5];
  assign shift_imm = Shift_operand[11:7];
  reg [31:0] Val_Rm_rotate_right;  // Rotate Right as shift_imm when shift==11
  
  // Immediate shifts ROR
  integer i;
  always @(*) begin
      Val_Rm_rotate_right = Val_Rm;
      for(i = 0; i < {1'b0, shift_imm}; i = i + 1) begin
          Val_Rm_rotate_right = {Val_Rm_rotate_right[0], Val_Rm_rotate_right[31:1]}; // ROR Rotate right
      end
  end
  
  // 32-bit immediate
  integer j;
  always @(*) begin
      immed_8_rotated = {24'b0, immed_8};
      for (j = 0; j < {1'b0, rotate_imm}; j = j + 1) begin
          immed_8_rotated = {immed_8_rotated[1], immed_8_rotated[0], immed_8_rotated[31:2]};  // Rotate Right Twice the rotate_imm
      end
  end

  assign Val2 = is_mem ? {20'b0, Shift_operand} :
          (
            imm ? ((rotate_imm == 4'b0) ? {24'b0, immed_8} : immed_8_rotated) :
            // Page 8 -> Chart 4
            (shift == 2'b00) ? Val_Rm << {1'b0, shift_imm} :  // LSL Logical shift left
            (shift == 2'b01) ? Val_Rm >> {1'b0, shift_imm} :  // LSR Logical shift right
            (shift == 2'b10) ? Val_Rm >>> {1'b0, shift_imm} :  // ASR Arithmetic shift right (The empty position in the most significant bit is filled with a copy of the original MSB.)
            (shift == 2'b11) ? Val_Rm_rotate_right :  // ROR Rotate right
            Val_Rm
          );

endmodule