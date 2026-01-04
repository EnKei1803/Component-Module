`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2025 03:35:53 PM
// Design Name: 
// Module Name: uart_tx_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx_rx(
    input  logic        clk,           
    input   logic       nrst,     

    input   logic       uart_rx,       
    output  logic       uart_tx,

    output  logic       rx_done,
    output  logic       tx_done,

    input   logic       send_en,
    input   logic [7:0] data_byte_tx,
    output  logic [7:0] data_byte_rx
);  
/* 
    Baud rate setting
    0 : 9600
    1 : 19200
    2 : 38400
    3 : 57600
    4 : 115200
*/
localparam baud_set = 3'd0; // Baud rate setting


// logic [7:0] data_byte_tx;   // Byte to transmit
// logic [7:0] data_byte_rx;   // Received byte
// logic       send_en;        // Send enable
// logic       tx_done;        // Transmission done flag
// logic       rx_done;        // Receive done flag

    // Check Receive byte by send it again to PC
    // always_ff @(posedge clk or negedge nrst) begin
    //     if (!nrst) begin
    //         data_byte_tx <= 8'd0;
    //         send_en <= 1'b0;
    //     end
    //     else if (rx_done) begin
    //         data_byte_tx <= data_byte_rx;
    //         send_en <= rx_done;
    //     end
    //     else begin
    //         data_byte_tx <= data_byte_tx;
    //         send_en <= 1'b0;
    //     end
    // end

// UART transmit module instantiation
uart_tx     UART_SEND_TOP (
    .clk        (clk),
    .nrst       (nrst),

    .data_byte  (data_byte_tx),
    .send_en    (send_en),
    .baud_set   (baud_set),

    .uart_tx    (uart_tx),
    .tx_done    (tx_done),
    .uart_state ()
);

// UART receive module instantiation
uart_rx     UART_RECEIVE_TOP (
    .clk        (clk),
    .nrst       (nrst),

    .baud_set   (baud_set),
    .uart_rx    (uart_rx),

    .data_byte  (data_byte_rx),
    .rx_done    (rx_done)
);


endmodule
