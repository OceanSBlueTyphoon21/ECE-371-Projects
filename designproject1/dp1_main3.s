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
	MOV R4, #NUM
	LDR R0, =TEMPDATA
	LDR R1, =AVERAGE
	LDR R2, =MINVAL
	LDR R3, =MAXVAL
	MOV R5, #0x00
SUM: LDRB R6, [R0], #1
	ADD R5, R5, R6
	SUBS R4, R4, #1
	BNE SUM
	MOVS R5, R5, LSR #4
	ADC R5, R5, #0x00
	STRB R5, [R1]
	NOP
@ Find the MAX & MIN values in the TEMPDATA array
	MOV R4, #NUM
	LDR R0, =TEMPDATA
	BL MAXMIN
	STRB R4, [R3]
	STRB R5, [R2]
	NOP

@ Begin MAXMIN Procedure
MAXMIN: STMFD R13!,{R6-R8, R14}
		MOV R6, #0x00				@ R6 holds the max value
		MOV R7, #0x7D					@ R7 holds the min value
NEXT:	LDRB R8, [R0], #1			@ increment by 1 on pointer and then load value
		CMP R8, R6					@ compare, R6-R8
		BHI MAX_UP
		CMP R8, R7
		BLS MIN_UP
		BL FINISH
MAX_UP: MOV R6, R8
		BL FINISH
MIN_UP: MOV R7, R8
		BL FINISH
FINISH: SUBS R4, R4, #1
		BNE NEXT
		MOV R4, R6
		MOV R5, R7
		LDMFD R13!,{R6-R8,PC}
		NOP

.data
TEMPDATA:	.byte 0x31, 0x30, 0x30, 0x2F, 0x2F, 0x2E, 0x2E, 0x2E, 0x2E, 0x2D, 0x2D, 0x2D, 0x2D, 0x2C, 0x2A, 0x2A
@ The Data Sample 1 = {49,48,48,47,47,46,46,46,46,45,45,45,45,44,42,42}

AVERAGE:	.byte 0x00
MINVAL:		.byte 0x00
MAXVAL:		.byte 0x00
.end