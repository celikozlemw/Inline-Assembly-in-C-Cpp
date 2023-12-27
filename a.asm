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




;Program, RESET etiketi ile başlar. Bu etiket, programın giriş noktasını linker’a bildirir. Bu bölümde, stack pointer (SP) 0280h adresine ayarlanır ve watchdog timer (WDT) durdurulur. WDT, programın belirli bir süre içinde yanıt vermediği durumlarda otomatik olarak resetlenmesini sağlayan bir mekanizmadır3.
Program, SetupADC10 etiketi ile devam eder. Bu bölümde, ADC10 modülünün kontrol kayıtları ayarlanır. ADC10, analog sinyalleri 10 bitlik dijital değerlere dönüştüren bir analog-dijital dönüştürücüdür4. ADC10CTL0 kaydı, örnekleme süresini, ADC10’yu açmayı ve kesme iznini belirler. ADC10CTL1 kaydı, giriş kanalını belirler. ADC10AE0 kaydı, P1.1 pininin ADC10 girişi olarak seçilmesini sağlar.
Program, SetupP1 etiketi ile devam eder. Bu bölümde, P1.0 pininin çıkış olarak ayarlanır. Bu pin, dijital bir LED’i kontrol etmek için kullanılacaktır.
Program, Mainloop etiketi ile devam eder. Bu bölümde, ADC10’yu başlatmak ve örnekleme/dönüştürme işlemini gerçekleştirmek için ADC10CTL0 kaydına ENC ve ADC10SC bitleri set edilir. Ardından, program düşük güç modu 0 (LPM0) ve genel kesme izni (GIE) ile uyku moduna geçer. Bu modda, program ADC10 kesmesi (ADC10_ISR) ile uyanacaktır. Bu arada, P1.0 pininin değeri 0 olarak ayarlanır, yani LED söner.
Program, ADC10_ISR etiketi ile devam eder. Bu bölümde, ADC10 kesmesinin gerçekleştiği zaman çalışacak kod bulunur. Bu kod, CPUOFF bitini stack pointer’dan silerek programın uyku modundan çıkmasını sağlar. Ayrıca, reti komutu ile kesmeden çıkılır.
Program, Mainloop bölümüne geri döner. Bu bölümde, ADC10MEM kaydındaki değer 007Fh ile karşılaştırılır. ADC10MEM, ADC10 tarafından dönüştürülen dijital değeri tutan bir kayıttır4. Eğer ADC10MEM değeri 007Fh’den büyük veya eşit ise, program aa etiketine atlar. Aksi halde, program Mainloop bölümünün başına döner.
Program, aa etiketi ile devam eder. Bu bölümde, ADC10MEM kaydındaki değer 01FFh ile karşılaştırılır. Eğer ADC10MEM değeri 01FFh’den küçük ise, program Mainloop bölümünün başına döner. Aksi halde, P1.0 pininin değeri 1 olarak ayarlanır, yani LED yanar. Sonra, program Mainloop bölümünün başına döner.
Program, son bölümde kesme vektörlerini tanımlar. Kesme vektörleri, kesmelerin hangi adreslerdeki kodları çalıştıracağını belirleyen kayıtlardır5. Bu programda, reset kesmesi RESET etiketindeki kodu, ADC10 kesmesi ise ADC10_ISR etiketindeki kodu çalıştırır.
