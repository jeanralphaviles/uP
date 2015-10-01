/*
 * Part3_JA.asm
 *
 *  Created: 9/17/2015
 *  Author: Jean-Ralph Aviles
 *  This program reads from the switches mapped to 0x8000
 *  and writes those values to the LEDs at 0x8000 and shifts
 *  the bits left by one once every two seconds for 8
 *  seconds before reading from input again and looping.
 */

.include "ATxmega128A1Udef.inc"

.equ START = 0x8000 ; Start Address

.org 0x100
  rjmp MAIN

.org 0x200
MAIN:
  ldi R16, 0b10111    ;set /WE, /RE, /CS0 to Output
  sts PORTH_DIR, R16
  ldi R16, 0b10100    ;set /RE, /WE, /CS0 to default of 1
  sts PORTH_OUTSET, R16
  ldi R16, 0xFF       ;set all PORTJ pins (D0-D7) to be outputs
                      ;As requried
  sts PORTJ_DIR, R16  ;in the data sheet.
  ldi R16, 0xFF       ;set all PORTK pins (A0-A15) to be outputs
                      ;As requried
  sts PORTK_DIR, R16  ;in the data sheet.
  ldi R16, 0x01       ;Store 0x01 in EBI_CTRL register to select
                      ;3 port EBI(H, J, K) mode and SRAM ALE1
                      ;mode
  sts EBI_CTRL, R16

  ldi r16, 0b0010101  ;Set CTRL A to 8K address size
                      ;(0b00101) and SRAM Mode (0b01)
                      ;pg 335 8331
  sts EBI_CS0_CTRLA, r16

  ldi ZL, LOW(EBI_CS0_BASEADDR)  ; Load Z with BASEADDR
  ldi ZH, HIGH(EBI_CS0_BASEADDR) ; We will load the upper 12
  ldi r16, byte2(START)          ; bits of the START address
  st Z+, r16                     ; into BASEADDR register.
  ldi r16, byte3(START)
  st Z, r16

  ldi r16, byte3(START)          ; Set third byte of X
  sts CPU_RAMPX, r16
  ldi XL, LOW(START)             ; Load X with START address
  ldi XH, HIGH(START)

  ldi r16, 0x0                   ; Zero out the LEDs
  st X, r16

LOOP:
  ld r16, X                      ; Load value from switches.
  ldi r17, 0x8                   ; Load loop2 counter
LOOP2:
  cpi r17, 0x0                   ; Compare r17 to 0
  breq LOOP                      ; Restart when r17 is 0
  dec r17                        ; Decrement r17
  st X, r16                      ; Store value into LEDs
  push r16                       ; Save r16
  ldi r16, 0xC8                  ; Delay for 200*10 ms = 2s
  CALL DELAY                     ; Delay
  pop r16                        ; Restore r16
  ldi r18, 0x0                   ; Set r18 to 0
  ror r16                        ; Rotate right
  ror r18                        ; Get carry bit to r18
  or r16, r18                    ; Put Carry in MSB of r16
  rjmp LOOP2                     ; Return to LOOP2

DELAY:                           ; Delays by r16 x 10ms
                                 ; 66*100 instructions=10ms
  push r16                       ; Push r16 onto the stack
  cpi r16, 0                     ; Compare counter
  breq DELAY_RET                 ; If counter is 0 return
DELAY_LOOP:
  push r16                       ; Counter onto the stack
  ldi r16, 66                    ; Load outer time loop
DELAY_OUTERLOOP:
  push r16                       ; Push outer loop to stack
  ldi r16, 100                   ; Load inner time loop
DELAY_INNERLOOP:
  dec r16                        ; Decrement inner counter
  brne DELAY_INNERLOOP
  pop r16                        ; Pop outer time loop
  dec r16                        ; Decrement outer counter
  brne DELAY_OUTERLOOP
  pop r16                        ; Pop counter off of stack
  dec r16                        ; Decrement Counter
  brne DELAY_LOOP                ; If counter != 0 loop again
DELAY_RET:
  pop r16                        ; Pop r16 off 
  ret                            ; Return
