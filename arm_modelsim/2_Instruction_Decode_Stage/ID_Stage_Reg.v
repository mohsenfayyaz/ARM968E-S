`include "configs.v"

module ID_Stage_Regs 
(
    output S_out, B_out, MEM_W_EN_out, MEM_R_EN_out, WB_EN_out, immediate_out,
    output [`ADDRESS_LEN - 1 : 0] val_Rn_out, val_Rm_out, pc_out,
    output [23 : 0] signed_extend_immediate_out,
    output [3 : 0] output_dst_out, EXE_CMD_out,
    output [11 : 0] shift_operand_out,
    input S, B, MEM_W_EN, MEM_R_EN, WB_EN, immediate,
    input [`ADDRESS_LEN - 1 : 0] val_Rn, val_Rm, pc,
    input [23 : 0] signed_extend_immediate,
    input [3 : 0] output_dst,EXE_CMD,
    input [11 : 0] shift_operand,
    input clk,flush,pop,push,
    input rst
);

wire [`ADDRESS_LEN - 1 : 0] pc_mux_out,val_Rn_mux_out,val_Rm_mux_out;
wire [23 : 0] signed_immediate_mux_out;
wire [11 : 0] shift_operand_mux_out;
wire [3 : 0] output_dst_mux_out,EXE_CMD_mux_out;
wire imm_mux_out,s_mux_out,b_mux_out,MEM_W_EN_mux_out,MEM_R_EN_mux_out,WB_EN_mux_out;

Mux # (`ADDRESS_LEN) pc_mux (.first(pc),.second(32'b0),.select(flush),.out(pc_mux_out));
Mux # (`ADDRESS_LEN) val_Rn_mux (.first(val_Rn),.second(32'b0),.select(flush),.out(val_Rn_mux_out));
Mux # (`ADDRESS_LEN) val_Rm_mux (.first(val_Rm),.second(32'b0),.select(flush),.out(val_Rm_mux_out));
Mux # (24) imm24_mux (.first(signed_extend_immediate),.second(24'b0),.select(flush),.out(signed_immediate_mux_out));
Mux # (4) dst_mux (.first(output_dst),.second(4'b0),.select(flush),.out(output_dst_mux_out));
Mux # (12) shift_operand_mux (.first(shift_operand),.second(12'b0),.select(flush),.out(shift_operand_mux_out));
Mux # (1) imm_mux (.first(immediate),.second(1'b0),.select(flush),.out(imm_mux_out));
Mux # (1) s_mux (.first(S),.second(1'b0),.select(flush),.out(s_mux_out));
Mux # (1) b_mux (.first(B),.second(1'b0),.select(flush),.out(b_mux_out));
Mux # (4) exe_cmd_mux (.first(EXE_CMD),.second(4'b0),.select(flush),.out(EXE_CMD_mux_out));
Mux # (1) mem_w_mux (.first(MEM_W_EN),.second(1'b0),.select(flush),.out(MEM_W_EN_mux_out));
Mux # (1) mem_r_mux (.first(MEM_R_EN),.second(1'b0),.select(flush),.out(MEM_R_EN_mux_out));
Mux # (1) wb_mux (.first(WB_EN),.second(1'b0),.select(flush),.out(WB_EN_mux_out));

R_Register # (`ADDRESS_LEN) pc_register (.q(pc_out), .d(pc_mux_out), .clk(clk), .rst(rst));
R_Register # (`ADDRESS_LEN) val_Rn_register (.q(val_Rn_out), .d(val_Rn_mux_out), .clk(clk), .rst(rst));
R_Register # (`ADDRESS_LEN) val_Rm_register (.q(val_Rm_out), .d(val_Rm_mux_out), .clk(clk), .rst(rst));
R_Register # (24) imm24_register (.q(signed_extend_immediate_out), .d(signed_immediate_mux_out), .clk(clk), .rst(rst));
R_Register # (4) output_dst_register (.q(output_dst_out), .d(output_dst_mux_out), .clk(clk), .rst(rst));
R_Register # (12) shift_operand_register (.q(shift_operand_out), .d(shift_operand_mux_out), .clk(clk), .rst(rst));
R_Register # (1) imm_register (.q(immediate_out), .d(imm_mux_out), .clk(clk), .rst(rst));
R_Register # (1) S_register (.q(S_out), .d(s_mux_out), .clk(clk), .rst(rst));
R_Register # (1) B_register (.q(B_out), .d(b_mux_out), .clk(clk), .rst(rst));
R_Register # (4) EXE_CMD_register (.q(EXE_CMD_out), .d(EXE_CMD_mux_out), .clk(clk), .rst(rst));
R_Register # (1) MEM_W_EN_register (.q(MEM_W_EN_out), .d(MEM_W_EN_mux_out), .clk(clk), .rst(rst));
R_Register # (1) MEM_R_EN_register (.q(MEM_R_EN_out), .d(MEM_R_EN_mux_out), .clk(clk), .rst(rst));
R_Register # (1) WB_EN_register (.q(WB_EN_out), .d(WB_EN_mux_out), .clk(clk), .rst(rst));

endmodule