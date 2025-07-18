# Clean previous work files
#exec cmd /c del /Q w*

# Compile design files
vlog -sv AXI4.sv axi_if.sv
vlog tx_pkg.sv Top.sv +define+UVM_REPORT_DISABLE_FILE_LINE 

# Launch simulation
vsim -classdebug -uvmcontrol=all work.top +UVM_VERBOSITY=UVM_LOW +UVM_TESTNAME=read_after_write_i_test \
     +UVM_NO_RELNOTES  +UVM_NO_MSG=PHASESEQ +UVM_NO_MSG=PH_READY_TO_END 
#-sv_seed random
add wave -position insertpoint \
    sim:/top/axi_i/AW* \
    sim:/top/axi_i/W*  \
    sim:/top/axi_i/B*  \
    sim:/top/axi_i/clk \
    sim:/top/axi_i/AR* \
    sim:/top/axi_i/R*  \
    sim:/top/axi_i/rst_n
property wave -color orchid /top/axi_i/AWADDR
property wave -color orchid /top/axi_i/ARADDR
property wave -color gold /top/axi_i/RDATA
property wave -color gold /top/axi_i/WDATA

# Run simulation
run -all
