# RISC-V-CPU
In the Spring of 2025, during my **Computer Organization course**, I learned how to implement a MIPS-CPU [(**Github**)](https://github.com/akira2963753/MIPS-5-stage-pipelined-CPU)   
Unfortunately, due to the course schedule, we were unable to implement more advanced features such as **caches** and **branch prediction.** Therefore, to further explore mainstream CPU architecture design, I chose RISC-V as a practice platform.  
  
<img width="617.4" height="477.4" alt="RISCV_ALL drawio (3)" src="https://github.com/user-attachments/assets/9d67d304-47b1-4591-be26-7a1e44f2c6ed" />   

## Repository Structure :
```
RISCV-CPU /
├── src/                           # RTL Resource
│   ├── RISCV_CPU.v 
│   ├── IF_ID.v          
│   └── ID_EX.v              
│   └── EX_MEM.v              
│   └── MEM_WB.v
│   ├── RF.v          
│   └── ImmGen.v              
│   └── ALU.v
│   └── BPU.v            
│   └── ALU_Control.v    
│   ├── Control.v          
│   └── Forwarding_Unit.v              
│   └── Hazard_Unit.v              
│   └── DPU.v
│   └── PC.v
│   └── PC_Adder.v
│   └── BHT.v
└── └── BTB.v
        
```  
   
## 5-Stage-Pipeline-CPU Based on RV32I/M of RISC-V  :    
<img width="2147" height="964" alt="RISC-V 的副本 drawio (2)" src="https://github.com/user-attachments/assets/8f9f5783-ba46-4b96-a9de-866a14257a65" />  

## RV32I and RV32M :  
<img width="570" height="662" alt="image" src="https://github.com/user-attachments/assets/17bd8742-7456-4b52-8ced-78caf17fa577" />  
<img width="570" height="177" alt="image" src="https://github.com/user-attachments/assets/79486f22-eb21-4a10-b238-a6f51e0e17cb" />

## RTL Simulation :  
...  

## Reference :  
[**CS 61C at UC Berkeley with Justin Yokota - Summer 2025**](https://cs61c.org/su25/)    
[**從零開始的RISC-V SoC架構設計**](https://hackmd.io/@w4K9apQGS8-NFtsnFXutfg/B1Re5uGa5#CPU%E6%9E%B6%E6%A7%8B)   
