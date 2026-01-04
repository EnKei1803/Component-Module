`timescale 1ns / 1ns
`define CLK_PERIOD 20

module UART_DATA_RX_TB;

    parameter DATA_WIDTH = 32;
    parameter MSB_FIRST = 0;
    reg clk;
    reg nrst;

    reg [DATA_WIDTH-1:0] data;
    reg send_en;
    wire [DATA_WIDTH-1:0] rx_data;
    wire uart_tx;
    wire uart_rx;
    wire tx_done;
    wire uart_state;
    wire rx_done;
    wire timeout_flag;

    // Assign uart_rx to uart_tx for loopback testing
    assign uart_rx = uart_tx;

    // Instantiate uart_data_tx module
    UART_DATA_TX #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)
    )
    uart_data_tx_inst (
        .clk(clk),
        .nrst(nrst),
        .data(data),
        .send_en(send_en),
        .baud_set(3'd4),
        .uart_tx(uart_tx),
        .tx_done(tx_done),
        .uart_state(uart_state)
    );

    // Instantiate uart_data_rx module (assuming it exists)
    UART_DATA_RX #(
        .DATA_WIDTH(DATA_WIDTH),
        .MSB_FIRST(MSB_FIRST)
    )
    uart_data_rx_inst (
        .clk(clk),
        .nrst(nrst),
        .uart_rx(uart_rx),
        .data(rx_data),
        .rx_done(rx_done),
        .timeout_flag(timeout_flag),
        .baud_set(3'd4)
    );

    // Clock generation
    initial clk = 1;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // Test stimulus
    initial begin
        nrst    = 0;
        data    = 0;
        send_en = 0;
        #201;
        nrst    = 1;
        #2000;
        data = 32'h12345678;
        send_en = 1;
        #20;
        send_en = 0;
        #20;

        @(posedge tx_done) 
        #1
        #1000000
        data    = 32'h87654321;
        send_en = 1;
        #20
        send_en = 0;
        #20

        @(posedge tx_done) 
        #1
        #1000000
        data = 32'h24680135;
        send_en = 1;
        #20
        send_en = 0;
        #20

        @(posedge tx_done) 
        #1
        #400000
        $stop;
    end

endmodule