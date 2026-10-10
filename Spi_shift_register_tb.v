`timescale 1ns/1ps

module spi_shift_register_tb();

reg PCLK;
reg PRESET_n;
reg ss_i;
reg send_data_i;
reg receive_data_i;
reg lsbfe_i;
reg cpha_i;
reg cpol_i;
reg miso_receive_sclk_i;
reg miso_receive_sclk0_i;
reg mosi_send_sclk_i;
reg mosi_send_sclk0_i;
reg [7:0] data_mosi_i;
reg miso_i;

wire [7:0] data_miso_o;
wire mosi_o;

// ---------------- DUT ----------------
spi_shift_register DUT (
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .ss_i(ss_i),
    .send_data_i(send_data_i),
    .receive_data_i(receive_data_i),
    .lsbfe_i(lsbfe_i),
    .cpha_i(cpha_i),
    .cpol_i(cpol_i),
    .miso_receive_sclk_i(miso_receive_sclk_i),
    .miso_receive_sclk0_i(miso_receive_sclk0_i),
    .mosi_send_sclk_i(mosi_send_sclk_i),
    .mosi_send_sclk0_i(mosi_send_sclk0_i),
    .data_mosi_i(data_mosi_i),
    .miso_i(miso_i),
    .data_miso_o(data_miso_o),
    .mosi_o(mosi_o)
);

// ---------------- CLOCK ----------------
initial begin
    PCLK = 1'b0;
    forever #10 PCLK = ~PCLK;
end

// ---------------- INITIALIZE TASK ----------------
task initialize;
begin
    PRESET_n = 1'b0;
    ss_i = 1'b1;
    send_data_i = 1'b0;
    receive_data_i = 1'b0;
    lsbfe_i = 1'b1;   // LSB first
    cpol_i = 1'b0;
    cpha_i = 1'b0;
    data_mosi_i = 8'h00;
    miso_i = 1'b0;
    mosi_send_sclk_i = 1'b0;
    mosi_send_sclk0_i = 1'b0;
    miso_receive_sclk_i = 1'b0;
    miso_receive_sclk0_i = 1'b0;
end
endtask

// ---------------- RESET TASK ----------------
task reset;
begin
    PRESET_n = 1'b0;
    #40;
    PRESET_n = 1'b1;
end
endtask

// ---------------- VALUES TASK ----------------
task values;
integer k;
begin
    ss_i = 1'b0;

    // -------- MOSI TRANSMIT --------
    send_data_i = 1'b1;
    data_mosi_i = 8'hA5;

    for (k = 0; k < 8; k = k + 1) begin
        #20 mosi_send_sclk_i = 1'b1;
        #20 mosi_send_sclk_i = 1'b0;
    end
    send_data_i = 1'b0;

    // -------- MISO RECEIVE --------
    receive_data_i = 1'b1;

    // 8'h3C = 0011_1100 (LSB first)
    miso_i = 0; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 0; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 1; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 1; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 1; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 1; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 0; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;
    miso_i = 0; #20 miso_receive_sclk_i = 1; #20 miso_receive_sclk_i = 0;

    receive_data_i = 1'b0;
end
endtask

// ---------------- TEST SEQUENCE ----------------
initial begin
    initialize;
    reset;

    #10;
    @(negedge PCLK);
    #300;

    @(negedge PCLK);
    values;

    #300;
    ss_i = 1'b1;

    #1000 $finish;
end

endmodule
