#define sSpare sF
#define STACK s9
#include "pb_stack.h"
#include "soft_i2c_user.h"

// only [7:5] are decoded
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
  // DO NOTHING
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

