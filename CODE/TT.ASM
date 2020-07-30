.model small

;.data

.code
org 100h

MAIN PROC NEAR
		;initialize the program
	;mov ax, @data
	;mov ds, ax

	mov dx, OFFSET var
	mov ah, 9
	int 21h
	mov ax, 4c00h
	int 21h
MAIN ENDP
	var db "ASAS Hello world$"
end main