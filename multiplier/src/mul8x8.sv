/*

	DADDA MULTILPLIER 8 Bits

*/
module mul8x8
(
	input [7:0] a,
	input [7:0] b,
	
	output [15:0] p
);

logic p70, p60, p50, p40, p30, p20, p10, p00;
logic p71, p61, p51, p41, p31, p21, p11, p01;
logic p72, p62, p52, p42, p32, p22, p12, p02;
logic p73, p63, p53, p43, p33, p23, p13, p03;
logic p74, p64, p54, p44, p34, p24, p14, p04;
logic p75, p65, p55, p45, p35, p25, p15, p05;
logic p76, p66, p56, p46, p36, p26, p16, p06;
logic p77, p67, p57, p47, p37, p27, p17, p07;

logic [56:1] s, c;

// ===================================================
// 						Partial products
// ===================================================

// Row b[0]
assign p00 = a[0] & b[0];
assign p10 = a[1] & b[0];
assign p20 = a[2] & b[0];
assign p30 = a[3] & b[0];
assign p40 = a[4] & b[0];
assign p50 = a[5] & b[0];
assign p60 = a[6] & b[0];
assign p70 = a[7] & b[0];

// Row b[1]
assign p01 = a[0] & b[1];
assign p11 = a[1] & b[1];
assign p21 = a[2] & b[1];
assign p31 = a[3] & b[1];
assign p41 = a[4] & b[1];
assign p51 = a[5] & b[1];
assign p61 = a[6] & b[1];
assign p71 = a[7] & b[1];

// Row b[2]
assign p02 = a[0] & b[2];
assign p12 = a[1] & b[2];
assign p22 = a[2] & b[2];
assign p32 = a[3] & b[2];
assign p42 = a[4] & b[2];
assign p52 = a[5] & b[2];
assign p62 = a[6] & b[2];
assign p72 = a[7] & b[2];

// Row b[3]
assign p03 = a[0] & b[3];
assign p13 = a[1] & b[3];
assign p23 = a[2] & b[3];
assign p33 = a[3] & b[3];
assign p43 = a[4] & b[3];
assign p53 = a[5] & b[3];
assign p63 = a[6] & b[3];
assign p73 = a[7] & b[3];

// Row b[4]
assign p04 = a[0] & b[4];
assign p14 = a[1] & b[4];
assign p24 = a[2] & b[4];
assign p34 = a[3] & b[4];
assign p44 = a[4] & b[4];
assign p54 = a[5] & b[4];
assign p64 = a[6] & b[4];
assign p74 = a[7] & b[4];

// Row b[5]
assign p05 = a[0] & b[5];
assign p15 = a[1] & b[5];
assign p25 = a[2] & b[5];
assign p35 = a[3] & b[5];
assign p45 = a[4] & b[5];
assign p55 = a[5] & b[5];
assign p65 = a[6] & b[5];
assign p75 = a[7] & b[5];

// Row b[6]
assign p06 = a[0] & b[6];
assign p16 = a[1] & b[6];
assign p26 = a[2] & b[6];
assign p36 = a[3] & b[6];
assign p46 = a[4] & b[6];
assign p56 = a[5] & b[6];
assign p66 = a[6] & b[6];
assign p76 = a[7] & b[6];

// Row b[7]
assign p07 = a[0] & b[7];
assign p17 = a[1] & b[7];
assign p27 = a[2] & b[7];
assign p37 = a[3] & b[7];
assign p47 = a[4] & b[7];
assign p57 = a[5] & b[7];
assign p67 = a[6] & b[7];
assign p77 = a[7] & b[7];

// ===================================================
//								Stage 1
// ===================================================

half_adder  HA_s1   (.a(p10), .b(p01), 				.sum(s[1]),  	.cout(c[1]));
full_adder  FA_s2   (.a(p20), .b(p11), .cin(p02), 	.sum(s[2]), 	.cout(c[2]));
full_adder  FA_s3   (.a(p21), .b(p12), .cin(p03), 	.sum(s[3]), 	.cout(c[3]));
full_adder  FA_s4   (.a(p22), .b(p13), .cin(p04), 	.sum(s[4]), 	.cout(c[4]));
full_adder  FA_s5   (.a(p50), .b(p41), .cin(p32), 	.sum(s[5]), 	.cout(c[5]));
full_adder  FA_s6   (.a(p23), .b(p14), .cin(p05), 	.sum(s[6]), 	.cout(c[6]));
full_adder  FA_s7   (.a(p51), .b(p42), .cin(p33), 	.sum(s[7]), 	.cout(c[7]));
full_adder  FA_s8   (.a(p24), .b(p15), .cin(p06), 	.sum(s[8]), 	.cout(c[8]));
full_adder  FA_s9   (.a(p52), .b(p43), .cin(p34), 	.sum(s[9]), 	.cout(c[9]));
full_adder  FA_s10  (.a(p25), .b(p16), .cin(p07), 	.sum(s[10]), 	.cout(c[10]));
full_adder  FA_s11  (.a(p62), .b(p53), .cin(p44), 	.sum(s[11]), 	.cout(c[11]));
full_adder  FA_s12  (.a(p35), .b(p26), .cin(p17), 	.sum(s[12]), 	.cout(c[12]));
full_adder  FA_s13  (.a(p72), .b(p63), .cin(p54), 	.sum(s[13]), 	.cout(c[13]));
full_adder  FA_s14  (.a(p45), .b(p36), .cin(p27), 	.sum(s[14]), 	.cout(c[14]));
full_adder  FA_s15  (.a(p55), .b(p46), .cin(p37), 	.sum(s[15]), 	.cout(c[15]));
full_adder  FA_s16  (.a(p65), .b(p56), .cin(p47), 	.sum(s[16]), 	.cout(c[16]));
full_adder  FA_s17  (.a(p75), .b(p66), .cin(p57), 	.sum(s[17]), 	.cout(c[17]));

// ===================================================
//								Stage 2
// ===================================================

half_adder  HA_s18  (.a(c[1]),	.b(s[2]), 						.sum(s[18]), .cout(c[18]));
full_adder  FA_s19  (.a(p30),		.b(c[2]), 	.cin(s[3]), 	.sum(s[19]), .cout(c[19]));
full_adder  FA_s20  (.a(p31), 	.b(c[3]), 	.cin(s[4]), 	.sum(s[20]), .cout(c[20]));
full_adder  FA_s21  (.a(c[4]), 	.b(s[5]), 	.cin(s[6]), 	.sum(s[21]), .cout(c[21]));
full_adder  FA_s22  (.a(c[6]), 	.b(s[7]), 	.cin(s[8]), 	.sum(s[22]), .cout(c[22]));
full_adder  FA_s23  (.a(p70), 	.b(p61), 	.cin(c[7]), 	.sum(s[23]), .cout(c[23]));
full_adder  FA_s24  (.a(c[8]), 	.b(s[9]), 	.cin(s[10]), 	.sum(s[24]), .cout(c[24]));
full_adder  FA_s25  (.a(c[10]), 	.b(s[11]), 	.cin(s[12]), 	.sum(s[25]), .cout(c[25]));
full_adder  FA_s26  (.a(c[12]), 	.b(s[13]), 	.cin(s[14]), 	.sum(s[26]), .cout(c[26]));
full_adder  FA_s27  (.a(c[13]), 	.b(c[14]), 	.cin(s[15]), 	.sum(s[27]), .cout(c[27]));
full_adder  FA_s28  (.a(p74), 	.b(c[15]), 	.cin(s[16]), 	.sum(s[28]), .cout(c[28]));
full_adder  FA_s29  (.a(p76), 	.b(p67), 	.cin(c[17]), 	.sum(s[29]), .cout(c[29]));

// ===================================================
//								Stage 3
// ===================================================

half_adder  HA_s30  (.a(c[18]),	.b(s[19]), 						.sum(s[30]), .cout(c[30]));
full_adder  FA_s31  (.a(p40),		.b(c[19]), 	.cin(s[20]), 	.sum(s[31]), .cout(c[31]));
full_adder  FA_s32  (.a(c[5]), 	.b(c[21]), 	.cin(s[22]), 	.sum(s[32]), .cout(c[32]));
full_adder  FA_s33  (.a(c[22]), 	.b(s[23]), 	.cin(s[24]), 	.sum(s[33]), .cout(c[33]));
full_adder  FA_s34  (.a(c[23]), 	.b(c[24]), 	.cin(s[25]), 	.sum(s[34]), .cout(c[34]));
full_adder  FA_s35  (.a(c[11]),	.b(c[25]), 	.cin(s[26]), 	.sum(s[35]), .cout(c[35]));
full_adder  FA_s36  (.a(p64), 	.b(c[26]), 	.cin(s[27]), 	.sum(s[36]), .cout(c[36]));
full_adder  FA_s37  (.a(c[16]), 	.b(s[17]), 	.cin(c[28]), 	.sum(s[37]), .cout(c[37]));

// ===================================================
//								Stage 4
// ===================================================

half_adder  HA_s38  (.a(c[30]),	.b(s[31]), 						.sum(s[38]), .cout(c[38]));
full_adder  FA_s39  (.a(c[20]),	.b(s[21]), 	.cin(c[31]), 	.sum(s[39]), .cout(c[39]));
full_adder  FA_s40  (.a(c[9]), 	.b(c[33]), 	.cin(s[34]), 	.sum(s[40]), .cout(c[40]));
full_adder  FA_s41  (.a(p73), 	.b(c[35]), 	.cin(s[36]), 	.sum(s[41]), .cout(c[41]));
full_adder  FA_s42  (.a(c[27]), 	.b(s[28]), 	.cin(c[36]), 	.sum(s[42]), .cout(c[42]));

// ===================================================
//								Stage 5
// ===================================================

half_adder  HA_s43  (.a(c[38]),	.b(s[39]), 						.sum(s[43]), .cout(c[43]));
full_adder  FA_s44  (.a(p60),		.b(s[32]), 	.cin(c[39]), 	.sum(s[44]), .cout(c[44]));
full_adder  FA_s45  (.a(c[34]), 	.b(s[35]), 	.cin(c[40]), 	.sum(s[45]), .cout(c[45]));

// ===================================================
//								Stage 6
// ===================================================

half_adder  HA_s46  (.a(c[43]),	.b(s[44]), 						.sum(s[46]), .cout(c[46]));
full_adder  FA_s47  (.a(c[32]),	.b(s[33]), 	.cin(c[44]), 	.sum(s[47]), .cout(c[47]));

// ===================================================
//								Stage 7
// ===================================================

half_adder  HA_s48  (.a(c[46]),	.b(s[47]), 						.sum(s[48]), .cout(c[48]));
full_adder  FA_s49  (.a(p71),		.b(s[40]), 	.cin(c[47]), 	.sum(s[49]), .cout(c[49]));

// ===================================================
//								Final Stage
// ===================================================

half_adder  HA_s50  (.a(c[48]),	.b(s[49]), 						.sum(s[50]), .cout(c[50]));
full_adder  FA_s51  (.a(s[45]),	.b(c[49]), 	.cin(c[50]), 	.sum(s[51]), .cout(c[51]));
full_adder  FA_s52  (.a(s[41]), 	.b(c[45]), 	.cin(c[51]), 	.sum(s[52]), .cout(c[52]));
full_adder  FA_s53  (.a(c[41]), 	.b(s[42]), 	.cin(c[52]), 	.sum(s[53]), .cout(c[53]));
full_adder  FA_s54  (.a(c[42]), 	.b(s[37]), 	.cin(c[53]), 	.sum(s[54]), .cout(c[54]));
full_adder  FA_s55  (.a(s[29]), 	.b(c[37]), 	.cin(c[54]), 	.sum(s[55]), .cout(c[55]));
full_adder  FA_s56  (.a(p77), 	.b(c[29]), 	.cin(c[55]), 	.sum(s[56]), .cout(c[56]));

assign p = {c[56],s[56],s[55],s[54],s[53],s[52],s[51],s[50],s[48],s[46],s[43],s[38],s[30],s[18],s[1],p00};

endmodule 


// ============================================================
// Half Adder (HA)
// sum = a ^ b
// cout = a & b
// ============================================================
module half_adder (
    input  logic a,
    input  logic b,
    output logic sum,
    output logic cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule

// ============================================================
// Full Adder (FA)
// sum  = a ^ b ^ cin
// cout = (a & b) | (b & cin) | (a & cin)
// ============================================================
module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
