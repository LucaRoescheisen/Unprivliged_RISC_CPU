.section .text
.globl _start

_start:

addi x1, x0, -1
addi x2, x0, 1
slt  x3, x1, x2
sltu x4, x1, x2

slti x5, x1, 1
sltiu x6, x1, 1

addi x7, x0, 1
addi x8, x0, 32
sll x9, x7, x8
addi x8, x0, 33
sll  x10, x7, x8

addi x11, x0, -1
addi x12, x0, 2047
addi x13, x0, -2048

addi x14, x0, -8
srai x15, x14, 1
srli x16, x14, 1

end:
    j end