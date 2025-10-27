/* 
==================================================================================================
		  ____                                      _             
		 / ___|___  _ __ ___  _ __   __ _ _ __ __ _| |_ ___  _ __ 
		| |   / _ \| '_ ` _ \| '_ \ / _` | '__/ _` | __/ _ \| '__|
		| |__| (_) | | | | | | |_) | (_| | | | (_| | || (_) | |   
		 \____\___/|_| |_| |_| .__/ \__,_|_|  \__,_|\__\___/|_|   
									|_|                                  
==================================================================================================
*/
//	------------------------------------------------------------------------------
// Copy the module from top to bottom to get the size of comparator that you want
// ------------------------------------------------------------------------------

// ==================================================
//		1 bit
// ==================================================

module comparator_1bit
(
  input  logic	operand_a, 
  input  logic	operand_b,
  output logic	o_eq, 
  output logic	o_lt, 
  output logic	o_gt
);

assign o_eq = ~(operand_a ^ operand_b);
assign o_lt = ~ operand_a & operand_b;
assign o_gt = ~(o_eq | o_lt);

endmodule 

// ==================================================
// 	2 bit
// ==================================================

module comparator_2bit
(
  input  logic [1:0] operand_a, 
  input  logic [1:0] operand_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_1bit	com4bit_high	(.operand_a(operand_a[1]), .operand_b(operand_b[1]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_1bit	com4bit_low		(.operand_a(operand_a[0]), .operand_b(operand_b[0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		4 bit
// ==================================================

module comparator_4bit
(
  input  logic [3:0] operand_a, 
  input  logic [3:0] operand_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_2bit	com2bit_high	(.operand_a(operand_a[3:2]), .operand_b(operand_b[3:2]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_2bit	com2bit_low		(.operand_a(operand_a[1:0]), .operand_b(operand_b[1:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		8 bit
// ==================================================

module comparator_8bit
(
  input  logic [7:0] operand_a, 
  input  logic [7:0] operand_b,
  output logic       o_eq, 
  output logic       o_lt, 
  output logic       o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_4bit	com4bit_high	(.operand_a(operand_a[7:4]), .operand_b(operand_b[7:4]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_4bit	com4bit_low		(.operand_a(operand_a[3:0]), .operand_b(operand_b[3:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule

// ==================================================
//		16 bit
// ==================================================

module comparator_16bit
(
  input  logic [15:0] operand_a, 
  input  logic [15:0] operand_b,
  output logic        o_eq, 
  output logic        o_lt, 
  output logic        o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_8bit	com8bit_high	(.operand_a(operand_a[15:8]), .operand_b(operand_b[15:8]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_8bit	com8bit_low		(.operand_a(operand_a[ 7:0]), .operand_b(operand_b[ 7:0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule 

// ==================================================
//		32 bit
// ==================================================

module comparator_32bits
(
  input  logic [31:0] operand_a, 
  input  logic [31:0] operand_b,
  output logic        o_eq, 
  output logic        o_lt, 
  output logic        o_gt
);

logic Ehigh, Lhigh;
logic Elow, Llow;

comparator_16bit	com16bit_high	(.operand_a(operand_a[31:16]), .operand_b(operand_b[31:16]), .o_eq(Ehigh), .o_lt(Lhigh), .o_gt());
comparator_16bit	com16bit_low	(.operand_a(operand_a[15: 0]), .operand_b(operand_b[15: 0]), .o_eq( Elow), .o_lt( Llow), .o_gt());

assign o_eq =  Ehigh & Elow;
assign o_lt = (Ehigh & Llow) | Lhigh;
assign o_gt = ~(o_eq | o_lt);

endmodule 