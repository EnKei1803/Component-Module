`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2026 11:52:08 PM
// Design Name: 
// Module Name: debounce_key
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


module debounce_key(
    input  logic clk,
    input  logic nrst,
    input  logic key_in,

    output logic key_out
);


// ============= KEY EDGE DETECT =============

logic key_in_sync1,   key_in_sync2;
logic key_in_reg1,    key_in_reg2;
logic key_in_negedge, key_in_posedge;
logic key_flag;                         // Switching state flag
logic key_state;                        // Press status  


assign key_out = key_flag & !key_state;

always_ff @(posedge clk or negedge nrst) 
    if (!nrst) begin
        key_in_sync1 <= 1'b0;
        key_in_sync2 <= 1'b0;
    end
    else begin
        key_in_sync1 <= key_in;
        key_in_sync2 <= key_in_sync1;
end

always_ff @(posedge clk or negedge nrst) 
    if (!nrst) begin
        key_in_reg1 <= 1'b0;
        key_in_reg2 <= 1'b0;
    end
    else begin
        key_in_reg1 <= key_in_sync2;
        key_in_reg2 <= key_in_reg1;
end

// Edge Detect
assign  key_in_negedge = !key_in_sync1 & key_in_sync2;
assign  key_in_posedge = key_in_sync1 & !key_in_sync2;

// ============= COUNTER(20ms) =============

logic [19:0] cnt;
logic en_cnt;
logic cnt_full;

always_ff @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        cnt <= 20'd0;
    end
    else if(en_cnt) begin
        cnt <= cnt + 1'b1;
    end
end

always_ff @(posedge clk or negedge nrst) begin
    if(!nrst) begin
        cnt_full <= 1'b0;
    end
    else if(cnt == 20'd999_999) begin
        cnt_full <= 1'b1;
    end
    else begin
        cnt_full <= 1'b0;
    end
end
// ============= KEY FILTER FSM =============

localparam  IDLE    =   4'b0001;
localparam  FILTER0 =   4'b0010;
localparam  DOWN    =   4'b0100;
localparam  FILTER1 =   4'b1000;

logic [3:0]   state;

    // FSM
    always_ff @(posedge clk or negedge nrst) begin
        if(!nrst) begin
            en_cnt      <= 1'b0;
            state       <= IDLE;
            key_flag    <= 1'b0;
            key_state   <= 1'b1;
        end
        else begin
            case(state)

        // State 1: IDLE
            IDLE: begin
                key_flag    <= 1'b0;
                if(key_in_negedge) begin
                    state   <= FILTER0;
                    en_cnt  <= 1'b1;
                end
                else
                    state <= IDLE;
            end

        // State 2: FILTER0
            FILTER0: begin
                if(cnt_full) begin
                    key_flag    <= 1'b1;
                    key_state   <= 1'b0;
                    en_cnt      <= 1'b0;
                    state       <= DOWN;
                end
                else if(key_in_posedge) begin
                    state   <= IDLE;
                    en_cnt  <= 1'b0;
                end
                else
                    state   <= FILTER0;
            end

        // State 3: DOWN
            DOWN: begin
                key_flag    <= 1'b0;
                if(key_in_posedge) begin
                    state   <= FILTER1;
                    en_cnt  <= 1'b1;
                end
                else
                    state   <= DOWN;
            end

        // State 4: FILTER1
            FILTER1: begin
                if(cnt_full) begin
                    key_flag    <= 1'b1;
                    key_state   <= 1'b1;
                    state       <= IDLE;
                    en_cnt      <= 1'b0;
                end
                else if(key_in_negedge) begin
                    en_cnt  <= 1'b0;
                    state   <= DOWN;
                end
                else
                    state   <= FILTER1;
            end

            default: begin
                state       <= IDLE;
                en_cnt      <= 1'b0;
                key_flag    <= 1'b0;
                key_state   <= 1'b1;
            end
        endcase
    end
end


endmodule 

