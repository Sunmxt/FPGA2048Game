`timescale 10ns/1ns

module test_ssd1780;

    reg clk;
    reg rst;
    reg[7:0] dat;
    reg start;
    reg write_sda;
    reg sda;

    wire busy;
    wire running;
    wire scl;
    wire sda_io;

    assign sda_io = write_sda ? sda : 1'bz;

    ssd1780 uut(clk, dat, sda_io, scl, start, rst, busy, running);

    initial
    begin
        rst = 0;
        start = 0;
        dat = 0; 
        write_sda = 0;
        clk = 0;

        $dumpfile("ssd1780.vcd");
        $dumpvars(2, uut);
    end

    always
    begin
        #10 rst <= 1;
        #10 write_sda = 0;
        #10 start <= 1;
        #10 dat <= 8'h20;
        #50 sda <= 0; write_sda <= 1;
        #2 write_sda = 0;
        #52 write_sda = 1;
        #2 write_sda = 0;
        #52 write_sda = 1;
        #2 write_sda = 0;
        #20 start <= 0;
        #50;
        $finish;
    end

    always #1 clk = ~clk;
endmodule
