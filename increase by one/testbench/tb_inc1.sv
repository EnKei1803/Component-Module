// Test bench for the combinational incrementer module inc1
`timescale 1ns / 1ps

module tb_inc1;

    // 1. Declarations for DUT inputs and outputs
    logic [23:0] a;
    logic        cin;
    
    logic [23:0] inc;
    logic        cout;

    // Expected values for verification
    logic [23:0] expected_inc;
    logic        expected_cout;

    // Test case counter and error count
    int test_count = 0;
    int error_count = 0;

    // 2. Instantiate the Device Under Test (DUT)
    inc1 dut (
        .a   (a),
        .cin (cin),
        .inc (inc),
        .cout(cout)
    );

    // Function to calculate the expected result for verification
    function void calculate_expected(logic [23:0] input_a, logic input_cin);
        // The expected operation is: a + cin
        // Use a 25-bit container to correctly capture the carry-out
        logic [24:0] result;
        result = {1'b0, input_a} + {24'h0, input_cin};

        expected_inc  = result[23:0];
        expected_cout = result[24];
    endfunction

    // Task to apply stimulus and check results
    // The 'verbose' argument controls detailed PASS logging
    task run_test(logic [23:0] input_a, logic input_cin, bit verbose);
        test_count++;
        
        // 1. Apply stimulus
        a   = input_a;
        cin = input_cin;

        // 2. Wait for stable combinational output (0 delay is sufficient)
        #1ns;

        // 3. Calculate expected values
        calculate_expected(a, cin);

        // 4. Verify results
        if ((inc === expected_inc) && (cout === expected_cout)) begin
            if (verbose) begin
                $display("--- Test %0d PASS ---", test_count);
                $display("Input A: 0x%h, Cin: %b => Output INC: 0x%h, COUT: %b | Expected INC: 0x%h, COUT: %b", 
                         a, cin, inc, cout, expected_inc, expected_cout);
                $display("");
            end
        end else begin
            $display("+++ Test %0d FAIL +++ (CRITICAL ERROR)", test_count);
            $display("Input A: 0x%h, Cin: %b => Output INC: 0x%h, COUT: %b | Expected INC: 0x%h, COUT: %b", 
                     a, cin, inc, cout, expected_inc, expected_cout);
            error_count++;
            $display("");
        end
    endtask

    // 3. Initial block for test execution
    initial begin
        // Variables for random testing
        int i;
        logic [23:0] rand_a;
        logic rand_cin;
        const int NUM_RANDOM_TESTS = 100000;

        $display("------------------------------------------------------------------");
        $display("Starting Test Bench for inc1 (24-bit Incrementer/Adder)");
        $display("------------------------------------------------------------------");

        // Initialize inputs to a known state
        a = 24'b0;
        cin = 1'b0;
        #5ns; // Initial stabilization time

        // --- Structured Tests (Boundary and Corner Cases) ---
        $display("--- Running Structured Tests (10 cases) ---");
        
        // Use VERBOSE mode (1) for these critical tests
        
        // Test Case 1: Simple Pass-through (cin = 0, no change)
        run_test(24'h000000, 0, 1);
        run_test(24'h123456, 0, 1);
        
        // Test Case 2: Simple Increment (cin = 1, increment by 1)
        run_test(24'h000000, 1, 1);
        run_test(24'h123456, 1, 1);
        
        // Test Case 3: Carry Propagation (AF->B0, BF->C0)
        run_test(24'hAFFFFF, 1, 1); 
        run_test(24'hBFFFFF, 1, 1); 
        
        // Test Case 4: Max value (2^24 - 1) - Boundary Check
        run_test(24'hFFFFFF, 0, 1); // FFFFFF + 0
        
        // Test Case 5: Max value with Wrap-around (Full carry chain, cout = 1)
        run_test(24'hFFFFFF, 1, 1); // FFFFFF + 1 = 000000, cout=1
        
        // Test Case 6: Test mid-range carry
        run_test(24'h00FFFF, 1, 1); 
        
        $display("--- Structured Tests Complete. Starting %0d Random Tests (Silent on Pass) ---", NUM_RANDOM_TESTS);

        // --- Random Tests (Non-Verbose Mode) ---
        for (i = 0; i < NUM_RANDOM_TESTS; i++) begin
            // Generate random 24-bit value for 'a'
            rand_a = $urandom;
            
            // Generate random 1-bit value for 'cin'
            rand_cin = $urandom_range(1, 0); 
            
            // Use NON-VERBOSE mode (0) for random tests. Only FAILURES will be displayed in detail.
            run_test(rand_a, rand_cin, 0);

            // Print progress every 1000 tests
            if (i % 1000 == 999) begin
                $display("-- Progress: %0d tests run...", i + 1);
            end
        end
        
        // Final Test Report
        $display("------------------------------------------------------------------");
        if (error_count == 0) begin
            $display("SUCCESS: All %0d tests passed!", test_count);
        end else begin
            $display("FAILURE: %0d out of %0d tests failed!", error_count, test_count);
        end
        $display("------------------------------------------------------------------");

        $stop; // End simulation
    end

endmodule
// Test bench for the combinational incrementer module inc1
`timescale 1ns / 1ps

module inc1_tb;

    // 1. Declarations for DUT inputs and outputs
    logic [23:0] a;
    logic        cin;
    
    logic [23:0] inc;
    logic        cout;

    // Expected values for verification
    logic [23:0] expected_inc;
    logic        expected_cout;

    // Test case counter and error count
    int test_count = 0;
    int error_count = 0;

    // 2. Instantiate the Device Under Test (DUT)
    inc1 dut (
        .a   (a),
        .cin (cin),
        .inc (inc),
        .cout(cout)
    );

    // Function to calculate the expected result for verification
    function void calculate_expected(logic [23:0] input_a, logic input_cin);
        // The expected operation is: a + cin
        // Use a 25-bit container to correctly capture the carry-out
        logic [24:0] result;
        result = {1'b0, input_a} + {24'h0, input_cin};

        expected_inc  = result[23:0];
        expected_cout = result[24];
    endfunction

    // Task to apply stimulus and check results
    // The 'verbose' argument controls detailed PASS logging
    task run_test(logic [23:0] input_a, logic input_cin, bit verbose);
        test_count++;
        
        // 1. Apply stimulus
        a   = input_a;
        cin = input_cin;

        // 2. Wait for stable combinational output (0 delay is sufficient)
        #1ns;

        // 3. Calculate expected values
        calculate_expected(a, cin);

        // 4. Verify results
        if ((inc === expected_inc) && (cout === expected_cout)) begin
            if (verbose) begin
                $display("--- Test %0d PASS ---", test_count);
                $display("Input A: 0x%h, Cin: %b => Output INC: 0x%h, COUT: %b | Expected INC: 0x%h, COUT: %b", 
                         a, cin, inc, cout, expected_inc, expected_cout);
                $display("");
            end
        end else begin
            $display("+++ Test %0d FAIL +++ (CRITICAL ERROR)", test_count);
            $display("Input A: 0x%h, Cin: %b => Output INC: 0x%h, COUT: %b | Expected INC: 0x%h, COUT: %b", 
                     a, cin, inc, cout, expected_inc, expected_cout);
            error_count++;
            $display("");
        end
    endtask

    // 3. Initial block for test execution
    initial begin
        // Variables for random testing
        int i;
        logic [23:0] rand_a;
        logic rand_cin;
        const int NUM_RANDOM_TESTS = 10000;

        $display("------------------------------------------------------------------");
        $display("Starting Test Bench for inc1 (24-bit Incrementer/Adder)");
        $display("------------------------------------------------------------------");

        // Initialize inputs to a known state
        a = 24'b0;
        cin = 1'b0;
        #5ns; // Initial stabilization time

        // --- Structured Tests (Boundary and Corner Cases) ---
        $display("--- Running Structured Tests (10 cases) ---");
        
        // Use VERBOSE mode (1) for these critical tests
        
        // Test Case 1: Simple Pass-through (cin = 0, no change)
        run_test(24'h000000, 0, 1);
        run_test(24'h123456, 0, 1);
        
        // Test Case 2: Simple Increment (cin = 1, increment by 1)
        run_test(24'h000000, 1, 1);
        run_test(24'h123456, 1, 1);
        
        // Test Case 3: Carry Propagation (AF->B0, BF->C0)
        run_test(24'hAFFFFF, 1, 1); 
        run_test(24'hBFFFFF, 1, 1); 
        
        // Test Case 4: Max value (2^24 - 1) - Boundary Check
        run_test(24'hFFFFFF, 0, 1); // FFFFFF + 0
        
        // Test Case 5: Max value with Wrap-around (Full carry chain, cout = 1)
        run_test(24'hFFFFFF, 1, 1); // FFFFFF + 1 = 000000, cout=1
        
        // Test Case 6: Test mid-range carry
        run_test(24'h00FFFF, 1, 1); 
        
        $display("--- Structured Tests Complete. Starting %0d Random Tests (Silent on Pass) ---", NUM_RANDOM_TESTS);

        // --- Random Tests (Non-Verbose Mode) ---
        for (i = 0; i < NUM_RANDOM_TESTS; i++) begin
            // Generate random 24-bit value for 'a'
            rand_a = $urandom;
            
            // Generate random 1-bit value for 'cin'
            rand_cin = $urandom_range(1, 0); 
            
            // Use NON-VERBOSE mode (0) for random tests. Only FAILURES will be displayed in detail.
            run_test(rand_a, rand_cin, 0);

            // Print progress every 1000 tests
            if (i % 1000 == 999) begin
                $display("-- Progress: %0d tests run...", i + 1);
            end
        end
        
        // Final Test Report
        $display("------------------------------------------------------------------");
        if (error_count == 0) begin
            $display("SUCCESS: All %0d tests passed!", test_count);
        end else begin
            $display("FAILURE: %0d out of %0d tests failed!", error_count, test_count);
        end
        $display("------------------------------------------------------------------");

        $stop; // End simulation
    end

endmodule
