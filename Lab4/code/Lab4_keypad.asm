/*
* Jean-Ralph Aviles 
* Lab 4 Keypad Reading
* 10/06/2015
* TA Khaled
*/

.include "ATxmega128A1Udef.inc"

.equ START = 0x8000     ; Start Address for IO
.equ KEYTAB_WIDTH = 4   ; Width for Keypad Table
.equ KEYTAB_HEIGHT = 4  ; Height for Keypad Table

.org 0x100
  rjmp CONFIGURE

CONFIGURE:
.org 0x200
  ldi r16, 0xF0  ; PortF pin dir, upper bits output lower input
  sts PORTF_DIR, r16  ; ""
  ldi r16, 0x0F  ; Set mask for pins to configure 3:0
  sts PORTCFG_MPCMASK, r16  ; Load mask into MPCMASK register.
  ldi r16, 0x10  ; Configure input pin pull up resistors.
  sts PORTF_PIN0CTRL, r16  ; Pin0 pullup
                           ; (Applies to 3:0 due to MPCMASK).

  ; Mem mapped I/O
  ldi R16, 0b10111  ;set /WE, /RE, /CS0 to Output      
  sts PORTH_DIR, R16
  ldi R16, 0b10100  ;set /RE, /WE, /CS0 to default of 1 
  sts PORTH_OUTSET, R16
  ldi R16, 0xFF  ; set all PORTJ pins (D0-D7) to be outputs.
  sts PORTJ_DIR, R16  ; As required in the data sheet.
  ldi R16, 0xFF  ; set all PORTK pins (A0-A15) to be outputs.
  sts PORTK_DIR, R16  ; As required in the data sheet.
  ldi R16, 0x01  ; Store 0x01 in EBI_CTRL register to select
                 ; 3 port EBI(H, J, K) mode and SRAM ALE1 mode
  sts EBI_CTRL, R16  

  ldi r16, 0b0010101      ; Set CTRL A to 8K address size
  sts EBI_CS0_CTRLA, r16  ; (0b00101) and SRAM Mode (0b01)
                          ;  pg 335 8331
  ldi ZL, LOW(EBI_CS0_BASEADDR)  ; Load Z with BASEADDR
  ldi ZH, HIGH(EBI_CS0_BASEADDR)  ; We will load the upper 12
  ldi r16, byte2(START) ; bits of the START address
  st Z+, r16  ; into BASEADDR register.
  ldi r16, byte3(START)
  st Z, r16
  
  ldi r16, byte3(START)  ; Set third byte of X
  sts CPU_RAMPX, r16
  ldi XL, LOW(START)  ; Load X with START address
  ldi XH, HIGH(START)

  ldi r16, 0x0  ; Zero out the LEDs
  st X, r16
  rjmp MAIN

MAIN:
  call READ_KEYPAD  ; Load value from keypad.
  st X, r16  ; Store that value in the LEDS
  rjmp MAIN  ; Wait for another input.

READ_KEYPAD:    ; Result stored in r16
  push ZL       ; Save ZL register
  push ZH       ; Save ZH register
  push r13      ; Save r13
  push r14      ; Save r14
  push r17      ; Save r17
  ldi r16, 0x00 ; Load r16 with 0
READ_KEYPAD_1:
  cpi r16, KEYTAB_HEIGHT  ; Compare r16 with Keytab Height
  breq READ_KEYPAD_EXIT1  ; If Equal exit
  push r16  ; Save r16
  mov r17, r16  ; Save r16 into r17
  ldi r16, 0x80  ; Load r16 with output mask
  call ROTATE_RIGHT  ; Rotate r16 r17 times
  mov r17, r16  ; Move rotated value into r17
  pop r16  ; Restore r16

  sts PORTF_OUT, r17  ; Write output mask to keypad.
  nop  ; NOP Needed for some reason
  lds r13, PORTF_IN  ; Read response into r13
  ldi r17, 0x0F  ; Mask for lower bits of response.
  and r13, r17  ; Mask the response.
  ldi r17, 0  ; Load 0 into r17
READ_KEYPAD_2:
  cpi r17, KEYTAB_WIDTH  ; Compare r17 with width
  breq READ_KEYPAD_2_END  ; If equal break
  push r16  ; Else Save r16
  ldi r16, 0x08  ; Store mask into r16
  call ROTATE_RIGHT  ; Rotate response r17 times.
  mov r14, r16  ; Return value to r14
  pop r16  ; Restore r16
  cp r14, r13  ; Compare rotated mask with response.
  breq READ_KEYPAD_READ_TAB  ; If equal read value from KEYTAB.
  inc r17  ; Else decrement r17.
  rjmp READ_KEYPAD_2  ; Loop
READ_KEYPAD_READ_TAB:
  ; Read ret value from KEYTAB to r16
  ; r16 is row offset, r17 is col offset.
  ldi ZL, LOW(KEYTAB<<1)  ; Load KEYTAB into Z
  ldi ZH, HIGH(KEYTAB<<1)  ; Load KEYTAB into Z
  push r16  ; Save r16
  ldi r16, KEYTAB_WIDTH  ; Load WIDTH into r16
  mov r13, r16  ; Move WIDTH into r13
  pop r16  ; Restore r16
  mul r13, r16  ; Multiply Offset by width
  mov r16, r0  ; Get Lower value of answer.
  call INCZ_NTIMES  ; Increment Z r16 times
  mov r16, r17  ; Get COL offset
  call INCZ_NTIMES  ; Increment Z again
  lpm r16, Z        ;  Get Keypad Value
  rjmp READ_KEYPAD_EXIT
READ_KEYPAD_2_END:
  inc r16  ; Decrement r16 loop var
  rjmp READ_KEYPAD_1  ; Jump to begining of loop
READ_KEYPAD_EXIT1:
  ldi r16, 0xFF  ; Load r16 with 
READ_KEYPAD_EXIT:
  ldi r17, 0x0  ; Assert 0 to the Keypad
  sts PORTF_OUT, r17  ; Write that 0
  pop r17          ; Restore r17
  pop r14          ; Restore r14
  pop r13          ; Restore r14
  pop ZH           ; Restore ZH
  pop ZL           ; Restore ZL
  ret
  
INCZ_NTIMES:
  push r16  ; Save r16
  push r17  ; Save r17
INCZ_NTIMES_LOOP:
  cpi r16, 0x00  ; If r16 is 0
  breq INCZ_NTIMES_END  ; Exit
  ld r17, Z+    ;  Increment Z
  dec r16  ; Decrement r16
  rjmp INCZ_NTIMES_LOOP
INCZ_NTIMES_END:
  pop r17  ; Retstore 17
  pop r16  ; Restore r16
  ret

ROTATE_RIGHT:  ; Rotate r16 r17 times.
  push r17
ROTATE_RIGHT_START:
  cpi r17, 0x00  ; Compare r17 with 0x00
  breq ROTATE_RIGHT_END  ; If 0 jump to end.
  lsr r16  ; Else rotate right r16
  dec r17  ; Decrement r17
  rjmp ROTATE_RIGHT_START  ; Loop to begining.
ROTATE_RIGHT_END:
  pop r17
  ret

KEYTAB:  ; Keypad is inverted
  .DB 0x0D, 0x0F, 0x00, 0x0E
  .DB 0x0C, 0x09, 0x08, 0x07
  .DB 0x0B, 0x06, 0x05, 0x04
  .DB 0x0A, 0x03, 0x02, 0x01
