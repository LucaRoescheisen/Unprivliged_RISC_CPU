@echo off
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o programs/test.o builds/test.s
riscv64-unknown-elf-ld -m elf32lriscv -Ttext 0x0 -o programs/test.elf programs/test.o
riscv64-unknown-elf-objcopy -O verilog -j .text --verilog-data-width=4 --reverse-bytes=4 programs/test.elf programs/test.hex