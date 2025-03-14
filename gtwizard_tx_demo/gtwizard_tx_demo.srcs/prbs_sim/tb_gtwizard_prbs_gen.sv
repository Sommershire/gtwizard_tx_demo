`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DC Group
// Engineer: Di Wu
// 
// Create Date: 2025/03/12
// Design Name: 
// Module Name: tb_gtwizard_prbs_gen
// Project Name: tx
// Target Devices: xc7k420tiffg901-2L
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

module tb_gtwizard_prbs_gen();

parameter T = 20;

logic clk;
logic rst;

logic valid;
logic [63:0] prbs_64b;

initial begin
    clk = 0;
    rst = 1;
    #10
    rst = 0;
    #10
    rst = 1;
end

// clk freq 100M
always #(T/2) clk = ~clk;

gtwizard_sync_prbs_prbs_any # (
    .CHK_MODE   (0 ),   // Generation mode
    .INV_PATTERN(0 ),   // No invert
    .POLY_LENGHT(23),   // PRBS-23
    .POLY_TAP   (18),   // PRBS23 = X23+X18+1
    .NBITS      (64)    // bus size 
) prbs_any_gen_inst (
    .RST        (!rst),
    .CLK        (clk),
    .DATA_IN    (0),
    .EN         (1),
    .DATA_OUT   (prbs_64b)
);

endmodule