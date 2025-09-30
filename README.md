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
<img width="500" height="400" alt="RISCV_ALL drawio (4)" src="https://github.com/user-attachments/assets/5aa5eeed-15eb-467f-a554-bf9208201c23" />

## Control State Register (CSR) :   
``` Verilog
 // CSR Address Definition
parameter CSR_MSTATUS = 12'h300;  # Machine Status Register
parameter CSR_MTVEC   = 12'h305;  # Machine Trap Vector
parameter CSR_MEPC    = 12'h341;  # Machine Exception PC
parameter CSR_MCAUSE  = 12'h342;  # Machine Cause Register
parameter CSR_RDCYCLE = 12'hc00;  # Read Cycle Register
```

### Dynamic Branch Prediction :  
I use Branch History Table (BHT) and Branch Tag Buffer (BTB) to achieve *Dynamic Branch Prediction*.  
Branch History Table can predict whether branch using 2-bit dynamic branch predictor.  
``` Verilog
reg [1:0] state [0:`BHT_SIZE-1];

00 -> Strong non-branch
01 -> Soft non-branch
10 -> Soft branch
10 -> Strong branch

```
### Branch Tag Buffer :  
Branch Tag Buffer can help me to record previous branch address (Branch_PC), like a cache.   

### Simulation :  
Example : Loop condition  
``` assembly 
// Branch Prediction Test - Simple Loop Pattern
// This test demonstrates branch prediction learning

// Initialize counter
ADDI x1, x0, 10        // Loop counter = 10
ADDI x2, x0, 0        // Sum accumulator = 0

// Simple Loop (Predictable Pattern) - starts at address 8
ADD x2, x2, x1        // sum += counter
ADDI x1, x1, -1       // counter--
BNE x1, x0, -8        // if counter != 0, branch back 8 bytes (to ADD instruction)

ADDI x3, x0, 3
ADDI x4, x0, 4
LW x5, 0(x0)
ADDI x6, x5, 5
ADDI x7, x6, 6
SW x7, 0(x0)
ADDI x8, x7, 0
```
<img width="1862" height="228" alt="image" src="https://github.com/user-attachments/assets/6babf407-d854-4862-bec4-3bda19433ca0" />  





