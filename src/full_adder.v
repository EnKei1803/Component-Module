/**
 * Module: full_adder
 * Description: 1-bit full adder implementation
 * 
 * This module implements a basic 1-bit full adder with carry in and carry out.
 * It serves as a fundamental building block for larger arithmetic circuits.
 * 
 * Author: EnKei1803
 * Date: 2025-10-27
 * License: MIT
 */

module full_adder (
    input  wire a,      // First input bit
    input  wire b,      // Second input bit
    input  wire cin,    // Carry in
    output wire sum,    // Sum output
    output wire cout    // Carry out
);

    // Sum is XOR of all inputs
    assign sum = a ^ b ^ cin;
    
    // Carry out logic
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
