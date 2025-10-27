// Simplified Floating Point Adder
// A simpler version for educational purposes
// Uses 16-bit custom format: Sign (1) | Exponent (5) | Mantissa (10)

module fp_adder_simple #(
    parameter EXP_WIDTH = 5,
    parameter MANT_WIDTH = 10
)(
    input  [15:0] a,           // First operand
    input  [15:0] b,           // Second operand
    output [15:0] result       // Result
);

    localparam TOTAL_WIDTH = 1 + EXP_WIDTH + MANT_WIDTH;
    
    // Extract fields
    wire sign_a = a[15];
    wire sign_b = b[15];
    wire [EXP_WIDTH-1:0] exp_a = a[14:10];
    wire [EXP_WIDTH-1:0] exp_b = b[14:10];
    wire [MANT_WIDTH-1:0] mant_a = a[9:0];
    wire [MANT_WIDTH-1:0] mant_b = b[9:0];
    
    // Add implicit leading 1
    wire [MANT_WIDTH:0] frac_a = {1'b1, mant_a};
    wire [MANT_WIDTH:0] frac_b = {1'b1, mant_b};
    
    // Align exponents
    wire [EXP_WIDTH-1:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire a_larger = exp_a >= exp_b;
    
    wire [EXP_WIDTH-1:0] exp_result = a_larger ? exp_a : exp_b;
    wire [MANT_WIDTH:0] frac_aligned_a = a_larger ? frac_a : (frac_a >> exp_diff);
    wire [MANT_WIDTH:0] frac_aligned_b = a_larger ? (frac_b >> exp_diff) : frac_b;
    
    // Add or subtract mantissas
    wire [MANT_WIDTH+1:0] mant_sum;
    wire effective_sub = sign_a ^ sign_b;
    
    assign mant_sum = effective_sub ? 
                      (frac_aligned_a - frac_aligned_b) :
                      (frac_aligned_a + frac_aligned_b);
    
    // Determine sign
    wire sign_result = a_larger ? sign_a : sign_b;
    
    // Simple normalization
    wire [EXP_WIDTH-1:0] exp_normalized = mant_sum[MANT_WIDTH+1] ? 
                                          (exp_result + 1) : exp_result;
    wire [MANT_WIDTH:0] mant_normalized = mant_sum[MANT_WIDTH+1] ? 
                                          mant_sum[MANT_WIDTH+1:1] : mant_sum[MANT_WIDTH:0];
    
    // Assemble result
    assign result = {sign_result, exp_normalized, mant_normalized[MANT_WIDTH-1:0]};

endmodule
