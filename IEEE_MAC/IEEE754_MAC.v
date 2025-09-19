module mac (
    input         clk,      // Clock signal
    input         rst,      // Active-high synchronous reset
    input  [31:0] a,        // Multiplier input (IEEE-754)
    input  [31:0] b,        // Multiplicand input (IEEE-754)
    input  [31:0] c,        // Accumulation input (IEEE-754)
    output reg [31:0] mac_ieee,      // MAC result in IEEE-754 format (registered)
    output reg    overflow,          // Combined overflow signal (registered)
    output reg    underflow        // Combined underflow signal (registered)
  
);
 

    // Internal wires for combinational results.
    wire [31:0] mul_result;
    wire [31:0] add_result;
    wire        mul_overflow, mul_underflow;
    wire        add_overflow, add_underflow;

    // Instantiate the IEEE-754 multiplier.
    ieee754_mul multiplier (
        .a(a),
        .b(b),
        .s(mul_result),
        .overflow(mul_overflow),
        .underflow(mul_underflow)
    );

    // Instantiate the IEEE-754 adder.
    ieee754_adder adder (
        .a(mul_result),
        .b(c),
        .s(add_result),
        .overflow(add_overflow),
        .underflow(add_underflow)
    );
    // Register outputs on rising edge of clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mac_ieee  <= 32'b0;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else begin
            mac_ieee  <= add_result;
            overflow  <= mul_overflow | add_overflow;
            underflow <= mul_underflow | add_underflow;
        end
    end

endmodule
