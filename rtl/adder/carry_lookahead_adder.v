// Carry Lookahead Adder
// Faster adder that computes carries in parallel
// Better performance for larger bit widths

module carry_lookahead_adder #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,      // First operand
    input  [WIDTH-1:0] b,      // Second operand
    input              cin,    // Carry input
    output [WIDTH-1:0] sum,    // Sum output
    output             cout    // Carry output
);

    wire [WIDTH-1:0] g;  // Generate
    wire [WIDTH-1:0] p;  // Propagate
    wire [WIDTH:0] c;    // Carry
    
    // Generate and Propagate
    assign g = a & b;
    assign p = a ^ b;
    
    // Carry logic
    assign c[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_logic
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    
    // Sum calculation
    assign sum = p ^ c[WIDTH-1:0];
    assign cout = c[WIDTH];

endmodule
