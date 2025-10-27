`timescale 1ps/1ps
module tb_comparator_32bits;

    // Declare input and output signals
    logic [31:0] A, B;
    logic EQ, LT, GT;

    // Instantiate the Device Under Test (DUT)
    comparator_32bits dut (
        .operand_a(A),
        .operand_b(B),
        .o_eq(EQ),
        .o_lt(LT),
        .o_lt(GT)
    );

    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    // Task to check outputs against expected values
    task check_outputs;
        input [31:0] A_in, B_in;
        input exp_EQ, exp_LT, exp_GT;
        begin
            if (EQ !== exp_EQ || LT !== exp_LT || GT !== exp_GT) begin
                $display("Incorrect result at A = %h, B = %h", A_in, B_in);
                $display("Expected: EQ=%b, LT=%b, GT=%b", exp_EQ, exp_LT, exp_GT);
                $display("Got:      EQ=%b, LT=%b, GT=%b", EQ, LT, GT);
                fail_count = fail_count + 1;
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    initial begin
        // Test specific cases
        $display("Testing specific cases...");

        // Test case 1: A = B
        A = 32'h12345678; B = 32'h12345678; #10;
        check_outputs(A, B, 1, 0, 0); // EQ = 1, LT = 0, GT = 0

        // Test case 2: A < B (unsigned)
        A = 32'h00000001; B = 32'h00000002; #10;
        check_outputs(A, B, 0, 1, 0); // EQ = 0, LT = 1, GT = 0

        // Test case 3: A > B (unsigned)
        A = 32'h00000002; B = 32'h00000001; #10;
        check_outputs(A, B, 0, 0, 1); // EQ = 0, LT = 0, GT = 1

        // Test case 4: A < B (unsigned, large numbers)
        A = 32'h7FFFFFFF; B = 32'h80000000; #10;
        check_outputs(A, B, 0, 1, 0); // EQ = 0, LT = 1, GT = 0

        // Test case 5: A > B (unsigned, large numbers)
        A = 32'h80000000; B = 32'h7FFFFFFF; #10;
        check_outputs(A, B, 0, 0, 1); // EQ = 0, LT = 0, GT = 1

        // Test case 6: Edge case - all zeros vs all ones
        A = 32'h00000000; B = 32'hFFFFFFFF; #10;
        check_outputs(A, B, 0, 1, 0); // EQ = 0, LT = 1, GT = 0

        // Random testing
        $display("Testing with 100000 random inputs...");
        for (i = 0; i < 100000; i = i + 1) begin
            A = $random;    // Random 32-bit input A
            B = $random;    // Random 32-bit input B
            #10;

            // Calculate expected outputs (unsigned comparison)
            check_outputs(A, B,
                          (A == B),          // EQ
                          (A < B),           // LT (unsigned)
                          (A > B));          // GT (unsigned)
        end

        // Summary
        $display("Test Summary: %0d tests passed, %0d tests failed", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("[%t] --------------- SIMULATION PASS ---------------", $time);
        end else begin
            $display("[%t] --------------- SIMULATION FAIL ---------------", $time);
        end

        $stop;
    end

endmodule 