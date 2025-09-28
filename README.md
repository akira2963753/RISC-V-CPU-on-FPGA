# RISC-V-CPU
該專案基於計算機組織課程，以及 UC Berkeley CS 61C Summer 2025，設計一個32-bit Pipelined RISC-V CPU 支援 RV32I 和 RV32M 指令集，並且包含Forwarding, Hazard, Flush Detection, Dynamic Branch Prediction和兩個L1 Cache。
  
## Repository Structure :
```
RISCV-CPU /
├── Five-Stage-Pipelined-RISC-V-CPU  # No Cache, only RISC-V CPU CORE    
│   ├── RTL
│   └── Testbench
│   └── DEF         
```

## 32-bit RISC-V CPU Framework :   
<img width="924" height="784" alt="RISCV_ALL drawio (3)" src="https://github.com/user-attachments/assets/3f7c01e0-0a03-4622-90f1-992623e3e7a1" />  

## RV 32I / RV32M :  
<img width="600" height="500" alt="image" src="https://github.com/user-attachments/assets/a9422d66-a458-423a-a5ec-328198ec9eaf" />  

## AXI BUS (Cache-AXI-BRAM) :  
<img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/e464dd90-c861-4607-8c2b-0ae3b75be536" />  

### Read Handshake Protocol :  
Master (CPU) 發送 ARVALID 直到 Slave (BRAM) 的 ARREADY 拉起，代表握手成功。   
<img width="500" height="40" alt="image" src="https://github.com/user-attachments/assets/af1607de-bbb2-4d10-9745-fa0982f03dc3" />  
  
Master (CPU) 的 RREADY 拉起，代表可以接受資料，而 Slave (BRAM) 的 RVALID 拉起，代表握手成功，開始傳送資料，直到 RLAST 拉起為最後一筆。   
<img width="500" height="40" alt="image" src="https://github.com/user-attachments/assets/84086cba-7fdf-4dcc-912c-b6dc47b0e827" />  
  
Cache 成功從 AXI 讀出八筆資料出來  
<img width="500" height="40" alt="image" src="https://github.com/user-attachments/assets/145e75bf-9079-4474-89c2-1098ba3e4b6c" />  

但由於 Cache 的 CMP 與 READ 狀態分開，因此需要兩個Cycle才能把正確 Instruction 吐出去(待優化)    
<img width="500" height="40" alt="image" src="https://github.com/user-attachments/assets/feb5fe68-6fd2-46ce-b575-b23287d8e5d0" />  


