`timescale 1ns/1ps

`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module spi_APB_Slave_Interface(
    input PCLK,
    input PRESET_n,
    input [2:0] PADDR_i,
    input PWRITE_i,
    input PSEL_i,
    input PENABLE_i,
    input [7:0] PWDATA_i,
    input ss_i,
    input [7:0] miso_data_i,
    input receive_data_i,
    input tip_i,

    output reg [7:0] PRDATA_o,
    output mstr_o,
    output cpol_o,
    output cpha_o,
    output lsbfe_o,
    output spiswai_o,
    output [2:0] sppr_o,
    output [2:0] spr_o,
    output reg spi_interrupt_request_o,
    output PREADY_o,
    output PSLVERR_o,
    output reg send_data_o,
    output reg [7:0] mosi_data_o,
    output reg [1:0] spi_mode_o
);

    // Internal Configuration Registers
    reg [7:0] SPI_BR;
    reg [7:0] SPI_CR1;
    reg [7:0] SPI_CR2;
    reg [7:0] SPI_DR;

    // Read/Write Enable Internal Control Wires
    wire wr_enb;
    wire rd_enb;

    // FSM State Variables
    reg [1:0] next_mode;
    reg [1:0] STATE, next_state;

    // Internal Protocol Status Flags
    wire sptef;
    wire spif;
    wire spe;
    wire modfen;
    wire modf;
    wire ssoe;
    wire spie;
    wire sptie;

    // Register Bitmasks
    parameter cr2_mask = 8'b0001_1011;
    parameter br_mask  = 8'b0111_0111;

    // SPI Operating Modes
    parameter spi_run  = 2'b00;
    parameter spi_wait = 2'b01;
    parameter spi_stop = 2'b10;

    // APB Bus Bridge States
    parameter IDLE   = 2'b00;
    parameter SETUP  = 2'b01;
    parameter ENABLE = 2'b10;

    // =================================================================
    // ? FIXED: Correct Register Bit Slice Mapping
    // =================================================================
    assign ssoe      = SPI_CR1[1];
    assign mstr_o    = SPI_CR2[4];
    assign spe       = SPI_CR1[6];
    assign spie      = SPI_CR1[7];
    assign cpol_o    = SPI_CR1[5];
    assign cpha_o    = SPI_CR1[3];
    assign lsbfe_o   = SPI_CR1[0];
    assign modfen    = SPI_CR2[4];
    assign spiswai_o = SPI_CR2[1];
    assign sppr_o    = SPI_BR[6:4];
    assign spr_o     = SPI_BR[2:0];

    // APB Protocol Execution Controls
    assign wr_enb    = PSEL_i && PENABLE_i && PWRITE_i;  // Active only during ENABLE phase
    assign rd_enb    = PSEL_i && PENABLE_i && !PWRITE_i; // Active only during ENABLE phase
    assign PREADY_o  = (STATE == ENABLE) ? 1'b1 : 1'b0;
    assign PSLVERR_o = (STATE == ENABLE) ? tip_i : 1'b0;

    // Clean Continuous Assignment for Status Register (Eliminated Latches)
    wire [7:0] SPI_SR;
    assign SPI_SR = (~PRESET_n) ? 8'b00100000 : {spif, 1'b0, sptef, modf, 4'b0};
    
    assign sptef = (SPI_DR == 8'b0) ? 1'b1 : 1'b0;
    assign spif  = (SPI_DR != 8'b0) ? 1'b1 : 1'b0;
    assign modf  = (!ss_i && mstr_o && modfen && (!ssoe));
    assign sptie = 1'b0; // Default tie-off for transmit buffer empty interrupt

    // SPI Operational Mode FSM Clocking
    always @(posedge PCLK or negedge PRESET_n) begin
        if(!PRESET_n)
            spi_mode_o <= spi_run;
        else
            spi_mode_o <= next_mode;
    end

    // SPI Operational Mode Next State Combinational Logic
    always @(*) begin
        case(spi_mode_o)
            spi_run: begin
                if(!spe)           next_mode = spi_wait;
                else               next_mode = spi_run;
            end
            spi_wait: begin
                if(spe)            next_mode = spi_run;
                else if(spiswai_o) next_mode = spi_stop;
                else               next_mode = spi_wait;
            end
            spi_stop: begin
                if(spe)             next_mode = spi_run;
                else if(!spiswai_o) next_mode = spi_wait;
                else                next_mode = spi_stop;
            end
            default: next_mode = spi_run;
        endcase
    end

    // APB Bus FSM Clocking
    always @(posedge PCLK or negedge PRESET_n) begin
        if(!PRESET_n)
            STATE <= IDLE;
        else
            STATE <= next_state;
    end

    // APB Bus Next State Combinational Logic
    always @(*) begin
        next_state = STATE;
        case (STATE)
            IDLE: begin
                if (PSEL_i && !PENABLE_i) next_state = SETUP;
            end
            SETUP: begin
                if (PSEL_i && PENABLE_i)  next_state = ENABLE;
            end
            ENABLE: begin
                if (!PSEL_i)              next_state = IDLE;
                else                      next_state = SETUP;
            end
            default:                      next_state = IDLE;
        endcase
    end

    // =================================================================
    // ? FIXED: Unified Register & Transmit Control Execution Matrix
    // =================================================================
    always @(posedge PCLK or negedge PRESET_n) begin
        if(!PRESET_n) begin
            SPI_CR1     <= 8'h04;
            SPI_CR2     <= 8'h00;
            SPI_BR      <= 8'h00;
            send_data_o <= 1'b0;
            mosi_data_o <= 8'h00;
        end else begin
            // Default Assignment: Enforces send_data_o clears automatically next cycle
            send_data_o <= 1'b0; 
            
            if(wr_enb) begin
                case(PADDR_i)
                    3'b000: SPI_CR1 <= PWDATA_i;
                    3'b001: SPI_CR2 <= PWDATA_i & cr2_mask;
                    3'b010: SPI_BR  <= PWDATA_i & br_mask;
                    3'b101: begin
                        send_data_o <= 1'b1;       // Generates a synchronous, race-free pulse
                        mosi_data_o <= PWDATA_i;   // Securely captures the transaction data
                    end
                endcase
            end
        end
    end

    // SPI Data Register (SPI_DR) Read/Write Priority Logic
    always @(posedge PCLK or negedge PRESET_n) begin
        if(!PRESET_n)
            SPI_DR <= 8'h00;
        else if(wr_enb && (PADDR_i == 3'b101))
            SPI_DR <= PWDATA_i; // Active APB write update takes precedence
        else if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && receive_data_i)
            SPI_DR <= miso_data_i; // Latch incoming data shifted from serial MISO line
    end

    // Interrupt Request Evaluation Block
    always @(*) begin
        if(!spie && !sptie)
            spi_interrupt_request_o = 1'b0;
        else if(!sptie && spie)
            spi_interrupt_request_o = spif | modf;
        else if(!spie && sptie)
            spi_interrupt_request_o = sptef;
        else
            spi_interrupt_request_o = spif | modf | sptef;
    end

    // APB Bus Read Route Address Multiplexer
    always @(*) begin
        if(rd_enb) begin
            case(PADDR_i)
                3'b000:  PRDATA_o = SPI_CR1;
                3'b001:  PRDATA_o = SPI_CR2;
                3'b010:  PRDATA_o = SPI_BR;
                3'b011:  PRDATA_o = SPI_SR;
                3'b101:  PRDATA_o = SPI_DR;
                default: PRDATA_o = 8'h00;
            endcase
        end else begin
            PRDATA_o = 8'h00;
        end
    end

endmodule
