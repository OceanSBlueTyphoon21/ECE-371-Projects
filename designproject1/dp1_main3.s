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
.equ	NUM2, 15
	MOV R4, #NUM					@ Initialize the Counter
	LDR R0, =TEMPDATA				@ Load pointer to TEMPDATA
	LDR R1, =AVERAGE				@ Load pointer to AVERAGE
	LDR R2, =MINVAL					@ Load pointer to MINVAL
	LDR R3, =MAXVAL					@ Load pointer to MAXVAL
	MOV R5, #0x00					@ Initialize the SUM in R5
SUM: LDRB R6, [R0], #1				@ Read byte element from TEMPDATA, increment the pointer
	ADD R5, R5, R6					@ Add the read element to SUM, put result in R5
	SUBS R4, R4, #1					@ Decrement the counter by 1
	BNE SUM							@ Check the counter, branch if counter !=0
	MOVS R5, R5, LSR #4				@ Divide the SUM by 16, update the CPSR
	ADC R5, R5, #0x00				@ Round the average using carry bit
	STRB R5, [R1]					@ Store rounded average byte in memory at AVERAGE
	NOP								@ for Debugging and testing
@ Find the MAX & MIN values in the TEMPDATA array
	MOV R4, #NUM2					@ Initizalize the counter
	LDR R0, =TEMPDATA				@ Re-load the pointer to top of TEMPDATA
	BL MAXMIN						@ Branch to MAXMIN prcedure
	STRB R4, [R3]					@ Store the returned MAX value in memory at MAXVAL
	STRB R5, [R2]					@ Store the returned MIN value in memory at MINVAL
	NOP								@ for Debugging and testing

@ Begin MAXMIN Procedure
MAXMIN: STMFD R13!,{R6-R8, R14}		@ Push the registers to stack, with R14
		LDRB R6, [R0]				@ Initialize the MAX Value in R6
		LDRB R7, [R0]				@ Initialize the MIN Value in R7
NEXT:	LDRB R8, [R0,#1]!			@ Increment the poinrter and then Read a byte element from TEMPDATA
		CMP R8, R6					@ Compare the read element to MAX value
		BHI MAX_UP					@ Branch to MAX_UPDATE if R8 is greater than MAX value
		CMP R8, R7					@ Compare the read element to MIN value
		BLS MIN_UP					@ Branch to MIN_UPDATE if R8 is less than MIN value
		BL FINISH					@ Branch to FINISH if read element is between MAX and MIN value
MAX_UP: MOV R6, R8					@ Update the MAX value to read element
		BL FINISH					@ Branch to FINISH
MIN_UP: MOV R7, R8					@ Update the MIN value to read element
		BL FINISH					@ Branch to FINISH
FINISH: SUBS R4, R4, #1				@ Decrement the counter
		BNE NEXT					@ Branch to NEXT if counter != 0
		MOV R4, R6					@ copy MAX value to R4 for return
		MOV R5, R7					@ copy MIN value to R5 for return
		LDMFD R13!,{R6-R8,PC}		@ Pop the registers off the stack, return to mainline

@ DATA
.data
TEMPDATA:	.byte 0x31, 0x30, 0x30, 0x2F, 0x2F, 0x2E, 0x2E, 0x2E, 0x2E, 0x2D, 0x2D, 0x2D, 0x2D, 0x2C, 0x2A, 0x2A
@ The Data Sample 1 = {49,48,48,47,47,46,46,46,46,45,45,45,45,44,42,42}

@TEMPDATA:	.byte 0x30, 0x33, 0x33, 0x33, 0x34, 0x34, 0x35, 0x37, 0x38, 0x38, 0x3A, 0x39, 0x38, 0x37, 0x37, 0x35
@ The Data Sample 2 = {48,51,51,51,52,52,53,55,56,56,58,57,56,55,55,53}

@TEMPDATA:  .byte 0x34, 0x34, 0x35, 0x34, 0x37, 0x35, 0x33, 0x30, 0x2F, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30
@ The Data Sample 3 = {52,52,53,52,55,53,51,48,47,48,48,48,48,48,48,48}

@TEMPDATA:  .byte 0x30, 0x2F, 0x2E, 0x2F, 0x2E, 0x2F, 0x2F, 0x2F, 0x30, 0x31, 0x33, 0x35, 0x37, 0x37, 0x37, 0x36
@ The Data Sample 4 = {48,47,46,47,46,47,47,47,48,49,51,53,55,55,55,54

AVERAGE:	.byte 0x00
MINVAL:		.byte 0x00
MAXVAL:		.byte 0x00
.end