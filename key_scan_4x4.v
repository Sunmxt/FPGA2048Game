// Hight-bit priority
module encoder_42(
    input [3:0] IN
    , input EN
    , output[1:0] OUT
    , output EOUT
);
    reg[1:0] out;

    always @(IN)
    begin 
        if(IN <= 7)
            out <= 2'b11;
        else if(IN < 12)
            out <= 2'b10;
        else if(IN < 14)
            out <= 2'b01;
        else
            out <= 2'b00;
    end

    assign EOUT = ~{&{IN}} & EN;
    assign OUT = out & {2{EN}};

    
endmodule

module key_scan_4x4(
    input CLK
    , input [3:0] REACT
    , input ASYNC_RST_L
    , output [3:0] SCAN
    , output DET
    , output [3:0] LAST_CODE
);
    reg[3:0] last;
    reg[1:0] sig;
    //reg[3:0] latch_react;
    reg[1:0] latch_sig;

    reg[3:0] scan_sig;
    reg det;
    reg latch_det;

    wire[1:0] encoded;
    wire eout;

    //encoder_42 enc42(latch_react, ASYNC_RST_L, latch_encoded, eout);
    encoder_42 enc42(REACT, ASYNC_RST_L, encoded, eout);

    assign DET = det;
    assign SCAN = scan_sig; 
    assign LAST_CODE = last;

    // Only use for testing
    //initial
    //    begin
    //        last <= 0;
    //        sig <= 0;
    //        latch_react <= 0;
    //        scan_sig <= 0;
    //        det <= 0;
    //    end

    always @(posedge CLK or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L)
        begin
            sig <= 0;
            last <= 0;
            latch_det <= 0;
            //latch_react <= 0;
            //latch_sig <= 0;
        end
        else
            begin
                if({&{REACT}})
                    sig <= sig + 1;
                else
                    last <= {sig, encoded};

                latch_det <= ~(&{REACT});
            end

    end

    // Async buffer.
    //always @(negedge CLK or negedge ASYNC_RST_L)
    //begin
    //    if(!ASYNC_RST_L)
    //        begin
    //            latch_react <= 0;
    //            latch_sig <= 0;
    //        end
    //    else
    //        begin
    //            latch_react <= REACT;
    //            latch_sig <= sig;
    //        end
    //end

    // Combitnation
    always @(negedge CLK) det <= latch_det;

    always @(sig)
    begin
        case(sig)
            3: scan_sig <= 4'b1110;
            2: scan_sig <= 4'b1101;
            1: scan_sig <= 4'b1011;
            0: scan_sig <= 4'b0111;
        endcase
    end

endmodule
