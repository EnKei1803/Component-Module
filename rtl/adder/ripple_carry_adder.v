// Ripple Carry Adder
// A simple N-bit adder where carry propagates through all stages
// Good for understanding but slower for large bit widths

module ripple_carry_adder #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,      // First operand
    input  [WIDTH-1:0] b,      // Second operand
    input              cin,    // Carry input
    output [WIDTH-1:0] sum,    // Sum output
    output             cout    // Carry output
);

    wire [WIDTH:0] carry;
    
    assign carry[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : adder_stage
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    assign cout = carry[WIDTH];

endmodule

// Full Adder - basic building block
module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
