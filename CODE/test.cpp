#include <iostream>
#include <fstream>
#include <string>
#include <cmath>

using namespace std;

int main(void){
  int x, y;
  int radius = int(sqrt(160 * 160 + 100 * 100));
  float easyin;

  ofstream file ("STARS.ASM", ios::binary);
  file << "spiral";

  for (int angle=0; angle<360; angle+=(360/64)){
    for (float i=0; i<=1.0; i+=0.05){
      easyin = i * i * i;
      x = int(radius * easyin *  cos(angle)) + 160;
      y = int(radius * easyin *  sin(angle)) + 100;
 
      x = x < 0 ? 0 : x;
      x = x > 319 ? 319 : x;

      y = y < 0 ? 0 : y;
      y = y > 199 ? 199 : y;

      unsigned int mem = (320 * y + x);
      cout << "\t" << "dw 0" << std::hex << mem << "h\r\n";
      file << "\t" << "dw 0" << std::hex << mem << "h\r\n";
    }
  }
  return 0;
}
