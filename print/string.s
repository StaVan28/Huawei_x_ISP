;----------------------------------;
;        TEXT                      ;
;----------------------------------;

section .text

global _start

_start:         

                mov rax, 0x3C
                xor rdi, rdi
                syscall

;----------------------------------;
;        FUNCS                     ;
;----------------------------------;

;----------------------------------------------------
; strlen_reg () -- count quantity of symbols of string
;
; Entry: Regs:   RDI -- address of start string
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  RCX -- numb of symb
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RCX RDI
;----------------------------------------------------
strlen_reg      cld

                xor rcx, rcx
                dec rcx
                xor rax, rax

                repne scasb

                neg rcx
                sub rcx, 2
                dec di

                ret


;----------------------------------------------------
; strlen_cdecl () -- count quantity of symbols of string
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of start string
;        Consts: NONE
; Call:  strlen_reg ()
; Exit:  RAX -- number of symbols
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RCX
;----------------------------------------------------
strlen_cdecl    proc
                push rbp
                mov  rbp, rsp
                push rdi

                mov rdi, [rbp + 16]
                call strlen_reg         
                mov rax, rcx
 
                pop rdi rbp
                ret 
                endp

;----------------------------------;
;        DATA                      ;
;----------------------------------;

section .data

label DIGITS_TABLE
itoa_table      db      '0123456789abcdef', 0
empty_str       db      32 dup (0)
hello_str       db      'Hello, world!$', 0
len_hello_str   =       $ - hello_str
cpy_str         db      len_hello_str dup (0)
cmp1_str        db      'aello, world!$',    0
cmp2_str        db      'Hellp, world!$',    0
cmp3_str        db      'Hello, world!asd$', 0
