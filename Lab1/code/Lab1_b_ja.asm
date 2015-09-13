/*
 * Table.asm
 * Lab 1 Part B
 *
 *  Created: 9/10/2015 2:24:48 PM
 *   Author: Jean-Ralph Aviles
 *   Section: 1539
 *   TA: Khaled
 *   This program filters values from a Table located at
 *   address 0x1000 in memory and places the filtered table
 *   at address 0x2B10.
 */
 
; Definitions for all the registers in the processor. ALWAYS
; REQUIRED.View the contents of this file in the Processor
; "Solution Explorer" window under "Dependencies"
.include "ATxmega128A1Udef.inc"
 
.equ  NUL = 0x00
.equ  LOWERBOUND = 0x21
.equ  UPPERBOUND = 0x40
.equ  TABLE1 = 0x1000
.equ  TABLE2 = 0x2B10
 
.ORG TABLE1
  .db 0x47, 0x32, 0x2F, 0x6F, 0x2B, 0x20, 0x43, 0x34
  .db 0x64, 0x47, 0x2F, 0x29, 0x61, 0x34, 0x26, 0x3C
  .db 0x74, 0x2A, 0x6F, 0x28, 0x2E, 0x72, 0x3F, 0x73
  .db 0x21, 0x0
 
.ORG 0x0000
  rjmp MAIN
 
.ORG 0x0100
MAIN:
  ldi r30, LOW(TABLE1<<1)  ; Z = Address of Table1
  ldi r31, HIGH(TABLE1<<1)
  ldi r28, LOW(TABLE2)  ; Y = Address of Table2
  ldi r29, HIGH(TABLE2)
DO:
  lpm r0, Z+  ; ro = *(SRC++)
  ldi r17, LOWERBOUND  ; r17 = LOWERBOUND
  cp r17, r0  ; Compare r17 and r0
  BRGE TRANSFER  ; IF r0 <= LOWERBOUND GOTO TRANSFER
  ldi r17, UPPERBOUND  ; r17 = UPPERBOUND
  cp r17, r0  ; Compare r17 and r0
  BRLT TRANSFER  ; IF r0 > r17 GOTO TRANSFER
RETURN:
  ldi r17, NUL  ; r17 = NUL
  cp r0, r17  ; Compare r0 with NUL
  BRNE DO  ; IF r0 != NUL GOTO DO
DONE:
  rjmp DONE  ; ELSE Loop forever
TRANSFER:
  st Y+, r0  ; *(DEST++) = r0
  rjmp RETURN  ; GOTO RETURN
