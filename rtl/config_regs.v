// -------------------------------------------------------------
// Module: config_regs.v
// Author: PWI
// Release: 1.0, Jan 2019
// -------------------------------------------------------------

module config_regs #(
  parameter CH0_REG_ADDR = 2'h0,
  parameter CH1_REG_ADDR = 2'h1,
  parameter CH2_REG_ADDR = 2'h2,
  parameter CRC_EN_REG_ADDR = 2'h3
)
(
  input       clk,
  input       rst_n,
  input [1:0] config_addr,
  input [1:0] config_data,
  input       config_en,
  output      ch0_addr,
  output      ch1_addr,
  output      ch2_addr,
  output      crc_en
);

  //Registers
  reg   [1:0] ch0_addr_r;
  reg   [1:0] ch1_addr_r;
  reg   [1:0] ch2_addr_r;
  reg         crc_en_r;

  //Output connections
  assign ch0_addr = ch0_addr_r;
  assign ch1_addr = ch1_addr_r;
  assign ch2_addr = ch2_addr_r;
  assign crc_en = crc_en_r;

  //********** FUNCTIONAL PART **********
  always @(posedge clk or negedge rst_n)
  begin: ch_addr_reg_proc
    if (!rst_n) begin
      {ch2_addr_r, ch1_addr_r, ch0_addr_r} <= 6'd0;
    end
    else if (config_en) begin
      if (config_addr == CH0_REG_ADDR)
        ch0_addr_r <= config_data;
      if (config_addr == CH1_REG_ADDR)
        ch1_addr_r <= config_data;
      if (config_addr == CH2_REG_ADDR)
        ch2_addr_r <= config_data;
    end
  end

  always @(posedge clk or negedge rst_n)
  begin: crc_en_reg_proc
    if (!rst_n)
      crc_en_r <= 1'b0;
    else if (config_en) begin
      if (config_addr == CRC_EN_REG_ADDR)
        crc_en_r <= config_data[0];
    end
  end

endmodule
