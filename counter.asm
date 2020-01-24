		LIST P=16F747
		title "Counting program"
;***********************************************************
;
; This program runs on the Mechatronics microcomputer board.
; On this microcomputer board, Port D is connected to 8 LEDs.
; Port C is connected to 2 switches, both of which will be used.
; This program increments a file register Count every time
; the green pushbutton switch (PortC pin 0) is pressed.
; The program decrements the file register Count every time
; the red pushbutton switch (PortC pin 1) is pressed.
; The value of Count is displayed on the LEDs connected
; to Port D.
;
; (Note: when entered correctly, this progran will generate 2
; messages in the Assembler.)
;
; The net result is that LEDs should increment or decrement
; in a binary manner every time a switch is pressed.
;
;
; State register (not used)
; bit 0
; bit 1
; bit 2
; bit 3
; bit 4
; bit 5
; bit 6
; bit 7
;
;***********************************************************
		#include <P16F747.INC>
	__CONFIG _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
	__CONFIG _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF

; Note: the format for the CONFIG directive starts with a double underscore.
; The above directive sets the oscillator to an external high speed clock,
; sets the watchdog timer off, sets the power up timer on, sets the system
; clear on (which enables the reset pin) and turns code protect off.
; Variable declarations

Count 	equ 	20h 			; the counter
Temp 	equ 	21h 			; a temporary register
State 	equ 	22h 			; the program state register

		org 	00h 			; Assembler directive - Reset Vector

		goto 	initPort
		org		04h 			; interrupt vector
		goto 	isrService 		; jump to interrupt service routine (dummy)
 		org 	15h 			; Beginning of program storage
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; Port Initialization
initPort
		clrf 	PORTD 			; Clear Port D output latches
		clrf 	PORTC 			; Clear Port C output latches
		bsf 	STATUS,RP0 		; Set bit in STATUS register for bank 1
		movlw 	B'11111111' 	; move hex value FF into W register
		movwf 	TRISC 			; Configure Port C as all inputs
		clrf 	TRISD 			; Configure Port D as all outputs
		bcf 	STATUS,RP0 		; Clear bit in STATUS register for bank 0
		clrf 	Count 			; zero the counter
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;

waitPress
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress 		; green button is pressed - goto routine
		btfsc 	PORTC,1 		; see if red button pressed
		goto 	RedPress 		; red button is pressed - goto routine
		goto 	waitPress 		; keep checking

GreenPress
		btfss 	PORTC,0 ; see if green button still pressed
		goto 	waitPress ; noise - button not pressed - keep checking

GreenRelease
		btfsc 	PORTC,0 ; see if green button released
		goto 	GreenRelease ; no - keep waiting
		call 	SwitchDelay ; let switch debounce
		goto 	IncCount ; increment the counter

RedPress
		btfss 	PORTC,1 ; see if red button still pressed
		goto 	waitPress ; noise - button not pressed - keep checking

RedRelease
		btfsc 	PORTC,1 ; see if red button released
		goto 	RedRelease ; no - keep waiting
		call 	SwitchDelay ; let switch debounce
		decf 	Count,F ; decrement count - store in register
		goto 	outCount ; output the count on the PORTD LEDs

IncCount
		incf 	Count,F ; increment count - store in register

outCount
		movf 	Count,W ; move the count to the W register
		movwf 	PORTD ; display count on port D
		goto 	waitPress ; wait for next button press

SwitchDelay
		movlw 	D'2' ; load Temp with decimal 20
		movwf 	Temp

delay
		decfsz 	Temp, F ; 60 usec delay loop
		goto 	delay ; loop until count equals zero
		return 			; return to calling routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Note: this is a dummy interrupt service routine. It is good programming
; practice to have it. If interrupts are enabled (which they should not be)
; and if an interrupt occurs (which should not happen), this routine safely
; hangs up the microcomputer in an infinite loop.

isrService
		goto 	isrService ; error - stay here
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
		END ; Assembler directive - end of program
