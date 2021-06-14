`include "configs.v"

module ID_Stage(
  input clk, rst,
  input[`ADDRESS_LEN - 1:0] pc_in,
  output[`ADDRESS_LEN - 1:0] pc,
  
  // Green
  input [`ADDRESS_LEN - 1:0] instruction,
  // Yellow
  input Hazard, 
  // From Status Reg Color
  input z, c, v, n,
  // Blue Wires
  input WB_WB_EN,
  input [3:0] WB_Dest,
  input [`ADDRESS_LEN - 1:0] WB_Value,
  
  
  // Green
  output S, B, MEM_W_EN, MEM_R_EN, WB_EN,
  output [3:0] EXE_CMD, BEFORE_MUX_EXE_CMD,
  
  output [`ADDRESS_LEN - 1:0] Val_Rn, Val_Rm,
  output imm,
  output [23:0] Signed_imm_24,
  output [3:0] Dest, 
  output [11:0] Shift_operand,
  // Yellow
  output Two_src,
  output [3:0] output_src1 /*Rn For Hazard*/, output_src2 /*Rm or Rd (When Mem_W)*/,
  
  // EXAM
  output cycle_freeze
);
  
  wire[1:0] mode;
  wire[3:0] opcode, exe_cmd, cond, Rn, Rm, Rd, reg_src2;
  wire status, mem_read, mem_write, wb_en, branch, status_update, cond_check, control_unit_mux_select;
  
  assign pc = pc_in;
  assign output_src1 = Rn;
  assign output_src2 = reg_src2;
  assign cond = instruction[31:28];
  assign mode = instruction[27:26];
  assign imm = instruction[25];
  assign opcode = instruction[24:21];
  assign status = instruction[20];
  assign Rn = instruction[19:16];
  assign Rd = instruction[15:12];
  assign Rm = instruction[3:0];
  
  assign Two_src = ~imm | mem_write;
  assign control_unit_mux_select = ~cond_check | Hazard;
  
  //assign Dest = Rd;
  // EXAM
  wire cycle_counter;
  assign Dest = (cycle_counter == 1'b1) ? Rd + 1 : Rd;
  
  assign Shift_operand = instruction[11:0];
  assign Signed_imm_24 = instruction[23:0];
  
  assign BEFORE_MUX_EXE_CMD = exe_cmd;

  Mux #(.WIDTH(9)) src1_mux
  (
    .first({status_update, branch, exe_cmd, mem_write,  mem_read, wb_en}),
    .second(9'b0),
    .select(control_unit_mux_select),
    .out({S, B, EXE_CMD, MEM_W_EN, MEM_R_EN, WB_EN})
  );

  Control_Unit control_unit
  (
    .mode(mode),
    .opcode(opcode),
    .status(status),
    .exe_cmd(exe_cmd),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .wb_en(wb_en),
    .branch(branch),
    .status_update(status_update),
    
    // EXAM
    .clk(clk),
    .rst(rst),
    .hazard(Hazard),
    .cycle_freeze(cycle_freeze),
    .cycle_counter(cycle_counter)
  );

  Condition_Check condition_check
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

  Register_File register_file
  (
    .clk(clk),
    .rst(rst),
    .src1(Rn),
    .src2(reg_src2),
    .dest_wb(WB_Dest),
    .result_wb(WB_Value),
    .wb_en(WB_WB_EN),
    .reg1(Val_Rn),
    .reg2(Val_Rm)
  );
  
endmodule
