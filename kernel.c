#include<stdint.h>
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

void update_cursor(int x, int y){
   uint16_t pos = y * VGA_WIDTH + x;
   //outb(0x3D4, 0x0F);
   //outb(0x3D5, (uint8_t)(pos & 0xFF));
   //outb(0x3D4, 0x0E);
   //outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

extern void main(){
   //while(1);
   /*
   __asm__(
      "mov $0x0e, %ah\n"
      "mov $'A', %al\n"
      "int $0x10\n"
      "mov $0x0a, %al\n"
      "int $0x10\n"
      "mov $0x0d, %al\n"
      "int $0x10\n"
   );
   */
   *(char*)0xb8000 = 'A';
   *(char*)0xb8001 = 0x0F;
   return;
}
