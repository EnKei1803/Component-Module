`timescale 1ns / 1ns
`define CLK_PERIOD 20

module UART_DATA_TX_TB;

    parameter DATA_WIDTH = 32;
    parameter MSB_FIRST = 0;

    reg clk;
    reg nrst;
    reg [DATA_WIDTH-1:0] data;
    reg send_en;
    wire uart_tx;
    wire tx_done;
    wire uart_state;

    UART_DATA_TX #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)
    )
    UART_DATA_TX (
        .clk(clk),
        .nrst(nrst),
        .data(data),
        .send_en(send_en),
        .baud_set(3'd4),

        .uart_tx(uart_tx),
        .tx_done(tx_done),
        .uart_state(uart_state)
    ); 

    // Clock generation
    initial clk = 1;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        nrst = 0;
        data = 0;
        send_en = 0;
        #201;
        nrst = 1;
        #2000;
        data = 32'h01234567;
        send_en = 1;
        #20;
        send_en = 0;
        #20;

        @(posedge tx_done); 
        #1
        data = 32'h12345678;
        send_en = 1;
        #20
        send_en = 0;
        #20

        @(posedge tx_done); 
        #1
        data = 32'h23456789;
        send_en = 1;
        #20
        send_en = 0;
        #20

        @(posedge tx_done); 
        #1
        #2000
        $stop;
    end

endmodule