module black_cell
(
	input logic		P_pre, G_pre,
	input logic		P_cur, G_cur,
	output logic	P_n, G_n
);

	assign G_n = G_cur | ( P_cur & G_pre) ; 
	assign P_n = P_pre & P_cur ;

endmodule 