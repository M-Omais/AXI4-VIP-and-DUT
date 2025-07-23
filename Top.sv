`timescale 1ps/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import tx_pkg::*;
module top;
	// Clock and Reset
	logic clk, rst_n;

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	int data_width = 32;
	// Instantiate interface
		axi_if axi_i(clk, rst_n);
		AXI4 #(.DATA_WIDTH(1024)) bram (.ACLK(clk),
								.ARESET(rst_n),
								.ARADDR(axi_i.ARADDR),
								.ARBURST(axi_i.ARBURST),
								.ARVALID(axi_i.ARVALID),
								.ARREADY(axi_i.ARREADY),
								.ARLEN(axi_i.ARLEN),
								.ARSIZE(axi_i.ARSIZE),
								.RDATA(axi_i.RDATA),
								.RLAST(axi_i.RLAST),
								.RVALID(axi_i.RVALID),
								.RREADY(axi_i.RREADY),
								.RRESP(axi_i.RRESP),
								.AWADDR(axi_i.AWADDR),
								.AWBURST(axi_i.AWBURST),
								.AWVALID(axi_i.AWVALID),
								.AWREADY(axi_i.AWREADY),
								.AWLEN(axi_i.AWLEN),
								.AWSIZE(axi_i.AWSIZE),
								.WDATA(axi_i.WDATA),
								.WLAST(axi_i.WLAST),
								.WVALID(axi_i.WVALID),
								.WREADY(axi_i.WREADY),
								.BRESP(axi_i.BRESP),
								.BVALID(axi_i.BVALID),
								.BREADY(axi_i.BREADY));

	// DUT instantiation using modport

	// Clock generation

	// Reset logic
	initial begin
		rst_n = 1;
		#3 rst_n = 0;
		#3 rst_n = 1;
	end


	initial begin
		// Pass virtual interface to UVM testbench
		uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top.env.agt.*", "vif", axi_i);
		// Run the test
		uvm_config_db#(int)            ::set(null, "", "recording_detail", 0);
		uvm_config_db#(uvm_bitstream_t)::set(null, "", "recording_detail", 0);
		run_test("i_write_5");
	end

endmodule