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
module input_logic
#(
  parameter DATA_WIDTH = 8,
  parameter DATA_SIZE = 6
)
(
  input                  clk,
  input                  rst_n,
  // Input IF
  input [DATA_WIDTH-1:0] data_in,
  input                  data_in_req,
  output                 data_in_ack,
  //FIFO IF
  output                 fifo_push,
  output                 fifo_flush,
  input                  fifo_full,
  // Config IF
  input            [1:0] ch0_addr,
  input            [1:0] ch1_addr,
  input            [1:0] ch2_addr,
  input                  crc_en
);
  localparam [1:0] IDLE = 2'b00, HEADER  = 2'b01,
                   DATA = 2'b10, DISCARD = 2'b11;

  // Input IF
  reg                  data_in_ack_r;
  reg [DATA_WIDTH-1:0] data_in_r;

  // FIFO IF
  reg                  fifo_flush_c;
  reg                  fifo_push_c;
  reg                  data_in_ack_c;

  // Internal
  reg                  req_edge_detect_r;
  reg  [DATA_SIZE-1:0] pkt_cnt_r;
  reg            [1:0] pkt_addr_r;

  reg                  bad_data_size_c;
  reg            [2:0] ch_sel_c;

  wire                 crc8_en;
  reg                  crc_next_c;
  reg                  bad_crc_c;
  reg            [1:0] check_crc_r;
  wire           [7:0] crc_out;

  reg            [1:0] state_r, state_next_c;

  assign data_in_ack = data_in_ack_r;

  assign fifo_push = fifo_push_c;
  assign fifo_flush = fifo_flush_c;

  //CRC INSTANCE
  assign crc8_en = crc_en & data_in_ack_r;

  crc8
  crc8_inst
  (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in_r),
    .crc_en(crc8_en),
    .crc_out(crc_out)
  );

  // INPUT BUFFER & NEW PKT DETECTION
  always @(posedge clk or negedge rst_n)
  begin: req_edge_detect_r_proc
    if (!rst_n) begin
      req_edge_detect_r <= 1'b0;
    end
    else if (data_in_req && !req_edge_detect_r && state_r == IDLE) begin
      req_edge_detect_r <= 1'b1;
    end
    else begin
      req_edge_detect_r <= 1'b0;
    end
  end

  always @(posedge clk or negedge rst_n)
  begin: data_in_r_proc
    if (!rst_n) begin
      data_in_r <= {DATA_WIDTH{1'b0}};
    end
    else if (data_in_req) begin
      data_in_r <= data_in;
    end
  end

  // HEADER - ADDR & CH_SEL
  always @(posedge clk or negedge rst_n)
  begin: pkt_addr_r_proc
    if (!rst_n) begin
      pkt_addr_r <= 2'b00;
    end
    else if (req_edge_detect_r && state_r == IDLE) begin
      pkt_addr_r <= data_in[DATA_SIZE-1:DATA_SIZE-3];
    end
  end

  always @(*)
  begin: ch_sel_c_proc
    ch_sel_c = 3'b000;
    if(pkt_addr_r == ch0_addr) begin
      ch_sel_c[0] = 1'b1;
    end
    if(pkt_addr_r == ch1_addr) begin
      ch_sel_c[1] = 1'b1;
    end
    if(pkt_addr_r == ch2_addr) begin
      ch_sel_c[2] = 1'b1;
    end
  end

  // HEADER - PKT SIZE, ADDR
  always @(posedge clk or negedge rst_n)
  begin: pkt_cnt_r_proc
    if (!rst_n) begin
      pkt_cnt_r <= {DATA_WIDTH{1'b0}};
    end
    else if (req_edge_detect_r && state_r == IDLE) begin
      // load SIZE+1
      pkt_cnt_r <= data_in_r[DATA_SIZE-1:0]+1'b1;
    end
    else if ((state_r == DATA || state_r == DISCARD) && data_in_ack_r && pkt_cnt_r != {DATA_WIDTH{1'b0}})
      pkt_cnt_r <= pkt_cnt_r-1'b1;
  end

  always @(*)
  begin: bad_data_size_c_proc
    if (pkt_cnt_r == {DATA_WIDTH{1'b1}}) begin
      bad_data_size_c = 1'b1;
    end
    else begin
      bad_data_size_c = 1'b0;
    end
  end

  // PUSH/FLUSH/ACK LOGIC
  always @(*)
  begin: push_flush_ack_logic_c_proc
    fifo_flush_c = 1'b0;
    fifo_push_c = 1'b0;
    data_in_ack_c = 1'b0;
    if (bad_crc_c) begin
      fifo_flush_c = 1'b1;
    end
    if ((!fifo_full && data_in_req && !data_in_ack_r) || state_r == DISCARD) begin
      data_in_ack_c = 1'b1;
    end
    if (data_in_ack_r && state_r == DATA) begin
      fifo_push_c = 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n)
  begin: data_in_ack_r_proc
    if (!rst_n) begin
      data_in_ack_r <= 1'b0;
    end
    else begin
      data_in_ack_r <= data_in_ack_c;
    end
  end

  // CRC logic
  always @(*)
  begin: crc_next_c_proc
    if (crc_en && state_r == DATA && pkt_cnt_r == {DATA_WIDTH{1'b0}})
      crc_next_c = 1'b1;
    else
      crc_next_c = 1'b0;
  end

  always @(posedge clk or negedge rst_n)
  begin: check_crc_r_proc
    if (!rst_n) begin
      check_crc_r <= 2'b00;
    end
    else if (state_r == DATA) begin
      check_crc_r <= {check_crc_r[0], crc_next_c};
    end
  end

  always @(*)
  begin: bad_crc_c_proc
    bad_crc_c = 1'b0;
    if (check_crc_r[1] && crc_out != data_in_r)
      bad_crc_c = 1'b1;
  end

    // FSM
    always @(posedge clk or negedge rst_n)
    begin: state_r_proc
      if (!rst_n) begin
        state_r <= 2'b00;
      end
      else begin
        state_r <= state_next_c;
      end
    end

    always @(*)
    begin: state_next_c_proc
      case (state_r)
        IDLE:
          if (req_edge_detect_r) begin
            state_next_c = HEADER;
          end
          else begin
            state_next_c = IDLE;
          end
        HEADER:
          if (ch_sel_c == 3'b000 || bad_data_size_c) begin
            state_next_c = DISCARD;
          end
          else begin
            state_next_c = DATA;
          end
        DATA:
          if (pkt_cnt_r == {DATA_SIZE{1'b0}} || (crc_en && check_crc_r[1] && bad_crc_c)) begin
            state_next_c = IDLE;
          end
          else begin
            state_next_c = DATA;
          end
        DISCARD: //wait for pkt to end, ack all bytes
          if (pkt_cnt_r == {DATA_SIZE{1'b0}}) begin
            state_next_c = IDLE;
          end
          else begin
            state_next_c = DISCARD;
          end
      endcase
    end

endmodule
