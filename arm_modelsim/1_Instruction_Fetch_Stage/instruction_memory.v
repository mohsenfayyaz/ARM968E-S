`include "configs.v"

module Instruction_Memory(output reg [`WORD_LEN - 1 : 0 ] instruction, input [`ADDRESS_LEN - 1 : 0 ] address);
  reg [`WORD_LEN-1:0] regs[0:`MEMORY_SIZE-1];
  
  initial begin
    //regs[0] = 32'b00001000000000000000000001100100;// jmp 100
    regs[0] = 32'b000000_00001_00010_00000_00000000000;// nop;
    regs[1] = 32'b000000_00011_00100_00000_00000000000;// nop;
    regs[2] = 32'b000000_00101_00110_00000_00000000000;// nop;
    regs[3] = 32'b000000_00111_01000_00010_00000000000;// nop;
    regs[4] = 32'b000000_01001_01010_00011_00000000000;// nop;
    regs[5] = 32'b000000_01011_01100_00000_00000000000;// nop;
    regs[6] = 32'b000000_01101_01110_00000_00000000000;// nop;
    regs[7] = 32'b00000000000000000000000000000000;// nop;
    regs[8] = 32'b00000000000000000000000000000000;// nop;
    regs[9] = 32'b00000000000000000000000000000000;// nop;
  end

  always @(address) begin
    instruction = regs[address];
    //if(address < 40)
      //$display("CLK%d:--%b--", address, regs[address]);
  end

endmodule