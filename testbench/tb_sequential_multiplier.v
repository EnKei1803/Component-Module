// Testbench for Sequential Multiplier

`timescale 1ns/1ps

module tb_sequential_multiplier;

    parameter WIDTH = 8;
    parameter CLK_PERIOD = 10;
    
    reg clk, rst_n, start;
    reg [WIDTH-1:0] a, b;
    wire [2*WIDTH-1:0] product;
    wire done;
    
    // Instantiate the multiplier
    sequential_multiplier #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .product(product),
        .done(done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $display("Testing Sequential Multiplier");
        $display("Time\t a\t b\t product\t done");
        
        // Reset
        rst_n = 0;
        start = 0;
        a = 0;
        b = 0;
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD);
        
        // Test case 1: Simple multiplication
        a = 8'd5; b = 8'd3; start = 1;
        #(CLK_PERIOD);
        start = 0;
        wait(done);
        $display("%0t\t %d\t %d\t %d\t\t %b", $time, a, b, product, done);
        #(CLK_PERIOD*2);
        
        // Test case 2: Larger numbers
        a = 8'd15; b = 8'd10; start = 1;
        #(CLK_PERIOD);
        start = 0;
        wait(done);
        $display("%0t\t %d\t %d\t %d\t\t %b", $time, a, b, product, done);
        #(CLK_PERIOD*2);
        
        // Test case 3: Maximum values
        a = 8'd255; b = 8'd255; start = 1;
        #(CLK_PERIOD);
        start = 0;
        wait(done);
        $display("%0t\t %d\t %d\t %d\t\t %b", $time, a, b, product, done);
        #(CLK_PERIOD*2);
        
        // Test case 4: Multiply by zero
        a = 8'd10; b = 8'd0; start = 1;
        #(CLK_PERIOD);
        start = 0;
        wait(done);
        $display("%0t\t %d\t %d\t %d\t\t %b", $time, a, b, product, done);
        #(CLK_PERIOD*2);
        
        $display("\nAll tests completed");
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #(CLK_PERIOD * 1000);
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule
