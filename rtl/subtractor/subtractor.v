// Subtractor Module
// Performs A - B using 2's complement addition (A + (~B) + 1)
// Supports both signed and unsigned subtraction
// Dependencies: ripple_carry_adder (from ripple_carry_adder.v)

module subtractor #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,        // Minuend
    input  [WIDTH-1:0] b,        // Subtrahend
    input              borrow_in, // Borrow input (0 for normal subtraction)
    output [WIDTH-1:0] diff,     // Difference output
    output             borrow_out // Borrow output
);

    wire [WIDTH-1:0] b_complement;
    wire [WIDTH-1:0] sum;
    wire cout;
    
    // Create 1's complement of b
    assign b_complement = ~b;
    
    // Add a + (~b) + 1 (where the 1 comes from ~borrow_in)
    ripple_carry_adder #(.WIDTH(WIDTH)) adder (
        .a(a),
        .b(b_complement),
        .cin(~borrow_in),  // For normal subtraction, this is 1
        .sum(sum),
        .cout(cout)
    );
    
    assign diff = sum;
    assign borrow_out = ~cout;

endmodule

// Full Subtractor - basic building block
module full_subtractor (
    input  a,
    input  b,
    input  bin,    // Borrow in
    output diff,
    output bout    // Borrow out
);

    assign diff = a ^ b ^ bin;
    assign bout = (~a & b) | (~a & bin) | (b & bin);

endmodule
