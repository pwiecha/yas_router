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
  input                      wr_ptr_upd, // update the pointer
  input                      flush, // go back to stored ptr
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
reg [POINTER_WIDTH:0]   wr_pointer_new_r; //+wrap indicator bit
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
begin: WR_POINTER_NEW_R_PROC
  if (!rst_n) begin
    wr_pointer_r <= {POINTER_WIDTH+1{1'b0}};
  end
  else begin
    if (flush) begin
      // discard pkt with bad CRC, rewind the pointer
      wr_pointer_new_r <= wr_pointer_r;
    end
    else if (!full && push) begin
      wr_pointer_new_r <= wr_pointer_new_r+1'b1;
    end
  end
end

always @(posedge clk or negedge rst_n)
begin: WR_POINTER_R_PROC
  if (!rst_n) begin
    wr_pointer_r <= {POINTER_WIDTH+1{1'b0}};
  end
  else if (wr_ptr_upd) begin
    wr_pointer_r <= wr_pointer_new_r;
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
