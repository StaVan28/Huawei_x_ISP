;----------------------------------;
;        TEXT                      ;
;----------------------------------;

section .text

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
strlen_cdecl    push rbp
                mov  rbp, rsp
                push rdi

                mov rdi, [rbp + 16]
                call strlen_reg         
                mov rax, rcx
 
                pop rdi 
                pop rbp
                ret

;----------------------------------------------------
; strchr_reg () -- found a symbol RBX in string RDI
;
; Entry: Regs:   RDI -- address of string
;                RBX -- symbol to search for
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
; Exit:  RDI -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RCX RDI
;----------------------------------------------------
strchr_reg      mov  rdx, rdi
                call strlen_reg
                mov  rax, rbx

                mov rdi, rdx
                repne scasb
                dec rdi

                ret

;----------------------------------------------------
; strchr_cdecl () -- found a symbol RBX in string RDI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- symbol to search for
;                2 push -- address of string
;        Consts: NONE
; Call:  strchr_reg () -> ...
; Exit:  RAX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RCX flags
;----------------------------------------------------
strchr_cdecl    push rbp
                mov  rbp, rsp
                push rbx 
                push rdi

                mov  rbx, [rbp + 24]
                mov  rdi, [rbp + 16]
                call strchr_reg
                mov  rax, rdi

                pop rdi
                pop rbx
                pop rbp
                ret

;----------------------------------------------------
; strcpy_reg () -- copy string from RDI to RSI
;
; Entry: Regs:   RSI -- address of src string
;                RDI -- address of cpy string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
; Exit:  RBX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        func don't get memmory to cpy string
; Destr: RAX RBX RCX RSI RDI
;----------------------------------------------------
strcpy_reg      mov rbx, rsi

                push rsi
                call strlen_cdecl
                add  rsp, 8
                mov  rcx, rax

                cld
                rep movsb

                ret

;----------------------------------------------------
; strcpy_cdecl () -- copy string from RSI to RDI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of src  string
;                2 push -- address of dest string
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
;        str_cpy      () -> ...
; Exit:  RDI -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        func don't get memmory to dest string
; Destr: RAX RCX
;----------------------------------------------------
strcpy_cdecl    push rbp
                mov  rbp, rsp
                push rbx
                push rsi
                push rdi

                mov  rsi, [rbp + 24]
                mov  rdi, [rbp + 16]
                call strcpy_reg
                mov  rax, rbx

                pop rdi
                pop rsi 
                pop rbx
                pop rbp
                ret

;----------------------------------------------------
; strcmp_reg () -- compare RSI and RDI
;
; Entry: Regs:   RSI -- address of src  string
;                RDI -- address of dest string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl ()
; Exit:  > 0 -- rsi > rdi
;          0 -- rsi = rdi
;        < 0 -- rsi < rdi
; Note:  '0' NECESSARILY NEEDED IN BOTH STRINGS!!!!1!1!
;        func don't get memory to dest string
; Destr: RAX RBX RCX RDX RDI RSI
;----------------------------------------------------
strcmp_reg      push rsi
                call strlen_cdecl
                add  rsp, 8
                mov  rdx, rax

                push rdi
                call strlen_cdecl
                add  rsp, 8
                mov  rbx, rax

                cmp rbx, rdx
                jl  .bx_less_dx
                
                mov rcx, rdx
                jmp .cmp_str

.bx_less_dx:    mov rcx, rbx
                jmp .cmp_str

.cmp_str:       cld
                repz cmpsb

                mov rax, [rsi - 1]
                sub rax, [rdi - 1]

.exit:          ret

;----------------------------------------------------
; strcmp_cdecl () -- compare RSI and RDI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of src  string
;                2 push -- address of dest string
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
;        strcpy_reg   () -> ...
; Exit:  RAX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        func don't get memory to dest string
; Destr: RAX RCX RDX
;----------------------------------------------------
strcmp_cdecl    push rbp
                mov  rbp, rsp
                push rbx
                push rsi
                push rdi

                mov rsi, [rbp + 24]
                mov rdi, [rbp + 16]
                call strcmp_reg

                pop rdi
                pop rsi
                pop rbx
                pop rbp
                ret

;----------------------------------------------------
; atoi_reg () -- ASCII to 10 int
;
; Entry: Regs:   RDI -- address of string
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  RAX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RBX RDI
;----------------------------------------------------
atoi_reg        xor rax, rax
                
.convert:       xor rbx, rbx
                mov bl, [rdi] 
                cmp bl, 0
                je .exit

                cmp bl, '0'
                jl .error

                cmp bl, '9'
                jg .error

                sub  rbx, '0'
                imul rax, 10
                add  rax, rbx

                inc rdi
                jmp .convert


.error:         mov rax, -1

.exit:          ret

;----------------------------------------------------
; atoi_cdecl () -- ASCII to 10 int
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of string
;        Consts: NONE
; Call:  NONE
; Exit:  RAX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: RAX RBX RDI
;----------------------------------------------------
atoi_cdecl      push rbp
                mov  rbp, rsp
                push rbx
                push rdi

                mov  rdi, [rbp + 16]
                call atoi_reg

                pop rdi
                pop rbx
                pop rbp
                ret

;----------------------------------------------------
; itoa_reg () -- int to ASCII (radix 2, 4, 8, 10, 16)
;
; Entry: Regs:   RCX -- input number
;                RDI -- start of buffer
;                RBX -- radix
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  (RAX = -1 if ERROR)
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        work onle with 2, 4, 8, 10, 16 bases
;        if base = 2/4/8/16, RCX > 0
; Destr: RAX RBX RCX RDX RDI RSI
;----------------------------------------------------
itoa_reg        push rdi                        ; remember start buff

                cmp rbx, 10
                je  .base_10

                push rcx
                mov  rcx, 4                     ; for cycle (max pow 2^4 <--)
                xor  rdx, rdx
                
.pow_loop:      shr rbx, 1                      ;
                jc  .bit_eq_1                   ;
                                                ;
.bit_eq_0:      inc rdx                         ;
                jmp .repeat                     ;
                                                ;
.bit_eq_1:      jmp .end_pow_loop               ;
                                                ;
.repeat:        loop .pow_loop                  ; dx = log_2 (BX -- radix), BX max = 16;

.end_pow_loop:  xor rcx, rcx
                mov rcx, rdx
                pop rdx

.base_2_8_16:   mov  rax, rdx
                shr  rax, cl
                push rax
                shl  rax, cl

                push rdx
                sub  rdx, rax
                mov  rax, rdx
                pop  rdx
                add  rax, DIGITS_TABLE          ; find a digit in table

                mov rsi, rax                    ; 
                cld                             ;
                movsb                           ; fill a string

                mov rax, rdx                    ; for negative numb
                pop rdx                         ; for cycle

                cmp rdx, 0
                jne .base_2_8_16
                jmp .add_last_sym

.base_10:
                push rcx                        ; remeber numb for sign

                cmp rcx, 0
                jge .not_neg_numb

                neg rcx

.not_neg_numb:
.pars_b10:      xor  rdx, rdx                   ;
                mov  rax, rcx                   ; for idiv dx:ax/bx
                idiv rbx                        ;
                push rax                        ; remember quotient
                imul rbx

                push rcx
                sub  rcx, rax
                mov  rax, rcx
                pop  rcx
                add  rax, DIGITS_TABLE          ; find a digit in table

                mov rsi, rax                    ; 
                cld                             ;
                movsb                           ; fill a string

                mov rax, rcx                    ; for negative numb
                pop rcx                         ; for cycle

                cmp rcx, 0
                jne .pars_b10

                pop rax
                cmp rax, 0
                jge .skip_neg_int

                mov byte [rdi], '-'
                inc  rdi

.skip_neg_int:
.add_last_sym:  mov byte [rdi], 0               ; last symb
                dec rdi

                pop rsi                         ; get out start buff

.reverse_str:   mov   al , [rsi]
                mov   ah , [rdi]
                mov [rdi],   al
                dec  rdi
                mov [rsi],   ah
                inc  rsi

                cmp rsi, rdi
                jb  .reverse_str
                jmp .exit

.error:         xor rax, rax
                dec rax

.exit:          ret

;----------------------------------;
;        DATA                      ;
;----------------------------------;

section .data

DIGITS_TABLE:   db      '0123456789abcdef', 0