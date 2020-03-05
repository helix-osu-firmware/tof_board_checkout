// Generic board checkout module.
`include "board_checkout_ppdefs.vh"

// Board checkout parameters. These specify the number of things this board has to check out.
`DEFINE_IF(NUM_DIFF_CLOCKS, 1)
`DEFINE_IF(NUM_SE_CLOCKS, 2)
`DEFINE_IF(NUM_I2C, 2)
`DEFINE_IF(NUM_SPI_FLASH, 1)
`DEFINE_IF(NUM_LED, 4)

`ifndef NUM_LED
`error you always have to have at least ONE blinky LED
`endif

module board_checkout(
		      // Add clocks to test 
		      `ifdef NUM_DIFF_CLOCKS
		      input [`NUM_DIFF_CLOCKS-1:0] DIFFCLK_P,
		      input [`NUM_DIFF_CLOCKS-1:0] DIFFCLK_N,
              `endif
              `ifdef NUM_SE_CLOCKS
		      input [`NUM_SE_CLOCKS-1:0] CLK,
		      `endif
		      // Add I2C busses to scan.
		      `ifdef NUM_I2C
		      inout [`NUM_I2C-1:0] SDA,
		      inout [`NUM_I2C-1:0] SCL,
		      `endif
		      // Add SPI Flash path to identify.
		      `ifdef NUM_SPI_FLASH
		      output [`NUM_SPI_FLASH-1:0] SPI_CS_B,
		      output SPI_MOSI,
		      input SPI_MISO,
		      `endif
              //// ADD BOARD SPECIFIC STUFF HERE ////
              ////    END BOARD SPECIFIC STUFF   ////
		      // Add blinky LED.
		      // you always have to have at least ONE blinky LED		      
		      output [`NUM_LED-1:0] LED
		      );
   // convert into parameters
   localparam NUM_DIFF_CLOCKS = `IF_DEFINED_ELSE_Z(NUM_DIFF_CLOCKS);
   localparam NUM_SE_CLOCKS = `IF_DEFINED_ELSE_Z(NUM_SE_CLOCKS);
   localparam NUM_I2C = `IF_DEFINED_ELSE_Z(NUM_I2C);
   localparam NUM_SPI_FLASH = `IF_DEFINED_ELSE_Z(NUM_SPI_FLASH);
   localparam NUM_LED = `IF_DEFINED_ELSE_Z(NUM_LED);
   localparam NUM_CLOCKS = NUM_DIFF_CLOCKS + NUM_SE_CLOCKS;

   // and generate fakey-signals to shut up el-stupido compiler
   `ifndef NUM_DIFF_CLOCKS
   wire [0:0] DIFFCLK_P;
   wire [0:0] DIFFCLK_N;
   `endif
   `ifndef NUM_SE_CLOCKS
   wire [0:0] CLK;
   `endif
   `ifndef NUM_I2C
   wire [0:0] SDA;
   wire [0:0] SCL;
   `endif
   `ifndef NUM_SPI_FLASH
   wire [0:0] SPI_CS_B;
   wire SPI_MOSI;
   wire SPI_MISO;
   `endif
   

   wire [NUM_CLOCKS-1:0] 	   clocks;
   wire 			   sysclk;
   // SPI's SCLK is fake, routed through USRCCLKO.
   wire                            SPI_SCLK;
   // the CCLK frequency is bullcrap here, it's usually around
   // a 60-ish MHz oscillator but we can only do 0-10 ns
   STARTUPE2 #(.SIM_CCLK_FREQ(10.0)) u_startup(.CFGCLK(),
					       .CFGMCLK(sysclk),
					       .CLK(1'b0),
					       .EOS(),
					       .GSR(1'b0),
					       .GTS(1'b0),
					       .KEYCLEARB(1'b1),
					       // pointless anyway
					       .PACK(1'b1),
					       .PREQ(),
					       .USRCCLKO(SPI_SCLK),
					       .USRCCLKTS(1'b0),
					       .USRDONEO(1'b0),
					       .USRDONETS(1'b0));

   // generate a millisecond-ish flag
   // The clock is ~65 MHz, conveniently, so we just
   // assume it's 65.535 MHz and use a 16-bit counter.
   reg [15:0] 			   counter = {16{1'b0}};
   // steal the carry output
   wire [16:0] 			   counter_plus_one = counter + 1;
   reg 				   sysclk_millice = 0;
   always @(posedge sysclk) begin
      counter <= counter_plus_one[15:0];
      sysclk_millice <= counter_plus_one[16];
   end   

   generate
      genvar 			   ci,ii;
      for (ci=0;ci<NUM_CLOCKS;ci=ci+1) begin : CCS
         if (ci < NUM_DIFF_CLOCKS) begin : DIFF
            IBUFDS u_ibuf(.I(DIFFCLK_P[ci]),.IB(DIFFCLK_N[ci]),.O(clocks[ci]));
         end else begin : SE
	    IBUF u_ibuf(.I(CLK[ci]),.O(clocks[ci]));
	 end
	 // instantiate a clock counter for this clock
	 board_clock_checkout u_cc(.sysclk(sysclk),
				   .sysclk_millice(sysclk_millice),
				   .testclk(clocks[ci]));	 
      end
      for (ii=0;ii<NUM_I2C;ii=ii+1) begin : I2CSCANNER
	 wire sda_i;
	 wire sda_o;
	 wire sda_t;
	 wire scl_i;
	 wire scl_o;
	 wire scl_t;	 
	 IOBUF u_sdaiobuf(.I(sda_o),.O(sda_i),.T(sda_t),.IO(SDA[ii]));
	 IOBUF u_scliobuf(.I(scl_o),.O(scl_i),.T(scl_t),.IO(SCL[ii]));
	 // instantiate an I2C bus scanner for this bus
	 board_i2c_checkout u_i2c(.clk(sysclk),.scl_i(scl_i),.scl_o(scl_o),.scl_t(scl_t),.sda_i(sda_i),.sda_o(sda_o),.sda_t(sda_t));
      end
      if (NUM_SPI_FLASH > 0) begin : SPI
        board_spi_flash_checkout #(.NUM_SPI_FLASH(NUM_SPI_FLASH)) u_spi(.clk(sysclk),
                                       .sclk_o(SPI_SCLK),
                                       .mosi_o(SPI_MOSI),
                                       .miso_i(SPI_MISO),
                                       .cs_b_o(SPI_CS_B));
      end
   endgenerate

   // blink the LEDs. 1 millisecond is too fast obviously
   // so we prescale down by 256.
   reg [NUM_LED+8-1:0] led_counter = {NUM_LED+8{1'b0}};
   always @(posedge sysclk) begin
      if (sysclk_millice) led_counter <= led_counter + 1;
   end
   assign LED = led_counter[8 +: NUM_LED];      

   //// ADD BOARD SPECIFIC STUFF HERE ////
   
   ////     END BOARD SPECIFIC STUFF  ////
   
endmodule // board_checkout

		      
