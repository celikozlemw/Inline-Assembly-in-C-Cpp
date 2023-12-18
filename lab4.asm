-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
         bis.b #040h,&P1DIR
         mov #64,r13
         bis.b #08h,&P1IE
         bis.b #08h,&P1REN
         bis.b #08h,&P1OUT
         bis.b #08h,&P1IFG
         eint
loop     xor.b #040h,&P1OUT
         call #delay
         jmp loop

delay   mov r13,r14
loop1   mov #02fffh,r15
loop2   dec r15
        jnz loop2
        dec r14
        jnz loop1
        ret
P1kesme rra r13
        bic.b #08h,&P1IFG
        reti

        .sect".int02"
        .short P1kesme

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
