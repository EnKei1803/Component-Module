// Sequential Multiplier
// Performs multiplication over multiple clock cycles
// More area-efficient than combinational multipliers
// Uses shift-and-add algorithm

module sequential_multiplier #(
    parameter WIDTH = 8
)(
    input                    clk,
    input                    rst_n,
    input                    start,        // Start multiplication
    input  [WIDTH-1:0]       a,            // Multiplicand
    input  [WIDTH-1:0]       b,            // Multiplier
    output [2*WIDTH-1:0]     product,      // Product output
    output                   done          // Operation complete
);

    // State encoding
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;
    
    reg [1:0] state, next_state;
    reg [2*WIDTH-1:0] accumulator;
    reg [WIDTH-1:0] multiplicand;
    reg [WIDTH-1:0] multiplier;
    reg [$clog2(WIDTH):0] counter;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            accumulator <= {2*WIDTH{1'b0}};
            multiplicand <= {WIDTH{1'b0}};
            multiplier <= {WIDTH{1'b0}};
            counter <= 0;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (start) begin
                        multiplicand <= a;
                        multiplier <= b;
                        accumulator <= {2*WIDTH{1'b0}};
                        counter <= 0;
                    end
                end
                
                COMPUTE: begin
                    // Shift and add algorithm
                    if (multiplier[0]) begin
                        accumulator <= accumulator + ({{WIDTH{1'b0}}, multiplicand} << counter);
                    end
                    multiplier <= multiplier >> 1;
                    counter <= counter + 1;
                end
                
                DONE: begin
                    // Stay in done state until start goes low
                    if (!start) begin
                        accumulator <= {2*WIDTH{1'b0}};
                        counter <= 0;
                    end
                end
            endcase
        end
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            IDLE: next_state = start ? COMPUTE : IDLE;
            COMPUTE: next_state = (counter == WIDTH) ? DONE : COMPUTE;
            DONE: next_state = start ? DONE : IDLE;
            default: next_state = IDLE;
        endcase
    end
    
    assign product = accumulator;
    assign done = (state == DONE);

endmodule
