/*
BSD 2-Clause License

Copyright (c) 2019, TDK Electronics
All rights reserved.

Author: Pawel Wiecha, https://github.com/pwiecha

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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
  wire [1:0] ch0_addr;
  wire [1:0] ch1_addr;
  wire [1:0] ch2_addr;
  wire       crc_en;

  /*
  input_logic
  input_logic_inst
#(.DATA_WIDTH(DATA_WIDTH),
  .DATA_SIZE(DATA_SIZE))
  (
  );

  */

  genvar i;
  generate for (i=0; i<3; i=i+1)
  begin: FIFO_GENERATE_PROC
    fifo_synch
    fifo_inst
    #( .DATA_WIDTH(DATA_WIDTH),
       .POINTER_WIDTH(DATA_SIZE)
    )
    (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(),
      .pkt_start(),
      .flush(),
      .level(),
      .push(),
      .pop(),
      .data_out(),
      .full(),
      .empty()
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
