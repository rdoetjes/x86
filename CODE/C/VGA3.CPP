#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>
#include <math.h>

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

void drawLine(int x0, int y0, int x1, int y1, int col){
   //the Bresenham line drawing algorithm
  int dx =  abs (x1 - x0), sx = x0 < x1 ? 1 : -1;
  int dy = -abs (y1 - y0), sy = y0 < y1 ? 1 : -1; 
  int err = dx + dy, e2; /* error value e_xy */
 
  for (;;){  /* loop */
    putPixel (x0, y0, col);
    if (x0 == x1 && y0 == y1) break;
    e2 = 2 * err;
    if (e2 >= dy) { err += dy; x0 += sx; } /* e_xy+e_x > 0 */
    if (e2 <= dx) { err += dx; y0 += sy; } /* e_xy+e_y < 0 */
  }
}

int main(void){
  //mov ah,0, mov al,13h, int 10h
  setVgaMode(0x13);

  putPixel(160, 110, 5);
  putPixel(161, 111, getPixel(160, 110));

  while( !kbhit() ){
    drawLine(rand() % 320, rand() % 200, rand() % 320, rand() % 199, rand() %16);
  }

  setVgaMode(0x3);
  return 0;
}
