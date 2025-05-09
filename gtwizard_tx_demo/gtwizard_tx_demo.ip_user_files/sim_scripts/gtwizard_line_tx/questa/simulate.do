onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib gtwizard_line_tx_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {gtwizard_line_tx.udo}

run -all

quit -force
