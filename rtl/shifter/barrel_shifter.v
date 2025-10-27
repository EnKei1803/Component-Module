// Barrel Shifter Module
// Performs efficient shifting and rotation operations
// Supports logical left/right, arithmetic right, and rotate operations

module barrel_shifter #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0]           data_in,    // Input data
    input  [$clog2(WIDTH)-1:0]   shift_amt,  // Shift amount
    input  [2:0]                 shift_type, // Shift operation type
    output [WIDTH-1:0]           data_out    // Output data
);

    // Shift types
    localparam LOGICAL_LEFT  = 3'b000;
    localparam LOGICAL_RIGHT = 3'b001;
    localparam ARITH_RIGHT   = 3'b010;
    localparam ROTATE_LEFT   = 3'b011;
    localparam ROTATE_RIGHT  = 3'b100;

    reg [WIDTH-1:0] result;
    
    always @(*) begin
        case (shift_type)
            LOGICAL_LEFT: begin
                result = data_in << shift_amt;
            end
            
            LOGICAL_RIGHT: begin
                result = data_in >> shift_amt;
            end
            
            ARITH_RIGHT: begin
                result = $signed(data_in) >>> shift_amt;
            end
            
            ROTATE_LEFT: begin
                result = (data_in << shift_amt) | (data_in >> (WIDTH - shift_amt));
            end
            
            ROTATE_RIGHT: begin
                result = (data_in >> shift_amt) | (data_in << (WIDTH - shift_amt));
            end
            
            default: begin
                result = data_in;
            end
        endcase
    end
    
    assign data_out = result;

endmodule
