/*
 * == pblaze-cc ==
 * source : i2c_checkout_rom.c
 * create : Thu Mar 12 11:11:22 2020
 * modify : Thu Mar 12 11:11:22 2020
 */
`timescale 1 ps / 1ps

/* 
 * == pblaze-as ==
 * source : i2c_checkout_rom.s
 * create : Thu Mar 12 11:11:25 2020
 * modify : Thu Mar 12 11:11:25 2020
 */
/* 
 * == pblaze-ld ==
 * target : kcpsm3
 */

module i2c_checkout_rom (address, instruction, enable, clk, rdl);
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
         1 : dbg_instr = "boot+0x001                                     ";
         2 : dbg_instr = "boot+0x002                                     ";
         3 : dbg_instr = "boot+0x003                                     ";
         4 : dbg_instr = "loop                                           ";
         5 : dbg_instr = "loop+0x001                                     ";
         6 : dbg_instr = "loop+0x002                                     ";
         7 : dbg_instr = "loop+0x003                                     ";
         8 : dbg_instr = "loop+0x004                                     ";
         9 : dbg_instr = "loop+0x005                                     ";
         10 : dbg_instr = "loop+0x006                                     ";
         11 : dbg_instr = "loop+0x007                                     ";
         12 : dbg_instr = "loop+0x008                                     ";
         13 : dbg_instr = "loop+0x009                                     ";
         14 : dbg_instr = "loop+0x00a                                     ";
         15 : dbg_instr = "loop+0x00b                                     ";
         16 : dbg_instr = "loop+0x00c                                     ";
         17 : dbg_instr = "loop+0x00d                                     ";
         18 : dbg_instr = "loop+0x00e                                     ";
         19 : dbg_instr = "loop+0x00f                                     ";
         20 : dbg_instr = "loop+0x010                                     ";
         21 : dbg_instr = "loop+0x011                                     ";
         22 : dbg_instr = "loop+0x012                                     ";
         23 : dbg_instr = "I2C_delay_5us                                  ";
         24 : dbg_instr = "I2C_delay_4us                                  ";
         25 : dbg_instr = "I2C_delay_2us                                  ";
         26 : dbg_instr = "I2C_delay_1us                                  ";
         27 : dbg_instr = "I2C_delay_1us+0x001                            ";
         28 : dbg_instr = "I2C_delay_1us+0x002                            ";
         29 : dbg_instr = "I2C_delay_1us+0x003                            ";
         30 : dbg_instr = "I2C_reg_write                                  ";
         31 : dbg_instr = "I2C_reg_write+0x001                            ";
         32 : dbg_instr = "I2C_reg_write+0x002                            ";
         33 : dbg_instr = "I2C_reg_write+0x003                            ";
         34 : dbg_instr = "I2C_reg_write+0x004                            ";
         35 : dbg_instr = "I2C_write_bytes_process                        ";
         36 : dbg_instr = "I2C_write_bytes_process+0x001                  ";
         37 : dbg_instr = "I2C_write_bytes_process+0x002                  ";
         38 : dbg_instr = "I2C_write_bytes_process+0x003                  ";
         39 : dbg_instr = "I2C_write_bytes_process+0x004                  ";
         40 : dbg_instr = "I2C_write_bytes_process_failure                ";
         41 : dbg_instr = "I2C_write_bytes_process_failure+0x001          ";
         42 : dbg_instr = "I2C_write_bytes_process_failure+0x002          ";
         43 : dbg_instr = "I2C_clk_Low                                    ";
         44 : dbg_instr = "I2C_clk_Low+0x001                              ";
         45 : dbg_instr = "I2C_clk_Low+0x002                              ";
         46 : dbg_instr = "I2C_Tx_NACK                                    ";
         47 : dbg_instr = "I2C_Tx_NACK+0x001                              ";
         48 : dbg_instr = "I2C_Tx_ACK                                     ";
         49 : dbg_instr = "I2C_clk_pulse                                  ";
         50 : dbg_instr = "I2C_clk_pulse+0x001                            ";
         51 : dbg_instr = "I2C_clk_pulse+0x002                            ";
         52 : dbg_instr = "I2C_clk_pulse+0x003                            ";
         53 : dbg_instr = "I2C_clk_pulse+0x004                            ";
         54 : dbg_instr = "I2C_update_read_reg_turnaround                 ";
         55 : dbg_instr = "I2C_update_read_reg_turnaround+0x001           ";
         56 : dbg_instr = "I2C_update_read_reg_turnaround+0x002           ";
         57 : dbg_instr = "I2C_update_read_reg_turnaround+0x003           ";
         58 : dbg_instr = "I2C_update_read_reg_turnaround+0x004           ";
         59 : dbg_instr = "I2C_update_read_reg_turnaround+0x005           ";
         60 : dbg_instr = "I2C_update_read_reg_turnaround+0x006           ";
         61 : dbg_instr = "I2C_update_read_reg_turnaround+0x007           ";
         62 : dbg_instr = "I2C_update_read_reg_turnaround+0x008           ";
         63 : dbg_instr = "check_device                                   ";
         64 : dbg_instr = "check_device+0x001                             ";
         65 : dbg_instr = "check_device+0x002                             ";
         66 : dbg_instr = "check_device+0x003                             ";
         67 : dbg_instr = "check_device+0x004                             ";
         68 : dbg_instr = "check_device+0x005                             ";
         69 : dbg_instr = "check_device+0x006                             ";
         70 : dbg_instr = "I2C_write_bytes                                ";
         71 : dbg_instr = "I2C_write_bytes+0x001                          ";
         72 : dbg_instr = "I2C_write_bytes+0x002                          ";
         73 : dbg_instr = "I2C_write_bytes+0x003                          ";
         74 : dbg_instr = "I2C_write_bytes+0x004                          ";
         75 : dbg_instr = "I2C_write_bytes+0x005                          ";
         76 : dbg_instr = "init                                           ";
         77 : dbg_instr = "init+0x001                                     ";
         78 : dbg_instr = "init+0x002                                     ";
         79 : dbg_instr = "init+0x003                                     ";
         80 : dbg_instr = "init+0x004                                     ";
         81 : dbg_instr = "init+0x005                                     ";
         82 : dbg_instr = "init+0x006                                     ";
         83 : dbg_instr = "init+0x007                                     ";
         84 : dbg_instr = "init+0x008                                     ";
         85 : dbg_instr = "init+0x009                                     ";
         86 : dbg_instr = "init+0x00a                                     ";
         87 : dbg_instr = "init+0x00b                                     ";
         88 : dbg_instr = "init+0x00c                                     ";
         89 : dbg_instr = "init+0x00d                                     ";
         90 : dbg_instr = "init+0x00e                                     ";
         91 : dbg_instr = "init+0x00f                                     ";
         92 : dbg_instr = "I2C_Tx_byte_and_Rx_ACK                         ";
         93 : dbg_instr = "I2C_Rx_ACK                                     ";
         94 : dbg_instr = "I2C_Rx_ACK+0x001                               ";
         95 : dbg_instr = "I2C_Rx_ACK+0x002                               ";
         96 : dbg_instr = "I2C_reg_read16                                 ";
         97 : dbg_instr = "I2C_reg_read16+0x001                           ";
         98 : dbg_instr = "I2C_reg_read16+0x002                           ";
         99 : dbg_instr = "I2C_read_two_bytes                             ";
         100 : dbg_instr = "I2C_read_two_bytes+0x001                       ";
         101 : dbg_instr = "I2C_read_two_bytes+0x002                       ";
         102 : dbg_instr = "I2C_read_two_bytes+0x003                       ";
         103 : dbg_instr = "I2C_read_two_bytes+0x004                       ";
         104 : dbg_instr = "I2C_read_two_bytes+0x005                       ";
         105 : dbg_instr = "I2C_read_two_bytes+0x006                       ";
         106 : dbg_instr = "I2C_read_two_bytes+0x007                       ";
         107 : dbg_instr = "I2C_read_two_bytes+0x008                       ";
         108 : dbg_instr = "I2C_reg_read16_failure                         ";
         109 : dbg_instr = "I2C_reg_read16_failure+0x001                   ";
         110 : dbg_instr = "I2C_reg_read16_finish                          ";
         111 : dbg_instr = "I2C_reg_read16_finish+0x001                    ";
         112 : dbg_instr = "push3                                          ";
         113 : dbg_instr = "push3+0x001                                    ";
         114 : dbg_instr = "push2                                          ";
         115 : dbg_instr = "push2+0x001                                    ";
         116 : dbg_instr = "push1                                          ";
         117 : dbg_instr = "push1+0x001                                    ";
         118 : dbg_instr = "push1+0x002                                    ";
         119 : dbg_instr = "I2C_start                                      ";
         120 : dbg_instr = "I2C_start+0x001                                ";
         121 : dbg_instr = "I2C_start+0x002                                ";
         122 : dbg_instr = "I2C_start+0x003                                ";
         123 : dbg_instr = "I2C_start+0x004                                ";
         124 : dbg_instr = "I2C_start+0x005                                ";
         125 : dbg_instr = "I2C_start+0x006                                ";
         126 : dbg_instr = "pop3                                           ";
         127 : dbg_instr = "pop3+0x001                                     ";
         128 : dbg_instr = "pop3+0x002                                     ";
         129 : dbg_instr = "pop3+0x003                                     ";
         130 : dbg_instr = "pop2                                           ";
         131 : dbg_instr = "pop2+0x001                                     ";
         132 : dbg_instr = "pop2+0x002                                     ";
         133 : dbg_instr = "pop2+0x003                                     ";
         134 : dbg_instr = "pop1                                           ";
         135 : dbg_instr = "pop1+0x001                                     ";
         136 : dbg_instr = "pop1+0x002                                     ";
         137 : dbg_instr = "I2C_clk_Z                                      ";
         138 : dbg_instr = "I2C_clk_Z+0x001                                ";
         139 : dbg_instr = "I2C_clk_Z+0x002                                ";
         140 : dbg_instr = "I2C_clk_Z+0x003                                ";
         141 : dbg_instr = "I2C_clk_Z+0x004                                ";
         142 : dbg_instr = "I2C_stop                                       ";
         143 : dbg_instr = "I2C_stop+0x001                                 ";
         144 : dbg_instr = "I2C_stop+0x002                                 ";
         145 : dbg_instr = "I2C_stop+0x003                                 ";
         146 : dbg_instr = "I2C_stop+0x004                                 ";
         147 : dbg_instr = "I2C_stop+0x005                                 ";
         148 : dbg_instr = "I2C_Rx_bit                                     ";
         149 : dbg_instr = "I2C_Rx_bit+0x001                               ";
         150 : dbg_instr = "I2C_Rx_bit+0x002                               ";
         151 : dbg_instr = "I2C_Rx_bit+0x003                               ";
         152 : dbg_instr = "I2C_Rx_bit+0x004                               ";
         153 : dbg_instr = "I2C_Rx_bit+0x005                               ";
         154 : dbg_instr = "I2C_Rx_bit+0x006                               ";
         155 : dbg_instr = "I2C_Rx_bit+0x007                               ";
         156 : dbg_instr = "I2C_Rx_bit+0x008                               ";
         157 : dbg_instr = "I2C_Rx_bit+0x009                               ";
         158 : dbg_instr = "I2C_reg_read                                   ";
         159 : dbg_instr = "I2C_reg_read+0x001                             ";
         160 : dbg_instr = "I2C_reg_read+0x002                             ";
         161 : dbg_instr = "I2C_read_one_byte                              ";
         162 : dbg_instr = "I2C_read_one_byte+0x001                        ";
         163 : dbg_instr = "I2C_read_one_byte+0x002                        ";
         164 : dbg_instr = "I2C_read_one_byte+0x003                        ";
         165 : dbg_instr = "I2C_reg_read_failure                           ";
         166 : dbg_instr = "I2C_reg_read_finish                            ";
         167 : dbg_instr = "I2C_reg_read_finish+0x001                      ";
         168 : dbg_instr = "I2C_Rx_byte                                    ";
         169 : dbg_instr = "I2C_Rx_byte+0x001                              ";
         170 : dbg_instr = "I2C_Rx_byte+0x002                              ";
         171 : dbg_instr = "I2C_Rx_byte+0x003                              ";
         172 : dbg_instr = "I2C_Rx_byte+0x004                              ";
         173 : dbg_instr = "I2C_Rx_byte+0x005                              ";
         174 : dbg_instr = "I2C_read1_process                              ";
         175 : dbg_instr = "I2C_read1_process+0x001                        ";
         176 : dbg_instr = "I2C_read1_process+0x002                        ";
         177 : dbg_instr = "I2C_read1_process+0x003                        ";
         178 : dbg_instr = "I2C_read1_process+0x004                        ";
         179 : dbg_instr = "I2C_Tx_byte                                    ";
         180 : dbg_instr = "I2C_Tx_byte+0x001                              ";
         181 : dbg_instr = "I2C_Tx_byte+0x002                              ";
         182 : dbg_instr = "I2C_Tx_byte+0x003                              ";
         183 : dbg_instr = "I2C_Tx_byte+0x004                              ";
         184 : dbg_instr = "I2C_Tx_byte+0x005                              ";
         185 : dbg_instr = "I2C_Tx_byte+0x006                              ";
         186 : dbg_instr = "I2C_Tx_byte+0x007                              ";
         187 : dbg_instr = "I2C_Tx_byte+0x008                              ";
         188 : dbg_instr = "I2C_Tx_byte+0x009                              ";
         189 : dbg_instr = "I2C_Tx_byte+0x00a                              ";
         190 : dbg_instr = "I2C_Tx_byte+0x00b                              ";
         191 : dbg_instr = "I2C_Tx_byte+0x00c                              ";
         192 : dbg_instr = "I2C_Tx_byte+0x00d                              ";
         193 : dbg_instr = "I2C_Tx_byte+0x00e                              ";
         194 : dbg_instr = "I2C_Tx_byte+0x00f                              ";
         195 : dbg_instr = "I2C_Tx_byte+0x010                              ";
         196 : dbg_instr = "I2C_Tx_byte+0x011                              ";
         197 : dbg_instr = "I2C_Tx_byte+0x012                              ";
         198 : dbg_instr = "I2C_Tx_byte+0x013                              ";
         199 : dbg_instr = "I2C_Tx_byte+0x014                              ";
         200 : dbg_instr = "I2C_Tx_byte+0x015                              ";
         201 : dbg_instr = "I2C_Tx_byte+0x016                              ";
         202 : dbg_instr = "I2C_Tx_byte+0x017                              ";
         203 : dbg_instr = "I2C_Tx_byte+0x018                              ";
         204 : dbg_instr = "I2C_Tx_byte+0x019                              ";
         205 : dbg_instr = "I2C_Tx_byte+0x01a                              ";
         206 : dbg_instr = "I2C_Tx_byte+0x01b                              ";
         207 : dbg_instr = "I2C_Tx_byte+0x01c                              ";
         208 : dbg_instr = "I2C_Tx_byte+0x01d                              ";
         209 : dbg_instr = "I2C_Tx_byte+0x01e                              ";
         210 : dbg_instr = "I2C_Tx_byte+0x01f                              ";
         211 : dbg_instr = "I2C_Tx_byte+0x020                              ";
         212 : dbg_instr = "I2C_Tx_byte+0x021                              ";
         213 : dbg_instr = "I2C_Tx_byte+0x022                              ";
         214 : dbg_instr = "I2C_Tx_byte+0x023                              ";
         215 : dbg_instr = "I2C_Tx_byte+0x024                              ";
         216 : dbg_instr = "I2C_Tx_byte+0x025                              ";
         217 : dbg_instr = "I2C_Tx_byte+0x026                              ";
         218 : dbg_instr = "I2C_Tx_byte+0x027                              ";
         219 : dbg_instr = "I2C_Tx_byte+0x028                              ";
         220 : dbg_instr = "I2C_Tx_byte+0x029                              ";
         221 : dbg_instr = "I2C_Tx_byte+0x02a                              ";
         222 : dbg_instr = "I2C_Tx_byte+0x02b                              ";
         223 : dbg_instr = "I2C_Tx_byte+0x02c                              ";
         224 : dbg_instr = "I2C_Tx_byte+0x02d                              ";
         225 : dbg_instr = "I2C_Tx_byte+0x02e                              ";
         226 : dbg_instr = "I2C_Tx_byte+0x02f                              ";
         227 : dbg_instr = "I2C_Tx_byte+0x030                              ";
         228 : dbg_instr = "I2C_Tx_byte+0x031                              ";
         229 : dbg_instr = "I2C_Tx_byte+0x032                              ";
         230 : dbg_instr = "I2C_Tx_byte+0x033                              ";
         231 : dbg_instr = "I2C_Tx_byte+0x034                              ";
         232 : dbg_instr = "I2C_Tx_byte+0x035                              ";
         233 : dbg_instr = "I2C_Tx_byte+0x036                              ";
         234 : dbg_instr = "I2C_Tx_byte+0x037                              ";
         235 : dbg_instr = "I2C_Tx_byte+0x038                              ";
         236 : dbg_instr = "I2C_Tx_byte+0x039                              ";
         237 : dbg_instr = "I2C_Tx_byte+0x03a                              ";
         238 : dbg_instr = "I2C_Tx_byte+0x03b                              ";
         239 : dbg_instr = "I2C_Tx_byte+0x03c                              ";
         240 : dbg_instr = "I2C_Tx_byte+0x03d                              ";
         241 : dbg_instr = "I2C_Tx_byte+0x03e                              ";
         242 : dbg_instr = "I2C_Tx_byte+0x03f                              ";
         243 : dbg_instr = "I2C_Tx_byte+0x040                              ";
         244 : dbg_instr = "I2C_Tx_byte+0x041                              ";
         245 : dbg_instr = "I2C_Tx_byte+0x042                              ";
         246 : dbg_instr = "I2C_Tx_byte+0x043                              ";
         247 : dbg_instr = "I2C_Tx_byte+0x044                              ";
         248 : dbg_instr = "I2C_Tx_byte+0x045                              ";
         249 : dbg_instr = "I2C_Tx_byte+0x046                              ";
         250 : dbg_instr = "I2C_Tx_byte+0x047                              ";
         251 : dbg_instr = "I2C_Tx_byte+0x048                              ";
         252 : dbg_instr = "I2C_Tx_byte+0x049                              ";
         253 : dbg_instr = "I2C_Tx_byte+0x04a                              ";
         254 : dbg_instr = "I2C_Tx_byte+0x04b                              ";
         255 : dbg_instr = "I2C_Tx_byte+0x04c                              ";
         256 : dbg_instr = "I2C_Tx_byte+0x04d                              ";
         257 : dbg_instr = "I2C_Tx_byte+0x04e                              ";
         258 : dbg_instr = "I2C_Tx_byte+0x04f                              ";
         259 : dbg_instr = "I2C_Tx_byte+0x050                              ";
         260 : dbg_instr = "I2C_Tx_byte+0x051                              ";
         261 : dbg_instr = "I2C_Tx_byte+0x052                              ";
         262 : dbg_instr = "I2C_Tx_byte+0x053                              ";
         263 : dbg_instr = "I2C_Tx_byte+0x054                              ";
         264 : dbg_instr = "I2C_Tx_byte+0x055                              ";
         265 : dbg_instr = "I2C_Tx_byte+0x056                              ";
         266 : dbg_instr = "I2C_Tx_byte+0x057                              ";
         267 : dbg_instr = "I2C_Tx_byte+0x058                              ";
         268 : dbg_instr = "I2C_Tx_byte+0x059                              ";
         269 : dbg_instr = "I2C_Tx_byte+0x05a                              ";
         270 : dbg_instr = "I2C_Tx_byte+0x05b                              ";
         271 : dbg_instr = "I2C_Tx_byte+0x05c                              ";
         272 : dbg_instr = "I2C_Tx_byte+0x05d                              ";
         273 : dbg_instr = "I2C_Tx_byte+0x05e                              ";
         274 : dbg_instr = "I2C_Tx_byte+0x05f                              ";
         275 : dbg_instr = "I2C_Tx_byte+0x060                              ";
         276 : dbg_instr = "I2C_Tx_byte+0x061                              ";
         277 : dbg_instr = "I2C_Tx_byte+0x062                              ";
         278 : dbg_instr = "I2C_Tx_byte+0x063                              ";
         279 : dbg_instr = "I2C_Tx_byte+0x064                              ";
         280 : dbg_instr = "I2C_Tx_byte+0x065                              ";
         281 : dbg_instr = "I2C_Tx_byte+0x066                              ";
         282 : dbg_instr = "I2C_Tx_byte+0x067                              ";
         283 : dbg_instr = "I2C_Tx_byte+0x068                              ";
         284 : dbg_instr = "I2C_Tx_byte+0x069                              ";
         285 : dbg_instr = "I2C_Tx_byte+0x06a                              ";
         286 : dbg_instr = "I2C_Tx_byte+0x06b                              ";
         287 : dbg_instr = "I2C_Tx_byte+0x06c                              ";
         288 : dbg_instr = "I2C_Tx_byte+0x06d                              ";
         289 : dbg_instr = "I2C_Tx_byte+0x06e                              ";
         290 : dbg_instr = "I2C_Tx_byte+0x06f                              ";
         291 : dbg_instr = "I2C_Tx_byte+0x070                              ";
         292 : dbg_instr = "I2C_Tx_byte+0x071                              ";
         293 : dbg_instr = "I2C_Tx_byte+0x072                              ";
         294 : dbg_instr = "I2C_Tx_byte+0x073                              ";
         295 : dbg_instr = "I2C_Tx_byte+0x074                              ";
         296 : dbg_instr = "I2C_Tx_byte+0x075                              ";
         297 : dbg_instr = "I2C_Tx_byte+0x076                              ";
         298 : dbg_instr = "I2C_Tx_byte+0x077                              ";
         299 : dbg_instr = "I2C_Tx_byte+0x078                              ";
         300 : dbg_instr = "I2C_Tx_byte+0x079                              ";
         301 : dbg_instr = "I2C_Tx_byte+0x07a                              ";
         302 : dbg_instr = "I2C_Tx_byte+0x07b                              ";
         303 : dbg_instr = "I2C_Tx_byte+0x07c                              ";
         304 : dbg_instr = "I2C_Tx_byte+0x07d                              ";
         305 : dbg_instr = "I2C_Tx_byte+0x07e                              ";
         306 : dbg_instr = "I2C_Tx_byte+0x07f                              ";
         307 : dbg_instr = "I2C_Tx_byte+0x080                              ";
         308 : dbg_instr = "I2C_Tx_byte+0x081                              ";
         309 : dbg_instr = "I2C_Tx_byte+0x082                              ";
         310 : dbg_instr = "I2C_Tx_byte+0x083                              ";
         311 : dbg_instr = "I2C_Tx_byte+0x084                              ";
         312 : dbg_instr = "I2C_Tx_byte+0x085                              ";
         313 : dbg_instr = "I2C_Tx_byte+0x086                              ";
         314 : dbg_instr = "I2C_Tx_byte+0x087                              ";
         315 : dbg_instr = "I2C_Tx_byte+0x088                              ";
         316 : dbg_instr = "I2C_Tx_byte+0x089                              ";
         317 : dbg_instr = "I2C_Tx_byte+0x08a                              ";
         318 : dbg_instr = "I2C_Tx_byte+0x08b                              ";
         319 : dbg_instr = "I2C_Tx_byte+0x08c                              ";
         320 : dbg_instr = "I2C_Tx_byte+0x08d                              ";
         321 : dbg_instr = "I2C_Tx_byte+0x08e                              ";
         322 : dbg_instr = "I2C_Tx_byte+0x08f                              ";
         323 : dbg_instr = "I2C_Tx_byte+0x090                              ";
         324 : dbg_instr = "I2C_Tx_byte+0x091                              ";
         325 : dbg_instr = "I2C_Tx_byte+0x092                              ";
         326 : dbg_instr = "I2C_Tx_byte+0x093                              ";
         327 : dbg_instr = "I2C_Tx_byte+0x094                              ";
         328 : dbg_instr = "I2C_Tx_byte+0x095                              ";
         329 : dbg_instr = "I2C_Tx_byte+0x096                              ";
         330 : dbg_instr = "I2C_Tx_byte+0x097                              ";
         331 : dbg_instr = "I2C_Tx_byte+0x098                              ";
         332 : dbg_instr = "I2C_Tx_byte+0x099                              ";
         333 : dbg_instr = "I2C_Tx_byte+0x09a                              ";
         334 : dbg_instr = "I2C_Tx_byte+0x09b                              ";
         335 : dbg_instr = "I2C_Tx_byte+0x09c                              ";
         336 : dbg_instr = "I2C_Tx_byte+0x09d                              ";
         337 : dbg_instr = "I2C_Tx_byte+0x09e                              ";
         338 : dbg_instr = "I2C_Tx_byte+0x09f                              ";
         339 : dbg_instr = "I2C_Tx_byte+0x0a0                              ";
         340 : dbg_instr = "I2C_Tx_byte+0x0a1                              ";
         341 : dbg_instr = "I2C_Tx_byte+0x0a2                              ";
         342 : dbg_instr = "I2C_Tx_byte+0x0a3                              ";
         343 : dbg_instr = "I2C_Tx_byte+0x0a4                              ";
         344 : dbg_instr = "I2C_Tx_byte+0x0a5                              ";
         345 : dbg_instr = "I2C_Tx_byte+0x0a6                              ";
         346 : dbg_instr = "I2C_Tx_byte+0x0a7                              ";
         347 : dbg_instr = "I2C_Tx_byte+0x0a8                              ";
         348 : dbg_instr = "I2C_Tx_byte+0x0a9                              ";
         349 : dbg_instr = "I2C_Tx_byte+0x0aa                              ";
         350 : dbg_instr = "I2C_Tx_byte+0x0ab                              ";
         351 : dbg_instr = "I2C_Tx_byte+0x0ac                              ";
         352 : dbg_instr = "I2C_Tx_byte+0x0ad                              ";
         353 : dbg_instr = "I2C_Tx_byte+0x0ae                              ";
         354 : dbg_instr = "I2C_Tx_byte+0x0af                              ";
         355 : dbg_instr = "I2C_Tx_byte+0x0b0                              ";
         356 : dbg_instr = "I2C_Tx_byte+0x0b1                              ";
         357 : dbg_instr = "I2C_Tx_byte+0x0b2                              ";
         358 : dbg_instr = "I2C_Tx_byte+0x0b3                              ";
         359 : dbg_instr = "I2C_Tx_byte+0x0b4                              ";
         360 : dbg_instr = "I2C_Tx_byte+0x0b5                              ";
         361 : dbg_instr = "I2C_Tx_byte+0x0b6                              ";
         362 : dbg_instr = "I2C_Tx_byte+0x0b7                              ";
         363 : dbg_instr = "I2C_Tx_byte+0x0b8                              ";
         364 : dbg_instr = "I2C_Tx_byte+0x0b9                              ";
         365 : dbg_instr = "I2C_Tx_byte+0x0ba                              ";
         366 : dbg_instr = "I2C_Tx_byte+0x0bb                              ";
         367 : dbg_instr = "I2C_Tx_byte+0x0bc                              ";
         368 : dbg_instr = "I2C_Tx_byte+0x0bd                              ";
         369 : dbg_instr = "I2C_Tx_byte+0x0be                              ";
         370 : dbg_instr = "I2C_Tx_byte+0x0bf                              ";
         371 : dbg_instr = "I2C_Tx_byte+0x0c0                              ";
         372 : dbg_instr = "I2C_Tx_byte+0x0c1                              ";
         373 : dbg_instr = "I2C_Tx_byte+0x0c2                              ";
         374 : dbg_instr = "I2C_Tx_byte+0x0c3                              ";
         375 : dbg_instr = "I2C_Tx_byte+0x0c4                              ";
         376 : dbg_instr = "I2C_Tx_byte+0x0c5                              ";
         377 : dbg_instr = "I2C_Tx_byte+0x0c6                              ";
         378 : dbg_instr = "I2C_Tx_byte+0x0c7                              ";
         379 : dbg_instr = "I2C_Tx_byte+0x0c8                              ";
         380 : dbg_instr = "I2C_Tx_byte+0x0c9                              ";
         381 : dbg_instr = "I2C_Tx_byte+0x0ca                              ";
         382 : dbg_instr = "I2C_Tx_byte+0x0cb                              ";
         383 : dbg_instr = "I2C_Tx_byte+0x0cc                              ";
         384 : dbg_instr = "I2C_Tx_byte+0x0cd                              ";
         385 : dbg_instr = "I2C_Tx_byte+0x0ce                              ";
         386 : dbg_instr = "I2C_Tx_byte+0x0cf                              ";
         387 : dbg_instr = "I2C_Tx_byte+0x0d0                              ";
         388 : dbg_instr = "I2C_Tx_byte+0x0d1                              ";
         389 : dbg_instr = "I2C_Tx_byte+0x0d2                              ";
         390 : dbg_instr = "I2C_Tx_byte+0x0d3                              ";
         391 : dbg_instr = "I2C_Tx_byte+0x0d4                              ";
         392 : dbg_instr = "I2C_Tx_byte+0x0d5                              ";
         393 : dbg_instr = "I2C_Tx_byte+0x0d6                              ";
         394 : dbg_instr = "I2C_Tx_byte+0x0d7                              ";
         395 : dbg_instr = "I2C_Tx_byte+0x0d8                              ";
         396 : dbg_instr = "I2C_Tx_byte+0x0d9                              ";
         397 : dbg_instr = "I2C_Tx_byte+0x0da                              ";
         398 : dbg_instr = "I2C_Tx_byte+0x0db                              ";
         399 : dbg_instr = "I2C_Tx_byte+0x0dc                              ";
         400 : dbg_instr = "I2C_Tx_byte+0x0dd                              ";
         401 : dbg_instr = "I2C_Tx_byte+0x0de                              ";
         402 : dbg_instr = "I2C_Tx_byte+0x0df                              ";
         403 : dbg_instr = "I2C_Tx_byte+0x0e0                              ";
         404 : dbg_instr = "I2C_Tx_byte+0x0e1                              ";
         405 : dbg_instr = "I2C_Tx_byte+0x0e2                              ";
         406 : dbg_instr = "I2C_Tx_byte+0x0e3                              ";
         407 : dbg_instr = "I2C_Tx_byte+0x0e4                              ";
         408 : dbg_instr = "I2C_Tx_byte+0x0e5                              ";
         409 : dbg_instr = "I2C_Tx_byte+0x0e6                              ";
         410 : dbg_instr = "I2C_Tx_byte+0x0e7                              ";
         411 : dbg_instr = "I2C_Tx_byte+0x0e8                              ";
         412 : dbg_instr = "I2C_Tx_byte+0x0e9                              ";
         413 : dbg_instr = "I2C_Tx_byte+0x0ea                              ";
         414 : dbg_instr = "I2C_Tx_byte+0x0eb                              ";
         415 : dbg_instr = "I2C_Tx_byte+0x0ec                              ";
         416 : dbg_instr = "I2C_Tx_byte+0x0ed                              ";
         417 : dbg_instr = "I2C_Tx_byte+0x0ee                              ";
         418 : dbg_instr = "I2C_Tx_byte+0x0ef                              ";
         419 : dbg_instr = "I2C_Tx_byte+0x0f0                              ";
         420 : dbg_instr = "I2C_Tx_byte+0x0f1                              ";
         421 : dbg_instr = "I2C_Tx_byte+0x0f2                              ";
         422 : dbg_instr = "I2C_Tx_byte+0x0f3                              ";
         423 : dbg_instr = "I2C_Tx_byte+0x0f4                              ";
         424 : dbg_instr = "I2C_Tx_byte+0x0f5                              ";
         425 : dbg_instr = "I2C_Tx_byte+0x0f6                              ";
         426 : dbg_instr = "I2C_Tx_byte+0x0f7                              ";
         427 : dbg_instr = "I2C_Tx_byte+0x0f8                              ";
         428 : dbg_instr = "I2C_Tx_byte+0x0f9                              ";
         429 : dbg_instr = "I2C_Tx_byte+0x0fa                              ";
         430 : dbg_instr = "I2C_Tx_byte+0x0fb                              ";
         431 : dbg_instr = "I2C_Tx_byte+0x0fc                              ";
         432 : dbg_instr = "I2C_Tx_byte+0x0fd                              ";
         433 : dbg_instr = "I2C_Tx_byte+0x0fe                              ";
         434 : dbg_instr = "I2C_Tx_byte+0x0ff                              ";
         435 : dbg_instr = "I2C_Tx_byte+0x100                              ";
         436 : dbg_instr = "I2C_Tx_byte+0x101                              ";
         437 : dbg_instr = "I2C_Tx_byte+0x102                              ";
         438 : dbg_instr = "I2C_Tx_byte+0x103                              ";
         439 : dbg_instr = "I2C_Tx_byte+0x104                              ";
         440 : dbg_instr = "I2C_Tx_byte+0x105                              ";
         441 : dbg_instr = "I2C_Tx_byte+0x106                              ";
         442 : dbg_instr = "I2C_Tx_byte+0x107                              ";
         443 : dbg_instr = "I2C_Tx_byte+0x108                              ";
         444 : dbg_instr = "I2C_Tx_byte+0x109                              ";
         445 : dbg_instr = "I2C_Tx_byte+0x10a                              ";
         446 : dbg_instr = "I2C_Tx_byte+0x10b                              ";
         447 : dbg_instr = "I2C_Tx_byte+0x10c                              ";
         448 : dbg_instr = "I2C_Tx_byte+0x10d                              ";
         449 : dbg_instr = "I2C_Tx_byte+0x10e                              ";
         450 : dbg_instr = "I2C_Tx_byte+0x10f                              ";
         451 : dbg_instr = "I2C_Tx_byte+0x110                              ";
         452 : dbg_instr = "I2C_Tx_byte+0x111                              ";
         453 : dbg_instr = "I2C_Tx_byte+0x112                              ";
         454 : dbg_instr = "I2C_Tx_byte+0x113                              ";
         455 : dbg_instr = "I2C_Tx_byte+0x114                              ";
         456 : dbg_instr = "I2C_Tx_byte+0x115                              ";
         457 : dbg_instr = "I2C_Tx_byte+0x116                              ";
         458 : dbg_instr = "I2C_Tx_byte+0x117                              ";
         459 : dbg_instr = "I2C_Tx_byte+0x118                              ";
         460 : dbg_instr = "I2C_Tx_byte+0x119                              ";
         461 : dbg_instr = "I2C_Tx_byte+0x11a                              ";
         462 : dbg_instr = "I2C_Tx_byte+0x11b                              ";
         463 : dbg_instr = "I2C_Tx_byte+0x11c                              ";
         464 : dbg_instr = "I2C_Tx_byte+0x11d                              ";
         465 : dbg_instr = "I2C_Tx_byte+0x11e                              ";
         466 : dbg_instr = "I2C_Tx_byte+0x11f                              ";
         467 : dbg_instr = "I2C_Tx_byte+0x120                              ";
         468 : dbg_instr = "I2C_Tx_byte+0x121                              ";
         469 : dbg_instr = "I2C_Tx_byte+0x122                              ";
         470 : dbg_instr = "I2C_Tx_byte+0x123                              ";
         471 : dbg_instr = "I2C_Tx_byte+0x124                              ";
         472 : dbg_instr = "I2C_Tx_byte+0x125                              ";
         473 : dbg_instr = "I2C_Tx_byte+0x126                              ";
         474 : dbg_instr = "I2C_Tx_byte+0x127                              ";
         475 : dbg_instr = "I2C_Tx_byte+0x128                              ";
         476 : dbg_instr = "I2C_Tx_byte+0x129                              ";
         477 : dbg_instr = "I2C_Tx_byte+0x12a                              ";
         478 : dbg_instr = "I2C_Tx_byte+0x12b                              ";
         479 : dbg_instr = "I2C_Tx_byte+0x12c                              ";
         480 : dbg_instr = "I2C_Tx_byte+0x12d                              ";
         481 : dbg_instr = "I2C_Tx_byte+0x12e                              ";
         482 : dbg_instr = "I2C_Tx_byte+0x12f                              ";
         483 : dbg_instr = "I2C_Tx_byte+0x130                              ";
         484 : dbg_instr = "I2C_Tx_byte+0x131                              ";
         485 : dbg_instr = "I2C_Tx_byte+0x132                              ";
         486 : dbg_instr = "I2C_Tx_byte+0x133                              ";
         487 : dbg_instr = "I2C_Tx_byte+0x134                              ";
         488 : dbg_instr = "I2C_Tx_byte+0x135                              ";
         489 : dbg_instr = "I2C_Tx_byte+0x136                              ";
         490 : dbg_instr = "I2C_Tx_byte+0x137                              ";
         491 : dbg_instr = "I2C_Tx_byte+0x138                              ";
         492 : dbg_instr = "I2C_Tx_byte+0x139                              ";
         493 : dbg_instr = "I2C_Tx_byte+0x13a                              ";
         494 : dbg_instr = "I2C_Tx_byte+0x13b                              ";
         495 : dbg_instr = "I2C_Tx_byte+0x13c                              ";
         496 : dbg_instr = "I2C_Tx_byte+0x13d                              ";
         497 : dbg_instr = "I2C_Tx_byte+0x13e                              ";
         498 : dbg_instr = "I2C_Tx_byte+0x13f                              ";
         499 : dbg_instr = "I2C_Tx_byte+0x140                              ";
         500 : dbg_instr = "I2C_Tx_byte+0x141                              ";
         501 : dbg_instr = "I2C_Tx_byte+0x142                              ";
         502 : dbg_instr = "I2C_Tx_byte+0x143                              ";
         503 : dbg_instr = "I2C_Tx_byte+0x144                              ";
         504 : dbg_instr = "I2C_Tx_byte+0x145                              ";
         505 : dbg_instr = "I2C_Tx_byte+0x146                              ";
         506 : dbg_instr = "I2C_Tx_byte+0x147                              ";
         507 : dbg_instr = "I2C_Tx_byte+0x148                              ";
         508 : dbg_instr = "I2C_Tx_byte+0x149                              ";
         509 : dbg_instr = "I2C_Tx_byte+0x14a                              ";
         510 : dbg_instr = "I2C_Tx_byte+0x14b                              ";
         511 : dbg_instr = "I2C_Tx_byte+0x14c                              ";
         512 : dbg_instr = "I2C_Tx_byte+0x14d                              ";
         513 : dbg_instr = "I2C_Tx_byte+0x14e                              ";
         514 : dbg_instr = "I2C_Tx_byte+0x14f                              ";
         515 : dbg_instr = "I2C_Tx_byte+0x150                              ";
         516 : dbg_instr = "I2C_Tx_byte+0x151                              ";
         517 : dbg_instr = "I2C_Tx_byte+0x152                              ";
         518 : dbg_instr = "I2C_Tx_byte+0x153                              ";
         519 : dbg_instr = "I2C_Tx_byte+0x154                              ";
         520 : dbg_instr = "I2C_Tx_byte+0x155                              ";
         521 : dbg_instr = "I2C_Tx_byte+0x156                              ";
         522 : dbg_instr = "I2C_Tx_byte+0x157                              ";
         523 : dbg_instr = "I2C_Tx_byte+0x158                              ";
         524 : dbg_instr = "I2C_Tx_byte+0x159                              ";
         525 : dbg_instr = "I2C_Tx_byte+0x15a                              ";
         526 : dbg_instr = "I2C_Tx_byte+0x15b                              ";
         527 : dbg_instr = "I2C_Tx_byte+0x15c                              ";
         528 : dbg_instr = "I2C_Tx_byte+0x15d                              ";
         529 : dbg_instr = "I2C_Tx_byte+0x15e                              ";
         530 : dbg_instr = "I2C_Tx_byte+0x15f                              ";
         531 : dbg_instr = "I2C_Tx_byte+0x160                              ";
         532 : dbg_instr = "I2C_Tx_byte+0x161                              ";
         533 : dbg_instr = "I2C_Tx_byte+0x162                              ";
         534 : dbg_instr = "I2C_Tx_byte+0x163                              ";
         535 : dbg_instr = "I2C_Tx_byte+0x164                              ";
         536 : dbg_instr = "I2C_Tx_byte+0x165                              ";
         537 : dbg_instr = "I2C_Tx_byte+0x166                              ";
         538 : dbg_instr = "I2C_Tx_byte+0x167                              ";
         539 : dbg_instr = "I2C_Tx_byte+0x168                              ";
         540 : dbg_instr = "I2C_Tx_byte+0x169                              ";
         541 : dbg_instr = "I2C_Tx_byte+0x16a                              ";
         542 : dbg_instr = "I2C_Tx_byte+0x16b                              ";
         543 : dbg_instr = "I2C_Tx_byte+0x16c                              ";
         544 : dbg_instr = "I2C_Tx_byte+0x16d                              ";
         545 : dbg_instr = "I2C_Tx_byte+0x16e                              ";
         546 : dbg_instr = "I2C_Tx_byte+0x16f                              ";
         547 : dbg_instr = "I2C_Tx_byte+0x170                              ";
         548 : dbg_instr = "I2C_Tx_byte+0x171                              ";
         549 : dbg_instr = "I2C_Tx_byte+0x172                              ";
         550 : dbg_instr = "I2C_Tx_byte+0x173                              ";
         551 : dbg_instr = "I2C_Tx_byte+0x174                              ";
         552 : dbg_instr = "I2C_Tx_byte+0x175                              ";
         553 : dbg_instr = "I2C_Tx_byte+0x176                              ";
         554 : dbg_instr = "I2C_Tx_byte+0x177                              ";
         555 : dbg_instr = "I2C_Tx_byte+0x178                              ";
         556 : dbg_instr = "I2C_Tx_byte+0x179                              ";
         557 : dbg_instr = "I2C_Tx_byte+0x17a                              ";
         558 : dbg_instr = "I2C_Tx_byte+0x17b                              ";
         559 : dbg_instr = "I2C_Tx_byte+0x17c                              ";
         560 : dbg_instr = "I2C_Tx_byte+0x17d                              ";
         561 : dbg_instr = "I2C_Tx_byte+0x17e                              ";
         562 : dbg_instr = "I2C_Tx_byte+0x17f                              ";
         563 : dbg_instr = "I2C_Tx_byte+0x180                              ";
         564 : dbg_instr = "I2C_Tx_byte+0x181                              ";
         565 : dbg_instr = "I2C_Tx_byte+0x182                              ";
         566 : dbg_instr = "I2C_Tx_byte+0x183                              ";
         567 : dbg_instr = "I2C_Tx_byte+0x184                              ";
         568 : dbg_instr = "I2C_Tx_byte+0x185                              ";
         569 : dbg_instr = "I2C_Tx_byte+0x186                              ";
         570 : dbg_instr = "I2C_Tx_byte+0x187                              ";
         571 : dbg_instr = "I2C_Tx_byte+0x188                              ";
         572 : dbg_instr = "I2C_Tx_byte+0x189                              ";
         573 : dbg_instr = "I2C_Tx_byte+0x18a                              ";
         574 : dbg_instr = "I2C_Tx_byte+0x18b                              ";
         575 : dbg_instr = "I2C_Tx_byte+0x18c                              ";
         576 : dbg_instr = "I2C_Tx_byte+0x18d                              ";
         577 : dbg_instr = "I2C_Tx_byte+0x18e                              ";
         578 : dbg_instr = "I2C_Tx_byte+0x18f                              ";
         579 : dbg_instr = "I2C_Tx_byte+0x190                              ";
         580 : dbg_instr = "I2C_Tx_byte+0x191                              ";
         581 : dbg_instr = "I2C_Tx_byte+0x192                              ";
         582 : dbg_instr = "I2C_Tx_byte+0x193                              ";
         583 : dbg_instr = "I2C_Tx_byte+0x194                              ";
         584 : dbg_instr = "I2C_Tx_byte+0x195                              ";
         585 : dbg_instr = "I2C_Tx_byte+0x196                              ";
         586 : dbg_instr = "I2C_Tx_byte+0x197                              ";
         587 : dbg_instr = "I2C_Tx_byte+0x198                              ";
         588 : dbg_instr = "I2C_Tx_byte+0x199                              ";
         589 : dbg_instr = "I2C_Tx_byte+0x19a                              ";
         590 : dbg_instr = "I2C_Tx_byte+0x19b                              ";
         591 : dbg_instr = "I2C_Tx_byte+0x19c                              ";
         592 : dbg_instr = "I2C_Tx_byte+0x19d                              ";
         593 : dbg_instr = "I2C_Tx_byte+0x19e                              ";
         594 : dbg_instr = "I2C_Tx_byte+0x19f                              ";
         595 : dbg_instr = "I2C_Tx_byte+0x1a0                              ";
         596 : dbg_instr = "I2C_Tx_byte+0x1a1                              ";
         597 : dbg_instr = "I2C_Tx_byte+0x1a2                              ";
         598 : dbg_instr = "I2C_Tx_byte+0x1a3                              ";
         599 : dbg_instr = "I2C_Tx_byte+0x1a4                              ";
         600 : dbg_instr = "I2C_Tx_byte+0x1a5                              ";
         601 : dbg_instr = "I2C_Tx_byte+0x1a6                              ";
         602 : dbg_instr = "I2C_Tx_byte+0x1a7                              ";
         603 : dbg_instr = "I2C_Tx_byte+0x1a8                              ";
         604 : dbg_instr = "I2C_Tx_byte+0x1a9                              ";
         605 : dbg_instr = "I2C_Tx_byte+0x1aa                              ";
         606 : dbg_instr = "I2C_Tx_byte+0x1ab                              ";
         607 : dbg_instr = "I2C_Tx_byte+0x1ac                              ";
         608 : dbg_instr = "I2C_Tx_byte+0x1ad                              ";
         609 : dbg_instr = "I2C_Tx_byte+0x1ae                              ";
         610 : dbg_instr = "I2C_Tx_byte+0x1af                              ";
         611 : dbg_instr = "I2C_Tx_byte+0x1b0                              ";
         612 : dbg_instr = "I2C_Tx_byte+0x1b1                              ";
         613 : dbg_instr = "I2C_Tx_byte+0x1b2                              ";
         614 : dbg_instr = "I2C_Tx_byte+0x1b3                              ";
         615 : dbg_instr = "I2C_Tx_byte+0x1b4                              ";
         616 : dbg_instr = "I2C_Tx_byte+0x1b5                              ";
         617 : dbg_instr = "I2C_Tx_byte+0x1b6                              ";
         618 : dbg_instr = "I2C_Tx_byte+0x1b7                              ";
         619 : dbg_instr = "I2C_Tx_byte+0x1b8                              ";
         620 : dbg_instr = "I2C_Tx_byte+0x1b9                              ";
         621 : dbg_instr = "I2C_Tx_byte+0x1ba                              ";
         622 : dbg_instr = "I2C_Tx_byte+0x1bb                              ";
         623 : dbg_instr = "I2C_Tx_byte+0x1bc                              ";
         624 : dbg_instr = "I2C_Tx_byte+0x1bd                              ";
         625 : dbg_instr = "I2C_Tx_byte+0x1be                              ";
         626 : dbg_instr = "I2C_Tx_byte+0x1bf                              ";
         627 : dbg_instr = "I2C_Tx_byte+0x1c0                              ";
         628 : dbg_instr = "I2C_Tx_byte+0x1c1                              ";
         629 : dbg_instr = "I2C_Tx_byte+0x1c2                              ";
         630 : dbg_instr = "I2C_Tx_byte+0x1c3                              ";
         631 : dbg_instr = "I2C_Tx_byte+0x1c4                              ";
         632 : dbg_instr = "I2C_Tx_byte+0x1c5                              ";
         633 : dbg_instr = "I2C_Tx_byte+0x1c6                              ";
         634 : dbg_instr = "I2C_Tx_byte+0x1c7                              ";
         635 : dbg_instr = "I2C_Tx_byte+0x1c8                              ";
         636 : dbg_instr = "I2C_Tx_byte+0x1c9                              ";
         637 : dbg_instr = "I2C_Tx_byte+0x1ca                              ";
         638 : dbg_instr = "I2C_Tx_byte+0x1cb                              ";
         639 : dbg_instr = "I2C_Tx_byte+0x1cc                              ";
         640 : dbg_instr = "I2C_Tx_byte+0x1cd                              ";
         641 : dbg_instr = "I2C_Tx_byte+0x1ce                              ";
         642 : dbg_instr = "I2C_Tx_byte+0x1cf                              ";
         643 : dbg_instr = "I2C_Tx_byte+0x1d0                              ";
         644 : dbg_instr = "I2C_Tx_byte+0x1d1                              ";
         645 : dbg_instr = "I2C_Tx_byte+0x1d2                              ";
         646 : dbg_instr = "I2C_Tx_byte+0x1d3                              ";
         647 : dbg_instr = "I2C_Tx_byte+0x1d4                              ";
         648 : dbg_instr = "I2C_Tx_byte+0x1d5                              ";
         649 : dbg_instr = "I2C_Tx_byte+0x1d6                              ";
         650 : dbg_instr = "I2C_Tx_byte+0x1d7                              ";
         651 : dbg_instr = "I2C_Tx_byte+0x1d8                              ";
         652 : dbg_instr = "I2C_Tx_byte+0x1d9                              ";
         653 : dbg_instr = "I2C_Tx_byte+0x1da                              ";
         654 : dbg_instr = "I2C_Tx_byte+0x1db                              ";
         655 : dbg_instr = "I2C_Tx_byte+0x1dc                              ";
         656 : dbg_instr = "I2C_Tx_byte+0x1dd                              ";
         657 : dbg_instr = "I2C_Tx_byte+0x1de                              ";
         658 : dbg_instr = "I2C_Tx_byte+0x1df                              ";
         659 : dbg_instr = "I2C_Tx_byte+0x1e0                              ";
         660 : dbg_instr = "I2C_Tx_byte+0x1e1                              ";
         661 : dbg_instr = "I2C_Tx_byte+0x1e2                              ";
         662 : dbg_instr = "I2C_Tx_byte+0x1e3                              ";
         663 : dbg_instr = "I2C_Tx_byte+0x1e4                              ";
         664 : dbg_instr = "I2C_Tx_byte+0x1e5                              ";
         665 : dbg_instr = "I2C_Tx_byte+0x1e6                              ";
         666 : dbg_instr = "I2C_Tx_byte+0x1e7                              ";
         667 : dbg_instr = "I2C_Tx_byte+0x1e8                              ";
         668 : dbg_instr = "I2C_Tx_byte+0x1e9                              ";
         669 : dbg_instr = "I2C_Tx_byte+0x1ea                              ";
         670 : dbg_instr = "I2C_Tx_byte+0x1eb                              ";
         671 : dbg_instr = "I2C_Tx_byte+0x1ec                              ";
         672 : dbg_instr = "I2C_Tx_byte+0x1ed                              ";
         673 : dbg_instr = "I2C_Tx_byte+0x1ee                              ";
         674 : dbg_instr = "I2C_Tx_byte+0x1ef                              ";
         675 : dbg_instr = "I2C_Tx_byte+0x1f0                              ";
         676 : dbg_instr = "I2C_Tx_byte+0x1f1                              ";
         677 : dbg_instr = "I2C_Tx_byte+0x1f2                              ";
         678 : dbg_instr = "I2C_Tx_byte+0x1f3                              ";
         679 : dbg_instr = "I2C_Tx_byte+0x1f4                              ";
         680 : dbg_instr = "I2C_Tx_byte+0x1f5                              ";
         681 : dbg_instr = "I2C_Tx_byte+0x1f6                              ";
         682 : dbg_instr = "I2C_Tx_byte+0x1f7                              ";
         683 : dbg_instr = "I2C_Tx_byte+0x1f8                              ";
         684 : dbg_instr = "I2C_Tx_byte+0x1f9                              ";
         685 : dbg_instr = "I2C_Tx_byte+0x1fa                              ";
         686 : dbg_instr = "I2C_Tx_byte+0x1fb                              ";
         687 : dbg_instr = "I2C_Tx_byte+0x1fc                              ";
         688 : dbg_instr = "I2C_Tx_byte+0x1fd                              ";
         689 : dbg_instr = "I2C_Tx_byte+0x1fe                              ";
         690 : dbg_instr = "I2C_Tx_byte+0x1ff                              ";
         691 : dbg_instr = "I2C_Tx_byte+0x200                              ";
         692 : dbg_instr = "I2C_Tx_byte+0x201                              ";
         693 : dbg_instr = "I2C_Tx_byte+0x202                              ";
         694 : dbg_instr = "I2C_Tx_byte+0x203                              ";
         695 : dbg_instr = "I2C_Tx_byte+0x204                              ";
         696 : dbg_instr = "I2C_Tx_byte+0x205                              ";
         697 : dbg_instr = "I2C_Tx_byte+0x206                              ";
         698 : dbg_instr = "I2C_Tx_byte+0x207                              ";
         699 : dbg_instr = "I2C_Tx_byte+0x208                              ";
         700 : dbg_instr = "I2C_Tx_byte+0x209                              ";
         701 : dbg_instr = "I2C_Tx_byte+0x20a                              ";
         702 : dbg_instr = "I2C_Tx_byte+0x20b                              ";
         703 : dbg_instr = "I2C_Tx_byte+0x20c                              ";
         704 : dbg_instr = "I2C_Tx_byte+0x20d                              ";
         705 : dbg_instr = "I2C_Tx_byte+0x20e                              ";
         706 : dbg_instr = "I2C_Tx_byte+0x20f                              ";
         707 : dbg_instr = "I2C_Tx_byte+0x210                              ";
         708 : dbg_instr = "I2C_Tx_byte+0x211                              ";
         709 : dbg_instr = "I2C_Tx_byte+0x212                              ";
         710 : dbg_instr = "I2C_Tx_byte+0x213                              ";
         711 : dbg_instr = "I2C_Tx_byte+0x214                              ";
         712 : dbg_instr = "I2C_Tx_byte+0x215                              ";
         713 : dbg_instr = "I2C_Tx_byte+0x216                              ";
         714 : dbg_instr = "I2C_Tx_byte+0x217                              ";
         715 : dbg_instr = "I2C_Tx_byte+0x218                              ";
         716 : dbg_instr = "I2C_Tx_byte+0x219                              ";
         717 : dbg_instr = "I2C_Tx_byte+0x21a                              ";
         718 : dbg_instr = "I2C_Tx_byte+0x21b                              ";
         719 : dbg_instr = "I2C_Tx_byte+0x21c                              ";
         720 : dbg_instr = "I2C_Tx_byte+0x21d                              ";
         721 : dbg_instr = "I2C_Tx_byte+0x21e                              ";
         722 : dbg_instr = "I2C_Tx_byte+0x21f                              ";
         723 : dbg_instr = "I2C_Tx_byte+0x220                              ";
         724 : dbg_instr = "I2C_Tx_byte+0x221                              ";
         725 : dbg_instr = "I2C_Tx_byte+0x222                              ";
         726 : dbg_instr = "I2C_Tx_byte+0x223                              ";
         727 : dbg_instr = "I2C_Tx_byte+0x224                              ";
         728 : dbg_instr = "I2C_Tx_byte+0x225                              ";
         729 : dbg_instr = "I2C_Tx_byte+0x226                              ";
         730 : dbg_instr = "I2C_Tx_byte+0x227                              ";
         731 : dbg_instr = "I2C_Tx_byte+0x228                              ";
         732 : dbg_instr = "I2C_Tx_byte+0x229                              ";
         733 : dbg_instr = "I2C_Tx_byte+0x22a                              ";
         734 : dbg_instr = "I2C_Tx_byte+0x22b                              ";
         735 : dbg_instr = "I2C_Tx_byte+0x22c                              ";
         736 : dbg_instr = "I2C_Tx_byte+0x22d                              ";
         737 : dbg_instr = "I2C_Tx_byte+0x22e                              ";
         738 : dbg_instr = "I2C_Tx_byte+0x22f                              ";
         739 : dbg_instr = "I2C_Tx_byte+0x230                              ";
         740 : dbg_instr = "I2C_Tx_byte+0x231                              ";
         741 : dbg_instr = "I2C_Tx_byte+0x232                              ";
         742 : dbg_instr = "I2C_Tx_byte+0x233                              ";
         743 : dbg_instr = "I2C_Tx_byte+0x234                              ";
         744 : dbg_instr = "I2C_Tx_byte+0x235                              ";
         745 : dbg_instr = "I2C_Tx_byte+0x236                              ";
         746 : dbg_instr = "I2C_Tx_byte+0x237                              ";
         747 : dbg_instr = "I2C_Tx_byte+0x238                              ";
         748 : dbg_instr = "I2C_Tx_byte+0x239                              ";
         749 : dbg_instr = "I2C_Tx_byte+0x23a                              ";
         750 : dbg_instr = "I2C_Tx_byte+0x23b                              ";
         751 : dbg_instr = "I2C_Tx_byte+0x23c                              ";
         752 : dbg_instr = "I2C_Tx_byte+0x23d                              ";
         753 : dbg_instr = "I2C_Tx_byte+0x23e                              ";
         754 : dbg_instr = "I2C_Tx_byte+0x23f                              ";
         755 : dbg_instr = "I2C_Tx_byte+0x240                              ";
         756 : dbg_instr = "I2C_Tx_byte+0x241                              ";
         757 : dbg_instr = "I2C_Tx_byte+0x242                              ";
         758 : dbg_instr = "I2C_Tx_byte+0x243                              ";
         759 : dbg_instr = "I2C_Tx_byte+0x244                              ";
         760 : dbg_instr = "I2C_Tx_byte+0x245                              ";
         761 : dbg_instr = "I2C_Tx_byte+0x246                              ";
         762 : dbg_instr = "I2C_Tx_byte+0x247                              ";
         763 : dbg_instr = "I2C_Tx_byte+0x248                              ";
         764 : dbg_instr = "I2C_Tx_byte+0x249                              ";
         765 : dbg_instr = "I2C_Tx_byte+0x24a                              ";
         766 : dbg_instr = "I2C_Tx_byte+0x24b                              ";
         767 : dbg_instr = "I2C_Tx_byte+0x24c                              ";
         768 : dbg_instr = "I2C_Tx_byte+0x24d                              ";
         769 : dbg_instr = "I2C_Tx_byte+0x24e                              ";
         770 : dbg_instr = "I2C_Tx_byte+0x24f                              ";
         771 : dbg_instr = "I2C_Tx_byte+0x250                              ";
         772 : dbg_instr = "I2C_Tx_byte+0x251                              ";
         773 : dbg_instr = "I2C_Tx_byte+0x252                              ";
         774 : dbg_instr = "I2C_Tx_byte+0x253                              ";
         775 : dbg_instr = "I2C_Tx_byte+0x254                              ";
         776 : dbg_instr = "I2C_Tx_byte+0x255                              ";
         777 : dbg_instr = "I2C_Tx_byte+0x256                              ";
         778 : dbg_instr = "I2C_Tx_byte+0x257                              ";
         779 : dbg_instr = "I2C_Tx_byte+0x258                              ";
         780 : dbg_instr = "I2C_Tx_byte+0x259                              ";
         781 : dbg_instr = "I2C_Tx_byte+0x25a                              ";
         782 : dbg_instr = "I2C_Tx_byte+0x25b                              ";
         783 : dbg_instr = "I2C_Tx_byte+0x25c                              ";
         784 : dbg_instr = "I2C_Tx_byte+0x25d                              ";
         785 : dbg_instr = "I2C_Tx_byte+0x25e                              ";
         786 : dbg_instr = "I2C_Tx_byte+0x25f                              ";
         787 : dbg_instr = "I2C_Tx_byte+0x260                              ";
         788 : dbg_instr = "I2C_Tx_byte+0x261                              ";
         789 : dbg_instr = "I2C_Tx_byte+0x262                              ";
         790 : dbg_instr = "I2C_Tx_byte+0x263                              ";
         791 : dbg_instr = "I2C_Tx_byte+0x264                              ";
         792 : dbg_instr = "I2C_Tx_byte+0x265                              ";
         793 : dbg_instr = "I2C_Tx_byte+0x266                              ";
         794 : dbg_instr = "I2C_Tx_byte+0x267                              ";
         795 : dbg_instr = "I2C_Tx_byte+0x268                              ";
         796 : dbg_instr = "I2C_Tx_byte+0x269                              ";
         797 : dbg_instr = "I2C_Tx_byte+0x26a                              ";
         798 : dbg_instr = "I2C_Tx_byte+0x26b                              ";
         799 : dbg_instr = "I2C_Tx_byte+0x26c                              ";
         800 : dbg_instr = "I2C_Tx_byte+0x26d                              ";
         801 : dbg_instr = "I2C_Tx_byte+0x26e                              ";
         802 : dbg_instr = "I2C_Tx_byte+0x26f                              ";
         803 : dbg_instr = "I2C_Tx_byte+0x270                              ";
         804 : dbg_instr = "I2C_Tx_byte+0x271                              ";
         805 : dbg_instr = "I2C_Tx_byte+0x272                              ";
         806 : dbg_instr = "I2C_Tx_byte+0x273                              ";
         807 : dbg_instr = "I2C_Tx_byte+0x274                              ";
         808 : dbg_instr = "I2C_Tx_byte+0x275                              ";
         809 : dbg_instr = "I2C_Tx_byte+0x276                              ";
         810 : dbg_instr = "I2C_Tx_byte+0x277                              ";
         811 : dbg_instr = "I2C_Tx_byte+0x278                              ";
         812 : dbg_instr = "I2C_Tx_byte+0x279                              ";
         813 : dbg_instr = "I2C_Tx_byte+0x27a                              ";
         814 : dbg_instr = "I2C_Tx_byte+0x27b                              ";
         815 : dbg_instr = "I2C_Tx_byte+0x27c                              ";
         816 : dbg_instr = "I2C_Tx_byte+0x27d                              ";
         817 : dbg_instr = "I2C_Tx_byte+0x27e                              ";
         818 : dbg_instr = "I2C_Tx_byte+0x27f                              ";
         819 : dbg_instr = "I2C_Tx_byte+0x280                              ";
         820 : dbg_instr = "I2C_Tx_byte+0x281                              ";
         821 : dbg_instr = "I2C_Tx_byte+0x282                              ";
         822 : dbg_instr = "I2C_Tx_byte+0x283                              ";
         823 : dbg_instr = "I2C_Tx_byte+0x284                              ";
         824 : dbg_instr = "I2C_Tx_byte+0x285                              ";
         825 : dbg_instr = "I2C_Tx_byte+0x286                              ";
         826 : dbg_instr = "I2C_Tx_byte+0x287                              ";
         827 : dbg_instr = "I2C_Tx_byte+0x288                              ";
         828 : dbg_instr = "I2C_Tx_byte+0x289                              ";
         829 : dbg_instr = "I2C_Tx_byte+0x28a                              ";
         830 : dbg_instr = "I2C_Tx_byte+0x28b                              ";
         831 : dbg_instr = "I2C_Tx_byte+0x28c                              ";
         832 : dbg_instr = "I2C_Tx_byte+0x28d                              ";
         833 : dbg_instr = "I2C_Tx_byte+0x28e                              ";
         834 : dbg_instr = "I2C_Tx_byte+0x28f                              ";
         835 : dbg_instr = "I2C_Tx_byte+0x290                              ";
         836 : dbg_instr = "I2C_Tx_byte+0x291                              ";
         837 : dbg_instr = "I2C_Tx_byte+0x292                              ";
         838 : dbg_instr = "I2C_Tx_byte+0x293                              ";
         839 : dbg_instr = "I2C_Tx_byte+0x294                              ";
         840 : dbg_instr = "I2C_Tx_byte+0x295                              ";
         841 : dbg_instr = "I2C_Tx_byte+0x296                              ";
         842 : dbg_instr = "I2C_Tx_byte+0x297                              ";
         843 : dbg_instr = "I2C_Tx_byte+0x298                              ";
         844 : dbg_instr = "I2C_Tx_byte+0x299                              ";
         845 : dbg_instr = "I2C_Tx_byte+0x29a                              ";
         846 : dbg_instr = "I2C_Tx_byte+0x29b                              ";
         847 : dbg_instr = "I2C_Tx_byte+0x29c                              ";
         848 : dbg_instr = "I2C_Tx_byte+0x29d                              ";
         849 : dbg_instr = "I2C_Tx_byte+0x29e                              ";
         850 : dbg_instr = "I2C_Tx_byte+0x29f                              ";
         851 : dbg_instr = "I2C_Tx_byte+0x2a0                              ";
         852 : dbg_instr = "I2C_Tx_byte+0x2a1                              ";
         853 : dbg_instr = "I2C_Tx_byte+0x2a2                              ";
         854 : dbg_instr = "I2C_Tx_byte+0x2a3                              ";
         855 : dbg_instr = "I2C_Tx_byte+0x2a4                              ";
         856 : dbg_instr = "I2C_Tx_byte+0x2a5                              ";
         857 : dbg_instr = "I2C_Tx_byte+0x2a6                              ";
         858 : dbg_instr = "I2C_Tx_byte+0x2a7                              ";
         859 : dbg_instr = "I2C_Tx_byte+0x2a8                              ";
         860 : dbg_instr = "I2C_Tx_byte+0x2a9                              ";
         861 : dbg_instr = "I2C_Tx_byte+0x2aa                              ";
         862 : dbg_instr = "I2C_Tx_byte+0x2ab                              ";
         863 : dbg_instr = "I2C_Tx_byte+0x2ac                              ";
         864 : dbg_instr = "I2C_Tx_byte+0x2ad                              ";
         865 : dbg_instr = "I2C_Tx_byte+0x2ae                              ";
         866 : dbg_instr = "I2C_Tx_byte+0x2af                              ";
         867 : dbg_instr = "I2C_Tx_byte+0x2b0                              ";
         868 : dbg_instr = "I2C_Tx_byte+0x2b1                              ";
         869 : dbg_instr = "I2C_Tx_byte+0x2b2                              ";
         870 : dbg_instr = "I2C_Tx_byte+0x2b3                              ";
         871 : dbg_instr = "I2C_Tx_byte+0x2b4                              ";
         872 : dbg_instr = "I2C_Tx_byte+0x2b5                              ";
         873 : dbg_instr = "I2C_Tx_byte+0x2b6                              ";
         874 : dbg_instr = "I2C_Tx_byte+0x2b7                              ";
         875 : dbg_instr = "I2C_Tx_byte+0x2b8                              ";
         876 : dbg_instr = "I2C_Tx_byte+0x2b9                              ";
         877 : dbg_instr = "I2C_Tx_byte+0x2ba                              ";
         878 : dbg_instr = "I2C_Tx_byte+0x2bb                              ";
         879 : dbg_instr = "I2C_Tx_byte+0x2bc                              ";
         880 : dbg_instr = "I2C_Tx_byte+0x2bd                              ";
         881 : dbg_instr = "I2C_Tx_byte+0x2be                              ";
         882 : dbg_instr = "I2C_Tx_byte+0x2bf                              ";
         883 : dbg_instr = "I2C_Tx_byte+0x2c0                              ";
         884 : dbg_instr = "I2C_Tx_byte+0x2c1                              ";
         885 : dbg_instr = "I2C_Tx_byte+0x2c2                              ";
         886 : dbg_instr = "I2C_Tx_byte+0x2c3                              ";
         887 : dbg_instr = "I2C_Tx_byte+0x2c4                              ";
         888 : dbg_instr = "I2C_Tx_byte+0x2c5                              ";
         889 : dbg_instr = "I2C_Tx_byte+0x2c6                              ";
         890 : dbg_instr = "I2C_Tx_byte+0x2c7                              ";
         891 : dbg_instr = "I2C_Tx_byte+0x2c8                              ";
         892 : dbg_instr = "I2C_Tx_byte+0x2c9                              ";
         893 : dbg_instr = "I2C_Tx_byte+0x2ca                              ";
         894 : dbg_instr = "I2C_Tx_byte+0x2cb                              ";
         895 : dbg_instr = "I2C_Tx_byte+0x2cc                              ";
         896 : dbg_instr = "I2C_Tx_byte+0x2cd                              ";
         897 : dbg_instr = "I2C_Tx_byte+0x2ce                              ";
         898 : dbg_instr = "I2C_Tx_byte+0x2cf                              ";
         899 : dbg_instr = "I2C_Tx_byte+0x2d0                              ";
         900 : dbg_instr = "I2C_Tx_byte+0x2d1                              ";
         901 : dbg_instr = "I2C_Tx_byte+0x2d2                              ";
         902 : dbg_instr = "I2C_Tx_byte+0x2d3                              ";
         903 : dbg_instr = "I2C_Tx_byte+0x2d4                              ";
         904 : dbg_instr = "I2C_Tx_byte+0x2d5                              ";
         905 : dbg_instr = "I2C_Tx_byte+0x2d6                              ";
         906 : dbg_instr = "I2C_Tx_byte+0x2d7                              ";
         907 : dbg_instr = "I2C_Tx_byte+0x2d8                              ";
         908 : dbg_instr = "I2C_Tx_byte+0x2d9                              ";
         909 : dbg_instr = "I2C_Tx_byte+0x2da                              ";
         910 : dbg_instr = "I2C_Tx_byte+0x2db                              ";
         911 : dbg_instr = "I2C_Tx_byte+0x2dc                              ";
         912 : dbg_instr = "I2C_Tx_byte+0x2dd                              ";
         913 : dbg_instr = "I2C_Tx_byte+0x2de                              ";
         914 : dbg_instr = "I2C_Tx_byte+0x2df                              ";
         915 : dbg_instr = "I2C_Tx_byte+0x2e0                              ";
         916 : dbg_instr = "I2C_Tx_byte+0x2e1                              ";
         917 : dbg_instr = "I2C_Tx_byte+0x2e2                              ";
         918 : dbg_instr = "I2C_Tx_byte+0x2e3                              ";
         919 : dbg_instr = "I2C_Tx_byte+0x2e4                              ";
         920 : dbg_instr = "I2C_Tx_byte+0x2e5                              ";
         921 : dbg_instr = "I2C_Tx_byte+0x2e6                              ";
         922 : dbg_instr = "I2C_Tx_byte+0x2e7                              ";
         923 : dbg_instr = "I2C_Tx_byte+0x2e8                              ";
         924 : dbg_instr = "I2C_Tx_byte+0x2e9                              ";
         925 : dbg_instr = "I2C_Tx_byte+0x2ea                              ";
         926 : dbg_instr = "I2C_Tx_byte+0x2eb                              ";
         927 : dbg_instr = "I2C_Tx_byte+0x2ec                              ";
         928 : dbg_instr = "I2C_Tx_byte+0x2ed                              ";
         929 : dbg_instr = "I2C_Tx_byte+0x2ee                              ";
         930 : dbg_instr = "I2C_Tx_byte+0x2ef                              ";
         931 : dbg_instr = "I2C_Tx_byte+0x2f0                              ";
         932 : dbg_instr = "I2C_Tx_byte+0x2f1                              ";
         933 : dbg_instr = "I2C_Tx_byte+0x2f2                              ";
         934 : dbg_instr = "I2C_Tx_byte+0x2f3                              ";
         935 : dbg_instr = "I2C_Tx_byte+0x2f4                              ";
         936 : dbg_instr = "I2C_Tx_byte+0x2f5                              ";
         937 : dbg_instr = "I2C_Tx_byte+0x2f6                              ";
         938 : dbg_instr = "I2C_Tx_byte+0x2f7                              ";
         939 : dbg_instr = "I2C_Tx_byte+0x2f8                              ";
         940 : dbg_instr = "I2C_Tx_byte+0x2f9                              ";
         941 : dbg_instr = "I2C_Tx_byte+0x2fa                              ";
         942 : dbg_instr = "I2C_Tx_byte+0x2fb                              ";
         943 : dbg_instr = "I2C_Tx_byte+0x2fc                              ";
         944 : dbg_instr = "I2C_Tx_byte+0x2fd                              ";
         945 : dbg_instr = "I2C_Tx_byte+0x2fe                              ";
         946 : dbg_instr = "I2C_Tx_byte+0x2ff                              ";
         947 : dbg_instr = "I2C_Tx_byte+0x300                              ";
         948 : dbg_instr = "I2C_Tx_byte+0x301                              ";
         949 : dbg_instr = "I2C_Tx_byte+0x302                              ";
         950 : dbg_instr = "I2C_Tx_byte+0x303                              ";
         951 : dbg_instr = "I2C_Tx_byte+0x304                              ";
         952 : dbg_instr = "I2C_Tx_byte+0x305                              ";
         953 : dbg_instr = "I2C_Tx_byte+0x306                              ";
         954 : dbg_instr = "I2C_Tx_byte+0x307                              ";
         955 : dbg_instr = "I2C_Tx_byte+0x308                              ";
         956 : dbg_instr = "I2C_Tx_byte+0x309                              ";
         957 : dbg_instr = "I2C_Tx_byte+0x30a                              ";
         958 : dbg_instr = "I2C_Tx_byte+0x30b                              ";
         959 : dbg_instr = "I2C_Tx_byte+0x30c                              ";
         960 : dbg_instr = "I2C_Tx_byte+0x30d                              ";
         961 : dbg_instr = "I2C_Tx_byte+0x30e                              ";
         962 : dbg_instr = "I2C_Tx_byte+0x30f                              ";
         963 : dbg_instr = "I2C_Tx_byte+0x310                              ";
         964 : dbg_instr = "I2C_Tx_byte+0x311                              ";
         965 : dbg_instr = "I2C_Tx_byte+0x312                              ";
         966 : dbg_instr = "I2C_Tx_byte+0x313                              ";
         967 : dbg_instr = "I2C_Tx_byte+0x314                              ";
         968 : dbg_instr = "I2C_Tx_byte+0x315                              ";
         969 : dbg_instr = "I2C_Tx_byte+0x316                              ";
         970 : dbg_instr = "I2C_Tx_byte+0x317                              ";
         971 : dbg_instr = "I2C_Tx_byte+0x318                              ";
         972 : dbg_instr = "I2C_Tx_byte+0x319                              ";
         973 : dbg_instr = "I2C_Tx_byte+0x31a                              ";
         974 : dbg_instr = "I2C_Tx_byte+0x31b                              ";
         975 : dbg_instr = "I2C_Tx_byte+0x31c                              ";
         976 : dbg_instr = "I2C_Tx_byte+0x31d                              ";
         977 : dbg_instr = "I2C_Tx_byte+0x31e                              ";
         978 : dbg_instr = "I2C_Tx_byte+0x31f                              ";
         979 : dbg_instr = "I2C_Tx_byte+0x320                              ";
         980 : dbg_instr = "I2C_Tx_byte+0x321                              ";
         981 : dbg_instr = "I2C_Tx_byte+0x322                              ";
         982 : dbg_instr = "I2C_Tx_byte+0x323                              ";
         983 : dbg_instr = "I2C_Tx_byte+0x324                              ";
         984 : dbg_instr = "I2C_Tx_byte+0x325                              ";
         985 : dbg_instr = "I2C_Tx_byte+0x326                              ";
         986 : dbg_instr = "I2C_Tx_byte+0x327                              ";
         987 : dbg_instr = "I2C_Tx_byte+0x328                              ";
         988 : dbg_instr = "I2C_Tx_byte+0x329                              ";
         989 : dbg_instr = "I2C_Tx_byte+0x32a                              ";
         990 : dbg_instr = "I2C_Tx_byte+0x32b                              ";
         991 : dbg_instr = "I2C_Tx_byte+0x32c                              ";
         992 : dbg_instr = "I2C_Tx_byte+0x32d                              ";
         993 : dbg_instr = "I2C_Tx_byte+0x32e                              ";
         994 : dbg_instr = "I2C_Tx_byte+0x32f                              ";
         995 : dbg_instr = "I2C_Tx_byte+0x330                              ";
         996 : dbg_instr = "I2C_Tx_byte+0x331                              ";
         997 : dbg_instr = "I2C_Tx_byte+0x332                              ";
         998 : dbg_instr = "I2C_Tx_byte+0x333                              ";
         999 : dbg_instr = "I2C_Tx_byte+0x334                              ";
         1000 : dbg_instr = "I2C_Tx_byte+0x335                              ";
         1001 : dbg_instr = "I2C_Tx_byte+0x336                              ";
         1002 : dbg_instr = "I2C_Tx_byte+0x337                              ";
         1003 : dbg_instr = "I2C_Tx_byte+0x338                              ";
         1004 : dbg_instr = "I2C_Tx_byte+0x339                              ";
         1005 : dbg_instr = "I2C_Tx_byte+0x33a                              ";
         1006 : dbg_instr = "I2C_Tx_byte+0x33b                              ";
         1007 : dbg_instr = "I2C_Tx_byte+0x33c                              ";
         1008 : dbg_instr = "I2C_Tx_byte+0x33d                              ";
         1009 : dbg_instr = "I2C_Tx_byte+0x33e                              ";
         1010 : dbg_instr = "I2C_Tx_byte+0x33f                              ";
         1011 : dbg_instr = "I2C_Tx_byte+0x340                              ";
         1012 : dbg_instr = "I2C_Tx_byte+0x341                              ";
         1013 : dbg_instr = "I2C_Tx_byte+0x342                              ";
         1014 : dbg_instr = "I2C_Tx_byte+0x343                              ";
         1015 : dbg_instr = "I2C_Tx_byte+0x344                              ";
         1016 : dbg_instr = "I2C_Tx_byte+0x345                              ";
         1017 : dbg_instr = "I2C_Tx_byte+0x346                              ";
         1018 : dbg_instr = "I2C_Tx_byte+0x347                              ";
         1019 : dbg_instr = "I2C_Tx_byte+0x348                              ";
         1020 : dbg_instr = "I2C_Tx_byte+0x349                              ";
         1021 : dbg_instr = "I2C_Tx_byte+0x34a                              ";
         1022 : dbg_instr = "I2C_Tx_byte+0x34b                              ";
         1023 : dbg_instr = "I2C_Tx_byte+0x34c                              ";
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
    .INIT_00(256'hD0FF90011101EF008F100A001001114390422016DF019F40000000002004004C),
    .INIT_01(256'hFA00FB015000601B9F014F80001A0019001A2004D0419001601510020046600B),
    .INIT_02(256'h2031B02250000017B00150009AFF0AC0E0239C01A028005CAAC0500000461A02),
    .INIT_03(256'h40065000BA02500000230077FA025A01BA011C015000002B001800890017B002),
    .INIT_04(256'h008ED2201200193F50001A00008E002300770CA05000500160450046E1A01A00),
    .INIT_05(256'h5000DA01009400B35000D220120160511102C0205280420E0210003F10001100),
    .INIT_06(256'h5000008E1BFF1AFF206E00860BA0002E00A800300074A06C00AE606C0036FA00),
    .INIT_07(256'h190100825000002B0018B00200170089B02250009901EA909901EB909901EC90),
    .INIT_08(256'h0017B0025000208ADF019F00B0115000AA9019015000AB90190100865000AC90),
    .INIT_09(256'h0036FA005000002B00194A00DF029F00001900890017B0225000B02200180089),
    .INIT_0A(256'h005C00775000009420A9DA8000941A015000008E1AFF20A6002EA0A500AE60A5),
    .INIT_0B(256'h0000000000005000E0B44B0E0031B00220B9B02220B8CBA01B80500000A89000),
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
    .INITP_00(256'h6AAAA666A0A2ABBA8AA36120A09A88E863A80AAAAAA4DE28AB5AA9CB5604300A),
    .INITP_01(256'h0000000000000000000000000000000002DAAC2BAAC8A2BBAA90AAAAAB0A1868),

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
