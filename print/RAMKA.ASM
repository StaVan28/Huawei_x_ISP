;-------------------------------;
;	MODEL                   ;
;-------------------------------;

.186
.model tiny

;-------------------------------;
;	CONSTS                  ;
;-------------------------------;

LENGTH_SCREEN		equ 080d
 WIDTH_SCREEN		equ 025d

VIDEO_SEG		equ 0b800h
MAX_BYTE_ON_SCREEN	=   WIDTH_SCREEN * LENGTH_SCREEN

SN_LT_UP		equ 0dah
SN_RT_UP		equ 0bfh
SN_LT_DOWN		equ 0c0h
SN_RT_DOWN		equ 0d9h
SN_HR_LINE		equ 0c4h
SN_VR_LINE		equ 0b3h

DB_LT_UP		equ 0c9h
DB_RT_UP		equ 0bbh
DB_LT_DOWN		equ 0c8h
DB_RT_DOWN		equ 0bch
DB_HR_LINE		equ 0cdh
DB_VR_LINE		equ 0bah

SPACE			equ 020h
VOID			equ 000h

BLACK_ON_RED		equ 040h
GREEN_ON_BLUE		equ 012h
BLACK_ON_BLACK		equ 000h
GREY_ON_BLACK		equ 008h
BLACK_ON_CYAN		equ 030h

;-------------------------------;
;	CURRENT SETINGS         ;
;-------------------------------;

X1		equ 010d
Y1		equ 005d
X2		equ 070d
Y2		equ 020d

CUR_RAM_COLOR 	equ GREEN_ON_BLUE
CUR_BCK_COLOR	equ GREY_ON_BLACK

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

_START:		mov ax, VIDEO_SEG
		mov es, ax

		call pars_com_line

		mov ah, CUR_BCK_COLOR
		call clear_screen

		mov ah, CUR_RAM_COLOR
		call draw_ramka

		.GETCH_MACRO

		call return

;-------------------------------;
;	FUNCS                   ;
;-------------------------------;

;----------------------------------------------------
; Parsing command line
;
; Entry: Comd line: Enter: {<file_name> [1..3]}
;	 Regs:      NONE
;        Stack:     NONE
;        Consts:    CUR_STYLE_ADR -- fill a buff for address style
; Call:  NONE
; Exit:  ref Consts (CUR_STYLE_ADR)
; Note:  NONE
; Destr: BX
;----------------------------------------------------
pars_com_line	proc

		mov bl, cs:[82h]
		sub bl, '0'
		sub bl, 1

		cmp bl, -1
		je @@cmd_symb

		xor bh, bh
		shl bx, 4
		add bx, offset START_OF_ARRAYS
		mov CUR_STYLE_ADR, bx
		jmp @@ret

@@cmd_symb:
		mov CUR_STYLE_ADR, 82h
		jmp @@ret

@@ret:
		ret
		endp

;----------------------------------------------------
; Draw a full ramka
;
; Entry: Regs:   AH            -- a color of symb.
;        Stack:  NONE
;        Consts:   UP_LINE     -- buff which contains   up of ramka
;                 MID_LINE     -- buff which contains  mid of ramka
;                DOWN_LINE     -- buff which contains down of ramka
;                LENGTH_SCREEN -- length of DOS screen
; Call:  draw_line
; Exit:  NONE
; Note:  ES -- Video segment address
; Destr: AX BX CX SI DI df zf
;----------------------------------------------------
draw_ramka	proc

		mov si, CUR_STYLE_ADR
		mov di, (Y1 * LENGTH_SCREEN + X1) * 2d
		mov cx, X2 - X1

		call draw_line
		
		mov bx, (Y1 * LENGTH_SCREEN + X1) * 2d

@@draw_body:	mov si, CUR_STYLE_ADR
		add si, 3d
		add bx, LENGTH_SCREEN * 2d
		mov di, bx
		mov cx, X2 - X1

		call draw_line

		cmp bx, (Y2 * LENGTH_SCREEN + X1) * 2d
		jne @@draw_body

		mov si, CUR_STYLE_ADR
		add si, 6d
		mov di, (Y2 * LENGTH_SCREEN + X1) * 2d
		mov cx, X2 - X1

		call draw_line
		
		ret
		endp

;----------------------------------------------------
; Draw a horizontal line
;
; Entry: Regs:   AH            -- color for ramochka
;                SI            -- address of array print symbols: <Left> <Mid> <Right>
;                DI            -- start addr to draw
;                CX            -- line length in symbols
;        Stack:  NONE
;        Consts: CUR_RAM_COLOR -- a color of ramochochka.
; Call:  NONE
; Exit:  NONE
; Note:  ES -- Video segment address
; Destr: AX CX SI DI df
;----------------------------------------------------
draw_line	proc

		cld

		lodsb
		stosw

		lodsb
		rep stosw

		lodsb
		stosw
		
		ret
		endp

;----------------------------------------------------
; Clear a screen with color in AH reg
;
; Entry: Regs:   AH                 -- a color of symb.
;        Stack:  NONE
;        Consts: VOID               -- a filling symbol
;                MAX_BYTE_ON_SCREEN -- quantity bits on screen
; Call:  NONE
; Exit:  NONE
; Note:  ES -- Video segment address
; Destr: AX CX DI df
;----------------------------------------------------
clear_screen	proc

		cld

		mov al, VOID 

		xor di, di
		mov cx, MAX_BYTE_ON_SCREEN

		rep stosw

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
label START_OF_ARRAYS
SINGLE_LINE	db SN_LT_UP,   SN_HR_LINE, SN_RT_UP,   \
                   SN_VR_LINE, SPACE,      SN_VR_LINE, \ 
                   SN_LT_DOWN, SN_HR_LINE, SN_RT_DOWN, 7 dup (0)
DOUBLE_LINE	db DB_LT_UP  , DB_HR_LINE, DB_RT_UP,   \
		   DB_VR_LINE, SPACE     , DB_VR_LINE, \
		   DB_LT_DOWN, DB_HR_LINE, DB_RT_DOWN, 7 dup (0)
RANDOM_LINE	db 012d,       012d,       012d,       \
                   012d,       003h,       012d,       \
                   012d,       012d,       012d,       7 dup (0)

CUR_STYLE_ADR	dw 1 dup (0)

;-------------------------------;
;	END                     ;
;-------------------------------;

end _START