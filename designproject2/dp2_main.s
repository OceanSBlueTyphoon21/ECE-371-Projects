@ Design Project 1: Interrupts & GPIOs - USR LED0 ON/OFF
@ Description: This program simply turns on the USR LED0 ON/OFF Indefinately
@ Registers Used: R0-R3, R8
@ Anthony Bruno, November 2021

.text
.global _start
_start:	MOV R0, #0x02			@ value to enable the GPIO clocks
		LDR R1, =0x44E000AC		@ Address of CM_PER_GPIO1_CLKCRTL register
		STR R0, [R1]			@ write enable value to GPIO1_clk register address

@ BASE ADDRESS OF GPIO1 MODULE
		LDR R0, =0x4804C000		@ base address of GPIO1 Module

@ Configure the 4 USR LED GPIOs as LOW
		MOV R1, #0x01E00000		@ value to output LOW on GPIOs 21-24
		ADD R2, R0, #0x190		@ make the GPIO1_CLEARDATAOUT register address
		STR R1, [R2]			@ Write the LOW value to GPIO_CLEARDATAOUT register

		NOP						@ For Debugging

@ Configure the 4 USR LED GPIOs as OUTPUT
		ADD R2, R0, #0x134		@ Make the GPIO1_OE register address
		MOV R1, #0xFE1FFFFF		@ Word to enable GPIO 21 - 24 as outputs
		LDR R3,[R2]				@ READ the current value from GPIO1_OE register
		AND R3, R1, R3			@ MODIFY the value with the enable word
		STR R3, [R2]			@ WRITE the modified word back to GPIO1_OE register

		NOP						@ For Debugging

@ WHILE - DO LOOP
F_LOOP:	@ wait 1 second
		LDR R8, =0x003FFFFF		@ delay loop total
		BL LOOP					@ branch/link to loop
		NOP						@ For Debugging
		@ Configure GPIO1_21 to HIGH
		MOV R1, #0x00200000		@ value to output HIGH on GPIO1_21
		ADD R2, R0, #0x194		@ make the GPIO1_SETDATAOUT register address
		STR R1, [R2]			@ Write the value to GPIO1_SETDATAOUT register
		NOP						@ For Debugging
		@ wait 1 second
		LDR R8, =0x003FFFFF		@ delay loop total
		BL LOOP					@ branch/link to loop
		NOP						@ For Debugging
		@ Configure GPIO1_21 to LOW
		MOV R1, #0x00200000		@ value to output LOW on GPIO1_21
		ADD R2, R0, #0x190		@ make the GPIO1_CLEARDATAOUT register address
		STR R1, [R2]			@ Write the value to GPIO1_CLEARDATAOUT register
		NOP						@ For Debugging
		B F_LOOP

@ Delay loop
LOOP:	NOP
		SUBS R8, R8, #1			@ Decrement loop counter
		BNE LOOP					@ Branch to loop counter
		MOV PC, R14				@ Branch back to mainline

