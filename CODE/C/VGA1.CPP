#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <stdlib.h>

const SCREEN_WIDTH = 320;
const SCREEN_HEIGHT = 200;
typedef unsigned char byte;
byte far *VGA=(byte far*)0xA0000000L;

#define putPixel(x, y, col) *(VGA+(y)*SCREEN_WIDTH+x)=col;
#define getPixel(x, y) *(VGA+(y)*SCREEN_WIDTH+x);

void setVgaMode(int mode){
  union REGS regs;
  regs.h.ah = 0;
  regs.h.al = mode;
  int86(0x10, &regs, &regs);
}

void fillRectangle(int x0, int y0, int x1, int y1, byte col){
   for (int x = x0; x < x1; ++x){
     for (int y = y0; y < y1; ++y)
       putPixel(x, y, col);
   }
}

int main(void){
  //mov ah,0, mov al,13h, int 10h
  setVgaMode(0x13);

  fillRectangle(140, 140, 180, 180, 3);

  while( !kbhit() ){
    int x = rand() % 320;
    int y = rand() % 200;
    int x1 = rand() % 320;
    int y1 = rand() % 200;
    byte c = (rand() % 256);

    fillRectangle(x, y, x1, y1, c);
  }

  setVgaMode(0x3);
  return 0;
}