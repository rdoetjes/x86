.MODEL tiny

.STACK 100h

PALETTE_INDEX EQU 3c8h
PALETTE_DATA EQU 3c9h
INPUT_STATUS EQU 3dah
HRETRACE EQU 01h
VRETRACE EQU 08h
BAR_WIDTH EQU 10

.DATA
	barPallete db 10, 20, 30, 40, 60, 40, 30, 20, 10, 5, 5
	;https://daycounter.com/Calculators/Sine-Generator-Calculator.phtml
	sine 	dw 188,192,197,201,206,210,215,220,224,229,233,238,242,246,251,255
		dw 259,263,268,272,276,280,284,288,292,295,299,303,306,310,313,317
		dw 320,323,326,329,332,335,338,341,343,346,348,351,353,355,357,359
		dw 361,362,364,366,367,368,369,370,371,372,373,374,374,374,375,375
		dw 375,375,375,374,374,374,373,372,371,370,369,368,367,366,364,362
		dw 361,359,357,355,353,351,348,346,343,341,338,335,332,329,326,323
		dw 320,317,313,310,306,303,299,295,292,288,284,280,276,272,268,263
		dw 259,255,251,246,242,238,233,229,224,220,215,210,206,201,197,192
		dw 188,183,178,174,169,165,160,155,151,146,142,137,133,129,124,120
		dw 116,112,107,103,99,95,91,87,83,80,76,72,69,65,62,58
		dw 55,52,49,46,43,40,37,34,32,29,27,24,22,20,18,16
		dw 14,13,11,9,8,7,6,5,4,3,2,1,1,1,0,0
		dw 0,0,0,1,1,1,2,3,4,5,6,7,8,9,11,13
		dw 14,16,18,20,22,24,27,29,32,34,37,40,43,46,49,52
		dw 55,58,62,65,69,72,76,80,83,87,91,95,99,103,107,112
		dw 116,120,124,129,133,137,142,146,151,155,160,165,169,174,178,183
  sineend:
  r    db 00
  g    db 00
  b    db 00
.CODE
	;used for keypress exit
	include STDFUNC.ASM

MAIN PROC
	;initialize the program
	mov ax,SEG _DATA
	mov ds, ax
	mov di, 0
_loop:
	call vertRetrace
	mov cx, 0ffffh                  ;set line count back to 0, after retrace
	mov bx, word ptr sine[di] 	;get next bar start position from table

_wait4line:
	call horizRetrace
	inc cx
	cmp cx, bx
	jne _wait4line

	call drawBar

	add di, 2 ;move to next index in the sine table
	cmp di, (sineend - sine)
	jle continueTable
	;reset di counter
	mov di, 0

continueTable:
	sti

	;if key pressed then exit
	call KeyPressExit

	jmp _loop
MAIN ENDP

drawBar PROC
	push si
	push ax

	mov si, BAR_WIDTH
_barLines:
	mov al, byte ptr barPallete[si]
	mov [r], al
	mov [g], al
	mov [b], al
	call drawRasterLine
	call horizRetrace
	dec si
	jnz _barLines

	mov al, 0
	mov [r], al
	mov [b], al
	mov [g], al
	call drawRasterline

	pop ax
	pop si
	ret
drawBar ENDP

;
; @Desc:	Wait for a vertical retrace of the electron beam
; @Input:	None
;
; @Globbers: 	dx, al
; @Returns:	None

vertRetrace PROC
	;wait for a vertical retrace
	cli
	mov dx, INPUT_STATUS

_v1:	in al, dx
	and al, VRETRACE
	jnz _v1

_v2:	in al, dx
	and al, VRETRACE
	jz _v2
	sti

	ret
vertRetrace ENDP

;
; @Desc:	Wait for a horizontal retrace of the electron beam
; @Input:	None
;
; @Globbers: 	dx, al
; @Returns:	None
horizRetrace PROC
	;wait for horizontal retrace
	cli
	mov dx, INPUT_STATUS

_h1:	in al, dx
	and al, HRETRACE
	jnz _h1

_h2:	in al, dx
	and al, HRETRACE
	jz _h2

	ret
horizRetrace ENDP

drawRasterLine PROC
	;now set the color of the scan line to black
	mov dx, PALETTE_INDEX
	mov al, 00h
	out dx, al

	;this is the current scanline so set the color not to black
	mov al, byte ptr [r]
	mov dx, PALETTE_DATA
	out dx, al

	mov al, byte ptr [g]
	mov dx, PALETTE_DATA
	out dx, al

	mov al, byte ptr [b]
	mov dx, PALETTE_DATA
	out dx, al

	call horizRetrace

	ret
drawRasterLine ENDP
END MAIN
