`include "SYSTEM_DEF.vh"

module BHT (
    input clk,
    input rst_n,
    input [`BHT_PC_WIDTH - 1:0] PC,
    input Branch_Taken,
    input [`BHT_PC_WIDTH - 1:0] EX_PC,
    output Prediction
);
    reg [1:0] state [0:`BHT_SIZE-1];
    integer i;

    assign Prediction = state[PC];

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < `BHT_SIZE; i = i + 1) state[i] <= 2'b00;
        end
        else begin
            // Update the BHT
            if(Branch_Taken) state[EX_PC] <= (state[EX_PC] == 2'b11)? 2'b11 : state[EX_PC] + 1;
            else state[EX_PC] <= (state[EX_PC] == 2'b00)? 2'b00 : state[EX_PC] - 1;
        end
    end

endmodule
