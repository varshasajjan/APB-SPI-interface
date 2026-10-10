`timescale 1ns/1ps


module spi_slave_select_tb();
reg PCLK;
reg PRESET_n;
reg mstr_i;
reg send_data_i;
reg spiswai_i;
reg [1:0]spi_mode_i;
reg [11:0]baudratedivisor_i;
wire ss_o;
wire tip_o;
wire receive_data_o;

SPI_Slave_Select dut(PCLK,PRESET_n,send_data_i,mstr_i,spiswai_i,spi_mode_i,baudratedivisor_i,receive_data_o,ss_o,tip_o);
initial
begin
PCLK=0;
forever #5 PCLK=~PCLK;
end

task resetn;
begin
#5;
PRESET_n=0;
#10;
PRESET_n=1;
end
endtask

task initialize;
begin
{mstr_i,spiswai_i,send_data_i,baudratedivisor_i,spi_mode_i}=0;
end
endtask

task stimulus;
begin
@(negedge PCLK)
spiswai_i=0;
send_data_i=1'b1;
mstr_i=1'b1;
spi_mode_i=2'b00;
#20;
@(negedge PCLK)
send_data_i=0;
end
endtask

initial
begin
initialize;
resetn;
baudratedivisor_i=4;
stimulus;
end

initial #1000 $finish;
endmodule
