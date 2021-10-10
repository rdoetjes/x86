.model small

TSTARS	EQU    200
INPUT_STATUS EQU 3dah
HRETRACE EQU 01h
VRETRACE EQU 08h

.data
	prn	dw 	00h
	stars	db	3*TSTARS DUP (?)

.code
org 100h

main proc
	mov ax, 13h	;MCGA mode
	int 010h

	mov ax, 0a000h	;point to screen memory
	mov es, ax

	mov ax, seg stars
	mov ds, ax

	call SeedRnd
	call loadStars
  loop_:
	call drawStars
	mov cx, 0e000h
  wait_:
	dec cx
	jnz wait_
	call moveStars
	call keyP
	call vertRetrace
	jmp loop_

main endp

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

moveStars PROC
	mov di, TSTARS
	mov si, OFFSET stars
  move_:
	mov bx, word ptr [si]
	mov al, 0
	mov es:[bx], al	;black the old location

	mov al, byte ptr [si+2]	;get color white pixels move faster
	sub al, 15

	cmp al, 10
	jb _slow
	dec bx

	cmp al, 11
	jb _slow
	dec bx

	cmp al, 12
	jb _slow
	dec bx

	cmp al, 13
	jb _slow
	dec bx

	cmp al, 14
	jb _slow
	dec bx

  _slow:
	dec bx
	mov [si], bx

	add si, 3
	dec di
	jnz move_
	ret
moveStars ENDP

drawStars PROC
	mov di, TSTARS
	mov si, OFFSET stars
  drawStars_:
	mov bx, word ptr [si]
	mov al, byte ptr [si+2]
	mov byte ptr es:[bx], al
	add si, 3
	dec di
	jnz drawStars_
	ret
drawStars ENDP

loadStars PROC
	mov di, TSTARS
	mov bx, OFFSET stars
  loadStars_:
	call Random
	mov [bx], ax
	call Random
	and al, 15
	add al, 15
	mov [bx+2], al
	add bx,3
	dec di
	jnz loadStars_
	ret
loadStars ENDP

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

	mov ax, 25173	;LCG mult
	mul word ptr [PRN]
	add ax, 13849
	mov [PRN], ax
	ret
Random ENDP

vertRetrace PROC
	;wait for vertical retrace
	cli
	mov dx, INPUT_STATUS

_v1:
	in al, dx
	and al, VRETRACE
	jnz _v1

_v2:
	in al, dx
	and al, VRETRACE
	jz _v2

	ret
vertRetrace ENDP

end main