/*
* Jean-Ralph Aviles 
* Lab 5 Program - Asynchronuous Non blocking Serial Prompt
* 10/22/2015
* TA Khaled
*/

.include "ATxmega128A1Udef.inc"

.equ START = 0x8000             ; Start Address for IO
.equ SRAM_STARTA = 0x472000     ; Start Address for SRAM
.equ KEYTAB_WIDTH = 4           ; Width for Keypad Table
.equ KEYTAB_HEIGHT = 4          ; Height for Keypad Table
.equ BSCALE = -7                ; BSCALE = -7
.equ BSEL = 983                 ; BSEL = 983

.org 0x0000
	rjmp CONFIGURE

.org USARTD0_RXC_vect
	rjmp USARTD0_RXC_isr

CONFIGURE:
.org 0x0200
	; Initialize Stack
	ldi r16, 0xFF              ; Lower Byte of Stack Pointer
	out CPU_SPL, r16           ; Set lower byte
	ldi r16, 0x3F              ; Upper byte of Stack Pointer
	out CPU_SPH, r16           ; Set Upper byte

	ldi r16, 0xF0              ; PortF pin dir, upper bits output, lower input.
	sts PORTF_DIR, r16         ; ""
	ldi r16, 0x0F              ; Set mask for pins to configure 3:0
	sts PORTCFG_MPCMASK, r16   ; Load mask into MPCMASK register.
	ldi r16, 0x10              ; Configure input pins to have pull up resistors.
	sts PORTF_PIN0CTRL, r16    ; Pin0 pullup (Applies to 3:0 due to MPCMASK).

	; Mem mapped I/O
	ldi R16, 0b110111          ;set /WE, /RE, /CS0, /CS1 to Output			
	sts PORTH_DIR, R16
	ldi R16, 0b110011          ;set /RE, /WE, /CS0, /CS1 to default of H
	sts PORTH_OUTSET, R16
	ldi R16, 0xFF              ;set all PORTJ pins (D0-D7) to be outputs. As requried 
	sts PORTJ_DIR, R16         ;in the data sheet.
	ldi R16, 0xFF              ;set all PORTK pins (A0-A15) to be outputs. As requried	
	sts PORTK_DIR, R16         ;in the data sheet.
	ldi R16, 0x01              ;Store 0x01 in EBI_CTRL register to select 3 port EBI(H, J, K) 
                                   ;mode and SRAM ALE1 mode
	sts EBI_CTRL, R16

	; Switches and Leds /CS0
	ldi r16, 0b0010101         ; Set CTRL A to 8K address size
	sts EBI_CS0_CTRLA, r16     ; (0b00101) and SRAM Mode (0b01)
						   ; pg 335 8331
	ldi ZL, LOW(EBI_CS0_BASEADDR) ; Load Z with BASEADDR
	ldi ZH, HIGH(EBI_CS0_BASEADDR) ; We will load the upper 12
	ldi r16, byte2(START)      ; bits of the START address
	st Z+, r16                 ; into BASEADDR register.
	ldi r16, byte3(START)
	st Z, r16
	
	ldi r16, byte3(START)      ; Set third byte of X
	sts CPU_RAMPX, r16
	ldi XL, LOW(START)         ; Load X with START address
	ldi XH, HIGH(START)

	ldi r16, 0x0               ; Zero out the LED
	st X, r16

	call INIT_USART
	call INIT_USART_INT

	ldi r16, 0x01              ; Load 0x01 into r16
	sts PMIC_CTRL, r16         ; Enable low level interrupts.
	sei                        ; Interrupts Activated!
	rjmp MAIN

MAIN:
	ldi r16, 0x04           ; Load r16 with 0x04
	ldi r17, 0xC3           ; Load r17 with 0x0F
LOOP:
	st X, r17               ; Store r17 into LEDs
	com r17                 ; Flip r17 bits
	rcall DELAY             ; Delay for 40ms
	rjmp LOOP               ; Loop

USARTD0_RXC_isr:
	push r16                ; Save r16
	rcall IN_CHAR           ; Read character
	rcall OUT_CHAR          ; Echo character, will clear RXCIF
	pop r16                 ; Restore r16
	reti                    ; Resume execution

OUT_CHAR:
	push r17                   ; Save r17
TX_POLL:
	lds r17, USARTD0_STATUS    ; Get USART status
	sbrs r17, 5                ; Break when DREIF is empty
	rjmp TX_POLL               ; Loop again
	sts USARTD0_DATA, r16      ; Output r16
	pop r17                    ; Restore r17
	ret                        ; Return

OUT_STRING:
	push r16                   ; Save r16
	push ZL                    ; Save ZL
	push ZH                    ; Save ZH
	lds r16, CPU_RAMPZ         ; Save RAMPZ
	push r16                   ; Save RAMPZ
OUT_STRING_A:
	lpm r16, Z+                ; Load r16 and inc Z
	tst r16                    ; Compare r16 with '\0'
	breq OUT_STRING_EXIT       ; At end of string, exit
	rcall OUT_CHAR             ; Call OUT_CHAR to output
	rjmp OUT_STRING_A          ; Loop
OUT_STRING_EXIT:
	pop r16                    ; Restore RAMPZ
	sts CPU_RAMPZ, r16         ; Restore RAMPZ
	pop ZH                     ; Restore ZH
	pop ZL                     ; Restore ZL
	pop r16                    ; Restore r16
	ret

IN_CHAR:
	lds r16, USARTD0_STATUS    ; Get USART status
	sbrs r16, 7                ; Break if RXCIF is on
	rjmp IN_CHAR               ; Else jmp to IN_CHAR
	lds r16, USARTD0_DATA      ; Read Data
	ret                        ; Return

INIT_USART:
	; GPIO
	push r16                   ; Save r16
	ldi r16, 0x08              ; Load r16 with Bit3 (Tx)
	sts PORTD_DIRSET, r16      ; Set Tx to output
	sts PORTD_OUTSET, r16      ; Set Tx default output
	ldi r16, 0x04              ; Load r16 with Bit2 (Rx)
	sts PORTD_DIRCLR, r16      ; Set Rx to input
	ldi r16, 0x0A              ; Load Bit3,1 into r16
	sts PORTQ_DIRSET, r16      ; Connect PORTD serial pins
	sts PORTQ_OUTCLR, r16      ; to USB
	; USART
	ldi r16, 0x18              ; Load 0x18 into r16
	sts USARTD0_CTRLB, r16     ; Enable Rx and Tx on PortD
	ldi r16, 0x03              ; Configure USART for Async,
	sts USARTD0_CTRLC, r16     ; No Parity, 1 Stop Bit, 8bits
	ldi r16, (BSEL & 0xFF)     ; Load lower 8 bits of BSEL
	sts USARTD0_BAUDCTRLA, r16 ; Set lower 8 bits of BSEL
	ldi r16, ((BSCALE << 4) & 0xF0) | ((BSEL>>8) & 0x0F)
	sts USARTD0_BAUDCTRLB, r16 ; Configure BSCALE and upper BSEL
	pop r16                    ; Restore r16
	ret                        ; Return

INIT_USART_INT:
	push r16                   ; Save r16
	ldi r16, 0x10              ; Load LO-level interupt mask
	sts USARTD0_CTRLA, r16     ; Set LO-level interupt on recieve
	pop r16
	ret

COUNT_ISR:
	push r17                 ; Save r17
	push r16                 ; Save r16
	ldi r16, 0x01            ; Load 0x01 into r16
	call DELAY               ; Delay for 1ms
	pop r16                  ; Restore r16
	lds r17, PORTE_IN        ; Read PORTE after delay bounces
	andi r17, 0x80           ; Read Pin7
	tst r17                  ; Compare Pin7 to 0x00
	brne COUNT_ISR_EXIT      ; False positive
	inc r16                  ; Increment our counter r16
	st X, r16                ; Store the counter into the LEDS
COUNT_ISR_EXIT:
	ldi r17, 0x01            ; Load a 0x01 into r17
	sts PORTE_INTFLAGS, r17	 ; Clear interrupt flag
	pop r17                  ; Restore r17
	reti                     ; Return from interrupt

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
