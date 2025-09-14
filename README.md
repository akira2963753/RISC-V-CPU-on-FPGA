# RISC-V-CPU
該專案基於計算機組織課程，以及 UC Berkeley CS 61C Summer 2025，設計一個32-bit Pipelined RISC-V CPU 支援 RV32I 和 RV32M 指令集，並且包含Forwarding, Hazard Detection, Dynamic Branch Prediction和兩個L1 Cache。
  
## Repository Structure :
```
RISCV-CPU /
├── src/     
│   ├── RISCV_CPU.v
│   └── IF/
│       ├── IF_ID.v
│       ├── PC.v
│       ├── PC_Adder.v
│       ├── BTB.v
│       ├── BHT.v
│       ├── I_Cache_AXI4.v
│       └── I_Cache.v
│   └── ID/
│       ├── ID_EX.v
│       ├── RF.v
│       └── ImmGen.v
│   └── EX/
│       ├── EX_MEM.v
│       ├── ALU.v
│       ├── BPU.v
│       ├── MUL.v
│       └── DIV.v         
│   └── MEM/
│       ├── MEM_WB.v
│       ├── D_Mem.v
│       └── DPU.v
│   └── CONTROL/
│       ├── Control.v
│       ├── ALU_Control.v
│       ├── Forwarding_Unit.v
│       └── Hazard_Unit.v   
      
```

## 32-bit RISC-V CPU Framework :   
<img width="500" height="400" alt="RISCV_ALL drawio (5)" src="https://github.com/user-attachments/assets/3b634290-4d0c-4b64-bdc3-b66d062d040c" />   

## RV 32I / RV32M :  
<img width="828" height="715" alt="image" src="https://github.com/user-attachments/assets/a9422d66-a458-423a-a5ec-328198ec9eaf" />  
