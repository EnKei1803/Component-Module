module kogge_stone_adder_16bits
(
    input  logic [15:0] operand_a,
    input  logic [15:0] operand_b,
    input  logic        cin,

    output logic [15:0] sum,
    output logic        cout
);
    // Pre-processing: bitwise Generate/Propagate
    logic [16:1] G, P;    // 1-based to mirror your 32-bit adder
    logic [16:1] C;

    assign G = operand_a & operand_b;
    assign P = operand_a ^ operand_b;

    // -------- Prefix network (4 levels for 16 bits) --------
    // Level 1 spans 1
    logic [16:3] G1, P1;
    // Level 2 spans 2
    logic [16:5] G2, P2;
    // Level 3 spans 4
    logic [16:9] G3, P3;

    // -------- Level 1 --------
    assign C[1] = G[1] | (P[1] & cin);               // gray for bit1 (carry into bit1)

    gray_cell  gray_cell_02 (C[1], P[2], G[2], C[2]);

    // black cells combining (i-1, i) → (P1[i], G1[i]) for i=3..16
    black_cell black_cell_1_03 (P[2],  G[2],  P[3],  G[3],  P1[3],  G1[3]);
    black_cell black_cell_1_04 (P[3],  G[3],  P[4],  G[4],  P1[4],  G1[4]);
    black_cell black_cell_1_05 (P[4],  G[4],  P[5],  G[5],  P1[5],  G1[5]);
    black_cell black_cell_1_06 (P[5],  G[5],  P[6],  G[6],  P1[6],  G1[6]);
    black_cell black_cell_1_07 (P[6],  G[6],  P[7],  G[7],  P1[7],  G1[7]);
    black_cell black_cell_1_08 (P[7],  G[7],  P[8],  G[8],  P1[8],  G1[8]);
    black_cell black_cell_1_09 (P[8],  G[8],  P[9],  G[9],  P1[9],  G1[9]);
    black_cell black_cell_1_10 (P[9],  G[9],  P[10], G[10], P1[10], G1[10]);
    black_cell black_cell_1_11 (P[10], G[10], P[11], G[11], P1[11], G1[11]);
    black_cell black_cell_1_12 (P[11], G[11], P[12], G[12], P1[12], G1[12]);
    black_cell black_cell_1_13 (P[12], G[12], P[13], G[13], P1[13], G1[13]);
    black_cell black_cell_1_14 (P[13], G[13], P[14], G[14], P1[14], G1[14]);
    black_cell black_cell_1_15 (P[14], G[14], P[15], G[15], P1[15], G1[15]);
    black_cell black_cell_1_16 (P[15], G[15], P[16], G[16], P1[16], G1[16]);

    // -------- Level 2 (span=2) --------
    // gray for C[3], C[4]
    gray_cell gray_cell_03 (C[1], P1[3], G1[3], C[3]);
    gray_cell gray_cell_04 (C[2], P1[4], G1[4], C[4]);

    // black combine (i-2, i) → (P2[i], G2[i]) for i=5..16
    black_cell black_cell_2_05 (P1[3],  G1[3],  P1[5],  G1[5],  P2[5],  G2[5]);
    black_cell black_cell_2_06 (P1[4],  G1[4],  P1[6],  G1[6],  P2[6],  G2[6]);
    black_cell black_cell_2_07 (P1[5],  G1[5],  P1[7],  G1[7],  P2[7],  G2[7]);
    black_cell black_cell_2_08 (P1[6],  G1[6],  P1[8],  G1[8],  P2[8],  G2[8]);
    black_cell black_cell_2_09 (P1[7],  G1[7],  P1[9],  G1[9],  P2[9],  G2[9]);
    black_cell black_cell_2_10 (P1[8],  G1[8],  P1[10], G1[10], P2[10], G2[10]);
    black_cell black_cell_2_11 (P1[9],  G1[9],  P1[11], G1[11], P2[11], G2[11]);
    black_cell black_cell_2_12 (P1[10], G1[10], P1[12], G1[12], P2[12], G2[12]);
    black_cell black_cell_2_13 (P1[11], G1[11], P1[13], G1[13], P2[13], G2[13]);
    black_cell black_cell_2_14 (P1[12], G1[12], P1[14], G1[14], P2[14], G2[14]);
    black_cell black_cell_2_15 (P1[13], G1[13], P1[15], G1[15], P2[15], G2[15]);
    black_cell black_cell_2_16 (P1[14], G1[14], P1[16], G1[16], P2[16], G2[16]);

    // -------- Level 3 (span=4) --------
    // gray for C[5]..C[8]
    gray_cell gray_cell_05 (C[1], P2[5], G2[5], C[5]);
    gray_cell gray_cell_06 (C[2], P2[6], G2[6], C[6]);
    gray_cell gray_cell_07 (C[3], P2[7], G2[7], C[7]);
    gray_cell gray_cell_08 (C[4], P2[8], G2[8], C[8]);

    // black combine (i-4, i) → (P3[i], G3[i]) for i=9..16
    black_cell black_cell_3_09 (P2[5],  G2[5],  P2[9],  G2[9],  P3[9],  G3[9]);
    black_cell black_cell_3_10 (P2[6],  G2[6],  P2[10], G2[10], P3[10], G3[10]);
    black_cell black_cell_3_11 (P2[7],  G2[7],  P2[11], G2[11], P3[11], G3[11]);
    black_cell black_cell_3_12 (P2[8],  G2[8],  P2[12], G2[12], P3[12], G3[12]);
    black_cell black_cell_3_13 (P2[9],  G2[9],  P2[13], G2[13], P3[13], G3[13]);
    black_cell black_cell_3_14 (P2[10], G2[10], P2[14], G2[14], P3[14], G3[14]);
    black_cell black_cell_3_15 (P2[11], G2[11], P2[15], G2[15], P3[15], G3[15]);
    black_cell black_cell_3_16 (P2[12], G2[12], P2[16], G2[16], P3[16], G3[16]);

    // -------- Level 4 (span=8) --------
    // gray for C[9]..C[16]
    gray_cell gray_cell_09 (C[1], P3[9],  G3[9],  C[9]);
    gray_cell gray_cell_10 (C[2], P3[10], G3[10], C[10]);
    gray_cell gray_cell_11 (C[3], P3[11], G3[11], C[11]);
    gray_cell gray_cell_12 (C[4], P3[12], G3[12], C[12]);
    gray_cell gray_cell_13 (C[5], P3[13], G3[13], C[13]);
    gray_cell gray_cell_14 (C[6], P3[14], G3[14], C[14]);
    gray_cell gray_cell_15 (C[7], P3[15], G3[15], C[15]);
    gray_cell gray_cell_16 (C[8], P3[16], G3[16], C[16]);

    // -------- Post-processing: Sum/Cout --------
    assign sum[0]     = cin ^ P[1];
    assign sum[15:1]  = C[15:1] ^ P[16:2];
    assign cout       = C[16];

endmodule