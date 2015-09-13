/*
 * PartA_1.asm
 *
 *  Created: 9/11/2015
 *   Author: Jean-Ralph Aviles
 *  This program is an example program to output from port E.
 */

; Definitions for all the registers in the processor. ALWAYS
; REQUIRED. View the contents of this file in the Processor
; "Solution Explorer"  window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.equ MASK8 = 0xFF  ; 0b11111111

.ORG 0x0100
  rjmp MAIN

.ORG 0x0200
MAIN:
  ldi r16, MASK8  ; r16 := MASK8
  sts PORTE_DIRSET, r16  ; Set all pins on port E to output.
  ldi r16, 0xFF  ; r16 = 1
  sts PORTE_OUT, r16  ; Set port E to output
DONE:
  rjmp DONE  ; Infinite Loop
