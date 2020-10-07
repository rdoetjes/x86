.model small

TSPIRALS	EQU    63
TSTEPS		EQU    31


.data
	prn		dw      0
	starPos 	db	TSPIRALS+1 dup (?)
	starsSeeded 	db 	0
	include STARS.ASM

.code
org 100h

main proc
	mov ax, 13h	;MCGA mode
	int 010h

	mov ax, 0a000h	;point to screen memory
	mov es, ax

	mov ax, seg spiral
	mov ds, ax
	call allOn
_loop:
	;call seedStar
	call drawStars
	call keyP

	mov cx, 06000h
wait:
	dec cx
	jnz wait

     jmp _loop

allOn Proc
	mov bp, offset starPos
	mov si, 0
load:
	mov ds:[bp+si], byte ptr 1
	inc si
	cmp si, 64
	jnz load
	ret
endp Allon

seedStar PROC
	call Random
	mov bp, offset starPos
	and ax, 63 	;only keep the first 64, as we have 64 stars

	;get the star position in this corresponding spiral arm
	mov si, ax
	mov ax, ds:[bp+si]
	cmp ax, 0
	jnz _exitSeedStar

	mov ds:[bp+si], byte ptr 1

  _exitSeedStar:
	ret
seedStar ENDP

drawStars PROC
	mov cx, 0
draw:
	;dx = starPos[cx]
	mov ax, 0
	mov bp, offset starPos
	mov si, cx
	mov al, byte ptr ds:[bp+si]

	;if starPos[cx]!= 32 starPos[cx]+=1 else starPos[cx]=0
	cmp al, 31
	jne incStarPos
	mov ds:[bp+si], byte ptr 0
	jmp moveStar

incStarPos:
	inc byte ptr ds:[bp+si]		;move the star forward

moveStar:
	;bx = starSpiral[cx*32+ax]
	mov bp, offset spiral
	mov dx, cx
	shl dx, 5
	add ax, dx
	mov di, ax

	mov bx, ds:[bp+di]
	mov es:[bx], byte ptr 0

	mov bx, ds:[bp+di+2]
	mov es:[bx], byte ptr 15

nextSpiral:
	inc cx
	cmp cx, 64
	jne draw

	ret
drawStars ENDP

keyP PROC
	mov ah,06h
	mov dl, 0ffh
	int 21h
	cmp al,00
	jnz exit
	ret
  exit:
	mov ax, 03h
	int 010h

	mov ax, 04c00h
	int 021h
keyP ENDP

SeedRnd PROC
	xor ax, ax
	int 01ah
	add [PRN], dx
	ret
SeedRnd ENDP

Random PROC
	call SeedRnd
	mov cx, 09ffh
  __rnd:
	dec cx
	jnz __rnd

	mov ax, 25173   ;LCG mult
	mul word ptr [PRN]
	add ax, 13849
	mov [PRN], ax
	ret
Random ENDP

endp main
end main
