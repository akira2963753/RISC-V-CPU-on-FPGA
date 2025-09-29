#!/usr/bin/env python3
# RISC-V RV32I 指令轉換器

import re

# 指令編碼表
OPCODES = {
    # R-type
    'ADD': 0x33, 'SUB': 0x33, 'SLL': 0x33, 'SLT': 0x33, 'SLTU': 0x33,
    'XOR': 0x33, 'SRL': 0x33, 'SRA': 0x33, 'OR': 0x33, 'AND': 0x33,
    # I-type (arithmetic)
    'ADDI': 0x13, 'SLTI': 0x13, 'SLTIU': 0x13, 'XORI': 0x13, 'ORI': 0x13, 'ANDI': 0x13,
    'SLLI': 0x13, 'SRLI': 0x13, 'SRAI': 0x13,
    # I-type (load)
    'LB': 0x03, 'LH': 0x03, 'LW': 0x03, 'LBU': 0x03, 'LHU': 0x03,
    # I-type (jump/system)
    'JALR': 0x67, 'ECALL': 0x73, 'EBREAK': 0x73,
    # CSR instructions
    'CSRRW': 0x73, 'CSRRS': 0x73, 'CSRRC': 0x73,
    'CSRRWI': 0x73, 'CSRRSI': 0x73, 'CSRRCI': 0x73,
    # S-type
    'SB': 0x23, 'SH': 0x23, 'SW': 0x23,
    # B-type
    'BEQ': 0x63, 'BNE': 0x63, 'BLT': 0x63, 'BGE': 0x63, 'BLTU': 0x63, 'BGEU': 0x63,
    # U-type
    'LUI': 0x37, 'AUIPC': 0x17,
    # J-type
    'JAL': 0x6F
}

FUNCT3 = {
    'ADD': 0, 'SUB': 0, 'ADDI': 0, 'SLL': 1, 'SLLI': 1, 'SLT': 2, 'SLTI': 2,
    'SLTU': 3, 'SLTIU': 3, 'XOR': 4, 'XORI': 4, 'SRL': 5, 'SRA': 5, 'SRLI': 5, 'SRAI': 5,
    'OR': 6, 'ORI': 6, 'AND': 7, 'ANDI': 7, 'LB': 0, 'LH': 1, 'LW': 2, 'LBU': 4, 'LHU': 5,
    'SB': 0, 'SH': 1, 'SW': 2, 'BEQ': 0, 'BNE': 1, 'BLT': 4, 'BGE': 5, 'BLTU': 6, 'BGEU': 7,
    'JALR': 0, 'ECALL': 0, 'EBREAK': 0,
    # CSR instructions funct3
    'CSRRW': 1, 'CSRRS': 2, 'CSRRC': 3, 'CSRRWI': 5, 'CSRRSI': 6, 'CSRRCI': 7
}

FUNCT7 = {
    'ADD': 0, 'SUB': 0x20, 'SLL': 0, 'SLT': 0, 'SLTU': 0, 'XOR': 0,
    'SRL': 0, 'SRA': 0x20, 'OR': 0, 'AND': 0, 'SLLI': 0, 'SRLI': 0, 'SRAI': 0x20
}

def parse_csr(csr_name):
    """解析 CSR 名稱，返回 CSR 位址"""
    csr_map = {
        'mstatus': 0x300,
        'mtvec': 0x305,
        'mepc': 0x341,
        'mcause': 0x342,
        'rdcycle': 0xC00,
        'rdcycleh': 0xC80,
        'rdinstret': 0xC02,
        'rdinstreth': 0xC82
    }
    if csr_name in csr_map:
        return csr_map[csr_name]
    # 如果是數字形式 (如 0x300)
    if csr_name.startswith('0x'):
        return int(csr_name, 16)
    return int(csr_name)

def parse_register(reg):
    """解析暫存器名稱，返回數字"""
    if reg.startswith('x'):
        return int(reg[1:])
    return 0
    """解析暫存器名稱，返回數字"""
    if reg.startswith('x'):
        return int(reg[1:])
    return 0

def parse_immediate(imm):
    """解析立即數"""
    if imm.startswith('0x'):
        return int(imm, 16)
    return int(imm)

def sign_extend(value, bits):
    """符號擴展"""
    if value & (1 << (bits - 1)):
        value -= (1 << bits)
    return value

def encode_instruction(parts):
    """編碼單一指令"""
    opcode_name = parts[0]
    opcode = OPCODES[opcode_name]
    
    # R-type 指令
    if opcode_name in ['ADD', 'SUB', 'SLL', 'SLT', 'SLTU', 'XOR', 'SRL', 'SRA', 'OR', 'AND']:
        rd = parse_register(parts[1].rstrip(','))
        rs1 = parse_register(parts[2].rstrip(','))
        rs2 = parse_register(parts[3])
        funct3 = FUNCT3[opcode_name]
        funct7 = FUNCT7[opcode_name]
        return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # I-type 立即數運算
    elif opcode_name in ['ADDI', 'SLTI', 'SLTIU', 'XORI', 'ORI', 'ANDI']:
        rd = parse_register(parts[1].rstrip(','))
        rs1 = parse_register(parts[2].rstrip(','))
        imm = parse_immediate(parts[3]) & 0xFFF
        funct3 = FUNCT3[opcode_name]
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # I-type 移位
    elif opcode_name in ['SLLI', 'SRLI', 'SRAI']:
        rd = parse_register(parts[1].rstrip(','))
        rs1 = parse_register(parts[2].rstrip(','))
        shamt = parse_immediate(parts[3]) & 0x1F
        funct3 = FUNCT3[opcode_name]
        funct7 = FUNCT7[opcode_name]
        imm = (funct7 << 5) | shamt
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # I-type 載入指令
    elif opcode_name in ['LB', 'LH', 'LW', 'LBU', 'LHU']:
        rd = parse_register(parts[1].rstrip(','))
        match = re.match(r'(-?\d+)\(x(\d+)\)', parts[2])
        imm = parse_immediate(match.group(1)) & 0xFFF
        rs1 = int(match.group(2))
        funct3 = FUNCT3[opcode_name]
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # S-type 儲存指令
    elif opcode_name in ['SB', 'SH', 'SW']:
        rs2 = parse_register(parts[1].rstrip(','))
        match = re.match(r'(-?\d+)\(x(\d+)\)', parts[2])
        imm = parse_immediate(match.group(1)) & 0xFFF
        rs1 = int(match.group(2))
        funct3 = FUNCT3[opcode_name]
        imm_11_5 = (imm >> 5) & 0x7F
        imm_4_0 = imm & 0x1F
        return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
    
    # B-type 分支指令
    elif opcode_name in ['BEQ', 'BNE', 'BLT', 'BGE', 'BLTU', 'BGEU']:
        rs1 = parse_register(parts[1].rstrip(','))
        rs2 = parse_register(parts[2].rstrip(','))
        imm = parse_immediate(parts[3]) & 0x1FFE  # 13位，最低位為0
        funct3 = FUNCT3[opcode_name]
        imm_12 = (imm >> 12) & 1
        imm_11 = (imm >> 11) & 1  
        imm_10_5 = (imm >> 5) & 0x3F
        imm_4_1 = (imm >> 1) & 0xF
        return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
    
    # U-type 指令
    elif opcode_name in ['LUI', 'AUIPC']:
        rd = parse_register(parts[1].rstrip(','))
        imm = parse_immediate(parts[2]) & 0xFFFFF
        return (imm << 12) | (rd << 7) | opcode
    
    # J-type JAL
    elif opcode_name == 'JAL':
        rd = parse_register(parts[1].rstrip(','))
        imm = parse_immediate(parts[2]) & 0x1FFFFE  # 21位，最低位為0
        imm_20 = (imm >> 20) & 1
        imm_19_12 = (imm >> 12) & 0xFF
        imm_11 = (imm >> 11) & 1
        imm_10_1 = (imm >> 1) & 0x3FF
        return (imm_20 << 31) | (imm_10_1 << 21) | (imm_11 << 20) | (imm_19_12 << 12) | (rd << 7) | opcode
    
    # I-type JALR
    elif opcode_name == 'JALR':
        rd = parse_register(parts[1].rstrip(','))
        rs1 = parse_register(parts[2].rstrip(','))
        imm = parse_immediate(parts[3]) & 0xFFF
        funct3 = FUNCT3[opcode_name]
        return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # CSR 指令
    elif opcode_name in ['CSRRW', 'CSRRS', 'CSRRC', 'CSRRWI', 'CSRRSI', 'CSRRCI']:
        rd = parse_register(parts[1].rstrip(','))
        csr_addr = parse_csr(parts[2].rstrip(','))
        funct3 = FUNCT3[opcode_name]
        
        # 判斷是立即數版本還是暫存器版本
        if opcode_name.endswith('I'):  # 立即數版本
            uimm = parse_immediate(parts[3]) & 0x1F  # 5位立即數
            return (csr_addr << 20) | (uimm << 15) | (funct3 << 12) | (rd << 7) | opcode
        else:  # 暫存器版本
            rs1 = parse_register(parts[3])
            return (csr_addr << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    
    # 系統指令
    elif opcode_name == 'ECALL':
        return 0x73
    elif opcode_name == 'EBREAK':
        return 0x100073
    
    return 0

def convert_instructions(input_file, output_file):
    """轉換指令檔案"""
    with open(input_file, 'r', encoding='utf-8') as f_in, open(output_file, 'w', encoding='utf-8') as f_out:
        for line in f_in:
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            
            parts = line.split()
            if not parts:
                continue
            
            try:
                machine_code = encode_instruction(parts)
                
                # 轉換為大端序位元組
                bytes_data = machine_code.to_bytes(4, 'big')
                
                # 寫入註解
                f_out.write(f"// {line}\n")
                
                # 寫入十六進制位元組（大寫）
                for byte in bytes_data:
                    f_out.write(f"{byte:02X}\n")
                
            except Exception as e:
                print(f"Error processing line: {line}")
                print(f"Error: {e}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 2:
        print("使用方法: python riscv_transfer.py <instruction_file>")
        print("範例: python riscv_transfer.py instruction.dat")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = "IM.dat"
    
    try:
        convert_instructions(input_file, output_file)
        print(f"轉換完成！")
        print(f"輸入檔案：{input_file}")
        print(f"輸出檔案：{output_file}")
    except FileNotFoundError:
        print(f"錯誤：找不到檔案 {input_file}")
    except Exception as e:
        print(f"轉換過程中發生錯誤：{e}")