`include "SYSTEM_DEF.vh"

module Control(
    input [`OPCODE_WIDTH - 1:0] Opcode,
    input Branch_Taken,
    input ID_EX_Jump,
    output reg [2:0] Imm_Type,
    output reg [1:0] ALU_op,
    output reg [1:0] WB_sel,
    output reg Reg_w,
    output reg ALU_src1,
    output reg ALU_src2,
    output reg Mem_w,
    output reg Mem_r,
    output reg Branch,
    output reg Jump,
    // Flush signals
    output IF_ID_Flush,
    output ID_EX_Flush_1
);

    assign IF_ID_Flush = Branch_Taken || ID_EX_Jump;
    assign ID_EX_Flush_1 = Branch_Taken || ID_EX_Jump;
    
    always @(*) begin
        case(Opcode)
        `R_TYPE : begin
            Imm_Type = 0;
            ALU_op = `ALU_OP_R_TYPE;
            Reg_w = 1;
            ALU_src1 = 0;
            ALU_src2 = 0;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd0;
        end
        `I_TYPE_ALU : begin
            Imm_Type = `I_TYPE_IMM;
            ALU_op = `ALU_OP_I_TYPE;
            Reg_w = 1;
            ALU_src1 = 0;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd0;
        end
        `I_TYPE_LOAD : begin
            Imm_Type = `I_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 1;
            ALU_src1 = 0;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 1;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd2;
        end
        `I_TYPE_JALR : begin
            Imm_Type = `I_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 1;
            ALU_src1 = 1;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 1;
            WB_sel = 2'd1;
        end
        `S_TYPE : begin
            Imm_Type = `S_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 0;
            ALU_src1 = 0;
            ALU_src2 = 1;
            Mem_w = 1;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd0;
        end
        `B_TYPE : begin
            Imm_Type = `B_TYPE_IMM;
            ALU_op = `ALU_OP_BRANCH;
            Reg_w = 0;
            ALU_src1 = 0;
            ALU_src2 = 0;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 1;
            Jump = 0;
            WB_sel = 2'd0;
        end
        `U_TYPE_LUI : begin
            Imm_Type = `U_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 1;
            ALU_src1 = 0;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd3;         
        end 
        `U_TYPE_AUIPC : begin
            Imm_Type = `U_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 1;
            ALU_src1 = 1;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd1;        
        end
        `J_TYPE_JAL : begin
            Imm_Type = `J_TYPE_IMM;
            ALU_op = `ALU_OP_ADD;
            Reg_w = 1;
            ALU_src1 = 1;
            ALU_src2 = 1;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 1;
            WB_sel = 2'd1;  
        end
        default: begin
            Imm_Type = 0;
            ALU_op = 0;
            Reg_w = 0;
            ALU_src1 = 0;
            ALU_src2 = 0;
            Mem_w = 0;
            Mem_r = 0;
            Branch = 0;
            Jump = 0;
            WB_sel = 2'd0;
        end
        endcase
    end
endmodule