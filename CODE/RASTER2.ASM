.MODEL tiny

.STACK 100h

PALETTE_INDEX EQU 3c8h
PALETTE_DATA EQU 3c9h
INPUT_STATUS EQU 3dah
HRETRACE EQU 01h
VRETRACE EQU 08h
BAR_WIDTH EQU 10

.DATA
	bpos	db 00
	cop1Pos dw 00
	r	db 00
	g	db 00
	b	db 00
.CODE
	;used for keypress exit
	include STDFUNC.ASM

MAIN PROC
	;initialize the program
	mov ax,SEG _DATA
	mov ds, ax
	mov bx, 100
_loop:
	call vertRetrace
	mov cx, 0
_wait4line:
	call horizRetrace
	inc cx	;increment line count
	cmp cx, bx
	jne _wait4line

	call drawBar
	sti

	;if key pressed then exit
	call KeyPressExit

	jmp _loop
MAIN ENDP

drawBar PROC
	mov ah, BAR_WIDTH

_barLines:
	mov al, 60
	mov [r], al
	call drawRasterLine
	call horizRetrace
	dec ah
	jnz _barLines

	mov al, 0
	mov [r], al
	call drawRasterline
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
