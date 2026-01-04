`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2025 02:24:14 PM
// Design Name: 
// Module Name: uart_rx
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

module uart_rx(
    input  logic        clk,
    input  logic        nrst,
    input  logic        uart_rx,
    input  logic [2:0]  baud_set,
//    input send_en,              // 0: Receive / 1: Transmit
    output  logic [7:0] data_byte,
    output  logic rx_done
);
logic bps_clk;
logic uart_rx_sync2;
logic [15:0] bps_DR;
logic [23:0] data_byte_pre;
logic [7:0] bps_cnt;
logic [2:0] START_BIT;
logic [2:0] STOP_BIT;

DR_LUT_receive  DR_LUT_receive  (
    .clk        (clk), 
    .nrst       (nrst), 
    .baud_set   (baud_set), 
    .bps_DR     (bps_DR)
);

div_cnt_receive div_cnt_receive (
    .clk        (clk), 
    .nrst       (nrst), 
    .bps_DR     (bps_DR), 
    .bps_clk    (bps_clk)
);

bps_cnt_receive bps_cnt_receive (
    .clk(       clk), 
    .nrst       (nrst), 
    .bps_clk    (bps_clk),  
    .START_BIT  (START_BIT),
    .bps_cnt    (bps_cnt)
);

EDGE_DETECT EDGE_DETECT (
    .clk            (clk), 
    .nrst           (nrst),
    .uart_rx        (uart_rx),
    .uart_rx_sync2  (uart_rx_sync2)
);

RX_data_sampling    RX_data_sampling    (
    .clk                (clk), 
    .nrst               (nrst),
    .bps_clk            (bps_clk), 
    .bps_cnt            (bps_cnt), 
    .uart_rx_sync2      (uart_rx_sync2), 
    .START_BIT          (START_BIT), 
    .data_byte_pre      (data_byte_pre), 
    .STOP_BIT           (STOP_BIT)
);

RX_data_byte    RX_data_byte    (
    .clk            (clk), 
    .nrst           (nrst),
    .bps_cnt        (bps_cnt),
    .data_byte_pre  (data_byte_pre),
    .data_byte      (data_byte)
);

REG_rx_done REG_rx_done     (
    .clk            (clk), 
    .nrst           (nrst), 
    .bps_cnt        (bps_cnt), 
    .rx_done        (rx_done)
);

endmodule

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module DR_LUT_receive
(
    input  logic [2:0]  baud_set,
    input  logic        clk,
    input  logic        nrst,
    output logic [15:0] bps_DR
);
/*
    Formula to calculate bps_DR:

             /    1         /    1     \
 bps_DR   = |  ----------  / ---------- | / 16  - 1 
             \ Baud Rate  /   SysFreq  /

          = (SysFreq / Baud Rate) / 16 - 1 = (50,000,000 / Baud Rate) / 16 - 1

    For SysFreq = 50 MHz
            +---------------+-------------+
            |   Baud Rate   |   bps_DR    |
            +---------------+-------------+
            |      9600     |     325     |
            |     19200     |     162     |
            |     38400     |     80      |
            |     57600     |     53      |
            |    115200     |     26      |
            +---------------+-------------+

    Default(9600):     325     
*/
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            bps_DR <= 16'd325;          // Default Baud rate:  9600
        else 
        case (baud_set)
            0 : bps_DR <= 16'd325;     // Baud rate:   9600
            1 : bps_DR <= 16'd162;     // Baud rate:  19200
            2 : bps_DR <= 16'd80;      // Baud rate:  38400
            3 : bps_DR <= 16'd53;      // Baud rate:  57600
            4 : bps_DR <= 16'd26;      // Baud rate: 115200
            default: bps_DR <= 16'd325;
        endcase 
    end

endmodule

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module div_cnt_receive(
    input  logic [15:0] bps_DR,
    input  logic        clk,
    input  logic        nrst,
    output logic        bps_clk
);
logic [15:0] div_cnt;

    always_ff @(posedge clk or negedge nrst) begin 
        if (!nrst)
            div_cnt <= 16'd0;
        else if (div_cnt == bps_DR)
            div_cnt <= 16'd0;
        else 
            div_cnt <= div_cnt + 1'b1;
        end

    // bps_clk gen
    always_ff @(posedge clk or negedge nrst) begin 
        if (!nrst)
            bps_clk <= 1'b0;
        else if (div_cnt == 16'd1)
            bps_clk <= 1'b1;
        else 
            bps_clk <= 1'b0;
    end

endmodule 

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module bps_cnt_receive(
    input  logic        bps_clk,
    input  logic        clk,
    input  logic        nrst,
    input  logic [2:0]  START_BIT,
    output logic [7:0]  bps_cnt
);

    always_ff @(posedge clk or negedge nrst) begin 
        if (!nrst)
            bps_cnt <= 8'd0;
        else if (bps_cnt==8'd159 | (bps_cnt==8'd12 && (START_BIT>2)))
            bps_cnt <= 8'd0;
        else if (bps_clk)
            bps_cnt <= bps_cnt + 1'b1;
        else 
            bps_cnt <= bps_cnt;
    end 

endmodule

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module EDGE_DETECT(
    input  logic        clk, 
    input  logic        nrst,
    input  logic        uart_rx,
    output logic        uart_rx_sync2
//    output uart_rx_negedge,
//    output uart_rx_posedge
);
logic        uart_rx_sync1;

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            uart_rx_sync1 <= 1'b0;
            uart_rx_sync2 <= 1'b0;
        end
        else begin
            uart_rx_sync1 <= uart_rx;
            uart_rx_sync2 <= uart_rx_sync1;
        end
    end

//assign  uart_rx_negedge = !uart_rx_sync1 & uart_rx_sync2;
//assign  uart_rx_posedge = uart_rx_sync1 & !uart_rx_sync2;

endmodule 

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module RX_data_sampling(
    input  logic        clk,
    input  logic        nrst,
    input  logic        bps_clk,
    input  logic [7:0]  bps_cnt,
    input  logic        uart_rx_sync2,
    // Các thanh ghi để lấy mẫu
    output logic [2:0]  START_BIT,
    output logic [2:0]  STOP_BIT,
    output logic [23:0] data_byte_pre  // Mảng 8 phần tử, mỗi phần tử 3-bit
);

    // Phần reset
    // Khi tín hiệu reset tích cực (high), tất cả các thanh ghi được khởi tạo về 0.
    // START_BIT, data_byte_pre[0:7], và STOP_BIT đều là các thanh ghi 3-bit (vì được khởi tạo bằng 3'd0).

    always_ff @(posedge clk or negedge nrst)
        if (!nrst) begin
            START_BIT        <= 3'd0;
            data_byte_pre    <= 24'd0;
            STOP_BIT         <= 3'd0;
        end
        else if (bps_clk) begin
            case (bps_cnt)
                0: begin
                // Reset các thanh ghi khi bắt đầu một frame mới
                START_BIT        <= 3'd0;
                data_byte_pre    <= 24'd0;
                STOP_BIT         <= 3'd0;
                end

    // Mỗi bit UART được lấy mẫu **6 lần** (ví dụ: bit start được lấy mẫu ở các giá trị bps_cnt = 6,7,8,9,10,11).
    // Giá trị uart_rx_sync2 (tín hiệu UART đã đồng bộ hóa) được cộng dồn vào thanh ghi tương ứng.
    // Sau 6 lần lấy mẫu, giá trị của thanh ghi sẽ nằm trong khoảng 0–6. Nếu giá trị >= 4, bit đó được coi là '1'; ngược lại là '0'
                6,7,8,9,10,11           : START_BIT               <= START_BIT + uart_rx_sync2;
                22,23,24,25,26,27       : data_byte_pre[2:0]      <= data_byte_pre[2:0] + uart_rx_sync2;
                38,39,40,41,42,43       : data_byte_pre[5:3]      <= data_byte_pre[5:3] + uart_rx_sync2;
                54,55,56,57,58,59       : data_byte_pre[8:6]      <= data_byte_pre[8:6] + uart_rx_sync2;
                70,71,72,73,74,75       : data_byte_pre[11:9]     <= data_byte_pre[11:9] + uart_rx_sync2;
                86,87,88,89,90,91       : data_byte_pre[14:12]    <= data_byte_pre[14:12] + uart_rx_sync2;
                102,103,104,105,106,107 : data_byte_pre[17:15]    <= data_byte_pre[17:15] + uart_rx_sync2;
                118,119,120,121,122,123 : data_byte_pre[20:18]    <= data_byte_pre[20:18] + uart_rx_sync2;
                134,135,136,137,138,139 : data_byte_pre[23:21]    <= data_byte_pre[23:21] + uart_rx_sync2;
                150,151,152,153,154,155 : STOP_BIT                <= STOP_BIT + uart_rx_sync2;

                // Khi bps_cnt không rơi vào các khoảng lấy mẫu, các thanh ghi giữ nguyên giá trị
                default: begin
                START_BIT        <= START_BIT;
                data_byte_pre    <= data_byte_pre;
                STOP_BIT         <= STOP_BIT;
                end
            endcase
        end

endmodule 

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module RX_data_byte(
    input logic        clk,
    input logic        nrst,
    input logic [7:0]  bps_cnt,
    input logic [23:0] data_byte_pre,  // 8 phần tử, mỗi phần tử 3-bit
    output logic [7:0] data_byte       
);

always_ff @(posedge clk or negedge nrst)
    if (!nrst)
        data_byte <= 8'd0;  // reset về 0
    else if (bps_cnt == 8'd159) begin
        // chốt dữ liệu khi kết thúc 1 frame
        // mỗi phần tử data_byte được lấy MSB (bit thứ 2) từ thanh ghi lấy mẫu tương ứng
        data_byte[0] <= data_byte_pre[2];     // bit 2 of byte 0
        data_byte[1] <= data_byte_pre[5];     // bit 2 of byte 1
        data_byte[2] <= data_byte_pre[8];     // bit 2 of byte 2
        data_byte[3] <= data_byte_pre[11];    // bit 2 of byte 3
        data_byte[4] <= data_byte_pre[14];    // bit 2 of byte 4
        data_byte[5] <= data_byte_pre[17];    // bit 2 of byte 5
        data_byte[6] <= data_byte_pre[20];    // bit 2 of byte 6
        data_byte[7] <= data_byte_pre[23];    // bit 2 of byte 7
    end

endmodule

/*
==================================================================================================
                     ____  ____    _    _   _ _____   ____  __  __
                    |  _ \|  _ \  | |  | | | |_   _| |  _ \ \ \/ /
                    | | | | |_) | | |  | | | | | |   | |_) | \  / 
                    | |_| |  _ <  | |__| |_| | | |   |  _ <  /  \ 
                    |____/|_| \_\ |_____\___/  |_|   |_| \_\/_/\_\
                                                                
==================================================================================================
*/

module REG_rx_done(
    input logic        clk,
    input logic        nrst,
    input logic [7:0]  bps_cnt,
    output logic       rx_done
);

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            rx_done <= 1'b0;
        else if (bps_cnt==8'd159)
            rx_done <= 1'b1;
        else 
            rx_done <= 1'b0;
    end

endmodule