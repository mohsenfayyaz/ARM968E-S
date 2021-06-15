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
  
  //output [`ADDRESS_LEN - 1:0] Val_Rn, Val_Rm,
  // EXAM
  output [`ADDRESS_LEN - 1:0] Val_Rn, Val_Rm_After_ADD32,
  
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
  
  //assign output_src2 = reg_src2;
  
  
  assign cond = instruction[31:28];
  assign mode = instruction[27:26];
  //assign imm = instruction[25];
  assign opcode = instruction[24:21];
  assign status = instruction[20];
  //assign Rn = instruction[19:16];
  assign Rd = instruction[15:12];
  assign Rm = instruction[3:0];
  
  assign Two_src = ~imm | mem_write;
  
  // EXAM ------------------
  wire cycle_counter;
  wire [1:0] exam_mode;
  wire [1:0] ADD32_STATE;
  
  assign control_unit_mux_select = ~cond_check | Hazard | ADD32_STATE == 2'b01;
  assign imm = (ADD32_STATE == 2'b10) ? 1'b0 : instruction[25];
  assign Shift_operand = (ADD32_STATE == 2'b10) ? 12'b0 : instruction[11:0];
  assign Signed_imm_24 = (ADD32_STATE == 2'b10) ? 24'b0 : instruction[23:0];
  assign output_src2 = (ADD32_STATE == 2'b10) ? 4'b0111 : reg_src2;
  //assign Dest = Rd;

  /*
  assign Dest = (exam_mode == `EXAM_MODE_NONE) ? Rd : 
                (exam_mode == `EXAM_MODE_MUL_DIV && cycle_counter == 1'b1) ? Rd + 1 :
                (exam_mode == `EXAM_MODE_PUSH && cycle_counter == 1'b0) ? 4'b1101 :
                (exam_mode == `EXAM_MODE_POP && cycle_counter == 1'b1) ? 4'b1101 :
                Rd;
  */
  reg [3:0] ADD32_Rn, ADD32_Rd;
  
  assign Dest = (ADD32_STATE == 2'b10) ? ADD32_Rd : Rd;
  assign Rn = (ADD32_STATE == 2'b10) ? ADD32_Rn : instruction[19:16];
  wire [`ADDRESS_LEN - 1:0] Val_Rm;
  assign Val_Rm_After_ADD32 = (ADD32_STATE == 2'b10) ? instruction[31:0] : Val_Rm;
  
  
  always @(posedge clk) begin
    if (ADD32_STATE == 2'b01) begin
      ADD32_Rn <= Rn;
      ADD32_Rd <= Rd;
    end  
  end
  
  // END EXAM ----------
  
  //assign Shift_operand = instruction[11:0];
  //assign Signed_imm_24 = instruction[23:0];
  
  assign BEFORE_MUX_EXE_CMD = exe_cmd;
  
  wire wb_en_before_add32, MEM_W_EN_before_add32, MEM_R_EN_before_add32, B_before_add32;
  wire [3:0] EXE_CMD_BERFORE_ADD32;
  assign EXE_CMD = (ADD32_STATE == 2'b10) ? 4'b0010 : EXE_CMD_BERFORE_ADD32;
  assign WB_EN = (ADD32_STATE == 2'b10) ? 1'b1 : wb_en_before_add32;
  assign MEM_W_EN = (ADD32_STATE == 1'b10) ? 1'b0 : MEM_W_EN_before_add32;
  assign MEM_R_EN = (ADD32_STATE == 1'b10) ? 1'b0 : MEM_R_EN_before_add32;
  assign B = (ADD32_STATE == 1'b10) ? 1'b0 : B_before_add32;
  Mux #(.WIDTH(9)) src1_mux
  (
    .first({status_update, branch, exe_cmd, mem_write,  mem_read, wb_en}),
    .second(9'b0),
    .select(control_unit_mux_select),
    .out({S, B_before_add32, EXE_CMD_BERFORE_ADD32, MEM_W_EN_before_add32, MEM_R_EN_before_add32, wb_en_before_add32})
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
    .cycle_counter(cycle_counter),
    .exam_mode(exam_mode),
    .ADD32_STATE(ADD32_STATE)
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
