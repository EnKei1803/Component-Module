// Adder-Subtractor Module
// Combined module that can perform both addition and subtraction
// Control signal determines the operation

module adder_subtractor #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,        // First operand
    input  [WIDTH-1:0] b,        // Second operand
    input              mode,     // 0 = Add, 1 = Subtract
    input              cin,      // Carry/Borrow input
    output [WIDTH-1:0] result,   // Result output
    output             cout,     // Carry/Borrow output
    output             overflow  // Overflow flag for signed operations
);

    wire [WIDTH-1:0] b_modified;
    wire [WIDTH-1:0] sum;
    wire carry_out;
    
    // XOR b with mode: if mode=0 (add), b_modified=b; if mode=1 (subtract), b_modified=~b
    assign b_modified = b ^ {WIDTH{mode}};
    
    // Use adder for both operations
    carry_lookahead_adder #(.WIDTH(WIDTH)) adder (
        .a(a),
        .b(b_modified),
        .cin(cin ^ mode),  // For subtraction, we need cin=1 for 2's complement
        .sum(sum),
        .cout(carry_out)
    );
    
    assign result = sum;
    assign cout = carry_out;
    
    // Overflow detection for signed arithmetic
    // Overflow occurs when:
    // - Adding two positive numbers gives negative result
    // - Adding two negative numbers gives positive result
    assign overflow = (a[WIDTH-1] == b_modified[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);

endmodule
