module Controller 
(
    input [1 : 0] mode,
    input [3 : 0] opcode,
    input status,
    output reg push,
    output reg pop,
    output reg [3 : 0] exe_cmd,
    output reg mem_read, mem_write, wb_en, branch, 
    output status_update
);

always @(*) begin
    {exe_cmd,mem_read, mem_write, wb_en, branch, push, pop} = 0;
    case (mode)
        2'b0: begin
                case (opcode)
                    6'b1101: begin //MOV
                        exe_cmd = 4'b0001;
                        // $display("here %t",$time());
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b1111: begin //MVN
                        exe_cmd = 4'b1001;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0100: begin //ADD
                        exe_cmd = 4'b0010;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0101: begin //ADC
                        exe_cmd = 4'b0011;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0010: begin //SUB
                        exe_cmd = 4'b0100;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0110: begin //SBC
                        exe_cmd = 4'b0101;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0000: begin //AND
                        exe_cmd = 4'b0110;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b1100: begin //ORR
                        exe_cmd = 4'b0111;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b0001: begin //EOR
                        exe_cmd = 4'b1000;
                        {mem_read, mem_write, wb_en, branch} = 4'b0010;
                    end
                    6'b1010: begin //CMP
                        exe_cmd = 4'b0100;
                        {mem_read, mem_write, wb_en, branch} = 4'b0000;
                    end
                    6'b1000: begin //TST
                        exe_cmd = 4'b0110;
                        {mem_read, mem_write, wb_en, branch} = 4'b0000;
                    end
                    default: begin
                        exe_cmd = 4'b0;
                        {mem_read, mem_write, wb_en, branch} = 4'b0;
                    end
                endcase
        end
        2'b01: begin
            if (opcode == 4'b1111) begin
                if (status == 1'b1) begin //pop
                    {mem_read, mem_write, wb_en, branch} = 4'b1010;
                    pop = 1'b1;
                end
                else begin // push
                    exe_cmd = 4'b0010;
                    {mem_read, mem_write, wb_en, branch} = 4'b0110;
                    push = 1'b1;
                end
            end
            else begin
                exe_cmd = 4'b0010;
                if (status) begin //LDR
                    {mem_read, mem_write, wb_en, branch} = 4'b1010;
                end else begin //STR
                    {mem_read, mem_write, wb_en, branch} = 4'b0100;      
                end 
            end
        end
        2'b10: begin
            exe_cmd = 4'b0;
            {mem_read, mem_write, wb_en, branch} = 4'b0001;
        end
        default: begin
            exe_cmd = 4'b0;
            {mem_read, mem_write, wb_en, branch} = 4'b0;
        end
    endcase
end

    assign status_update = (mode == 2'b0) ? (
                                (opcode == 4'b0) ? 1'b0 :    //NOP
                                (opcode == 4'b1010) ? 1'b1 : //CMP
                                (opcode == 4'b1000) ? 1'b1 : //TST
                                status //OTHERS
                            ) : status; //LDR, STR, BR
endmodule