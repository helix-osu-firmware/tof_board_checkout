/*
 * == pblaze-cc ==
 * source : i2c_checkout_rom.c
 * create : Thu Mar  5 15:31:26 2020
 * modify : Thu Mar  5 15:31:26 2020
 */
`timescale 1 ps / 1ps

/* 
 * == pblaze-as ==
 * source : i2c_checkout_rom.s
 * create : Thu Mar  5 17:27:13 2020
 * modify : Thu Mar  5 17:27:13 2020
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
         5 : dbg_instr = "I2C_delay_5us                                  ";
         6 : dbg_instr = "I2C_delay_4us                                  ";
         7 : dbg_instr = "I2C_delay_2us                                  ";
         8 : dbg_instr = "I2C_delay_1us                                  ";
         9 : dbg_instr = "I2C_delay_1us+0x001                            ";
         10 : dbg_instr = "I2C_delay_1us+0x002                            ";
         11 : dbg_instr = "I2C_delay_1us+0x003                            ";
         12 : dbg_instr = "I2C_reg_write                                  ";
         13 : dbg_instr = "I2C_reg_write+0x001                            ";
         14 : dbg_instr = "I2C_reg_write+0x002                            ";
         15 : dbg_instr = "I2C_reg_write+0x003                            ";
         16 : dbg_instr = "I2C_reg_write+0x004                            ";
         17 : dbg_instr = "I2C_write_bytes_process                        ";
         18 : dbg_instr = "I2C_write_bytes_process+0x001                  ";
         19 : dbg_instr = "I2C_write_bytes_process+0x002                  ";
         20 : dbg_instr = "I2C_write_bytes_process+0x003                  ";
         21 : dbg_instr = "I2C_write_bytes_process+0x004                  ";
         22 : dbg_instr = "I2C_write_bytes_process_failure                ";
         23 : dbg_instr = "I2C_write_bytes_process_failure+0x001          ";
         24 : dbg_instr = "I2C_write_bytes_process_failure+0x002          ";
         25 : dbg_instr = "I2C_clk_Low                                    ";
         26 : dbg_instr = "I2C_clk_Low+0x001                              ";
         27 : dbg_instr = "I2C_clk_Low+0x002                              ";
         28 : dbg_instr = "I2C_Tx_NACK                                    ";
         29 : dbg_instr = "I2C_Tx_NACK+0x001                              ";
         30 : dbg_instr = "I2C_Tx_ACK                                     ";
         31 : dbg_instr = "I2C_clk_pulse                                  ";
         32 : dbg_instr = "I2C_clk_pulse+0x001                            ";
         33 : dbg_instr = "I2C_clk_pulse+0x002                            ";
         34 : dbg_instr = "I2C_clk_pulse+0x003                            ";
         35 : dbg_instr = "I2C_clk_pulse+0x004                            ";
         36 : dbg_instr = "I2C_update_read_reg_turnaround                 ";
         37 : dbg_instr = "I2C_update_read_reg_turnaround+0x001           ";
         38 : dbg_instr = "I2C_update_read_reg_turnaround+0x002           ";
         39 : dbg_instr = "I2C_update_read_reg_turnaround+0x003           ";
         40 : dbg_instr = "I2C_update_read_reg_turnaround+0x004           ";
         41 : dbg_instr = "I2C_update_read_reg_turnaround+0x005           ";
         42 : dbg_instr = "I2C_update_read_reg_turnaround+0x006           ";
         43 : dbg_instr = "I2C_update_read_reg_turnaround+0x007           ";
         44 : dbg_instr = "I2C_update_read_reg_turnaround+0x008           ";
         45 : dbg_instr = "check_device                                   ";
         46 : dbg_instr = "check_device+0x001                             ";
         47 : dbg_instr = "check_device+0x002                             ";
         48 : dbg_instr = "check_device+0x003                             ";
         49 : dbg_instr = "check_device+0x004                             ";
         50 : dbg_instr = "check_device+0x005                             ";
         51 : dbg_instr = "check_device+0x006                             ";
         52 : dbg_instr = "I2C_write_bytes                                ";
         53 : dbg_instr = "I2C_write_bytes+0x001                          ";
         54 : dbg_instr = "I2C_write_bytes+0x002                          ";
         55 : dbg_instr = "I2C_write_bytes+0x003                          ";
         56 : dbg_instr = "I2C_write_bytes+0x004                          ";
         57 : dbg_instr = "I2C_write_bytes+0x005                          ";
         58 : dbg_instr = "init                                           ";
         59 : dbg_instr = "init+0x001                                     ";
         60 : dbg_instr = "init+0x002                                     ";
         61 : dbg_instr = "init+0x003                                     ";
         62 : dbg_instr = "init+0x004                                     ";
         63 : dbg_instr = "init+0x005                                     ";
         64 : dbg_instr = "init+0x006                                     ";
         65 : dbg_instr = "init+0x007                                     ";
         66 : dbg_instr = "init+0x008                                     ";
         67 : dbg_instr = "init+0x009                                     ";
         68 : dbg_instr = "init+0x00a                                     ";
         69 : dbg_instr = "init+0x00b                                     ";
         70 : dbg_instr = "init+0x00c                                     ";
         71 : dbg_instr = "init+0x00d                                     ";
         72 : dbg_instr = "init+0x00e                                     ";
         73 : dbg_instr = "init+0x00f                                     ";
         74 : dbg_instr = "I2C_Tx_byte_and_Rx_ACK                         ";
         75 : dbg_instr = "I2C_Rx_ACK                                     ";
         76 : dbg_instr = "I2C_Rx_ACK+0x001                               ";
         77 : dbg_instr = "I2C_Rx_ACK+0x002                               ";
         78 : dbg_instr = "I2C_reg_read16                                 ";
         79 : dbg_instr = "I2C_reg_read16+0x001                           ";
         80 : dbg_instr = "I2C_reg_read16+0x002                           ";
         81 : dbg_instr = "I2C_read_two_bytes                             ";
         82 : dbg_instr = "I2C_read_two_bytes+0x001                       ";
         83 : dbg_instr = "I2C_read_two_bytes+0x002                       ";
         84 : dbg_instr = "I2C_read_two_bytes+0x003                       ";
         85 : dbg_instr = "I2C_read_two_bytes+0x004                       ";
         86 : dbg_instr = "I2C_read_two_bytes+0x005                       ";
         87 : dbg_instr = "I2C_read_two_bytes+0x006                       ";
         88 : dbg_instr = "I2C_read_two_bytes+0x007                       ";
         89 : dbg_instr = "I2C_read_two_bytes+0x008                       ";
         90 : dbg_instr = "I2C_reg_read16_failure                         ";
         91 : dbg_instr = "I2C_reg_read16_failure+0x001                   ";
         92 : dbg_instr = "I2C_reg_read16_finish                          ";
         93 : dbg_instr = "I2C_reg_read16_finish+0x001                    ";
         94 : dbg_instr = "push3                                          ";
         95 : dbg_instr = "push3+0x001                                    ";
         96 : dbg_instr = "push2                                          ";
         97 : dbg_instr = "push2+0x001                                    ";
         98 : dbg_instr = "push1                                          ";
         99 : dbg_instr = "push1+0x001                                    ";
         100 : dbg_instr = "push1+0x002                                    ";
         101 : dbg_instr = "I2C_start                                      ";
         102 : dbg_instr = "I2C_start+0x001                                ";
         103 : dbg_instr = "I2C_start+0x002                                ";
         104 : dbg_instr = "I2C_start+0x003                                ";
         105 : dbg_instr = "I2C_start+0x004                                ";
         106 : dbg_instr = "I2C_start+0x005                                ";
         107 : dbg_instr = "I2C_start+0x006                                ";
         108 : dbg_instr = "pop3                                           ";
         109 : dbg_instr = "pop3+0x001                                     ";
         110 : dbg_instr = "pop3+0x002                                     ";
         111 : dbg_instr = "pop3+0x003                                     ";
         112 : dbg_instr = "pop2                                           ";
         113 : dbg_instr = "pop2+0x001                                     ";
         114 : dbg_instr = "pop2+0x002                                     ";
         115 : dbg_instr = "pop2+0x003                                     ";
         116 : dbg_instr = "pop1                                           ";
         117 : dbg_instr = "pop1+0x001                                     ";
         118 : dbg_instr = "pop1+0x002                                     ";
         119 : dbg_instr = "I2C_clk_Z                                      ";
         120 : dbg_instr = "I2C_clk_Z+0x001                                ";
         121 : dbg_instr = "I2C_clk_Z+0x002                                ";
         122 : dbg_instr = "I2C_clk_Z+0x003                                ";
         123 : dbg_instr = "I2C_clk_Z+0x004                                ";
         124 : dbg_instr = "I2C_stop                                       ";
         125 : dbg_instr = "I2C_stop+0x001                                 ";
         126 : dbg_instr = "I2C_stop+0x002                                 ";
         127 : dbg_instr = "I2C_stop+0x003                                 ";
         128 : dbg_instr = "I2C_stop+0x004                                 ";
         129 : dbg_instr = "I2C_stop+0x005                                 ";
         130 : dbg_instr = "I2C_Rx_bit                                     ";
         131 : dbg_instr = "I2C_Rx_bit+0x001                               ";
         132 : dbg_instr = "I2C_Rx_bit+0x002                               ";
         133 : dbg_instr = "I2C_Rx_bit+0x003                               ";
         134 : dbg_instr = "I2C_Rx_bit+0x004                               ";
         135 : dbg_instr = "I2C_Rx_bit+0x005                               ";
         136 : dbg_instr = "I2C_Rx_bit+0x006                               ";
         137 : dbg_instr = "I2C_Rx_bit+0x007                               ";
         138 : dbg_instr = "I2C_Rx_bit+0x008                               ";
         139 : dbg_instr = "I2C_Rx_bit+0x009                               ";
         140 : dbg_instr = "I2C_reg_read                                   ";
         141 : dbg_instr = "I2C_reg_read+0x001                             ";
         142 : dbg_instr = "I2C_reg_read+0x002                             ";
         143 : dbg_instr = "I2C_read_one_byte                              ";
         144 : dbg_instr = "I2C_read_one_byte+0x001                        ";
         145 : dbg_instr = "I2C_read_one_byte+0x002                        ";
         146 : dbg_instr = "I2C_read_one_byte+0x003                        ";
         147 : dbg_instr = "I2C_reg_read_failure                           ";
         148 : dbg_instr = "I2C_reg_read_finish                            ";
         149 : dbg_instr = "I2C_reg_read_finish+0x001                      ";
         150 : dbg_instr = "I2C_Rx_byte                                    ";
         151 : dbg_instr = "I2C_Rx_byte+0x001                              ";
         152 : dbg_instr = "I2C_Rx_byte+0x002                              ";
         153 : dbg_instr = "I2C_Rx_byte+0x003                              ";
         154 : dbg_instr = "I2C_Rx_byte+0x004                              ";
         155 : dbg_instr = "I2C_Rx_byte+0x005                              ";
         156 : dbg_instr = "I2C_read1_process                              ";
         157 : dbg_instr = "I2C_read1_process+0x001                        ";
         158 : dbg_instr = "I2C_read1_process+0x002                        ";
         159 : dbg_instr = "I2C_read1_process+0x003                        ";
         160 : dbg_instr = "I2C_read1_process+0x004                        ";
         161 : dbg_instr = "I2C_Tx_byte                                    ";
         162 : dbg_instr = "I2C_Tx_byte+0x001                              ";
         163 : dbg_instr = "I2C_Tx_byte+0x002                              ";
         164 : dbg_instr = "I2C_Tx_byte+0x003                              ";
         165 : dbg_instr = "I2C_Tx_byte+0x004                              ";
         166 : dbg_instr = "I2C_Tx_byte+0x005                              ";
         167 : dbg_instr = "I2C_Tx_byte+0x006                              ";
         168 : dbg_instr = "I2C_Tx_byte+0x007                              ";
         169 : dbg_instr = "I2C_Tx_byte+0x008                              ";
         170 : dbg_instr = "I2C_Tx_byte+0x009                              ";
         171 : dbg_instr = "I2C_Tx_byte+0x00a                              ";
         172 : dbg_instr = "I2C_Tx_byte+0x00b                              ";
         173 : dbg_instr = "I2C_Tx_byte+0x00c                              ";
         174 : dbg_instr = "I2C_Tx_byte+0x00d                              ";
         175 : dbg_instr = "I2C_Tx_byte+0x00e                              ";
         176 : dbg_instr = "I2C_Tx_byte+0x00f                              ";
         177 : dbg_instr = "I2C_Tx_byte+0x010                              ";
         178 : dbg_instr = "I2C_Tx_byte+0x011                              ";
         179 : dbg_instr = "I2C_Tx_byte+0x012                              ";
         180 : dbg_instr = "I2C_Tx_byte+0x013                              ";
         181 : dbg_instr = "I2C_Tx_byte+0x014                              ";
         182 : dbg_instr = "I2C_Tx_byte+0x015                              ";
         183 : dbg_instr = "I2C_Tx_byte+0x016                              ";
         184 : dbg_instr = "I2C_Tx_byte+0x017                              ";
         185 : dbg_instr = "I2C_Tx_byte+0x018                              ";
         186 : dbg_instr = "I2C_Tx_byte+0x019                              ";
         187 : dbg_instr = "I2C_Tx_byte+0x01a                              ";
         188 : dbg_instr = "I2C_Tx_byte+0x01b                              ";
         189 : dbg_instr = "I2C_Tx_byte+0x01c                              ";
         190 : dbg_instr = "I2C_Tx_byte+0x01d                              ";
         191 : dbg_instr = "I2C_Tx_byte+0x01e                              ";
         192 : dbg_instr = "I2C_Tx_byte+0x01f                              ";
         193 : dbg_instr = "I2C_Tx_byte+0x020                              ";
         194 : dbg_instr = "I2C_Tx_byte+0x021                              ";
         195 : dbg_instr = "I2C_Tx_byte+0x022                              ";
         196 : dbg_instr = "I2C_Tx_byte+0x023                              ";
         197 : dbg_instr = "I2C_Tx_byte+0x024                              ";
         198 : dbg_instr = "I2C_Tx_byte+0x025                              ";
         199 : dbg_instr = "I2C_Tx_byte+0x026                              ";
         200 : dbg_instr = "I2C_Tx_byte+0x027                              ";
         201 : dbg_instr = "I2C_Tx_byte+0x028                              ";
         202 : dbg_instr = "I2C_Tx_byte+0x029                              ";
         203 : dbg_instr = "I2C_Tx_byte+0x02a                              ";
         204 : dbg_instr = "I2C_Tx_byte+0x02b                              ";
         205 : dbg_instr = "I2C_Tx_byte+0x02c                              ";
         206 : dbg_instr = "I2C_Tx_byte+0x02d                              ";
         207 : dbg_instr = "I2C_Tx_byte+0x02e                              ";
         208 : dbg_instr = "I2C_Tx_byte+0x02f                              ";
         209 : dbg_instr = "I2C_Tx_byte+0x030                              ";
         210 : dbg_instr = "I2C_Tx_byte+0x031                              ";
         211 : dbg_instr = "I2C_Tx_byte+0x032                              ";
         212 : dbg_instr = "I2C_Tx_byte+0x033                              ";
         213 : dbg_instr = "I2C_Tx_byte+0x034                              ";
         214 : dbg_instr = "I2C_Tx_byte+0x035                              ";
         215 : dbg_instr = "I2C_Tx_byte+0x036                              ";
         216 : dbg_instr = "I2C_Tx_byte+0x037                              ";
         217 : dbg_instr = "I2C_Tx_byte+0x038                              ";
         218 : dbg_instr = "I2C_Tx_byte+0x039                              ";
         219 : dbg_instr = "I2C_Tx_byte+0x03a                              ";
         220 : dbg_instr = "I2C_Tx_byte+0x03b                              ";
         221 : dbg_instr = "I2C_Tx_byte+0x03c                              ";
         222 : dbg_instr = "I2C_Tx_byte+0x03d                              ";
         223 : dbg_instr = "I2C_Tx_byte+0x03e                              ";
         224 : dbg_instr = "I2C_Tx_byte+0x03f                              ";
         225 : dbg_instr = "I2C_Tx_byte+0x040                              ";
         226 : dbg_instr = "I2C_Tx_byte+0x041                              ";
         227 : dbg_instr = "I2C_Tx_byte+0x042                              ";
         228 : dbg_instr = "I2C_Tx_byte+0x043                              ";
         229 : dbg_instr = "I2C_Tx_byte+0x044                              ";
         230 : dbg_instr = "I2C_Tx_byte+0x045                              ";
         231 : dbg_instr = "I2C_Tx_byte+0x046                              ";
         232 : dbg_instr = "I2C_Tx_byte+0x047                              ";
         233 : dbg_instr = "I2C_Tx_byte+0x048                              ";
         234 : dbg_instr = "I2C_Tx_byte+0x049                              ";
         235 : dbg_instr = "I2C_Tx_byte+0x04a                              ";
         236 : dbg_instr = "I2C_Tx_byte+0x04b                              ";
         237 : dbg_instr = "I2C_Tx_byte+0x04c                              ";
         238 : dbg_instr = "I2C_Tx_byte+0x04d                              ";
         239 : dbg_instr = "I2C_Tx_byte+0x04e                              ";
         240 : dbg_instr = "I2C_Tx_byte+0x04f                              ";
         241 : dbg_instr = "I2C_Tx_byte+0x050                              ";
         242 : dbg_instr = "I2C_Tx_byte+0x051                              ";
         243 : dbg_instr = "I2C_Tx_byte+0x052                              ";
         244 : dbg_instr = "I2C_Tx_byte+0x053                              ";
         245 : dbg_instr = "I2C_Tx_byte+0x054                              ";
         246 : dbg_instr = "I2C_Tx_byte+0x055                              ";
         247 : dbg_instr = "I2C_Tx_byte+0x056                              ";
         248 : dbg_instr = "I2C_Tx_byte+0x057                              ";
         249 : dbg_instr = "I2C_Tx_byte+0x058                              ";
         250 : dbg_instr = "I2C_Tx_byte+0x059                              ";
         251 : dbg_instr = "I2C_Tx_byte+0x05a                              ";
         252 : dbg_instr = "I2C_Tx_byte+0x05b                              ";
         253 : dbg_instr = "I2C_Tx_byte+0x05c                              ";
         254 : dbg_instr = "I2C_Tx_byte+0x05d                              ";
         255 : dbg_instr = "I2C_Tx_byte+0x05e                              ";
         256 : dbg_instr = "I2C_Tx_byte+0x05f                              ";
         257 : dbg_instr = "I2C_Tx_byte+0x060                              ";
         258 : dbg_instr = "I2C_Tx_byte+0x061                              ";
         259 : dbg_instr = "I2C_Tx_byte+0x062                              ";
         260 : dbg_instr = "I2C_Tx_byte+0x063                              ";
         261 : dbg_instr = "I2C_Tx_byte+0x064                              ";
         262 : dbg_instr = "I2C_Tx_byte+0x065                              ";
         263 : dbg_instr = "I2C_Tx_byte+0x066                              ";
         264 : dbg_instr = "I2C_Tx_byte+0x067                              ";
         265 : dbg_instr = "I2C_Tx_byte+0x068                              ";
         266 : dbg_instr = "I2C_Tx_byte+0x069                              ";
         267 : dbg_instr = "I2C_Tx_byte+0x06a                              ";
         268 : dbg_instr = "I2C_Tx_byte+0x06b                              ";
         269 : dbg_instr = "I2C_Tx_byte+0x06c                              ";
         270 : dbg_instr = "I2C_Tx_byte+0x06d                              ";
         271 : dbg_instr = "I2C_Tx_byte+0x06e                              ";
         272 : dbg_instr = "I2C_Tx_byte+0x06f                              ";
         273 : dbg_instr = "I2C_Tx_byte+0x070                              ";
         274 : dbg_instr = "I2C_Tx_byte+0x071                              ";
         275 : dbg_instr = "I2C_Tx_byte+0x072                              ";
         276 : dbg_instr = "I2C_Tx_byte+0x073                              ";
         277 : dbg_instr = "I2C_Tx_byte+0x074                              ";
         278 : dbg_instr = "I2C_Tx_byte+0x075                              ";
         279 : dbg_instr = "I2C_Tx_byte+0x076                              ";
         280 : dbg_instr = "I2C_Tx_byte+0x077                              ";
         281 : dbg_instr = "I2C_Tx_byte+0x078                              ";
         282 : dbg_instr = "I2C_Tx_byte+0x079                              ";
         283 : dbg_instr = "I2C_Tx_byte+0x07a                              ";
         284 : dbg_instr = "I2C_Tx_byte+0x07b                              ";
         285 : dbg_instr = "I2C_Tx_byte+0x07c                              ";
         286 : dbg_instr = "I2C_Tx_byte+0x07d                              ";
         287 : dbg_instr = "I2C_Tx_byte+0x07e                              ";
         288 : dbg_instr = "I2C_Tx_byte+0x07f                              ";
         289 : dbg_instr = "I2C_Tx_byte+0x080                              ";
         290 : dbg_instr = "I2C_Tx_byte+0x081                              ";
         291 : dbg_instr = "I2C_Tx_byte+0x082                              ";
         292 : dbg_instr = "I2C_Tx_byte+0x083                              ";
         293 : dbg_instr = "I2C_Tx_byte+0x084                              ";
         294 : dbg_instr = "I2C_Tx_byte+0x085                              ";
         295 : dbg_instr = "I2C_Tx_byte+0x086                              ";
         296 : dbg_instr = "I2C_Tx_byte+0x087                              ";
         297 : dbg_instr = "I2C_Tx_byte+0x088                              ";
         298 : dbg_instr = "I2C_Tx_byte+0x089                              ";
         299 : dbg_instr = "I2C_Tx_byte+0x08a                              ";
         300 : dbg_instr = "I2C_Tx_byte+0x08b                              ";
         301 : dbg_instr = "I2C_Tx_byte+0x08c                              ";
         302 : dbg_instr = "I2C_Tx_byte+0x08d                              ";
         303 : dbg_instr = "I2C_Tx_byte+0x08e                              ";
         304 : dbg_instr = "I2C_Tx_byte+0x08f                              ";
         305 : dbg_instr = "I2C_Tx_byte+0x090                              ";
         306 : dbg_instr = "I2C_Tx_byte+0x091                              ";
         307 : dbg_instr = "I2C_Tx_byte+0x092                              ";
         308 : dbg_instr = "I2C_Tx_byte+0x093                              ";
         309 : dbg_instr = "I2C_Tx_byte+0x094                              ";
         310 : dbg_instr = "I2C_Tx_byte+0x095                              ";
         311 : dbg_instr = "I2C_Tx_byte+0x096                              ";
         312 : dbg_instr = "I2C_Tx_byte+0x097                              ";
         313 : dbg_instr = "I2C_Tx_byte+0x098                              ";
         314 : dbg_instr = "I2C_Tx_byte+0x099                              ";
         315 : dbg_instr = "I2C_Tx_byte+0x09a                              ";
         316 : dbg_instr = "I2C_Tx_byte+0x09b                              ";
         317 : dbg_instr = "I2C_Tx_byte+0x09c                              ";
         318 : dbg_instr = "I2C_Tx_byte+0x09d                              ";
         319 : dbg_instr = "I2C_Tx_byte+0x09e                              ";
         320 : dbg_instr = "I2C_Tx_byte+0x09f                              ";
         321 : dbg_instr = "I2C_Tx_byte+0x0a0                              ";
         322 : dbg_instr = "I2C_Tx_byte+0x0a1                              ";
         323 : dbg_instr = "I2C_Tx_byte+0x0a2                              ";
         324 : dbg_instr = "I2C_Tx_byte+0x0a3                              ";
         325 : dbg_instr = "I2C_Tx_byte+0x0a4                              ";
         326 : dbg_instr = "I2C_Tx_byte+0x0a5                              ";
         327 : dbg_instr = "I2C_Tx_byte+0x0a6                              ";
         328 : dbg_instr = "I2C_Tx_byte+0x0a7                              ";
         329 : dbg_instr = "I2C_Tx_byte+0x0a8                              ";
         330 : dbg_instr = "I2C_Tx_byte+0x0a9                              ";
         331 : dbg_instr = "I2C_Tx_byte+0x0aa                              ";
         332 : dbg_instr = "I2C_Tx_byte+0x0ab                              ";
         333 : dbg_instr = "I2C_Tx_byte+0x0ac                              ";
         334 : dbg_instr = "I2C_Tx_byte+0x0ad                              ";
         335 : dbg_instr = "I2C_Tx_byte+0x0ae                              ";
         336 : dbg_instr = "I2C_Tx_byte+0x0af                              ";
         337 : dbg_instr = "I2C_Tx_byte+0x0b0                              ";
         338 : dbg_instr = "I2C_Tx_byte+0x0b1                              ";
         339 : dbg_instr = "I2C_Tx_byte+0x0b2                              ";
         340 : dbg_instr = "I2C_Tx_byte+0x0b3                              ";
         341 : dbg_instr = "I2C_Tx_byte+0x0b4                              ";
         342 : dbg_instr = "I2C_Tx_byte+0x0b5                              ";
         343 : dbg_instr = "I2C_Tx_byte+0x0b6                              ";
         344 : dbg_instr = "I2C_Tx_byte+0x0b7                              ";
         345 : dbg_instr = "I2C_Tx_byte+0x0b8                              ";
         346 : dbg_instr = "I2C_Tx_byte+0x0b9                              ";
         347 : dbg_instr = "I2C_Tx_byte+0x0ba                              ";
         348 : dbg_instr = "I2C_Tx_byte+0x0bb                              ";
         349 : dbg_instr = "I2C_Tx_byte+0x0bc                              ";
         350 : dbg_instr = "I2C_Tx_byte+0x0bd                              ";
         351 : dbg_instr = "I2C_Tx_byte+0x0be                              ";
         352 : dbg_instr = "I2C_Tx_byte+0x0bf                              ";
         353 : dbg_instr = "I2C_Tx_byte+0x0c0                              ";
         354 : dbg_instr = "I2C_Tx_byte+0x0c1                              ";
         355 : dbg_instr = "I2C_Tx_byte+0x0c2                              ";
         356 : dbg_instr = "I2C_Tx_byte+0x0c3                              ";
         357 : dbg_instr = "I2C_Tx_byte+0x0c4                              ";
         358 : dbg_instr = "I2C_Tx_byte+0x0c5                              ";
         359 : dbg_instr = "I2C_Tx_byte+0x0c6                              ";
         360 : dbg_instr = "I2C_Tx_byte+0x0c7                              ";
         361 : dbg_instr = "I2C_Tx_byte+0x0c8                              ";
         362 : dbg_instr = "I2C_Tx_byte+0x0c9                              ";
         363 : dbg_instr = "I2C_Tx_byte+0x0ca                              ";
         364 : dbg_instr = "I2C_Tx_byte+0x0cb                              ";
         365 : dbg_instr = "I2C_Tx_byte+0x0cc                              ";
         366 : dbg_instr = "I2C_Tx_byte+0x0cd                              ";
         367 : dbg_instr = "I2C_Tx_byte+0x0ce                              ";
         368 : dbg_instr = "I2C_Tx_byte+0x0cf                              ";
         369 : dbg_instr = "I2C_Tx_byte+0x0d0                              ";
         370 : dbg_instr = "I2C_Tx_byte+0x0d1                              ";
         371 : dbg_instr = "I2C_Tx_byte+0x0d2                              ";
         372 : dbg_instr = "I2C_Tx_byte+0x0d3                              ";
         373 : dbg_instr = "I2C_Tx_byte+0x0d4                              ";
         374 : dbg_instr = "I2C_Tx_byte+0x0d5                              ";
         375 : dbg_instr = "I2C_Tx_byte+0x0d6                              ";
         376 : dbg_instr = "I2C_Tx_byte+0x0d7                              ";
         377 : dbg_instr = "I2C_Tx_byte+0x0d8                              ";
         378 : dbg_instr = "I2C_Tx_byte+0x0d9                              ";
         379 : dbg_instr = "I2C_Tx_byte+0x0da                              ";
         380 : dbg_instr = "I2C_Tx_byte+0x0db                              ";
         381 : dbg_instr = "I2C_Tx_byte+0x0dc                              ";
         382 : dbg_instr = "I2C_Tx_byte+0x0dd                              ";
         383 : dbg_instr = "I2C_Tx_byte+0x0de                              ";
         384 : dbg_instr = "I2C_Tx_byte+0x0df                              ";
         385 : dbg_instr = "I2C_Tx_byte+0x0e0                              ";
         386 : dbg_instr = "I2C_Tx_byte+0x0e1                              ";
         387 : dbg_instr = "I2C_Tx_byte+0x0e2                              ";
         388 : dbg_instr = "I2C_Tx_byte+0x0e3                              ";
         389 : dbg_instr = "I2C_Tx_byte+0x0e4                              ";
         390 : dbg_instr = "I2C_Tx_byte+0x0e5                              ";
         391 : dbg_instr = "I2C_Tx_byte+0x0e6                              ";
         392 : dbg_instr = "I2C_Tx_byte+0x0e7                              ";
         393 : dbg_instr = "I2C_Tx_byte+0x0e8                              ";
         394 : dbg_instr = "I2C_Tx_byte+0x0e9                              ";
         395 : dbg_instr = "I2C_Tx_byte+0x0ea                              ";
         396 : dbg_instr = "I2C_Tx_byte+0x0eb                              ";
         397 : dbg_instr = "I2C_Tx_byte+0x0ec                              ";
         398 : dbg_instr = "I2C_Tx_byte+0x0ed                              ";
         399 : dbg_instr = "I2C_Tx_byte+0x0ee                              ";
         400 : dbg_instr = "I2C_Tx_byte+0x0ef                              ";
         401 : dbg_instr = "I2C_Tx_byte+0x0f0                              ";
         402 : dbg_instr = "I2C_Tx_byte+0x0f1                              ";
         403 : dbg_instr = "I2C_Tx_byte+0x0f2                              ";
         404 : dbg_instr = "I2C_Tx_byte+0x0f3                              ";
         405 : dbg_instr = "I2C_Tx_byte+0x0f4                              ";
         406 : dbg_instr = "I2C_Tx_byte+0x0f5                              ";
         407 : dbg_instr = "I2C_Tx_byte+0x0f6                              ";
         408 : dbg_instr = "I2C_Tx_byte+0x0f7                              ";
         409 : dbg_instr = "I2C_Tx_byte+0x0f8                              ";
         410 : dbg_instr = "I2C_Tx_byte+0x0f9                              ";
         411 : dbg_instr = "I2C_Tx_byte+0x0fa                              ";
         412 : dbg_instr = "I2C_Tx_byte+0x0fb                              ";
         413 : dbg_instr = "I2C_Tx_byte+0x0fc                              ";
         414 : dbg_instr = "I2C_Tx_byte+0x0fd                              ";
         415 : dbg_instr = "I2C_Tx_byte+0x0fe                              ";
         416 : dbg_instr = "I2C_Tx_byte+0x0ff                              ";
         417 : dbg_instr = "I2C_Tx_byte+0x100                              ";
         418 : dbg_instr = "I2C_Tx_byte+0x101                              ";
         419 : dbg_instr = "I2C_Tx_byte+0x102                              ";
         420 : dbg_instr = "I2C_Tx_byte+0x103                              ";
         421 : dbg_instr = "I2C_Tx_byte+0x104                              ";
         422 : dbg_instr = "I2C_Tx_byte+0x105                              ";
         423 : dbg_instr = "I2C_Tx_byte+0x106                              ";
         424 : dbg_instr = "I2C_Tx_byte+0x107                              ";
         425 : dbg_instr = "I2C_Tx_byte+0x108                              ";
         426 : dbg_instr = "I2C_Tx_byte+0x109                              ";
         427 : dbg_instr = "I2C_Tx_byte+0x10a                              ";
         428 : dbg_instr = "I2C_Tx_byte+0x10b                              ";
         429 : dbg_instr = "I2C_Tx_byte+0x10c                              ";
         430 : dbg_instr = "I2C_Tx_byte+0x10d                              ";
         431 : dbg_instr = "I2C_Tx_byte+0x10e                              ";
         432 : dbg_instr = "I2C_Tx_byte+0x10f                              ";
         433 : dbg_instr = "I2C_Tx_byte+0x110                              ";
         434 : dbg_instr = "I2C_Tx_byte+0x111                              ";
         435 : dbg_instr = "I2C_Tx_byte+0x112                              ";
         436 : dbg_instr = "I2C_Tx_byte+0x113                              ";
         437 : dbg_instr = "I2C_Tx_byte+0x114                              ";
         438 : dbg_instr = "I2C_Tx_byte+0x115                              ";
         439 : dbg_instr = "I2C_Tx_byte+0x116                              ";
         440 : dbg_instr = "I2C_Tx_byte+0x117                              ";
         441 : dbg_instr = "I2C_Tx_byte+0x118                              ";
         442 : dbg_instr = "I2C_Tx_byte+0x119                              ";
         443 : dbg_instr = "I2C_Tx_byte+0x11a                              ";
         444 : dbg_instr = "I2C_Tx_byte+0x11b                              ";
         445 : dbg_instr = "I2C_Tx_byte+0x11c                              ";
         446 : dbg_instr = "I2C_Tx_byte+0x11d                              ";
         447 : dbg_instr = "I2C_Tx_byte+0x11e                              ";
         448 : dbg_instr = "I2C_Tx_byte+0x11f                              ";
         449 : dbg_instr = "I2C_Tx_byte+0x120                              ";
         450 : dbg_instr = "I2C_Tx_byte+0x121                              ";
         451 : dbg_instr = "I2C_Tx_byte+0x122                              ";
         452 : dbg_instr = "I2C_Tx_byte+0x123                              ";
         453 : dbg_instr = "I2C_Tx_byte+0x124                              ";
         454 : dbg_instr = "I2C_Tx_byte+0x125                              ";
         455 : dbg_instr = "I2C_Tx_byte+0x126                              ";
         456 : dbg_instr = "I2C_Tx_byte+0x127                              ";
         457 : dbg_instr = "I2C_Tx_byte+0x128                              ";
         458 : dbg_instr = "I2C_Tx_byte+0x129                              ";
         459 : dbg_instr = "I2C_Tx_byte+0x12a                              ";
         460 : dbg_instr = "I2C_Tx_byte+0x12b                              ";
         461 : dbg_instr = "I2C_Tx_byte+0x12c                              ";
         462 : dbg_instr = "I2C_Tx_byte+0x12d                              ";
         463 : dbg_instr = "I2C_Tx_byte+0x12e                              ";
         464 : dbg_instr = "I2C_Tx_byte+0x12f                              ";
         465 : dbg_instr = "I2C_Tx_byte+0x130                              ";
         466 : dbg_instr = "I2C_Tx_byte+0x131                              ";
         467 : dbg_instr = "I2C_Tx_byte+0x132                              ";
         468 : dbg_instr = "I2C_Tx_byte+0x133                              ";
         469 : dbg_instr = "I2C_Tx_byte+0x134                              ";
         470 : dbg_instr = "I2C_Tx_byte+0x135                              ";
         471 : dbg_instr = "I2C_Tx_byte+0x136                              ";
         472 : dbg_instr = "I2C_Tx_byte+0x137                              ";
         473 : dbg_instr = "I2C_Tx_byte+0x138                              ";
         474 : dbg_instr = "I2C_Tx_byte+0x139                              ";
         475 : dbg_instr = "I2C_Tx_byte+0x13a                              ";
         476 : dbg_instr = "I2C_Tx_byte+0x13b                              ";
         477 : dbg_instr = "I2C_Tx_byte+0x13c                              ";
         478 : dbg_instr = "I2C_Tx_byte+0x13d                              ";
         479 : dbg_instr = "I2C_Tx_byte+0x13e                              ";
         480 : dbg_instr = "I2C_Tx_byte+0x13f                              ";
         481 : dbg_instr = "I2C_Tx_byte+0x140                              ";
         482 : dbg_instr = "I2C_Tx_byte+0x141                              ";
         483 : dbg_instr = "I2C_Tx_byte+0x142                              ";
         484 : dbg_instr = "I2C_Tx_byte+0x143                              ";
         485 : dbg_instr = "I2C_Tx_byte+0x144                              ";
         486 : dbg_instr = "I2C_Tx_byte+0x145                              ";
         487 : dbg_instr = "I2C_Tx_byte+0x146                              ";
         488 : dbg_instr = "I2C_Tx_byte+0x147                              ";
         489 : dbg_instr = "I2C_Tx_byte+0x148                              ";
         490 : dbg_instr = "I2C_Tx_byte+0x149                              ";
         491 : dbg_instr = "I2C_Tx_byte+0x14a                              ";
         492 : dbg_instr = "I2C_Tx_byte+0x14b                              ";
         493 : dbg_instr = "I2C_Tx_byte+0x14c                              ";
         494 : dbg_instr = "I2C_Tx_byte+0x14d                              ";
         495 : dbg_instr = "I2C_Tx_byte+0x14e                              ";
         496 : dbg_instr = "I2C_Tx_byte+0x14f                              ";
         497 : dbg_instr = "I2C_Tx_byte+0x150                              ";
         498 : dbg_instr = "I2C_Tx_byte+0x151                              ";
         499 : dbg_instr = "I2C_Tx_byte+0x152                              ";
         500 : dbg_instr = "I2C_Tx_byte+0x153                              ";
         501 : dbg_instr = "I2C_Tx_byte+0x154                              ";
         502 : dbg_instr = "I2C_Tx_byte+0x155                              ";
         503 : dbg_instr = "I2C_Tx_byte+0x156                              ";
         504 : dbg_instr = "I2C_Tx_byte+0x157                              ";
         505 : dbg_instr = "I2C_Tx_byte+0x158                              ";
         506 : dbg_instr = "I2C_Tx_byte+0x159                              ";
         507 : dbg_instr = "I2C_Tx_byte+0x15a                              ";
         508 : dbg_instr = "I2C_Tx_byte+0x15b                              ";
         509 : dbg_instr = "I2C_Tx_byte+0x15c                              ";
         510 : dbg_instr = "I2C_Tx_byte+0x15d                              ";
         511 : dbg_instr = "I2C_Tx_byte+0x15e                              ";
         512 : dbg_instr = "I2C_Tx_byte+0x15f                              ";
         513 : dbg_instr = "I2C_Tx_byte+0x160                              ";
         514 : dbg_instr = "I2C_Tx_byte+0x161                              ";
         515 : dbg_instr = "I2C_Tx_byte+0x162                              ";
         516 : dbg_instr = "I2C_Tx_byte+0x163                              ";
         517 : dbg_instr = "I2C_Tx_byte+0x164                              ";
         518 : dbg_instr = "I2C_Tx_byte+0x165                              ";
         519 : dbg_instr = "I2C_Tx_byte+0x166                              ";
         520 : dbg_instr = "I2C_Tx_byte+0x167                              ";
         521 : dbg_instr = "I2C_Tx_byte+0x168                              ";
         522 : dbg_instr = "I2C_Tx_byte+0x169                              ";
         523 : dbg_instr = "I2C_Tx_byte+0x16a                              ";
         524 : dbg_instr = "I2C_Tx_byte+0x16b                              ";
         525 : dbg_instr = "I2C_Tx_byte+0x16c                              ";
         526 : dbg_instr = "I2C_Tx_byte+0x16d                              ";
         527 : dbg_instr = "I2C_Tx_byte+0x16e                              ";
         528 : dbg_instr = "I2C_Tx_byte+0x16f                              ";
         529 : dbg_instr = "I2C_Tx_byte+0x170                              ";
         530 : dbg_instr = "I2C_Tx_byte+0x171                              ";
         531 : dbg_instr = "I2C_Tx_byte+0x172                              ";
         532 : dbg_instr = "I2C_Tx_byte+0x173                              ";
         533 : dbg_instr = "I2C_Tx_byte+0x174                              ";
         534 : dbg_instr = "I2C_Tx_byte+0x175                              ";
         535 : dbg_instr = "I2C_Tx_byte+0x176                              ";
         536 : dbg_instr = "I2C_Tx_byte+0x177                              ";
         537 : dbg_instr = "I2C_Tx_byte+0x178                              ";
         538 : dbg_instr = "I2C_Tx_byte+0x179                              ";
         539 : dbg_instr = "I2C_Tx_byte+0x17a                              ";
         540 : dbg_instr = "I2C_Tx_byte+0x17b                              ";
         541 : dbg_instr = "I2C_Tx_byte+0x17c                              ";
         542 : dbg_instr = "I2C_Tx_byte+0x17d                              ";
         543 : dbg_instr = "I2C_Tx_byte+0x17e                              ";
         544 : dbg_instr = "I2C_Tx_byte+0x17f                              ";
         545 : dbg_instr = "I2C_Tx_byte+0x180                              ";
         546 : dbg_instr = "I2C_Tx_byte+0x181                              ";
         547 : dbg_instr = "I2C_Tx_byte+0x182                              ";
         548 : dbg_instr = "I2C_Tx_byte+0x183                              ";
         549 : dbg_instr = "I2C_Tx_byte+0x184                              ";
         550 : dbg_instr = "I2C_Tx_byte+0x185                              ";
         551 : dbg_instr = "I2C_Tx_byte+0x186                              ";
         552 : dbg_instr = "I2C_Tx_byte+0x187                              ";
         553 : dbg_instr = "I2C_Tx_byte+0x188                              ";
         554 : dbg_instr = "I2C_Tx_byte+0x189                              ";
         555 : dbg_instr = "I2C_Tx_byte+0x18a                              ";
         556 : dbg_instr = "I2C_Tx_byte+0x18b                              ";
         557 : dbg_instr = "I2C_Tx_byte+0x18c                              ";
         558 : dbg_instr = "I2C_Tx_byte+0x18d                              ";
         559 : dbg_instr = "I2C_Tx_byte+0x18e                              ";
         560 : dbg_instr = "I2C_Tx_byte+0x18f                              ";
         561 : dbg_instr = "I2C_Tx_byte+0x190                              ";
         562 : dbg_instr = "I2C_Tx_byte+0x191                              ";
         563 : dbg_instr = "I2C_Tx_byte+0x192                              ";
         564 : dbg_instr = "I2C_Tx_byte+0x193                              ";
         565 : dbg_instr = "I2C_Tx_byte+0x194                              ";
         566 : dbg_instr = "I2C_Tx_byte+0x195                              ";
         567 : dbg_instr = "I2C_Tx_byte+0x196                              ";
         568 : dbg_instr = "I2C_Tx_byte+0x197                              ";
         569 : dbg_instr = "I2C_Tx_byte+0x198                              ";
         570 : dbg_instr = "I2C_Tx_byte+0x199                              ";
         571 : dbg_instr = "I2C_Tx_byte+0x19a                              ";
         572 : dbg_instr = "I2C_Tx_byte+0x19b                              ";
         573 : dbg_instr = "I2C_Tx_byte+0x19c                              ";
         574 : dbg_instr = "I2C_Tx_byte+0x19d                              ";
         575 : dbg_instr = "I2C_Tx_byte+0x19e                              ";
         576 : dbg_instr = "I2C_Tx_byte+0x19f                              ";
         577 : dbg_instr = "I2C_Tx_byte+0x1a0                              ";
         578 : dbg_instr = "I2C_Tx_byte+0x1a1                              ";
         579 : dbg_instr = "I2C_Tx_byte+0x1a2                              ";
         580 : dbg_instr = "I2C_Tx_byte+0x1a3                              ";
         581 : dbg_instr = "I2C_Tx_byte+0x1a4                              ";
         582 : dbg_instr = "I2C_Tx_byte+0x1a5                              ";
         583 : dbg_instr = "I2C_Tx_byte+0x1a6                              ";
         584 : dbg_instr = "I2C_Tx_byte+0x1a7                              ";
         585 : dbg_instr = "I2C_Tx_byte+0x1a8                              ";
         586 : dbg_instr = "I2C_Tx_byte+0x1a9                              ";
         587 : dbg_instr = "I2C_Tx_byte+0x1aa                              ";
         588 : dbg_instr = "I2C_Tx_byte+0x1ab                              ";
         589 : dbg_instr = "I2C_Tx_byte+0x1ac                              ";
         590 : dbg_instr = "I2C_Tx_byte+0x1ad                              ";
         591 : dbg_instr = "I2C_Tx_byte+0x1ae                              ";
         592 : dbg_instr = "I2C_Tx_byte+0x1af                              ";
         593 : dbg_instr = "I2C_Tx_byte+0x1b0                              ";
         594 : dbg_instr = "I2C_Tx_byte+0x1b1                              ";
         595 : dbg_instr = "I2C_Tx_byte+0x1b2                              ";
         596 : dbg_instr = "I2C_Tx_byte+0x1b3                              ";
         597 : dbg_instr = "I2C_Tx_byte+0x1b4                              ";
         598 : dbg_instr = "I2C_Tx_byte+0x1b5                              ";
         599 : dbg_instr = "I2C_Tx_byte+0x1b6                              ";
         600 : dbg_instr = "I2C_Tx_byte+0x1b7                              ";
         601 : dbg_instr = "I2C_Tx_byte+0x1b8                              ";
         602 : dbg_instr = "I2C_Tx_byte+0x1b9                              ";
         603 : dbg_instr = "I2C_Tx_byte+0x1ba                              ";
         604 : dbg_instr = "I2C_Tx_byte+0x1bb                              ";
         605 : dbg_instr = "I2C_Tx_byte+0x1bc                              ";
         606 : dbg_instr = "I2C_Tx_byte+0x1bd                              ";
         607 : dbg_instr = "I2C_Tx_byte+0x1be                              ";
         608 : dbg_instr = "I2C_Tx_byte+0x1bf                              ";
         609 : dbg_instr = "I2C_Tx_byte+0x1c0                              ";
         610 : dbg_instr = "I2C_Tx_byte+0x1c1                              ";
         611 : dbg_instr = "I2C_Tx_byte+0x1c2                              ";
         612 : dbg_instr = "I2C_Tx_byte+0x1c3                              ";
         613 : dbg_instr = "I2C_Tx_byte+0x1c4                              ";
         614 : dbg_instr = "I2C_Tx_byte+0x1c5                              ";
         615 : dbg_instr = "I2C_Tx_byte+0x1c6                              ";
         616 : dbg_instr = "I2C_Tx_byte+0x1c7                              ";
         617 : dbg_instr = "I2C_Tx_byte+0x1c8                              ";
         618 : dbg_instr = "I2C_Tx_byte+0x1c9                              ";
         619 : dbg_instr = "I2C_Tx_byte+0x1ca                              ";
         620 : dbg_instr = "I2C_Tx_byte+0x1cb                              ";
         621 : dbg_instr = "I2C_Tx_byte+0x1cc                              ";
         622 : dbg_instr = "I2C_Tx_byte+0x1cd                              ";
         623 : dbg_instr = "I2C_Tx_byte+0x1ce                              ";
         624 : dbg_instr = "I2C_Tx_byte+0x1cf                              ";
         625 : dbg_instr = "I2C_Tx_byte+0x1d0                              ";
         626 : dbg_instr = "I2C_Tx_byte+0x1d1                              ";
         627 : dbg_instr = "I2C_Tx_byte+0x1d2                              ";
         628 : dbg_instr = "I2C_Tx_byte+0x1d3                              ";
         629 : dbg_instr = "I2C_Tx_byte+0x1d4                              ";
         630 : dbg_instr = "I2C_Tx_byte+0x1d5                              ";
         631 : dbg_instr = "I2C_Tx_byte+0x1d6                              ";
         632 : dbg_instr = "I2C_Tx_byte+0x1d7                              ";
         633 : dbg_instr = "I2C_Tx_byte+0x1d8                              ";
         634 : dbg_instr = "I2C_Tx_byte+0x1d9                              ";
         635 : dbg_instr = "I2C_Tx_byte+0x1da                              ";
         636 : dbg_instr = "I2C_Tx_byte+0x1db                              ";
         637 : dbg_instr = "I2C_Tx_byte+0x1dc                              ";
         638 : dbg_instr = "I2C_Tx_byte+0x1dd                              ";
         639 : dbg_instr = "I2C_Tx_byte+0x1de                              ";
         640 : dbg_instr = "I2C_Tx_byte+0x1df                              ";
         641 : dbg_instr = "I2C_Tx_byte+0x1e0                              ";
         642 : dbg_instr = "I2C_Tx_byte+0x1e1                              ";
         643 : dbg_instr = "I2C_Tx_byte+0x1e2                              ";
         644 : dbg_instr = "I2C_Tx_byte+0x1e3                              ";
         645 : dbg_instr = "I2C_Tx_byte+0x1e4                              ";
         646 : dbg_instr = "I2C_Tx_byte+0x1e5                              ";
         647 : dbg_instr = "I2C_Tx_byte+0x1e6                              ";
         648 : dbg_instr = "I2C_Tx_byte+0x1e7                              ";
         649 : dbg_instr = "I2C_Tx_byte+0x1e8                              ";
         650 : dbg_instr = "I2C_Tx_byte+0x1e9                              ";
         651 : dbg_instr = "I2C_Tx_byte+0x1ea                              ";
         652 : dbg_instr = "I2C_Tx_byte+0x1eb                              ";
         653 : dbg_instr = "I2C_Tx_byte+0x1ec                              ";
         654 : dbg_instr = "I2C_Tx_byte+0x1ed                              ";
         655 : dbg_instr = "I2C_Tx_byte+0x1ee                              ";
         656 : dbg_instr = "I2C_Tx_byte+0x1ef                              ";
         657 : dbg_instr = "I2C_Tx_byte+0x1f0                              ";
         658 : dbg_instr = "I2C_Tx_byte+0x1f1                              ";
         659 : dbg_instr = "I2C_Tx_byte+0x1f2                              ";
         660 : dbg_instr = "I2C_Tx_byte+0x1f3                              ";
         661 : dbg_instr = "I2C_Tx_byte+0x1f4                              ";
         662 : dbg_instr = "I2C_Tx_byte+0x1f5                              ";
         663 : dbg_instr = "I2C_Tx_byte+0x1f6                              ";
         664 : dbg_instr = "I2C_Tx_byte+0x1f7                              ";
         665 : dbg_instr = "I2C_Tx_byte+0x1f8                              ";
         666 : dbg_instr = "I2C_Tx_byte+0x1f9                              ";
         667 : dbg_instr = "I2C_Tx_byte+0x1fa                              ";
         668 : dbg_instr = "I2C_Tx_byte+0x1fb                              ";
         669 : dbg_instr = "I2C_Tx_byte+0x1fc                              ";
         670 : dbg_instr = "I2C_Tx_byte+0x1fd                              ";
         671 : dbg_instr = "I2C_Tx_byte+0x1fe                              ";
         672 : dbg_instr = "I2C_Tx_byte+0x1ff                              ";
         673 : dbg_instr = "I2C_Tx_byte+0x200                              ";
         674 : dbg_instr = "I2C_Tx_byte+0x201                              ";
         675 : dbg_instr = "I2C_Tx_byte+0x202                              ";
         676 : dbg_instr = "I2C_Tx_byte+0x203                              ";
         677 : dbg_instr = "I2C_Tx_byte+0x204                              ";
         678 : dbg_instr = "I2C_Tx_byte+0x205                              ";
         679 : dbg_instr = "I2C_Tx_byte+0x206                              ";
         680 : dbg_instr = "I2C_Tx_byte+0x207                              ";
         681 : dbg_instr = "I2C_Tx_byte+0x208                              ";
         682 : dbg_instr = "I2C_Tx_byte+0x209                              ";
         683 : dbg_instr = "I2C_Tx_byte+0x20a                              ";
         684 : dbg_instr = "I2C_Tx_byte+0x20b                              ";
         685 : dbg_instr = "I2C_Tx_byte+0x20c                              ";
         686 : dbg_instr = "I2C_Tx_byte+0x20d                              ";
         687 : dbg_instr = "I2C_Tx_byte+0x20e                              ";
         688 : dbg_instr = "I2C_Tx_byte+0x20f                              ";
         689 : dbg_instr = "I2C_Tx_byte+0x210                              ";
         690 : dbg_instr = "I2C_Tx_byte+0x211                              ";
         691 : dbg_instr = "I2C_Tx_byte+0x212                              ";
         692 : dbg_instr = "I2C_Tx_byte+0x213                              ";
         693 : dbg_instr = "I2C_Tx_byte+0x214                              ";
         694 : dbg_instr = "I2C_Tx_byte+0x215                              ";
         695 : dbg_instr = "I2C_Tx_byte+0x216                              ";
         696 : dbg_instr = "I2C_Tx_byte+0x217                              ";
         697 : dbg_instr = "I2C_Tx_byte+0x218                              ";
         698 : dbg_instr = "I2C_Tx_byte+0x219                              ";
         699 : dbg_instr = "I2C_Tx_byte+0x21a                              ";
         700 : dbg_instr = "I2C_Tx_byte+0x21b                              ";
         701 : dbg_instr = "I2C_Tx_byte+0x21c                              ";
         702 : dbg_instr = "I2C_Tx_byte+0x21d                              ";
         703 : dbg_instr = "I2C_Tx_byte+0x21e                              ";
         704 : dbg_instr = "I2C_Tx_byte+0x21f                              ";
         705 : dbg_instr = "I2C_Tx_byte+0x220                              ";
         706 : dbg_instr = "I2C_Tx_byte+0x221                              ";
         707 : dbg_instr = "I2C_Tx_byte+0x222                              ";
         708 : dbg_instr = "I2C_Tx_byte+0x223                              ";
         709 : dbg_instr = "I2C_Tx_byte+0x224                              ";
         710 : dbg_instr = "I2C_Tx_byte+0x225                              ";
         711 : dbg_instr = "I2C_Tx_byte+0x226                              ";
         712 : dbg_instr = "I2C_Tx_byte+0x227                              ";
         713 : dbg_instr = "I2C_Tx_byte+0x228                              ";
         714 : dbg_instr = "I2C_Tx_byte+0x229                              ";
         715 : dbg_instr = "I2C_Tx_byte+0x22a                              ";
         716 : dbg_instr = "I2C_Tx_byte+0x22b                              ";
         717 : dbg_instr = "I2C_Tx_byte+0x22c                              ";
         718 : dbg_instr = "I2C_Tx_byte+0x22d                              ";
         719 : dbg_instr = "I2C_Tx_byte+0x22e                              ";
         720 : dbg_instr = "I2C_Tx_byte+0x22f                              ";
         721 : dbg_instr = "I2C_Tx_byte+0x230                              ";
         722 : dbg_instr = "I2C_Tx_byte+0x231                              ";
         723 : dbg_instr = "I2C_Tx_byte+0x232                              ";
         724 : dbg_instr = "I2C_Tx_byte+0x233                              ";
         725 : dbg_instr = "I2C_Tx_byte+0x234                              ";
         726 : dbg_instr = "I2C_Tx_byte+0x235                              ";
         727 : dbg_instr = "I2C_Tx_byte+0x236                              ";
         728 : dbg_instr = "I2C_Tx_byte+0x237                              ";
         729 : dbg_instr = "I2C_Tx_byte+0x238                              ";
         730 : dbg_instr = "I2C_Tx_byte+0x239                              ";
         731 : dbg_instr = "I2C_Tx_byte+0x23a                              ";
         732 : dbg_instr = "I2C_Tx_byte+0x23b                              ";
         733 : dbg_instr = "I2C_Tx_byte+0x23c                              ";
         734 : dbg_instr = "I2C_Tx_byte+0x23d                              ";
         735 : dbg_instr = "I2C_Tx_byte+0x23e                              ";
         736 : dbg_instr = "I2C_Tx_byte+0x23f                              ";
         737 : dbg_instr = "I2C_Tx_byte+0x240                              ";
         738 : dbg_instr = "I2C_Tx_byte+0x241                              ";
         739 : dbg_instr = "I2C_Tx_byte+0x242                              ";
         740 : dbg_instr = "I2C_Tx_byte+0x243                              ";
         741 : dbg_instr = "I2C_Tx_byte+0x244                              ";
         742 : dbg_instr = "I2C_Tx_byte+0x245                              ";
         743 : dbg_instr = "I2C_Tx_byte+0x246                              ";
         744 : dbg_instr = "I2C_Tx_byte+0x247                              ";
         745 : dbg_instr = "I2C_Tx_byte+0x248                              ";
         746 : dbg_instr = "I2C_Tx_byte+0x249                              ";
         747 : dbg_instr = "I2C_Tx_byte+0x24a                              ";
         748 : dbg_instr = "I2C_Tx_byte+0x24b                              ";
         749 : dbg_instr = "I2C_Tx_byte+0x24c                              ";
         750 : dbg_instr = "I2C_Tx_byte+0x24d                              ";
         751 : dbg_instr = "I2C_Tx_byte+0x24e                              ";
         752 : dbg_instr = "I2C_Tx_byte+0x24f                              ";
         753 : dbg_instr = "I2C_Tx_byte+0x250                              ";
         754 : dbg_instr = "I2C_Tx_byte+0x251                              ";
         755 : dbg_instr = "I2C_Tx_byte+0x252                              ";
         756 : dbg_instr = "I2C_Tx_byte+0x253                              ";
         757 : dbg_instr = "I2C_Tx_byte+0x254                              ";
         758 : dbg_instr = "I2C_Tx_byte+0x255                              ";
         759 : dbg_instr = "I2C_Tx_byte+0x256                              ";
         760 : dbg_instr = "I2C_Tx_byte+0x257                              ";
         761 : dbg_instr = "I2C_Tx_byte+0x258                              ";
         762 : dbg_instr = "I2C_Tx_byte+0x259                              ";
         763 : dbg_instr = "I2C_Tx_byte+0x25a                              ";
         764 : dbg_instr = "I2C_Tx_byte+0x25b                              ";
         765 : dbg_instr = "I2C_Tx_byte+0x25c                              ";
         766 : dbg_instr = "I2C_Tx_byte+0x25d                              ";
         767 : dbg_instr = "I2C_Tx_byte+0x25e                              ";
         768 : dbg_instr = "I2C_Tx_byte+0x25f                              ";
         769 : dbg_instr = "I2C_Tx_byte+0x260                              ";
         770 : dbg_instr = "I2C_Tx_byte+0x261                              ";
         771 : dbg_instr = "I2C_Tx_byte+0x262                              ";
         772 : dbg_instr = "I2C_Tx_byte+0x263                              ";
         773 : dbg_instr = "I2C_Tx_byte+0x264                              ";
         774 : dbg_instr = "I2C_Tx_byte+0x265                              ";
         775 : dbg_instr = "I2C_Tx_byte+0x266                              ";
         776 : dbg_instr = "I2C_Tx_byte+0x267                              ";
         777 : dbg_instr = "I2C_Tx_byte+0x268                              ";
         778 : dbg_instr = "I2C_Tx_byte+0x269                              ";
         779 : dbg_instr = "I2C_Tx_byte+0x26a                              ";
         780 : dbg_instr = "I2C_Tx_byte+0x26b                              ";
         781 : dbg_instr = "I2C_Tx_byte+0x26c                              ";
         782 : dbg_instr = "I2C_Tx_byte+0x26d                              ";
         783 : dbg_instr = "I2C_Tx_byte+0x26e                              ";
         784 : dbg_instr = "I2C_Tx_byte+0x26f                              ";
         785 : dbg_instr = "I2C_Tx_byte+0x270                              ";
         786 : dbg_instr = "I2C_Tx_byte+0x271                              ";
         787 : dbg_instr = "I2C_Tx_byte+0x272                              ";
         788 : dbg_instr = "I2C_Tx_byte+0x273                              ";
         789 : dbg_instr = "I2C_Tx_byte+0x274                              ";
         790 : dbg_instr = "I2C_Tx_byte+0x275                              ";
         791 : dbg_instr = "I2C_Tx_byte+0x276                              ";
         792 : dbg_instr = "I2C_Tx_byte+0x277                              ";
         793 : dbg_instr = "I2C_Tx_byte+0x278                              ";
         794 : dbg_instr = "I2C_Tx_byte+0x279                              ";
         795 : dbg_instr = "I2C_Tx_byte+0x27a                              ";
         796 : dbg_instr = "I2C_Tx_byte+0x27b                              ";
         797 : dbg_instr = "I2C_Tx_byte+0x27c                              ";
         798 : dbg_instr = "I2C_Tx_byte+0x27d                              ";
         799 : dbg_instr = "I2C_Tx_byte+0x27e                              ";
         800 : dbg_instr = "I2C_Tx_byte+0x27f                              ";
         801 : dbg_instr = "I2C_Tx_byte+0x280                              ";
         802 : dbg_instr = "I2C_Tx_byte+0x281                              ";
         803 : dbg_instr = "I2C_Tx_byte+0x282                              ";
         804 : dbg_instr = "I2C_Tx_byte+0x283                              ";
         805 : dbg_instr = "I2C_Tx_byte+0x284                              ";
         806 : dbg_instr = "I2C_Tx_byte+0x285                              ";
         807 : dbg_instr = "I2C_Tx_byte+0x286                              ";
         808 : dbg_instr = "I2C_Tx_byte+0x287                              ";
         809 : dbg_instr = "I2C_Tx_byte+0x288                              ";
         810 : dbg_instr = "I2C_Tx_byte+0x289                              ";
         811 : dbg_instr = "I2C_Tx_byte+0x28a                              ";
         812 : dbg_instr = "I2C_Tx_byte+0x28b                              ";
         813 : dbg_instr = "I2C_Tx_byte+0x28c                              ";
         814 : dbg_instr = "I2C_Tx_byte+0x28d                              ";
         815 : dbg_instr = "I2C_Tx_byte+0x28e                              ";
         816 : dbg_instr = "I2C_Tx_byte+0x28f                              ";
         817 : dbg_instr = "I2C_Tx_byte+0x290                              ";
         818 : dbg_instr = "I2C_Tx_byte+0x291                              ";
         819 : dbg_instr = "I2C_Tx_byte+0x292                              ";
         820 : dbg_instr = "I2C_Tx_byte+0x293                              ";
         821 : dbg_instr = "I2C_Tx_byte+0x294                              ";
         822 : dbg_instr = "I2C_Tx_byte+0x295                              ";
         823 : dbg_instr = "I2C_Tx_byte+0x296                              ";
         824 : dbg_instr = "I2C_Tx_byte+0x297                              ";
         825 : dbg_instr = "I2C_Tx_byte+0x298                              ";
         826 : dbg_instr = "I2C_Tx_byte+0x299                              ";
         827 : dbg_instr = "I2C_Tx_byte+0x29a                              ";
         828 : dbg_instr = "I2C_Tx_byte+0x29b                              ";
         829 : dbg_instr = "I2C_Tx_byte+0x29c                              ";
         830 : dbg_instr = "I2C_Tx_byte+0x29d                              ";
         831 : dbg_instr = "I2C_Tx_byte+0x29e                              ";
         832 : dbg_instr = "I2C_Tx_byte+0x29f                              ";
         833 : dbg_instr = "I2C_Tx_byte+0x2a0                              ";
         834 : dbg_instr = "I2C_Tx_byte+0x2a1                              ";
         835 : dbg_instr = "I2C_Tx_byte+0x2a2                              ";
         836 : dbg_instr = "I2C_Tx_byte+0x2a3                              ";
         837 : dbg_instr = "I2C_Tx_byte+0x2a4                              ";
         838 : dbg_instr = "I2C_Tx_byte+0x2a5                              ";
         839 : dbg_instr = "I2C_Tx_byte+0x2a6                              ";
         840 : dbg_instr = "I2C_Tx_byte+0x2a7                              ";
         841 : dbg_instr = "I2C_Tx_byte+0x2a8                              ";
         842 : dbg_instr = "I2C_Tx_byte+0x2a9                              ";
         843 : dbg_instr = "I2C_Tx_byte+0x2aa                              ";
         844 : dbg_instr = "I2C_Tx_byte+0x2ab                              ";
         845 : dbg_instr = "I2C_Tx_byte+0x2ac                              ";
         846 : dbg_instr = "I2C_Tx_byte+0x2ad                              ";
         847 : dbg_instr = "I2C_Tx_byte+0x2ae                              ";
         848 : dbg_instr = "I2C_Tx_byte+0x2af                              ";
         849 : dbg_instr = "I2C_Tx_byte+0x2b0                              ";
         850 : dbg_instr = "I2C_Tx_byte+0x2b1                              ";
         851 : dbg_instr = "I2C_Tx_byte+0x2b2                              ";
         852 : dbg_instr = "I2C_Tx_byte+0x2b3                              ";
         853 : dbg_instr = "I2C_Tx_byte+0x2b4                              ";
         854 : dbg_instr = "I2C_Tx_byte+0x2b5                              ";
         855 : dbg_instr = "I2C_Tx_byte+0x2b6                              ";
         856 : dbg_instr = "I2C_Tx_byte+0x2b7                              ";
         857 : dbg_instr = "I2C_Tx_byte+0x2b8                              ";
         858 : dbg_instr = "I2C_Tx_byte+0x2b9                              ";
         859 : dbg_instr = "I2C_Tx_byte+0x2ba                              ";
         860 : dbg_instr = "I2C_Tx_byte+0x2bb                              ";
         861 : dbg_instr = "I2C_Tx_byte+0x2bc                              ";
         862 : dbg_instr = "I2C_Tx_byte+0x2bd                              ";
         863 : dbg_instr = "I2C_Tx_byte+0x2be                              ";
         864 : dbg_instr = "I2C_Tx_byte+0x2bf                              ";
         865 : dbg_instr = "I2C_Tx_byte+0x2c0                              ";
         866 : dbg_instr = "I2C_Tx_byte+0x2c1                              ";
         867 : dbg_instr = "I2C_Tx_byte+0x2c2                              ";
         868 : dbg_instr = "I2C_Tx_byte+0x2c3                              ";
         869 : dbg_instr = "I2C_Tx_byte+0x2c4                              ";
         870 : dbg_instr = "I2C_Tx_byte+0x2c5                              ";
         871 : dbg_instr = "I2C_Tx_byte+0x2c6                              ";
         872 : dbg_instr = "I2C_Tx_byte+0x2c7                              ";
         873 : dbg_instr = "I2C_Tx_byte+0x2c8                              ";
         874 : dbg_instr = "I2C_Tx_byte+0x2c9                              ";
         875 : dbg_instr = "I2C_Tx_byte+0x2ca                              ";
         876 : dbg_instr = "I2C_Tx_byte+0x2cb                              ";
         877 : dbg_instr = "I2C_Tx_byte+0x2cc                              ";
         878 : dbg_instr = "I2C_Tx_byte+0x2cd                              ";
         879 : dbg_instr = "I2C_Tx_byte+0x2ce                              ";
         880 : dbg_instr = "I2C_Tx_byte+0x2cf                              ";
         881 : dbg_instr = "I2C_Tx_byte+0x2d0                              ";
         882 : dbg_instr = "I2C_Tx_byte+0x2d1                              ";
         883 : dbg_instr = "I2C_Tx_byte+0x2d2                              ";
         884 : dbg_instr = "I2C_Tx_byte+0x2d3                              ";
         885 : dbg_instr = "I2C_Tx_byte+0x2d4                              ";
         886 : dbg_instr = "I2C_Tx_byte+0x2d5                              ";
         887 : dbg_instr = "I2C_Tx_byte+0x2d6                              ";
         888 : dbg_instr = "I2C_Tx_byte+0x2d7                              ";
         889 : dbg_instr = "I2C_Tx_byte+0x2d8                              ";
         890 : dbg_instr = "I2C_Tx_byte+0x2d9                              ";
         891 : dbg_instr = "I2C_Tx_byte+0x2da                              ";
         892 : dbg_instr = "I2C_Tx_byte+0x2db                              ";
         893 : dbg_instr = "I2C_Tx_byte+0x2dc                              ";
         894 : dbg_instr = "I2C_Tx_byte+0x2dd                              ";
         895 : dbg_instr = "I2C_Tx_byte+0x2de                              ";
         896 : dbg_instr = "I2C_Tx_byte+0x2df                              ";
         897 : dbg_instr = "I2C_Tx_byte+0x2e0                              ";
         898 : dbg_instr = "I2C_Tx_byte+0x2e1                              ";
         899 : dbg_instr = "I2C_Tx_byte+0x2e2                              ";
         900 : dbg_instr = "I2C_Tx_byte+0x2e3                              ";
         901 : dbg_instr = "I2C_Tx_byte+0x2e4                              ";
         902 : dbg_instr = "I2C_Tx_byte+0x2e5                              ";
         903 : dbg_instr = "I2C_Tx_byte+0x2e6                              ";
         904 : dbg_instr = "I2C_Tx_byte+0x2e7                              ";
         905 : dbg_instr = "I2C_Tx_byte+0x2e8                              ";
         906 : dbg_instr = "I2C_Tx_byte+0x2e9                              ";
         907 : dbg_instr = "I2C_Tx_byte+0x2ea                              ";
         908 : dbg_instr = "I2C_Tx_byte+0x2eb                              ";
         909 : dbg_instr = "I2C_Tx_byte+0x2ec                              ";
         910 : dbg_instr = "I2C_Tx_byte+0x2ed                              ";
         911 : dbg_instr = "I2C_Tx_byte+0x2ee                              ";
         912 : dbg_instr = "I2C_Tx_byte+0x2ef                              ";
         913 : dbg_instr = "I2C_Tx_byte+0x2f0                              ";
         914 : dbg_instr = "I2C_Tx_byte+0x2f1                              ";
         915 : dbg_instr = "I2C_Tx_byte+0x2f2                              ";
         916 : dbg_instr = "I2C_Tx_byte+0x2f3                              ";
         917 : dbg_instr = "I2C_Tx_byte+0x2f4                              ";
         918 : dbg_instr = "I2C_Tx_byte+0x2f5                              ";
         919 : dbg_instr = "I2C_Tx_byte+0x2f6                              ";
         920 : dbg_instr = "I2C_Tx_byte+0x2f7                              ";
         921 : dbg_instr = "I2C_Tx_byte+0x2f8                              ";
         922 : dbg_instr = "I2C_Tx_byte+0x2f9                              ";
         923 : dbg_instr = "I2C_Tx_byte+0x2fa                              ";
         924 : dbg_instr = "I2C_Tx_byte+0x2fb                              ";
         925 : dbg_instr = "I2C_Tx_byte+0x2fc                              ";
         926 : dbg_instr = "I2C_Tx_byte+0x2fd                              ";
         927 : dbg_instr = "I2C_Tx_byte+0x2fe                              ";
         928 : dbg_instr = "I2C_Tx_byte+0x2ff                              ";
         929 : dbg_instr = "I2C_Tx_byte+0x300                              ";
         930 : dbg_instr = "I2C_Tx_byte+0x301                              ";
         931 : dbg_instr = "I2C_Tx_byte+0x302                              ";
         932 : dbg_instr = "I2C_Tx_byte+0x303                              ";
         933 : dbg_instr = "I2C_Tx_byte+0x304                              ";
         934 : dbg_instr = "I2C_Tx_byte+0x305                              ";
         935 : dbg_instr = "I2C_Tx_byte+0x306                              ";
         936 : dbg_instr = "I2C_Tx_byte+0x307                              ";
         937 : dbg_instr = "I2C_Tx_byte+0x308                              ";
         938 : dbg_instr = "I2C_Tx_byte+0x309                              ";
         939 : dbg_instr = "I2C_Tx_byte+0x30a                              ";
         940 : dbg_instr = "I2C_Tx_byte+0x30b                              ";
         941 : dbg_instr = "I2C_Tx_byte+0x30c                              ";
         942 : dbg_instr = "I2C_Tx_byte+0x30d                              ";
         943 : dbg_instr = "I2C_Tx_byte+0x30e                              ";
         944 : dbg_instr = "I2C_Tx_byte+0x30f                              ";
         945 : dbg_instr = "I2C_Tx_byte+0x310                              ";
         946 : dbg_instr = "I2C_Tx_byte+0x311                              ";
         947 : dbg_instr = "I2C_Tx_byte+0x312                              ";
         948 : dbg_instr = "I2C_Tx_byte+0x313                              ";
         949 : dbg_instr = "I2C_Tx_byte+0x314                              ";
         950 : dbg_instr = "I2C_Tx_byte+0x315                              ";
         951 : dbg_instr = "I2C_Tx_byte+0x316                              ";
         952 : dbg_instr = "I2C_Tx_byte+0x317                              ";
         953 : dbg_instr = "I2C_Tx_byte+0x318                              ";
         954 : dbg_instr = "I2C_Tx_byte+0x319                              ";
         955 : dbg_instr = "I2C_Tx_byte+0x31a                              ";
         956 : dbg_instr = "I2C_Tx_byte+0x31b                              ";
         957 : dbg_instr = "I2C_Tx_byte+0x31c                              ";
         958 : dbg_instr = "I2C_Tx_byte+0x31d                              ";
         959 : dbg_instr = "I2C_Tx_byte+0x31e                              ";
         960 : dbg_instr = "I2C_Tx_byte+0x31f                              ";
         961 : dbg_instr = "I2C_Tx_byte+0x320                              ";
         962 : dbg_instr = "I2C_Tx_byte+0x321                              ";
         963 : dbg_instr = "I2C_Tx_byte+0x322                              ";
         964 : dbg_instr = "I2C_Tx_byte+0x323                              ";
         965 : dbg_instr = "I2C_Tx_byte+0x324                              ";
         966 : dbg_instr = "I2C_Tx_byte+0x325                              ";
         967 : dbg_instr = "I2C_Tx_byte+0x326                              ";
         968 : dbg_instr = "I2C_Tx_byte+0x327                              ";
         969 : dbg_instr = "I2C_Tx_byte+0x328                              ";
         970 : dbg_instr = "I2C_Tx_byte+0x329                              ";
         971 : dbg_instr = "I2C_Tx_byte+0x32a                              ";
         972 : dbg_instr = "I2C_Tx_byte+0x32b                              ";
         973 : dbg_instr = "I2C_Tx_byte+0x32c                              ";
         974 : dbg_instr = "I2C_Tx_byte+0x32d                              ";
         975 : dbg_instr = "I2C_Tx_byte+0x32e                              ";
         976 : dbg_instr = "I2C_Tx_byte+0x32f                              ";
         977 : dbg_instr = "I2C_Tx_byte+0x330                              ";
         978 : dbg_instr = "I2C_Tx_byte+0x331                              ";
         979 : dbg_instr = "I2C_Tx_byte+0x332                              ";
         980 : dbg_instr = "I2C_Tx_byte+0x333                              ";
         981 : dbg_instr = "I2C_Tx_byte+0x334                              ";
         982 : dbg_instr = "I2C_Tx_byte+0x335                              ";
         983 : dbg_instr = "I2C_Tx_byte+0x336                              ";
         984 : dbg_instr = "I2C_Tx_byte+0x337                              ";
         985 : dbg_instr = "I2C_Tx_byte+0x338                              ";
         986 : dbg_instr = "I2C_Tx_byte+0x339                              ";
         987 : dbg_instr = "I2C_Tx_byte+0x33a                              ";
         988 : dbg_instr = "I2C_Tx_byte+0x33b                              ";
         989 : dbg_instr = "I2C_Tx_byte+0x33c                              ";
         990 : dbg_instr = "I2C_Tx_byte+0x33d                              ";
         991 : dbg_instr = "I2C_Tx_byte+0x33e                              ";
         992 : dbg_instr = "I2C_Tx_byte+0x33f                              ";
         993 : dbg_instr = "I2C_Tx_byte+0x340                              ";
         994 : dbg_instr = "I2C_Tx_byte+0x341                              ";
         995 : dbg_instr = "I2C_Tx_byte+0x342                              ";
         996 : dbg_instr = "I2C_Tx_byte+0x343                              ";
         997 : dbg_instr = "I2C_Tx_byte+0x344                              ";
         998 : dbg_instr = "I2C_Tx_byte+0x345                              ";
         999 : dbg_instr = "I2C_Tx_byte+0x346                              ";
         1000 : dbg_instr = "I2C_Tx_byte+0x347                              ";
         1001 : dbg_instr = "I2C_Tx_byte+0x348                              ";
         1002 : dbg_instr = "I2C_Tx_byte+0x349                              ";
         1003 : dbg_instr = "I2C_Tx_byte+0x34a                              ";
         1004 : dbg_instr = "I2C_Tx_byte+0x34b                              ";
         1005 : dbg_instr = "I2C_Tx_byte+0x34c                              ";
         1006 : dbg_instr = "I2C_Tx_byte+0x34d                              ";
         1007 : dbg_instr = "I2C_Tx_byte+0x34e                              ";
         1008 : dbg_instr = "I2C_Tx_byte+0x34f                              ";
         1009 : dbg_instr = "I2C_Tx_byte+0x350                              ";
         1010 : dbg_instr = "I2C_Tx_byte+0x351                              ";
         1011 : dbg_instr = "I2C_Tx_byte+0x352                              ";
         1012 : dbg_instr = "I2C_Tx_byte+0x353                              ";
         1013 : dbg_instr = "I2C_Tx_byte+0x354                              ";
         1014 : dbg_instr = "I2C_Tx_byte+0x355                              ";
         1015 : dbg_instr = "I2C_Tx_byte+0x356                              ";
         1016 : dbg_instr = "I2C_Tx_byte+0x357                              ";
         1017 : dbg_instr = "I2C_Tx_byte+0x358                              ";
         1018 : dbg_instr = "I2C_Tx_byte+0x359                              ";
         1019 : dbg_instr = "I2C_Tx_byte+0x35a                              ";
         1020 : dbg_instr = "I2C_Tx_byte+0x35b                              ";
         1021 : dbg_instr = "I2C_Tx_byte+0x35c                              ";
         1022 : dbg_instr = "I2C_Tx_byte+0x35d                              ";
         1023 : dbg_instr = "I2C_Tx_byte+0x35e                              ";
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
    .INIT_00(256'h00341A02FA00FB01500060099F014F800008000700082004000000002004003A),
    .INIT_01(256'h0005B002201FB02250000005B00150009AFF0AC0E0119C01A016004AAAC05000),
    .INIT_02(256'hE1A01A0040065000BA02500000110065FA025A01BA011C015000001900060077),
    .INIT_03(256'h10001100007CD2201200193F50001A00007C001100650CA05000500160330034),
    .INIT_04(256'h0024FA005000DA01008200A15000D2201201603F1102C0205280420E0210002D),
    .INIT_05(256'h9901EC905000007C1BFF1AFF205C00740BA0001C0096001E0062A05A009C605A),
    .INIT_06(256'h5000AC9019010070500000190006B00200050077B02250009901EA909901EB90),
    .INIT_07(256'h000600770005B00250002078DF019F00B0115000AA9019015000AB9019010074),
    .INIT_08(256'h009C60930024FA005000001900074A00DF029F00000700770005B0225000B022),
    .INIT_09(256'h00969000004A0065500000822097DA8000821A015000007C1AFF2094001CA093),
    .INIT_0A(256'h000000000000000000005000E0A24B0E001FB00220A7B02220A6CBA01B805000),
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
    .INITP_00(256'hAAB0A18686AAAA666A0A2ABBA8AA36120A09A88E863A80AAAAAA4DE28AB5AA0A),
    .INITP_01(256'h0000000000000000000000000000000000000000002DAAC2BAAC8A2BBAA90AAA),

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
