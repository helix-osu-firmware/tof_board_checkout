/*
 * == pblaze-cc ==
 * source : board_checkout_spi_rom.c
 * create : Thu Mar  5 14:23:40 2020
 * modify : Thu Mar  5 14:23:40 2020
 */
`timescale 1 ps / 1ps

/* 
 * == pblaze-as ==
 * source : board_checkout_spi_rom.s
 * create : Thu Mar  5 14:24:17 2020
 * modify : Thu Mar  5 14:24:17 2020
 */
/* 
 * == pblaze-ld ==
 * target : kcpsm3
 */

module board_checkout_spi_rom (address, instruction, enable, clk, rdl);
parameter USE_JTAG_LOADER = "FALSE";
localparam BRAM_PORT_WIDTH = 18;
localparam BRAM_ADR_WIDTH = (BRAM_PORT_WIDTH == 18) ? 10 : 11;
localparam BRAM_WE_WIDTH = (BRAM_PORT_WIDTH == 18) ? 2 : 1;
input [9:0] address;
input clk;
input enable;
output [17:0] instruction;
output rdl; // download reset

wire [BRAM_ADR_WIDTH-1:0] jtag_addr;
wire jtag_we;
wire jtag_clk;
wire [17:0] jtag_din;
wire [17:0] bram_macro_din;
wire [17:0] jtag_dout;
wire [17:0] bram_macro_dout;
wire jtag_en;

// Note: JTAG loader's DIN goes to (15:0) DIBDI and (17:16) DIPBDIP.
// Because we use the TDP macro, the parity is interspersed every byte,
// meaning we need to swizzle it to
// { jtag_din[17],jtag_din[8 +: 8],jtag_din[16],jtag_din[0 +: 8] }
// and when going back, we need to do
// { bram_macro_dout[17], bram_macro_dout[8], bram_macro_dout[9 +: 8], bram_macro_dout[0 +: 8] }
assign bram_macro_din = { jtag_din[17], jtag_din[8 +: 8],    // byte 1
                          jtag_din[16], jtag_din[0 +: 8] };  // byte 0
assign jtag_dout = { bram_macro_dout[17], bram_macro_dout[8],            // parity
                     bram_macro_dout[9 +: 8], bram_macro_dout[0 +: 8] }; // data

generate
  if (USE_JTAG_LOADER == "YES" || USE_JTAG_LOADER == "TRUE") begin : JL
     jtag_loader_6 #(.C_JTAG_LOADER_ENABLE(1),
                     .C_FAMILY("7S"),
                     .C_NUM_PICOBLAZE(1),
                     .C_BRAM_MAX_ADDR_WIDTH(10),
                     .C_PICOBLAZE_INSTRUCTION_DATA_WIDTH(18),
                     .C_JTAG_CHAIN(2),
                     .C_ADDR_WIDTH_0(10))
                   u_loader( .picoblaze_reset(rdl),
                             .jtag_en(jtag_en),
                             .jtag_din(jtag_din),
                             .jtag_addr(jtag_addr),
                             .jtag_clk(jtag_clk),
                             .jtag_we(jtag_we),
                             .jtag_dout_0(jtag_dout),
                             .jtag_dout_1('b0),
                             .jtag_dout_2('b0),
                             .jtag_dout_3('b0),
                             .jtag_dout_4('b0),
                             .jtag_dout_5('b0),
                             .jtag_dout_6('b0),
                             .jtag_dout_7('b0));
  end else begin : NOJL
     assign jtag_en = 0;
     assign jtag_we = 0;
     assign jtag_clk = 0;
     assign jtag_din = {18{1'b0}};
     assign jtag_addr = {BRAM_ADR_WIDTH{1'b0}};
  end
endgenerate

// Debugging symbols. Note that they're
// only 48 characters long max.
// synthesis translate_off

// allocate a bunch of space for the text
   reg [8*48-1:0] dbg_instr;
   always @(*) begin
     case(address)
         0 : dbg_instr = "boot                                           ";
         1 : dbg_instr = "loop                                           ";
         2 : dbg_instr = "SPI_Flash_read_ID                              ";
         3 : dbg_instr = "SPI_Flash_read_ID+0x001                        ";
         4 : dbg_instr = "SPI_Flash_read_ID+0x002                        ";
         5 : dbg_instr = "SPI_Flash_read_ID+0x003                        ";
         6 : dbg_instr = "SPI_Flash_read_ID+0x004                        ";
         7 : dbg_instr = "SPI_Flash_read_ID+0x005                        ";
         8 : dbg_instr = "SPI_Flash_read_ID+0x006                        ";
         9 : dbg_instr = "SPI_Flash_read_ID+0x007                        ";
         10 : dbg_instr = "SPI_Flash_read_ID+0x008                        ";
         11 : dbg_instr = "SPI_Flash_read_ID+0x009                        ";
         12 : dbg_instr = "push3                                          ";
         13 : dbg_instr = "push3+0x001                                    ";
         14 : dbg_instr = "push2                                          ";
         15 : dbg_instr = "push2+0x001                                    ";
         16 : dbg_instr = "push1                                          ";
         17 : dbg_instr = "push1+0x001                                    ";
         18 : dbg_instr = "push1+0x002                                    ";
         19 : dbg_instr = "SPI_STARTUP_initialize                         ";
         20 : dbg_instr = "SPI_STARTUP_initialize+0x001                   ";
         21 : dbg_instr = "SPI_STARTUP_initialize+0x002                   ";
         22 : dbg_instr = "SPI_STARTUP_initialize+0x003                   ";
         23 : dbg_instr = "SPI_STARTUP_initialize+0x004                   ";
         24 : dbg_instr = "SPI_STARTUP_initialize+0x005                   ";
         25 : dbg_instr = "SPI_STARTUP_initialize+0x006                   ";
         26 : dbg_instr = "init                                           ";
         27 : dbg_instr = "init+0x001                                     ";
         28 : dbg_instr = "init+0x002                                     ";
         29 : dbg_instr = "init+0x003                                     ";
         30 : dbg_instr = "init+0x004                                     ";
         31 : dbg_instr = "init+0x005                                     ";
         32 : dbg_instr = "init+0x006                                     ";
         33 : dbg_instr = "SPI_Flash_tx_address                           ";
         34 : dbg_instr = "SPI_Flash_tx_stack2                            ";
         35 : dbg_instr = "SPI_Flash_tx_stack                             ";
         36 : dbg_instr = "SPI_Flash_tx_stack+0x001                       ";
         37 : dbg_instr = "SPI_Flash_tx_stack+0x002                       ";
         38 : dbg_instr = "SPI_Flash_single_command                       ";
         39 : dbg_instr = "SPI_Flash_single_command+0x001                 ";
         40 : dbg_instr = "SPI_Flash_single_command+0x002                 ";
         41 : dbg_instr = "SPI_Flash_write_complete                       ";
         42 : dbg_instr = "SPI_Flash_write_complete+0x001                 ";
         43 : dbg_instr = "SPI_Flash_write_complete+0x002                 ";
         44 : dbg_instr = "SPI_Flash_write_complete+0x003                 ";
         45 : dbg_instr = "SPI_Flash_write_complete+0x004                 ";
         46 : dbg_instr = "SPI_Flash_write_complete+0x005                 ";
         47 : dbg_instr = "SPI_Flash_write_complete+0x006                 ";
         48 : dbg_instr = "SPI_Flash_write_complete+0x007                 ";
         49 : dbg_instr = "SPI_tx_rx_twice                                ";
         50 : dbg_instr = "SPI_tx_rx                                      ";
         51 : dbg_instr = "SPI_tx_rx+0x001                                ";
         52 : dbg_instr = "SPI_tx_rx+0x002                                ";
         53 : dbg_instr = "SPI_tx_rx+0x003                                ";
         54 : dbg_instr = "SPI_tx_rx+0x004                                ";
         55 : dbg_instr = "SPI_tx_rx+0x005                                ";
         56 : dbg_instr = "SPI_tx_rx+0x006                                ";
         57 : dbg_instr = "SPI_tx_rx+0x007                                ";
         58 : dbg_instr = "SPI_tx_rx+0x008                                ";
         59 : dbg_instr = "SPI_tx_rx+0x009                                ";
         60 : dbg_instr = "SPI_tx_rx+0x00a                                ";
         61 : dbg_instr = "SPI_Flash_erase_nonvolatile_lock_bits          ";
         62 : dbg_instr = "SPI_Flash_erase_nonvolatile_lock_bits+0x001    ";
         63 : dbg_instr = "SPI_Flash_erase_nonvolatile_lock_bits+0x002    ";
         64 : dbg_instr = "SPI_Flash_erase_nonvolatile_lock_bits+0x003    ";
         65 : dbg_instr = "SPI_Flash_erase_nonvolatile_lock_bits+0x004    ";
         66 : dbg_instr = "SPI_Flash_read_begin                           ";
         67 : dbg_instr = "SPI_Flash_read_begin+0x001                     ";
         68 : dbg_instr = "SPI_Flash_read_begin+0x002                     ";
         69 : dbg_instr = "SPI_Flash_read_begin+0x003                     ";
         70 : dbg_instr = "SPI_Flash_read_begin+0x004                     ";
         71 : dbg_instr = "SPI_Flash_read_begin+0x005                     ";
         72 : dbg_instr = "SPI_Flash_read_begin+0x006                     ";
         73 : dbg_instr = "SPI_Flash_read_begin+0x007                     ";
         74 : dbg_instr = "SPI_Flash_read_begin+0x008                     ";
         75 : dbg_instr = "SPI_Flash_read_begin+0x009                     ";
         76 : dbg_instr = "SPI_Flash_read_begin+0x00a                     ";
         77 : dbg_instr = "pop3                                           ";
         78 : dbg_instr = "pop3+0x001                                     ";
         79 : dbg_instr = "pop3+0x002                                     ";
         80 : dbg_instr = "pop3+0x003                                     ";
         81 : dbg_instr = "pop2                                           ";
         82 : dbg_instr = "pop2+0x001                                     ";
         83 : dbg_instr = "pop2+0x002                                     ";
         84 : dbg_instr = "pop2+0x003                                     ";
         85 : dbg_instr = "pop1                                           ";
         86 : dbg_instr = "pop1+0x001                                     ";
         87 : dbg_instr = "pop1+0x002                                     ";
         88 : dbg_instr = "SPI_Flash_wait_WIP                             ";
         89 : dbg_instr = "SPI_Flash_wait_WIP+0x001                       ";
         90 : dbg_instr = "SPI_Flash_wait_WIP+0x002                       ";
         91 : dbg_instr = "SPI_Flash_wait_WIP+0x003                       ";
         92 : dbg_instr = "SPI_Flash_wait_WIP+0x004                       ";
         93 : dbg_instr = "SPI_Flash_wait_WIP+0x005                       ";
         94 : dbg_instr = "SPI_Flash_wait_WIP+0x006                       ";
         95 : dbg_instr = "SPI_Flash_wait_WIP+0x007                       ";
         96 : dbg_instr = "SPI_Flash_wait_WIP+0x008                       ";
         97 : dbg_instr = "SPI_Flash_wait_WIP+0x009                       ";
         98 : dbg_instr = "SPI_Flash_wait_WIP+0x00a                       ";
         99 : dbg_instr = "SPI_Flash_wait_WIP+0x00b                       ";
         100 : dbg_instr = "SPI_Flash_wait_WIP+0x00c                       ";
         101 : dbg_instr = "SPI_Flash_wait_WIP+0x00d                       ";
         102 : dbg_instr = "SPI_Flash_wait_WIP+0x00e                       ";
         103 : dbg_instr = "SPI_Flash_wait_WIP+0x00f                       ";
         104 : dbg_instr = "SPI_Flash_wait_WIP+0x010                       ";
         105 : dbg_instr = "SPI_Flash_read_SR                              ";
         106 : dbg_instr = "SPI_Flash_read_SR+0x001                        ";
         107 : dbg_instr = "SPI_Flash_read_SR+0x002                        ";
         108 : dbg_instr = "SPI_Flash_read_SR+0x003                        ";
         109 : dbg_instr = "SPI_Flash_write_begin                          ";
         110 : dbg_instr = "SPI_Flash_write_begin+0x001                    ";
         111 : dbg_instr = "SPI_Flash_write_begin+0x002                    ";
         112 : dbg_instr = "SPI_Flash_write_begin+0x003                    ";
         113 : dbg_instr = "SPI_Flash_write_begin+0x004                    ";
         114 : dbg_instr = "SPI_Flash_write_begin+0x005                    ";
         115 : dbg_instr = "SPI_Flash_write_begin+0x006                    ";
         116 : dbg_instr = "SPI_Flash_write_begin+0x007                    ";
         117 : dbg_instr = "SPI_Flash_write_begin+0x008                    ";
         118 : dbg_instr = "SPI_Flash_write_begin+0x009                    ";
         119 : dbg_instr = "SPI_Flash_write_begin+0x00a                    ";
         120 : dbg_instr = "SPI_Flash_write_begin+0x00b                    ";
         121 : dbg_instr = "SPI_Flash_reset                                ";
         122 : dbg_instr = "SPI_Flash_reset+0x001                          ";
         123 : dbg_instr = "SPI_Flash_reset+0x002                          ";
         124 : dbg_instr = "SPI_Flash_reset+0x003                          ";
         125 : dbg_instr = "SPI_Flash_reset+0x004                          ";
         126 : dbg_instr = "SPI_Flash_reset+0x005                          ";
         127 : dbg_instr = "SPI_Flash_reset+0x006                          ";
         128 : dbg_instr = "SPI_Flash_erase_sector                         ";
         129 : dbg_instr = "SPI_Flash_erase_sector+0x001                   ";
         130 : dbg_instr = "SPI_Flash_erase_sector+0x002                   ";
         131 : dbg_instr = "SPI_Flash_erase_sector+0x003                   ";
         132 : dbg_instr = "SPI_Flash_erase_sector+0x004                   ";
         133 : dbg_instr = "SPI_Flash_erase_sector+0x005                   ";
         134 : dbg_instr = "SPI_Flash_erase_sector+0x006                   ";
         135 : dbg_instr = "SPI_Flash_erase_sector+0x007                   ";
         136 : dbg_instr = "SPI_Flash_erase_sector+0x008                   ";
         137 : dbg_instr = "SPI_Flash_erase_sector+0x009                   ";
         138 : dbg_instr = "SPI_Flash_erase_sector+0x00a                   ";
         139 : dbg_instr = "SPI_Flash_erase_sector+0x00b                   ";
         140 : dbg_instr = "SPI_Flash_erase_sector_wait                    ";
         141 : dbg_instr = "SPI_Flash_erase_sector_wait+0x001              ";
         142 : dbg_instr = "SPI_disable_and_return                         ";
         143 : dbg_instr = "SPI_disable_and_return+0x001                   ";
         144 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits          ";
         145 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x001    ";
         146 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x002    ";
         147 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x003    ";
         148 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x004    ";
         149 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x005    ";
         150 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x006    ";
         151 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x007    ";
         152 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x008    ";
         153 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x009    ";
         154 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00a    ";
         155 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00b    ";
         156 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00c    ";
         157 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00d    ";
         158 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00e    ";
         159 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x00f    ";
         160 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x010    ";
         161 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x011    ";
         162 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x012    ";
         163 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x013    ";
         164 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x014    ";
         165 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x015    ";
         166 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x016    ";
         167 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x017    ";
         168 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x018    ";
         169 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x019    ";
         170 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01a    ";
         171 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01b    ";
         172 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01c    ";
         173 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01d    ";
         174 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01e    ";
         175 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x01f    ";
         176 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x020    ";
         177 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x021    ";
         178 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x022    ";
         179 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x023    ";
         180 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x024    ";
         181 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x025    ";
         182 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x026    ";
         183 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x027    ";
         184 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x028    ";
         185 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x029    ";
         186 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02a    ";
         187 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02b    ";
         188 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02c    ";
         189 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02d    ";
         190 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02e    ";
         191 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x02f    ";
         192 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x030    ";
         193 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x031    ";
         194 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x032    ";
         195 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x033    ";
         196 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x034    ";
         197 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x035    ";
         198 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x036    ";
         199 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x037    ";
         200 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x038    ";
         201 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x039    ";
         202 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03a    ";
         203 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03b    ";
         204 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03c    ";
         205 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03d    ";
         206 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03e    ";
         207 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x03f    ";
         208 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x040    ";
         209 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x041    ";
         210 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x042    ";
         211 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x043    ";
         212 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x044    ";
         213 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x045    ";
         214 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x046    ";
         215 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x047    ";
         216 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x048    ";
         217 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x049    ";
         218 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04a    ";
         219 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04b    ";
         220 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04c    ";
         221 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04d    ";
         222 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04e    ";
         223 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x04f    ";
         224 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x050    ";
         225 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x051    ";
         226 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x052    ";
         227 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x053    ";
         228 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x054    ";
         229 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x055    ";
         230 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x056    ";
         231 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x057    ";
         232 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x058    ";
         233 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x059    ";
         234 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05a    ";
         235 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05b    ";
         236 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05c    ";
         237 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05d    ";
         238 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05e    ";
         239 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x05f    ";
         240 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x060    ";
         241 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x061    ";
         242 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x062    ";
         243 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x063    ";
         244 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x064    ";
         245 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x065    ";
         246 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x066    ";
         247 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x067    ";
         248 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x068    ";
         249 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x069    ";
         250 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06a    ";
         251 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06b    ";
         252 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06c    ";
         253 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06d    ";
         254 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06e    ";
         255 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x06f    ";
         256 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x070    ";
         257 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x071    ";
         258 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x072    ";
         259 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x073    ";
         260 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x074    ";
         261 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x075    ";
         262 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x076    ";
         263 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x077    ";
         264 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x078    ";
         265 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x079    ";
         266 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07a    ";
         267 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07b    ";
         268 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07c    ";
         269 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07d    ";
         270 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07e    ";
         271 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x07f    ";
         272 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x080    ";
         273 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x081    ";
         274 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x082    ";
         275 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x083    ";
         276 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x084    ";
         277 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x085    ";
         278 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x086    ";
         279 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x087    ";
         280 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x088    ";
         281 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x089    ";
         282 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08a    ";
         283 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08b    ";
         284 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08c    ";
         285 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08d    ";
         286 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08e    ";
         287 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x08f    ";
         288 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x090    ";
         289 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x091    ";
         290 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x092    ";
         291 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x093    ";
         292 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x094    ";
         293 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x095    ";
         294 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x096    ";
         295 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x097    ";
         296 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x098    ";
         297 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x099    ";
         298 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09a    ";
         299 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09b    ";
         300 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09c    ";
         301 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09d    ";
         302 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09e    ";
         303 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x09f    ";
         304 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a0    ";
         305 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a1    ";
         306 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a2    ";
         307 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a3    ";
         308 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a4    ";
         309 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a5    ";
         310 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a6    ";
         311 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a7    ";
         312 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a8    ";
         313 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0a9    ";
         314 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0aa    ";
         315 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ab    ";
         316 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ac    ";
         317 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ad    ";
         318 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ae    ";
         319 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0af    ";
         320 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b0    ";
         321 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b1    ";
         322 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b2    ";
         323 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b3    ";
         324 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b4    ";
         325 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b5    ";
         326 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b6    ";
         327 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b7    ";
         328 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b8    ";
         329 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0b9    ";
         330 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ba    ";
         331 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0bb    ";
         332 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0bc    ";
         333 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0bd    ";
         334 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0be    ";
         335 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0bf    ";
         336 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c0    ";
         337 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c1    ";
         338 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c2    ";
         339 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c3    ";
         340 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c4    ";
         341 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c5    ";
         342 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c6    ";
         343 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c7    ";
         344 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c8    ";
         345 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0c9    ";
         346 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ca    ";
         347 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0cb    ";
         348 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0cc    ";
         349 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0cd    ";
         350 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ce    ";
         351 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0cf    ";
         352 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d0    ";
         353 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d1    ";
         354 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d2    ";
         355 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d3    ";
         356 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d4    ";
         357 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d5    ";
         358 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d6    ";
         359 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d7    ";
         360 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d8    ";
         361 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0d9    ";
         362 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0da    ";
         363 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0db    ";
         364 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0dc    ";
         365 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0dd    ";
         366 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0de    ";
         367 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0df    ";
         368 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e0    ";
         369 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e1    ";
         370 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e2    ";
         371 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e3    ";
         372 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e4    ";
         373 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e5    ";
         374 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e6    ";
         375 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e7    ";
         376 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e8    ";
         377 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0e9    ";
         378 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ea    ";
         379 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0eb    ";
         380 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ec    ";
         381 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ed    ";
         382 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ee    ";
         383 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ef    ";
         384 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f0    ";
         385 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f1    ";
         386 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f2    ";
         387 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f3    ";
         388 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f4    ";
         389 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f5    ";
         390 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f6    ";
         391 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f7    ";
         392 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f8    ";
         393 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0f9    ";
         394 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0fa    ";
         395 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0fb    ";
         396 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0fc    ";
         397 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0fd    ";
         398 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0fe    ";
         399 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x0ff    ";
         400 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x100    ";
         401 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x101    ";
         402 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x102    ";
         403 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x103    ";
         404 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x104    ";
         405 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x105    ";
         406 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x106    ";
         407 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x107    ";
         408 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x108    ";
         409 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x109    ";
         410 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10a    ";
         411 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10b    ";
         412 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10c    ";
         413 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10d    ";
         414 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10e    ";
         415 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x10f    ";
         416 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x110    ";
         417 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x111    ";
         418 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x112    ";
         419 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x113    ";
         420 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x114    ";
         421 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x115    ";
         422 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x116    ";
         423 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x117    ";
         424 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x118    ";
         425 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x119    ";
         426 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11a    ";
         427 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11b    ";
         428 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11c    ";
         429 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11d    ";
         430 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11e    ";
         431 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x11f    ";
         432 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x120    ";
         433 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x121    ";
         434 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x122    ";
         435 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x123    ";
         436 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x124    ";
         437 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x125    ";
         438 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x126    ";
         439 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x127    ";
         440 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x128    ";
         441 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x129    ";
         442 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12a    ";
         443 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12b    ";
         444 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12c    ";
         445 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12d    ";
         446 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12e    ";
         447 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x12f    ";
         448 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x130    ";
         449 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x131    ";
         450 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x132    ";
         451 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x133    ";
         452 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x134    ";
         453 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x135    ";
         454 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x136    ";
         455 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x137    ";
         456 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x138    ";
         457 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x139    ";
         458 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13a    ";
         459 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13b    ";
         460 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13c    ";
         461 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13d    ";
         462 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13e    ";
         463 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x13f    ";
         464 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x140    ";
         465 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x141    ";
         466 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x142    ";
         467 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x143    ";
         468 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x144    ";
         469 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x145    ";
         470 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x146    ";
         471 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x147    ";
         472 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x148    ";
         473 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x149    ";
         474 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14a    ";
         475 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14b    ";
         476 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14c    ";
         477 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14d    ";
         478 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14e    ";
         479 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x14f    ";
         480 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x150    ";
         481 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x151    ";
         482 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x152    ";
         483 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x153    ";
         484 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x154    ";
         485 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x155    ";
         486 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x156    ";
         487 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x157    ";
         488 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x158    ";
         489 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x159    ";
         490 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15a    ";
         491 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15b    ";
         492 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15c    ";
         493 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15d    ";
         494 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15e    ";
         495 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x15f    ";
         496 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x160    ";
         497 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x161    ";
         498 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x162    ";
         499 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x163    ";
         500 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x164    ";
         501 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x165    ";
         502 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x166    ";
         503 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x167    ";
         504 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x168    ";
         505 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x169    ";
         506 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16a    ";
         507 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16b    ";
         508 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16c    ";
         509 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16d    ";
         510 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16e    ";
         511 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x16f    ";
         512 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x170    ";
         513 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x171    ";
         514 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x172    ";
         515 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x173    ";
         516 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x174    ";
         517 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x175    ";
         518 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x176    ";
         519 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x177    ";
         520 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x178    ";
         521 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x179    ";
         522 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17a    ";
         523 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17b    ";
         524 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17c    ";
         525 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17d    ";
         526 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17e    ";
         527 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x17f    ";
         528 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x180    ";
         529 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x181    ";
         530 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x182    ";
         531 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x183    ";
         532 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x184    ";
         533 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x185    ";
         534 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x186    ";
         535 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x187    ";
         536 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x188    ";
         537 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x189    ";
         538 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18a    ";
         539 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18b    ";
         540 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18c    ";
         541 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18d    ";
         542 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18e    ";
         543 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x18f    ";
         544 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x190    ";
         545 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x191    ";
         546 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x192    ";
         547 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x193    ";
         548 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x194    ";
         549 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x195    ";
         550 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x196    ";
         551 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x197    ";
         552 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x198    ";
         553 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x199    ";
         554 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19a    ";
         555 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19b    ";
         556 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19c    ";
         557 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19d    ";
         558 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19e    ";
         559 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x19f    ";
         560 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a0    ";
         561 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a1    ";
         562 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a2    ";
         563 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a3    ";
         564 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a4    ";
         565 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a5    ";
         566 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a6    ";
         567 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a7    ";
         568 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a8    ";
         569 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1a9    ";
         570 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1aa    ";
         571 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ab    ";
         572 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ac    ";
         573 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ad    ";
         574 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ae    ";
         575 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1af    ";
         576 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b0    ";
         577 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b1    ";
         578 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b2    ";
         579 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b3    ";
         580 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b4    ";
         581 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b5    ";
         582 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b6    ";
         583 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b7    ";
         584 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b8    ";
         585 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1b9    ";
         586 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ba    ";
         587 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1bb    ";
         588 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1bc    ";
         589 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1bd    ";
         590 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1be    ";
         591 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1bf    ";
         592 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c0    ";
         593 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c1    ";
         594 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c2    ";
         595 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c3    ";
         596 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c4    ";
         597 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c5    ";
         598 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c6    ";
         599 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c7    ";
         600 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c8    ";
         601 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1c9    ";
         602 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ca    ";
         603 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1cb    ";
         604 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1cc    ";
         605 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1cd    ";
         606 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ce    ";
         607 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1cf    ";
         608 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d0    ";
         609 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d1    ";
         610 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d2    ";
         611 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d3    ";
         612 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d4    ";
         613 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d5    ";
         614 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d6    ";
         615 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d7    ";
         616 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d8    ";
         617 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1d9    ";
         618 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1da    ";
         619 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1db    ";
         620 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1dc    ";
         621 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1dd    ";
         622 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1de    ";
         623 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1df    ";
         624 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e0    ";
         625 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e1    ";
         626 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e2    ";
         627 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e3    ";
         628 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e4    ";
         629 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e5    ";
         630 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e6    ";
         631 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e7    ";
         632 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e8    ";
         633 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1e9    ";
         634 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ea    ";
         635 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1eb    ";
         636 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ec    ";
         637 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ed    ";
         638 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ee    ";
         639 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ef    ";
         640 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f0    ";
         641 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f1    ";
         642 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f2    ";
         643 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f3    ";
         644 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f4    ";
         645 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f5    ";
         646 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f6    ";
         647 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f7    ";
         648 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f8    ";
         649 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1f9    ";
         650 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1fa    ";
         651 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1fb    ";
         652 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1fc    ";
         653 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1fd    ";
         654 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1fe    ";
         655 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x1ff    ";
         656 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x200    ";
         657 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x201    ";
         658 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x202    ";
         659 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x203    ";
         660 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x204    ";
         661 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x205    ";
         662 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x206    ";
         663 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x207    ";
         664 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x208    ";
         665 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x209    ";
         666 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20a    ";
         667 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20b    ";
         668 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20c    ";
         669 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20d    ";
         670 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20e    ";
         671 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x20f    ";
         672 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x210    ";
         673 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x211    ";
         674 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x212    ";
         675 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x213    ";
         676 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x214    ";
         677 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x215    ";
         678 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x216    ";
         679 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x217    ";
         680 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x218    ";
         681 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x219    ";
         682 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21a    ";
         683 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21b    ";
         684 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21c    ";
         685 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21d    ";
         686 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21e    ";
         687 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x21f    ";
         688 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x220    ";
         689 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x221    ";
         690 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x222    ";
         691 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x223    ";
         692 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x224    ";
         693 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x225    ";
         694 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x226    ";
         695 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x227    ";
         696 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x228    ";
         697 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x229    ";
         698 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22a    ";
         699 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22b    ";
         700 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22c    ";
         701 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22d    ";
         702 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22e    ";
         703 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x22f    ";
         704 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x230    ";
         705 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x231    ";
         706 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x232    ";
         707 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x233    ";
         708 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x234    ";
         709 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x235    ";
         710 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x236    ";
         711 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x237    ";
         712 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x238    ";
         713 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x239    ";
         714 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23a    ";
         715 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23b    ";
         716 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23c    ";
         717 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23d    ";
         718 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23e    ";
         719 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x23f    ";
         720 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x240    ";
         721 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x241    ";
         722 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x242    ";
         723 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x243    ";
         724 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x244    ";
         725 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x245    ";
         726 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x246    ";
         727 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x247    ";
         728 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x248    ";
         729 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x249    ";
         730 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24a    ";
         731 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24b    ";
         732 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24c    ";
         733 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24d    ";
         734 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24e    ";
         735 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x24f    ";
         736 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x250    ";
         737 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x251    ";
         738 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x252    ";
         739 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x253    ";
         740 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x254    ";
         741 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x255    ";
         742 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x256    ";
         743 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x257    ";
         744 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x258    ";
         745 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x259    ";
         746 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25a    ";
         747 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25b    ";
         748 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25c    ";
         749 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25d    ";
         750 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25e    ";
         751 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x25f    ";
         752 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x260    ";
         753 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x261    ";
         754 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x262    ";
         755 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x263    ";
         756 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x264    ";
         757 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x265    ";
         758 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x266    ";
         759 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x267    ";
         760 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x268    ";
         761 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x269    ";
         762 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26a    ";
         763 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26b    ";
         764 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26c    ";
         765 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26d    ";
         766 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26e    ";
         767 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x26f    ";
         768 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x270    ";
         769 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x271    ";
         770 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x272    ";
         771 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x273    ";
         772 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x274    ";
         773 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x275    ";
         774 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x276    ";
         775 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x277    ";
         776 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x278    ";
         777 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x279    ";
         778 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27a    ";
         779 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27b    ";
         780 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27c    ";
         781 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27d    ";
         782 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27e    ";
         783 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x27f    ";
         784 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x280    ";
         785 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x281    ";
         786 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x282    ";
         787 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x283    ";
         788 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x284    ";
         789 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x285    ";
         790 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x286    ";
         791 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x287    ";
         792 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x288    ";
         793 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x289    ";
         794 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28a    ";
         795 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28b    ";
         796 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28c    ";
         797 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28d    ";
         798 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28e    ";
         799 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x28f    ";
         800 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x290    ";
         801 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x291    ";
         802 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x292    ";
         803 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x293    ";
         804 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x294    ";
         805 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x295    ";
         806 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x296    ";
         807 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x297    ";
         808 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x298    ";
         809 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x299    ";
         810 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29a    ";
         811 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29b    ";
         812 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29c    ";
         813 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29d    ";
         814 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29e    ";
         815 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x29f    ";
         816 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a0    ";
         817 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a1    ";
         818 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a2    ";
         819 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a3    ";
         820 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a4    ";
         821 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a5    ";
         822 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a6    ";
         823 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a7    ";
         824 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a8    ";
         825 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2a9    ";
         826 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2aa    ";
         827 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ab    ";
         828 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ac    ";
         829 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ad    ";
         830 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ae    ";
         831 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2af    ";
         832 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b0    ";
         833 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b1    ";
         834 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b2    ";
         835 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b3    ";
         836 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b4    ";
         837 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b5    ";
         838 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b6    ";
         839 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b7    ";
         840 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b8    ";
         841 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2b9    ";
         842 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ba    ";
         843 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2bb    ";
         844 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2bc    ";
         845 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2bd    ";
         846 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2be    ";
         847 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2bf    ";
         848 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c0    ";
         849 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c1    ";
         850 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c2    ";
         851 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c3    ";
         852 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c4    ";
         853 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c5    ";
         854 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c6    ";
         855 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c7    ";
         856 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c8    ";
         857 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2c9    ";
         858 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ca    ";
         859 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2cb    ";
         860 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2cc    ";
         861 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2cd    ";
         862 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ce    ";
         863 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2cf    ";
         864 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d0    ";
         865 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d1    ";
         866 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d2    ";
         867 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d3    ";
         868 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d4    ";
         869 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d5    ";
         870 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d6    ";
         871 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d7    ";
         872 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d8    ";
         873 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2d9    ";
         874 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2da    ";
         875 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2db    ";
         876 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2dc    ";
         877 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2dd    ";
         878 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2de    ";
         879 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2df    ";
         880 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e0    ";
         881 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e1    ";
         882 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e2    ";
         883 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e3    ";
         884 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e4    ";
         885 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e5    ";
         886 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e6    ";
         887 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e7    ";
         888 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e8    ";
         889 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2e9    ";
         890 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ea    ";
         891 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2eb    ";
         892 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ec    ";
         893 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ed    ";
         894 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ee    ";
         895 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ef    ";
         896 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f0    ";
         897 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f1    ";
         898 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f2    ";
         899 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f3    ";
         900 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f4    ";
         901 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f5    ";
         902 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f6    ";
         903 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f7    ";
         904 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f8    ";
         905 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2f9    ";
         906 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2fa    ";
         907 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2fb    ";
         908 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2fc    ";
         909 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2fd    ";
         910 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2fe    ";
         911 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x2ff    ";
         912 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x300    ";
         913 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x301    ";
         914 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x302    ";
         915 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x303    ";
         916 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x304    ";
         917 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x305    ";
         918 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x306    ";
         919 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x307    ";
         920 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x308    ";
         921 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x309    ";
         922 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30a    ";
         923 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30b    ";
         924 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30c    ";
         925 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30d    ";
         926 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30e    ";
         927 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x30f    ";
         928 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x310    ";
         929 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x311    ";
         930 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x312    ";
         931 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x313    ";
         932 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x314    ";
         933 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x315    ";
         934 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x316    ";
         935 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x317    ";
         936 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x318    ";
         937 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x319    ";
         938 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31a    ";
         939 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31b    ";
         940 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31c    ";
         941 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31d    ";
         942 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31e    ";
         943 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x31f    ";
         944 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x320    ";
         945 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x321    ";
         946 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x322    ";
         947 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x323    ";
         948 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x324    ";
         949 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x325    ";
         950 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x326    ";
         951 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x327    ";
         952 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x328    ";
         953 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x329    ";
         954 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32a    ";
         955 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32b    ";
         956 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32c    ";
         957 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32d    ";
         958 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32e    ";
         959 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x32f    ";
         960 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x330    ";
         961 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x331    ";
         962 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x332    ";
         963 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x333    ";
         964 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x334    ";
         965 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x335    ";
         966 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x336    ";
         967 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x337    ";
         968 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x338    ";
         969 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x339    ";
         970 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33a    ";
         971 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33b    ";
         972 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33c    ";
         973 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33d    ";
         974 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33e    ";
         975 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x33f    ";
         976 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x340    ";
         977 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x341    ";
         978 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x342    ";
         979 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x343    ";
         980 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x344    ";
         981 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x345    ";
         982 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x346    ";
         983 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x347    ";
         984 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x348    ";
         985 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x349    ";
         986 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34a    ";
         987 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34b    ";
         988 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34c    ";
         989 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34d    ";
         990 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34e    ";
         991 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x34f    ";
         992 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x350    ";
         993 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x351    ";
         994 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x352    ";
         995 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x353    ";
         996 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x354    ";
         997 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x355    ";
         998 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x356    ";
         999 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x357    ";
         1000 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x358    ";
         1001 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x359    ";
         1002 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35a    ";
         1003 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35b    ";
         1004 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35c    ";
         1005 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35d    ";
         1006 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35e    ";
         1007 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x35f    ";
         1008 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x360    ";
         1009 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x361    ";
         1010 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x362    ";
         1011 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x363    ";
         1012 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x364    ";
         1013 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x365    ";
         1014 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x366    ";
         1015 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x367    ";
         1016 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x368    ";
         1017 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x369    ";
         1018 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36a    ";
         1019 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36b    ";
         1020 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36c    ";
         1021 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36d    ";
         1022 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36e    ";
         1023 : dbg_instr = "SPI_Flash_write_nonvolatile_lock_bits+0x36f    ";
     endcase
   end
// synthesis translate_on


BRAM_TDP_MACRO #(
    .BRAM_SIZE("18Kb"),
    .DOA_REG(0),
    .DOB_REG(0),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .READ_WIDTH_A(18),
    .WRITE_WIDTH_A(18),
    .READ_WIDTH_B(BRAM_PORT_WIDTH),
    .WRITE_WIDTH_B(BRAM_PORT_WIDTH),
    .SIM_COLLISION_CHECK("ALL"),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    // The following INIT_xx declarations specify the initial contents of the RAM
    // Address 0 to 255
    .INIT_00(256'h9901EB909901EC90208E004D0010003200100032001000311A9FB0232001001A),
    .INIT_01(256'hDC30DB20DA1000020013193F500060159F01B021B0311F08B02350009901EA90),
    .INIT_02(256'h005500261A04001000581A01B023208E0032B023500000320055002300235000),
    .INIT_03(256'h1AE400261A06500060349B01B001B0114A00DF049F00DA02B0011B0800325000),
    .INIT_04(256'hAC90190100515000002100320AD000321A13204ADDFF1A03000CB023208C0026),
    .INIT_05(256'h1C004E004D064E004D064E004D060DA05000AA9019015000AB90190100555000),
    .INIT_06(256'h00261A06000C208E00311A05B0235000E060BE00BD009C01500060643A010069),
    .INIT_07(256'h20261A9900261AF000261A66B0235000002100320AD000321A122076DDFF1A02),
    .INIT_08(256'h5000B02320581AAAB023002100320AD000321ADC2089DDFF1AD800261A06000C),
    .INIT_09(256'h00000000000000002029002100320AD000321AE300261A06000C9D0120931D01),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Address 256 to 511
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Address 512 to 767
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Address 768 to 1023
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // The next set of INITP_xx are for the parity bits
    // Address 0 to 255
    .INITP_00(256'h888AA2348A8AD5B21554861A1AA234AA22DA428AA28AAAAAAA8B68A666AAAA2A),
    .INITP_01(256'h00000000000000000000000000000000000000000000000000A8889DA8A88D22),

    // Address 256 to 511
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Address 512 to 767
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Address 768 to 1023
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),

    // Output value upon SSR assertion
    .SRVAL_A(18'h000000),
    .SRVAL_B({BRAM_PORT_WIDTH{1'b0}})
) ramdp_1024_x_18(
    .DIA (18'h00000),
    .ENA (enable),
    .WEA ({BRAM_WE_WIDTH{1'b0}}),
    .RSTA(1'b0),
    .CLKA (clk),
    .ADDRA (address),
    // swizzle the parity bits into their proper place
    .DOA ({instruction[17],instruction[15:8],instruction[16],instruction[7:0]}),
    .DIB (bram_macro_din),
    .DOB (bram_macro_dout),
    .ENB (jtag_en),
    .WEB ({BRAM_WE_WIDTH{jtag_we}}),
    .RSTB(1'b0),
    .CLKB (jtag_clk),
    .ADDRB(jtag_addr)
);

endmodule
