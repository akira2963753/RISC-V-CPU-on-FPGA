`include "SYSTEM_DEF.vh"

module IF_ID(
    input clk,
    input rst_n,
    input IF_ID_w,
    input IF_ID_Flush,
    input [`PC_WIDTH - 1:0] IF_PC,
    input [`INSTR_WIDTH - 1:0] IF_Instr,
    output reg [`PC_WIDTH - 1:0] ID_PC,
    output reg [`INSTR_WIDTH - 1:0] ID_Instr
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ID_PC <= 0;
            ID_Instr <= `NOP;
        end
        else begin
            if (IF_ID_w) begin
                ID_PC <= (IF_ID_Flush)? 0 : IF_PC;
                ID_Instr <= (IF_ID_Flush)? `NOP : IF_Instr;
            end
            else begin
                ID_PC <= ID_PC;
                ID_Instr <= ID_Instr;
            end
        end
    end

endmodule