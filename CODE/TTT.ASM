.model small

.code
org 100h

drawPixel MACRO x, y, c
	;push the variables on the stack
	push x
	push y
	push c
	;call the routine that reads args from stack
	call dPixel
	;restore stack pointer
	add sp, 6
ENDM


main proc
	mov ax, 13h	;MCGA mode
	int 010h

	mov ax, 0a000h	;point to screen memory
	mov es, ax

	mov ax, 0
	mov bx, 0
	mov cx, 0
draw:
	drawPixel ax cx bx
	inc ax
	inc bl
	cmp ax, 320
	jne draw
	mov ax, 0
	inc cx
	cmp cx, 200
	jne draw

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

	;prevent globbering the registers we use
	push ax
	push bx
	push dx

	;get the x and y argument from the stack
	mov ax, word ptr [bp+8]	;get x from the stack (first parm)
	mov bx, word ptr [bp+6] ;get y from the stack (second parm)

	;calculate the memory position
	mov dx, bx
	shl dx, 8	;multiply by 256
	shl bx, 6       ;multiply by 64
	add bx, dx	;320 * y
	add bx, ax	;+ x
	mov al, [bp+4]                  ;get color from the stack (third parm)
	mov byte ptr es:[bx], al	;draw a white pixel on x y

	;restore the used registers
	pop dx
	pop bx
	pop ax

	;restore bp
	pop bp
	ret
dPixel endp
end main