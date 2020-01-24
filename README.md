# OnOff-Control
Programming a microcomputer in assembler to control a solenoid through four different modes of operation.

 Mode 1 (indicator LEDs 0001)
o Press the red button, the solenoid engages.
o Press the red button again, the solenoid disengages. o Repeats on and off with the red button.
o Press the green button and a new mode is entered.

 Mode 2 (indicator LEDs 0010)
o Read the value on the control pot
o Press the red button, the solenoid engages for 1⁄4 the value of the control pot in
seconds.
o Press the red button again before the timing finishes, the timing sequence restarts. o After finishing, press the red button again to repeat the process.
o After finishing, press the green button to switch to a new mode.
o If the reading of the A/D converter is 0, a fault is indicated.

 Mode 3 (indicator LEDs 0011)
o Read the value on the control pot
o Press the red button, the control becomes active.
o If the value on the A/D converter is greater than 70 hex, the solenoid engages
o The A/D is read continuously. When the value is greater than 70 hex, the solenoid
engages. When the value is less than 70 hex, the solenoid retracts.
o Press the red button again to stop the control.
o When control is active, the indicator flashes.
o With control inactive, press the green button to switch to a new mode. o If the reading of the A/D converter is 0, a fault is indicated.

 Mode 4 (indicator LEDs 0100)
o Read the value on the control pot
o Press the red button, the solenoid engages with the main transistor.
o As soon as the optical sensor indicates that the solenoid has retracted, turn on the
reduced transistor and turn off the main transistor.
o The reduced transistor stays on for 1⁄4 the value of the control pot in seconds.
o Pressing the red button again before the timing finishes does not restart the timing sequence.
o If the reading of the A/D converter is 0, a fault is indicated.
o If the optical sensor does not indicate that the solenoid has retracted in 10
seconds, turn off the main transistor and indicate a fault. (indicator LEDs 1011) o If the optical sensor indicates that the solenoid has disengaged when the reduced transistor in on, restart the whole sequence again (one time). If the optical sensor
indicates that the solenoid has disengaged a second time when the reduced
transistor in on, indicate a fault. (indicator LEDs 1011)
o If the solenoid is turned off and the optical sensor indicates that the solenoid is
still retracted in 10 seconds, also indicate a fault. (indicator LEDs 1011)
o After finishing successfully, press the red button again to repeat the process.
o After finishing successfully, press the green button to switch to a new mode.
o If a fault, the microcomputer has to be reset with the black reset switch (green and
red buttons are ignored).

 Mode 0 and 5 to 7 (indicator LEDs 1xxx where xxx is the mode number)
o These modes are errors (they do not exist). The solenoid is disengaged (if it is
engaged) and the microcomputer has to be reset with the reset switch (green and red buttons are ignored).
