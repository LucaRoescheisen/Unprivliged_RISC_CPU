addi x2, x0, 10     # Setup: x2 = 10

    # 1. CALL THE FUNCTION
    jal x1, add_five    # Jump to 'add_five', save 'AfterFunc' address in x1

AfterFunc:
    # 3. CHECK IF WE BACK
    # If the CPU returns correctly, it executes this line.
    addi x2, x2, 100    # x2 should now be 15 + 100 = 115

    jal x0, end         # Jump to end to avoid falling into the function again

# --- THE FUNCTION ---
add_five:
    addi x2, x2, 5      # x2 = 10 + 5 = 15
    # 2. RETURN
    jalr x0, x1, 0      # Jump to the address in x1 (AfterFunc)

end:
    jal x0, end         # Final parking spot