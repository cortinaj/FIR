`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 09:07:52 AM
// Design Name: 
// Module Name: serial
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


module serial #(
    parameter integer N_TAPS = 21,
    parameter integer DATA_WIDTH = 16,
    parameter integer COEF_WIDTH = 16,
    parameter integer OUT_WIDTH = 37
)(
    input clk, rst_n,
    input signed [DATA_WIDTH-1:0]x_in,
    input x_valid,
    output reg signed [OUT_WIDTH-1:0] y_out
    );
    
    
wire [COEF_WIDTH-1:0] h [0:N_TAPS-1];

    assign h[0]  = 16'd0;
    assign h[1]  = 16'd113;
    assign h[2]  = 16'd0;
    assign h[3]  = 16'hFE7B; // -389 
    assign h[4]  = 16'd0;
    assign h[5]  = 16'd1107;
    assign h[6]  = 16'd0;
    assign h[7]  = 16'hF4EB; // -2797
    assign h[8]  = 16'd0;
    assign h[9]  = 16'd10172;
    assign h[10] = 16'd16356;
    assign h[11] = 16'd10172;
    assign h[12] = 16'd0;
    assign h[13] = 16'hF4EB; // -2797
    assign h[14] = 16'd0;
    assign h[15] = 16'd1107;
    assign h[16] = 16'd0;
    assign h[17] = 16'hFE7B; // -389
    assign h[18] = 16'd0;
    assign h[19] = 16'd113;
    assign h[20] = 16'd0;
    

reg signed [OUT_WIDTH-1:0] acc [0:N_TAPS-1];
integer i;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < N_TAPS; i = i + 1)
            acc[i] <= 0;
        y_out <= 0;
     end
     else if (x_valid) begin
        y_out <= (x_in * h[N_TAPS-1]) + acc[N_TAPS-1];
        
        for (i = N_TAPS-1; i > 0;  i= i -1)
            acc[i] <= (x_in * h[i-1]) + acc[i-1];
            
         acc[0] <= x_in * h[0];
      end
end

endmodule
