@ PackedBCD to ASCII Codes
@ Anthony Bruno - November 2021

.text
.global _start
_start:
	MOV R0, #0x59
	MOV R1, R0
	AND R0, R0, #0xF0
	AND R1, R1, #0x0F
	MOV R0, R0, LSR #4
	ADD R0, R0, #0x30
	ADD R1, R1, #0x30
	NOP

.end
