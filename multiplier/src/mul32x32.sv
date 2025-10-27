module mul32x32
(
    input  logic [31:0] a,		// operand a
    input  logic [31:0] b,		// operand b
    output logic [63:0] p		// product
);

    // divide into 4 8-bit
	logic [7:0] a0, a1, a2, a3;
	logic [7:0] b0, b1, b2, b3;

	assign a0 = a[7:0];
	assign a1 = a[15:8];
	assign a2 = a[23:16];
	assign a3 = a[31:24];

	assign b0 = b[7:0];
	assign b1 = b[15:8];
	assign b2 = b[23:16];
	assign b3 = b[31:24];


    // 16 partial products (16-bit)
    logic [15:0] p00, p01, p02, p03;
    logic [15:0] p10, p11, p12, p13;
    logic [15:0] p20, p21, p22, p23;
    logic [15:0] p30, p31, p32, p33;

    // Instance
    mul8x8	m00(.a(a0), .b(b0), .p(p00));
    mul8x8	m01(.a(a0), .b(b1), .p(p01));
    mul8x8	m02(.a(a0), .b(b2), .p(p02));
    mul8x8	m03(.a(a0), .b(b3), .p(p03));

    mul8x8	m10(.a(a1), .b(b0), .p(p10));
    mul8x8	m11(.a(a1), .b(b1), .p(p11));
    mul8x8	m12(.a(a1), .b(b2), .p(p12));
    mul8x8	m13(.a(a1), .b(b3), .p(p13));

    mul8x8	m20(.a(a2), .b(b0), .p(p20));
    mul8x8	m21(.a(a2), .b(b1), .p(p21));
    mul8x8	m22(.a(a2), .b(b2), .p(p22));
    mul8x8	m23(.a(a2), .b(b3), .p(p23));

    mul8x8	m30(.a(a3), .b(b0), .p(p30));
    mul8x8	m31(.a(a3), .b(b1), .p(p31));
    mul8x8	m32(.a(a3), .b(b2), .p(p32));
    mul8x8	m33(.a(a3), .b(b3), .p(p33));

// ====== Biểu diễn dịch thủ công bằng nối bit ======
    logic [63:0] t00, t01, t02, t03;
    logic [63:0] t10, t11, t12, t13;
    logic [63:0] t20, t21, t22, t23;
    logic [63:0] t30, t31, t32, t33;

    assign t00 = {48'd0, p00};
    assign t01 = {40'd0, p01, 8'd0};
    assign t02 = {32'd0, p02, 16'd0};
    assign t03 = {24'd0, p03, 24'd0};

    assign t10 = {40'd0, p10, 8'd0};
    assign t11 = {32'd0, p11, 16'd0};
    assign t12 = {24'd0, p12, 24'd0};
    assign t13 = {16'd0, p13, 32'd0};

    assign t20 = {32'd0, p20, 16'd0};
    assign t21 = {24'd0, p21, 24'd0};
    assign t22 = {16'd0, p22, 32'd0};
    assign t23 = {8'd0 , p23, 40'd0};

    assign t30 = {24'd0, p30, 24'd0};
    assign t31 = {16'd0, p31, 32'd0};
    assign t32 = {8'd0 , p32, 40'd0};
    assign t33 = {       p33, 48'd0};

    // ====== Cộng dần bằng bộ cộng 64-bit ======
    logic [63:0] s1,s2,s3,s4,s5,s6,s7,s8;
    logic [63:0] s9,s10,s11,s12,s13,s14,s15;
    logic cout_dummy;

    // ADD Stage 1
    ADDER_64bits add1 (.A(t00), .B(t01), .Cin(1'b0), .Sum(s1), .Cout(cout_dummy));
    ADDER_64bits add2 (.A(t02), .B(t03), .Cin(1'b0), .Sum(s2), .Cout(cout_dummy));
    ADDER_64bits add3 (.A(t10), .B(t11), .Cin(1'b0), .Sum(s3), .Cout(cout_dummy));
    ADDER_64bits add4 (.A(t12), .B(t13), .Cin(1'b0), .Sum(s4), .Cout(cout_dummy));
    ADDER_64bits add5 (.A(t20), .B(t21), .Cin(1'b0), .Sum(s5), .Cout(cout_dummy));
    ADDER_64bits add6 (.A(t22), .B(t23), .Cin(1'b0), .Sum(s6), .Cout(cout_dummy));
    ADDER_64bits add7 (.A(t30), .B(t31), .Cin(1'b0), .Sum(s7), .Cout(cout_dummy));
    ADDER_64bits add8 (.A(t32), .B(t33), .Cin(1'b0), .Sum(s8), .Cout(cout_dummy));

    // ADD Stage 2
    ADDER_64bits add9  (.A(s1), .B(s2), .Cin(1'b0), .Sum(s9),  .Cout(cout_dummy));
    ADDER_64bits add10 (.A(s3), .B(s4), .Cin(1'b0), .Sum(s10), .Cout(cout_dummy));
    ADDER_64bits add11 (.A(s5), .B(s6), .Cin(1'b0), .Sum(s11), .Cout(cout_dummy));
    ADDER_64bits add12 (.A(s7), .B(s8), .Cin(1'b0), .Sum(s12), .Cout(cout_dummy));

    // ADD Stage 3
    ADDER_64bits add13 (.A(s9),  .B(s10), .Cin(1'b0), .Sum(s13), .Cout(cout_dummy));
    ADDER_64bits add14 (.A(s11), .B(s12), .Cin(1'b0), .Sum(s14), .Cout(cout_dummy));

    // ADD Final Stage
    ADDER_64bits add15 (.A(s13), .B(s14), .Cin(1'b0), .Sum(p), .Cout(cout_dummy));

endmodule



// ===================================================
// 			Dummy Adder (change to your design)
// ===================================================

module ADDER_64bits 
(
    input logic [63:0] A,
    input logic [63:0] B,
    input logic        Cin,

    output logic [63:0] Sum,
    output logic        Cout
);
    assign {cout, sum} = a + b + cin;

endmodule 