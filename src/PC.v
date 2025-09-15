`include "SYSTEM_DEF.vh"

module PC(
    input clk,
    input rst_n,
    input PC_sel,
    input [`DATA_WIDTH-1:0] EX_ALU_Result,
    input [`DATA_WIDTH-1:0] PC_Plus_4,
    output reg [`PC_WIDTH-1:0] IF_PC
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) IF_PC <= 0;
        else IF_PC <= (PC_sel)? EX_ALU_Result : PC_Plus_4;
    end

endmodule