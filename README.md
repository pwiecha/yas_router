# yas_router
Yet Another Simple Router - a comprehensive COCOTB verification example of the Verilog RTL simple router model

Initial Specification  

1x3 Router  
1 input channel  
3 output channels  

1 clock clk  
active low async reset rst_n  
Data_in data [7:0]  
Data_in_req data_req  
Data_ack data_ack  
Same IF for output
Minimal Register interface  


Packet format [header / size / data / CRC], header first  
HEADER MSB [HEADER|SIZE] LSB :     
2b (address), 6b payload size (bytes)  

1-63bytes data  (size+1, pkts have a minimum of 1 byte of data, does not include CRC byte)

8bit CRC (calculated over everything)  

Bad address or CRC - packet discarded  
Channel addresses configurable via registers  
Multiple channels can have the same address  

Config  
Simple interface for programming (addr, data, enable)  
Each channel has configurable address (1) via registers  
CRC check on / off  

