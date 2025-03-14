`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DC Group
// Engineer: Di Wu
// 
// Create Date: 2025/03/13
// Design Name: 
// Module Name: comm_tx_top_tb
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

module comm_tx_top_tb #(
    parameter   TX_REFCLK_PERIOD = 6.4,
    parameter   SYSCLK_PERIOD = 20,
    parameter   DRPCLK_PERIOD = 20
)();
    logic rst;
    logic clk;

    logic line_tx_clk;
    logic drpclk_in;  

    logic [1:0] line_tx_data_out;

    /* ---------------------------------- Reset --------------------------------- */
    initial begin
        rst = 1;
        #10
        rst = 0;
        #10
        rst = 1;
    end

    /* --------------------------- Generate Ref Clock --------------------------- */
    initial begin
        line_tx_clk = 1;
    end

    always #(TX_REFCLK_PERIOD/2) line_tx_clk = !line_tx_clk;

    /* -------------------------- Generate System Clock ------------------------- */
    initial begin
        clk = 1;
    end

    always #(SYSCLK_PERIOD/2) clk = !clk;

    /* --------------------------- Generate DRP Clock --------------------------- */
    initial begin 
        drpclk_in = 1;
    end

    always #(DRPCLK_PERIOD/2) drpclk_in = !drpclk_in;

    comm_tx_top comm_tx_top (
        .clk                (clk),
        .rst                (rst),
        .line_tx_clk        (line_tx_clk),
        .drpclk_in          (drpclk_in),

        .line_tx_data_out   (line_tx_data_out)
    );

endmodule
