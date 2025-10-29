`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 09:49:33 AM
// Design Name: 
// Module Name: serial_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module serial_tb;

  // Parameters
    parameter N_TAPS      = 21;
    parameter DATA_WIDTH  = 16;
    parameter COEF_WIDTH  = 16;
    parameter OUT_WIDTH   = 37;

    // DUT signals
    reg clk;
    reg rst_n;
    reg signed [DATA_WIDTH-1:0] x_in;
    reg x_valid;
    wire signed [OUT_WIDTH-1:0] y_out;

    // Instantiate the DUT
    serial #(
        .N_TAPS(N_TAPS),
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_in),
        .x_valid(x_valid),
        .y_out(y_out)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Parameters for sine generation
    integer sample_count;
    integer total_samples = 1024;
    real pi = 3.141592653589793;
    real phase;
    real freq_start = 0.0;       // Normalized freq = 0
    real freq_end = 0.5;         // Normalized freq = 0.5 (Nyquist)
    real freq;                   // Current freq for sine
    real sine_val;

    initial begin
        // Init signals
        rst_n = 0;
        x_in = 0;
        x_valid = 0;
        sample_count = 0;

        // Release reset after some cycles
        #20;
        rst_n = 1;
        #10;

        x_valid = 1;

        // Generate sine sweep input over total_samples
        for (sample_count = 0; sample_count < total_samples; sample_count = sample_count + 1) begin
            // Linear freq sweep from freq_start to freq_end
            freq = freq_start + (freq_end - freq_start) * sample_count / total_samples;
            phase = 2.0 * pi * freq * sample_count;
            sine_val = $sin(phase);

            // Scale sine to 16-bit signed range
            x_in = $rtoi(sine_val * 30000);  // 30000 to avoid overflow

            @(posedge clk);
        end

        // Stop sending valid data
        x_valid = 0;
        x_in = 0;

        // Wait a few cycles for output to settle
        repeat (20) @(posedge clk);

        $display("Testbench done.");
        $finish;
    end

    // Output monitor
    always @(posedge clk) begin
        if (x_valid)
            $display("Time %t | x_in = %d | y_out = %d", $time, x_in, y_out);
        else
            $display("Time %t | y_out = %d", $time, y_out);
    end

endmodule
