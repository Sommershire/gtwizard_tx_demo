`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DC Group
// Engineer: Di Wu
// 
// Create Date: 2025/03/13
// Design Name: 
// Module Name: comm_tx_top
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

module comm_tx_top # (
    parameter WID_PER_LANE = 16,
    parameter LINE_TX_LANES = 4
)(
    input clk,
    input rst,
    input rsat_linetx_clk,

    output line_txclk_o
);

logic line_txclk;
assign line_txclk_o = line_txclk;


/* ------------------------------ PRBS-23 BEGIN ----------------------------- */
logic [63:0] prbs_64b;

gtwizard_sync_prbs_prbs_any # (
    .CHK_MODE   (0 ),   // Generation mode
    .INV_PATTERN(0 ),   // No invert
    .POLY_LENGHT(23),   // PRBS-23
    .POLY_TAP   (18),   // PRBS23 = X23+X18+1
    .NBITS      (64)    // bus size 
) prbs_any_gen_inst (
    .RST        (!rst), // RST高位有效
    .CLK        (clk),
    .DATA_IN    (0),
    .EN         (1),
    .DATA_OUT   (prbs_64b)
);


// 5Gb/s
logic [WID_PER_LANE*LINE_TX_LANES-1:0] line_tx_raw;
always @ (posedge line_txclk) begin
    line_tx_raw <= prbs_64b;
end
/* ------------------------------- PRBS-23 END ------------------------------ */

/* --------------------------- Rate Matching BEGIN -------------------------- */
// 暂时只考虑2.5G SP-QPSK场景

//////////////////////////////////////////////////////////////////////////////////
// Mod Format  SP-QPSK 5G   
// Baudrate    2.5Gbaud     
// DAC         5GSa/s       
// Tx Bitrate  5Gbps
//////////////////////////////////////////////////////////////////////////////////

logic [63:0] line_tx_data_to_gt_5g;

genvar m, n;
for (m=0; m<LINE_TX_LANES; m=m+1) begin
    for (n=0; n<WID_PER_LANE; n=n+1) begin
        assign line_tx_data_to_gt_1g[m*WID_PER_LANE+n] = line_tx_raw[m+LINE_TX_LANES*n];
    end
end

logic [WID_PER_LANE*LINE_TX_LANES-1:0] line_tx_data_to_gt;

always @ (posedge line_txclk) begin
    line_tx_data_to_gt <= line_tx_data_to_gt_1g;
end

/* ---------------------------- Rate Matching END --------------------------- */

reg [WID_PER_LANE-1:0] line_tx_data [1:4];
assign line_tx_data[1] = line_tx_data_to_gt[WID_PER_LANE*1-1 -: WID_PER_LANE];
assign line_tx_data[2] = line_tx_data_to_gt[WID_PER_LANE*2-1 -: WID_PER_LANE];
assign line_tx_data[3] = line_tx_data_to_gt[WID_PER_LANE*3-1 -: WID_PER_LANE];
assign line_tx_data[4] = line_tx_data_to_gt[WID_PER_LANE*4-1 -: WID_PER_LANE];


/* ------------------------------- gtwizard tx ------------------------------ */


endmodule