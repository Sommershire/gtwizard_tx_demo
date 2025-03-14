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
    parameter LINE_TX_LANES = 2
)(
    input clk,                          // system clk
    input rst,                          // rst
    input line_tx_clk,                  // GTX ref clk 156.5MHz
    input drpclk_in,                    // GTX drp clk 50MHz

    output logic [LINE_TX_LANES-1:0] line_tx_data_out             // GTX data output 5Gbps
);

logic line_txclk;
assign line_tx_clk_p = line_tx_clk;
assign line_tx_clk_n = !line_tx_clk;

assign drpclk_in_p = drpclk_in;
assign drpclk_in_n = !drpclk_in;



/* ------------------------------ PRBS-23 BEGIN ----------------------------- */
logic [31:0] prbs_64b;

gtwizard_sync_prbs_prbs_any # (
    .CHK_MODE   (0 ),   // Generation mode
    .INV_PATTERN(0 ),   // No invert
    .POLY_LENGHT(23),   // PRBS-23
    .POLY_TAP   (18),   // PRBS23 = X23+X18+1
    .NBITS      (32)    // bus size 
) prbs_any_gen_inst (
    .RST        (!rst), // RST高位有效
    .CLK        (line_tx_clk_p),
    .DATA_IN    (0),
    .EN         (1),
    .DATA_OUT   (prbs_64b)
);


// 5Gb/s
logic [WID_PER_LANE*LINE_TX_LANES-1:0] line_tx_data_raw;
always @ (posedge line_tx_clk) begin
    line_tx_data_raw <= prbs_64b;
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

logic [31:0] line_tx_data_raw_12;
logic [31:0] line_tx_data_to_gt_5g_sp;

genvar m, n;

// // downsample 1/2
// for (m=0; m<LINE_TX_LANES*WID_PER_LANE/2; m++) begin
//     assign line_tx_data_raw_12 = line_tx_data_raw[m*2];
// end

for (m=0; m<LINE_TX_LANES/2+1; m++) begin
    for (n=0; n<WID_PER_LANE; n++) begin
        assign line_tx_data_to_gt_5g_sp[m*WID_PER_LANE+n] = line_tx_data_raw[m+LINE_TX_LANES/2*n];
    end
end

logic [WID_PER_LANE*LINE_TX_LANES-1:0] line_tx_data_to_gt;

always @ (posedge line_tx_clk) begin
    line_tx_data_to_gt <= line_tx_data_to_gt_5g_sp;
end

/* ---------------------------- Rate Matching END --------------------------- */

reg [WID_PER_LANE-1:0] line_tx_data_in [1:2];
assign line_tx_data_in[1] = line_tx_data_to_gt[WID_PER_LANE*1-1 -: WID_PER_LANE];
assign line_tx_data_in[2] = line_tx_data_to_gt[WID_PER_LANE*2-1 -: WID_PER_LANE];

/* ------------------------------- gtwizard tx ------------------------------ */
    gtwizard_tx_top gtwizard_tx_top (
        .Q0_CLK1_GTREFCLK_PAD_N_IN  (line_tx_clk_n),                // REF CLK for TX
        .Q0_CLK1_GTREFCLK_PAD_P_IN  (line_tx_clk_p),                     
        .DRP_CLK_IN_P               (drpclk_in_n),                  // DRP CLK
        .DRP_CLK_IN_N               (drpclk_in_p),
        .TRACK_DATA_OUT             (),
        .RXN_IN                     (),
        .RXP_IN                     (),
        .gt0_txdata_i               (line_tx_data_in[1]),
        .gt1_txdata_i               (line_tx_data_in[2]),
        .TXN_OUT                    (),
        .TXP_OUT                    (line_tx_data_out)
    );

endmodule