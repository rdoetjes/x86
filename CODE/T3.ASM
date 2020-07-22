.MODEL TINY

;.STACK 1000h  	;We want a tiny .COM file so stack can't be set

.DATA
	PRN dw 00h

.CODE
ORG 0100h
MAIN PROC
	call SeedRnd	;Seed the LGC with time ticks
	mov al, 12h	;640x480 16 col
	int 10h

	mov ax, 0A000h	;screen memory base
	mov es, ax	;point ES to frame buffer

	mov dx, 03ch	;VGA index register to select bit plane
	mov ax,1803h	;mask used in bitplane
	out dx,ax	;write to all bitplanes
qloop:
	mov di, 0h
sloop:
	call Random
	mov di, ax
	mov ax, 0fh
	mov es:[di], ax
	call KeyPressExit
	call SeedRnd
	jmp short qloop
MAIN  ENDP

;Generate a random number between 1 and 10 IN DX
SeedRnd PROC
	xor ax, ax	;clear AX
	int 1ah		;get timer ticks IN CX:DX
	add [PRN], dx   ;we are only interrested in the lower bytes
	ret
SeedRnd ENDP

Random PROC
	mov ax, 25173	;LCG multiplier
	mul word ptr [PRN]	;DX:AX = LCG multiplr * seed
	add ax, 13849	;add lcg increment value
	mov [PRN], ax
	ret
Random ENDP

TextMode PROC
	mov al, 12h	;video mode 25x80 16 colours
	int 10h         ;set it
TextMode ENDP

KeyPressExit PROC
	mov ah,06h      ;check if keyboard was pressed
	mov dl,0ffh     ;
	int 21h         ;check the keypress (00 is pressed)
	cmp al,00h      ;not keypressed then goto mainloop else exit
	jnz EXIT
	ret
EXIT:
	mov ax, 4c00h
	int 21h
KeyPressExit ENDP
END MAIN