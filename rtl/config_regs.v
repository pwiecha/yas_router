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
// Module: config_regs.v
// Author: PWI
// Release: 1.0, Jan 2019
// ------------------------------------------------------------

module config_regs
#(
  parameter CH0_REG_ADDR = 2'h0,
  parameter CH1_REG_ADDR = 2'h1,
  parameter CH2_REG_ADDR = 2'h2,
  parameter CRC_EN_REG_ADDR = 2'h3
)
(
  input        clk,
  input        rst_n,
  input  [1:0] config_addr,
  input  [1:0] config_data,
  input        config_en,
  output [1:0] ch0_addr,
  output [1:0] ch1_addr,
  output [1:0] ch2_addr,
  output       crc_en
);

  // Registers
  reg   [1:0] ch0_addr_r;
  reg   [1:0] ch1_addr_r;
  reg   [1:0] ch2_addr_r;
  reg         crc_en_r;

  // Output connections
  assign ch0_addr = ch0_addr_r;
  assign ch1_addr = ch1_addr_r;
  assign ch2_addr = ch2_addr_r;
  assign crc_en = crc_en_r;

  //********** FUNCTIONAL PART **********
  always @(posedge clk or negedge rst_n)
  begin: ch_addr_r_proc
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
  begin: crc_en_r_proc
    if (!rst_n)
      crc_en_r <= 1'b0;
    else if (config_en) begin
      if (config_addr == CRC_EN_REG_ADDR)
        crc_en_r <= config_data[0];
    end
  end

endmodule
