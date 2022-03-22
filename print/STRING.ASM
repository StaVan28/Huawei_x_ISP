;-------------------------------;
;	MODEL                   ;
;-------------------------------;

.186
.model tiny

locals @@

;-------------------------------;
;	MACROS                  ;
;-------------------------------;

.GETCH_MACRO	macro
		nop
		xor ah, ah
		int 16h
		nop
		endm

;-------------------------------;
;	CODE                    ;
;-------------------------------;

.code
org 100h

;-------------------------------;
;	START                   ;
;-------------------------------;

_START:		dec ax
		dec bx
		dec cx
		dec dx
		dec si
		dec di

		mov cx, 12345d
		mov di, offset empty_str
		mov bx, 10d
		call itoa_reg

		mov si, offset hello_str
		mov di, offset  cmp2_str
		call strcmp_reg

		push offset hello_str
		push offset   cpy_str
		call strcpy_cdecl

		mov si, offset hello_str
		mov di, offset   cpy_str
		call strcpy_reg

		mov di, offset hello_str
		mov bx, 'w'
		call strchr_reg

		mov di, offset hello_str
		call strlen_reg

		push offset hello_str
		call strlen_cdecl

		call return

;-------------------------------;
;	FUNCS                   ;
;-------------------------------;

;----------------------------------------------------
; strlen_reg () -- count quantity of symbols of string
;
; Entry: Regs:   DI -- address of start string
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  CX -- numb of symb
;        DI -- address of system symb
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX DI
;----------------------------------------------------
strlen_reg	proc

		cld

		xor cx, cx
		dec cx
		xor ax, ax
		repne scasb
		neg cx
		sub cx, 2
		dec di

		ret
		endp

;----------------------------------------------------
; strlen_cdecl () -- count quantity of symbols of string
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of start string
;        Consts: NONE
; Call:  strlen_reg ()
; Exit:  AX -- number of symbols
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX
;----------------------------------------------------
strlen_cdecl	proc
		push bp
		mov  bp, sp
		push di

		mov di, [bp + 4]
		call strlen_reg		
		mov ax, cx
 
		pop di bp
		ret 
		endp

;----------------------------------------------------
; strchr_reg () -- found a symbol BX in string DI
;
; Entry: Regs:   DI -- address of string
;                BX -- symbol to search for
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
; Exit:  DI -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX DI
;----------------------------------------------------
strchr_reg	proc

		mov dx, di
		call strlen_reg
		mov ax, bx

		mov di, dx
		repne scasb
		dec di

		ret
		endp

;----------------------------------------------------
; strchr_cdecl () -- found a symbol BX in string DI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- symbol to search for
;                2 push -- address of string
;        Consts: NONE
; Call:  strchr_reg () -> ...
; Exit:  AX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX flags
;----------------------------------------------------
strchr_cdecl	proc
		push bp
		mov  bp, sp
		push bx di

		mov bx, [bp + 6]
		mov di, [bp + 4]
		call strchr_reg
		mov ax, di

		pop di bx
		pop bp
		ret
		endp

;----------------------------------------------------
; strcpy_reg () -- copy string from DI to SI
;
; Entry: Regs:   SI -- address of src string
;                DI -- address of cpy string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
; Exit:  BX -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        func don't get memmory to cpy string
; Destr: AX BX CX SI DI flags
;----------------------------------------------------
strcpy_reg	proc

		mov bx, si

		push si
		call strlen_cdecl
		add sp, 2
		mov cx, ax

		cld
		rep movsb

		ret
		endp

;----------------------------------------------------
; strcpy_cdecl () -- copy string from SI to DI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of src  string
;                2 push -- address of dest string
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
;	 str_cpy      () -> ...
; Exit:  DI -- address of required character
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        func don't get memmory to dest string
; Destr: AX CX
;----------------------------------------------------
strcpy_cdecl	proc
		push bp
		mov  bp, sp
		push bx si di

		mov si, [bp + 6]
		mov di, [bp + 4]
		call strcpy_reg
		mov ax, bx

		pop di si bx
		pop bp
		ret
		endp

;----------------------------------------------------
; strcmp_reg () -- compare SI and DI
;
; Entry: Regs:   SI -- address of src  string
;                DI -- address of dest string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl ()
; Exit:  > 0 -- si > di
;          0 -- si = di
;        < 0 -- si < di
; Note:  '0' NECESSARILY NEEDED IN BOTH STRINGS!!!!1!1!
;        func don't get memory to dest string
; Destr: AX BX CX DX DI SI
;----------------------------------------------------
strcmp_reg	proc

		push si
		call strlen_cdecl
		add sp, 2
		mov dx, ax

		push di
		call strlen_cdecl
		add sp, 2
		mov bx, ax

		cmp bx, dx
		jl @@bx_less_dx
		
		mov cx, dx
		jmp @@cmp_str

@@bx_less_dx:	mov cx, bx
		jmp @@cmp_str

@@cmp_str:	cld
		repz cmpsb

		mov al, [si - 1]
		sub al, [di - 1]
		xor ah, ah

@@exit:		ret
		endp

;----------------------------------------------------
; strcmp_cdecl () -- compare SI and DI
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of src  string
;                2 push -- address of dest string
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
;	 strcpy_reg   () -> ...
; Exit:  AX -- address of required character
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
;        func don't get memory to dest string
; Destr: AX CX DX
;----------------------------------------------------
strcmp_cdecl	proc
		push bp
		mov  bp, sp
		push bx si di

		mov si, [bp + 6]
		mov di, [bp + 4]
		call strcmp_reg

		pop di si bx
		pop bp
		ret
		endp

;----------------------------------------------------
; atoi_reg () -- ASCII to 10 int
;
; Entry: Regs:   DI -- address of string
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  AX -- address of required character
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
; Destr: AX BX DI
;----------------------------------------------------
atoi_reg	proc

		xor ax, ax

@@convert:	mov bx, [di]
		xor bh, bh 
		cmp bx, '$'
		je @@exit

		cmp bx, '0'
		jl @@error

		cmp bx, '9'
		jg @@error

		sub  bx, '0'
		imul ax, 10
		add  ax, bx

		inc di
		jmp @@convert

@@error:	mov ax, -1

@@exit:		ret
		endp

;----------------------------------------------------
; atoi_reg () -- ASCII to 10 int
;
; Entry: Regs:   NONE
;        Stack:  1 push -- address of string
;        Consts: NONE
; Call:  NONE
; Exit:  AX -- address of required character
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
; Destr: AX BX DI
;----------------------------------------------------
atoi_cdecl	proc
		push bp
		mov  bp, sp
		push bx di

		mov di, [bp + 4]
		call atoi_reg

		pop di bx
		pop bp
		ret
		endp

;----------------------------------------------------
; itoa_reg () -- int to ASCII (radix 2, 8, 10)
;
; Entry: Regs:   CX -- input number
;                DI -- start of buffer
;                BX -- radix
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  (AX = -1 if ERRROR)
; Note:  '0' NECESSARILY NEEDED!!!!1!1!
;        work onle with 2, 4, 8, 10, 16 bases
;        if base = 2/4/8/16, cx > 0
; Destr: AX BX CX DX DI SI
;----------------------------------------------------
itoa_reg	proc
		push di				; remember start buff

		cmp bx, 10
		je  @@base_10

		push cx
		mov  cx, 4			; for cycle (max pow 2^4 <--)
		xor  dx, dx
		
@@pow_loop:	shr bx, 1			;
		jc  @@bit_eq_1			;
						;
@@bit_eq_0:	inc dx				;
		jmp @@repeat			;
						;
@@bit_eq_1:	jmp @@end_pow_loop		;
						;
@@repeat:	loop @@pow_loop			; dx = log_2 (BX -- radix), BX max = 16;

@@end_pow_loop:	mov cx, dx
		xor ch, ch
		pop dx

@@base_2_8_16:	mov  ax, dx
		shr  ax, cl
		push ax
		shl  ax, cl

		push dx
		sub  dx, ax
		mov  ax, dx
		pop  dx
		add  ax, offset DIGITS_TABLE	; find a digit in table

		mov si, ax			; 
		cld				;
		movsb				; fill a string

		mov ax, dx			; for negative numb
		pop dx				; for cycle

		cmp dx, 0
		jne @@base_2_8_16
		jmp @@add_last_sym

@@base_10:
		push cx				; remeber numb for sign

		cmp cx, 0
		jge @@not_neg_numb

		neg cx

@@not_neg_numb:
@@pars_b10:	xor  dx, dx			;
		mov  ax, cx			; for idiv dx:ax/bx
		idiv bx				;
		push ax 			; remember quotient
		imul bx 			

		push cx
		sub  cx, ax
		mov  ax, cx
		pop  cx
		add  ax, offset DIGITS_TABLE	; find a digit in table

		mov si, ax			; 
		cld				;
		movsb				; fill a string

		mov ax, cx			; for negative numb
		pop cx				; for cycle

		cmp cx, 0
		jne @@pars_b10

		pop ax
		cmp ax, 0
		jge @@skip_neg_int

		mov byte ptr [di], '-'
		inc di

@@skip_neg_int:
@@add_last_sym: mov byte ptr [di], 0		; last symb
		dec di

		pop si				; get out start buff

@@reverse_str: 	mov       al     , byte [si - 1]
		mov       ah     , byte [di - 1]
		mov byte [di - 1],       al
		dec di
		mov byte [si - 1],       ah
		inc si

		cmp si, di
		jb  @@reverse_str
		jmp @@exit

@@error:	xor ax, ax
		dec ax

@@exit:		ret
		endp

;TODO:
;3) 2, 8, 16

;----------------------------------------------------
; Return to DOS
;
; Entry: Regs:   NONE
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  NONE
; Note:  NONE
; Destr: AX 
;----------------------------------------------------
return		proc
		
		mov ax, 4c00h
		int 21h
			
		ret
		endp

;-------------------------------;
;	DATA                    ;
;-------------------------------;

.data
label DIGITS_TABLE
itoa_table	db	'0123456789abcdef', 0
empty_str	db	32 dup (0)
hello_str	db	'Hello, world!$', 0
len_hello_str	=	$ - hello_str
cpy_str		db	len_hello_str dup (0)
cmp1_str	db	'aello, world!$',    0
cmp2_str	db	'Hellp, world!$',    0
cmp3_str	db	'Hello, world!asd$', 0
numb		db	'123$'


;-------------------------------;
;	END                     ;
;-------------------------------;

end _START