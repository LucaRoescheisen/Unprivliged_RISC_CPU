# RISC-V Base Integer Test
# No branches, no complex math

# 1. Test ADDI (Immediate math)
addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20
addi x3, x1, 5       # x3 = 15

# 2. Test ADD/SUB (Register math)
add  x4, x1, x2      # x4 = 30
sub  x5, x4, x1      # x5 = 20

# 3. Test Logical Ops
or   x6, x1, x2      # x6 = 10 | 20 = 30 (0x1E)
and  x7, x6, x1      # x7 = 30 & 10 = 10 (0x0A)

# 4. Test Load/Store (MEM Stage)
sw   x4, 4(x0)       # Store value 30 into RAM address 4
lw   x8, 4(x0)       # Load value from RAM address 4 into x8

# 5. Final result check
# If everything works, x8 should contain 30 (0x1E)
addi x0, x0, 0       # NOP (End of test)