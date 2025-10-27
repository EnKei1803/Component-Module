// Carry Select Adder
// Uses multiple adders and a multiplexer to improve speed
// Computes sum for both cin=0 and cin=1, then selects based on actual carry
// Dependencies: full_adder (from ripple_carry_adder.v)

module carry_select_adder #(
    parameter WIDTH = 8,
    parameter BLOCK_SIZE = 4
)(
    input  [WIDTH-1:0] a,      // First operand
    input  [WIDTH-1:0] b,      // Second operand
    input              cin,    // Carry input
    output [WIDTH-1:0] sum,    // Sum output
    output             cout    // Carry output
);

    localparam NUM_BLOCKS = (WIDTH + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    wire [NUM_BLOCKS:0] block_carry;
    wire [WIDTH-1:0] sum_temp;
    
    assign block_carry[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : select_block
            localparam START_BIT = i * BLOCK_SIZE;
            localparam END_BIT = (START_BIT + BLOCK_SIZE > WIDTH) ? WIDTH : START_BIT + BLOCK_SIZE;
            localparam CURRENT_WIDTH = END_BIT - START_BIT;
            
            if (i == 0) begin
                // First block: simple ripple carry adder
                wire [CURRENT_WIDTH:0] carry_chain;
                assign carry_chain[0] = block_carry[i];
                
                genvar j;
                for (j = 0; j < CURRENT_WIDTH; j = j + 1) begin : first_block_adder
                    full_adder fa (
                        .a(a[START_BIT + j]),
                        .b(b[START_BIT + j]),
                        .cin(carry_chain[j]),
                        .sum(sum_temp[START_BIT + j]),
                        .cout(carry_chain[j+1])
                    );
                end
                assign block_carry[i+1] = carry_chain[CURRENT_WIDTH];
            end else begin
                // Other blocks: dual computation with mux selection
                wire [CURRENT_WIDTH-1:0] sum0, sum1;
                wire cout0, cout1;
                
                // Compute assuming carry-in = 0
                wire [CURRENT_WIDTH:0] carry0;
                assign carry0[0] = 1'b0;
                genvar j;
                for (j = 0; j < CURRENT_WIDTH; j = j + 1) begin : carry0_adder
                    full_adder fa0 (
                        .a(a[START_BIT + j]),
                        .b(b[START_BIT + j]),
                        .cin(carry0[j]),
                        .sum(sum0[j]),
                        .cout(carry0[j+1])
                    );
                end
                assign cout0 = carry0[CURRENT_WIDTH];
                
                // Compute assuming carry-in = 1
                wire [CURRENT_WIDTH:0] carry1;
                assign carry1[0] = 1'b1;
                for (j = 0; j < CURRENT_WIDTH; j = j + 1) begin : carry1_adder
                    full_adder fa1 (
                        .a(a[START_BIT + j]),
                        .b(b[START_BIT + j]),
                        .cin(carry1[j]),
                        .sum(sum1[j]),
                        .cout(carry1[j+1])
                    );
                end
                assign cout1 = carry1[CURRENT_WIDTH];
                
                // Select based on actual carry
                assign sum_temp[END_BIT-1:START_BIT] = block_carry[i] ? sum1 : sum0;
                assign block_carry[i+1] = block_carry[i] ? cout1 : cout0;
            end
        end
    endgenerate
    
    assign sum = sum_temp;
    assign cout = block_carry[NUM_BLOCKS];

endmodule
