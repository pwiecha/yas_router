// ------------------------------------------------------------
// Module: fifo_synch.v
// Author: PWI
// Release: 1.0, Mar 2019
// Synchronous fifo with flush (discard pkt with bad CRC)
// and fifo level indicator
// ------------------------------------------------------------

module fifo_synch
#(
  parameter DATA_WD = 8,
  parameter PTR_WD = 6
)
(
  input clk,
  input rst_n,
  input [DATA_WD-1:0] data_in,
  input wr_ptr_upd, // update pointer - pkt correct
  input flush, // rewind to stored pointer - pkt incorrect
  output [PTR_WD-1:0] level, // how many fifo cells are not yet popped
  input push,
  output pop,
  output [DATA_WD-1:0] data_out,
  output full,
  output empty
);

localparam FIFO_DEPTH = 1 << PTR_WD; //2^6=64 cells

reg [DATA_WD-1:0] fifo_r [FIFO_DEPTH-1:0];
reg [PTR_WD:0] rd_ptr_r; //+wrap indicator bit
reg [PTR_WD:0] wr_ptr_r; //+wrap indicator bit
reg [PTR_WD:0] wr_ptr_new_r; //+wrap indicator bit, used for new pkt coming ti FIFO
reg [PTR_WD-1:0] level_r;
wire full_bit;

assign level = level_r;

// STATUS FLAGS
assign full_bit = wr_ptr_r[PTR_WD] ^ rd_ptr_r[PTR_WD];
assign full = full_bit && (wr_ptr_r[PTR_WD-1:0] == rd_ptr_r[PTR_WD-1:0]);
assign empty = (wr_ptr_r == rd_ptr_r) ? 1'b1 : 1'b0;

// DATA IN/OUT HANDLING
assign data_out = fifo_r[rd_ptr_r[PTR_WD-1:0]];

always @(posedge clk)
begin: FIFO_R_PROC
  if (push) begin
    fifo_r[wr_ptr_new_r[PTR_WD-1:0]] <= data_in;
  end
end

// R/W POINTER LOGIC
always @(posedge clk or negedge rst_n)
begin: RD_POINTER_R_PROC
  if (!rst_n) begin
    rd_ptr_r <= {PTR_WD+1{1'b0}};
  end
  else if (!empty && pop) begin
    rd_ptr_r <= rd_ptr_r+1'b1;
  end
end

/*
  Wr pointer new is used when the new packet is being written to the FIFO
  At the end of the packet, after a couple of writes, either will be issued:
  flush command and new write pointer will be rewind (bad CRC)
  wr_ptr_upd and actual write pointer will be updated with the value of new
  
  Otherwise the actual write pointer (wr_ptr) will be updated
*/
always @(posedge clk or negedge rst_n)
begin: WR_PTR_NEW_R_PROC
  if (!rst_n) begin
    wr_ptr_new_r <= {PTR_WD+1{1'b0}};
  end
  else begin
    if (flush) begin
      wr_ptr_new_r <= wr_ptr_r; // rewind the pointer
    end
    else if (!full && push) begin
      wr_ptr_new_r <= wr_ptr_new_r+1'b1;
    end
  end
end

always @(posedge clk or negedge rst_n)
begin: WR_PTR_R_PROC
  if (!rst_n) begin
    wr_ptr_r <= {PTR_WD+1{1'b0}};
  end
  else if (wr_ptr_upd) begin
    wr_ptr_r <= wr_ptr_new_r;
  end
end

// FIFO LEVEL
always @(posedge clk or negedge rst_n)
begin: LEVEL_R_PROC
  if (!rst_n) begin
    level_r <= {PTR_WD{1'b0}};
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
