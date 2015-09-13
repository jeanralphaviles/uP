/*
 * Lab2c_JA.asm
 *
 *  Created: 9/11/2015
 *   Author: Jean-Ralph Aviles
 *   Section: 1539
 *   TA: Khaled
 *  This program flashes some fancy animations depending on
 *  the status of PORT F.
 */

; Definitions for all the registers in the processor. ALWAYS
; REQUIRED. View the contents of this file in the Processor
; "Solution Explorer"  window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.org 0x0100
  rjmp MAIN

.org 0x200
MAIN:
  ldi r16, 0x00
  sts PORTF_DIRSET, r16  ; Set PORTF to input
  ldi r16, 0xFF
  sts PORTE_DIRSET, r16  ; Set PORTE to output
  call GET_PORT_6  ; r16 = PORT_F_6
  cpi r16, 0x0  ; compare PORT_F_6
  brne B  ; If PORT_F_6 is set goto C
  breq A  ; Else go to A

A:
  ldi r16, 0x03  ; r16 = 0x00000011
A_1:
  call SET_OUTPUT  ; Output r16
  push r16  ; Save r16
  ldi r16, 24 ; r16 = 24
  call DELAY  ; Delay for 24*10 = 240ms
  call GET_PORT_6  ; r16 = PORT_F_6
  brne A_EXIT ; Break if PORT_F_6 is not zero
  pop r16  ; Restore r16
  rol r16  ; Rotate left
  brcc A_2; If there was no carry bit
  ori r16, 0x01  ; Add bit that "fell off"
A_2:
  rjmp A_1  ; Loop
A_EXIT:
  pop r16  ; Make sure to clean the stack
  rjmp B  ; Go to other Pattern

B:
  ldi r17, 0x24  ; Load r17 with 0x24
  ldi r16, 0xE7  ; Load r16 with 0b11100111
B_1:
  call SET_OUTPUT  ; Output r16
  push r16  ; Save r16
  ldi r16, 42  ; r16 = 42
  call DELAY  ; Delay for 42*10 = 420ms
  call GET_PORT_6  ; r16 = PORT_F_6
  breq B_EXIT  ; Break if PORT_F_6 is zero
  pop r16  ; Restore r16
  eor r16, r17  ; r16 = r16 ^ r17
  swap r17  ; Swap nibbles of r17

  call SET_OUTPUT  ; Output r16
  push r16  ; Save r16
  ldi r16, 42  ; r16 = 42
  call DELAY  ; Delay for 42*10 = 420ms
  call GET_PORT_6  ; r16 = PORT_F_6
  breq B_EXIT  ; Break if PORT_F_6 is zero
  pop r16  ; Restore r16
  eor r16, r17  ; r16 = r16 ^ r17
  rjmp B_1  ; Loop
B_EXIT:
  pop r16  ; Make sure to clean the stack
  rjmp A  ; Go to other Pattern


GET_PORT_6: ; Returns port 6 into r16
  lds r16, PORTF_IN  ; Get PORTF input
  andi r16, 0x40  ; We only care about bit 6
  ret

SET_OUTPUT: ; Outputs r16 to Port E
   sts PORTE_OUT, r16  ; Set output to r16
   ret

DELAY: ; Delays by r16 x 10ms
  ; 66 * 100 instructions is ~ 10ms
  push r16  ; Push r16 onto the stack
  cpi r16, 0  ; Compare counter
  breq DELAY_RET  ; If counter is 0 return
DELAY_LOOP:
  push r16  ; Push counter onto the stack
  ldi r16, 66; Load outer time loop
DELAY_OUTERLOOP:
  push r16  ; Push outer time loop onto the stack
  ldi r16, 100 ; Load inner time loop
DELAY_INNERLOOP:
  dec r16  ; Decrement inner counter
  brne DELAY_INNERLOOP
  pop r16  ; Pop outer time loop off the stacl
  dec r16  ; Decrement outer counter
  brne DELAY_OUTERLOOP
  pop r16  ; Pop counter off of stack
  dec r16  ; Decrement Counter
  brne DELAY_LOOP  ; If counter is not zero loop again
DELAY_RET:
  pop r16 ; Pop original r16 off of the stack
  ret

