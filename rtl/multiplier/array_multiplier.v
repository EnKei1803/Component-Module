// Array Multiplier
// Uses an array of AND gates and adders
// Generates partial products and sums them
// Good for understanding but not optimal for area/speed

module array_multiplier #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,           // Multiplicand
    input  [WIDTH-1:0] b,           // Multiplier
    output [2*WIDTH-1:0] product    // Product output
);

    // Partial products
    wire [WIDTH-1:0] pp [WIDTH-1:0];
    
    // Generate partial products
    genvar i, j;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : pp_gen
            for (j = 0; j < WIDTH; j = j + 1) begin : pp_bit
                assign pp[i][j] = a[j] & b[i];
            end
        end
    endgenerate
    
    // Sum partial products
    wire [2*WIDTH-1:0] sum [WIDTH:0];
    assign sum[0] = {{WIDTH{1'b0}}, pp[0]};
    
    generate
        for (i = 1; i < WIDTH; i = i + 1) begin : pp_sum
            wire [2*WIDTH-1:0] pp_shifted;
            wire [2*WIDTH-1:0] sum_result;
            wire cout;
            
            assign pp_shifted = {{WIDTH{1'b0}}, pp[i]} << i;
            
            // Add shifted partial product to accumulated sum
            ripple_carry_adder #(.WIDTH(2*WIDTH)) adder (
                .a(sum[i-1]),
                .b(pp_shifted),
                .cin(1'b0),
                .sum(sum_result),
                .cout(cout)
            );
            
            assign sum[i] = sum_result;
        end
    endgenerate
    
    assign product = sum[WIDTH-1];

endmodule
