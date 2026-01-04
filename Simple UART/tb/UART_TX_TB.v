`timescale 1ns / 1ns
`define CLK_PERIOD 20

module UART_TX_TB;

    // Clock and reset
    reg clk;
    reg nrst;

    // Inputs to DUT
    reg [7:0] data_byte;
    reg [2:0] baud_set;
    reg send_en;

    // Outputs from DUT
    wire uart_tx;
    wire tx_done;
    wire uart_state;

    // Clock period
    parameter CLK_PERIOD = 20;

    // Instantiate DUT
    UART_SEND_TOP uut (
        .clk(clk),
        .nrst(nrst),
        .data_byte(data_byte),
        .baud_set(baud_set),
        .send_en(send_en),
        .uart_tx(uart_tx),
        .tx_done(tx_done),
        .uart_state(uart_state)
    );                                                                                                  

    // Clock generation
    initial clk = 1;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        // === Initial state ===
        nrst      = 1'b1;           // LUÔN giữ reset ở mức cao
        data_byte = 8'd0;           // Send
        send_en   = 1'b1;
        baud_set  = 3'd4;           // Baud 115200

        #(`CLK_PERIOD * 50);         // Đợi hệ thống ổn định sau khi khởi động

        // === Send First Byte ===
        data_byte = 8'hAA;
        send_en   = 1'b1;
        #`CLK_PERIOD;
        send_en   = 1'b0;

        // Wait for transmission done
        @(posedge tx_done);
        #(`CLK_PERIOD * 5000)

        // === Send Second Byte ===
        data_byte = 8'h55;
        send_en   = 1'b1;
        #`CLK_PERIOD
        send_en   = 1'b0;

        // Wait for transmission done
        @(posedge tx_done);
        #(`CLK_PERIOD * 5000)

        // Kết thúc mô phỏng
        $finish;
    end

endmodule
