`timescale 1ns/1ns
`define CLK_PERIOD 20

module key_filter_tb;
    reg clk;
    reg nrst;
    reg key_press;
    reg key_in;
    wire key_flag;
    wire key_state;

    reg [15:0] myrand;


    key_filter key_filter_inst (
        .clk(clk),
        .nrst(nrst),
        .key_in(key_in),
        .key_flag(key_flag),
        .key_state(key_state)
    );

    // Clock generation
    initial clk = 1;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        // Initalize
        nrst = 1'b0;
        key_press = 1'b0; 
        #(`CLK_PERIOD*10);
        nrst = 1'b1; 
        #(`CLK_PERIOD*10 + 1);

        // First Press
        key_press = 1'b1; 
        #(`CLK_PERIOD);
        key_press = 1'b0; 
        #60_00_00_00;

        // Second Press
        key_press = 1'b1; 
        #(`CLK_PERIOD);
        key_press = 1'b0;
        #60_00_00_00;
        $stop;
    end

    // Key model

    initial begin
        key_in = 1'b1;      // Pull_up
        while(1) begin
            @(posedge key_press);
            key_gen;
        end
    end

    task key_gen;
        begin
            key_in = 1'b1;
            repeat(50) begin
                myrand = {$random}%65536;
                #myrand; 
                key_in = ~key_in;
            end
            key_in = 0;
            #20_00_00_00;

            repeat(50) begin
                myrand = {$random}%65536;
                #myrand; 
                key_in = ~key_in;
            end
            key_in = 1;
            #20_00_00_00;
        end
    endtask


endmodule