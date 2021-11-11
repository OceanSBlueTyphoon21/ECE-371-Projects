@ Design Project 1: Arrays & Procedures
@ Description: This program computes the rounded average of a 16-element temperature
@			   array and store this rounded average in memory. In addition, this program
@			   uses a procedure to determine the maximum and minimum temperature values
@			   of the day (from the 16-element array), the values are returned to mainline
@			   and then stored in memory.
@ Registers Used: R0 - R6
@ Anthony Bruno, November 2021

.text
.global _start
_start:
.equ	NUM, 16
		MOV R4, #NUM			@ Initialize the counter 16
		LDR R1, =TEMPDATA		@ Load pointer to Temperature data array
		LDR R2, =AVERAGE		@ Load pointer to AVERAGE from memory
		MOV R5, #0x00			@ USe R5 to accumulate summation of temperature values
SUM: LDRB R6, [R1], #1			@ Load temp array value, then increment the temp array pointer
		ADD R5, R5, R6			@ Add the temp array element to Sum, store in sum
		SUBS R4, R4, #1			@ Decrement the counter by 1
		BNE SUM					@ Branch back to SUM label if Z flag isn't set
		NOP						@ Instruction for breakpoint, does nothing, for debugging only
		MOVS R5, R5, LSR #4		@ Shift the sum right by 4, divides by 16
		ADC R5, R5, #0x00		@ Round the result with carry flag set
		STRB R5, [R2]			@ store the average byte result at AVERAGE in memory

.data
TEMPDATA:	.byte 0x31, 0x30, 0x30, 0x2F, 0x2F, 0x2E, 0x2E, 0x2E, 0x2E, 0x2D, 0x2D, 0x2D, 0x2D, 0x2C, 0x2A, 0x2A
@ The Data Sample 1 = {49,48,48,47,47,46,46,46,46,45,45,45,45,44,42,42}

AVERAGE:	.byte 0x00
.END