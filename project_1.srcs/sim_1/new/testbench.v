`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2020 04:04:49 AM
// Design Name: 
// Module Name: testbench
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


module testbench;

    reg clk = 0;
    wire Hsync;
    wire Vsync;
    wire [3:0]vgaRed;
    wire [3:0]vgaGreen;
    wire [3:0]vgaBlue;
   
    top UUT (clk , Hsync , Vsync , vgaRed ,vgaGreen , vgaBlue);
    
    always #5 clk = -clk;
endmodule
