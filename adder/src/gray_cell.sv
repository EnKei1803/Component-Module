module gray_cell
(
	input logic		G_pre,
	input logic		P_cur, G_cur,
	output logic	G_n
);

	assign G_n = G_cur | ( P_cur & G_pre) ; 

endmodule 