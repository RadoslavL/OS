OS.bin: main.bin kernel.bin
	cat main.bin kernel.bin > OS.bin

kernel.bin: kernel-asm.o kernel-c.o
	i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel-asm.o kernel-c.o --oformat binary

kernel-asm.o: kernel.s
	nasm kernel.s -f elf -o kernel-asm.o

kernel-c.o: kernel.c
	i386-elf-gcc -ffreestanding -m32 -c kernel.c -o kernel-c.o

main.bin: main.s
	nasm main.s -o main.bin
