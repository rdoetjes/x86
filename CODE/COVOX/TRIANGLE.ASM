.model tiny

.code
	org 100h
main proc
	mov dx, 378h
	mov al, 0h
sound:
	out dx, al
	inc al
	call KeyPressExit
	mov cx, 01
delay:
	dec cx
	jnz delay

	jmp sound

	include stdfunc.asm
main endp
end main