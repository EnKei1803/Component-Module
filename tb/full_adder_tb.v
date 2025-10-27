/**
 * Testbench: full_adder_tb
 * Description: Testbench for 1-bit full adder
 * 
 * This testbench verifies the functionality of the full_adder module
 * by testing all possible input combinations.
 * 
 * Author: EnKei1803
 * Date: 2025-10-27
 */

`timescale 1ns / 1ps

module full_adder_tb;

    // Testbench signals
    reg a;
    reg b;
    reg cin;
    wire sum;
    wire cout;
    
    // Test result counter
    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate the Unit Under Test (UUT)
    full_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // Task to check result
    task check_result;
        input expected_sum;
        input expected_cout;
        begin
            #1; // Wait for propagation
            if (sum === expected_sum && cout === expected_cout) begin
                $display("PASS: a=%b b=%b cin=%b => sum=%b cout=%b", a, b, cin, sum, cout);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: a=%b b=%b cin=%b => Expected: sum=%b cout=%b, Got: sum=%b cout=%b", 
                         a, b, cin, expected_sum, expected_cout, sum, cout);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Test stimulus
    initial begin
        $display("Starting Full Adder Testbench");
        $display("================================");
        
        // Test all 8 input combinations
        a = 0; b = 0; cin = 0; check_result(0, 0);
        a = 0; b = 0; cin = 1; check_result(1, 0);
        a = 0; b = 1; cin = 0; check_result(1, 0);
        a = 0; b = 1; cin = 1; check_result(0, 1);
        a = 1; b = 0; cin = 0; check_result(1, 0);
        a = 1; b = 0; cin = 1; check_result(0, 1);
        a = 1; b = 1; cin = 0; check_result(0, 1);
        a = 1; b = 1; cin = 1; check_result(1, 1);
        
        // Display test summary
        $display("================================");
        $display("Test Summary:");
        $display("PASSED: %0d", pass_count);
        $display("FAILED: %0d", fail_count);
        
        if (fail_count == 0)
            $display("All tests PASSED!");
        else
            $display("Some tests FAILED!");
        
        $finish;
    end

endmodule
