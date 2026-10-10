module SPI_Slave_Select(
input PCLK,
input PRESET_n,
input send_data_i,
input mstr_i,
input spiswai_i,
input [1:0]spi_mode_i,
input [11:0]baudratedivisor_i,

output reg receive_data_o,
output reg ss_o,
output tip_o);

reg [15:0]count_s;//to track the baud based timing
wire [15:0]target_s;
reg rcv_s;//receive indicator

assign target_s=16*(baudratedivisor_i/2);//8 pulses totally 16 edges
assign tip_o=~ss_o;//Transfer in progress

//generating receive data signal
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
receive_data_o<=1'b0;
else
receive_data_o<=rcv_s;
end

//to control ss_o,counter,rcv-s
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
count_s<=16'hffff;
ss_o<=1'b1;
rcv_s<=1'b0;
end
else if(mstr_i &&(spi_mode_i==2'b00||spi_mode_i==2'b01)&& !spiswai_i)
begin
if(send_data_i)
begin
ss_o<=1'b0;
count_s<=16'b0;
end
else if(count_s<=target_s-1'b1)
begin
ss_o<=1'b0;
count_s<=count_s+1'b1;
if(count_s==target_s-1'b1)
rcv_s<=1'b1;
end
else
begin
ss_o<=1'b1;
rcv_s<=1'b0;
count_s<=16'hffff;
end
end
else
begin
ss_o<=1'b1;
rcv_s<=1'b0;
count_s<=16'hffff;
end
end
endmodule
