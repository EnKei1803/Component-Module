`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2025 02:37:06 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input  logic        clk,
    input  logic        nrst,

    input  logic [7:0]  data_byte,
    input  logic [2:0]  baud_set,
    input  logic        send_en,
    output logic        uart_tx,
    output logic        tx_done,
    output logic        uart_state
);
logic        bps_clk; 
logic        uart_tx_pre;
logic [15:0] bps_DR;
logic [ 7:0] data_byte_reg;
logic [ 3:0] bps_cnt_q;

DR_LUT_send DrLUT_send_inst(
    .clk        (clk), 
    .nrst       (nrst), 
    .baud_set   (baud_set), 
    .bps_DR     (bps_DR)
);

div_cnt_send    div_cnt_send_inst(
    .clk        (clk), 
    .nrst       (nrst), 
    .bps_DR     (bps_DR), 
    .uart_state (uart_state), 
    .bps_clk    (bps_clk)
);

bps_cnt_send    bps_cnt_send_inst(
    .clk        (clk), 
    .nrst       (nrst), 
    .bps_clk    (bps_clk), 
    .bps_cnt_q  (bps_cnt_q)
);

DATA_REG    DATA_REG_inst(
    .clk            (clk), 
    .nrst           (nrst), 
    .data_byte      (data_byte), 
    .send_en        (send_en), 
    .data_byte_reg  (data_byte_reg)
);

MUX_10x1    MUX10_inst(
    .clk            (clk), 
    .nrst           (nrst), 
    .bps_cnt        (bps_cnt_q), 
    .START_BIT      (1'b0), 
    .STOP_BIT       (1'b1), 
    .data_byte_reg  (data_byte_reg), 
    .uart_tx        (uart_tx_pre)
);

REG_uart_tx     REG_uart_tx_inst(
    .clk            (clk), 
    .nrst           (nrst), 
    .uart_tx_pre    (uart_tx_pre), 
    .uart_tx        (uart_tx)
);
REG_tx_done     REG_tx_done_inst(
    .clk            (clk), 
    .nrst           (nrst), 
    .bps_cnt_q      (bps_cnt_q), 
    .tx_done        (tx_done)
);
REG_uart_state  REG_uart_state_inst(
    .clk            (clk), 
    .nrst           (nrst), 
    .bps_cnt_q      (bps_cnt_q), 
    .send_en        (send_en), 
    .uart_state     (uart_state)
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

module DR_LUT_send
(
    input  logic        clk,
    input  logic        nrst,

    input  logic [ 2:0] baud_set,
    output logic [15:0] bps_DR
);

/*
    Formula to calculate bps_DR:

             /    1         /    1     \
 bps_DR   = |  ----------  / ---------- |  - 1 
             \ Baud Rate  /   SysFreq  /

          = (SysFreq / Baud Rate) - 1 = (50,000,000 / Baud Rate) - 1

    For SysFreq = 50 MHz
            +---------------+-------------+
            |   Baud Rate   |   bps_DR    |
            +---------------+-------------+
            |      9600     |    5207     |
            |     19200     |    2603     |
            |     38400     |    1301     |
            |     57600     |     867     |
            |    115200     |     433     |
            +---------------+-------------+

    Default(9600):     5207     
*/
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            bps_DR <= 16'd5207;
        else  
        case (baud_set)
            0 : bps_DR <= 16'd5207;     // Baud rate:   9600
            1 : bps_DR <= 16'd2603;     // Baud rate:  19200
            2 : bps_DR <= 16'd1301;     // Baud rate:  38400
            3 : bps_DR <= 16'd867;      // Baud rate:  57600
            4 : bps_DR <= 16'd433;      // Baud rate: 115200
            default: bps_DR <= 16'd5207;
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

module div_cnt_send
(
    input  logic [15:0] bps_DR,
    input  logic clk,
    input  logic nrst,
    input  logic uart_state,
    output logic bps_clk
);
logic [15:0] div_cnt;

    always_ff @(posedge clk or negedge nrst) begin 
        if (!nrst)
            div_cnt <= 16'd0;
        else if (uart_state) begin
            if (div_cnt == bps_DR)
                div_cnt <= 16'd0;
            else 
                div_cnt <= div_cnt + 1'b1;
            end
        else 
            div_cnt <= 16'd0;
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

module bps_cnt_send 
(
    input  logic bps_clk,
    input  logic clk,
    input  logic nrst,
    output logic [3:0] bps_cnt_q
);

    always_ff @(posedge clk or negedge nrst) begin 
        if (!nrst)
            bps_cnt_q <= 4'd0;
        else if (bps_cnt_q==4'd11)
            bps_cnt_q <= 4'd0;
        else if (bps_clk)
            bps_cnt_q <= bps_cnt_q + 1'b1;
        else 
            bps_cnt_q <= bps_cnt_q;
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

module DATA_REG
(
    input  logic clk,
    input  logic nrst,
    input  logic send_en,
    input  logic [7:0] data_byte,
    output logic [7:0] data_byte_reg 
);

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            data_byte_reg <= 8'b0;
        else if (send_en)
            data_byte_reg <= data_byte;
        else
            data_byte_reg <= data_byte_reg;
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

module MUX_10x1
(
    input  logic START_BIT, STOP_BIT,
    input  logic [7:0] data_byte_reg,
    input  logic [3:0 ]bps_cnt,
    input  logic clk,
    input  logic nrst,
    output logic uart_tx
);

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            uart_tx <= 1'b1;
        else  
        case (bps_cnt)
            0  : uart_tx <= 1'b1;
            1  : uart_tx <= START_BIT;
            2  : uart_tx <= data_byte_reg[0];
            3  : uart_tx <= data_byte_reg[1];
            4  : uart_tx <= data_byte_reg[2];
            5  : uart_tx <= data_byte_reg[3];
            6  : uart_tx <= data_byte_reg[4];
            7  : uart_tx <= data_byte_reg[5];
            8  : uart_tx <= data_byte_reg[6];
            9  : uart_tx <= data_byte_reg[7];
            10 : uart_tx <= STOP_BIT;
            default: uart_tx <= 1'b1;
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

module REG_uart_tx
(
    input  logic clk,
    input  logic nrst,
    input  logic uart_tx_pre,
    output logic uart_tx
);
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            uart_tx <= 1'b0;
        else
            uart_tx <= uart_tx_pre;
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

module REG_tx_done
(
    input  logic clk,
    input  logic nrst,
    input  logic [3:0] bps_cnt_q,
    output logic tx_done
);
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            tx_done <= 1'b0;
        else if (bps_cnt_q==4'd11)
            tx_done <= 1'b1;
        else 
            tx_done <= 1'b0;
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

module REG_uart_state 
(
    input  logic clk,
    input  logic nrst,
    input  logic send_en,
    input  logic [3:0] bps_cnt_q,
    output logic uart_state
);
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst)
            uart_state <= 1'b0;
        else if (send_en)
            uart_state <= 1'b1;
        else if (bps_cnt_q==4'd11)
            uart_state <= 1'b0;
        else 
            uart_state = uart_state;
    end

endmodule