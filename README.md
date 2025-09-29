# RISC-V-CPU
This project is based on a [**Computer Organization**](https://github.com/akira2963753/5-Stage-Pipelined-MIPS-CPU) course and [**UC Berkeley CS 61C Summer 2025**](https://cs61c.org/fa25/). I try to design a **32-bit Pipelined RISC-V CPU** that supports the **RV32I and RV32M** instruction sets, including Forwarding, Hazard Detection, Flush Detection, Dynamic Branch Prediction, and two L1 Caches. Finally, I Implemented on an FPGA.   

Current Progress : Completed Five-Stage-Pipelined RISC-V CPU Design and L1 Cache design   
Incomplete Progress : Integrating the Cache into the RISC-V CPU and performing data transmission with BRAM using the AXI Bus  
  
## Repository Structure :
```
RISCV-CPU /
├── Five-Stage-Pipelined-RISC-V-CPU  # No Cache  
│   ├── RTL
│   └── TESTBENCH
│   └── DEF         
```

## 32-bit RISC-V CPU Framework :   
<img width="600" height="500" alt="RISCV_ALL drawio (4)" src="https://github.com/user-attachments/assets/5aa5eeed-15eb-467f-a554-bf9208201c23" />

