.model small

TSTARS	EQU    200

.data
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

	mov si, OFFSET spiral
DRAW:
	mov BX, DS:[SI]
	mov ES:[BX], BYTE PTR 15
	ADD si,2
	CMP si,2880
	JNZ DRAW

	mov ax,4c00h
	int 21h
endp main
end main