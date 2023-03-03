org 0x7c00
bits 16

init:
  mov [BOOT_DISK], dl
  xor ax, ax
  mov es, ax
  mov ds, ax
  mov bp, 0x8000
  mov sp, bp
  mov bx, KERNEL_LOCATION
  mov dh, 20
  mov ah, 0x02
  mov al, dh
  mov ch, 0x00
  mov dh, 0x00
  mov cl, 0x02
  mov dl, [BOOT_DISK]
  int 0x13
  mov ah, 0x0e
  mov bx, string
  mov si, reserved
  jmp loop

loop:
  mov al, [bx]
  cmp al, 0
  je key_press
  int 0x10
  inc bx
  jmp loop

PS1:
  cmp byte [bx], 0
  je go_back_PS1
  mov ah, 0x0e
  mov al, [bx]
  int 0x10
  inc bx
  jmp PS1

go_back_PS1:
  popa
  jmp key_press

command_not_found:
  cmp byte [bx], 0
  je go_back_command_not_found
  mov al, [bx]
  int 0x10
  inc bx
  jmp command_not_found

go_back_command_not_found:
  popa
  pusha
  mov bx, PS1_env
  jmp PS1

key_press:
  mov ah, 0x00
  int 0x16
  cmp al, 0x21
;  mov si, reserved
  jge compare
  jl other_chars
  jmp key_press

compare:
  cmp al, 0x7e
  jl print
  jmp key_press

print:
  pusha
  mov ah, 0x0e
  int 0x10
  popa
  mov [si], al
  inc si
  jmp key_press

other_chars:
  cmp ah, 0x1C
  je enter
  cmp ah, 0x39
  je space
  cmp al, 0x8
  je backspace
  jmp key_press

enter:
  pusha
  mov ah, 0x0e
  mov al, 0x0a
  int 0x10
  mov al, 0x0d
  int 0x10
  popa
  mov di, reserved
  mov bx, ping_command
  jmp loop1

loop1:
  cmp di, si
  je middle_loop1
  cmp byte [bx], 0
  je go_back_loop1
  mov ch, [di]
  cmp ch, [bx]
  jne go_back_loop1
;  pusha
;  mov ah, 0x0e
;  mov al, [di]
;  int 0x10
;  popa
  inc di
  inc bx
  jmp loop1

go_back_loop1:
  mov si, reserved
  mov bx, ping_command
  pusha
  mov ah, 0x0e
  mov bx, command_not_found_text
  jmp command_not_found
;  pusha
;  mov bx, PS1_env
;  jmp PS1
;  jmp key_press

middle_loop1:
  mov si, reserved
  mov bx, pong
  pusha
  jmp print_ping

print_ping:
  cmp byte [bx], 0
  je go_back_print_ping
  mov ah, 0x0e
  mov al, [bx]
  int 0x10
  inc bx
  jmp print_ping

go_back_print_ping:
  mov al, 0x0a
  int 0x10
  mov al, 0x0d
  int 0x10
  jmp enter_PM
;  mov bx, PS1_env
;  jmp PS1
;  popa
;  jmp key_press

space:
  pusha
  mov ah, 0x0e
  mov al, ' '
  int 0x10
  popa
  mov byte [si], ' '
  inc si
  jmp key_press

backspace:
  cmp si, reserved
  jle key_press
  pusha
  mov ah, 0x0e
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x8
  int 0x10
  popa
  dec si
  jmp key_press

enter_PM:
;  mov ah, 0x0
;  mov al, 0x3
;  int 0x10
  cli
  lidt [IDT_Descriptor]
  lgdt [GDT_Descriptor]
  mov eax, cr0
  or eax, 1
  mov cr0, eax
  jmp CODE_SEG:protected_mode

[bits 32]
protected_mode:
;  mov byte [0xb8000], 'A'
;  jmp halt
  call KERNEL_LOCATION
  jmp halt

halt:
  hlt
  jmp halt

GDT_Start:
  null_descriptor:
    dd 0
    dd 0
  code_descriptor:
    dw 0xffff
    dw 0
    db 0
    db 0b10011010
    db 0b11001111
    db 0
  data_descriptor:
    dw 0xffff
    dw 0
    db 0
    db 0b10010010
    db 0b11001111
    db 0
GDT_End:

GDT_Descriptor:
  dw GDT_End - GDT_Start - 1
  dd GDT_Start

;IDT_Start:
;  KEYBOARD:
;    dw 0x0078
;    dw CODE_SEG
;    db 0
;    db 0b11100001
;    dw 0x0000
;IDT_End:
;
;IDT_Descriptor:
;  dw IDT_End - IDT_Start - 1
;  dd IDT_Start

CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start
KERNEL_LOCATION equ 0x1000
BOOT_DISK db 0
ping_command db "ping", 0
pong db "pong", 0
PS1_env db "admin% ", 0
command_not_found_text db "Command not found!", 0xa, 0xd, 0
string db "It's me! Mario!", 0xa, 0xd, "admin% ", 0
times 510-($-$$) db 0
dw 0xAA55
reserved resb 128

IDT_Start:
  entry:
    dw 0
    dw CODE_SEG
    db 0
    db 0b11100001
    dw 0
  times 256-($-IDT_Start) dq 0 
IDT_End:

IDT_Descriptor:
  dw IDT_End - IDT_Start - 1
  dd IDT_Start
