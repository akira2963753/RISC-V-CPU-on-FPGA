# RISC-V-CPU
**This project is based on [Computer Organization Course](https://github.com/akira2963753/5-Stage-Pipelined-MIPS-CPU) and [UC Berkeley CS 61C Summer 2025](https://cs61c.org/fa25/)**  
  
**I try to design a 32-bit Pipelined RISC-V CPU that supports the RV32I and RV32M, including Forwarding, Hazard Detection, Flush Detection, Dynamic Branch Prediction, and two L1 Caches. Finally, I Implemented on FPGA.**  
  
<img width="500" height="400" alt="RISCV_ALL drawio (4)" src="https://github.com/user-attachments/assets/5aa5eeed-15eb-467f-a554-bf9208201c23" />  
    
#  
  
Progress :  
Integrating the Cache into the RISC-V CPU and performing data transmission with BRAM using the AXI Bus  
  
## Repository Structure 
**You can use [rv32i_transfer](./Five-Stage-Pipelined-RISC-V-CPU/testbench/rv32i_transfer.py) to transfer the instruction you wrote to machine code and write it into IM.dat.**  
  
```
RISCV-CPU /
├── Five-Stage-Pipelined-RISC-V-CPU  # No Cache  
│   ├── RTL
│   └── TESTBENCH
│   └── DEF         
```
  
## Five-Stage Pipelined RISC-V CPU     
<img width="2259" height="1173" alt="RISC-V 的副本 drawio" src="https://github.com/user-attachments/assets/b1996413-9ad6-460f-af46-fb20bdd8cbe3" />  

## Control State Register (CSR)    
``` Verilog
// CSR Address Definition
parameter CSR_MSTATUS = 12'h300;  # Machine Status Register
parameter CSR_MTVEC   = 12'h305;  # Machine Trap Vector
parameter CSR_MEPC    = 12'h341;  # Machine Exception PC
parameter CSR_MCAUSE  = 12'h342;  # Machine Cause Register
parameter CSR_RDCYCLE = 12'hc00;  # Read Cycle Register
```

### Dynamic Branch Prediction   
I use [Branch History Table](./Five-Stage-Pipelined-RISC-V-CPU/RTL/BHT.v)  and [Branch Tag Buffer](./Five-Stage-Pipelined-RISC-V-CPU/RTL/BTB.v) to achieve Dynamic Branch Prediction.  
Branch History Table can predict whether branch using 2-bit dynamic branch predictor.  
  ``` Verilog
  reg [1:0] state [0:`BHT_SIZE-1];

  00 -> Strong non-branch
  01 -> Soft non-branch
  10 -> Soft branch
  10 -> Strong branch

  ```
Branch Tag Buffer can help me to record previous branch address (Branch_PC), like a cache.  

### Example   
``` 
// Branch Prediction Test - Simple Loop Pattern
// This test demonstrates branch prediction learning

// Initialize counter
ADDI x1, x0, 10        // Loop counter = 10
ADDI x2, x0, 0        // Sum accumulator = 0

// Simple Loop (Predictable Pattern) - starts at address 8
ADD x2, x2, x1        // sum += counter
ADDI x1, x1, -1       // counter--
BNE x1, x0, -8        // if counter != 0, branch back 8 bytes (to ADD instruction)

...  
```
<img width="1862" height="228" alt="image" src="https://github.com/user-attachments/assets/6babf407-d854-4862-bec4-3bda19433ca0" />  

## Load Data Size and Store Data Size     
### Load Data Unit (LDU) :   
This unit handle read data size and sign extension from Data Memory.  
``` Verilog
module LDU(
    input [2:0] MEM_Funct3,
    input [`DATA_WIDTH - 1:0] Mem_R_Data,
    output reg [`DATA_WIDTH - 1:0] LDU_Result
);
    // DPU implementation
    always @(*) begin
        case(MEM_Funct3)
            3'b000 : LDU_Result = {{24{Mem_R_Data[7]}}, Mem_R_Data[7:0]}; // Load Byte
            3'b001 : LDU_Result = {{16{Mem_R_Data[15]}}, Mem_R_Data[15:0]}; // Load Half Word
            3'b010 : LDU_Result = Mem_R_Data;
            3'b100 : LDU_Result = {24'b0, Mem_R_Data[7:0]}; // Load Byte Unsigned
            3'b101 : LDU_Result = {16'b0, Mem_R_Data[15:0]}; // Load Half Word Unsigned
            default : LDU_Result = Mem_R_Data;
        endcase
    end
endmodule
```

### Data Memory Store :
Write Data use Mem_W_Strb to control the write data size.  
``` Verilog
    always @(posedge clk) begin
        if(Mem_w) begin
            if(Mem_W_Strb[0]) DataMem[Mem_Addr] <= Mem_W_Data[7:0];
            if(Mem_W_Strb[1]) DataMem[Mem_Addr+1] <= Mem_W_Data[15:8];
            if(Mem_W_Strb[2]) DataMem[Mem_Addr+2] <= Mem_W_Data[23:16];
            if(Mem_W_Strb[3]) DataMem[Mem_Addr+3] <= Mem_W_Data[31:24];
        end
        else; // No write operation
    end

```

## Branch Process Unit (BPU)     
I use the Result and the Zero Flag calculated from the [ALU](./Five-Stage-Pipelined-RISC-V-CPU/RTL/ALU.v) passed to the [Branch Processing Unit](./Five-Stage-Pipelined-RISC-V-CPU/RTL/BPU.v)  to determine whether the branch is taken.  

## Immediate Generator (ImmGen)    
[Immediate Generator](./Five-Stage-Pipelined-RISC-V-CPU/RTL/ImmGen.v) generates the immediate value based on the RISC-V Instruction Set encoding format.  
``` Verilog
  always @(*) begin
        case (Imm_Type)
            `I_TYPE_IMM : Imm = {{20{Instr[31]}},Instr[31:20]};
            `S_TYPE_IMM : Imm = {{20{Instr[31]}},Instr[31:25],Instr[11:7]};
            `B_TYPE_IMM : Imm = {{19{Instr[31]}},Instr[31],Instr[7],Instr[30:25],Instr[11:8],1'b0};
            `U_TYPE_IMM : Imm = {Instr[31:12],12'b0};
            `J_TYPE_IMM : Imm = {{11{Instr[31]}},Instr[31],Instr[19:12],Instr[20],Instr[30:21],1'b0};
            default : Imm = 0;
        endcase
    end
```  



