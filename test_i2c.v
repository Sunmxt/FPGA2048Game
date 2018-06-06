`timescale 100ns/1ns

module test_i2c_master;
    reg[7:0] dat;
    reg[7:0] addr;
    reg start;
    reg rst;
    reg clk;
    reg sda;
    reg write_sda;
    reg write_dat;

    wire scl;
    wire busy;
    wire running;
    wire sda_io;
    wire[7:0] dat_io;

    i2c_master uut(clk, sda_io, scl, busy, running, start, rst, dat_io, addr);

    assign sda_io = write_sda ? sda : 1'bz;
    assign dat_io = write_dat ? dat : 8'bz;

    initial
    begin
        rst = 0;
        start = 0;
        sda = 1;
        dat = 8'hAA;
        addr = 8'hA0;
        clk = 0;
        write_sda = 0;
        write_dat = 1;

        $dumpfile("i2c.vcd");
        $dumpvars(0, uut);
    end

    always #1 clk<=~clk;

    always
    begin
        #10 rst <= 1;
        #10 write_dat = 1; 
        #10 start <= 1;
        #60 sda <= 0; write_sda = 1;
        #5 write_sda = 0;
        #48 write_sda = 1;
        #5  write_sda = 0;
        #1000;
        $finish;
    end
    
endmodule
