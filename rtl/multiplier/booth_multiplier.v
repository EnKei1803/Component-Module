// Booth Multiplier (Radix-2)
// Uses Booth's algorithm to reduce the number of additions
// More efficient for signed multiplication
// Handles both positive and negative numbers
// Note: Uses for-loop in always block. Ensure your synthesis tool supports this construct.
//       For maximum compatibility, consider using a generate block or state machine implementation.

module booth_multiplier #(
    parameter WIDTH = 8
)(
    input  signed [WIDTH-1:0] a,           // Multiplicand
    input  signed [WIDTH-1:0] b,           // Multiplier
    output signed [2*WIDTH-1:0] product    // Product output
);

    reg signed [2*WIDTH-1:0] multiplicand;
    reg signed [2*WIDTH-1:0] result;
    reg [WIDTH:0] multiplier;
    integer i;
    
    always @(*) begin
        // Initialize
        multiplicand = {{WIDTH{a[WIDTH-1]}}, a};  // Sign extend
        multiplier = {b, 1'b0};
        result = {2*WIDTH{1'b0}};
        
        // Booth's algorithm
        for (i = 0; i < WIDTH; i = i + 1) begin
            case (multiplier[1:0])
                2'b01: result = result + (multiplicand << i);
                2'b10: result = result - (multiplicand << i);
                // 2'b00 and 2'b11: no operation
                default: result = result;
            endcase
            multiplier = multiplier >> 1;
        end
    end
    
    assign product = result;

endmodule
