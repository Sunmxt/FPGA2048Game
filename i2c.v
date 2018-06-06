module i2c_master(
    input CLK
    , inout SDA
    , output SCL
    , output BUSY
    , output RUNNING
    , input START
    , input RESTART
    , input ASYNC_RST_L
    , inout[7:0] DATA
    , input[7:0] ADDR
);

    reg[7:0] addr;
    reg[7:0] data;

    reg[3:0] cnt;
    reg read_bit;   // receiver mode
    reg start;
    reg start_cond; // Start condition sent
    reg dat_sent;
    reg addr_sent;
    reg acked;
    reg scl;
    reg sda;
    reg stop;
    reg sda_input;

    assign RUNNING = start;
    assign BUSY = start &  ~(start & addr_sent & ~stop & acked);
    assign SCL = scl;
    assign SDA = sda_input == 1 ? 1'bz : sda;

    always @(posedge CLK or negedge ASYNC_RST_L)
    begin
        if(!ASYNC_RST_L) // Async reset
            begin
                start <= 0;
                scl <= 1;
                sda <= 1;
                stop <= 0;
                cnt <= 0;
                acked <= 0;
                dat_sent = 0;
                read_bit <= 0;
                start_cond <= 0;
                addr_sent <= 0;
                sda_input <= 1;
                addr <= 0;
                data <= 0;
            end
        else
            begin
                if(!start)
                begin
                    if(START)       // Generate start condition
                    begin
                        start <= 1;
                        sda <= 0;
                        addr_sent <= 0;
                        dat_sent <= 0;
                        acked <= 0;
                        start_cond <= 0;
                        addr <= ADDR;
                        sda_input = 0;
                    end
                end
                else
                begin
                    if(!addr_sent)
                    begin
                        if(!start_cond)
                        begin
                            start_cond <= 1;
                            // Latch slave address, and shift to address sending.
                            // pull-down scl, prepare for address sending
                            scl <= 0;
                            cnt <= 0;
                            dat_sent = 0;
                            read_bit <= addr[0];
                        end
                        else
                        begin
                            if(!scl)
                            begin
                                if(!dat_sent)
                                begin   // Address shift to sda
                                    sda <= addr[7];
                                    addr <= {addr[6:0], 1'b1}; // Shift to next bit
                                    dat_sent <= 1'b1;
                                end
                                else
                                begin   // pull up scl, notifing that sda is available
                                    scl <= 1;
                                    dat_sent <= 0;
                                    cnt <= cnt + 1;
                                end
                            end
                            else
                            begin
                                if(!dat_sent)
                                    if(cnt != 4'd9) // The last bit is 1 aimming to pull up sda.
                                        scl <= 0; // Next 
                                    else
                                    begin
                                        dat_sent <= 1; // Finish sending. wait for ack.
                                        sda_input <= 1; 
                                        cnt <= 0;
                                    end
                                else
                                begin
                                    cnt <= cnt + 1;
                                    if(cnt != 3) // Wait for ack
                                    begin
                                        if(!SDA) //Acked
                                        begin
                                            // cnt <= 0;
                                            acked <= 1;
                                            addr_sent <= 1; // Shift to data sending
                                            sda_input <= read_bit;
                                        end
                                    end
                                    else // No acked. resrt.
                                        start <= 0;
                                end
                            end
                        end
                    end
                    else // Sending data
                    begin
                        if(stop) // Generate stop condition. (initial: acked = 1)
                        begin
                            sda_input = 0;
                            if(!scl)
                                if(acked)
                                begin
                                    sda <= 0; // Stage 1
                                    acked <= 0;
                                end
                                else
                                    scl <= 1;  // Stage 2
                            else
                            begin
                                sda <= 1;
                                start <= 0;  // Stage 3 : Stop condition
                            end
                        end
                        else
                        begin
                            if(acked) // Able to continue
                            begin
                                if(!RESTART)
                                begin
                                    scl <= 0;
                                    if(!START) // start stop procedure
                                    begin
                                        stop <= 1;
                                    end
                                    else
                                    begin // Begin next byte
                                        cnt <= 0;
                                        acked <= 0;
                                        dat_sent <= 0;
                                        if(!read_bit)
                                            data <= DATA;
                                    end
                                end
                                else
                                begin
                                    sda_input <= 0;
                                    case({sda, scl}) // restart condition
                                        0: sda <= 1;
                                        1: scl <= 0;
                                        2: scl <= 1;
                                        3: start <= 0;
                                    endcase
                                end
                            end
                            else
                            begin // Send or receive bits
                                if(cnt != 4'd8)
                                begin
                                    if(!scl)
                                        if(!read_bit) // Send
                                        begin
                                            if(!dat_sent)
                                            begin
                                                sda <= data[7]; // Shift data to sda
                                                data <= {data[6:0], 1'b1};
                                                dat_sent <= 1'b1;
                                            end
                                            else
                                                scl <= 1;  // pull up scl, notifing data available
                                        end
                                        else
                                        begin
                                            scl <= 1;
                                        end
                                    else
                                    begin
                                        scl <= 0;
                                        if(read_bit) // Receive 1 bit
                                            data <= {sda, data[7:1]};
                                        else
                                            dat_sent <= 0;
                                        cnt <= cnt + 1;
                                    end
                                end
                                else
                                begin
                                    if(read_bit) // recv-mode. send ack
                                    begin
                                        if(!dat_sent)
                                        begin
                                            sda_input <= 0;
                                            dat_sent <= 1;
                                        end
                                        else
                                        begin
                                            if(sda)
                                                sda <= 0;
                                            else
                                            begin
                                                acked <= 1;
                                                scl <= 1;
                                                sda_input <= read_bit;
                                            end
                                        end
                                    end
                                    else 
                                    // send-mode. wait ack
                                    begin
                                        if(!dat_sent)
                                        begin
                                            sda_input <= 1;
                                            dat_sent <= 1;
                                        end
                                        else
                                        begin
                                            if(SDA)
                                                cnt <= cnt + 1;
                                            else
                                            begin
                                                acked <= 1;
                                                sda_input <= read_bit;
                                            end
                                            if(cnt == 4'd11) // No ack. stop.
                                                stop <= 1;
                                        end
                                    end   
                                end
                            end
                        end
                    end
                end
            end

    end
    
endmodule
