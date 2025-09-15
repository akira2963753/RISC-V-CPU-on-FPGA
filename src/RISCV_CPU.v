`include "SYSTEM_DEF.vh"

module RISCV_CPU(
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET aresetn, FREQ_HZ=100000000" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    input aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    input aresetn,

    // ===== M_AXI (AXI4 Read-only Master) =====
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR"  *)
    output [`INSTR_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLEN"   *)
    output [7:0] M_AXI_ARLEN,   // AXI4 8-bit
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE"  *)
    output [2:0] M_AXI_ARSIZE,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARBURST" *)
    output [1:0] M_AXI_ARBURST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK"  *)
    output M_AXI_ARLOCK,  // AXI4: 1-bit
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE" *)
    output [3:0] M_AXI_ARCACHE,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARPROT"  *)
    output [2:0] M_AXI_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARQOS"   *)
    output [3:0] M_AXI_ARQOS,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *)
    output M_AXI_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *)
    input M_AXI_ARREADY,

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA"   *)
    input [`DATA_WIDTH-1:0] M_AXI_RDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP"   *)
    input [1:0] M_AXI_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RLAST"   *)
    input M_AXI_RLAST,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID"  *)
    input M_AXI_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY"  *)
    output M_AXI_RREADY


);

    wire [`PC_WIDTH - 1:0] IF_PC;
    wire [`PC_WIDTH - 1:0] PC_Plus_4;
    wire [`PC_WIDTH - 1:0] ID_PC,EX_PC,PC_Plus_Imm;
    wire IF_ID_w;
    wire [`INSTR_WIDTH - 1:0] IF_Instr;
    wire [`INSTR_WIDTH - 1:0] ID_Instr;

    wire [`DATA_WIDTH - 1:0] ID_Rs1_Data,EX_Rs1_Data;
    wire [`DATA_WIDTH - 1:0] ID_Rs2_Data,EX_Rs2_Data;
    wire [`ADDR_WIDTH - 1:0] ID_Rs1_Addr,EX_Rs1_Addr;
    wire [`ADDR_WIDTH - 1:0] ID_Rs2_Addr,EX_Rs2_Addr;
    wire [`ADDR_WIDTH - 1:0] ID_Rd_Addr,EX_Rd_Addr,MEM_Rd_Addr,WB_Rd_Addr;
    wire [6:0] ID_Funct7,EX_Funct7;
    wire [2:0] ID_Funct3,EX_Funct3,MEM_Funct3;

    wire Branch_Taken;
    wire [2:0] Imm_Type;
    wire [1:0] ID_ALU_op,EX_ALU_op;
    wire [1:0] ID_WB_sel,EX_WB_sel,MEM_WB_sel,WB_WB_sel;
    wire ID_Reg_w,EX_Reg_w,WB_Reg_w;
    wire ID_ALU_src1,EX_ALU_src1;
    wire ID_ALU_src2,EX_ALU_src2;
    wire ID_Mem_w,EX_Mem_w,MEM_Mem_w;
    wire ID_Mem_r,EX_Mem_r,MEM_Mem_r;
    wire ID_Branch,EX_Branch;
    wire ID_Jump,EX_Jump;
    wire PC_sel;
    wire IF_ID_Flush;
    wire ID_EX_Flush,ID_EX_Flush_0,ID_EX_Flush_1;
    wire [`DATA_WIDTH - 1:0] ID_Imm,EX_Imm,MEM_Imm,WB_Imm;
    wire [`OPCODE_WIDTH - 1:0] Opcode;

    wire [`DATA_WIDTH - 1:0] Src1_Data,Src2_Data;
    wire [`DATA_WIDTH - 1:0] Src1,Src2;
    wire [`DATA_WIDTH - 1:0] ALU_Result,EX_ALU_Result,MEM_ALU_Result,WB_ALU_Result;
    wire [3:0] ALU_Ctrl_op;
    wire Zero_Flag;

    wire [`DATA_WIDTH - 1:0] EX_PC_Plus_4,MEM_PC_Plus_4,WB_PC_Plus_4;
    wire [`DATA_WIDTH - 1:0] EX_Mem_W_Data,MEM_Mem_W_Data;
    wire [`DATA_WIDTH - 1:0] Mem_R_Data,MEM_Mem_R_Data,WB_Mem_R_Data;
    wire [`DATA_WIDTH - 1:0] WB_Data;
    wire [1:0] Forward_A,Forward_B;
    wire [3:0] EX_Mem_W_Strb,MEM_Mem_W_Strb;

    wire busy;
    wire cpu_req_ready = 1'b1;

    // Instruction Decode
    assign Opcode = ID_Instr[6:0];
    assign ID_Rs1_Addr = ID_Instr[19:15];
    assign ID_Rs2_Addr = ID_Instr[24:20];
    assign ID_Rd_Addr = ID_Instr[11:7];
    assign ID_Funct7 = ID_Instr[31:25];
    assign ID_Funct3 = ID_Instr[14:12];

    assign EX_Mem_W_Data = Src2_Data;

    // PC MUX
    assign PC_sel = Branch_Taken || EX_Jump;

    // PC + 4 
    assign EX_PC_Plus_4 = EX_PC + 4;

    // ALU MUX
    assign Src1_Data = (Forward_A == 2'b00)? EX_Rs1_Data :
                    (Forward_A == 2'b01)? WB_Data : MEM_ALU_Result;

    assign Src1 = (EX_ALU_src1)? EX_PC_Plus_4 : Src1_Data;

    assign Src2_Data = (Forward_B == 2'b00)? EX_Rs2_Data :
                    (Forward_B == 2'b01)? WB_Data : MEM_ALU_Result;

    assign Src2 = (EX_ALU_src2)? EX_Imm : Src2_Data;

    assign EX_ALU_Result = (EX_Branch)? PC_Plus_Imm : ALU_Result;

    // WB MUX
    assign WB_Data = (WB_WB_sel == 2'b00)? WB_ALU_Result : 
                    (WB_WB_sel == 2'b01)? WB_PC_Plus_4 : 
                    (WB_WB_sel == 2'b10)? WB_Mem_R_Data : WB_Imm;

    assign ID_EX_Flush = ID_EX_Flush_1 || ID_EX_Flush_0;

    PC Program_Counter (
        .clk(aclk),
        .rst_n(aresetn),
        .PC_sel(PC_sel),
        .EX_ALU_Result(EX_ALU_Result),
        .PC_Plus_4(PC_Plus_4),
        .IF_PC(IF_PC));

    PC_Adder PC_Adder_inst (
        .IF_ID_w(IF_ID_w),
        .PC_In(IF_PC),
        .busy(busy),
        .PC_Out(PC_Plus_4));

    /*I_Mem Instruction_Memory (
        .Instr_Addr(IF_PC),
        .Instr(IF_Instr));
    */

    I_Cache_AXI4 I_Cache_AXI4_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        .cpu_req(1'b1),
        .cpu_req_addr(IF_PC),
        .cpu_req_ready(cpu_req_ready),
        .cpu_req_data(IF_Instr),
        .flush(1'b0),
        .busy(busy),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE),
        .M_AXI_ARBURST(M_AXI_ARBURST),
        .M_AXI_ARLOCK(M_AXI_ARLOCK),
        .M_AXI_ARCACHE(M_AXI_ARCACHE),
        .M_AXI_ARPROT(M_AXI_ARPROT),
        .M_AXI_ARQOS(M_AXI_ARQOS),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RLAST(M_AXI_RLAST),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );


    IF_ID IF_ID_inst (
        .clk(aclk),
        .rst_n(aresetn),
        .IF_ID_w(IF_ID_w),
        .IF_ID_Flush(IF_ID_Flush),
        .IF_PC(IF_PC),
        .IF_Instr(IF_Instr),
        .ID_PC(ID_PC),
        .ID_Instr(ID_Instr));

    RF Register_File(
        .clk(aclk),
        .rst_n(aresetn),
        .Reg_w(WB_Reg_w),
        .Rs1_Addr(ID_Rs1_Addr),
        .Rs2_Addr(ID_Rs2_Addr),
        .Rd_Addr(WB_Rd_Addr),
        .Rd_Data(WB_Data),
        .Rs1_Data(ID_Rs1_Data),
        .Rs2_Data(ID_Rs2_Data));

    Control Control_Unit(
        .Opcode(Opcode),
        .Branch_Taken(Branch_Taken),
        .ID_EX_Jump(EX_Jump),
        .Imm_Type(Imm_Type),
        .ALU_op(ID_ALU_op),
        .WB_sel(ID_WB_sel),
        .Reg_w(ID_Reg_w),
        .ALU_src1(ID_ALU_src1),
        .ALU_src2(ID_ALU_src2),
        .Mem_w(ID_Mem_w),
        .Mem_r(ID_Mem_r),
        .Branch(ID_Branch),
        .Jump(ID_Jump),
        .IF_ID_Flush(IF_ID_Flush),
        .ID_EX_Flush_1(ID_EX_Flush_1));

    ImmGen Immediate_Generator(
        .Instr(ID_Instr),
        .Imm_Type(Imm_Type),
        .Imm(ID_Imm));

    Hazard_Unit Hazard_Unit_inst(
        .Rs1Addr(ID_Rs1_Addr),
        .Rs2Addr(ID_Rs2_Addr),
        .RdAddr(EX_Rd_Addr),
        .EX_Mem_r(EX_Mem_r),
        .IF_ID_w(IF_ID_w),
        .ID_EX_Flush_0(ID_EX_Flush_0));

    ID_EX ID_EX_inst(
        .clk(aclk),
        .rst_n(aresetn),
        .ID_EX_Flush(ID_EX_Flush),
        .ID_ALU_op(ID_ALU_op),
        .ID_ALU_src1(ID_ALU_src1),
        .ID_ALU_src2(ID_ALU_src2),
        .ID_Branch(ID_Branch),
        .ID_Jump(ID_Jump),
        .ID_Mem_r(ID_Mem_r),
        .ID_Mem_w(ID_Mem_w),
        .ID_Reg_w(ID_Reg_w),
        .ID_WB_sel(ID_WB_sel),
        .ID_PC(ID_PC),
        .ID_Rs1_Data(ID_Rs1_Data),
        .ID_Rs2_Data(ID_Rs2_Data),
        .ID_Imm(ID_Imm),
        .ID_Rs1_Addr(ID_Rs1_Addr),
        .ID_Rs2_Addr(ID_Rs2_Addr),
        .ID_Rd_Addr(ID_Rd_Addr),
        .ID_Funct7(ID_Funct7),
        .ID_Funct3(ID_Funct3),
        .EX_ALU_op(EX_ALU_op),
        .EX_ALU_src1(EX_ALU_src1),
        .EX_ALU_src2(EX_ALU_src2),
        .EX_Branch(EX_Branch),
        .EX_Jump(EX_Jump),
        .EX_Mem_r(EX_Mem_r),
        .EX_Mem_w(EX_Mem_w),
        .EX_Reg_w(EX_Reg_w),
        .EX_WB_sel(EX_WB_sel),
        .EX_PC(EX_PC),
        .EX_Rs1_Data(EX_Rs1_Data),
        .EX_Rs2_Data(EX_Rs2_Data),
        .EX_Imm(EX_Imm),
        .EX_Rs1_Addr(EX_Rs1_Addr),
        .EX_Rs2_Addr(EX_Rs2_Addr),
        .EX_Rd_Addr(EX_Rd_Addr),
        .EX_Funct7(EX_Funct7),
        .EX_Funct3(EX_Funct3));

    ALU Arithmetic_Logic_Unit(
        .Src1(Src1),
        .Src2(Src2),
        .ALU_Ctrl_op(ALU_Ctrl_op),
        .ALU_Result(ALU_Result),
        .Zero_Flag(Zero_Flag));

    ALU_Control ALU_Control_Unit(
        .ALU_op(EX_ALU_op),
        .Funct3(EX_Funct3),
        .Funct7(EX_Funct7),
        .Mem_W_Strb(EX_Mem_W_Strb),
        .ALU_Ctrl_op(ALU_Ctrl_op));

    BPU Branch_Processing_Unit(
        .ALU_Result0(ALU_Result[0]),
        .Zero_Flag(Zero_Flag),
        .Funct3(EX_Funct3),
        .EX_Branch(EX_Branch),
        .EX_PC(EX_PC),
        .EX_Imm(EX_Imm),
        .PC_Plus_Imm(PC_Plus_Imm),
        .Branch_Taken(Branch_Taken));


    Forwarding_Unit Forwarding_Unit_inst(
        .MEM_Rd_Addr(MEM_Rd_Addr),
        .MEM_Reg_w(MEM_Reg_w),
        .WB_Rd_Addr(WB_Rd_Addr),
        .WB_Reg_w(WB_Reg_w),
        .EX_Rs1_Addr(EX_Rs1_Addr),
        .EX_Rs2_Addr(EX_Rs2_Addr),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B));

    EX_MEM EX_MEM_inst(
        .clk(aclk),
        .rst_n(aresetn),
        .EX_Mem_r(EX_Mem_r),
        .EX_Mem_w(EX_Mem_w),
        .EX_Reg_w(EX_Reg_w),
        .EX_WB_sel(EX_WB_sel),
        .EX_Imm(EX_Imm),
        .EX_PC_Plus_4(EX_PC_Plus_4),
        .EX_ALU_Result(EX_ALU_Result),
        .EX_Mem_W_Data(EX_Mem_W_Data),
        .EX_Rd_Addr(EX_Rd_Addr),
        .EX_Mem_W_Strb(EX_Mem_W_Strb),
        .EX_Funct3(EX_Funct3),
        .MEM_Mem_r(MEM_Mem_r),
        .MEM_Mem_w(MEM_Mem_w),
        .MEM_Reg_w(MEM_Reg_w),
        .MEM_WB_sel(MEM_WB_sel),
        .MEM_Imm(MEM_Imm),
        .MEM_PC_Plus_4(MEM_PC_Plus_4),
        .MEM_ALU_Result(MEM_ALU_Result),
        .MEM_Mem_W_Data(MEM_Mem_W_Data),
        .MEM_Rd_Addr(MEM_Rd_Addr),
        .MEM_Mem_W_Strb(MEM_Mem_W_Strb),
        .MEM_Funct3(MEM_Funct3));

    D_Mem Data_Memory(
        .clk(aclk),
        .rst_n(aresetn),
        .Mem_r(MEM_Mem_r),
        .Mem_w(MEM_Mem_w),
        .Mem_W_Strb(MEM_Mem_W_Strb),
        .Mem_Addr(MEM_ALU_Result),
        .Mem_W_Data(MEM_Mem_W_Data),
        .Mem_R_Data(Mem_R_Data));

    LDU Load_Data_Unit(
        .MEM_Funct3(MEM_Funct3),
        .Mem_R_Data(Mem_R_Data),
        .DPU_Result(MEM_Mem_R_Data));

    MEM_WB MEM_WB_inst(
        .clk(aclk),
        .rst_n(aresetn),
        .MEM_Reg_w(MEM_Reg_w),
        .MEM_WB_sel(MEM_WB_sel),
        .MEM_Imm(MEM_Imm),
        .MEM_PC_Plus_4(MEM_PC_Plus_4),
        .MEM_Mem_R_Data(MEM_Mem_R_Data),
        .MEM_ALU_Result(MEM_ALU_Result),
        .MEM_Rd_Addr(MEM_Rd_Addr),
        .WB_Reg_w(WB_Reg_w),
        .WB_WB_sel(WB_WB_sel),
        .WB_Imm(WB_Imm),
        .WB_PC_Plus_4(WB_PC_Plus_4),
        .WB_Mem_R_Data(WB_Mem_R_Data),
        .WB_ALU_Result(WB_ALU_Result),
        .WB_Rd_Addr(WB_Rd_Addr));

endmodule