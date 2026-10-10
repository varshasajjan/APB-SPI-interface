`timescale 1ns/1ps


module SPI_Baud_generator_tb();
reg PCLK;
reg PRESET_n;
reg spiswai_i;
reg cpol_i;
reg cpha_i;
reg ss_i;
reg [2:0] sppr_i;
reg [2:0] spr_i;
reg [1:0] spi_mode_i;

wire sclk_o;
wire miso_receive_sclk_o;
wire miso_receive_sclk0_o;
wire mosi_send_sclk_o;
wire mosi_send_sclk0_o;
wire [11:0] baudratedivisor_o;

SPI_Baud_gen DUT(PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i,sppr_i,spr_i,spi_mode_i,sclk_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,baudratedivisor_o);

initial
begin
PCLK=1'b0;
forever #10 PCLK = ~PCLK;
end

task initialize;
begin
spiswai_i = 1'b0;
sppr_i    = 3'b000;
spr_i     = 3'b000;
cpol_i    = 1'b0;
cpha_i    = 1'b0;
ss_i      = 1'b1;
spi_mode_i= 1'b0;
end
endtask

task reset;
begin
PRESET_n=1'b0;
#20;
PRESET_n=1'b1;
end
endtask

task values;
input j;
input i;
begin
spi_mode_i  = 2'b01;
spiswai_i   = 1'b0;
sppr_i      = 3'b000;
spr_i       = 3'b010;
cpol_i      = j;
cpha_i      = i;
ss_i        = 1'b0;
end
endtask

initial
begin
initialize;
reset;
#10;
@(negedge PCLK)
#300;
@(negedge PCLK)
values(1'b1,1'b1);
#300;

#1000 $finish;
end
endmodule

