`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 10:17:10 AM
// Design Name: 
// Module Name: fir_transposed_rom_tb
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

    // === Parameters ===
    parameter N_TAPS      = 21;
    parameter DATA_WIDTH  = 16;
    parameter COEF_WIDTH  = 16;
    parameter OUT_WIDTH   = 37;
    parameter CLK_PERIOD  = 10;  // 100 MHz clock

    // === DUT signals ===
    reg clk;
    reg rst_n;
    reg signed [DATA_WIDTH-1:0] x_in;
    reg x_valid;
    wire signed [OUT_WIDTH-1:0] y_out;

    // === Instantiate DUT ===
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

    // === Clock generation ===
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // === Sine sweep parameters ===
    integer sample_count;
    integer total_samples = 256; // reduce for fast sim
    real pi = 3.141592653589793;
    real freq_start = 0.01;      // normalized start frequency
    real freq_end   = 0.25;      // normalized end frequency (0.5 = Nyquist)
    real freq, phase, sine_val;

    // === File logging ===
    integer f_log;
    initial f_log = $fopen("fir_output.csv", "w");

    // === Test sequence ===
    initial begin
        // Init
        rst_n = 0;
        x_in = 0;
        x_valid = 0;

        // Reset for a few cycles
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (5) @(posedge clk);

        $display("Starting sine sweep test...");
        $fwrite(f_log, "time_ns,x_in,y_out\n");

        x_valid = 1;
        // Generate sine sweep input
        for (sample_count = 0; sample_count < total_samples; sample_count = sample_count + 1) begin
            freq  = freq_start + (freq_end - freq_start) * sample_count / total_samples;
            phase = 2.0 * pi * freq * sample_count;
            sine_val = $sin(phase);
            x_in = $rtoi(sine_val * 15000.0);  // keep within ±32767
            @(posedge clk);

            // Log data
            $fwrite(f_log, "%0t,%0d,%0d\n", $time, x_in, y_out);
        end

        // Stop valid input
        x_valid = 0;
        x_in = 0;

        // Let output settle
        repeat (N_TAPS*2) @(posedge clk);

        $display("Test complete. Data written to fir_output.csv");
        $fclose(f_log);
        $stop;
    end

    // Optional display (limited)
    always @(posedge clk)
        if (x_valid && (sample_count % 16 == 0))
            $display("t=%0t ns | x_in=%d | y_out=%d", $time, x_in, y_out);

endmodule




