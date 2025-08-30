# RISC-V-CPU
<img width="500" height="400" alt="RISCV_ALL drawio (5)" src="https://github.com/user-attachments/assets/3b634290-4d0c-4b64-bdc3-b66d062d040c" />  
   
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
│       └── I_Mem.v
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
     
## 5-Stage-Pipeline-CPU Based on RV32I/M of RISC-V  :    
<img width="2147" height="964" alt="RISC-V 的副本 drawio (2)" src="https://github.com/user-attachments/assets/8f9f5783-ba46-4b96-a9de-866a14257a65" />   

## RTL Simulation :  
...  

## Reference :  
[**CS 61C at UC Berkeley with Justin Yokota - Summer 2025**](https://cs61c.org/su25/)    
[**從零開始的RISC-V SoC架構設計**](https://hackmd.io/@w4K9apQGS8-NFtsnFXutfg/B1Re5uGa5#CPU%E6%9E%B6%E6%A7%8B)   
