.MODEL TINY

;.STACK 1000h  	;We want a tiny .COM file so stack can't be set

.DATA
	PRN dw 00h

.CODE
ORG 0100h
MAIN PROC
	mov ax, 05h  	;CGA 320x200 monochrome to mimic C64
	int 10h         ;set the graphics mode

	call SeedRnd	;Seed the LGC with time ticks
mainLoop:
	;get random number between 1 and 10
	call Random
	and dx, 01h	;mask out all bits but the lowest
	cmp dx, 00h     ;if bit is 00 then draw backslash else slash
	jle backslash

	;load slash charachter
	mov dl, 2Fh     ;load slash char
	jmp print       ;print it to screen

	;load backslash character and print
backslash:
	mov dl, 5Ch	;load backslash char
	jmp print       ;print it to screen

	;print either slash or backslash
print:
	mov ah, 02h	;print char software interrupt
	int 21h         ;print character held in DL

	;delay a little
	mov cx, 0fffh
delay:
	dec cx          ;decrement CX till zero, to burn some cycles
	jnz delay

	;check if keypressed then exit
	mov ah,06h      ;check if keyboard was pressed
	mov dl,0ffh     ;
	int 21h         ;check the keypress (00 is pressed)
	cmp al,00h      ;not keypressed then goto mainloop else exit
	jnz EXIT

	jmp mainLoop

	;exit cleanly
EXIT:
	mov ax, 03h 	     ;reset back to 16 color text mode
	int 10h              ;set graphics mode

	mov ax,4c00h         ;exit with error code 00
	int 21h              ;call the exit
MAIN  ENDP

;Generate a random number between 1 and 10 IN DX
SeedRnd PROC
	xor ax, ax	;clear AX
	int 1ah		;get timer ticks IN CX:DX
	mov [PRN], dx   ;we are only interrested in the lower bytes
	ret
SeedRnd ENDP

Random PROC
	mov ax, 25173	;LCG multiplier
	mul word ptr [PRN]	;DX:AX = LCG multiplr * seed
	add ax, 13849	;add lcg increment value
	mov [PRN], ax

	;select range between 1 to 10
	;xor dx, dx      ;CLEAR DX
	;mov bx, 0Ah	;Between 0 and 9
	;div bx		;Divide AX with BX
	;inc dx		;DX is the modulo of the division
			;and add 1 to get between 1 and 10
	ret
Random ENDP

VgaMode PROC
	mov al, 12h	;video mode 25x80 16 colours
	int 10h         ;set it
VgaMode ENDP
END MAIN