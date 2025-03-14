`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DC Group
// Engineer: Di Wu
// 
// Create Date: 2025/03/14
// Design Name: 
// Module Name: gtwizard_tx_top.sv
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

module gtwizard_tx_top # (
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES      =   1,//configuration for frame gen and check
    parameter EXAMPLE_LANE_WITH_START_CHAR          =   0,         // specifies lane with unique start frame char
    parameter EXAMPLE_WORDS_IN_BRAM                 =   512,       // specifies amount of data in BRAM
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP           =   "TRUE",    // simulation setting for GT SecureIP model
    parameter EXAMPLE_USE_CHIPSCOPE                 =   0,         // Set to 1 to use Chipscope to drive resets
    parameter STABLE_CLOCK_PERIOD                   =   16,
    parameter WID_PER_LANE                          =   16,
    parameter LINE_TX_LANES                         =   2
)(
    input wire  Q0_CLK1_GTREFCLK_PAD_N_IN,
    input wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
    input wire  DRP_CLK_IN_P,
    input wire  DRP_CLK_IN_N,
    output wire TRACK_DATA_OUT,
    input  wire [1:0]   RXN_IN,
    input  wire [1:0]   RXP_IN,
    input  wire [WID_PER_LANE-1:0] gt0_txdata_i, gt1_txdata_i,      // Input data ports
    output wire [1:0]   TXN_OUT,
    output wire [1:0]   TXP_OUT
);

    wire soft_reset_i;
    (*mark_debug = "TRUE" *) wire soft_reset_vio_i;

//************************** Register Declarations ****************************
    wire            gt_txfsmresetdone_i;
    wire            gt_rxfsmresetdone_i;
    (* ASYNC_REG = "TRUE" *)reg             gt_txfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt_txfsmresetdone_r2;
    wire            gt0_txfsmresetdone_i;
    wire            gt0_rxfsmresetdone_i;
    (* ASYNC_REG = "TRUE" *)reg             gt0_txfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_txfsmresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxfsmresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_r3;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt0_rxresetdone_vio_r3;

    wire            gt1_txfsmresetdone_i;
    wire            gt1_rxfsmresetdone_i;
    (* ASYNC_REG = "TRUE" *)reg             gt1_txfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt1_txfsmresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxfsmresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxfsmresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_r;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_r3;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_vio_r;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_vio_r2;
    (* ASYNC_REG = "TRUE" *)reg             gt1_rxresetdone_vio_r3;

    reg [5:0] reset_counter = 0;
    reg     [3:0]   reset_pulse;

//**************************** Wire Declarations ******************************//
    //------------------------ GT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GT0  (X1Y0)
    //-------------------------- Channel - DRP Ports  --------------------------
    wire    [8:0]   gt0_drpaddr_i;
    wire    [15:0]  gt0_drpdi_i;
    wire    [15:0]  gt0_drpdo_i;
    wire            gt0_drpen_i;
    wire            gt0_drprdy_i;
    wire            gt0_drpwe_i;
    //------------------------- Digital Monitor Ports --------------------------
    wire    [7:0]   gt0_dmonitorout_i;
    //------------------- RX Initialization and Reset Ports --------------------
    wire            gt0_eyescanreset_i;
    wire            gt0_rxuserrdy_i;
    //------------------------ RX Margin Analysis Ports ------------------------
    wire            gt0_eyescandataerror_i;
    wire            gt0_eyescantrigger_i;
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    wire    [15:0]  gt0_rxdata_i;
    //------------------------- Receive Ports - RX AFE -------------------------
    wire            gt0_gtxrxp_i;
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    wire            gt0_gtxrxn_i;
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    wire            gt0_rxmcommaalignen_i;
    wire            gt0_rxpcommaalignen_i;
    //------------------- Receive Ports - RX Equalizer Ports -------------------
    wire            gt0_rxdfelpmreset_i;
    wire    [6:0]   gt0_rxmonitorout_i;
    wire    [1:0]   gt0_rxmonitorsel_i;
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    wire            gt0_rxoutclk_i;
    wire            gt0_rxoutclkfabric_i;
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    wire            gt0_gtrxreset_i;
    wire            gt0_rxpmareset_i;
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    wire            gt0_rxresetdone_i;
    //------------------- TX Initialization and Reset Ports --------------------
    wire            gt0_gttxreset_i;
    wire            gt0_txuserrdy_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [15:0]  gt0_txdata_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire            gt0_gtxtxn_i;
    wire            gt0_gtxtxp_i;
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    wire            gt0_txoutclk_i;
    wire            gt0_txoutclkfabric_i;
    wire            gt0_txoutclkpcs_i;
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    wire            gt0_txresetdone_i;

    //________________________________________________________________________
    //________________________________________________________________________
    //GT1  (X1Y1)
    //-------------------------- Channel - DRP Ports  --------------------------
    wire    [8:0]   gt1_drpaddr_i;
    wire    [15:0]  gt1_drpdi_i;
    wire    [15:0]  gt1_drpdo_i;
    wire            gt1_drpen_i;
    wire            gt1_drprdy_i;
    wire            gt1_drpwe_i;
    //------------------------- Digital Monitor Ports --------------------------
    wire    [7:0]   gt1_dmonitorout_i;
    //------------------- RX Initialization and Reset Ports --------------------
    wire            gt1_eyescanreset_i;
    wire            gt1_rxuserrdy_i;
    //------------------------ RX Margin Analysis Ports ------------------------
    wire            gt1_eyescandataerror_i;
    wire            gt1_eyescantrigger_i;
    //---------------- Receive Ports - FPGA RX interface Ports -----------------
    wire    [15:0]  gt1_rxdata_i;
    //------------------------- Receive Ports - RX AFE -------------------------
    wire            gt1_gtxrxp_i;
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    wire            gt1_gtxrxn_i;
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    wire            gt1_rxmcommaalignen_i;
    wire            gt1_rxpcommaalignen_i;
    //------------------- Receive Ports - RX Equalizer Ports -------------------
    wire            gt1_rxdfelpmreset_i;
    wire    [6:0]   gt1_rxmonitorout_i;
    wire    [1:0]   gt1_rxmonitorsel_i;
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    wire            gt1_rxoutclk_i;
    wire            gt1_rxoutclkfabric_i;
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    wire            gt1_gtrxreset_i;
    wire            gt1_rxpmareset_i;
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    wire            gt1_rxresetdone_i;
    //------------------- TX Initialization and Reset Ports --------------------
    wire            gt1_gttxreset_i;
    wire            gt1_txuserrdy_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [15:0]  gt1_txdata_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire            gt1_gtxtxn_i;
    wire            gt1_gtxtxp_i;
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    wire            gt1_txoutclk_i;
    wire            gt1_txoutclkfabric_i;
    wire            gt1_txoutclkpcs_i;
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    wire            gt1_txresetdone_i;

    //____________________________COMMON PORTS________________________________
    //-------------------- Common Block  - Ref Clock Ports ---------------------
    wire            gt0_gtrefclk1_common_i;
    //----------------------- Common Block - QPLL Ports ------------------------
    wire            gt0_qplllock_i;
    wire            gt0_qpllrefclklost_i;
    wire            gt0_qpllreset_i;


    //----------------------------- Global Signals -----------------------------

    wire            drpclk_in_i;
    wire            DRPCLK_IN;
    wire            gt0_tx_system_reset_c;
    wire            gt0_rx_system_reset_c;
    wire            gt1_tx_system_reset_c;
    wire            gt1_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            GTTXRESET_IN;
    wire            GTRXRESET_IN;
    wire            QPLLRESET_IN;

     //--------------------------- User Clocks ---------------------------------
     wire            gt0_txusrclk_i; 
     wire            gt0_txusrclk2_i; 
     wire            gt0_rxusrclk_i; 
     wire            gt0_rxusrclk2_i; 
     wire            gt1_txusrclk_i; 
     wire            gt1_txusrclk2_i; 
     wire            gt1_rxusrclk_i; 
     wire            gt1_rxusrclk2_i; 
 
    //--------------------------- Reference Clocks ----------------------------
    
    wire            q0_clk1_refclk_i;


    //--------------------- Frame check/gen Module Signals --------------------
    wire            gt0_matchn_i;
    
    wire    [5:0]   gt0_txcharisk_float_i;
   
    wire    [15:0]  gt0_txdata_float16_i;
    wire    [47:0]  gt0_txdata_float_i;
    
    
    wire            gt0_block_sync_i;
    wire            gt0_track_data_i;
    wire    [7:0]   gt0_error_count_i;
    wire            gt0_frame_check_reset_i;
    wire            gt0_inc_in_i;
    wire            gt0_inc_out_i;
    wire    [15:0]  gt0_unscrambled_data_i;

    wire            gt1_matchn_i;
    
    wire    [5:0]   gt1_txcharisk_float_i;
   
    wire    [15:0]  gt1_txdata_float16_i;
    wire    [47:0]  gt1_txdata_float_i;
    
    
    wire            gt1_block_sync_i;
    wire            gt1_track_data_i;
    wire    [7:0]   gt1_error_count_i;
    wire            gt1_frame_check_reset_i;
    wire            gt1_inc_in_i;
    wire            gt1_inc_out_i;
    wire    [15:0]  gt1_unscrambled_data_i;

    wire            reset_on_data_error_i;
    wire            track_data_out_i;


//**************************** Main Body of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 8'hff;

    assign zero_vector_rx_80 = 0;
    assign zero_vector_rx_8 = 0;

    assign  q0_clk1_refclk_i                     =  1'b0;



//***********************************************************************//
//                                                                       //
//--------------------------- The GT Wrapper ----------------------------//
//                                                                       //
//***********************************************************************//

// Use the instantiation template in the example directory to add the GT wrapper to your design.
// In this example, the wrapper is wired up for basic operation with a frame generator and frame 
// checker. The GTs will reset, then attempt to align and transmit data. If channel bonding is 
// enabled, bonding should occur after alignment.
// While connecting the GT TX/RX Reset ports below, please add a delay of
// minimum 500ns as mentioned in AR 43482.


    gtwizard_line_tx_support #
    (
        .EXAMPLE_SIM_GTRESET_SPEEDUP    (EXAMPLE_SIM_GTRESET_SPEEDUP),
        .STABLE_CLOCK_PERIOD            (STABLE_CLOCK_PERIOD)
    )
    gtwizard_line_tx_support_i
    (
        .soft_reset_tx_in               (soft_reset_i),
        .soft_reset_rx_in               (soft_reset_i),
        .dont_reset_on_data_error_in    (tied_to_ground_i),
        .q0_clk1_gtrefclk_pad_n_in      (Q0_CLK1_GTREFCLK_PAD_N_IN),
        .q0_clk1_gtrefclk_pad_p_in      (Q0_CLK1_GTREFCLK_PAD_P_IN),
        .gt0_tx_fsm_reset_done_out      (gt0_txfsmresetdone_i),
        .gt0_rx_fsm_reset_done_out      (gt0_rxfsmresetdone_i),
        .gt0_data_valid_in              (gt0_track_data_i),
        .gt1_tx_fsm_reset_done_out      (gt1_txfsmresetdone_i),
        .gt1_rx_fsm_reset_done_out      (gt1_rxfsmresetdone_i),
        .gt1_data_valid_in              (gt1_track_data_i),

        .gt0_txusrclk_out(gt0_txusrclk_i),
        .gt0_txusrclk2_out(gt0_txusrclk2_i),
        .gt0_rxusrclk_out(gt0_rxusrclk_i),
        .gt0_rxusrclk2_out(gt0_rxusrclk2_i),

        .gt1_txusrclk_out(gt1_txusrclk_i),
        .gt1_txusrclk2_out(gt1_txusrclk2_i),
        .gt1_rxusrclk_out(gt1_rxusrclk_i),
        .gt1_rxusrclk2_out(gt1_rxusrclk2_i),


        //_____________________________________________________________________
        //_____________________________________________________________________
        //GT0  (X1Y0)

        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 (gt0_drpaddr_i),
        .gt0_drpdi_in                   (gt0_drpdi_i),
        .gt0_drpdo_out                  (gt0_drpdo_i),
        .gt0_drpen_in                   (gt0_drpen_i),
        .gt0_drprdy_out                 (gt0_drprdy_i),
        .gt0_drpwe_in                   (gt0_drpwe_i),
        //------------------------- Digital Monitor Ports --------------------------
        .gt0_dmonitorout_out            (gt0_dmonitorout_i),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            (tied_to_ground_i),
        .gt0_rxuserrdy_in               (tied_to_vcc_i),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (gt0_eyescandataerror_i),
        .gt0_eyescantrigger_in          (tied_to_ground_i),
        //---------------- Receive Ports - FPGA RX interface Ports -----------------
        .gt0_rxdata_out                 (gt0_rxdata_i),
        //------------------------- Receive Ports - RX AFE -------------------------
        .gt0_gtxrxp_in                  (RXP_IN[0]),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtxrxn_in                  (RXN_IN[0]),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxmcommaalignen_in         (gt0_rxmcommaalignen_i),
        .gt0_rxpcommaalignen_in         (gt0_rxpcommaalignen_i),
        //------------------- Receive Ports - RX Equalizer Ports -------------------
        .gt0_rxdfelpmreset_in           (tied_to_ground_i),
        .gt0_rxmonitorout_out           (gt0_rxmonitorout_i),
        .gt0_rxmonitorsel_in            (2'b00),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclkfabric_out         (gt0_rxoutclkfabric_i),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (tied_to_ground_i),
        .gt0_rxpmareset_in              (gt0_rxpmareset_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (gt0_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               (tied_to_ground_i),
        .gt0_txuserrdy_in               (tied_to_vcc_i),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .gt0_txdata_in                  (gt0_txdata_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .gt0_gtxtxn_out                 (TXN_OUT[0]),
        .gt0_gtxtxp_out                 (TXP_OUT[0]),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclkfabric_out         (gt0_txoutclkfabric_i),
        .gt0_txoutclkpcs_out            (gt0_txoutclkpcs_i),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt0_txresetdone_out            (gt0_txresetdone_i),



        //_____________________________________________________________________
        //_____________________________________________________________________
        //GT1  (X1Y1)

        //-------------------------- Channel - DRP Ports  --------------------------
        .gt1_drpaddr_in                 (gt1_drpaddr_i),
        .gt1_drpdi_in                   (gt1_drpdi_i),
        .gt1_drpdo_out                  (gt1_drpdo_i),
        .gt1_drpen_in                   (gt1_drpen_i),
        .gt1_drprdy_out                 (gt1_drprdy_i),
        .gt1_drpwe_in                   (gt1_drpwe_i),
        //------------------------- Digital Monitor Ports --------------------------
        .gt1_dmonitorout_out            (gt1_dmonitorout_i),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt1_eyescanreset_in            (tied_to_ground_i),
        .gt1_rxuserrdy_in               (tied_to_vcc_i),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt1_eyescandataerror_out       (gt1_eyescandataerror_i),
        .gt1_eyescantrigger_in          (tied_to_ground_i),
        //---------------- Receive Ports - FPGA RX interface Ports -----------------
        .gt1_rxdata_out                 (gt1_rxdata_i),
        //------------------------- Receive Ports - RX AFE -------------------------
        .gt1_gtxrxp_in                  (RXP_IN[1]),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt1_gtxrxn_in                  (RXN_IN[1]),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt1_rxmcommaalignen_in         (gt1_rxmcommaalignen_i),
        .gt1_rxpcommaalignen_in         (gt1_rxpcommaalignen_i),
        //------------------- Receive Ports - RX Equalizer Ports -------------------
        .gt1_rxdfelpmreset_in           (tied_to_ground_i),
        .gt1_rxmonitorout_out           (gt1_rxmonitorout_i),
        .gt1_rxmonitorsel_in            (2'b00),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt1_rxoutclkfabric_out         (gt1_rxoutclkfabric_i),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt1_gtrxreset_in               (tied_to_ground_i),
        .gt1_rxpmareset_in              (gt1_rxpmareset_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt1_rxresetdone_out            (gt1_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt1_gttxreset_in               (tied_to_ground_i),
        .gt1_txuserrdy_in               (tied_to_vcc_i),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .gt1_txdata_in                  (gt1_txdata_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .gt1_gtxtxn_out                 (TXN_OUT[1]),
        .gt1_gtxtxp_out                 (TXP_OUT[1]),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt1_txoutclkfabric_out         (gt1_txoutclkfabric_i),
        .gt1_txoutclkpcs_out            (gt1_txoutclkpcs_i),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt1_txresetdone_out            (gt1_txresetdone_i),


    //____________________________COMMON PORTS________________________________
        .gt0_qplllock_out(),
        .gt0_qpllrefclklost_out(),
        .gt0_qplloutclk_out(),
        .gt0_qplloutrefclk_out(),
        .sysclk_in(drpclk_in_i)
    );


endmodule