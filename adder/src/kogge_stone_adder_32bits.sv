module kogge_stone_adder_32bits 			
(
    input logic	[31:0]	operand_a, 
	 input logic	[31:0]	operand_b,
    input logic				cin,
	 
    output logic	[31:0]	sum,
    output logic				cout
);
    logic [32:1] G,P; 
	 logic [32:1] C;
    
    // Pre-processing stage: Generate & Propagate
    assign G = operand_a & operand_b;    // Generate
    assign P = operand_a ^ operand_b;    // Propagate
    
    // Prefix Computation Stage: (Using Gray & Black Cells)
	 
	 logic [32:3] G1, P1;		// Level 1 - Level 2
	 logic [32:5] G2, P2;		// Level 2 - Level 3
	 logic [32:9] G3, P3;		// Level 3 - Level 4
	 logic [32:17] G4, P4;		// Level 4 - Level 5
	 
	 
	 // Level 1
	 assign C[1] = G[1] | (P[1] & cin);
	 
	 gray_cell 	gray_cell_02	(C[1], P[2], G[2], C[2]);
	 
	 //								 |P_pre-1|G_pre-1|P_cur| G_cur| P_n  |  G_n
    black_cell black_cell_1_03  ( P[2],  G[2],  P[3],  G[3],  P1[3],  G1[3]);
    black_cell black_cell_1_04  ( P[3],  G[3],  P[4],  G[4],  P1[4],  G1[4]);
	 
    black_cell black_cell_1_05  ( P[4],  G[4],  P[5],  G[5],  P1[5],  G1[5]);
    black_cell black_cell_1_06  ( P[5],  G[5],  P[6],  G[6],  P1[6],  G1[6]);
    black_cell black_cell_1_07  ( P[6],  G[6],  P[7],  G[7],  P1[7],  G1[7]);
    black_cell black_cell_1_08  ( P[7],  G[7],  P[8],  G[8],  P1[8],  G1[8]);
	 
    black_cell black_cell_1_09  ( P[8],  G[8],  P[9],  G[9],  P1[9],  G1[9]);
    black_cell black_cell_1_10  ( P[9],  G[9],  P[10], G[10], P1[10], G1[10]);
    black_cell black_cell_1_11  ( P[10], G[10], P[11], G[11], P1[11], G1[11]);
    black_cell black_cell_1_12  ( P[11], G[11], P[12], G[12], P1[12], G1[12]);
	 
    black_cell black_cell_1_13  ( P[12], G[12], P[13], G[13], P1[13], G1[13]);
    black_cell black_cell_1_14  ( P[13], G[13], P[14], G[14], P1[14], G1[14]);
    black_cell black_cell_1_15  ( P[14], G[14], P[15], G[15], P1[15], G1[15]);
    black_cell black_cell_1_16  ( P[15], G[15], P[16], G[16], P1[16], G1[16]);
	 
    black_cell black_cell_1_17  ( P[16], G[16], P[17], G[17], P1[17], G1[17]);
    black_cell black_cell_1_18  ( P[17], G[17], P[18], G[18], P1[18], G1[18]);
    black_cell black_cell_1_19  ( P[18], G[18], P[19], G[19], P1[19], G1[19]);
    black_cell black_cell_1_20  ( P[19], G[19], P[20], G[20], P1[20], G1[20]);
	 
    black_cell black_cell_1_21  ( P[20], G[20], P[21], G[21], P1[21], G1[21]);
    black_cell black_cell_1_22  ( P[21], G[21], P[22], G[22], P1[22], G1[22]);
    black_cell black_cell_1_23  ( P[22], G[22], P[23], G[23], P1[23], G1[23]);
    black_cell black_cell_1_24  ( P[23], G[23], P[24], G[24], P1[24], G1[24]);
	 
    black_cell black_cell_1_25  ( P[24], G[24], P[25], G[25], P1[25], G1[25]);
    black_cell black_cell_1_26  ( P[25], G[25], P[26], G[26], P1[26], G1[26]);
    black_cell black_cell_1_27  ( P[26], G[26], P[27], G[27], P1[27], G1[27]);
    black_cell black_cell_1_28  ( P[27], G[27], P[28], G[28], P1[28], G1[28]);
	 
    black_cell black_cell_1_29  ( P[28], G[28], P[29], G[29], P1[29], G1[29]);
    black_cell black_cell_1_30  ( P[29], G[29], P[30], G[30], P1[30], G1[30]);
    black_cell black_cell_1_31  ( P[30], G[30], P[31], G[31], P1[31], G1[31]);
	 black_cell black_cell_1_32  ( P[31], G[31], P[32], G[32], P1[32], G1[32]);


	 
	 // Level 2
	 gray_cell 	gray_cell_03	(C[1], P1[3], G1[3], C[3]);
	 gray_cell 	gray_cell_04	(C[2], P1[4], G1[4], C[4]);
	 
	 //								  |P_pre-2| G_pre-2|P_cur | G_cur | P_n  |  G_n 
    black_cell black_cell_2_05  ( P1[3],  G1[3],  P1[5],  G1[5],  P2[5],  G2[5]);
    black_cell black_cell_2_06  ( P1[4],  G1[4],  P1[6],  G1[6],  P2[6],  G2[6]);
    black_cell black_cell_2_07  ( P1[5],  G1[5],  P1[7],  G1[7],  P2[7],  G2[7]);
    black_cell black_cell_2_08  ( P1[6],  G1[6],  P1[8],  G1[8],  P2[8],  G2[8]);
	 
    black_cell black_cell_2_09  ( P1[7], G1[7], P1[9],  G1[9],  P2[9],  G2[9]);
    black_cell black_cell_2_10  ( P1[8], G1[8], P1[10], G1[10], P2[10], G2[10]);
    black_cell black_cell_2_11  ( P1[9], G1[9], P1[11], G1[11], P2[11], G2[11]);
    black_cell black_cell_2_12  ( P1[10], G1[10], P1[12], G1[12], P2[12], G2[12]);
	 
    black_cell black_cell_2_13  ( P1[11], G1[11], P1[13], G1[13], P2[13], G2[13]);
    black_cell black_cell_2_14  ( P1[12], G1[12], P1[14], G1[14], P2[14], G2[14]);
    black_cell black_cell_2_15  ( P1[13], G1[13], P1[15], G1[15], P2[15], G2[15]);
    black_cell black_cell_2_16  ( P1[14], G1[14], P1[16], G1[16], P2[16], G2[16]);

    black_cell black_cell_2_17  ( P1[15], G1[15], P1[17], G1[17], P2[17], G2[17]);
    black_cell black_cell_2_18  ( P1[16], G1[16], P1[18], G1[18], P2[18], G2[18]);
    black_cell black_cell_2_19  ( P1[17], G1[17], P1[19], G1[19], P2[19], G2[19]);
    black_cell black_cell_2_20  ( P1[18], G1[18], P1[20], G1[20], P2[20], G2[20]);
	 
    black_cell black_cell_2_21  ( P1[19], G1[19], P1[21], G1[21], P2[21], G2[21]);
    black_cell black_cell_2_22  ( P1[20], G1[20], P1[22], G1[22], P2[22], G2[22]);
    black_cell black_cell_2_23  ( P1[21], G1[21], P1[23], G1[23], P2[23], G2[23]);
    black_cell black_cell_2_24  ( P1[22], G1[22], P1[24], G1[24], P2[24], G2[24]);
	
    black_cell black_cell_2_25  ( P1[23], G1[23], P1[25], G1[25], P2[25], G2[25]);
    black_cell black_cell_2_26  ( P1[24], G1[24], P1[26], G1[26], P2[26], G2[26]);
    black_cell black_cell_2_27  ( P1[25], G1[25], P1[27], G1[27], P2[27], G2[27]);
    black_cell black_cell_2_28  ( P1[26], G1[26], P1[28], G1[28], P2[28], G2[28]);

    black_cell black_cell_2_29  ( P1[27], G1[27], P1[29], G1[29], P2[29], G2[29]);
    black_cell black_cell_2_30  ( P1[28], G1[28], P1[30], G1[30], P2[30], G2[30]);
    black_cell black_cell_2_31  ( P1[29], G1[29], P1[31], G1[31], P2[31], G2[31]);
	 black_cell black_cell_2_32  ( P1[30], G1[30], P1[32], G1[32], P2[32], G2[32]);

	 
	 // Level 3 
	 
	 gray_cell 	gray_cell_05	(C[1] , P2[5], G2[5], C[5]);
	 gray_cell 	gray_cell_06	(C[2] , P2[6], G2[6], C[6]);
	 gray_cell 	gray_cell_07	(C[3] , P2[7], G2[7], C[7]);
	 gray_cell 	gray_cell_08	(C[4] , P2[8], G2[8], C[8]);
	 //								 |P_pre-4|G_pre-4|P_cur| G_cur| P_n  |  G_n	 
    black_cell black_cell_3_09  ( P2[5], G2[5], P2[9],  G2[9],  P3[9],  G3[9]);
    black_cell black_cell_3_10  ( P2[6], G2[6], P2[10], G2[10], P3[10], G3[10]);
    black_cell black_cell_3_11  ( P2[7], G2[7], P2[11], G2[11], P3[11], G3[11]);
    black_cell black_cell_3_12  ( P2[8], G2[8], P2[12], G2[12], P3[12], G3[12]);
	 
    black_cell black_cell_3_13  ( P2[9] , G2[9] , P2[13], G2[13], P3[13], G3[13]);
    black_cell black_cell_3_14  ( P2[10], G2[10], P2[14], G2[14], P3[14], G3[14]);
    black_cell black_cell_3_15  ( P2[11], G2[11], P2[15], G2[15], P3[15], G3[15]);
    black_cell black_cell_3_16  ( P2[12], G2[12], P2[16], G2[16], P3[16], G3[16]);
	
    black_cell black_cell_3_17  ( P2[13], G2[13], P2[17], G2[17], P3[17], G3[17]);
    black_cell black_cell_3_18  ( P2[14], G2[14], P2[18], G2[18], P3[18], G3[18]);
    black_cell black_cell_3_19  ( P2[15], G2[15], P2[19], G2[19], P3[19], G3[19]);
    black_cell black_cell_3_20  ( P2[16], G2[16], P2[20], G2[20], P3[20], G3[20]);
	
    black_cell black_cell_3_21  ( P2[17], G2[17], P2[21], G2[21], P3[21], G3[21]);
    black_cell black_cell_3_22  ( P2[18], G2[18], P2[22], G2[22], P3[22], G3[22]);
    black_cell black_cell_3_23  ( P2[19], G2[19], P2[23], G2[23], P3[23], G3[23]);
    black_cell black_cell_3_24  ( P2[20], G2[20], P2[24], G2[24], P3[24], G3[24]);
	 
    black_cell black_cell_3_25  ( P2[21], G2[21], P2[25], G2[25], P3[25], G3[25]);
    black_cell black_cell_3_26  ( P2[22], G2[22], P2[26], G2[26], P3[26], G3[26]);
    black_cell black_cell_3_27  ( P2[23], G2[23], P2[27], G2[27], P3[27], G3[27]);
    black_cell black_cell_3_28  ( P2[24], G2[24], P2[28], G2[28], P3[28], G3[28]); 
	 
    black_cell black_cell_3_29  ( P2[25], G2[25], P2[29], G2[29], P3[29], G3[29]);
    black_cell black_cell_3_30  ( P2[26], G2[26], P2[30], G2[30], P3[30], G3[30]);
    black_cell black_cell_3_31  ( P2[27], G2[27], P2[31], G2[31], P3[31], G3[31]);
	 black_cell black_cell_3_32  ( P2[28], G2[28], P2[32], G2[32], P3[32], G3[32]);

	 
	 // Level 4
	 
    gray_cell 	gray_cell_09	(C[1], P3[9],  G3[9],  C[9]);
    gray_cell 	gray_cell_10	(C[2], P3[10], G3[10], C[10]);
    gray_cell 	gray_cell_11	(C[3], P3[11], G3[11], C[11]);
    gray_cell 	gray_cell_12	(C[4], P3[12], G3[12], C[12]);
    gray_cell 	gray_cell_13	(C[5], P3[13], G3[13], C[13]);
    gray_cell 	gray_cell_14	(C[6], P3[14], G3[14], C[14]);
    gray_cell 	gray_cell_15	(C[7], P3[15], G3[15], C[15]);
    gray_cell 	gray_cell_16	(C[8], P3[16], G3[16], C[16]);
	 //								 |P_pre-8|G_pre-8|P_cur| G_cur| P_n  |  G_n 
    black_cell black_cell_4_17  ( P3[9] , G3[9] , P3[17], G3[17], P4[17], G4[17]);
    black_cell black_cell_4_18  ( P3[10], G3[10], P3[18], G3[18], P4[18], G4[18]);
    black_cell black_cell_4_19  ( P3[11], G3[11], P3[19], G3[19], P4[19], G4[19]);
    black_cell black_cell_4_20  ( P3[12], G3[12], P3[20], G3[20], P4[20], G4[20]);
	 
    black_cell black_cell_4_21  ( P3[13], G3[13], P3[21], G3[21], P4[21], G4[21]);
    black_cell black_cell_4_22  ( P3[14], G3[14], P3[22], G3[22], P4[22], G4[22]);
    black_cell black_cell_4_23  ( P3[15], G3[15], P3[23], G3[23], P4[23], G4[23]);
    black_cell black_cell_4_24  ( P3[16], G3[16], P3[24], G3[24], P4[24], G4[24]);
	 
    black_cell black_cell_4_25  ( P3[17], G3[17], P3[25], G3[25], P4[25], G4[25]);
    black_cell black_cell_4_26  ( P3[18], G3[18], P3[26], G3[26], P4[26], G4[26]);
    black_cell black_cell_4_27  ( P3[19], G3[19], P3[27], G3[27], P4[27], G4[27]);
    black_cell black_cell_4_28  ( P3[20], G3[20], P3[28], G3[28], P4[28], G4[28]);
	 
    black_cell black_cell_4_29  ( P3[21], G3[21], P3[29], G3[29], P4[29], G4[29]);
    black_cell black_cell_4_30  ( P3[22], G3[22], P3[30], G3[30], P4[30], G4[30]);
    black_cell black_cell_4_31  ( P3[23], G3[23], P3[31], G3[31], P4[31], G4[31]);
	 black_cell black_cell_4_32  ( P3[24], G3[24], P3[32], G3[32], P4[32], G4[32]);

	 
	 // Level 5
	 //							   |G_pre-16|P_cur| G_cur|  G_n 
	 gray_cell 	gray_cell_17	(C[1],  P4[17], G4[17], C[17]);
    gray_cell 	gray_cell_18	(C[2],  P4[18], G4[18], C[18]);
    gray_cell 	gray_cell_19	(C[3],  P4[19], G4[19], C[19]);
    gray_cell 	gray_cell_20	(C[4],  P4[20], G4[20], C[20]);
	 
    gray_cell 	gray_cell_21	(C[5],  P4[21], G4[21], C[21]);
    gray_cell 	gray_cell_22	(C[6],  P4[22], G4[22], C[22]);
    gray_cell 	gray_cell_23	(C[7],  P4[23], G4[23], C[23]);
    gray_cell 	gray_cell_24	(C[8],  P4[24], G4[24], C[24]);
	 
    gray_cell 	gray_cell_25	(C[9],  P4[25], G4[25], C[25]);
    gray_cell 	gray_cell_26	(C[10], P4[26], G4[26], C[26]);
    gray_cell 	gray_cell_27	(C[11], P4[27], G4[27], C[27]);
    gray_cell 	gray_cell_28	(C[12], P4[28], G4[28], C[28]); 
	
    gray_cell 	gray_cell_29	(C[13], P4[29], G4[29], C[29]);
    gray_cell 	gray_cell_30	(C[14], P4[30], G4[30], C[30]);
    gray_cell 	gray_cell_31	(C[15], P4[31], G4[31], C[31]);
    gray_cell 	gray_cell_32	(C[16], P4[32], G4[32], C[32]);

	 
    // Post-processing stage: Compute Sum
	 
	 // Calculate Sum[31:0]
	 assign sum[0] = cin ^ P[1];
    assign sum[31:1] = C[31:1] ^ P[32:2];
	 
	 // Calculate Cout
	 assign cout = C[32];
	 

endmodule