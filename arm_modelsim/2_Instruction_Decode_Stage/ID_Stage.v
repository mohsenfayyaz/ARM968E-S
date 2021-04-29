`include "configs.v"

module ID_Stage(
  input [`ADDRESS_LEN - 1 : 0] pc, instruction, wb_value,
  input clk, rst, hazard, regfile_wb_en,
  input z, c, v, n,
  input [`REG_COUNT - 1 : 0] regFile_dst, EXE_CMD,
  output S, B, MEM_W_EN, MEM_R_EN, WB_EN, immediate,
  output two_src,
  output [`ADDRESS_LEN - 1 : 0] val_Rn, val_Rm,
  output [23 : 0] signed_immediate,
  output [3 : 0] output_dst, output_src1, output_src2,
  output [11 : 0] shift_operand
);


wire[1:0] mode;
wire[3:0] opcode, exe_cmd, cond, Rn, Rm, Rd, reg_src2;
wire status, mem_read, mem_write, wb_en, branch, status_update, cond_check, controller_mux_select, push, pop;

assign output_src1 = Rn;
assign output_src2 = reg_src2;
assign mode = instruction[27:26];
assign opcode = instruction[24:21];
assign status = instruction[20];
assign cond = instruction[31:28];
assign Rn = push ? 4'b1101 : instruction[19:16];
assign Rd = push ? 4'b1101 : instruction[15:12];
assign Rm = push ? instruction[19:16] : instruction[3:0];
assign immediate = instruction[25];
assign two_src = ~immediate | mem_write;
assign controller_mux_select = ~cond_check | hazard;
assign output_dst = Rd;
assign shift_operand = push ? (12'b111111111100) : instruction[11:0];
assign signed_immediate = instruction[23 : 0];


Mux #(.WIDTH(9)) src1_mux
(
    .first({status_update, branch, exe_cmd, mem_write, mem_read, wb_en}),
    .second(9'b0),
    .select(controller_mux_select),
    .out({S,B,EXE_CMD,MEM_W_EN,MEM_R_EN,WB_EN})
);

Controller controller
(
    .mode(mode),
    .opcode(opcode),
    .status(status),
    .exe_cmd(exe_cmd),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .push(push),
    .pop(pop),
    .wb_en(wb_en),
    .branch(branch),
    .status_update(status_update)
);

ConditionCheck conditionCheck
(
    .cond(cond),
    .z(z),
    .c(c),
    .v(v),
    .n(n), 
    .check(cond_check)
);

Mux #(.WIDTH(4)) src2_mux
(
    .first(Rm),
    .second(Rd),
    .select(mem_write),
    .out(reg_src2)
);

RegisterFile regFile
(
    .clk(clk),
    .rst(rst),
    .src1(Rn),
    .src2(reg_src2),
    .dst_wb(regFile_dst),
    .result_wb(wb_value),
    .writeback_enable(regfile_wb_en),
    .reg1(val_Rn),
    .reg2(val_Rm)
);
  
endmodule