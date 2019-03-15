//-----------------------------------------------------------------------------
// Copyright (C) 2009 OutputLogic.com 
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice 
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//-----------------------------------------------------------------------------
// CRC module for data[7:0] ,   crc[7:0]=1+x^1+x^2+x^3+x^6+x^7+x^8;
// poly taken from https://users.ece.cmu.edu/~koopman/crc/index.html
// should have HD=3 (detect 2b) for packets up to 247b (incl 8 CRC bits), HD=2 (detect 1b) else
// PWI - formatting and switched rst to asynch active low
//-----------------------------------------------------------------------------
module crc8
(
  input        clk,
  input        rst_n,
  input  [7:0] data_in,
  input        crc_en,
  output [7:0] crc_out
);

  reg [7:0] lfsr_r,lfsr_c;

  assign crc_out = lfsr_r;

  always @(*)
  begin: lfsr_comb_proc
    lfsr_c[0] = lfsr_r[0] ^ lfsr_r[1] ^ lfsr_r[3] ^ lfsr_r[4] ^ lfsr_r[5] ^ lfsr_r[7] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7];
    lfsr_c[1] = lfsr_r[0] ^ lfsr_r[2] ^ lfsr_r[3] ^ lfsr_r[6] ^ lfsr_r[7] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_c[2] = lfsr_r[0] ^ lfsr_r[5] ^ data_in[0] ^ data_in[5];
    lfsr_c[3] = lfsr_r[0] ^ lfsr_r[3] ^ lfsr_r[4] ^ lfsr_r[5] ^ lfsr_r[6] ^ lfsr_r[7] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    lfsr_c[4] = lfsr_r[1] ^ lfsr_r[4] ^ lfsr_r[5] ^ lfsr_r[6] ^ lfsr_r[7] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    lfsr_c[5] = lfsr_r[2] ^ lfsr_r[5] ^ lfsr_r[6] ^ lfsr_r[7] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    lfsr_c[6] = lfsr_r[0] ^ lfsr_r[1] ^ lfsr_r[4] ^ lfsr_r[5] ^ lfsr_r[6] ^ data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6];
    lfsr_c[7] = lfsr_r[0] ^ lfsr_r[2] ^ lfsr_r[3] ^ lfsr_r[4] ^ lfsr_r[6] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
  end

  always @(posedge clk or negedge rst_n)
  begin: lfsr_r_proc
    if(!rst_n) begin
      lfsr_r <= {8{1'b1}};
    end
    else begin
      lfsr_r <= crc_en ? lfsr_c : lfsr_r;
    end
  end

endmodule
