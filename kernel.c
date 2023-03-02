extern void main(){
   //while(1);
   __asm__(
      "mov $0x0e, %ah\n"
      "mov $'A', %al\n"
      "int $0x10\n"
      "mov $0x0a, %al\n"
      "int $0x10\n"
      "mov $0x0d, %al\n"
      "int $0x10\n"
   );
   //*(char*)0xb8000 = 'A';
   return;
}
