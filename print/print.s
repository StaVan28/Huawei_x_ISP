;----------------------------------;
;        INCLUDE                   ;
;----------------------------------;

%include "string.s"

extern _calloc, _realloc, _free

;----------------------------------;
;        TEXT                      ;
;----------------------------------;

section .text

global _start

_start:         mov  rdi, my_printf_str
                mov  rsi, 12345
                mov  rdx, 12345
                mov  r10, 12345
                mov  r9 , 12345
                mov  r8 , 12345
                call my_printf

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
; Entry: Regs:   RDI -- string
;                RSI -- 1 arg
;                RDX -- 2 arg
;                R10 -- 3 arg
;                R8  -- 4 arg
;                R9  -- 5 arg
;        Stack:  all others are pushed onto the stack
;        Consts: NONE
; Call:  NONE
; Exit:  Upon successful return, these functions return the number of
;        characters printed {RAX} (excluding the null byte used to end output to
;        strings).
;        If an output error is encountered, a negative value is returned in {RAX}.
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RBX RCX 
;----------------------------------------------------
my_printf       push rbp
                mov  rbp, rsp

                push r9
                push r8
                push r10
                push rdx
                push rsi
                push rdi

                pop rsi                 ; rsi -- string    V
                mov rdi, static_buff    ; rdi -- malloc  > for movs* cmds
                mov  r9, static_buff    ; debug

                xor rdx, rdx            ; arg counter

.pars_str:      cmp byte [rsi], 0
                je  .prep_exit

                cmp byte [rsi], '%'
                je  .jmp_table

                cld
                movsb 
                jmp .pars_str

.jmp_table:     inc rsi

                cmp byte [rsi], 'c'
                je  .c_print

                cmp byte [rsi], 's'
                je  .s_print

                cmp byte [rsi], 'd'
                je  .d_print

                cmp byte [rsi], 'x'
                je  .x_print

                cmp byte [rsi], 'o'
                je  .o_print

                cmp byte [rsi], 'f'
                je  .f_print

                cmp byte [rsi], 'b'
                je  .b_print

                cmp byte [rsi], '%'
                je  .proc_print

                jmp .error

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

.d_print:       call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push 10
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str

.x_print:       call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push 16
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str

.o_print:       call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push 8
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str

.f_print:       call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push 4
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str

.b_print:       call get_adr_arg

                ; overflow 4096
                mov  rbx, [rbx]
                push rbx
                push rdi
                push 2
                call itoa_cdecl
                add  rsp, 24

                add  rdi, rax
                inc  rsi
                jmp .pars_str

.proc_print:    call get_adr_arg

                ; check 4096 overflow
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
; Note:  -- '0' NECESSARILY NEEDED!!!!1!1!
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
; Note:  -- uses rsp
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

static_buff     times   4096 db 0

empty_str       times   32 db 0

hello_str       db      'Hello, world!',  0
len_hello_str   equ     $ - hello_str

my_printf_str   db      '{proc = [%%]}}, {b = [%b]}}, {f = [%f]}, {o = [%o]}, {d = [%d]}}, {x = [%x]}}', 0x0a, 0
