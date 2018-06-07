`timescale 1ns / 1ps

module test_random;
    reg clk=0;
    reg rst=1;
    reg [7:0]count=0;
    wire [7:0]data;

    random uut(rst,clk,data); 

    initial
    begin
        $dumpfile("random.vcd");
        $dumpvars(1, uut);
        rst = 0;
    end

    always #10 clk=~clk;

    always #20 rst = 1;

    always @(posedge clk)
    begin
        if(count==8'b00001111)
        begin
            count=0;
           // rst=0;
        end
        else
        begin
            count=count+1'b1;
            rst=1;
        end
     end

    always #300 $finish;
    
endmodule
