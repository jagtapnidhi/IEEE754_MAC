`timescale 1ns/1ps
module mac_tb;

    // Signals
    reg         clk;
    reg         rst;
    reg  [31:0] a, b, c;

    // Outputs from the DUT
    wire [31:0] mac_ieee;
    wire signed [31:0] mac_dec; // This is the scaled result (value * 10)
    wire        overflow, underflow;
    wire signed [31:0] a_dec, b_dec, c_dec;

    // Real variables to display as floating values (divide scaled value by 10.0)
    real a_real, b_real, c_real, mac_real;

    // Instantiate the Device Under Test (DUT)
    mac dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .c(c),
        .mac_ieee(mac_ieee),
        .mac_dec(mac_dec),
        .overflow(overflow),
        .underflow(underflow),
        .a_dec(a_dec),
        .b_dec(b_dec),
        .c_dec(c_dec)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Function: Convert scaled integer (value*10) to a real by dividing by 10.0.
    function real scaled_to_real(input signed [31:0] scaled);
        begin
            scaled_to_real = scaled / 10.0;
        end
    endfunction

    // Continuously update real variables for display.
    always @(*) begin
        a_real = scaled_to_real(a_dec);
        b_real = scaled_to_real(b_dec);
        c_real = scaled_to_real(c_dec);
        mac_real = scaled_to_real(mac_dec);
    end

    // Test stimulus with non-integer and negative values.
    initial begin
        // Apply reset
        rst = 1;
        a = 32'h00000000;
        b = 32'h00000000;
        c = 32'h00000000;
        #20;
        rst = 0;  // Deassert reset after 20 ns

        // Monitor changes: prints the real values (with one fractional digit)
        $monitor($time, 
            " ns: a=%f, b=%f, c=%f => mac=%f", 
            a_real, b_real, c_real, mac_real);

        // -----------------------------------------------------------
        // Test 1: 1.1 * (-2.2) + 3.3
        // Expected: (1.1 * -2.2) + 3.3 ≈ -2.42 + 3.3 ≈ 0.88
        #10;
        a = 32'h3F8CCCCD;  // 1.1
        b = 32'hC00CCCCD;  // -2.2
        c = 32'h40533333;  // 3.3
        #20;
        
        // -----------------------------------------------------------
        // Test 2: (-1.5) * 2.0 + (-0.5)
        // Expected: (-1.5 * 2.0) + (-0.5) = -3.0 - 0.5 = -3.5
        #10;
        a = 32'hBFC00000;  // -1.5
        b = 32'h40000000;  // 2.0
        c = 32'hBF000000;  // -0.5
        #20;
        
        // -----------------------------------------------------------
        // Test 3: 2.0 * 3.0 + 1.0
        // Expected: 2.0 * 3.0 + 1.0 = 7.0
        #10;
        a = 32'h40000000;  // 2.0
        b = 32'h40400000;  // 3.0
        c = 32'h3F800000;  // 1.0
        #20;

        $finish;
    end

endmodule

