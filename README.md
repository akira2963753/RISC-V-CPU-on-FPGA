# RISC-V-CPU
**I try to design a 32-bit Pipelined RISC-V CPU that supports the RV32I and RV32M instruction sets, including Forwarding, Hazard Detection, Flush Detection, Dynamic Branch Prediction, and two L1 Caches. Finally, I Implemented on an FPGA.**   

This project is based on [Computer Organization Course](https://github.com/akira2963753/5-Stage-Pipelined-MIPS-CPU) and [UC Berkeley CS 61C Summer 2025](https://cs61c.org/fa25/)     
#  
  
Progress : Integrating the Cache into the RISC-V CPU and performing data transmission with BRAM using the AXI Bus  
  
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

## Control State Register (CSR) :   
```
 // CSR Address Definition
parameter CSR_MSTATUS = 12'h300; # Machine Status Register
parameter CSR_MTVEC   = 12'h305; # Machine Trap Vector
parameter CSR_MEPC    = 12'h341; # Machine Exception PC
parameter CSR_MCAUSE  = 12'h342; # Machine Cause Register
parameter CSR_RDCYCLE = 12'hc00; # Read Cycle Register
```
