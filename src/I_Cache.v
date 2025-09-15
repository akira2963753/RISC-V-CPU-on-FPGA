`include "SYSTEM_DEF.vh"

module I_Cache(
    input clk,
    input rst_n,
    
    // CPU Fetch
    input cpu_req,
    input [`INSTR_ADDR_WIDTH - 1 : 0] cpu_req_addr,
    output cpu_req_ready,
    output [`DATA_WIDTH - 1 : 0] cpu_req_data,

    // Control 
    input flush,
    output busy,

    // AXI Read Master Output (Slave Input)
    output reg arvalid,
    output reg rready,
    output reg [`INSTR_ADDR_WIDTH - 1 : 0] araddr,
    output [7:0] arlen,
    output [2:0] arsize,
    output [1:0] arburst,

    // AXI Read Master Input (Slave Output)
    input arready,
    input rvalid,
    input rlast,
    input [`DATA_WIDTH - 1 : 0] rdata
);
    integer i,j;
     
    // AXI Read Address Channel 
    assign arlen = 7'd7; // Read 8 Cycle
    assign arsize = 3'b010; // 4 Bytes
    assign arburst = 2'b01; // INCR

    // Instruction Address : Tag | Index | Word_Offset | 00
    wire [`TAG_WIDTH - 1 :0] tag;
    wire [`INDEX_WIDTH - 1 :0] index;
    wire [`OFFSET_WIDTH - 1 :0] offset;
    wire [`WORD_OFFSET_WIDTH - 1 :0] word_offset;

    assign tag = cpu_req_addr[`INSTR_ADDR_WIDTH - 1 : `INSTR_ADDR_WIDTH - `TAG_WIDTH];
    assign index = cpu_req_addr[`INSTR_ADDR_WIDTH - `TAG_WIDTH - 1 : `INSTR_ADDR_WIDTH - `TAG_WIDTH - `INDEX_WIDTH];
    assign offset = cpu_req_addr[`OFFSET_WIDTH - 1 : 0];
    assign word_offset = cpu_req_addr[`OFFSET_WIDTH - 1 : `OFFSET_WIDTH - `WORD_OFFSET_WIDTH];

    // Cache 
    reg [`TAG_WIDTH - 1 :0] tag_array [0:`WAY-1][0:`SET_NUM-1];
    reg [`DATA_WIDTH - 1 :0] data_array [0:`WAY-1][0:`SET_NUM-1][0:`BLOCK_WORD_SIZE-1];
    reg valid_array [0:`WAY-1][0:`SET_NUM-1];
    reg LRU [0:`SET_NUM-1];

    // Cache Hit Net
    wire cache_hit, hit_way, hit0, hit1;
    wire empty;
    reg [2:0] refill_cnt;

    // victim
    reg victim_way;
    reg [`INDEX_WIDTH - 1 :0] miss_index;
    reg [`TAG_WIDTH - 1 :0] miss_tag;
    reg [`WORD_OFFSET_WIDTH - 1 :0] miss_word_offset;
    reg resp_way;
    reg [`INDEX_WIDTH - 1 :0] resp_index;
    reg [`WORD_OFFSET_WIDTH - 1 :0] resp_word_offset;

    assign hit0 = valid_array[0][index] && (tag_array[0][index] == tag);
    assign hit1 = valid_array[1][index] && (tag_array[1][index] == tag);

    assign cache_hit = hit0 | hit1;
    assign hit_way = hit1;
    assign empty = !valid_array[0][index] | !valid_array[1][index];

    assign cpu_req_data = (state==READ)? data_array[resp_way][resp_index][resp_word_offset] : `NOP;
    assign cpu_req_ready = (state==READ);
    //assign busy = (!(state==IDLE)&&(state!=READ));
    assign busy = (state!=READ);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < `SET_NUM; i = i + 1) begin
                LRU[i] <= 0;
                for(j = 0; j < `WAY; j = j + 1) begin
                    valid_array[j][i] <= 0;
                    tag_array[j][i] <= 0;
                end
            end
            refill_cnt <= 0;
            arvalid <= 0;
            rready <= 0;
            araddr <= 0;
            victim_way <= 0;
            miss_index <= 0;
            miss_tag <= 0;
            resp_index <= 0;
            resp_word_offset <= 0;
            refill_cnt <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    // Close AXI
                    arvalid <= 0;
                    rready <= 0;
                end
                CMP : begin
                    if(cache_hit) begin  // Hit
                        resp_way <= hit_way;
                        resp_index <= index;
                        resp_word_offset <= word_offset;
                        LRU[index] <= ~hit_way;
                    end
                    else begin  // Miss
                        // Choose Victim
                        if(empty) victim_way <= !valid_array[0][index];
                        else victim_way <= LRU[index];

                        // Fix Miss
                        miss_index <= index;
                        miss_tag <= tag;
                        miss_word_offset <= word_offset;

                        // align araddr to block
                        araddr <= {cpu_req_addr[`INSTR_ADDR_WIDTH-1:`OFFSET_WIDTH],{`OFFSET_WIDTH{1'b0}} };
                        rready <= 0;
                        refill_cnt <= 0;
                        arvalid <= 1;
                    end
                end
                MREQ : begin
                    if(arready) begin
                        arvalid <= 0;
                        rready <= 1;
                    end
                end
                REFILL : begin
                    if(rvalid) begin
                        data_array[victim_way][miss_index][refill_cnt] <= rdata;
                        refill_cnt <= refill_cnt + 1;

                        if(rlast) begin // last
                            // update cache
                            valid_array[victim_way][miss_index] <= 1;
                            tag_array[victim_way][miss_index] <= miss_tag;
                            LRU[miss_index] <= ~victim_way;

                            // Update response
                            resp_way <= victim_way;
                            resp_index <= miss_index;
                            resp_word_offset <= miss_word_offset;

                            // Clear ready signal
                            rready <= 0;
                        end
                        else;
                    end
                    else;
                end
            endcase 
        end
    end

    // Flush
    reg Flush_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) Flush_reg <= 1'b0;
        else Flush_reg <= flush;
    end

    // FSM
    localparam [2:0] IDLE = 3'd0, CMP = 3'd1, MREQ = 3'd2, REFILL = 3'd3, READ = 3'd4;
    reg [2:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE : next_state = (cpu_req)? CMP : IDLE;
            CMP : next_state = (cpu_req)? ((cache_hit)? CMP : MREQ) : IDLE;
            MREQ : next_state = (arready)? REFILL : MREQ;
            REFILL : next_state = (rvalid&&rlast)? READ : REFILL;
            READ : next_state = (cpu_req)? CMP : IDLE;
        endcase
    end


endmodule
