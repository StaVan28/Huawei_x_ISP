section .text

extern printf
global _start

main:           mov  rdx, 28
                mov  rsi, hello_str
                mov  rdi, printf_str
                xor  rax, rax
                call printf

                xor rax, rax
                ret

section .data
 hello_str      db      'Hello, world!'         , 0x0a,  0
printf_str      db      "{s = [%d]}, {d = [%d]}", 0x0a,  0