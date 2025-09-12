`include "SYSTEM_DEF.vh"

module PC_Adder(
    input IF_ID_w,
    input [`PC_WIDTH - 1:0] PC_In,
    input busy,
    output reg [`PC_WIDTH - 1:0] PC_Out
);

    always @(*) begin
        if(busy) PC_Out = PC_In;
        else if (IF_ID_w) PC_Out = PC_In + 4;
        else PC_Out = PC_In;
    end

endmodule