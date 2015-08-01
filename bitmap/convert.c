#include <stdio.h>
#include <stdint.h>
#include <string.h>

static int8_t readBit(int8_t* buf, int x) {
  return buf[x];
}

static void writeBit(int8_t* buf, int x, int8_t val) {
  int byteNum = x / 8;
  int offset = x % 8;
  if (val) {
    buf[byteNum] |= 1 << (7 - offset);
  }
}

static void c64WriteBit(int8_t* buf, int x, int8_t val) {
  int m = x % 320;
  int xl = m % 8 + ((m/8) * 64);
  int yl = x / 320;
  int r = yl / 8;
  int idx = ((yl % 8) * 8) + xl + (r * 320 * 8);

  writeBit(buf, idx, val);
}

int main(int argc, const char* argv[]) {
  FILE* inf = fopen(argv[1], "rb");
  FILE* outf = fopen(argv[2], "wb");
  int8_t in[320*200];
  int8_t out[(320*200)/8];
  memset(out, 0, (320*200)/8);
  
  int8_t* loc = in;
  for(int i=0; i < 320*200; ++i) {
    int16_t sh;
    fread(&sh, 2, 1, inf);
    *loc = 0x03 & sh;
    loc+=1;
  }

  for(int i=0; i < 320*200; ++i) {
    c64WriteBit(out, i, readBit(in, i));
  }

  loc = out;
  for(int i=0; i < (320*200)/8; ++i) {
    fwrite(loc, 1, 1, outf);
    loc+=1;
  }
  
  fclose(inf);
  fclose(outf);
  return 0;
}
