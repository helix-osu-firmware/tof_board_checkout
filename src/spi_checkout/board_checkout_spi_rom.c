#define sSpare sF
#define STACK  s9
#include "pb_stack.h"
#include "soft_spi_flash.h"

// [5:4] == 01, 10, 11 are the three bytes of the RDID instruction
#define RDID_0 0x10
#define RDID_1 0x20
#define RDID_2 0x30

void init() {
  stack_init();

  SPI_STARTUP_initialize();
  SPI_Flash_read_ID();
  output( RDID_0, sA);
  output( RDID_1, sB);
  output( RDID_2, sC);
}

void loop() {
  // DO NOTHING
}
