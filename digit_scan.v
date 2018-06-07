module digit_scan_decoder38(
    input [2:0] DIG
    , output [7:0] OUT
);
    reg[7:0] decoded;

    always @(DIG)
    begin
        case(DIG)
            0: decoded <= 8'b00000001;
            1: decoded <= 8'b00000010;
            2: decoded <= 8'b00000100;
            3: decoded <= 8'b00001000;
            4: decoded <= 8'b00010000;
            5: decoded <= 8'b00100000;
            6: decoded <= 8'b01000000;
            7: decoded <= 8'b10000000;
        endcase
    end

    assign OUT = decoded;
endmodule

module digit_scan6(
    input CLK
    , input ASYNC_RST_L
    , input OEN
    , input DIS_STATE
    , input [23:0] DIG
    , input [5:0] SEG_OEN
    , output[5:0] SEG_SEL
    , output[6:0] SEG_CODE
);
    reg[2:0] scan_cnt;
    reg[3:0] selected;

    wire[7:0] decoded;
    wire[6:0] seg_out;

    wire seg_oen;
    wire out_enabled;

    assign seg_oen = {&{decoded[5:0] & SEG_OEN}};

    //Output
    assign out_enabled = |{SEG_OEN & decoded[5:0]} & OEN;
    assign SEG_CODE = (seg_out & {7{out_enabled}}) ^ {7{DIS_STATE}};
    assign SEG_SEL = decoded[5:0];
    

    digit_scan_decoder38 dec38(scan_cnt, decoded);
    seg7_decoder seg_dec(OEN, 1'b0, selected, seg_out);

    // clock
    always @(posedge CLK or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L)
            scan_cnt <= 0;
        else
            scan_cnt <= scan_cnt + 1;                                
    end

    // digit select
    always @(decoded or DIG)
    begin
        if(decoded[0])
            selected <= DIG[3:0];
        else if(decoded[1])
            selected <= DIG[7:4];
        else if(decoded[2])
            selected <= DIG[11:8];
        else if(decoded[3])
            selected <= DIG[15:12];
        else if(decoded[4])
            selected <= DIG[19:16];
        else if(decoded[5])
            selected <= DIG[23:20];
        else
            selected <= 0;
    end

endmodule

