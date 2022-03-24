;----------------------------------;
;        INCLUDE                   ;
;----------------------------------;

%include "string.s"

;----------------------------------;
;        TEXT                      ;
;----------------------------------;

section .text

global _start

_start:         mov  rcx, -123456
                mov  rdi, empty_str
                mov  rbx, 10
                call itoa_reg

                mov rax, 0x01
                mov rdi, 1
                mov rsi, empty_str
                mov rdx, 7
                syscall

                mov rax, 0x3C
                xor rdi, rdi
                syscall

;----------------------------------;
;       END                        ;
;----------------------------------;

;----------------------------------;
;        DATA                      ;
;----------------------------------;

section .data

empty_str       times   32 db 0
cpy_str         times   32 db 0

hello_str       db      'Hello, world!',    0x0a, 0
len_hello_str   equ     $ - hello_str

cmp1_str        db      'aello, world!',    0x0a, 0
cmp2_str        db      'Hellp, world!',    0x0a, 0
cmp3_str        db      'Hello, world!asd', 0x0a, 0

Msg             db      "__Hllwrld", 0x0a, 0
MsgLen          equ     $ - Msg

numb1_str       db      "123",  0
numb2_str       db      "9876", 0