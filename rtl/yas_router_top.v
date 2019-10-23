// ------------------------------------------------------------
// Module: yas_router_top.v
// Author: PWI
// Release: 1.0, Feb 2019
// ------------------------------------------------------------

module yas_router_top
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

  localparam DATA_WIDTH = 8;
  localparam DATA_SIZE = 6; //max 64 bytes

  // INTERNAL WIRES
  // from config regs
  wire            [1:0] ch0_addr;
  wire            [1:0] ch1_addr;
  wire            [1:0] ch2_addr;
  wire                  crc_en;

  // input logic <-> fifo
  wire            [2:0] fifo_push;
  wire            [2:0] fifo_flush;
  wire            [2:0] fifo_full;
  wire            [2:0] fifo_wr_ptr_upd;
  wire [DATA_WIDTH-1:0] fifo_data_in;

  // fifo <-> output logic
  wire [(3*DATA_WIDTH)-1:0] fifo_data_out;

  input_logic
  input_logic_inst
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_SIZE(DATA_SIZE)
  )
  (
    .clk(clk),
    .rst_n(rst_n),
    // Input IF
    .data_in(data_in),
    .data_in_req(data_in_req),
    .data_in_ack(data_in_ack),
    // FIFO IF
    .fifo_push(fifo_push),
    .fifo_flush(fifo_flush),
    .fifo_full(fifo_full),
    .fifo_data_in(fifo_data_in),
    .fifo_wr_ptr_upd(fifo_wr_ptr_upd),
    // Config IF
    .ch0_addr(ch0_addr),
    .ch1_addr(ch1_addr),
    .ch2_addr(ch2_addr),
    .crc_en(crc_en)
  );

  genvar i;
  generate for (i=0; i<3; i=i+1)
  begin: FIFO_AND_OUTPUT_LOGIC_GENERATE_PROC
    fifo_synch
    fifo_inst
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .POINTER_WIDTH(DATA_SIZE)
    )
    (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(fifo_data_in),
      .wr_ptr_upd(fifo_wr_ptr_upd[i]),
      .flush(fifo_flush[i]),
      .level(),
      .push(fifo_push[i]),
      .pop(fifo_pop[i]),
      .data_out(fifo_data_out),
      .full(fifo_full[i]),
      .empty(fifo_empty[i])
    );

    output_logic
    output_logic_inst
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    (

    );
  end
  endgenerate

  /*output logic inst */

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
