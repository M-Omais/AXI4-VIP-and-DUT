interface axi_if(input logic clk, input logic rst_n);
	logic [3:0] ARID;
	logic [4:0] ARADDR;
	logic [1:0] ARBURST;
	bit			ARVALID;
	bit			ARREADY;
	logic [7:0] ARLEN;
	logic [2:0] ARSIZE;

	logic [3:0] RID;
	logic [31:0] RDATA;
	bit			RLAST;
	bit			RVALID;
	bit			RREADY;
	logic [1:0] RRESP;

	// logic [3:0] AWID;
	logic [4:0] AWADDR;
	logic [1:0] AWBURST;
	bit			AWVALID;
	bit			AWREADY;
	logic [7:0] AWLEN;
	logic [2:0] AWSIZE;

	logic [3:0] WID;
	logic [31:0] WDATA;
	bit			WLAST;
	bit			WVALID;
	bit			WREADY;

	logic [3:0] BID;
	logic [1:0] BRESP;
	bit			BVALID;
	bit			BREADY;
endinterface
