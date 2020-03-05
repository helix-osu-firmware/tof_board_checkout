// Reimplementation of Ken Chapman's I2C
// routines in the pseudo-C of pblaze-cc.

// We get rid of the need for the register
// by grabbing 3 output ports: one
// for clock, one for data, one for both,
// obviously done with address bits.
// This allows individual bit toggling
// as well as simultaneous bit toggling,
// and it basically costs nothing.

// Main functions:
// I2C_init
// I2C_Tx_byte
// I2C_Rx_ACK
// I2C_Rx_byte
// I2C_start
// I2C_stop
//

// this is around 60 kbit/s.
// It's slower because clock pulse goes
// (wait 5), clock high, (wait 4), clock low, (wait 5)
// 

// Look at soft_i2c_user.h for
// convenient functions.

// All functions take parameters in sB/sA
// and return values in sA.

#define I2C_clk 0x01
#define I2C_data 0x02
#define I2C_time_reference 49
// This uses the hwbuild instruction to grab the time reference.
// This is helpful because you can speed simulation up.
// Otherwise you can just use "x = I2C_time_reference"
#define LOAD_I2C_TIMEREF(x) psm("hwbuild %1", x)

#define I2C_input_port  0x00
#define I2C_bussel_port 0x00
#define I2C_output_clk  0x01
#define I2C_output_data 0x02
#define I2C_output_both 0x03

// NOTE: These functions eat some scratchpad
// RAM for the buffer. If you choose 0x00,
// this lets you sleaze the end condition
// as just C. Otherwise you need to compare
// against 1 below the base.
#define I2C_BUFFER_BASE 0x00
#define I2C_BUFFER(n) ( I2C_BUFFER_BASE + n )
// with I2C_BUFFER_BASE being 0x00 this works
// otherwise do I2C_BUFFER_END(reg) reg == (I2C_BUFFER_BASE - 1)
#define I2C_BUFFER_END_COND(reg) C == 0

// I2C busses should only be swapped when idle
#define KSET_I2C_BUS(x) outputk(I2C_bussel_port, x )
#define SET_I2C_BUS(x) output(I2C_bussel_port, x)

// Initializes I2C.
#define I2C_init() \
  outputk( I2C_output_both, (I2C_clk | I2C_data) )

#define I2C_data_Z() \
  outputk( I2C_output_data, I2C_data)

#define I2C_data_Low() \
  outputk( I2C_output_data, 0)

void I2C_clk_Z() {
  outputk(I2C_output_clk, I2C_clk);
  do {
    input(I2C_input_port, sSpare);   
  } while (!(sSpare & I2C_clk ));
}

void I2C_clk_Low() {
  outputk(I2C_output_clk, 0);
  I2C_delay_5us();
}

void I2C_start() {
  I2C_data_Z();
  I2C_clk_Z();
  // this is t_buf
  I2C_delay_5us();
  I2C_data_Low();
  // This is t_hd;sta
  I2C_delay_4us();
  I2C_clk_Low();
}

void I2C_stop() {
  I2C_data_Low();
  I2C_delay_5us();
  I2C_clk_Z();
  I2C_delay_4us();
  I2C_data_Z();
}

// transmit in sA, uses sB
void I2C_Tx_byte() {
  sB = 0x80;
  do {
    if (sB & sA) {
      I2C_data_Z();
    } else {
      I2C_data_Low();
    }
    I2C_clk_pulse();
    sB >>= 1;
  } while (!C);
}

void I2C_Rx_bit() {
  I2C_data_Z();
  I2C_delay_5us();
  I2C_clk_Z();
  I2C_delay_2us();
  input(I2C_input_port, sSpare);
  psm("test %1, %2", sSpare, I2C_data);
  psm("sla %1", sA);
  I2C_delay_2us();
  I2C_clk_Low();
}

void I2C_Rx_byte() {
  // this is sleazier than the original:
  // we start sA off as 0x1, then sla each bit,
  // and when carry is 1, we're done
  // damnit this doesn't work, since we obliterate
  // C in the delay functions, but we cheat
  // by doing 7 in the loop and one after.
  // This saves a register clobber at the expense of
  // an additional instruction.
  // Original was load, call, sub, jump return
  // Ours is      load, call, test, jump, call, return
  sA = 0x1;
  do {
    I2C_Rx_bit();    
  } while (!(sA & 0x80));
  I2C_Rx_bit();
}

// This is massive sleaze.
// The labels create additional function calls
// nested inside I2C_Tx_NACK.
// The jump call is because we don't have gotos
// yet.
void I2C_Tx_NACK() {
  I2C_data_Z();
  psm("jump I2C_clk_pulse");
 I2C_Tx_ACK:
  I2C_data_Low();
 I2C_clk_pulse:
  I2C_delay_5us();
  I2C_clk_Z();
  I2C_delay_4us();
  I2C_clk_Low();
}

// contains I2C_Rx_ACK: sets C if communication fails.
void I2C_Tx_byte_and_Rx_ACK() {
  I2C_Tx_byte();
 I2C_Rx_ACK:
  I2C_Rx_bit();
  psm("test %1, 0x1", sA);
}

// The labels here are to create
// additional function calls
// embedded within I2C_delay_5us.
//
// Call graph for delay_5us
// 1: calls delay_1us, returns to delay_4us
// 2: calls delay_2us:
//    2a: calls delay_1us, returns to delay_1us
//    2b: returns to delay_2us
// 3: calls delay_1us, returns to delay_1us
// 4: returns
// total of 5 delay_1us calls
//
void I2C_delay_5us() {
  I2C_delay_1us();
 I2C_delay_4us:
  // this is a space optimization over
  // Ken's: we can recurse the
  // functions to save a call.
  // PicoBlaze's call stack is
  // extremely big, so burning
  // an entry there is unlikely
  // to be an issue.
  I2C_delay_2us();
 I2C_delay_2us:
  I2C_delay_1us();
  // another optimization, there's
  // no reason for delay_2us to
  // call delay_1us when we can just
  // embed it inside.
 I2C_delay_1us:
  LOAD_I2C_TIMEREF(sSpare);
  while (--sSpare);
}

// multi-byte write with no start or stop
void I2C_write_bytes_process() {
  do {
    fetch(sC, &sA);
    I2C_Tx_byte_and_Rx_ACK();
    psm("jump C, I2C_write_bytes_process_failure");
    sC -= 1;
  } while (I2C_BUFFER_END_COND(sC));
 I2C_write_bytes_process_failure:
  // convert sA to number of bytes processed
  sA = sC;
  sA -= ( (I2C_BUFFER_BASE-1) & 0xFF );
}

// read 1 byte from sA with no stop
// sets C on error
void I2C_read1_process() {
  I2C_start();
  I2C_Tx_byte_and_Rx_ACK();
  psm("return C");
  // C gets cleared in the delay functions
  // (and Z set), so can use a C test.
  I2C_Rx_byte();
}

// set the read register, fetch back the pointer
// and set read byte
void I2C_update_read_reg_turnaround() {
  sC = I2C_BUFFER(1);
  fetch(I2C_BUFFER(1), sA);
  // save the modified sA.
  // we can't use push/pop
  // since they modify flags.
  sA |= 0x1;
  store(I2C_BUFFER(2), sA);
  I2C_start();
  I2C_write_bytes_process();
  psm("return NZ");
  // restore the modified sA without touching flags.
  fetch(I2C_BUFFER(2), sA);
}
