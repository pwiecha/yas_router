// ------------------------------------------------------------
// Module: fifo_synch_fs.v
// Author: PWI
// Release: 1.0, Mar 2019
// Synchronous fifo with flush of arbitrary size and level
// ------------------------------------------------------------

module fifo
#(
  parameter DATA_WIDTH = 8,
  parameter POINTER_WIDTH = 6
)
(
  input                      clk,
  input                      rst_n,
  input  [DATA_WIDTH-1:0]    data_in,
  //input                      flush,
  //input  [POINTER_WIDTH-1:0] flush_size,
  input                      push,
  output                     pop,
  output [DATA_WIDTH-1:0]    data_out,
  output                     full,
  output                     empty
);

localparam FIFO_DEPTH = 1 << POINTER_WIDTH; //64 cells

reg [DATA_WIDTH-1:0]  fifo_r [FIFO_DEPTH-1:0];
reg [POINTER_WIDTH:0] rd_pointer_r; //+wrap indicator bit
reg [POINTER_WIDTH:0] wr_pointer_r; //+wrap indicator bit
wire                  full_bit;

// STATEUS FLAGS
assign full_bit = wr_pointer_r[POINTER_WIDTH] ^ rd_pointer_r[POINTER_WIDTH];
assign full = full_bit && (wr_pointer_r[POINTER_WIDTH-1:0] == rd_pointer_r[POINTER_WIDTH-1:0]);
assign empty = (wr_pointer_r == rd_pointer_r) ? 1'b1 : 1'b0;

// DATA IN/OUT HANDLING
assign data_out = fifo_r[rd_pointer_r[POINTER_WIDTH-1:0]];

always @(posedge clk or negedge rst_n)
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
  else if (!full && push) begin
    wr_pointer_r <= wr_pointer_r+1'b1;
  end
end

endmodule
