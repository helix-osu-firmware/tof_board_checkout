// multi-chip support is godawful but WHATEVER
module board_spi_flash_checkout #(parameter NUM_SPI_FLASH=1)( input clk,
                                 output sclk_o,
                                 output mosi_o,
                                 input miso_i,
                                 output [NUM_SPI_FLASH-1:0] cs_b_o);
         
    // the board SPI flash checkout executes RDID on the SPI flash and reports the results here.
    reg [23:0] spi_flash_rdid = {24{1'b0}};
    
    wire [11:0] address;
    wire [17:0] instruction;
    wire bram_enable;
    reg [7:0] in_port = {8{1'b0}};
    wire [7:0] out_port;
    wire [7:0] port_id;
    wire write_strobe;
    wire k_write_strobe;
    wire read_strobe;
    reg interrupt = 0;
    wire interrupt_ack;
    wire sleep = 0;
    wire reset;
    // derived stuff
    // outputk functions use only bottom 4 bits
    wire [7:0] kport_id = { {4{1'b0}}, port_id[3:0] };
    // combined hybrid port (can be both output/outputk)
    wire [7:0] h_port_id = (k_write_strobe) ? kport_id : port_id;    
    wire [7:0] spi_in_port  = {{5{1'b0}}, miso_i, {2{1'b0}}};
        
    reg cs_b = 1;
    reg sclk = 0;
    reg mosi = 0;
    reg miso = 0;

    always @(posedge clk) begin
        in_port <= #1 spi_in_port;

        // SPI ports. Clock/CS is a constant port at 1 (and 3).
        if (k_write_strobe && port_id[0]) begin
            sclk <= #1 out_port[0];
            cs_b <= #1 out_port[1];
        end
        // Data. Hybrid output port at 2 (and 3).
        if ( (write_strobe || k_write_strobe) && ((h_port_id[5:4] == 2'b00) && port_id[1]))
            mosi <= #1 out_port[7];

        // flash read ID
        if (reset) spi_flash_rdid <= 24'h000000;
        else begin
            if (write_strobe && port_id[5:4] == 2'd1) spi_flash_rdid[7:0] <= out_port;
            if (write_strobe && port_id[5:4] == 2'd2) spi_flash_rdid[15:8] <= out_port;
            if (write_strobe && port_id[5:4] == 2'd3) spi_flash_rdid[23:16] <= out_port;
        end
    end                                                     

    kcpsm6 u_picoblaze(.address(address),.instruction(instruction),.bram_enable(bram_enable),
                        .in_port(in_port),.out_port(out_port),.port_id(port_id),
                        .write_strobe(write_strobe),.k_write_strobe(k_write_strobe),
                        .read_strobe(read_strobe),.interrupt(interrupt),.interrupt_ack(interrupt_ack),
                        .sleep(sleep),.reset(reset),.clk(clk));
    board_checkout_spi_rom u_rom(.clk(clk),.address(address),.enable(bram_enable),.instruction(instruction));
    // HACK-HACK WAY OF DEALING WITH MULTIPLE CHIPS
    // change them in the VIO and hit reset. lame, but works!
    wire [3:0] spi_flash_select;
    spi_checkout_vio u_vio(.clk(clk),.probe_in0(spi_flash_rdid),.probe_out0(reset),.probe_out1(spi_flash_select));
    
    assign sclk_o = sclk;
    assign mosi_o = mosi;
    generate
        genvar i;
        for (i=0;i<NUM_SPI_FLASH;i=i+1) begin : CSDEMUX
            assign cs_b_o[i] = (spi_flash_select == i) ? cs_b : 1'b1;
        end
    endgenerate
endmodule