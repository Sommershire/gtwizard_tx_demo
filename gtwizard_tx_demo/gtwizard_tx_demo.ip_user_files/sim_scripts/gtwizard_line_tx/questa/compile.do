vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_tx_startup_fsm.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_rx_startup_fsm.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_init.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_gt.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx_multi_gt.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx/example_design/gtwizard_line_tx_sync_block.v" \
"../../../../gtwizard_tx_demo.gen/sources_1/ip/gtwizard_line_tx/gtwizard_line_tx.v" \


vlog -work xil_defaultlib \
"glbl.v"

