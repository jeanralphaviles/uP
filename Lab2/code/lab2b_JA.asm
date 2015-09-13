/*
 * lab2b_JA.asm
 *
 *  Created: 9/11/2015
 *   Author: Jean-Ralph Aviles
 *   Section: 1539
 *   TA: Khaled
 * This program blinks the LEDs on port E at 2kHz.
 */

; Definitions for all the registers in the processor. ALWAYS
; REQUIRED. View the contents of this file in the Processor
; "Solution Explorer"  window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.equ MASK8 = 0xFF  ; 0b11111111
.equ NITERATIONS = 165

.ORG 0x0100
  rjmp MAIN

.ORG 0x0200
MAIN:
  ldi r16, MASK8  ; r16 := MASK8
  sts PORTE_DIRSET, r16  ; Set all pins on port E to output
LOOP:
  sts PORTE_OUTTGL, r16 ; Toggle OUTPUT
  CALL DELAY  ; Delay
  rjmp LOOP

DELAY:
  ldi r17, NITERATIONS ; Load r17 with delay counter
DELAYLOOP:
  dec r17 ; r17 = r17 - 1
  brne DELAYLOOP
  ret
