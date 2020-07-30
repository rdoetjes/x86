DOSSEG
.model TINY
.data
	OLD_INT	DD 00h
.code
org 100h
main proc
   jmp TSR
main endp

my_handler proc
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push es
	push si
	push di

	mov dl, 33
	mov ah, 2h
	int 21h

	pop di
	pop si
	pop es
	pop bp
	pop sp
	pop dx
	pop cx
	pop bx
	pop ax
	jmp cs:OLD_INT
my_handler endp

TSR:
	cli	;we are setting up interrupts so stop interupting please

	push cs	;quick way to point DS to CD
	pop ds

	;save old keyboard handler pointer
	;we will call that as soon as we have execute our hook
	mov al, 09h
	mov ah, 35h
	int 21h
	mov WORD PTR [OLD_INT], bx	;save instruction pojnter
	mov WORD PTR [OLD_INT+2], es	;save the code segment

	;install my keyboard hook
	lea dx, my_handler
	mov al, 9h
	mov ah, 25h
	int 21h

	;making program tsr and call tsr code
	mov al, 1h
	mov ah, 31h
	lea dx, TSR
	sti		;first enable interrupts again before going TSR
	int 21h
end main