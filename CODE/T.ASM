.MODEL SMALL

;.STACK 100h	;we want a tiny .COM file so no STACK POINTER CAN BE SET!

.DATA

.CODE
ORG 100h	;we want a tiny .COM file so we require ORG 100

MAIN PROC

;read key from keyboard without echo
      MOV     AH, 07h          ;read key without echo, reply is in AL
      INT     21h              ;call read key without echo

;Is charachter pressed ESC, Y then exit, N contiue
      CMP     AL, 1Bh          ;if AL (key read) is escape than jump to exit
      JZ      EXIT             ;jump to exit when AL==1Bh

;Turn capital letters into lower case
      OR      AL, 00100000b    ;Set 6th bit of read charachter to high to convert captials into lower case

;Print the charaters (which are converted to lower)
      MOV     AH, 02h          ;print char
      MOV     DL, AL           ;put the now lower case character in the output register for print char
      INT     21h              ;call print char

;Repeat until ESC is pressed
      JMP     MAIN             ;repeat until escape key is pressed

;exit cleanly
EXIT:
      MOV     AX,4c00h         ;exit with error code 00
      INT     21h              ;call the exit

MAIN  ENDP

END MAIN