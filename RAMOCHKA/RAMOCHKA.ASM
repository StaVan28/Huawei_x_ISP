;-------------------------------;
;	MODEL                   ;
;-------------------------------;

.model tiny

;-------------------------------;
;	CONSTS                  ;
;-------------------------------;

LENGTH_SCREEN		equ 080d
 WIDTH_SCREEN		equ 025d

VIDEO_SEG		equ 0b800h
MAX_BIT_ON_SCREEN	=   WIDTH_SCREEN * LENGTH_SCREEN

LT_UP			equ 0c9h
RT_UP			equ 0bbh
LT_DOWN			equ 0c8h
RT_DOWN			equ 0bch
HR_LINE			equ 0cdh
VR_LINE			equ 0bah

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

_START:		
		mov ax, VIDEO_SEG
		mov es, ax

		call clear_screen

		call draw_ramka

		.GETCH_MACRO

		call return

;-------------------------------;
;	FUNCS                   ;
;-------------------------------;

;----------------------------------------------------
; Draw a full ramka
;
; Entry: Regs:   NONE
;        Stack:  NONE
;        Consts:   UP_LINE     -- buff which contains   up of ramka
;                 MID_LINE     -- buff which contains  mid of ramka
;                DOWN_LINE     -- buff which contains down of ramka
;                LENGTH_SCREEN -- length of DOS screen
; Call:  draw_line
; Exit:  NONE
; Note:  ES -- Video segment addres
; Destr: AX BX CX SI DI df zf
;----------------------------------------------------
draw_ramka	proc

		mov si, offset UP_LINE
		mov di, (Y1 * LENGTH_SCREEN + X1) * 2d
		mov cx, X2 - X1

		call draw_line
		
		mov bx, (Y1 * LENGTH_SCREEN + X1) * 2d

draw_body:	mov si, offset MID_LINE
		add bx, LENGTH_SCREEN * 2d
		mov di, bx
		mov cx, X2 - X1

		call draw_line

		cmp bx, (Y2 * LENGTH_SCREEN + X1) * 2d
		jne draw_body

		mov si, offset DOWN_LINE
		mov di, (Y2 * LENGTH_SCREEN + X1) * 2d
		mov cx, X2 - X1

		call draw_line
		
		ret
		endp

;----------------------------------------------------
; Draw a horizontal line
;
; Entry: Regs:   SI -- addres of array print symbols: <Left> <Mid> <Right>
;                DI -- start addr to draw
;                CX -- line length
;        Stack:  NONE
;        Consts: CUR_RAM_COLOR -- a color of ramochochka.
; Call:  NONE
; Exit:  NONE
; Note:  ES -- Video segment addres
; Destr: AX CX SI DI df
;----------------------------------------------------
draw_line	proc

		cld

		mov ah, CUR_RAM_COLOR

		lodsb
		stosw

		lodsb
		rep stosw

		lodsb
		stosw
		
		ret
		endp

;----------------------------------------------------
; Clear a screen with VOID symbol
;
; Entry: Regs:   NONE
;        Stack:  NONE
;        Consts: VOID              -- a filling symbol
;                BLACK_ON_BLACK    -- a color of symb. If use VOID, it's nothing to change 
;                MAX_BIT_ON_SCREEN -- quantity bits on screen
; Call:  NONE
; Exit:  NONE
; Note:  ES -- Video segment addres
; Destr: AX CX DI df
;----------------------------------------------------
clear_screen	proc

		cld

		mov ah, VOID
		mov al, BLACK_ON_BLACK

		mov cx, MAX_BIT_ON_SCREEN

		rep stosw
		stosw				; for last symb

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

  UP_LINE	db LT_UP  , HR_LINE, RT_UP
 MID_LINE	db VR_LINE, SPACE  , VR_LINE
DOWN_LINE	db LT_DOWN, HR_LINE, RT_DOWN

;-------------------------------;
;	END                     ;
;-------------------------------;

end _START