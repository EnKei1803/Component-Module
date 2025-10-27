module kogge_stone_adder_8bits
(
    input  logic [7:0]  operand_a,
    input  logic [7:0]  operand_b,
    input  logic        cin,

    output logic [7:0]  sum,
    output logic        cout
);

    // Note: keep 1-based indexing like your 32-bit code
    logic [8:1] G, P;     // bit-Generate/Propagate for bits [1]=LSB ... [8]=MSB
    logic [8:1] C;        // carries into bits 1..8

    // Pre-process
    assign G = operand_a & operand_b;
    assign P = operand_a ^ operand_b;

    // Intermediate prefix levels
    logic [8:3]  G1, P1;  // distance-1 combine
    logic [8:5]  G2, P2;  // distance-2 combine

    // ----------------
    // Level 1 (distance 1)
    // ----------------
    assign C[1] = G[1] | (P[1] & cin);
    gray_cell  u_gc_02 (C[1], P[2], G[2], C[2]);

    // black cells: combine (i-1) with i  → G1[i], P1[i] for i=3..8
    black_cell u_bc_1_03 (P[2], G[2], P[3], G[3], P1[3], G1[3]);
    black_cell u_bc_1_04 (P[3], G[3], P[4], G[4], P1[4], G1[4]);
    black_cell u_bc_1_05 (P[4], G[4], P[5], G[5], P1[5], G1[5]);
    black_cell u_bc_1_06 (P[5], G[5], P[6], G[6], P1[6], G1[6]);
    black_cell u_bc_1_07 (P[6], G[6], P[7], G[7], P1[7], G1[7]);
    black_cell u_bc_1_08 (P[7], G[7], P[8], G[8], P1[8], G1[8]);

    // ----------------
    // Level 2 (distance 2)
    // ----------------
    gray_cell  u_gc_03 (C[1], P1[3], G1[3], C[3]);
    gray_cell  u_gc_04 (C[2], P1[4], G1[4], C[4]);

    // combine (i-2) with i → G2[i], P2[i] for i=5..8
    black_cell u_bc_2_05 (P1[3], G1[3], P1[5], G1[5], P2[5], G2[5]);
    black_cell u_bc_2_06 (P1[4], G1[4], P1[6], G1[6], P2[6], G2[6]);
    black_cell u_bc_2_07 (P1[5], G1[5], P1[7], G1[7], P2[7], G2[7]);
    black_cell u_bc_2_08 (P1[6], G1[6], P1[8], G1[8], P2[8], G2[8]);

    // ----------------
    // Level 3 (distance 4)
    // ----------------
    gray_cell  u_gc_05 (C[1], P2[5], G2[5], C[5]);
    gray_cell  u_gc_06 (C[2], P2[6], G2[6], C[6]);
    gray_cell  u_gc_07 (C[3], P2[7], G2[7], C[7]);
    gray_cell  u_gc_08 (C[4], P2[8], G2[8], C[8]);

    // Post-process: sum/cout
    assign sum[0]   = cin ^ P[1];
    assign sum[7:1] = C[7:1] ^ P[8:2];
    assign cout     = C[8];

endmodule