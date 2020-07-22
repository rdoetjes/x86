.MODEL tiny

.STACK 1000h

.DATA
	bpos	db 00
	sine	db 128,131,134,137,140,143,146,149
		db 152,156,159,162,165,168,171,174
		db 176,179,182,185,188,191,193,196
		db 199,201,204,206,209,211,213,216
		db 218,220,222,224,226,228,230,232
		db 234,235,237,239,240,242,243,244
		db 246,247,248,249,250,251,251,252
		db 253,253,254,254,254,255,255,255
		db 255,255,255,255,254,254,253,253
		db 252,252,251,250,249,248,247,246
		db 245,244,242,241,239,238,236,235
		db 233,231,229,227,225,223,221,219
		db 217,215,212,210,207,205,202,200
		db 197,195,192,189,186,184,181,178
		db 175,172,169,166,163,160,157,154
		db 151,148,145,142,138,135,132,129
		db 126,123,120,117,113,110,107,104
		db 101,98,95,92,89,86,83,80
		db 77,74,71,69,66,63,60,58
		db 55,53,50,48,45,43,40,38
		db 36,34,32,30,28,26,24,22
		db 20,19,17,16,14,13,11,10
		db 9,8,7,6,5,4,3,3
		db 2,2,1,1,0,0,0,0
		db 0,0,0,1,1,1,2,2
		db 3,4,4,5,6,7,8,9
		db 11,12,13,15,16,18,20,21
		db 23,25,27,29,31,33,35,37
		db 39,42,44,46,49,51,54,56
		db 59,62,64,67,70,73,76,79
		db 81,84,87,90,93,96,99,103
		db 106,109,112,115,118,121,124,128
	endSine	db 00

.CODE
	include STDFUNC.ASM

MAIN PROC
	;initialize the program
	mov ax,SEG _DATA
	mov ds, ax

	call SeedRnd

	cli	;diable interupts we are doing time critical stuff
_loop:
	mov di, 00h
__loop:
	;read the sine from the sine list
	mov al, [sine+di]

	;if key pressed then exit
	call KeyPressExit

	;Increment DI to point to the next entry in the sine list
	inc di
	cmp di, (endSine-sine)
	jnz __loop

	jmp short _loop
MAIN ENDP
END MAIN
