module ssd1780(
    input CLK
    , input[7:0] CMD_DAT
    , inout SDA
    , output SCL
    , input START
    , input ASYNC_RST_L
    , output BUSY
    , output RUNNING
    
);
    reg start;
    reg[1:0] busy_mask;
    wire i2c_busy;
    wire addr_sent;

    assign BUSY = RUNNING & (i2c_busy | ~busy_mask[1]);

    i2c_master i2c(CLK, SDA, SCL, i2c_busy, RUNNING, START, 1'b0, addr_sent, ASYNC_RST_L, CMD_DAT, 8'h78);

    always @(negedge CLK or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L)
        begin
            start <= 0;
            busy_mask <= 0;
        end
        else
        begin
            start <= START;
            if(RUNNING)
            begin
                if(!i2c_busy && !busy_mask[1])
                    busy_mask <= busy_mask + 1'b1;
            end
            else
            begin
                if(!start && START)
                    busy_mask <= 0;
            end
        end
    end

endmodule

