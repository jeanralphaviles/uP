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
