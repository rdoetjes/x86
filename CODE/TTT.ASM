.model small

.code
org 100h

main proc
	mov ax, 13h	;MCGA mode
	int 010h

	mov ax, 0a000h	;point to screen memory
	mov es, ax

	mov ax, 3
	mov bx, 3
	call drawPixel

	mov ax, 2
	mov bx, 2
	call drawPixel

	mov ax, 1
	mov bx, 1
	call drawPixel


	mov ah, 04ch
	int 021h
	ret
main endp

;ax = x position
;bx = y position
;formule is (320 * y) + x
;mul instruction would take up to 133 cycles
;shl instructions plus adds take 34 cycles in total
drawPixel proc
	mov dx, bx
	shl dx, 8	;multiply by 256
	shl bx, 6       ;multiply by 64
	add bx, dx	;320 * y
	add bx, ax	;+ x
	mov al, 15
	mov byte ptr es:[bx], al	;draw a white pixel on x y
	ret
drawPixel endp


end main