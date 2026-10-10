module APB_SPI_Top(
    input        PCLK,
    input        PRESETn,
    input        PSEL,
    input        PENABLE,
    input        PWRITE,
    input        miso,
    input  [2:0] PADDR,
    input  [7:0] PWDATA,

    output [7:0] PRDATA,
    output       PREADY,
    output       PSLVERR,
    output       sclk,
    output       ss,
    output       mosi,
    output       spi_interrupt_request
);

    // ---------------- Internal Signals ----------------
    wire [2:0] spr;
    wire [2:0] sppr;
    wire [1:0] spi_mode;
    wire [11:0] baudratedivisor;

    wire [7:0] data_mosi;
    wire [7:0] data_miso;

    wire cpol;
    wire cpha;
    wire lsbfe;
    wire spiswai;
    wire send_data;
    wire receive_data;
    wire tip;
    wire mstr_o;

    wire miso_receive_sclk;
    wire miso_receive_sclk0;
    wire mosi_send_sclk;
    wire mosi_send_sclk0;

    // ---------------- SPI Baud Rate Generator ----------------
    SPI_Baud_gen A1 (
        .PCLK(PCLK),
        .PRESET_n(PRESETn),
        .spiswai_i(spiswai),
        .cpol_i(cpol),
        .cpha_i(cpha),
        .ss_i(ss),
        .sppr_i(sppr),
        .spr_i(spr),
        .spi_mode_i(spi_mode),

        .sclk_o(sclk),
        .miso_receive_sclk_o(miso_receive_sclk),
        .miso_receive_sclk0_o(miso_receive_sclk0),
        .mosi_send_sclk_o(mosi_send_sclk),
        .mosi_send_sclk0_o(mosi_send_sclk0),
        .baudratedivisor_o(baudratedivisor)
    );

    // ---------------- SPI Slave Select ----------------
    SPI_Slave_Select B1 (
        .PCLK(PCLK),
        .PRESET_n(PRESETn),
        .send_data_i(send_data),
        .mstr_i(mstr_o),
        .spiswai_i(spiswai),
        .spi_mode_i(spi_mode),        // ✅ FIXED HERE
        .baudratedivisor_i(baudratedivisor),

        .receive_data_o(receive_data),
        .ss_o(ss),
        .tip_o(tip)
    );

    // ---------------- SPI Shift Register ----------------
    spi_shift_register C1 (
        .PCLK(PCLK),
        .PRESET_n(PRESETn),
        .ss_i(ss),
        .send_data_i(send_data),
        .receive_data_i(receive_data),
        .lsbfe_i(lsbfe),
        .cpha_i(cpha),
        .cpol_i(cpol),
        .miso_receive_sclk_i(miso_receive_sclk),
        .miso_receive_sclk0_i(miso_receive_sclk0),
        .mosi_send_sclk_i(mosi_send_sclk),
        .mosi_send_sclk0_i(mosi_send_sclk0),
        .data_mosi_i(data_mosi),
        .miso_i(miso),

        .data_miso_o(data_miso),
        .mosi_o(mosi)
    );

    // ---------------- APB SPI Slave Interface ----------------
    spi_APB_Slave_Interface D1 (
        .PCLK(PCLK),
        .PRESET_n(PRESETn),
        .PADDR_i(PADDR),
        .PWRITE_i(PWRITE),
        .PSEL_i(PSEL),
        .PENABLE_i(PENABLE),
        .PWDATA_i(PWDATA),
        .ss_i(ss),
        .miso_data_i(data_miso),
        .receive_data_i(receive_data),
        .tip_i(tip),

        .PRDATA_o(PRDATA),
        .mstr_o(mstr_o),
        .cpol_o(cpol),
        .cpha_o(cpha),
        .lsbfe_o(lsbfe),
        .spiswai_o(spiswai),
        .sppr_o(sppr),
        .spr_o(spr),
        .spi_interrupt_request_o(spi_interrupt_request),
        .PREADY_o(PREADY),
        .PSLVERR_o(PSLVERR),
        .send_data_o(send_data),
        .mosi_data_o(data_mosi),
        .spi_mode_o(spi_mode)
    );

endmodule
