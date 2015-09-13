/*
 * Lab2a_JA.asm
 *
 *  Created: 9/11/2015
 *   Author: Jean-Ralph Aviles
 *   Section: 1539
 *   TA: Khaled
 *  This program is an example program to read from port F
 *  and output to port E.
 */

; Definitions for all the registers in the processor. ALWAYS
; REQUIRED. View the contents of this file in the Processor
; "Solution Explorer"  window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.equ MASK8 = 0xFF  ; 0b11111111
.equ ZERO = 0x00  ; 0b00000000

.ORG 0x0100
  rjmp MAIN

.ORG 0x0200
MAIN:
  ldi r16, MASK8  ; r16 := MASK8
  sts PORTE_DIRSET, r16  ; Set all pins on port E to output.
  ldi r16, ZERO  ; r16 := ZERO
  sts PORTF_DIRSET, r16  ; Set all pins on port F to input.
LOOP:
  lds r16, PORTF_IN  ; Read Input from port F to r16
  sts PORTE_OUT, r16  ; Set port E to output what r16 had.
  rjmp LOOP  ; Do forever.
