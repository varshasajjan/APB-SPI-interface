module spi_shift_register(
input PCLK,
input PRESET_n,
input ss_i,
input send_data_i,
input receive_data_i,
input lsbfe_i,
input cpha_i,
input cpol_i,
input miso_receive_sclk_i,
input miso_receive_sclk0_i,
input mosi_send_sclk_i,
input mosi_send_sclk0_i,
input [7:0] data_mosi_i,
input miso_i,
output [7:0] data_miso_o,
output reg mosi_o);

//internal regsiter
reg [7:0] shift_reg;
reg [7:0] temp_reg;
reg [2:0] count,count1;
reg [2:0] count2,count3;

//updating DATA_MISO
assign data_miso_o=receive_data_i?temp_reg:8'h00;

//updating shift_register_signal 
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
shift_reg<=8'h00;
else if(send_data_i)
shift_reg<=data_mosi_i;
else
shift_reg<=shift_reg;
end

//---------MOSI TRANSMIT SHIFT REGISTER--------//
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
mosi_o<=1'b0;
count<=3'd0;
count1<=3'd7;
end
else
begin
if(!ss_i)
begin
if((!cpha_i && cpol_i)||(cpha_i && !cpol_i))//negedge clk
begin
if(lsbfe_i)
begin
if(count<=3'd7)
begin
if(mosi_send_sclk_i)
begin
mosi_o<=shift_reg[count];
count<=count+1'b1;
end
end
else
count<=3'd0;
end
else
begin
if(count1>=3'd0)
begin
if(mosi_send_sclk0_i)
begin
mosi_o<=shift_reg[count1];
count1<=count1-1'b1;
end
end
else
count1<=3'd7;
end
end
else//posegde clk
begin
if(lsbfe_i)
begin
if(count<=3'd7)
begin
if(mosi_send_sclk_i)
begin
mosi_o<=shift_reg[count];
count<=count+1'b1;
end
end
else
count<=3'd0;
end
else
begin
if(count1>=3'd0)
begin
if(mosi_send_sclk_i)
begin
mosi_o<=shift_reg[count1];
count1<=count1-1'b1;
end
end
else
count1<=3'd7;
end
end
end
end
end

// -------------------- MISO RECEIVE SHIFT REGISTER --------------------
always @(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
    begin
        temp_reg <= 8'h00;
        count2   <= 3'd0;
        count3   <= 3'd7;
    end
    else
    begin
        if(!ss_i && receive_data_i)
        begin
            // CPOL / CPHA based receive edge
            if((!cpha_i && cpol_i) || (cpha_i && !cpol_i)) // negedge receive
            begin
                if(lsbfe_i)
                begin
                    if(count2 <= 3'd7)
                    begin
                        if(miso_receive_sclk_i)
                        begin
                            temp_reg[count2] <= miso_i;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else
                        count2 <= 3'd0;
                end
                else
                begin
                    if(count3 >= 3'd0)
                    begin
                        if(miso_receive_sclk0_i)
                        begin
                            temp_reg[count3] <= miso_i;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else
                        count3 <= 3'd7;
                end
            end
            else // posedge receive
            begin
                if(lsbfe_i)
                begin
                    if(count2 <= 3'd7)
                    begin
                        if(miso_receive_sclk_i)
                        begin
                            temp_reg[count2] <= miso_i;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else
                        count2 <= 3'd0;
                end
                else
                begin
                    if(count3 >= 3'd0)
                    begin
                        if(miso_receive_sclk_i)
                        begin
                            temp_reg[count3] <= miso_i;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else
                        count3 <= 3'd7;
                end
            end
        end
    end
end
endmodule
