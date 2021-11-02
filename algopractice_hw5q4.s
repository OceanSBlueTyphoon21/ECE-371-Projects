@ PackedBCD to ASCII Codes
@ This program converts a PackedBCD into two 
@ separate ASCII Codes in the PackedBCD
@ Example: BCD = 59 or more specifically 0x59 = 0101 1001
@          ASCII result from program: 0011 0101 = 0x35
@                                     0011 1001 = 0x39

@ Inputs: Byte of Packed BCD
@ Outputs: Two Bytes of ASCII codes for PackedBCD nibbles.
@ Anthony Bruno - November 2021

.text 
.global _start
_start
  MOV R0, #0x59       @ Copy the PackedBCD value 59 into R0
  MOV R1, R0          @ Copy the PackedBCD value from R1 into R0
  AND R0, R0, #0xF0   @ Mask R0 with 0xF0 = 1111 0000, this gets the Most Significant Nibble (5 = 0101)
                      @ Put result into R0
  AND R1, R1, #0x0F   @ Mask R1 with 0x0F = 0000 1111, this gets the least significant nibble (9 = 1001)
                      @ Put result into R1
  MOV R0, R0, LSR #4  @ Right Shift the value in R0 by 4 bits, this is because it was in the most
                      @ significant nibble of the PackedBCD (0101 0000 --> 0000 0101)
                      
  ADD R0, R0, #0x30   @ Add 0x30 (0011 0000) to value in R0 to get ASCII Code for 5
  ADD R1, R1, #0x30   @ Add 0x30 to the value in R1 to get ASCII Code for 9
  NOP                 @ Does nothing, provides a breakpoint marker
  
.end
