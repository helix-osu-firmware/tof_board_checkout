// I2C scanner
module board_i2c_checkout( input clk,
                           input scl_i,
                           output scl_o,
                           output scl_t,
                           input sda_i,
                           output sda_o,
                           output sda_t );

    // SCAN ALL THE THINGS
    reg [127:0] address_found = {128{1'b0}};
    reg loop_done = 0;
    
    wire execute;
    reg execute_rereg = 0;
    reg execute_seen = 0;
    wire [1:0] numbytes;
    wire [6:0] address_7bit;
    (* DONT_TOUCH = "TRUE" *)
    wire [7:0] data[3:0];
    reg [1:0] result = {2{1'b0}};
    // registers:
    // control
    // address
    // numbytes
    // data0
    // data1
    // data2
    // data3
    // status
    // that's 8 total
    wire [7:0] i2c_registers[7:0];
    assign i2c_registers[0] = {{7{1'b0}},execute_seen};
    assign i2c_registers[1] = { {6{1'b0}}, result };
    assign i2c_registers[2] = { {6{1'b0}}, numbytes };
    assign i2c_registers[3] = {address_7bit, 1'b0};
    assign i2c_registers[4] = data[0];
    assign i2c_registers[5] = data[1];
    assign i2c_registers[6] = data[2];
    assign i2c_registers[7] = data[3];
    // whatever, this exists but just ignore it
    reg bus_sel = 0;
    reg [1:0] sda_tristate = 1'b1;
    reg [1:0] scl_tristate = 1'b1;
    wire [7:0] i2c_inport = { {6{1'b0}}, sda_i, scl_i };

    wire [11:0] address;
    wire [17:0] instruction;
    wire bram_enable;
    wire [7:0] out_port;
    wire [7:0] port_id;
    wire [7:0] in_port = (port_id[7:5]==3'b010) ? i2c_registers[port_id[2:0]] : i2c_inport ;
    wire write_strobe;
    wire k_write_strobe;
    wire read_strobe;
    wire interrupt = 0;
    wire interrupt_ack;
    wire sleep = 0;
    wire reset;

    localparam [7:0] PB_MASK_64BIT = 8'b11100111;
    localparam [7:0] PB_MASK_32BIT = 8'b11100011;
    localparam [7:0] PB_MASK_16BIT = 8'b11100001;
    localparam [7:0] PB_MASK_8BIT  = 8'b11100000;

    wire [7:0] kport_id = (k_write_strobe) ? { {4{1'b0}},port_id[3:0] } : port_id;
    
    always @(posedge clk) begin
        execute_rereg <= execute;
        
        if (write_strobe && (port_id[7:5]==3'b010) && (port_id[2:0] == 1)) execute_seen <= 0;
        else if (execute && !execute_rereg) execute_seen <= 1;
        
        if (write_strobe && (port_id[7:5]==3'b010) && (port_id[2:0] == 1)) result <= out_port[1:0];
        
        // no bus sel
        // CLK is 1 and 3
        if ((write_strobe || k_write_strobe) &&
            (((kport_id & PB_MASK_32BIT) == 8'h01)||((kport_id & PB_MASK_32BIT)==8'h03))) scl_tristate[bus_sel] <= out_port[0];
        // DATA is 2 and 3
        if ((write_strobe || k_write_strobe) &&
            (((kport_id & PB_MASK_32BIT) == 8'h02)||((kport_id & PB_MASK_32BIT)==8'h03))) sda_tristate[bus_sel] <= out_port[1];        
            
        if (write_strobe && port_id[7]) address_found[port_id[6:0]] <= out_port[0];
        if (write_strobe && (port_id[7:5]==3'b001)) loop_done <= out_port[0];
    end    

    // this is the time reference for I2C.
    parameter [7:0] HWBUILD = 8'd25;
    kcpsm6 #(.HWBUILD(HWBUILD)) u_picoblaze(.address(address),.instruction(instruction),.bram_enable(bram_enable),
                        .in_port(in_port),.out_port(out_port),.port_id(port_id),
                        .write_strobe(write_strobe),.k_write_strobe(k_write_strobe),
                        .read_strobe(read_strobe),.interrupt(interrupt),.interrupt_ack(interrupt_ack),
                        .sleep(sleep),.reset(reset),.clk(clk));

    i2c_checkout_rom #(.USE_JTAG_LOADER("FALSE")) u_rom(.clk(clk),.address(address),.enable(bram_enable),.instruction(instruction));

    i2c_checkout_vio u_vio(.clk(clk),.probe_in0(address_found),.probe_in1(loop_done),.probe_out0(reset),
                           .probe_in2(result),
                           .probe_out1(execute),
                           .probe_out2(numbytes),
                           .probe_out3(address_7bit),
                           .probe_out4(data[0]),
                           .probe_out5(data[1]),
                           .probe_out6(data[2]),
                           .probe_out7(data[3]));

    assign sda_t = sda_tristate[0];
    assign scl_t = scl_tristate[0];
    assign sda_o = {2{1'b0}};
    assign scl_o = {2{1'b0}};

endmodule