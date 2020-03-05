#include "soft_i2c.h"

#define I2C_NACK_MAGIC 0xFFFF

// writes bytes, starting from buffer
// pointed at sA and going BACKWARDS
// to I2C base.
// on return sA contains number of remaining bytes
// (Z is set on total success)
void I2C_write_bytes();

// read register sA (returned back in sA)
// device address is already in I2C_BUFFER(1)
void I2C_reg_read();

// read 1 byte from device address in sA
void I2C_read_one_byte();

// read 16-bit register sA (returned back in sB.sA)
// device address is already in I2C_BUFFER(1)
void I2C_reg_read16();

// read 2 bytes from device address in sA
void I2C_read_two_bytes();

void I2C_write_bytes() {
  // save sA since sA/sB get clobbered
  // in I2C_Tx_byte_and_Rx_ACK()
  sC = sA;
  I2C_start();
  I2C_write_bytes_process();
  I2C_stop();
  // I2C_stop() clobbers Z, so we need
  // to restore it. sA still holds
  // number of remaining characters.
  sA += 0;
}

// read register sA (returned back in sA)
// device address is already in I2C_BUFFER(1)
// This has a nested "read 1 byte" function.
// which doesn't update a register beforehand.
void I2C_reg_read(){
  store(I2C_BUFFER(0), sA);
  // set register and turn around to read
  // this gets used in multiple places

  // NZ on failure
  I2C_update_read_reg_turnaround();
  psm("jump NZ, I2C_reg_read_failure");
 I2C_read_one_byte:
  // C on failure
  I2C_read1_process();
  psm("jump C, I2C_reg_read_failure");
  I2C_Tx_NACK();
  psm("jump I2C_reg_read_finish");
 I2C_reg_read_failure:
  sA = 0xFF;
 I2C_reg_read_finish:
  I2C_stop();
}

// read 16-bit register sA (returned back in sA.sB)
// device address is already in I2C_BUFFER(1)
void I2C_reg_read16() {
  store(I2C_BUFFER(0), sA);
  // NZ on failure
  I2C_update_read_reg_turnaround();
  psm("jump NZ, I2C_reg_read16_failure");
 I2C_read_two_bytes:
  // C on failure
  I2C_read1_process();
  psm("jump C, I2C_reg_read16_failure");
  // store sA in 0x3F
  push1();
  I2C_Tx_ACK();
  I2C_Rx_byte();
  I2C_Tx_NACK();
  sB = sA;
  // fetch sA from 0x3F
  pop1();
  psm("jump I2C_reg_read16_finish");
 I2C_reg_read16_failure:
  sB.sA = I2C_NACK_MAGIC;
 I2C_reg_read16_finish:
  I2C_stop();
}

// write sA to register sB.
// device address is already in I2C_BUFFER(2)
// Z is set on total success
void I2C_reg_write() {
  // we use address 0 and up as a buffer
  store(I2C_BUFFER(1), sB);
  store(I2C_BUFFER(0), sA);
  sA = I2C_BUFFER(2);
  I2C_write_bytes();
}
