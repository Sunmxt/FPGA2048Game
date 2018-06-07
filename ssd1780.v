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
    reg restart;
    reg start;
    reg busy;
    wire i2c_busy;
    wire addr_sent;

    assign BUSY = RUNNING & (busy | i2c_busy) & addr_sent;

    i2c_master i2c(CLK, SDA, SCL, i2c_busy, RUNNING, start, 1'b0, addr_sent, ASYNC_RST_L, CMD_DAT, 8'h78);

    always @(negedge CLK or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L)
        begin
            restart <= 0;
            start <= 0;
            busy <= 0;
        end
        else
            start <= START;
    end

endmodule

