module digit_mod(
    input SHIFT
    , input [3:0] NUM
    , output [7:0] ARR
    , input ASYNC_RST_L
    , output reg FINISH
);
    reg [1:0] cnt;
    reg [3:0] num;
    reg [7:0] out;
    reg [3:0] latch;
    reg [1:0] dig_cnt;

    assign NUM = out;

    always @(dig_cnt) FINISH <= ~|{dig_cnt} & ~|{cnt};

    always @(cnt or num) 
    begin
        if(num < 10) 
        begin
            case(cnt)
            0: out <= 0; 
            1:
                case(num)
                    9: out <= 8'h5C;
                    8: out <= 8'h7C;
                    7: out <= 8'h04;
                    6: out <= 8'h7C;
                    5: out <= 8'h5C;
                    4: out <= 8'h1C;
                    3: out <= 8'h54;
                    2: out <= 8'h74;
                    1: out <= 8'h00;
                    0: out <= 8'h7C;
                endcase
            2:
                case(num)
                    9: out <= 8'h54;
                    8: out <= 8'h54;
                    7: out <= 8'h04;
                    6: out <= 8'h54;
                    5: out <= 8'h54;
                    4: out <= 8'h10;
                    3: out <= 8'h54;
                    2: out <= 8'h54;
                    1: out <= 8'h00;
                    0: out <= 8'h44;
                endcase
            3:
                case(num)
                    9: out <= 8'h7C;
                    8: out <= 8'h7C;
                    7: out <= 8'h7C;
                    6: out <= 8'h74;
                    5: out <= 8'h74;
                    4: out <= 8'h7C;
                    3: out <= 8'h7C;
                    2: out <= 8'h5C;
                    1: out <= 8'h7C;
                    0: out <= 8'h7C;
                endcase
            endcase
        end
        else
            out <= 0;
    end

    always @(posedge SHIFT or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L)
        begin
            cnt <= 0;
            num <= 0;
            out <= 0;
            dig_cnt <= 0;
            latch <= 0;
        end
        else
        begin
            cnt <= cnt + 1;
            if(cnt == 0)
            begin
                if(dig_cnt == 0)
                    latch <= NUM;
                dig_cnt <= dig_cnt + 1;

                case(latch)
                0:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 10;
                        3: num <= 1;
                    endcase
                1:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 10;
                        3: num <= 2;
                    endcase
                2:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 10;
                        3: num <= 4;
                    endcase
                3:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 10;
                        3: num <= 8;
                    endcase
                4:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 1;
                        3: num <= 6;
                    endcase
                5:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 3;
                        3: num <= 2;
                    endcase
                6:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 10;
                        2: num <= 6;
                        3: num <= 4;
                    endcase
                7:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 1;
                        2: num <= 2;
                        3: num <= 8;
                    endcase
                8:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 2;
                        2: num <= 5;
                        3: num <= 6;
                    endcase
                9:
                    case(dig_cnt)
                        0: num <= 10;
                        1: num <= 5;
                        2: num <= 1;
                        3: num <= 2;
                    endcase
                10:
                    case(dig_cnt)
                        0: num <= 1;
                        1: num <= 0;
                        2: num <= 2;
                        3: num <= 4;
                    endcase
                11:
                    case(dig_cnt)
                        0: num <= 2;
                        1: num <= 0;
                        2: num <= 4;
                        3: num <= 8;
                    endcase
                endcase
            end
        end
    end

endmodule


module display2048 (
    input CLK
    , input [63:0] NUMS
    , input REFRESH
    , input ASNYC_RST_L
    , output reg BUSY
    , output SCL
    , inout SDA    
);
    reg div;
    reg[7:0] cmd;
    reg[5:0] state;
    reg[9:0] cnt;
    reg[3:0] num;
    reg pos_set;
    reg start;
    reg shift;
    

    wire busy;
    wire running;
    wire[7:0] mod_arr;
    wire mod_finish;

    
    ssd1780 display(div, cmd, SDA, SCL, start, ASNYC_RST_L, busy, running);
    digit_mod digmod(shift, num, mod_arr, ASNYC_RST_L, mod_finish);


    always @(state) BUSY <= state != 0 && state != 15;

    always @(posedge CLK or negedge ASNYC_RST_L)
    begin
        if(!ASNYC_RST_L)
        begin
            cmd <= 0;
            start <= 0;
            state <= 0;
            cnt <= 0;
            div <= 0;
            num <= 0;
            pos_set <= 0;
            shift <= 0;
        end
        else
        begin
            div <= ~div;
            case(state)
            0: begin // reset
                BUSY <= 1;
                cmd <= 0; start <= 1;
                if(busy) state <= 1;
               end
            1: if(!busy) cmd <= 8'haf; state <= 2;
            2: if(busy) start <= 0; state <= 3;
            3: if(!running) state <= 4;
            // Clear 
            4:  // Line start
                if(!running)
                begin
                    start <= 1;
                    if(pos_set)
                    begin
                        cmd <= 8'h40;
                        state <= 7;
                        pos_set <= 0;
                    end
                    else
                    begin // Start sending set-line command
                        cmd <= 8'h00;
                        if(busy) state <= 5;
                        pos_set <= 1;
                    end
                end
            5: if(!busy) 
               begin
                    cmd <= 8'hb0 | {6'b0, cnt[9:7]}; state <= 6;
                    pos_set <= 1;
               end
            6: if(busy) start <= 0 ; state <= 13;
            13: if(!running) 
                begin
                    start <= 1; state <= 14;
                    cmd <= 8'h00;
                end
            14: if(busy) state <= 15;
            15: if(!busy) start <= 0; state <= 16;
            16: if(!running)
                begin
                    start <= 1; state <= 17;
                    cmd <= 8'h00;
                end
            17: if(busy) cmd <= 8'h10; state <= 18;
            18: if(!busy) start <= 0; state <= 4;

            // Burst sending 0 for 128 byte.
            7: 
                if(~&{cnt[6:0]}) 
                begin
                    cmd <= 0;
                    cnt <= cnt + 1;
                    state <= 8;
                end
                else
                    state <= 9;
            8: if(!busy) state <= 7;
            9: if(!busy) // Stop sending 0. next line.
                begin
                    state <= 4;
                    start <= 0;
                    if(~&{cnt[9:7]})
                        cnt <= cnt + 1;
                    else
                    begin
                        cnt <= 0;
                        state <= 10; // Finish clear
                    end
                end
            
            10: if(!running) state <= 11;
            // Ready
            11: 
                if(REFRESH) 
                begin
                    state <= 12;
                    cnt <= 0;
                    BUSY <= 1;
                end
                else
                    BUSY <= 0;
            12: 
                begin
                    // New line
                    start <= 1;
                    if(busy) state <= 19;
                    cmd <= 0;
                end
            19: if(!busy) cmd <= 8'hb0 | {6'b0, cnt[3:2]}; state <= 20;
            20: if(busy) start <= 0; state <= 21;
            21: if(!running) 
                begin
                    start <= 1; state <= 22;
                    cmd <= 8'h00;
                end
            22: if(!busy) state <= 23;
            23: if(busy) start <= 0; state <= 24;
            24: if(!running)
                begin
                    start <= 1; state <= 25;
                    cmd <= 8'h00;
                end
            25: if(busy) cmd <= 8'h10; state <= 26;
            26: if(!busy) start <= 0; state <= 27;

            27: 
                // Start sending number bitmap.
                begin
                    if(!running)
                    begin
                        start <= 1;
                        cmd <= 8'h40;
                    end
                    else
                    begin
                        if(cnt[5])
                        begin
                            state <= 31;
                            start <= 0;
                            cnt <= 0;
                        end
                        else
                        begin
                            if(busy)
                            begin
                                cnt <= cnt + 1;
                                if(cnt[2:0] == 4)
                                begin
                                    state <= 30;
                                    cnt[2:0] <= 0;
                                    cnt[4:3] <= cnt[4:3] + 1;
                                    start <= 0;
                                end
                                else
                                    state <= 28;
                            end
                        end
                    end
                    case({cnt[4:3], cnt[1:0]})
                        0:  num <= NUMS[63:60];
                        1:  num <= NUMS[59:56];
                        2:  num <= NUMS[55:52];
                        3:  num <= NUMS[51:48];
                        4:  num <= NUMS[47:44];
                        5:  num <= NUMS[43:40];
                        6:  num <= NUMS[39:36];
                        7:  num <= NUMS[35:32];
                        8:  num <= NUMS[31:28];
                        9:  num <= NUMS[27:24];
                        10: num <= NUMS[23:20];
                        11: num <= NUMS[19:16];
                        12: num <= NUMS[15:12];
                        13: num <= NUMS[11:8];
                        14: num <= NUMS[7:4];
                        15: num <= NUMS[3:0];
                    endcase
                end
            28: if(!busy) 
                begin
                    cmd <= mod_arr;
                    shift <= 1;
                    state <= 29;
                end
            29: if(busy)
                begin
                    shift <= 0;
                    if(!mod_finish)
                        state <= 28;
                    else
                        state <= 27;
                end
            30: if(!running) state <= 12; 
            31: if(!running) state <= 11;
        end
    end

endmodule
