`timescale 1ns / 1ps

module random(
    input               rst_n,    
    input               clk,       
    output reg [7:0]    rand_num 
);
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            rand_num    <=8'b10111001;
        else
            begin
                rand_num[0] <= rand_num[7];
                rand_num[1] <= rand_num[0];
                rand_num[2] <= rand_num[1];
                rand_num[3] <= rand_num[2];
                rand_num[4] <= rand_num[3]^rand_num[7];
                rand_num[5] <= rand_num[4]^rand_num[7];
                rand_num[6] <= rand_num[5]^rand_num[7];
                rand_num[7] <= rand_num[6];
            end
    end

endmodule
