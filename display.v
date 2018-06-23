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

    assign ARR = out;

    always @(dig_cnt or cnt) FINISH <= dig_cnt == 0 && cnt == 0;

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
            dig_cnt <= 0;
            latch <= 0;
        end
        else
        begin
            cnt <= cnt + 1;
            if(cnt == 0)
            begin
                //if(dig_cnt == 0)
                //    latch <= NUM;
                dig_cnt <= dig_cnt + 1;

                case(NUM)
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
    , output [5:0] STATE
    , output reg BUSY
    , output SCL
    , inout SDA    
);
    reg [1:0]div;
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
    
    assign STATE = state;

    ssd1780 display(div[1], cmd, SDA, SCL, start, ASNYC_RST_L, busy, running);
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
            div <= div + 1;
            case(state)
            0: begin // reset
                cmd <= 8'h00; start <= 1;
                if(running) 
                    state <= 1;
                end
            1: if(!busy) 
               begin
                   case(cnt)
                   0: cmd <= 8'h8d; // Charge pump
                   1: cmd <= 8'h14;
                   2: cmd <= 8'haf;
                   3: cmd <= 8'h20;
                   4: cmd <= 8'h02;
                   5: cmd <= 8'h00;
                   6: cmd <= 8'h10;
                   endcase
                   state <= 2;
               end
            2: if(busy)
               begin
                        start <= 0; state <= 3;
               end
            3: if(!running) 
                begin
                    if(cnt == 6)
                    begin
                        state <= 4;
                        cnt <= 8'h00;
                    end
                    else
                    begin
                        state <= 0;
                        cnt <= cnt + 1;
                    end
                end
            // Clear 
            4:  // Line start
                if(pos_set)
                begin
                        start <= 1;
                        cmd <= 8'h40;
                        if(busy) state <= 7;
                end
                else
                begin // Start sending set-line command
                    start <= 1;
                    cmd <= 8'h00;
                    if(busy) 
                    begin
                        //pos_set <= 1;
                        state <= 5;
                    end
                end
            5: if(!busy)
                begin
                    case(cnt[2:0])
                    0: cmd <= 8'h20;
                    1: cmd <= 8'h02;
                    2: cmd <= 8'h00;
                    3: cmd <= 8'h10;
                    4: cmd <= {4'hb, 1'b0, cnt[9:7]};
                    endcase
                    state <= 6;
                end
            6:  if(busy)
                begin
                    start <= 0; state <= 13;
                end
            13: if(!running)
                begin
                    if(cnt[2:0] == 4)
                    begin
                        pos_set <= 1;
                        state <= 13;
                        cnt[2:0] <= 0;
                    end
                    else
                    begin
                        cnt[2:0] <= cnt[2:0] + 1;
                        state <= 4;
                    end
                end
            // Burst sending 0 for 128 byte.
            7: 
                if(!busy) 
                begin
                    cmd <= 0;
                    state <= 10;
                end
            9: 
                if(!running)
                begin
                    cnt <= cnt + 1;
                    if(&{cnt[6:0]})
                    begin
                        if(&{cnt[9:7]})
                        begin
                            cnt <= 0;
                            state <= 11; // Finish
                        end
                        else
                        begin
                            pos_set <= 0;
                            state <= 4;
                        end
                    end
                    else
                        state <= 4;
                end
            
            10: if(busy) 
                begin
                    state <= 9;
                    start <= 0;
                end
            // Ready
            11:
                if(REFRESH) 
                begin
                    state <= 12;
                    cnt <= 0;
                    cnt[6:4] <= 0;
                end
            12: 
                begin
                    // New line
                    start <= 1;
                    if(busy) state <= 19;
                    cmd <= 0;
                end
            19: if(!busy) 
                begin
                    case(cnt[6:4])
                    0: cmd <= 8'h20;
                    1: cmd <= 8'h02;
                    2: cmd <= 8'h00;
                    3: cmd <= 8'h12;
                    4: cmd <= 8'hb0 | {5'b0, cnt[3:2], 1'b0};
                    endcase
                    state <= 20;
                end
            20:
                if(busy)
                begin
                    start <= 0; state <= 21;
                end
            21: if(!running)
                begin
                    if(cnt[6:4] == 4)
                    begin
                        cnt[6:4] <= 0;
                        state <= 27;
                    end
                    else
                    begin
                        cnt[6:4] <= cnt[6:4] + 1;
                        state <= 12;
                    end
                end
            27: 
                // Start sending number bitmap.
                begin
                    if(!running)
                    begin
                        start <= 1;
                        cmd <= 8'h40;
                        state <= 28;
                        case({cnt[3:2], cnt[1:0]})
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
                end
            28: if(running)
                begin
                    shift <= 0;
                    state <= 29;
                end
            29: if(!busy)
                begin
                    shift <= 1;
                    cmd <= mod_arr;
                    state <= 30;
                end
            30: if(busy) 
                begin
                    start <= 0;
                    state <= 31; 
                end
            31: if(!running)
                begin
                    if(!mod_finish)
                    begin
                        state <= 27;
                    end
                    else
                    begin
                        cnt <= cnt + 1;
                        if(cnt[1:0] == 2'b11)
                        begin
                            if(cnt[3:2] == 2'b11)
                                state <= 11;
                            else
                                state <= 12;
                        end
                        else
                            state <= 27;
                    end
                end

            endcase
        end
    end

endmodule
