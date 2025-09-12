`include "SYSTEM_DEF.vh"

module BTB(
    input clk,
    input rst_n,
    input [`BTB_PC_WIDTH - 1:0] PC,
    input Prediction,
    output [`PC_WIDTH - 1:0] BTB_PC,
    output Valid_bit,

    input [`BTB_PC_WIDTH - 1:0] EX_PC,
    input [`PC_WIDTH - 1:0] Branch_PC,
    input Branch_Taken
);
    integer i;
    // Branch Target Buffer (BTB)
    reg [`PC_WIDTH - 1:0] BTB [0:`BTB_SIZE-1];
    reg Valid [0:`BTB_SIZE-1];

    assign BTB_PC = BTB[PC];
    assign Valid_bit = Valid[PC];

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < `BTB_SIZE; i = i + 1) begin
                BTB[i] <= 0;
                Valid[i] <= 0;
            end
        end
        else begin
            if(Branch_Taken) begin
                BTB[EX_PC] <= Branch_PC;
                Valid[EX_PC] <= 1;
            end
            else;
        end
    end
endmodule