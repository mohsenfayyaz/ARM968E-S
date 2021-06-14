module Control_Unit
(
    input [1:0] mode,
    input [3:0] opcode,
    input status,  //s 
    output reg [3 : 0] exe_cmd,
    output reg mem_read, mem_write, wb_en, branch,  // B
    output status_update,  // S
    
    // EXAM
    input clk, rst, hazard,
    output reg cycle_freeze,
    output cycle_counter
);
  
  wire p_cycle;
  assign cycle_counter = p_cycle;
  reg n_cycle;
  Regular_Register #(.SIZE(1)) cycle_reg(.q(p_cycle), .d(n_cycle), .clk(clk), .rst(rst));
  
  always @(*) begin
    {exe_cmd, mem_read, mem_write, wb_en, branch, n_cycle, cycle_freeze} = 0;
    case(mode)
      
        2'b00: begin  // Arithmetic
                case (opcode)
                    4'b1101: begin //MOV
                        exe_cmd = 4'b0001;
                        wb_en = 1'b1;
                    end
                    4'b1111: begin //MVN
                        exe_cmd = 4'b1001;
                        wb_en = 1'b1;
                    end
                    4'b0100: begin //ADD
                        exe_cmd = 4'b0010;
                        wb_en = 1'b1;
                    end
                    4'b0101: begin //ADC
                        exe_cmd = 4'b0011;
                        wb_en = 1'b1;
                    end
                    4'b0010: begin //SUB
                        exe_cmd = 4'b0100;
                        wb_en = 1'b1;
                    end
                    4'b0110: begin //SBC
                        exe_cmd = 4'b0101;
                        wb_en = 1'b1;
                    end
                    4'b0000: begin //AND
                        exe_cmd = 4'b0110;
                        wb_en = 1'b1;
                    end
                    4'b1100: begin //ORR
                        exe_cmd = 4'b0111;
                        wb_en = 1'b1;
                    end
                    4'b0001: begin //EOR
                        exe_cmd = 4'b1000;
                        wb_en = 1'b1;
                    end
                    4'b1010: begin //CMP
                        exe_cmd = 4'b0100;
                    end
                    4'b1000: begin //TST
                        exe_cmd = 4'b0110;
                    end
                    // MUL -------------- NEW
                    4'b0011: begin  // MUL1
                      if(p_cycle == 1'b0) begin
                        exe_cmd = 4'b1100;
                        if(~hazard) begin
                          $display("Mohsen HI");
                          n_cycle = 1'b1;
                          cycle_freeze = 1'b1;
                          wb_en = 1'b1;
                        end
                      end
                      else if(p_cycle == 1'b1) begin  // MUL2
                        exe_cmd = 4'b1101;
                        n_cycle = 1'b0;
                        cycle_freeze = 1'b0;
                        wb_en = 1'b1;
                      end
                    end
                    default: begin
                        exe_cmd = 4'b0000;
                    end
                endcase
        end
        
        2'b01: begin  // Load or Store
            exe_cmd = 4'b0010;
            if (status) begin //LDR
                {mem_read, wb_en} = 2'b11;
            end else begin //STR
                mem_write = 1'b1;      
            end
        end
        
        2'b10: begin  // Branch
            exe_cmd = 4'b0;
            branch = 1'b1;
        end
        
        default: begin
            exe_cmd = 4'b0000;
            {mem_read, mem_write, wb_en, branch} = 4'b0;
        end
        
    endcase
  end

    assign status_update = (mode == 2'b00) ? (
                                (opcode == 4'b0000) ? 1'b0 : //NOP
                                (opcode == 4'b1010) ? 1'b1 : //CMP
                                (opcode == 4'b1000) ? 1'b1 : //TST
                                status //Others
                            ) : status; //LDR, STR, BR


endmodule