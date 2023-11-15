#include <msp430g2231.h>


char Kma=3;
int i,j;
long adcVAL,gdmv,fdmv=0; // adcVAL:ADC den ölçülen değer, gdmv: gerçek değer mV, fdmv:
//filitrelenmiş gerçek değer mV
int main(void)
{
 WDTCTL = WDTPW + WDTHOLD; // Stop WDT
 ADC10CTL0 = ADC10SHT_2 + ADC10ON + ADC10IE; // ADC10ON, interrupt enabled
 ADC10CTL1 = INCH_4; // input A4
 ADC10AE0 |= 0x10; // P1.4 ADC option select 0 0001 0000b =0x10;
 P1DIR |= 0x41; // P1.0 ve P1.6 LED pinleri çıkış
 P1IE =0x8; //P1.3 deki anahtar interrupt girişi yapıldı
 P1IES=0x8; //P1.3 deki interrupt yüksekten alçağa geçişte oluşssun
 P1REN =0x8; //P1.3 de içerideki direnç bağlandı
 P1OUT =0x8; //P1.3 deki direç pull-up direnci yapıldı
 P1IFG =0; //daha önceden bir interrupt bayrağı kalkmış ise silindi

 P2IE = 0x3F; // Tüm P2 pinleri interrupt girişi
    P2IES = 0x3F; // Tüm P2 pinleri yüksekten alçağa geçişte interrupt oluşssun
    P2REN = 0x3F; // Tüm P2 pinleri iç direnç bağlandı
    P2OUT = 0x3F; // Tüm P2 pinleri pull-up direnci yapıldı
    P2IFG = 0; // P2 interrupt bayrağı temizle

 _BIS_SR(GIE);
 for (;;)
 {
 ADC10CTL0 |= ENC + ADC10SC; // ADC nin dönüştürmesi başlatılıyor
 __bis_SR_register(CPUOFF + GIE); // LPM0 modunda işlemci kapalı, ADC10_ISR ile
//işlemci çalıştırılılmaktadır
 adcVAL=ADC10MEM;
 gdmv=adcVAL*3300/1024; //3.3 volt, yada 3300 mV referans değeri, N=10
//bitlik ADC için gerçek değer hesabı
 fdmv=(fdmv*Kma+gdmv) /(Kma+1);
 fdmv=(fdmv*Kma+gdmv)/(Kma);

 __no_operation();
 }
}
// ADC10 interrupt alt/servis programı
#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void){
 __bic_SR_register_on_exit(CPUOFF); // Clear CPUOFF bit from 0(SR)
}
//Port 1 interrupt alt/servis programı
#pragma vector=PORT1_VECTOR
__interrupt void PORT1_ISR(void){
 Kma=Kma+1;
 if(Kma > 7) {Kma =0; P1OUT =0b00001000;} //Kma sıfırlandı, Yeşil led söndürüldü
//(P1.3=1)
 if(Kma != 0){
     P1OUT =0b01001000;
 for(i = 0 ; i < 3 ; i++){
 P1OUT ^= 0b00000001;
 _delay_cycles(65000);
 P1OUT ^= 0b00000001;
 _delay_cycles(65000);
 }
 } // yeşil led yakıldı (P1.3=1)
 P1IFG=0; //P1 interruptları temizlendi
}
#pragma vector=PORT2_VECTOR
__interrupt void PORT2_ISR(void){
    if(P2IFG & 0x3F){
        //P2OUT = 0b00111111;
        for(j = 0 ; j < 3 ; j++){
            P1OUT |= 0b00000001; // P1.0 LED'i üç kez yakıp söndür
                       _delay_cycles(65000);
                       P1OUT &=0b11111110;
                       _delay_cycles(65000);
    }
        P2IFG = 0;
}
}
