.section .text.trap
.globl trap_handler

trap_handler:
    # Save registers if needed
    # Handle the trap
    # For now, maybe just hang
hang_trap:
    j trap_handler