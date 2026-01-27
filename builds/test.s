# --- TEST 1: Store/Load Word (32-bit) ---
addi x5, x0, 123       # x5 = 123 (Data to store)
addi x10, x0, 100      # x10 = 100 (The RAM Address)
sw x5, 0(x10)          # RAM[100] = 123

addi x5, x0, 0         # Clear x5 (So we know the load actually works)
lw x6, 0(x10)          # x6 = RAM[100]. Should be 123.

# --- TEST 2: Store/Load Byte (8-bit) ---
addi x7, x0, 0xFF      # x7 = 255 (0x000000FF)
sb x7, 4(x10)          # RAM[104] = 0xFF (Store only the byte)

lb x8, 4(x10)          # x8 = RAM[104]. Should be -1 (due to sign extension).
lbu x9, 4(x10)         # x9 = RAM[104]. Should be 255 (zero extension).

# --- TEST 3: Offset Check ---
addi x11, x0, 50       # x11 = 50
sw x7, 10(x11)         # Store x7 at address 60 (50 + 10)
lw x12, 60(x0)         # Load from address 60. x12 should be 0xFF.

# --- END ---
end:
jal x0, end            # Infinite loop