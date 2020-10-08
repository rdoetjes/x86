.model small

INPUT_STATUS    EQU    3dah
HRETRACE 	EQU    01h
VRETRACE 	EQU    08h
TSPIRALS	EQU    256
TSTEPS		EQU    31


.data
	curpos		db	0
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

	call SeedRnd
	call AllOff
_loop:
	call seedStar
	call drawStars
	;call seedStar
	call keyP

	mov cx, 02h
wait:
	call RasterWait
	dec cx
	jnz wait
	call seedRnd

     jmp _loop

allOff Proc
	mov bp, offset starPos
	mov si, 0
load:
	mov ds:[bp+si], byte ptr 0
	inc si
	cmp si, 63
	jnz load

	mov si, 64000
cls:
	mov es:[si], byte ptr 0
	dec si
	cmp si, 0
	jnz cls

	ret
endp AllOff

seedStar PROC
	call Random
	mov bp, offset starPos
	and ax, 255 	;only keep the first 64, as we have 64 stars
	;get the star position in this corresponding spiral arm
	mov si, ax

	mov dx, ds:[bp+si]
	cmp dx, 0
	jnz _exitSeedStar

	mov ds:[bp+si], byte ptr 1

  _exitSeedStar:
	ret
seedStar ENDP

drawStars PROC
	mov cx, 0
draw:
	;ax = starPos[cx]
	xor ax, ax
	mov bp, offset starPos
	mov si, cx
	mov al, byte ptr ds:[bp+si]
	mov [curpos], al

	;if starPos[cx]!= 31 starPos[cx]+=1 else starPos[cx]=0
	cmp al, 0
	je nextSpiral

	cmp al, 31
	jle incStarPos
	mov ds:[bp+si], byte ptr 1
	jmp nextSpiral

incStarPos:
	inc byte ptr ds:[bp+si]		;move the star forward

moveStar:
	;bx = starSpiral[(cx*32)+(2*ax)]
	mov bp, offset spiral
	mov dx, cx
	shl dx, 5   ;1 * 32 = 32
	shl ax, 1   ;1 * 2  = 2
	add ax, dx  ;34
	mov di, ax

	cmp [curpos], 30
	jge clean

	cmp [curpos], 4
	jle clean

	mov bx, ds:[bp+di+2]
	mov es:[bx], byte ptr 15

clean:
	mov bx, ds:[bp+di]
	mov es:[bx], byte ptr 0

nextSpiral:
	inc cx
	;inc cx
	cmp cx, 240

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
	mov ax, 25173   ;LCG mult
	mul word ptr [PRN]
	add ax, 13849
	mov [PRN], ax
	ret
Random ENDP

RasterWait PROC
;wait for a vertical retrace
	cli
	mov dx, INPUT_STATUS

_v1:    in al, dx
	and al, VRETRACE
	jnz _v1

_v2:    in al, dx
	and al, VRETRACE
	jz _v2
	sti
	ret
endp RasterWait

endp main
end main