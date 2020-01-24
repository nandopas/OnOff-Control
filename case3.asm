		LIST P=16F747
		title "Case 3, Group 7"
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
State 	equ 	21h 			; the program state register
Octal	equ		22h				; the octal switch register
Temp1 	equ 	23h 			; temporary register 1
Temp2	equ		24h				; temporary register 2
Timer0	equ		25h
Timer1	equ		26h
Timer2	equ		27h

		org 	00h				; Assembler directive - Reset Vector

		goto 	initPort		; initiate ports
		org		04h				; interrupt vector
		goto 	isrService		; jump to interrupt service routine (dummy)
 		org 	15h				; Beginning of program storage
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; Port Initialization
initPort
		clrf	PORTE			; Clear Port E output latches
		clrf 	PORTD			; Clear Port D output latches
		clrf 	PORTC			; Clear Port C output latches
		clrf	PORTB			; Clear Port B output latches
		bsf 	STATUS,RP0		; Set bit in STATUS register for bank 1
		movlw 	B'11111111'		; move hex value FF into W register
		movwf 	TRISC			; Configure Port C as all inputs
		movlw	B'00000111'		; Configure pin 0, 1 and 2 of PORTE as inputs
		movwf 	TRISE			; Configure Port E as all inputs
		movlw	B'11110010'		; move binary value 11110010 into W regiter
		movwf 	TRISD			; Configure pin 0,2,3 of Port D as outputs and others inputs
		clrf 	TRISB			; Configure Port B as all outputs
		bcf 	STATUS,RP0		; Clear bit in STATUS register for bank 0
		call 	initAD 			; call to initialize A/D
		call	SetupDelay		; delay for Tad (see data sheet) prior to A/D start
		clrf 	Count			; zero the counter
		bsf		ADCON0,GO		; start A/D conversion
		goto	waitPress		; wait for button to be pressed

;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
; Initializes and sets up the A/D hardware
initAD
		bsf 	STATUS,RP0 		; select register bank 1
		movlw 	B'00001010' 	; RA0,RA1,RA3 analog inputs, all other digital
		movwf 	ADCON1 			; move to special function A/D register
		bcf 	STATUS,RP0 		; select register bank 0
		movlw 	B'01000001' 	; select 8 * oscillator, analog input 0, turn on
		movwf 	ADCON0			; move to special function A/D register
		return
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Mode1234
		movf	PORTE,W			; read PORTE
		movwf	Octal			; move to Octal
		
		bsf		Octal,7			; set pin 3 to 7 of Octal to 1
		bsf		Octal,6
		bsf		Octal,5
		bsf		Octal,4
		bsf		Octal,3

		comf	Octal,W			; complement the value of Octal
		movwf	Octal			; move back to Octal

		decfsz	Octal,F			; decrement Octal
		goto	Mode234			; if not 0, check if mode 2, 3 or 4
		goto	Mode1			; if 0, go to mode 1

Mode234
		decfsz	Octal,F			; decrement Octal
		goto	Mode34			; if not 0, check if mode 3 or 4
		goto	Mode2			; if 0, go to mode 2

Mode34
		decfsz	Octal,F			; decrement Octal
		goto	Mode4			; if 0, go to mode 4 or error
		goto	Mode3			; if 0, go to mode 3



Mode1
		clrf 	PORTB 			; clear the mode led
		bsf 	PORTB,0 		; set led bit
		goto	waitPress1		; start mode 1


Mode2
 		clrf 	PORTB 			; clear the mode led
		bsf 	PORTB,1 		; set led bit
		goto 	waitPress2		; start mode 2


Mode3
        clrf 	PORTB 			; clear the mode led
        bsf 	PORTB,0 		; set led bit
		bsf 	PORTB,1 		; set led bit
		goto	waitPress3		; start mode 3


Mode4
		clrf 	PORTB 			; clear the mode led
		bsf 	PORTB,2 		; set led bit
		decfsz	Octal,F			; decrement Octal
		goto	ProgramError	; if not 0, indicate error
		goto	waitPress4		; if 0, start mode 4

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitPress
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress 		; green button is pressed - goto routine
		goto	waitPress		; loop until green button is pressed

GreenPress
		call	MainOff			; turn off main transistor
		btfss 	PORTC,0 		; see if green button still pressed
		goto 	waitPress 		; noise - button not pressed - keep checking

GreenRelease
		btfsc 	PORTC,0 		; see if green button released
		goto 	GreenRelease 	; no - keep waiting
		call 	SwitchDelay 	; let switch debounce
		goto 	Mode1234 		; choose the mode

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitPress1
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress 		; green button is pressed - goto routine
		btfsc 	PORTC,1 		; see if red button pressed
		goto 	RedPress1		; red button is pressed - goto routine
		goto 	waitPress1 		; keep checking

RedPress1
		btfss 	PORTC,1 		; see if red button still pressed
		goto 	waitPress1 		; noise - button not pressed - keep checking

RedRelease1
		btfsc 	PORTC,1 		; see if red button released
		goto 	RedRelease1		; no - keep waiting
		call 	SwitchDelay 	; let switch debounce
		btfss	PORTD,2			; check if main transistor on
		goto	MainOn1			; if not, turn on main transistor
		goto	MainOff1		; if on, turn off main transistor

MainOn1
		call	MainOn			; turn on main transistor
		goto	waitPress1		; wait for next button press

MainOff1
		call	MainOff			; turn off main transistor
		goto	waitPress1		; wait for next button press

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


waitPress2 						; wait press for mode2
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress		; green button is pressed - goto routine
		btfsc 	PORTC,1 		; see if red button pressed
		goto 	RedPress2		; red button is pressed - goto routine
		goto 	waitPress2 		; keep checking

RedPress2
		btfss 	PORTC,1 		; see if red button still pressed
		goto 	waitPress2 		; noise - button not pressed - keep checking

RedRelease2
		btfsc 	PORTC,1 		; see if red button released
		goto 	RedRelease2		; no - keep waiting
		call 	SwitchDelay 	; let switch debounce
		btfsc	ADCON0,GO 		; check A/D is finished - dont think this goes here
		goto	RedRelease2		; loop right here until A/D finished
		movf 	ADRESH,W 		; get A/D value
		movwf	Temp1			; move A/D value to temp register
		; fault indication
		incf 	Temp1	 		; increment the value to test for control pot 0
		call 	ZeroError 		; control pot is 0, display error
		call	MainOn			; turn on main transistor
		bcf		STATUS,C		; clear status bit
		rrf		Temp1,W			; divided by 2
		movwf	Temp1			; move the value back to Temp1
		bcf		STATUS,C		; clear status bit
		rrf		Temp1,W			; divided by 2
		movwf	Temp1			; move the value back to Temp1
		call 	delay2 			; go to delay (count down)
		call	MainOff			; turn off main transistor
		goto 	waitPress2 		; wait for next button press

RedPress2Check
		btfss 	PORTC,1 		; see if red button still pressed
		return 					; button not pressed - return to delay timer
		goto 	RedRelease2 	; restart the timer reading

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


waitPress3
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress		; green button is pressed - goto routine
		btfsc 	PORTC,1 		; see if red button pressed
		goto 	RedPress3		; red button is pressed - goto routine
		goto 	waitPress3 		; keep checking

RedPress3
		btfss 	PORTC,1 		; see if red button still pressed
		goto 	waitPress3 		; noise - button not pressed - keep checking

RedRelease3
		btfsc 	PORTC,1 		; see if red button released
		goto 	RedRelease3		; no - keep waiting
		call 	SwitchDelay 	; let switch debounce
		call	LEDOn			; turn LED on

ReadAD
		bsf		ADCON0,GO		; start A/D conversion
		btfsc	ADCON0,GO 		; check A/D is finished
		goto	ReadAD
		btfsc	ADCON0,GO 		; check A/D is finished
		goto	ReadAD
		movf 	ADRESH,W 		; get A/D value
		movwf	Temp1			; move A/D value to temp register
		; fault indication
		incf 	Temp1	 		; increment the value to test for control pot 0
		call 	ZeroError 		; control pot is 0, display error
		goto	checkGreater	; 
		goto 	waitPress3 		; wait for next button press

checkGreater
		movlw 	71h 			; move value 71h to W register
		subwf  	Temp1,1	  		; subtract w register from f register (f-W) and move result to Temp1
		btfsc	Temp1,7			; check the negative bit MSB, if 0 (positive) skip next instruction
		goto	MainOff3		; turn off transistor
		call	MainOn			; turn on transistor
		goto 	RedPress32		; go to the other RedPress for mode 3

MainOff3
		call	MainOff
		goto	RedPress32


RedPress32
		btfss 	PORTC,1 		; see if red button pressed
		goto 	ReadAD 		 	; noise - button not pressed - go back to reading A/D value

RedRelease32
		btfsc 	PORTC,1 		; see if red button released
		goto 	RedRelease32	; no - keep waiting
		call 	SwitchDelay 	; let switch debounce
		call	MainOff			; turn off transistor
		call	LEDOff			; turn off LED
		goto	waitPress3		; return back to waiting for green or red press

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


waitPress4
		btfsc	PORTC,0 		; see if green button pressed
		goto 	GreenPress 		; green button is pressed - goto routine
		btfsc 	PORTC,1 		; see if red button pressed
		goto 	RedPress4		; red button is pressed - goto routine
		goto 	waitPress4 		; keep checking

RedPress4
		btfss 	PORTC,1 		; see if red button still pressed
		goto 	waitPress4 		; noise - button not pressed - keep checking

RedRelease4
		btfsc 	PORTC,1 		; see if red button released
		goto 	RedRelease4		; no - keep waiting
		incf 	Count 			; increment the Reset Counter
		call 	SwitchDelay 	; let switch debounce

ReadAD4
		bsf		ADCON0,GO		; start A/D conversion
		btfsc	ADCON0,GO		; check A/D is finished
		goto	ReadAD4 		; loop right here until A/D finished
		btfsc	ADCON0,GO		; check A/D is finished
		goto	ReadAD4 		; loop right here until A/D finished
		movf 	ADRESH,W 		; get A/D value
		movwf	Temp1			; move A/D value to temp register
		; fault indication
		incf 	Temp1	 		; increment the value to test for control pot 0
		call 	ZeroError 		; test if control pot is 0, display error if so, return if not
		goto 	ReStart4 		; go to part of code where Restart4 is located

ReStart4
		call	MainOn			; turn on main transistor
		call	checkSensor		; check the state of sensor 
		call	ReducedOn		; turn on reduced transistor
		call	SetupDelay		; wait a little
		call	MainOff			; turn off main transistor
		bcf		STATUS,C 		; clear the carry bit
		rrf		Temp1,W 		; divide A/D by 2
		movwf	Temp1 			; move value to Temp1
		bcf		STATUS,C 	 	; clear the carry bit
		rrf		Temp1,W 		; divide A/D by 2
		movwf	Temp1 			; move value to Temp1
		call	delay42 		; call time for A/D value
		call	ReducedOff 		; turn off reduced transistor
		clrf	Count 			; clear the restart counter
		call	delay43 		; check if transistor off
		goto 	waitPress4 		; wait for next button press

checkSensor
		btfss	PORTD,5			; check if high
		goto	delay4			; if low, go to delay
		return					; if high, go back

CheckOff4
		btfsc	PORTD,5			; check if sensor low 
		return 					; if high, go back to delay
		goto	waitPress4		; if low, finish go back to start of mode 4

CheckReStart
		decfsz	Count 		    ; check if first restart or not
		goto	ProgramError	; if not first restart, error
		goto	ReStart4		; if first restart goto routine 
		
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SwitchDelay
		movlw 	D'20'			; move decimal value 20 into W register
		movwf 	Temp1			; load Temp1 with the value

delay
		decfsz 	Temp1, F		; 60 usec delay loop
		goto 	delay			; loop until count equals zero
		return					; return to calling routine

delay2
		call 	RedPress2Check 	; check for red buton press, reread timer and reset  if pressed
		call	timeLoop		; 1 sec delay
		decfsz 	Temp1, F		; delay loop
		goto 	delay2			; loop until Temp1 equals zero
		return					; return to calling routine

delay4
		movlw	D'10'			; move decimal value 10 into W register
		movwf	Temp2			; move the value to Temp2
		call	timeLoop4		; 1 sec delay
		decfsz	Temp2,F 		; decrement timer
		goto	checkSensor 	; if not 0, recheck sensor
		goto	ProgramError 	; if timer done, go to error


delay42
		btfss	PORTD,5 		; check if sensor is high
		call	CheckReStart 	; if not check for first restart or not
		call	timeLoop4
		decfsz	Temp1,F 		; if sensor high, decrement A/D timer
		goto	delay42 		; if timer not zero, reloop this section
		return 					; if timer done return to calling function

delay43
		movlw	D'10'			; move decimal value 10 into W register
		movwf	Temp2			; move the value to Temp2
		call	CheckOff4 		; check if sensor is low
		call	timeLoop4
		decfsz	Temp2,F 		; decrement the count
		goto	delay43 		; loop back if 10 second wait not finished
		goto	ProgramError 	; show error after 10 second wait

SetupDelay
		movlw	03h				; load Temp2 with hex3
		movwf	Temp2

delayAD
		decfsz	Temp2,F			; delay loop
		goto	delayAD
		return


timeLoop
		movlw	2Ch
		movwf	Timer1
		movlw	35h
		movwf	Timer0

timeDelay
		decfsz	Timer0,F
		goto	timeDelay
		decfsz	Timer1,F
		goto	timeDelay
		return

timeLoop4
		movlw	06h
		movwf	Timer2
		movlw	16h
		movwf	Timer1
		movlw	15h
		movwf	Timer0

timeDelay4
		decfsz	Timer0,F
		goto	timeDelay
		decfsz	Timer1,F
		goto	timeDelay
		decfsz	Timer2,F
		goto	timeDelay
		return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


MainOn
		bsf		PORTD,2 		; set main transistor bit high
		return

MainOff 
		bcf		PORTD,2 		; set main transistor bit low
		return

ReducedOn
		bsf		PORTD,0 		; set reduced transistor bit high
		return

ReducedOff
		bcf		PORTD,0 		; set reduced transistor bit low
		return

LEDOn
		bsf		PORTD,3			; turn LED on
		return

LEDOff
		bcf		PORTD,3			; turn LED off
		return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		

ZeroError
		decfsz 	Temp1			; decrement to see if 0
		return

ProgramError
		bsf 	PORTB,3 		; set error bit
		call 	MainOff 		; turn off main transistor
		call 	ReducedOff 		; turn off reduced transistor
		
		; indicate error on LEDS
		; continue to error loop isrService until processor reset
		
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;


isrService

		goto 	isrService		; error - stay here
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
		END						; Assembler directive - end of program