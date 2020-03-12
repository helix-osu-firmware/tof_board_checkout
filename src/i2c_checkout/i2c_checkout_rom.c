#define sSpare sF
#define STACK s9
#include "pb_stack.h"
#include "soft_i2c_user.h"

// only [7:5] are decoded
#define EXECUTE 0x40
#define RESULT 0x41
#define NUMBYTES 0x42
#define ADDRESS 0x43
#define DATA 0x44
#define LOOP_DONE 0x20

void init() {
  stack_init();
  s2 = 0;
  output( LOOP_DONE, s2 );
  // initialize I2C
  I2C_stop();
  
  s1 = 0;
  do {
    s0 = 0;
    check_device();
    s2 = s1;
    s2 >>= 1;
    s2 |= 0x80;
    output(s2, s0);
    s1 += 2;
  } while(!Z);
  s2 = 1;
  output( LOOP_DONE, s2 );
}

void loop() {
  input( EXECUTE, &sSpare);
  if (sSpare & 0x1) {    
    input( NUMBYTES, &s0 );
    s1 = ADDRESS;
    // s0 holds number of bytes-1
    // so add the buffer pointer+1
    s0 += I2C_BUFFER(1);
    // s0 is now pointer to the first byte
    sA = s0;
    // Loop and store.
    do {
      input(s1, &sSpare);
      store(s0, sSpare);
      s1++;
      s0--;
    } while(s0 != (I2C_BUFFER(-1)&0xFF));
    I2C_write_bytes();
    s0 = 2;
    if (Z) {
      s0 -= 1;
    }
    output( RESULT, s0 );
  }
}

// Check if device passed in s1 exists.
// If it does, set LSB in s0.
void check_device() {
  s0 <<= 1;
  sA = I2C_BUFFER(0);
  store(sA, s1);
  I2C_write_bytes();
  if (Z) {
    s0 |= 1;
  }
}

