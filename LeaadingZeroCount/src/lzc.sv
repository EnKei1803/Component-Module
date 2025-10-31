/*
==================================================================================================
  _                   _ _               _____                 ____                  _            
 | |    ___  __ _  __| (_)_ __   __ _  |__  /___ _ __ ___    / ___|___  _   _ _ __ | |_ ___ _ __ 
 | |   / _ \/ _` |/ _` | | '_ \ / _` |   / // _ \ '__/ _ \  | |   / _ \| | | | '_ \| __/ _ \ '__|
 | |__|  __/ (_| | (_| | | | | | (_| |  / /|  __/ | | (_) | | |__| (_) | |_| | | | | ||  __/ |   
 |_____\___|\__,_|\__,_|_|_| |_|\__, | /____\___|_|  \___/   \____\___/ \__,_|_| |_|\__\___|_|   
                                |___/                                                            
==================================================================================================
*/
module lzc_4bits
(
	input logic		[3:0]	x,		// Input Value
	
	output logic	[1:0]	q,		// Zero Count
	output logic			a		// All zero
);

	assign a 	= ~|x[3:0];
	assign q[1] = ~|x[3:2] & ~a;
	assign q[0] = ~x[3] & (x[2] | ~x[1]) & ~a;

endmodule 

// ======== lze ========

module lze	// Leading Zero Encoder
(
	input logic		[5:0]	a,		// Input Value
	
	output logic	[2:0]	q		// Zero Count
);

	assign q[0] = ( a[5] &  a[4] &  a[3] &  a[2] &  a[1] & ~a[0] )
					| ( a[5] &  a[4] &  a[3] & ~a[2] )
					| ( a[5] & ~a[4] );

	assign q[1] = ( a[5] &  a[4] &  a[3] &  a[2] &  a[1] &  a[0] )
					| ( a[5] &  a[4] &  a[3] & ~a[2] )
					| ( a[5] &  a[4] & ~a[3] );
					
	assign q[2] = ( a[5] &  a[4] &  a[3] &  a[2] &  a[1] &  a[0] )
					| ( a[5] &  a[4] &  a[3] &  a[2] &  a[1] & ~a[0] )
					| ( a[5] &  a[4] &  a[3] &  a[2] & ~a[1] );
					
endmodule 

// ======== lze_mux ========

module lze_mux
(
	input	[2:0]	sel,
	input	[1:0]	I0, I1, I2, I3, I4, I5,
	output[1:0] Y
);			

    always @(*) begin
        case (sel)
            3'd0: Y = I0;  
            3'd1: Y = I1; 
            3'd2: Y = I2;  
            3'd3: Y = I3; 
            3'd4: Y = I4;  
            3'd5: Y = I5; 				
            default: Y = 2'd0; 
        endcase
    end	
				
endmodule

// ======== lzc_24bits ========

module lzc_24bits
(
	input logic		[23:0]	x,		// Input Value
	
	output logic	[4:0]		q		// Zero Count
);

	logic a0, a1, a2, a3, a4, a5;
	logic [1:0] z0, z1, z2, z3, z4, z5;
	logic [5:0] a;

	lzc_4bits U0 (.x(x[ 3: 0]),  .q(z5), .a(a5));
	lzc_4bits U1 (.x(x[ 7: 4]),  .q(z4), .a(a4));
	lzc_4bits U2 (.x(x[11: 8]),  .q(z3), .a(a3));
	lzc_4bits U3 (.x(x[15:12]),  .q(z2), .a(a2));
	lzc_4bits U4 (.x(x[19:16]),  .q(z1), .a(a1));
	lzc_4bits U5 (.x(x[23:20]),  .q(z0), .a(a0));
  
//==============================
assign a = {a0, a1, a2, a3, a4, a5};
lze			lze0
(
	.a(a),	.q(q[4:2])
);
//==============================
lze_mux		lze_muxx
(
	.sel(q[4:2]),
	.I0(z0), 
	.I1(z1), 
	.I2(z2), 
	.I3(z3), 
	.I4(z4), 
	.I5(z5),
	.Y(q[1:0])
);	

endmodule 	