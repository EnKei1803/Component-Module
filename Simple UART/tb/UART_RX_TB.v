`timescale 1ns / 1ps
`define CLK_PERIOD 20

module UART_RX_TB;

    // Clock and reset
    reg             clk;
    reg             nrst;

    // Inputs to DUT
    reg     [7:0]   data_byte_tx;
    reg     [2:0]   baud_set;
    reg             send_en;

    // Outputs from DUT
    wire            tx_done;
    wire            uart_state;
    wire            uart_tx_rx;
    wire            rx_done;
    wire    [7:0]   data_byte_rx;

    // Instantiate DUT
    UART_TX_RX uut (
        .clk(clk),
        .nrst(nrst),

        .data_byte_tx(data_byte_tx),
        .baud_set(baud_set),
        .send_en(send_en),

        .tx_done(tx_done),
        .uart_state(uart_state),

        .uart_tx_rx(uart_tx_rx),

        .rx_done(rx_done),
        .data_byte_rx(data_byte_rx)
    );                                                                                                  

    // Clock generation
    initial clk = 1;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        // === Initial state ===
        nrst            = 1'b0;           // LUÔN giữ reset ở mức cao
        data_byte_tx    = 8'd0;           // Send
        send_en         = 1'b0;           // Transmit
        baud_set        = 3'd4;           // Baud 115200

        // === Start Running ===
        #(`CLK_PERIOD * 500 + 1);
        nrst            = 1'b1;

        #(`CLK_PERIOD * 50);         // Đợi hệ thống ổn định sau khi khởi động
        // === Send First Byte ===
        data_byte_tx    = 8'hAA;
        send_en         = 1'b1;
        #`CLK_PERIOD;
        send_en         = 1'b0;

        // Wait for transmission done
        @(posedge tx_done);
        #(`CLK_PERIOD * 5000)     

        // === Send Second Byte ===
        data_byte_tx    = 8'h55;
        send_en         = 1'b1;
        #`CLK_PERIOD      
        send_en   = 1'b0;

        // Wait for transmission done
        @(posedge tx_done);
        #(`CLK_PERIOD * 5000)     

        // Kết thúc mô phỏng
        $stop;
    end

endmodule
