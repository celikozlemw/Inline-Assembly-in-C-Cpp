SetupP1 bis.b #001h,&P1DIR ; P1.0 output
 clr R15
..
;-------------------------------------------------------------------------------
ADC10_ISR; Exit LPM0 on reti
;-------------------------------------------------------------------------------
 mov &ADC10MEM,0220h(r15)
 incd R15
 and #011111b,R15
 bic.w #CPUOFF,0(SP) ; Exit LPM0 on reti
 reti




 .cdecls C,LIST, "msp430.h"
;-------------------------------------------------------------------------------
 .def RESET ; Export program entry-point to
 ; make it known to linker.
;------------------------------------------------------------------------------
 .text ; Progam Start
;------------------------------------------------------------------------------
RESET mov.w #0280h,SP ; Initialize stackpointer
StopWDT mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT
SetupADC10 mov.w #ADC10SHT_2+ADC10ON+ADC10IE,&ADC10CTL0 ; 16x, enable int.
 mov.w #INCH_1, &ADC10CTL1 
 bis.b #02h,&ADC10AE0 ; P1.1 ADC10 option select
SetupP1 bis.b #041h,&P1DIR ; P1.0 output
 ;
Mainloop bis.w #ENC+ADC10SC,&ADC10CTL0 ; Start sampling/conversion
 bis.w #CPUOFF+GIE,SR ; LPM0, ADC10_ISR will force exit
 bic.b #041h,&P1OUT ; P1.0 = 0





 cmp.w #007Fh,&ADC10MEM 
jhs aa

bis.b #040h, &P1OUT




 aa  
cmp.w #01FFh,&ADC10MEM ; ADC10MEM = A1 > 0.5AVcc?
 jlo Mainloop ; Again
 bis.b #041h,&P1OUT ; P1.0 = 1
 jmp Mainloop ; Again
 ;
;-------------------------------------------------------------------------------
ADC10_ISR; Exit LPM0 on reti
;-------------------------------------------------------------------------------
 bic.w #CPUOFF,0(SP) ; Exit LPM0 on reti
 reti ;
 ;
;------------------------------------------------------------------------------
; Interrupt Vectors
;------------------------------------------------------------------------------
 .sect ".reset" ; MSP430 RESET Vector
 .short RESET ;
 .sect ".int05" ; ADC10 Vector
 .short ADC10_ISR ;
 .end
