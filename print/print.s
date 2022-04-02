;----------------------------------;
;        INCLUDE                   ;
;----------------------------------;

%include "string.s"

;----------------------------------;
;        DIFINE                    ;
;----------------------------------;

%macro digit_print 1
                call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push %1
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str
%endmacro

;----------------------------------;
;        TEXT                      ;
;----------------------------------;

section .text

; comment for call in c
;global _start

_start:         
                push hello_str
                push 10000
                mov  r9 , 28
                mov  r8 , 28 
                mov  rcx, 28
                mov  rdx, '$'
                mov  rsi, 28
                mov  rdi, my_printf_str
                call my_printf
                add  rsp, 16

                mov rax, 0x3C
                xor rdi, rdi
                syscall

;----------------------------------;
;       END                        ;
;----------------------------------;

;----------------------------------;
;       FUNCS                      ;
;----------------------------------;


;----------------------------------------------------
; my_printf () -- print string in stdout
; {stdcall convention}
;
; Entry: Regs:   R9  -- 5 arg
;                R8  -- 4 arg
;                RCX -- 3 arg
;                RDX -- 2 arg
;                RSI -- 1 arg
;                RDI -- string
;        Stack:  all others are pushed onto the stack in back order
;        Consts: NONE
; Call:  NONE
; Exit:  Upon successful return, these functions return the number of
;        characters printed {RAX} (excluding the null byte used to end output to
;        strings).
;        If an output error is encountered, a negative value is returned in {RAX}.
; Note:  '0' IS NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RBX RCX
;----------------------------------------------------
global my_printf
my_printf       push rbp
                mov  rbp, rsp

                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rdi

                pop rsi                 ; rsi -- string    V
                mov rdi, static_buff    ; rdi -- static buff for copy
                mov r9 , static_buff

                xor rdx, rdx            ; arg counter

                cld
.pars_str:      cmp byte [rsi], 0
                je  .prep_exit

                cmp byte [rsi], '%'
                je  .spec_format

                movsb 
                jmp .pars_str

.spec_format:   inc rsi

                xor rax,  rax
                mov  al, [rsi]

                cmp rax, '%'
                je  .prec_print

                cmp rax, 'b'
                jl  .skip_place

                cmp rax, 'x'
                ja  .skip_place

                mov rax, [jump_table + 8 * (rax - 'b')]
                jmp rax

.skip_place:    inc rsi
                jmp .pars_str

.c_print:       call get_adr_arg

                mov  rcx, [rbx]
                ; check 4096 overflow
                mov [rdi], rcx
                inc  rdi

                inc  rsi
                jmp .pars_str

.s_print:       call get_adr_arg

                mov  rax, [rbx]
                push rax
                call strlen_cdecl
                add rsp, 8
                mov rcx, rax
                ; check 4096 overflow

                xor  rax,  rax
                mov  rax, [rbx]

                push rdx
.loop_str:      mov   dl , byte [rax]
                mov [rdi], rdx
                inc  rdi
                inc  rax
                loop .loop_str
                pop  rdx

                inc  rsi
                jmp .pars_str

.x_print:       digit_print 16

.d_print:       digit_print 10

.o_print:       digit_print 8

.f_print:       digit_print 4

.b_print:       digit_print 2

.prec_print:    ; check 4096 overflow
                mov byte [rdi], '%'
                inc  rdi
                inc  rsi
                jmp .pars_str

.error:         mov rax, -1
                jmp .exit

.prep_exit:     ; check 4096 overflow
                mov byte [rdi], 0
                inc  rdi

                call print_buff

                sub rdi, rbp
                mov rax, rdi

.exit:          add rsp, 40
                pop rbp
                ret

;----------------------------------------------------
; print_buff () -- withdraw buff on screen
;
; Entry: Regs:   RDI -- start buff to print
;                R9  -- ptr stack
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  RAX -- On success, the number of bytes written is returned.  
;               On error, -1 is returned.
; Note:  -- '0' NECESSARILY NEEDED!!!!1!1!111111
; Destr: RAX
;----------------------------------------------------
print_buff      push rdi
                push rsi
                push rdx
                
                sub rdi, r9
                mov rdx, rdi    

                mov rax, 0x01
                mov rdi, 1 
                mov rsi, r9
                syscall

                pop rdx
                pop rsi
                pop rdi

                ret

;----------------------------------------------------
; print_buff () -- withdraw buff on screen
;
; Entry: Regs:   RDX -- num of args
;                RSP -- stack pointer
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  RBX -- addr arg
; Note:  -- uses RSP
; Destr: RBX 
;----------------------------------------------------
get_adr_arg     xor rbx, rbx
                cmp rdx, 5
                jl .reg_arg

                add  rbx, 2

.reg_arg:       add  rbx, rdx
                inc  rdx
                imul rbx, 8
                add  rbx, rsp
                add  rbx, 8

                ret

;----------------------------------;
;        DATA                      ;
;----------------------------------;

section .data

jump_table      dq      my_printf.b_print   , my_printf.c_print   , my_printf.d_print   , my_printf.skip_place, \
                        my_printf.f_print   , my_printf.skip_place, my_printf.skip_place, my_printf.skip_place, \
                        my_printf.skip_place, my_printf.skip_place, my_printf.skip_place, my_printf.skip_place, \
                        my_printf.skip_place, my_printf.o_print   , my_printf.skip_place, my_printf.skip_place, \
                        my_printf.skip_place, my_printf.s_print   , my_printf.skip_place, my_printf.skip_place, \
                        my_printf.skip_place, my_printf.skip_place, my_printf.x_print

static_buff     times   4096 db 0
empty_str       times   64   db 0

love_str        db      "love"         , 0
hello_str       db      'Hello, world!', 0
len_hello_str   equ     $ - hello_str

my_printf_str   db      "{b = [%b]}, {c = [%c]}, {d = [%d]}, {f = [%f]}," , 0x0a, \
                        "{o = [%o]}, {x = [%x]}, {pr = [%h]}, {s = [%s]}}", 0x0a, 0
