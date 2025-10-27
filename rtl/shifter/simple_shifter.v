// Simple Shifter Module
// Performs single-bit shift operations per clock cycle
// Useful for sequential shift register implementations

module simple_shifter #(
    parameter WIDTH = 8
)(
    input              clk,
    input              rst_n,
    input              shift_en,     // Enable shifting
    input  [WIDTH-1:0] data_in,      // Parallel load data
    input              load,         // Load data_in into register
    input              shift_dir,    // 0 = left, 1 = right
    input              shift_mode,   // 0 = logical, 1 = arithmetic (for right shift)
    input              serial_in,    // Serial input bit
    output [WIDTH-1:0] data_out,     // Parallel output
    output             serial_out    // Serial output
);

    reg [WIDTH-1:0] shift_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= {WIDTH{1'b0}};
        end else if (load) begin
            shift_reg <= data_in;
        end else if (shift_en) begin
            if (shift_dir == 1'b0) begin  // Left shift
                shift_reg <= {shift_reg[WIDTH-2:0], serial_in};
            end else begin  // Right shift
                if (shift_mode == 1'b0) begin  // Logical right shift
                    shift_reg <= {serial_in, shift_reg[WIDTH-1:1]};
                end else begin  // Arithmetic right shift
                    shift_reg <= {shift_reg[WIDTH-1], shift_reg[WIDTH-1:1]};
                end
            end
        end
    end
    
    assign data_out = shift_reg;
    assign serial_out = shift_dir ? shift_reg[0] : shift_reg[WIDTH-1];

endmodule
