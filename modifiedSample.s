@ Array Multiply Program
@ This program multiples each half word from the Multiplicands
@ array by the same numbered half word in the Multipliers array and
@ puts the result in the same numbered element PRODUCTS array/
@ Registers Used: R1-R4, R6-R8
@ This program is a modified version of the Multo.s program
@ it uses a special better way to increment the pointers.
@ Anthony Bruno October 2021

.text
.global _start
_start:
.equ	NUM, 4
		LDR R1, =MULTIPLICANDS		@ Load pointer to MULTIPLICANDS array
		LDR R2, =MULTIPLIERS		@ Load pointer to MULTIPLIERS array
		LDR R3, =PRODUCTS		@ Load pointer to PRODUCTS array
		MOV R4, #NUM			@ Initialize loop counter

NEXT:	LDRH R6, [R1], #2			@ Load a MULTIPLICAND half word into R6, then increment address
		LDRH R7, [R2], #2		@ Load a MULTIPLIER half word into R7, then increment address
		MUL R8, R6, R7			@ Multiply the halfwords loaded into R6 & R7
		STR R8, [R3], #4		@ Store result in PRODUCTS array, then increment address
		SUBS R4, #1			@ Decrement loop counter by 1 (4 elements, thus 4 loops)
		BNE NEXT			@ Go to NEXT if all elements haven't been multiplied (in this case 4 elements)
		NOP				@ Instruction for breakpoint. Does nothing

.data
MULTIPLICANDS: 	.HWORD 0x1111, 0x2222, 0x3333, 0x4444
MULTIPLIERS: 	.HWORD 0x1111, 0x2222, 0x3333, 0x4444
PRODUCTS:	.WORD 0x0, 0x0, 0x0, 0x0
.END
