vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_tx_startup_fsm.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_rx_startup_fsm.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_init.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_gt.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_multi_gt.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_sync_block.v" \
"../../../../gtwizard_line_tx_ex.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx.v" \


vlog -work xil_defaultlib \
"glbl.v"

