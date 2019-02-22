// ------------------------------------------------------------
// Module: yas_router_top.v
// Author: PWI
// Release: 1.0, Feb 2019
// ------------------------------------------------------------

module yas_router_top
#(
parameter DATA_WIDTH=8
)
(
  input clk,
  input rst_n,
  // INPUT IF
  input [DATA_WIDTH-1:0] data_in,
  input data_in_req,
  output reg data_in_ack,
  // OUTPUT IF
  output reg [(3*DATA_WIDTH)-1:0] data_out,
  output reg [(3*DATA_WIDTH)-1:0] data_out_req,
  input [(3*DATA_WIDTH)-1:0] data_out_ack,
  // CONFIG IF
  input [1:0] config_addr,
  input [1:0] config_data,
  input config_en
);
// INTERNAL WIRES
// from config regs
wire [1:0] ch0_addr;
wire [1:0] ch1_addr;
wire [1:0] ch2_addr;
wire       crc_en;



config_regs
config_regs_inst
(
  .clk(clk),
  .rst_n(rst_n),
  .config_addr(config_addr),
  .config_data(config_data),
  .config_en(config_en),
  .ch0_addr(ch0_addr),
  .ch1_addr(ch1_addr),
  .ch2_addr(ch2_addr),
  .crc_en(crc_en)
);

endmodule
