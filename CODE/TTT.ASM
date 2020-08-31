drawPixel MACRO x, y, c
	push x
	push y
	push c
	call dPixel
	add sp, 6
ENDM

.model small

.code
org 100h

main proc
	mov ax, 13h	;MCGA mode
	int 010h

	mov ax, 0a000h	;point to screen memory
	mov es, ax

	drawPixel 1 150 3

	drawPixel 2 150 4

	mov ah, 04ch
	int 021h
	ret
main endp

;ax = x position
;bx = y position
;formule is (320 * y) + x
;mul instruction would take up to 133 cycles
;shl instructions plus adds take 34 cycles in total
dPixel proc
	push bp  	;we pass parameters via the stack
	mov bp, sp      ;so we safe the bp

	push ax
	push bx
	push dx

	mov ax, word ptr [bp+8]	;get x from the stack (first parm)
	mov bx, word ptr [bp+6] ;get y from the stack (second parm)

	mov dx, bx
	shl dx, 8	;multiply by 256
	shl bx, 6       ;multiply by 64
	add bx, dx	;320 * y
	add bx, ax	;+ x
	mov al, [bp+4]                  ;get color from the stack (third parm)
	mov byte ptr es:[bx], al	;draw a white pixel on x y

	pop dx
	pop bx
	pop ax

	pop bp
	ret
dPixel endp


end main