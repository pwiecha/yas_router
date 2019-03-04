# yas_router
Yet Another Simple Router - a comprehensive COCOTB verification example of the Verilog RTL simple router model

Initial Specification  

1x3 Router  
1 input channel  
3 output channels  

1 clock clk  
Low input reset rst_n  
Data_in data [7:0]  
Data_in_req data_req  
Data_ack data_ack  
Same for outputs  
Register interface  


Packet format [header / size / data / CRC], header first  
2b header (address)  
6b size (bytes)  
1-63bytes data  
8bit CRC (calculated over everything)  

Bad address or CRC - packet discarded  
Channel addresses configurable via registers  
Multiple channels can have the same address  

Config  
Simple interface for programming (addr, data, enable)  
Each channel has configurable address (1) via registers  
CRC check on / off  

