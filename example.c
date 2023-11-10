#include <msp430.h>

int main(void)
{
  WDTCTL = WDTPW + WDTHOLD; // Watchdog timeri durdur
  P1DIR |= 0x01; // P1.0 pinini çıkış olarak ayarla
  P1IE |= 0x01; // P1.0 pininde kesmeye izin ver
  P1IES |= 0x01; // P1.0 pininde düşen kenarda kesme oluştur
  P1IFG &= ~0x01; // P1.0 pinindeki kesme flagını temizle
  __bis_SR_register(LPM4_bits + GIE); //  kesmelere izin ver
  asm("mov #01234h, &0200h"); // 0200h adresine 01234h değerini ver
  asm("add #01234h, r5"); // r5 kayıtçısına 01234h değerini ekle
  return 0;
}
