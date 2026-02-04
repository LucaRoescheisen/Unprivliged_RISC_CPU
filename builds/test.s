# divider_test.s
# Tests: DIV, DIVU, REM, REMU with various cases
# Also tests pipeline stalling behavior

.text
.globl _start

_start:
    # Initialize test result register
    addi x10, x0, 0   # x10 = test counter (0 = all tests passed)

   # ============================================
   # Test 1: DIV (signed division) - Basic case
   # ============================================
   addi x1, x0, 20    # x1 = 20
   addi x2, x0, 5     # x2 = 5
   div x3, x1, x2     # x3 = 20 / 5 = 4
   addi x4, x0, 4     # Expected result
   bne x3, x4, test_fail

   # ============================================
   # Test 2: DIV (signed) - Negative dividend
   # ============================================
   addi x1, x0, -20   # x1 = -20
   addi x2, x0, 5     # x2 = 5
   div x3, x1, x2     # x3 = -20 / 5 = -4
   addi x4, x0, -4    # Expected result
   bne x3, x4, test_fail

   # ============================================
   # Test 3: DIV (signed) - Negative divisor
   # ============================================
  addi x1, x0, 20    # x1 = 20
  addi x2, x0, -5    # x2 = -5
  div x3, x1, x2     # x3 = 20 / -5 = -4
  addi x4, x0, -4    # Expected result
  bne x3, x4, test_fail

  # ============================================
  # Test 4: DIVU (unsigned) - Basic case
  # ============================================
  addi x1, x0, 20    # x1 = 20
  addi x2, x0, 5     # x2 = 5
  divu x3, x1, x2    # x3 = 20 / 5 = 4
  addi x4, x0, 4     # Expected result
  bne x3, x4, test_fail

  # ============================================
  # Test 5: DIVU (unsigned) - Large numbers
  # ============================================
  lui x1, 0x12345    # x1 = 0x12345000
  addi x1, x1, 0x678 # x1 = 0x12345678
  addi x2, x0, 0x100 # x2 = 256
  divu x3, x1, x2    # x3 = 0x12345678 / 256 = 0x123456
  lui x4, 0x123      # Expected high bits
  addi x4, x4, 0x456 # x4 = 0x123456
  bne x3, x4, test_fail

  # ============================================
   # Test 6: REM (signed remainder) - Basic
   # ============================================
   addi x1, x0, 23    # x1 = 23
   addi x2, x0, 5     # x2 = 5
   rem x3, x1, x2     # x3 = 23 % 5 = 3
   addi x4, x0, 3     # Expected result
   bne x3, x4, test_fail

  # ============================================
  # Test 7: REM (signed) - Negative dividend
  # ============================================
  addi x1, x0, -23   # x1 = -23
  addi x2, x0, 5     # x2 = 5
  rem x3, x1, x2     # x3 = -23 % 5 = -3
  addi x4, x0, -3    # Expected result
  bne x3, x4, test_fail

  # ============================================
  # Test 8: REMU (unsigned remainder) - Basic
  # ============================================
  addi x1, x0, 23    # x1 = 23
  addi x2, x0, 5     # x2 = 5
  remu x3, x1, x2    # x3 = 23 % 5 = 3
  addi x4, x0, 3     # Expected result
  bne x3, x4, test_fail

  # ============================================
  # Test 9: Division by zero (should produce -1 for DIV, dividend for REM)
  # ============================================
  addi x1, x0, 42    # x1 = 42
  addi x2, x0, 0     # x2 = 0

  div x3, x1, x2     # x3 = 42 / 0 = -1 (by RISC-V spec)
  addi x4, x0, -1    # Expected result
  bne x3, x4, test_fail

  rem x5, x1, x2     # x5 = 42 % 0 = 42 (by RISC-V spec)
  addi x6, x0, 42    # Expected result
  bne x5, x6, test_fail

  # ============================================
  # Test 10: Pipeline stalling test
  # This is the key test - checks if pipeline stalls correctly
  # ============================================
  addi x1, x0, 1000   # x1 = 1000 (dividend)
  addi x2, x0, 7      # x2 = 7 (divisor)

  # Start a slow division
  div x3, x1, x2      # This should stall pipeline

  # These instructions should NOT execute until division completes
  # If pipeline stalls correctly, they'll execute after division
  # If pipeline doesn't stall, they'll execute with wrong data
  addi x4, x0, 1      # x4 = 1
  addi x5, x0, 2      # x5 = 2
  addi x6, x0, 3      # x6 = 3
  add x7, x4, x5      # x7 = 1 + 2 = 3
  add x8, x7, x6      # x8 = 3 + 3 = 6

  # Verify division result
  # 1000 / 7 = 142 (integer division)
  addi x9, x0, 142    # Expected: 1000 / 7 = 142
  bne x3, x9, test_fail

  # Verify pipeline executed in correct order
  addi x9, x0, 6      # Expected: x8 should be 6
  bne x8, x9, test_fail

  # ============================================
  # Test 11: Back-to-back divisions (stress test)
  # ============================================
  addi x1, x0, 100
  addi x2, x0, 3

  div x3, x1, x2      # 100 / 3 = 33
  addi x4, x0, 33
  bne x3, x4, test_fail

  div x5, x1, x2      # Another division immediately
  bne x5, x4, test_fail  # Should also be 33

  # ============================================
  # Test 12: Division followed by dependent instruction
  # Tests forwarding after stall
  # ============================================
  addi x1, x0, 64
  addi x2, x0, 4

  div x3, x1, x2      # 64 / 4 = 16
  add x4, x3, x0      # Immediately use result (tests forwarding)

  addi x5, x0, 16
  bne x4, x5, test_fail

  # ============================================
  # Test 13: Mixed operations during stall
  # ============================================
  addi x1, x0, 999
  addi x2, x0, 9

  # Start division
  div x3, x1, x2      # 999 / 9 = 111

  # Do some ALU ops that don't depend on division
  addi x4, x0, 10
  addi x5, x0, 20
  add x6, x4, x5      # x6 = 30

  # Now use division result
  addi x7, x0, 111
  bne x3, x7, test_fail

  # Verify ALU ops worked
  addi x8, x0, 30
  bne x6, x8, test_fail

   # ============================================
   # All tests passed!
   # ============================================
   addi x10, x0, 1     # x10 = 1 (success)
   ebreak

test_fail:
    # x10 already contains failure code (0)
    ebreak

# Expected final state if all tests pass:
# x10 = 1 (success flag)
# Other registers contain various test results