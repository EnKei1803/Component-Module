// Testbench for Adder-Subtractor

`timescale 1ns/1ps

module tb_adder_subtractor;

    parameter WIDTH = 8;
    
    reg [WIDTH-1:0] a, b;
    reg mode, cin;
    wire [WIDTH-1:0] result;
    wire cout, overflow;
    
    // Instantiate the adder-subtractor
    adder_subtractor #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .mode(mode),
        .cin(cin),
        .result(result),
        .cout(cout),
        .overflow(overflow)
    );
    
    // Test stimulus
    initial begin
        $display("Testing Adder-Subtractor");
        $display("Time\t Mode\t a\t b\t result\t cout\t ovf");
        
        // Test case 1: Addition
        a = 8'd10; b = 8'd5; mode = 0; cin = 0;
        #10;
        $display("%0t\t ADD\t %d\t %d\t %d\t %b\t %b", $time, a, b, result, cout, overflow);
        
        // Test case 2: Subtraction
        a = 8'd10; b = 8'd5; mode = 1; cin = 0;
        #10;
        $display("%0t\t SUB\t %d\t %d\t %d\t %b\t %b", $time, a, b, result, cout, overflow);
        
        // Test case 3: Addition overflow
        a = 8'hFF; b = 8'h01; mode = 0; cin = 0;
        #10;
        $display("%0t\t ADD\t %h\t %h\t %h\t %b\t %b", $time, a, b, result, cout, overflow);
        
        // Test case 4: Subtraction negative result
        a = 8'd5; b = 8'd10; mode = 1; cin = 0;
        #10;
        $display("%0t\t SUB\t %d\t %d\t %d\t %b\t %b", $time, a, b, result, cout, overflow);
        
        // Test case 5: Signed overflow in addition
        a = 8'h7F; b = 8'h01; mode = 0; cin = 0;
        #10;
        $display("%0t\t ADD\t %h\t %h\t %h\t %b\t %b", $time, a, b, result, cout, overflow);
        
        $display("\nAll tests completed");
        $finish;
    end

endmodule
