// Testbench for Ripple Carry Adder

`timescale 1ns/1ps

module tb_ripple_carry_adder;

    parameter WIDTH = 8;
    
    reg [WIDTH-1:0] a, b;
    reg cin;
    wire [WIDTH-1:0] sum;
    wire cout;
    
    // Instantiate the adder
    ripple_carry_adder #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    // Test stimulus
    initial begin
        $display("Testing Ripple Carry Adder");
        $display("Time\t a\t b\tcin\t sum\tcout");
        $monitor("%0t\t %h\t %h\t %b\t %h\t %b", $time, a, b, cin, sum, cout);
        
        // Test case 1: Simple addition
        a = 8'h0F; b = 8'h01; cin = 0;
        #10;
        
        // Test case 2: Addition with carry
        a = 8'hFF; b = 8'h01; cin = 0;
        #10;
        
        // Test case 3: Maximum values
        a = 8'hFF; b = 8'hFF; cin = 0;
        #10;
        
        // Test case 4: With carry in
        a = 8'h7F; b = 8'h7F; cin = 1;
        #10;
        
        // Test case 5: Zero addition
        a = 8'h00; b = 8'h00; cin = 0;
        #10;
        
        $display("\nAll tests completed");
        $finish;
    end

endmodule
