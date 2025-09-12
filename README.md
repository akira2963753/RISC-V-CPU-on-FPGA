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
     
## 5-Stage-Pipeline-CPU Based on RV32I/M of RISC-V  :    
<img width="2147" height="964" alt="RISC-V 的副本 drawio (2)" src="https://github.com/user-attachments/assets/8f9f5783-ba46-4b96-a9de-866a14257a65" />   
