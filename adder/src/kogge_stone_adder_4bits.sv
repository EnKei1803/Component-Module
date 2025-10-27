module kogge_stone_adder_4bits
(
    input logic	[3:0]	operand_a, 
	 input logic	[3:0]	operand_b,
    output logic	[3:0]	sum,
    output logic			cout
);

    logic [4:1] G, P;   // Generate & Propagate
    logic [4:1] C;      // Carry

    // Pre-processing
    assign G = operand_a & operand_b;
    assign P = operand_a ^ operand_b;

    // Cin = 0
    assign C[1] = G[1];

    // Level 1
    logic G1_2, P1_2;
    black_cell BC1_2 (P[1], G[1], P[2], G[2], P1_2, G1_2);
    gray_cell  GC2   (C[1], P1_2, G1_2, C[2]);

    // Level 2
    logic G2_3, P2_3;
    black_cell BC2_3 (P1_2, G1_2, P[3], G[3], P2_3, G2_3);
    gray_cell  GC3   (C[1], P2_3, G2_3, C[3]);

    logic G3_4, P3_4;
    black_cell BC2_4 (P2_3, G2_3, P[4], G[4], P3_4, G3_4);
    gray_cell  GC4   (C[1], P3_4, G3_4, C[4]);

    // Post-processing: sum and carry out
    assign sum[0] = P[1];        
    assign sum[1] = C[1] ^ P[2];
    assign sum[2] = C[2] ^ P[3];
    assign sum[3] = C[3] ^ P[4];
    assign cout   = C[4];

endmodule 
