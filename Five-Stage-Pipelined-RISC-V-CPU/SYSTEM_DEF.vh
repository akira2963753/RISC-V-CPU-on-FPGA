// system_defines.vh
`ifndef SYSTEM_DEF_VH
`define SYSTEM_DEF_VH

// I_MEM
`define INSTR_MEM_SIZE 256   
`define INSTR_WIDTH 32
`define INSTR_ADDR_WIDTH 32  

// D_MEM
`define DATA_MEM_SIZE 32
`define DATA_MEM_WIDTH 32
`define DATA_MEM_ADDR_WIDTH 32

`define PC_WIDTH 32
`define DATA_WIDTH 32
`define ADDR_WIDTH 5

// RF
`define GPR_SIZE 32

// ImmGen, Type
`define I_TYPE_IMM 0
`define S_TYPE_IMM 1
`define B_TYPE_IMM 2
`define U_TYPE_IMM 3
`define J_TYPE_IMM 4

// Opcode
`define OPCODE_WIDTH 7
`define R_TYPE 7'b0110011
`define I_TYPE_ALU 7'b0010011
`define I_TYPE_LOAD 7'b0000011
`define I_TYPE_JALR 7'b1100111
`define I_TYPE_CSR 7'b1110011
`define S_TYPE 7'b0100011
`define B_TYPE 7'b1100011
`define U_TYPE_LUI 7'b0110111
`define U_TYPE_AUIPC 7'b0010111
`define J_TYPE_JAL 7'b1101111

`define ALU_OP_ADD 2'b00
`define ALU_OP_BRANCH 2'b01
`define ALU_OP_R_TYPE 2'b10
`define ALU_OP_I_TYPE 2'b11

`define ALU_CTRL_ADD  4'b0000  
`define ALU_CTRL_SUB  4'b0001  
`define ALU_CTRL_SLL  4'b0010  
`define ALU_CTRL_SLT  4'b0011  
`define ALU_CTRL_SLTU 4'b0100  
`define ALU_CTRL_XOR  4'b0101  
`define ALU_CTRL_SRL  4'b0110  
`define ALU_CTRL_SRA  4'b0111  
`define ALU_CTRL_OR   4'b1000  
`define ALU_CTRL_AND  4'b1001
`define ALU_CTRL_GEU  4'b1010 
`define ALU_CTRL_GE   4'b1011  

`define NOP 0

`define BHT_PC_WIDTH 6
`define BTB_PC_WIDTH 6
`define BHT_SIZE 64
`define BTB_SIZE 64

// Cache
`define CACHE_SIZE 8192
`define WAY 2
`define BLOCK_BYTE_SIZE 32
`define BLOCK_WORD_SIZE (`BLOCK_BYTE_SIZE / 4)
`define SET_NUM (`CACHE_SIZE / (`BLOCK_BYTE_SIZE * `WAY))
`define OFFSET_WIDTH ($clog2(`BLOCK_BYTE_SIZE))
`define WORD_OFFSET_WIDTH ($clog2(`BLOCK_WORD_SIZE))
`define INDEX_WIDTH ($clog2(`SET_NUM))
`define TAG_WIDTH (`INSTR_ADDR_WIDTH - `OFFSET_WIDTH - `INDEX_WIDTH)

`endif