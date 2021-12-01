@ Design Project 1: Interrupts & GPIOs - USR LEDs cycling pattern
@ Description: This program cycles through the USR LEDs on the BBB board.
@			   The program utilizes MVN for inverting and registers
@ Registers Used: R0-R5, R8
@ Anthony Bruno, November 2021

.text
.global _start
_start:
.equ NUM, 3
		MOV R0, #0x02			@ value to enable the GPIO clocks
		LDR R1, =0x44E000AC		@ Address of CM_PER_GPIO1_CLKCRTL register
		STR R0, [R1]			@ write enable value to GPIO1_clk register address
								@ This turns on the CLK to the GPIO 1 module

@ BASE ADDRESS OF GPIO1 MODULE
		LDR R0, =0x4804C000		@ base address of GPIO1 Module

@ Configure the 4 USR LED GPIOs as LOW
		MOV R1, #0x01E00000		@ value to output LOW on GPIOs 21-24
		ADD R2, R0, #0x190		@ make the GPIO1_CLEARDATAOUT register address
		STR R1, [R2]			@ Write the LOW value to GPIO_CLEARDATAOUT register

		NOP						@ For Debugging

@ Configure GPIO1_21 as HIGH
		MOV R4, #0x00200000		@ word value to output HIGH for GPIO1_21
		ADD R2, R0, #0x194		@ make the GPIO1_SETDATAOUT register address
		STR R4, [R2]			@ Write the HIGH value word to GPIO1_SETDATAOUT

		NOP						@ for Debugging

@ Configure the 4 USR LED GPIOs as OUTPUT
		ADD R2, R0, #0x134		@ Make the GPIO1_OE register address
		MOV R1, #0xFE1FFFFF		@ Word to enable GPIO 21 - 24 as outputs
		LDR R3,[R2]				@ READ the current value from GPIO1_OE register
		AND R3, R1, R3			@ MODIFY the value with the enable word
		STR R3, [R2]			@ WRITE the modified word back to GPIO1_OE register

		NOP						@ For Debugging

@ WHILE - DO LOOP
F_LOOP:	MOV R5, #NUM			@ setup the loop counter

@ cycle up
CYCUP:	LDR R8, =0x003FFFFF		@ delay loop total (~1 sec)
		BL LOOP					@ branch/link to loop
		MOV R4, R4, LSL #1		@ Logic shift left by 1 bit
	@ SET the next LED GPIO to HIGH
		ADD R2, R0, #0x194		@ make the GPIO1_SETDATAOUT register address
		STR R4, [R2]			@ Write the HIGH value word to GPIO1_SETDATAOUT
	@ CLEAR the other LED GPIOs
		MVN R6, R4				@ invert R4 word value
		ADD R2, R0, #0x190		@ make the GPIO1_CLEARDATAOUT
		STR R6, [R2]			@ write the modified word to GPIO1_CLEARDATAOUT

		SUBS R5, R5, #1			@ decrement the counter
		NOP						@ for debugging
		BNE CYCUP
		NOP						@ for Debugging
		MOV R5, #NUM			@ re-initialize counter

@ cycle down
CYCDW:	LDR R8, =0x003FFFFF		@ delay loop total (~1 sec)
		BL LOOP					@ branch/link to loop
		MOV R4, R4, LSR #1		@ Logic shift left by 1 bit
	@ SET the next LED GPIO to HIGH
		ADD R2, R0, #0x194		@ make the GPIO1_SETDATAOUT register address
		STR R4, [R2]			@ Write the HIGH value word to GPIO1_SETDATAOUT
	@ CLEAR the other LED GPIOs
		MVN R6, R4					@ invert R4 word value
		ADD R2, R0, #0x190		@ make the GPIO1_CLEARDATAOUT
		STR R6, [R2]			@ write the modified word to GPIO1_CLEARDATAOUT

		SUBS R5, R5, #1			@ decrement the counter
		NOP						@ for debugging
		BNE CYCDW
		NOP						@ For debugging
		B F_LOOP

@ Delay loop
LOOP:	NOP
		SUBS R8, R8, #1			@ Decrement loop counter
		BNE LOOP				@ Branch to loop counter
		MOV PC, R14				@ Branch back to mainline

