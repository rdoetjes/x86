#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

const SCREEN_WIDTH = 320;
const SCREEN_HEIGHT = 200;
const TSTARS = 80;
const STEPS = 48;
const ARMS = 64;

typedef unsigned char byte;
byte far *VGA=(byte far*)0xA0000000L;
byte CMAP[]={16, 16, 16, 16, 16, 16,
	     16, 18, 18, 18, 18, 18,
	     18, 19, 19, 19, 19, 19,
	     21, 21, 21, 21, 21, 21,
	     27, 27, 27, 27, 27, 27,
	     15, 15, 15, 15, 15, 15,
	     15, 15, 15, 15, 15, 15,
	     15, 15, 15, 15, 15, 15,
	     };

#define putPixel(x, y, col) *(VGA+(y)*SCREEN_WIDTH+x)=col;
#define getPixel(x, y) *(VGA+(y)*SCREEN_WIDTH+x);

#define INPUT_STATUS 0x3da
#define VRETRACE 0x08
#define HRETRACE 0x01

int *STARMAP;
byte *STARS;

void setVgaMode(int mode){
  union REGS regs;
  regs.h.ah = 0;
  regs.h.al = mode;
  int86(0x10, &regs, &regs);
}

void starMap(){
  int x, y;
  int radius = 188;
  float easyin;
  int c = 0;

  for (int angle=0; angle<360; angle+=(360/ARMS)){
    for (float i=0.4f; i<=1.0; i+=0.9f/STEPS){
      easyin = i * i * i;
      x = int(radius * easyin *  cos(angle)) + 160;
      y = int(radius * easyin *  sin(angle)) + 100;

      x = x < 0 ? 319 : x;
      x = x >= 319 ? 319 : x;

      y = y < 0 ? 200 : y;
      y = y >= 199 ? 200 : y;

      STARMAP[c] = 320 * y + x;

      c++;
    }
  }
}

void initStars(){
  for (int i=0; i <TSTARS; i++)
     STARS[i] = rand() % STEPS;
}

void seedStar(){
    int s = rand() % TSTARS;
    if (STARS[s] == 0)
      STARS[s] = 1;
}

void waitRetrace(){
  disable();
  while ( inportb(INPUT_STATUS) & VRETRACE );
  while ( !(inportb(INPUT_STATUS) & VRETRACE) );
  enable();
}

int main(void){
  //mov ah,0, mov al,13h, int 10h
  setVgaMode(0x13);

  srand(time(0));

  STARMAP = (int*)malloc( (ARMS*STEPS)*sizeof(int) );
  starMap();

  STARS = (byte *)malloc(TSTARS);
  initStars();

  while( !kbhit() ){

    for(int i=0; i<2; ++i)
      waitRetrace();

    for(i=0; i < TSTARS; ++i){

      seedStar();

      if (STARS[i] >= STEPS) STARS[i] = 0;

      if (STARS[i] == 0 ) continue;

      int offset = ( (i % ARMS) * STEPS) + STARS[i];

      VGA[ STARMAP[offset] ] = 0;
      STARS[i]++;
      if (STARS[i] < STEPS){
	VGA[ STARMAP[offset+1] ] = CMAP[STARS[i]];
      }
      putPixel(0,0,0);
    }
  }

  setVgaMode(0x3);
  return 0;
}
