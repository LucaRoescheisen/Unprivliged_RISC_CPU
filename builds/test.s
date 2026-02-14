


    .section .text
    .globl _start

_start:

    # ----------------------------
    # Test mtvec CSR (0x305)
    # ----------------------------

    li    t0, 0x100         # Load test value
    csrw  mtvec, t0         # Write t0 into mtvec
    csrr  t1, mtvec         # Read mtvec back into t1

    # t1 should now be 0x100

    # ----------------------------
    # Test mscratch CSR (0x340)
    # ----------------------------

    li    t2, 0xDEADBEEF    # Load test value
    csrw  mscratch, t2      # Write t2 into mscratch
    csrr  t3, mscratch      # Read mscratch back into t3

    # t3 should now be 0xDEADBEEF

    # ----------------------------
    # End of test (infinite loop)
    # ----------------------------
loop:
    j loop
