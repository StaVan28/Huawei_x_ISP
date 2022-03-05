;-------------------------------;
;	MODEL                   ;
;-------------------------------;

.186
.model tiny

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

_START:	;	mov ax, offset hello_str
	;	mov bx, offset hello_str
	;	mov cx, offset hello_str
	;	mov dx, offset hello_str
	;	mov si, offset hello_str
	;	mov di, offset hello_str

		push offset numb
		call atoi_cdecl
		add sp, 2

		mov di, offset numb 
		call atoi_reg

		push offset hello_str
		push offset  cmp1_str
		call strcmp_cdecl
		add sp, 4

		mov si, offset hello_str
		mov di, offset  cmp1_str
		call strcmp_reg

		push offset hello_str
		push offset   cpy_str
		call strcpy_cdecl
		add sp, 4

		mov si, offset hello_str
		mov di, offset cpy_str
		call strcpy_reg

		mov bx, '!'
		mov di, offset hello_str
		call strchr_reg

		push '!'
		push offset hello_str
		call strchr_cdecl
		add sp, 4

		push offset hello_str
		call strlen_cdecl
		add sp, 2

		mov cx, offset hello_str
		call strlen_reg

		call return

;-------------------------------;
;	FUNCS                   ;
;-------------------------------;

;----------------------------------------------------
; strlen_reg () -- count quantity of symbols of string
;
; Entry: Regs:   CX -- address of start string
;        Stack:  NONE
;        Consts: NONE
; Call:  NONE
; Exit:  DI -- number of symbols
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
;        '$' also count (empl: "Hey!$" -- 5 symb)
; Destr: AX CX DI zf af
;----------------------------------------------------
strlen_reg	proc

		mov di, cx
		mov al, '$'
		repne scasb

		sub di, cx
		sar di, 1

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
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
;        '$' also count (empl: "Hey!$" -- 5 symb)
; Destr: AX CX
;----------------------------------------------------
strlen_cdecl	proc
		push bp
		mov  bp, sp
		push di
		sub  sp, 2

		mov cx, [bp + 4]
		call strlen_reg		
		mov ax, di
 
		add sp, 2
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
; Call:  strlen_cdecl () -> strlen_reg ()
; Exit:  DI -- address of required character
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX DI pf zf
;----------------------------------------------------
strchr_reg	proc

		push di
		call strlen_cdecl
		add sp, 2
		mov cx, ax
		mov ax, bx

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
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
; Destr: AX CX flags
;----------------------------------------------------
strchr_cdecl	proc
		push bp
		mov  bp, sp
		push bx di
		sub  sp, 4

		mov bx, [bp + 6]
		mov di, [bp + 4]
		call strchr_reg
		mov ax, di

		add sp, 4
		pop di bx
		pop bp
		ret
		endp

;----------------------------------------------------
; strcpy_reg () -- copy string from SI to DI
;
; Entry: Regs:   DI -- address of dest string
;                SI -- address of src  string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl () -> ...
; Exit:  BX -- address of required character
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
;        func don't get momery to dest string
; Destr: AX BX CX SI DI flags
;----------------------------------------------------
strcpy_reg	proc

		mov bx, di

		push di
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
; Note:  '$' NECESSARILY NEEDED!!!!1!1!
;        func don't get memory to dest string
; Destr: AX CX
;----------------------------------------------------
strcpy_cdecl	proc
		push bp
		mov  bp, sp
		push bx si di
		sub  sp, 6

		mov si, [bp + 6]
		mov di, [bp + 4]
		call strcpy_reg
		mov ax, bx

		add sp, 6
		pop di si bx
		pop bp
		ret
		endp

;----------------------------------------------------
; strcmp_reg () -- compare SI and DI
;
; Entry: Regs:   DI -- address of dest string
;                SI -- address of src  string
;        Stack:  NONE
;        Consts: NONE
; Call:  strlen_cdecl ()
; Exit:  AX -- address of required character
; Note:  '$' NECESSARILY NEEDED IN BOTH STRINGS!!!!1!1!
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

		dec si
		mov ax, [si]
		xor ah, ah

		dec di
		mov cx, [di]
		xor ch, ch

		cmp ax, '$'
		je  @@eq_$

		cmp cx, '$'
		je  @@eq_$

		cmp ax, cx
		jg @@ret_g
		je @@ret_e
		jl @@ret_l

@@eq_$:		cmp dx, bx
		jg @@ret_g
		je @@ret_e
		jl @@ret_l

@@ret_g:	mov ax, 1
		jmp @@exit

@@ret_e:	mov ax, 0
		jmp @@exit

@@ret_l:	mov ax, -1
		jmp @@exit

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
		sub  sp, 6

		mov si, [bp + 6]
		mov di, [bp + 4]
		call strcmp_reg

		add sp, 6
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
		je @@return

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

@@return:	ret
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
		sub  sp, 4

		mov di, [bp + 4]
		call atoi_reg

		add sp, 4
		pop di bx
		pop bp
		ret
		endp

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
hello_str	db	'Hello, world!$'
len_hello_str	=	$ - hello_str
cpy_str		db	len_hello_str dup (0)
cmp1_str	db	'aello, world!$'
cmp2_str	db	'Hellp, world!$'
cmp3_str	db	'Hello, world!asd$'
numb		db	'123$'


;-------------------------------;
;	END                     ;
;-------------------------------;

end _START