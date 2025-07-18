sim:/top/axi_i/AW* \
sim:/top/axi_i/W* \
sim:/top/axi_i/B* \
sim:/top/axi_i/AR* \
sim:/top/axi_i/R* \

# Add wave signals
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
