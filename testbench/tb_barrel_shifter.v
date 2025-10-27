// Testbench for Barrel Shifter

`timescale 1ns/1ps

module tb_barrel_shifter;

    parameter WIDTH = 8;
    
    reg [WIDTH-1:0] data_in;
    reg [$clog2(WIDTH)-1:0] shift_amt;
    reg [2:0] shift_type;
    wire [WIDTH-1:0] data_out;
    
    // Instantiate the shifter
    barrel_shifter #(.WIDTH(WIDTH)) dut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .shift_type(shift_type),
        .data_out(data_out)
    );
    
    // Test stimulus
    initial begin
        $display("Testing Barrel Shifter");
        $display("Time\t Type\t\t Data_in\t Shift\t Data_out");
        
        // Test case 1: Logical left shift
        data_in = 8'b00001111; shift_amt = 2; shift_type = 3'b000;
        #10;
        $display("%0t\t LogLeft\t %b\t %d\t %b", $time, data_in, shift_amt, data_out);
        
        // Test case 2: Logical right shift
        data_in = 8'b11110000; shift_amt = 2; shift_type = 3'b001;
        #10;
        $display("%0t\t LogRight\t %b\t %d\t %b", $time, data_in, shift_amt, data_out);
        
        // Test case 3: Arithmetic right shift
        data_in = 8'b11110000; shift_amt = 2; shift_type = 3'b010;
        #10;
        $display("%0t\t ArithRight\t %b\t %d\t %b", $time, data_in, shift_amt, data_out);
        
        // Test case 4: Rotate left
        data_in = 8'b11000011; shift_amt = 3; shift_type = 3'b011;
        #10;
        $display("%0t\t RotLeft\t %b\t %d\t %b", $time, data_in, shift_amt, data_out);
        
        // Test case 5: Rotate right
        data_in = 8'b11000011; shift_amt = 3; shift_type = 3'b100;
        #10;
        $display("%0t\t RotRight\t %b\t %d\t %b", $time, data_in, shift_amt, data_out);
        
        $display("\nAll tests completed");
        $finish;
    end

endmodule
