@ Design Project 1: Interrupts & GPIOs - Button Interrupt
@ Description: This program turns on LED0 on the BBB Board for 1 second
@			   in response to an interrupt from an external push button
@			   on GPIO1_29. Specifically, when GPIO1_29 detects a falling edge
@			   this program signals an IRQ request to the processor and then
@			   uses our written INT_DIRECTOR to direct execution to our written
@			   BUTTON_SVC procedure to turn on LED0 for 1 second on the BBB Board.
@ Registers Used: R0 - R5, R14
@ Anthony Bruno, December 2021

.text
.global _start
.global INT_DIRECTOR			@ accessible by startup_ARMCA8.s file
_start:
@ stack setup for SVC and IRQ
	LDR R13, =STACKSVC			@ load SP to base of SVC STACK
	ADD R13, R13, #0x1000		@ put the SP to the top of the SVC STACK
	CPS #0x12					@ switch mode to IRQ mode
	LDR R13, =STACKIRQ			@ load SP to base of IRQ STACK
	ADD R13, R13, #0x1000		@ put the SP to the top of the IRD STACK
	CPS #0x13					@ return mode to SVC mode
@ Turn on Clock to GPIO 1 module
	LDR R0, =0x44E000AC			@ load CM_PER_GPIO1_CLKCTRL register address
	MOV R1, #0x02				@ value to turn on GPIO 1 module clock
	STR R1, [R0]				@ write value to CM_PER_GPIO1_CLKCTRL register
@ Setup GPIO1_21 to output LOW
	LDR R0, =0x4804C000			@ BASE ADDRESS FOR GPIO 1 MODULE
	MOV R1, #0x00200000			@ word to clear GPIO1_21 (LOW)
	ADD R2, R0, #0x190			@ make the GPIO1_CLEARDATAOUT register address
	STR R1, [R2]				@ write word to GPIO1_CLEARDATAOUT
@ Setup GPIO1_21 as OUTPUT (RMW)
	LDR R1, =0xFFDFFFFF			@ word to setup GPIO1_21 as OUTPUT
	ADD R2, R0, #0x134			@ make the GPIO1_OE register address
	LDR R3, [R2]				@ READ word from GPIO1_OE register
	AND R3, R3, R1				@ MODIFY the stored word in GPIO1_OE register
	STR R3, [R2]				@ WRITE the new modified word to GPIO1_OE register
@ Setup GPIO1_29 to detect falling edge, enable GPIO1_29 to assert POINTRPEND1
	MOV R1, #0x20000000			@ word to enable falling edge on GPIO1_29
	ADD R2, R0, #0x14C			@ make the GPIO1_FALLINGDETECT register address
	LDR R3, [R2]				@ READ word from GPIO1_FALLINGDETECT
	ORR R3, R3, R1				@ MODIFY the word from GPIO1_FALLINGDETECT
	STR R3, [R2]				@ WRITE the modified word to GPIO1_FALLINGDETECT

	ADD R2, R0, #0x34			@ make the GPIO1_IRQSTATUS_SET_0 register address
	STR R1, [R2]				@ enable GPIO1_29 request on POINTRPEND1

@ Initialize the INTC
	MOV R1, #0x04				@ value to unmask INTC INT 98, GPIOINT1A
	LDR R2, =0x482000E8			@ address of INTC_MIR_CLEAR3 register
	STR R1, [R2]				@ write the value to unmask INTC INT 98

@ Enable the IRQ bit in CPSR
	MRS R2, CPSR				@ Copy CPSR to R2
	BIC R2, #0x80				@ clear bit number 7 in CPSR
	MSR CPSR_c, R2				@ write the modified CPSR value back to CPSR
	NOP							@ For Debugging and testing
@ Mainline Wait LOOP: Wait for an interrupt from GPIO1_29 via external push button
LOOP: 	NOP						@ for debugging & testing
		B LOOP

@ the INTC Director
INT_DIRECTOR: NOP				@ For debugging and testing
	STMFD R13!, {R0-R5, R14}	@ Push registers onto the IRQ STACK
	LDR R0, =0x482000F8			@ load INTC_PENDING_IRQ3 register address
	LDR R1, [R0]				@ read word from INTC_PENDING_IRQ3
	TST R1, #0x00000004			@ TST bit 2 in the INTC_PENDING_IRQ3 word, check for GPIOINT1A signal
	BEQ RETURN					@ IF no signal  --> Pass execution back to LOOP
	LDR R0, =0x4804C02C			@ load the address of GPIO1_IRQSTATUS_0 register
	LDR R1, [R0]				@ Read word from GPIO1_IRQSTATUS_0
	TST R1, #0x20000000			@ TST bit 29, check for GPIO1_29 interrupt requested
	BNE BUTTON_SVC				@ IF GPIO1_29 interrupt requested, go to BUTTON_SVC
	BEQ RETURN					@ ELSE --> Pass execution back to LOOP

@ to return back to mainline wait loop
RETURN:
	LDMFD R13!, {R0-R5, R14}	@ Pop registers off the IRQ STACK
	SUBS PC, R14, #4			@ Pass execution back to Mainline wait LOOP

@ Push button service procedure
BUTTON_SVC: NOP					@ For debugging and testing
	MOV R1, #0x20000000			@ word to turn off INTC IRQ request
	LDR R0, =0x4804C02C			@ load the GPIO1_IRQSTATUS_0 register address
	STR R1, [R0]				@ Write word to turn off INTC IRQ request
	MOV R1, #0x01				@ value to turn off NEWIRQ bit in INTC_CONTROL register
	LDR R0, =0x48200048			@ address of INTC_CONTROL register
	STR R1, [R0]				@ Write value to Turn off NEWIRQ bit in INTC_CONTROL register

	@ LED0 Toggling (GPIO1_21), HIGH
	LDR R0, =0x4804C194			@ Address of GPIO1_SETDATAOUT control register
	MOV R1, #0x00200000			@ value to toggle GPIO1_21
	STR R1, [R0]				@ Write value to GPIO1_SETDATAOUT

	@ Delay loop
	LDR R5, =0x002FFFFF			@ ~ 1 second for delay loop
DELAY:	NOP
		SUBS R5, R5, #1
		BNE DELAY

	@ LED0 Toggling, LOW
	LDR R0, =0x4804C190			@ address of GPIO1_CLEARDATAOUT control register
	STR R1, [R0]				@ Write value to GPIO1_CLEARDATAOUT

	@ return execeution to mainline wait loop and restore the registers.
	LDMFD R13!, {R0-R5, R14}	@ Pop registers off the STACK
	SUBS PC, R14, #4			@ pass execution back to mainline wait loop

.data
.align 2						@ for aligment in memory
STACKSVC:	.rept 1024
			.word 0x0000
			.endr
STACKIRQ:	.rept 1024
			.word 0x0000
			.endr
.END
