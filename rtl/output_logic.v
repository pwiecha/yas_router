module output_logic
(
  input clk,
  input rst_n,
  // INPUT IF
  input fifo_empty,
  output fifo_pop,
  // OUTPUT IF
  output data_out_req,
  input  data_out_ack
);

  reg data_out_req_r;
  reg fifo_pop_r;

  assign data_out_req = data_out_req_r;
  assign fifo_pop = fifo_pop_r;

  always @(posedge clk or negedge rst_n)
  begin: data_drive_logic_r_proc
    if (!rst_n) begin
      fifo_pop_r <= 1'b0;
      data_out_req_r <= 1'b0;
    end
    else begin:
      if (!fifo_empty && !data_out_req_r) begin
        data_out_req_r <= 1'b1;
      end
      else if (data_out_req_r && data_out_ack && fifo_empty) begin
        data_out_req_r <= 1'b0;
      end
      if (data_out_req_r && data_out_ack && !fifo_empty) begin
        fifo_pop_r <= 1'b1;
      end
      else begin
        fifo_pop_r <= 1'b0;
      end
    end
  end

endmodule
