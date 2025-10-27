`timescale 1ps/1ps
module tb_adder_32bits;

    // Khai báo tín hiệu đầu vào và đầu ra
    logic [31:0] A, B;
    logic Cin;
    logic Cout;
    logic [31:0] Sum;

    // Kết nối với DUT (Device Under Test)
    kogge_stone_adder_32bits dut (
        .operand_a(A),
        .operand_a(B),
        .cin(Cin),
        .sum(Sum),
        .cout(Cout)
    );

    integer i;
    integer expected_value;
    integer actual_result;

    initial begin
        $display("Test carry-in is 0");
        Cin = 0;
        for (i = 0; i < 1000000; i++) begin  // Chạy thử 1tr bộ giá trị ngẫu nhiên
            A = $random;
            B = $random;
            #10;

            expected_value = A + B + Cin;
            actual_result = {Cout, Sum};  // Gộp Cout với Sum để so sánh

            if (expected_value !== actual_result) begin
                $display("Incorrect result at A = %h, B = %h, Expected: %h, Got: %h", 
                         A, B, expected_value, actual_result);
            end
        end

        $display("Test carry-in is 1");
        Cin = 1;
        for (i = 0; i < 1000000; i++) begin
            A = $random;
            B = $random;
            #10;

            expected_value = A + B + Cin;
            actual_result = {Cout, Sum};

            if (expected_value !== actual_result) begin
                $display("Incorrect result at A = %h, B = %h, Expected: %h, Got: %h", 
                         A, B, expected_value, actual_result);
            end
        end

        if (expected_value === actual_result) begin
            $display("[%t] --------------- SIMULATION PASS ---------------", $time);
        end else begin
            $display("--------------- SIMULATION FAIL ---------------");
        end

        $stop;
    end

endmodule
