// Floating Point Adder (IEEE 754 Single Precision)
// Adds two 32-bit floating point numbers
// Format: Sign (1 bit) | Exponent (8 bits) | Mantissa (23 bits)

module fp_adder (
    input  [31:0] a,           // First operand (IEEE 754)
    input  [31:0] b,           // Second operand (IEEE 754)
    output [31:0] result,      // Result (IEEE 754)
    output        overflow,    // Overflow flag
    output        underflow    // Underflow flag
);

    // Extract fields
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] mant_a = a[22:0];
    wire [22:0] mant_b = b[22:0];
    
    // Add implicit leading 1 for normalized numbers
    wire [23:0] frac_a = {1'b1, mant_a};
    wire [23:0] frac_b = {1'b1, mant_b};
    
    // Determine larger exponent
    wire [7:0] exp_diff;
    wire a_larger;
    wire [7:0] exp_large, exp_small;
    wire [23:0] frac_large, frac_small;
    wire sign_large, sign_small;
    
    assign a_larger = (exp_a > exp_b) || ((exp_a == exp_b) && (mant_a >= mant_b));
    assign exp_diff = a_larger ? (exp_a - exp_b) : (exp_b - exp_a);
    
    assign exp_large = a_larger ? exp_a : exp_b;
    assign exp_small = a_larger ? exp_b : exp_a;
    assign frac_large = a_larger ? frac_a : frac_b;
    assign frac_small = a_larger ? frac_b : frac_a;
    assign sign_large = a_larger ? sign_a : sign_b;
    assign sign_small = a_larger ? sign_b : sign_a;
    
    // Align mantissas by shifting smaller one
    wire [23:0] frac_small_shifted;
    assign frac_small_shifted = (exp_diff >= 24) ? 24'b0 : (frac_small >> exp_diff);
    
    // Add or subtract based on signs
    wire [24:0] frac_result_temp;
    wire effective_sub = sign_large ^ sign_small;
    
    assign frac_result_temp = effective_sub ? 
                              ({1'b0, frac_large} - {1'b0, frac_small_shifted}) :
                              ({1'b0, frac_large} + {1'b0, frac_small_shifted});
    
    // Normalize result
    reg [7:0] exp_result;
    reg [23:0] frac_result;
    reg sign_result;
    
    always @(*) begin
        sign_result = sign_large;
        exp_result = exp_large;
        frac_result = frac_result_temp[23:0];
        
        // Check for overflow in addition
        if (frac_result_temp[24]) begin
            frac_result = frac_result_temp[24:1];
            exp_result = exp_large + 1;
        end
        // Normalize if MSB is not 1 (for subtraction case)
        else if (!frac_result_temp[23] && frac_result_temp != 0) begin
            // Count leading zeros and shift
            if (frac_result_temp[22]) begin
                frac_result = frac_result_temp[23:0] << 1;
                exp_result = exp_large - 1;
            end else if (frac_result_temp[21]) begin
                frac_result = frac_result_temp[23:0] << 2;
                exp_result = exp_large - 2;
            end else if (frac_result_temp[20]) begin
                frac_result = frac_result_temp[23:0] << 3;
                exp_result = exp_large - 3;
            end
            // Add more cases for better normalization or use a priority encoder
        end
    end
    
    // Check for special cases
    wire is_zero = (frac_result == 24'b0);
    wire exp_overflow = (exp_result >= 8'hFF);
    wire exp_underflow = (exp_result == 8'h00);
    
    // Construct result
    assign result = is_zero ? 32'b0 : {sign_result, exp_result, frac_result[22:0]};
    assign overflow = exp_overflow;
    assign underflow = exp_underflow && !is_zero;

endmodule
