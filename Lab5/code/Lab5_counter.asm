/*
* Jean-Ralph Aviles 
* Lab 5 Program - Interrupt Counting
* 10/21/2015
* TA Khaled
*/

.include "ATxmega128A1Udef.inc"

.equ START = 0x8000  ; Start Address for IO
.equ SRAM_STARTA = 0x472000  ; Start Address for SRAM
.equ KEYTAB_WIDTH = 4  ; Width for Keypad Table
.equ KEYTAB_HEIGHT = 4  ; Height for Keypad Table

.org 0x0000
	rjmp CONFIGURE

.org PORTE_INT0_VECT
	rjmp COUNT_ISR

CONFIGURE:
.org 0x0200
	; Initialize Stack
  ldi r16, 0xFF  ; Lower Byte of Stack Pointer
  out CPU_SPL, r16  ; Set lower byte
  ldi r16, 0x3F  ; Upper byte of Stack Pointer
  out CPU_SPH, r16  ; Set Upper byte

  ldi r16, 0xF0  ; PortF dir, upper bits output, lower input.
  sts PORTF_DIR, r16  ; ""
  ldi r16, 0x0F  ; Set mask for pins to configure 3:0
  sts PORTCFG_MPCMASK, r16  ; Load mask into MPCMASK register.
  ldi r16, 0x10  ; Configure input pins pull up resistors.
  sts PORTF_PIN0CTRL, r16  ; Pin0 pullup (Applies to 3:0).

  ; Mem mapped I/O
  ldi R16, 0b110111  ;set /WE, /RE, /CS0, /CS1 to Output      
  sts PORTH_DIR, R16
  ldi R16, 0b110011  ;set /RE, /WE, /CS0, /CS1 to defaultH
  sts PORTH_OUTSET, R16
  ldi R16, 0xFF  ;set all PORTJ pins (D0-D7) to be outputs.
                 ;As requried 
  sts PORTJ_DIR, R16  ;in the data sheet.
  ldi R16, 0xFF  ;set all PORTK pins (A0-A15) to be outputs.
  sts PORTK_DIR, R16  ;As required in the data sheet.
  ldi R16, 0x01  ;Store 0x01 in EBI_CTRL register to select
                 ;3 port EBI(H, J, K)  and SRAM ALE1 mode
  sts EBI_CTRL, R16

  ; Switches and Leds /CS0
  ldi r16, 0b0010101  ; Set CTRL A to 8K address size
  sts EBI_CS0_CTRLA, r16  ; (0b00101) and SRAM Mode (0b01)
               ; pg 335 8331
  ldi ZL, LOW(EBI_CS0_BASEADDR) ;  Load Z with BASEADDR
  ldi ZH, HIGH(EBI_CS0_BASEADDR) ;  We will load the upper 12
  ldi r16, byte2(START) ;  bits of the START address
  st Z+, r16  ; into BASEADDR register.
  ldi r16, byte3(START)
  st Z, r16
  
  ldi r16, byte3(START)  ;  Set third byte of X
  sts CPU_RAMPX, r16
  ldi XL, LOW(START)  ; Load X with START address
  ldi XH, HIGH(START)

  ldi r16, 0x0 ; Zero out the LED
  st X, r16

  ; Init Interupt 0 on falling edge on PORTE_7
  ldi r16, 0x01  ; Load 0x01 into r16 (Low Priority)
  sts PORTE_INTCTRL, r16  ; Set PORTE INT0 as Low Priority
  sts PORTE_DIRCLR, r16  ; Set PORTE_7 as Input
  ldi r16, 0x80  ; Load Bit7 mask into r16
  sts PORTE_OUT, r16  ; Default output on PORTE
  sts PORTE_INT0MASK, r16  ; Enable interrupts on Pin7
  ldi r16, 0x00  ; Load 0x00 into r16
  sts PORTE_INT1MASK, r16  ; Disable interrupt 1 on PORTE
  ldi r16, 0x02  ; Load Bit2 mask into r16
  sts PORTE_PIN7CTRL, r16  ; Set Pin7 trigger on falling edges
  ldi r16, 0x01  ; Load 0x01 into r16
  sts PMIC_CTRL, r16  ; Enable low level interrupts.
  sei  ; Interrupts Activated!
  rjmp MAIN

MAIN:
  ldi r16, 0x00  ; Initialize counter
DONE:
  sleep  ; Wait for an interrupt
  rjmp DONE

COUNT_ISR:
  push r17  ; Save r17
  push r16  ; Save r16
  ldi r16, 0x01  ; Load 0x01 into r16
  call DELAY  ; Delay for 1ms
  pop r16  ; Restore r16
  lds r17, PORTE_IN  ; Read PORTE after delay bounces
  andi r17, 0x80  ; Read Pin7
  tst r17  ; Compare Pin7 to 0x00
  brne COUNT_ISR_EXIT  ; False positive
  inc r16  ; Increment our counter r16
  st X, r16  ; Store the counter into the LEDS
COUNT_ISR_EXIT:
  ldi r17, 0x01  ; Load a 0x01 into r17
  sts PORTE_INTFLAGS, r17  ; Clear interrupt flag
  pop r17  ; Restore r17
  reti  ; Return from interrupt


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
