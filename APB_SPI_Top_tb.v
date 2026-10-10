`timescale 1ns/1ps

module APB_SPI_Top_TB;

    // ---------------- TB Signals ----------------
    reg         PCLK;
    reg         PRESETn;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg         miso;
    reg  [2:0]  PADDR;
    reg  [7:0]  PWDATA;

    wire [7:0]  PRDATA;
    wire        PREADY;
    wire        PSLVERR;
    wire        sclk;
    wire        ss;
    wire        mosi;
    wire        spi_interrupt_request;

    integer i;   // required integer variable

    // ---------------- DUT ----------------
    APB_SPI_Top DUT (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .miso(miso),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .spi_interrupt_request(spi_interrupt_request)
    );

    // ---------------- Clock ----------------
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;   // 100 MHz
    end

    // ---------------- APB WRITE TASK ----------------
    task apb_write(input [2:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
        PSEL    = 1'b1;
        PWRITE  = 1'b1;
        PADDR   = addr;
        PWDATA  = data;
        PENABLE = 1'b0;

        @(posedge PCLK);
        PENABLE = 1'b1;

        @(posedge PCLK);
        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
    end
    endtask

    // ---------------- APB READ TASK ----------------
    task apb_read(input [2:0] addr);
    begin
        @(posedge PCLK);
        PSEL    = 1'b1;
        PWRITE  = 1'b0;
        PADDR   = addr;
        PENABLE = 1'b0;

        @(posedge PCLK);
        PENABLE = 1'b1;

        @(posedge PCLK);
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    end
    endtask

    // ---------------- MISO MODEL ----------------
    always @(negedge sclk) begin
        if (!ss)
            miso <= $random;
    end

    // ---------------- TEST SEQUENCE ----------------
    initial begin
        // Init
        PRESETn = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PADDR   = 0;
        PWDATA  = 0;
        miso    = 0;

        // Reset
        #20;
        PRESETn = 1;

        // -------- SPI CONFIGURATION --------
        // SPI_CR1: SPE=1, LSBFE=1, CPOL=0, CPHA=0
        apb_write(3'b000, 8'b0100_0001);

        // SPI_CR2: MSTR=1
        apb_write(3'b001, 8'b0001_0000);

        // SPI_BR: baud rate
        apb_write(3'b010, 8'b0010_0010);

        // -------- SEND DATA --------
        apb_write(3'b101, 8'hA5);

        // wait for SPI transfer
        #600;

        // -------- READ RECEIVED DATA --------
        apb_read(3'b101);

        #300;
        $stop;
    end

endmodule
