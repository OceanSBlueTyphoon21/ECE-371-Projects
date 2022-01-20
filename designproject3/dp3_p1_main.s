@ Design Project 3: LED/Timer interrupt program w/ button
@ Description: This program is able to toggle an LED on the BeagleBone Black on a 1 second delay.
@			   The program produces an IRQ request to the processor either from the button being
@			   pushed down or Timer4 going over 1 second. When the button is pressed, the LED0
@			   will toggle on and off on a 1 second delay using Timer4. If the button is pressed
@			   a second time, the LED0 toggling cycle will stop.
@ Registers Used: R0 - R8, R14
@ Anthony Bruno, December 2022
@ Note: this program uses a modified startup_ARMCA8.s file with INT_DIRECTOR

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

@ Turn on GPIO1 Clock Module
	LDR R0, =0x44E000AC			@ load CM_PER_GPIO1_CLKCTRL register address
	MOV R1, #0x02				@ value to turn on GPIO 1 module clock
	STR R1, [R0]				@ write value to CM_PER_GPIO1_CLKCTRL register

	LDR R0, =0x4804C000			@ Base address for GPIO1 Module
@ Setup GPIO1_21 to output LOW
	MOV R2, #0x00200000			@ word to clear GPIO1_21 (LOW)
	ADD R1, R0, #0x190			@ make the GPIO1_CLEARDATAOUT register address
	STR R2, [R1]				@ write word to GPIO1_CLEARDATAOUT

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

@ Enable GPIO1_29 POINTRPEND1 for interrupt
	ADD R2, R0, #0x34			@ make the GPIO1_IRQSTATUS_SET_0 register address
	STR R1, [R2]				@ enable GPIO1_29 request on POINTRPEND1

@ Initialize the INTC
	LDR R1, =0x48200000			@ Base address of INTC
	MOV R2, #0x02				@ Reset Value
	STR R2, [R1,#0x10]				@ write reset to INTC Config register
	MOV R2, #0x04				@ Value to unmask INTC INT# 98 (GPIO1_29)
	STR R2, [R1,#0xE8]			@ write value to INTC_MIR_CLEAR3 register
	MOV R2, #0x10000000			@ value to unmask INTC INT #92 (Timer4)
	STR R2, [R1,#0xC8]			@ Write value to INTC_MIR_CLEAR2 register

@ Turn on Timer2 Clock
	MOV R2, #0x02				@ Value to turn on DMTimer4 clock
	LDR R1, =0x44E00088			@ CM_PER_TIMER4_CLKCTRL address
	STR R2, [R1]				@ write turn on value to Timer4 clock control register

@ Set the Timer2 Clock to the 32.768 KHz clock
	LDR R1, =0x44E00510			@ PRCMCLKSEL_TIMER4 register address
	STR R2, [R1]				@ write value to select 32.768 KHz clock

@ Initialize DMTimer2 (CFG register for reset, (re)-Load register, counter register)
	LDR R1, =0x48044000			@ base address for DMTimer4
	MOV R2, #0x01				@ reset value for timer4
	STR R2, [R1,#0x10]			@ write reset value to Timer4 CFG register
	MOV R2, #0x02				@ value to enable overflow interrupt
	STR R2, [R1,#0x2C]			@ write value to timer4 IRQENABLE_SET
	LDR R2, =0xFFFF8000			@ count value for 1 second
	STR R2, [R1,#0x40]			@ Write count value to Timer4 TLDR register (reloading)
	STR R2, [R1,#0x3C]			@ write count value to Timer4 TCRR register (count up)

@ Enable the IRQ bit in CPSR for processor
	MRS R3, CPSR				@ Copy CPSR to R2
	BIC R3, #0x80				@ clear bit number 7 in CPSR
	MSR CPSR_c, R3				@ write the modified CPSR value back to CPSR

@ ---------------------- WAIT LOOP ------------------------------------------------------
LOOP: 	NOP						@ for debugging & testing
		B LOOP

@ the INTC Director
INT_DIRECTOR: NOP				@ For debugging and testing
	STMFD R13!, {R0-R8, R14}	@ Push registers onto the stack
	LDR R1, =0x482000F8			@ Address of INTC_PENDING_IRQ3 register
	LDR R2, [R1]				@ Read INTC_PENDING_IRQ3 register
	TST R2, #0x00000004			@ Test bit 2 in the read word
	BEQ	TIMERCHK				@ IF the result is 0, then branch to TIMERCHK (Timer4)
	LDR R1, =0x4804C02C			@ ELSE, GPIO1_IRQSTATUS_0 register address
	LDR R2, [R1]				@ read the STATUS register to see the button was pushed
	TST R2, #0x20000000			@ Check if Bit 29 = 1
	BNE BUTTON_SVC				@ IF true, branch to button service (button was pushed)
	LDR R1, =0x48200048			@ ELSE, go back to wait loop. The INTC_CONTROL register address
	MOV R2, #0x01				@ Value to clear bit 0 in INTC_CONTROL register
	STR R2, [R1]				@ write the value to the INTC_CONTROL register
	LDMFD R13!, {R0-R8, R14}	@ Restore the registers
	SUBS PC, LR, #4				@ Pass execution back to WAIT LOOP


TIMERCHK:
	NOP							@ For debugging and testing
	LDR R1, =0x482000D8			@ address for INTC_PENDING_IRQ2 register
	LDR R2, [R1]				@ read value from INTC_PENDING_IRQ2
	TST R2, #0x10000000			@ Check if interrupt from DMTimer4
	BEQ PASS_THRU				@ IF result is 0 (not Timer2), return to WAIT LOOP
	LDR R1, =0x48044028			@ ELSE, check for overflow --> Address of TIMER4_IRQSTATUS register
	LDR R2, [R1]				@ read value from TIMER2_IRQSTATUS register
	TST R2, #0x2				@ Check bit 1 for overflow interrupt generation
	BNE LED						@ If overlow, branch to LED (toggling)
PASS_THRU:
	LDR R1, =0x48200048			@ INTC_CONTROL register address
	MOV R2, #0x01				@ value to clear bit 0
	STR R2, [R1]				@ write to INTC_CONTROL register
	LDMFD R13!, {R0-R8, R14}	@ Restore registers
	SUBS PC, LR, #4				@ Pass execution back to WAIT LOOP


BUTTON_SVC:
	NOP							@ For debugging and testing
	MOV R2, #0x20000000			@ Value to turn off interrrupt from GPIO1_29
	STR R2, [R1]				@ write vlaue to GPIO1_IRQSTATUS register
@ Check button status
	LDR R3, =BUTTON_STATUS		@ Load pointer to BUTTON_STATUS
	LDRB R4, [R3]				@ read a byte from BUTTON_STATUS
	TST R4, #0x01				@ Check button press count
	BEQ LEDON					@ IF 1st time button push, branch to LEDON
	MOV R2, #0x00200000			@ Value turn off LED0
	ADD R1, R0, #0x190			@ GPIO1_CLEARDATAOUT address
	STR R2, [R1]				@ Turn off LED0
	MOV R2, #0x02				@ value to stop the TIMER2
	LDR R1, =0x48044038			@ Address of Timer4 TCLR register
	STR R2, [R1]				@ Write value to stop Timer2
	LDR R2, =0xFFFF8000			@ value for 1 second, re-initalize the count register (TCRR register)
	LDR R1, =0x4804403C			@ Timer4 TCRR (count up) register address
	STR R2, [R1]				@ Re-initializes the count up to 1 second

	MOV R4, #0x00				@ Value to reset the button_status
	STRB R4, [R3]				@ write reset to button_status
@ Turn off NEWIRQ bit in INTC_CONTROL
FINISH:
	LDR R1, =0x48200048			@ INTC_CONTROL register address
	MOV R2, #0x01				@ value to clear bit 0
	STR R2, [R1]				@ write value to INTC_CONTROL register
	LDMFD R13!, {R0-R8, R14}	@ restore registers
	SUBS PC, LR, #4				@ Pass execution back to WAIT LOOP

LEDON:
	NOP							@ For debugging and testing
	MOV R2, #0x00200000			@ value to turn on LED0
	ADD R1, R0, #0x194			@ GPIO1_SETDATAOUT register address
	STR R2, [R1]				@ write value to turn on LED0
	MOV R2, #0x03				@ value to auto-reload timer2 and start Timer2
	LDR R1, =0x48044038			@ Timer4 TCLR register address
	STR R2, [R1]				@ write value to Timer4 TCLR register

	MOV R4, #0x01				@ value to set the button_status
	STRB R4, [R3]				@ write set value to button_status
	B FINISH					@ branch to finish


LED:
	NOP							@ For debugging and testing
@ Turn off Timer4 interrupt request
	LDR R1, =0x48044028			@ Timer4 IRQSTATUS register address
	MOV R2, #0x02				@ value to reset Timer4 IRQSTATUS register
	STR R2, [R1]				@ write value to reset Timer4_IRQSTATUS register
@ Toggle the LED
	LDR R2, [R0,#0x13C]			@ read value from GPIO1_DATAOUT
	TST R2, #0x00200000			@ check bit 21
	MOV R2, #0x00200000			@ Value to clear or set GPIO1_21 (LED0)
	BNE LEDOFF					@ LED is ON, turn it OFF
	STR R2, [R0,#0x194]			@ LED if OFF, turn it ON with GPIO1_SETDATAOUT
BACK:							@ Go back to WAIT LOOP
	LDR R1, =0x48200048			@ INTC_CONTROL register address
	MOV R2, #0x01				@ value to enable new IRQ response
	STR R2, [R1]				@ write value to enable new IRQ response
	LDMFD R13!, {R0-R8, R14}	@ Restore registers
	SUBS PC, LR, #4				@ Pass execution back to WAIT LOOP

LEDOFF:
	NOP							@ For Debuggin and testing
	STR R2, [R0,#0x190]			@ Turn off LED0 with GPIO1_CLEARDATAOUT
	B BACK						@ Go back to WAIT LOOP

.data
.align 2						@ for aligment in memory
STACKSVC:	.rept 1024
			.word 0x0000
			.endr
STACKIRQ:	.rept 1024
			.word 0x0000
			.endr

BUTTON_STATUS:	.byte 0x00
.END
