module score_counter(
    input ADD_TIGGER // 上升沿触发，累加
    , input[23:0] score_bcd // 6位 BCD 输出
    , input[23:0] score_add // BCD输入，加数
    , input ASYNC_RST_L // 异步复位
);

endmodule
