.model tiny
.code
org 100h

;-------------------------------
;	CONSTS
;-------------------------------

LNGTH			equ 80d
WDTH			equ 25d

VIDEOSEG		equ 0b800h
MAX_BIT_ON_SCREEN	equ ((WDTH - 1) * LNGTH + (LNGTH - 1)) * 2d

LT_UP			equ 0c9h
RT_UP			equ 0bbh
LT_DOWN			equ 0c8h
RT_DOWN			equ 0bch
HR_LINE			equ 0cdh
VR_LINE			equ 0bah
SPACE			equ 020h

BLACK_ON_RED		equ 040h
GREEN_ON_BLUE		equ 012h
BLACK_ON_BLACK		equ 000h

;-------------------------------
;	CURRENT SETTINGS
;-------------------------------

X1		equ 10d
Y1		equ 5d
X2		equ 70d
Y2		equ 20d

CUR_COLOR 	equ GREEN_ON_BLUE

;-------------------------------
;	MACROS
;-------------------------------

.GETCH_MACRO	macro
		nop
		xor ah, ah
		int 16h
		nop
		endm

;-------------------------------
;	CODE
;-------------------------------

_start:		mov ax, VIDEOSEG
		mov es, ax

		xor bx, bx

empty_screen:							; \
		mov byte ptr es:[bx    ], SPACE			; |
		mov byte ptr es:[bx + 1], BLACK_ON_BLACK	; |
		add bx, 2d					; | create empty screen 
								; |
		cmp bx, MAX_BIT_ON_SCREEN			; |
		jne empty_screen				; /

		mov byte ptr es:[(Y1 * LNGTH + X1) * 2d    ], LT_UP    	; \
		mov byte ptr es:[(Y1 * LNGTH + X1) * 2d + 1], CUR_COLOR	; |
		mov byte ptr es:[(Y1 * LNGTH + X2) * 2d    ], RT_UP    	; | 
		mov byte ptr es:[(Y1 * LNGTH + X2) * 2d + 1], CUR_COLOR	; | create angles
		mov byte ptr es:[(Y2 * LNGTH + X1) * 2d    ], LT_DOWN  	; |
		mov byte ptr es:[(Y2 * LNGTH + X1) * 2d + 1], CUR_COLOR	; |
		mov byte ptr es:[(Y2 * LNGTH + X2) * 2d    ], RT_DOWN  	; |	
		mov byte ptr es:[(Y2 * LNGTH + X2) * 2d + 1], CUR_COLOR	; /	


; create horizontal line				---{
		xor ax, ax
		mov bx, (Y2 * LNGTH + X1) * 2d

hor_lines:
		sub bx, ((Y2 - Y1) * LNGTH - 1) * 2d
		mov byte ptr es:[bx    ], HR_LINE
		mov byte ptr es:[bx + 1], CUR_COLOR

		add bx, (Y2 - Y1) * LNGTH * 2d
		mov byte ptr es:[bx    ], HR_LINE
		mov byte ptr es:[bx + 1], CUR_COLOR

		inc ax

		cmp ax, X2 - X1 - 1d
		jne hor_lines
;							---}


; create vertical lines					---{
		xor ax, ax
		mov bx, (Y1 * LNGTH + X2) * 2d		

ver_lines:
		add bx, (LNGTH - (X2 - X1)) * 2d
		mov byte ptr es:[bx    ], VR_LINE
		mov byte ptr es:[bx + 1], CUR_COLOR

		add bx, (X2 - X1) * 2d
		mov byte ptr es:[bx    ], VR_LINE
		mov byte ptr es:[bx + 1], CUR_COLOR

		inc ax

		cmp ax, Y2 - Y1 - 1d
		jne ver_lines
;							---}

		.GETCH_MACRO

return:
		mov ax, 4c00h
		int 21h

end _start																																																																										