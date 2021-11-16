@ Design Project 1: Arrays & Procedures
@ Description: This program computes the rounded average of a 16-element temperature
@			   array and store this rounded average in memory. In addition, this program
@			   uses a procedure to determine the maximum and minimum temperature values
@			   of the day (from the 16-element array), the values are stored in memory.
@ Registers Used: R0 - R8
@ Anthony Bruno, November 2021

.text
.global _start
_start:
.equ	NUM, 16
		LDR R13, =STACK			@ Load the SP to the STACK
		ADD R13, R13, #0x100	@ Move the SP to the TOS
		MOV R4, #NUM			@ Initialize the counter to 16
		LDR R0, =TEMPDATA		@ Load pointer to TEMPDATA
		LDR R1, =AVERAGE		@ Load pointer to AVERAGE
		LDR R2, =MINVAL			@ Load pointer to MINVAL
		LDR R3, =MAXVAL			@ Load pointer to MAXVAL
		MOV R5, #0x00			@ Initialize the sum to 0 in R5
SUM: 	LDRB R6, [R0], #1		@ Load byte data from TEMPDATA into R6, Incrememt the pointer
		ADD R5, R5, R6			@ Add the byte data to the sum, put result in sum
		SUBS R4, R4, #1			@ Decrement the counter, update the CPSR
		BNE SUM					@ Branch to SUM if Z flag is set
		MOVS R5, R5, LSR #4		@ Divide the sum by 16, update the CPSR
		ADC R5, R5, #0x00		@ Round the result in R5 with carry flag
		STRB R5, [R1]			@ Store the result in AVERAGE
		NOP						@ For Debugging

		MOV R4, #NUM			@ Re-initialize the counter to 16
		LDR R0, =TEMPDATA		@ Reload the pointer to top of TEMPDATA
		BL MAXMIN				@ Branch to MAXMIN procedure
		NOP						@ For debugging
		STRB R4, [R3]			@ Store Maximum value in MAXVAL
		STRB R5, [R2]			@ Store Minimum value in MINVAL
		NOP						@ For Debugging

MAXMIN:	STMFD R13!,{R6-R8,R14}	@ Push R6-R8, R14 onto the STACK
		LDRB R6, [R0]			@ Load the first element in TEMPDATA to R6
		LDRB R7, [R0]			@ Load the first element in TEMPDATA to R7, could also use MOV
NEXT:	LDRB R8, [R0], #1		@ Load a byte from TEMPDATA into R8, Increment the pointer
		CMP R8, R6				@ Compare the TEMPDATA byte to Maximum Value
		BHI MAXUP				@ Branch to MAXUP if R8 > R6
		CMP R8, R7				@ Compare the TEMPDATA byte to Minimum Value
		BLS MINUP				@ Branch to MINUP if R8 < R7
		BL FINISH				@ Branch to FINISH if R7 < R8 < R6
MAXUP:	MOV R6, R8				@ Copy R8 into R6
		BL FINISH				@ Branch to FINISH
MINUP:	MOV R7, R8				@ Copy R8 into R7
		BL FINISH				@ Branch to FINISH, not really necessary
FINISH:	SUBS R4, R4, #1			@ Decrement the counter by 1, update the CPSR
		BNE NEXT				@ Branch to NEXT if Z flag is set
		MOV R4, R6				@ copy R6 into R4
		MOV R5, R7				@ copy R7 into R5
		NOP						@ For Debugging
		LDMFD R13!,{R6-R8,R14}	@ Pop R6-R8, R14 off the STACK
		MOV PC, R14				@ Copy R14 into PC to return to mainline


.data
TEMPDATA:	.byte 0x31, 0x30, 0x30, 0x2F, 0x2F, 0x2E, 0x2E, 0x2E, 0x2E, 0x2D, 0x2D, 0x2D, 0x2D, 0x2C, 0x2A, 0x2A
STACK:		.rept 256
			.byte 0x00
			.endr

AVERAGE:	.byte 0x00
MINVAL:		.byte 0x00
MAXVAL:		.byte 0x00
.end
