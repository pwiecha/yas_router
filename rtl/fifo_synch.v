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
// Module: fifo_synch.v
// Author: PWI
// Release: 1.0, Mar 2019
// Synchronous fifo with flush (discard pkt with bad CRC)
// and fifo level indicator
// ------------------------------------------------------------

module fifo_synch
#(
  parameter DATA_WIDTH = 8,
  parameter POINTER_WIDTH = 6
)
(
  input                      clk,
  input                      rst_n,
  input  [DATA_WIDTH-1:0]    data_in,
  input                      pkt_start, // fifo will store wr_ptr
  input                      flush, // go back to stored wr_ptr
  output                     level,
  input                      push,
  output                     pop,
  output [DATA_WIDTH-1:0]    data_out,
  output                     full,
  output                     empty
);

localparam FIFO_DEPTH = 1 << POINTER_WIDTH; //2^6=64 cells

reg [DATA_WIDTH-1:0]    fifo_r [FIFO_DEPTH-1:0];
reg [POINTER_WIDTH:0]   rd_pointer_r; //+wrap indicator bit
reg [POINTER_WIDTH:0]   wr_pointer_r; //+wrap indicator bit
reg [POINTER_WIDTH:0]   wr_pointer_prev_r; //+wrap indicator bit
reg [POINTER_WIDTH-1:0] level_r;
wire                    full_bit;

assign level = level_r;

// STATUS FLAGS
assign full_bit = wr_pointer_r[POINTER_WIDTH] ^ rd_pointer_r[POINTER_WIDTH];
assign full = full_bit && (wr_pointer_r[POINTER_WIDTH-1:0] == rd_pointer_r[POINTER_WIDTH-1:0]);
assign empty = (wr_pointer_r == rd_pointer_r) ? 1'b1 : 1'b0;

// DATA IN/OUT HANDLING
assign data_out = fifo_r[rd_pointer_r[POINTER_WIDTH-1:0]];

always @(posedge clk)
begin: FIFO_R_PROC
  if (push) begin
    fifo_r[wr_pointer_r[POINTER_WIDTH-1:0]] <= data_in;
  end
end

// POINTER LOGIC
always @(posedge clk or negedge rst_n)
begin: RD_POINTER_R_PROC
  if (!rst_n) begin
    rd_pointer_r <= {POINTER_WIDTH+1{1'b0}};
  end
  else if (!empty && pop) begin
    rd_pointer_r <= rd_pointer_r+1'b1;
  end
end

always @(posedge clk or negedge rst_n)
begin: WR_POINTER_R_PROC
  if (!rst_n) begin
    wr_pointer_r <= {POINTER_WIDTH+1{1'b0}};
  end
  else begin
    if (flush) begin
      // discard pkt with bad CRC, go back to prev
      wr_pointer_r <= wr_pointer_prev_r;
    end
    else if (!full && push) begin
      wr_pointer_r <= wr_pointer_r+1'b1;
    end
  end
end

always @(posedge clk or negedge rst_n)
begin: WR_POINTER_PREV_R_PROC
  if (!rst_n) begin
    wr_pointer_prev_r <= {POINTER_WIDTH+1{1'b0}};
  end
  else if (pkt_start) begin
    wr_pointer_prev_r <= wr_pointer_r;
  end
end

// FIFO LEVEL
always @(posedge clk or negedge rst_n)
begin: LEVEL_R_PROC
  if (!rst_n) begin
    level_r <= {POINTER_WIDTH{1'b0}};
  end
  else begin
    if (push && !pop) begin
      level_r <= level_r+1'b1;
    end
    else if (pop && !push) begin
      level_r <= level_r-1'b1;
    end
  end
end

endmodule