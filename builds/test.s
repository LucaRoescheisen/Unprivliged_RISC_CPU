# RISC-V Math Test
# Final results will be stored in registers x10 through x20

.text
.globl _start

_start:


    # --- TEST UNSIGNED DIVISION ---
    # 0xFFFFFFFF is -1 as signed, but 4,294,967,295 as unsigned
    li   x5, -1
    li   x6, 2
    divu x14, x5, x6   # x14 = (2^32 - 1) / 2 = 2,147,483,647 (0x7FFFFFFF)

    # --- TEST MULTIPLICATION (MUL / MULH) ---
    li x7, 2000
    li x8, 3000
    mul x15, x7, x8    # x15 = 6,000,000

    # Test MULH (Upper 32 bits)
    # 0x7FFFFFFF * 2 = 0x00000001 FFFFFFFE
    li x7, 0x7FFFFFFF
    li x8, 2
    mul  x16, x7, x8   # x16 = 0xFFFFFFFE (Lower bits)
    mulh x17, x7, x8   # x17 = 0x00000001 (Upper bits)

    # --- END TEST ---
    # In a real simulation, we might loop here
    ebreak             # Signal to debugger/simulator to stop