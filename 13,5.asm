;-------------------------------------------------------------------------------
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
      mov #50,r4;referans ısı değeri=50 derece olarak alındı
      bis.b #011b,&P1DIR; p1 çıkış seçildi



         bis.b #01100,&P1IE; interrupt yetkilendirildi
         bis.b #01100,&P1IES; yüksekten alçağa geçiş
         bis.b #01100,&P1REN;iç dirençleri bağla
         bis.b #01100,&P1OUT;iç dirençleri pıll up direnci yap
         bic.b #01100,&P1IFG;daha öncesinde interrupt varsa sil
         eint


loop     mov r4,r7
         rla r7
         rla r7; hassasiyet oransal olarak 4.5 kat ayarlamamız lazım bu kısım 4 kısmını ayarlıyor.İşlemcimizde virgülden sonrası olmadığı için .5 kısmı bu şekilde ayarlayamayı.
         rla r7;13,5 için değişiklik yaptık ve 8 katını bulduk
        ; mov r4,r6; r4 ün yarısını r6 ya yükledik( bu kısmı 13 için kullandık 13.5 için kullanmayacağız)
        ; rra r6; r6 nın yarısını bulduk ( bu kısmı 13 için kullandık 13.5 için kullanmayacağız)
         ;add r6,r7; bu kısmı okunduğunda artık r7 nın 4.5 katı r7 ye yüklenmiş oldu.( bu kısmı 13 için kullandık 13.5 için kullanmayacağız)
         add #27,r7
         mov r4,r8
         rla r8
         rla r8
          rla r8; bu kısmı 13.5 için ekledik
         ;aradaki kodları sildik
         add r4,r8
         sub #27,r8; aslında ısı hassasiyetimiz 3 derece yanı 4.5x3 =13.5  .5 i ihmal etmedik 
;aradaki kodları sildik çünkü tekrar rx e atıp toplama yapmamıza gerek olmadan çarpma ile işlemi tamamladık
         mov &ADC10MEM0,r5 ; anolog girişten alınan ısı ölçüm değerini r5 e attı burada referansımız r5 olacak ve tüm karşılaştırmaları buna göre yazacağız
         rla r5
         cmp r7,r5; r5-r7 yaptı
         jn ss1
         bic.b #010b
ssı cmp r8,r5; r5-r8 yaptı
     jge ss2
     bis.b #010b,&P1OUT;ısıtıcıyı çalıştırdı
ss2 call #bekle
    jmp loop
bekle mov #0fffh,r15; büyük bir sayıyı r15 e attı bu sayede bir aralık bekleme gerçekleşecek
ss3 dec r15
    jnz ss3
    ret
kesme bit.b #0100b,P1IFG; src and dst
      jz ss4; sonuç sıfırsa ss4 e geri git
      inc r4; referansı 1 derece artır
      clr.b &P1IFG; bayrakları temizle
      reti

ss4 dec r4; referansı azalt 1 derece
   clr.b &P1IFG;bayrakları temizle
   reti




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
            ;bu kısımda interrupt ayarlaması yapılacak
            .sect".int02"
            .short kesme

            
