# branch_test.s
# Tests: BEQ, BNE, JAL, and Branch-not-taken behavior

.text
.globl _start

_start:
    # Initialize registers
    addi x1, x0, 10      # x1 = 10
    addi x2, x0, 10      # x2 = 10
    addi x3, x0, 20      # x3 = 20
    addi x4, x0, 0       # x4 = counter (0)

    # 1. Test BEQ (Branch Taken - Forward)
    beq x1, x2, test_bne # Should branch to test_bne
    addi x4, x4, 1       # This should be FLUSHED (x4 should stay 0)

test_bne:
    # 2. Test BNE (Branch Not Taken)
    bne x1, x2, fail     # Should NOT branch (10 == 10)
    addi x4, x4, 2       # Should execute (x4 = 2)

    # 3. Test BNE (Branch Taken - Forward)
    bne x1, x3, test_jal # Should branch to test_jal
    addi x4, x4, 10      # This should be FLUSHED

test_jal:
    # 4. Test JAL (Unconditional Jump)
    jal x5, loop_setup   # Jump to loop_setup, link PC to x5
    addi x4, x4, 100     # This should be FLUSHED

fail:
    addi x4, x0, 911     # Error indicator: x4 = 911
    ebreak               # Stop execution

loop_setup:
    addi x1, x0, 0       # reset x1 for loop counter
    addi x2, x0, 5       # loop limit

loop_start:
    # 5. Test Backward Branch (Loop)
    addi x1, x1, 1       # x1++
    bne x1, x2, loop_start # Loop back if x1 != 5

    # Final Success State
    # If successful:
    # x1 = 5
    # x4 = 2
    addi x10, x0, 1      # Success flag: x10 = 1
    ebreak