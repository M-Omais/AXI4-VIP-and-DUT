interface axi_if#(
    parameter int DATA_WIDTH = 1024,
    parameter int ADDR_WIDTH = $clog2(32 * (DATA_WIDTH))
)	(input logic clk, input logic rst_n);

    // AXI Read Address Channel
      logic [ADDR_WIDTH-1:0] ARADDR;
      logic [1:0] ARBURST;
      logic                 ARVALID;
     logic                 ARREADY;
      logic [7:0] 			ARLEN;
      logic [2:0] ARSIZE;

    // AXI Read Data Channel
     logic [DATA_WIDTH-1:0] RDATA;
     logic                 RLAST;
     logic                 RVALID;
      logic                 RREADY;
     logic [1:0] 			RRESP;

    // AXI Write Address Channel
      logic [ADDR_WIDTH-1:0] AWADDR;
      logic [1:0] 			AWBURST;
      logic                 AWVALID;
     logic                 AWREADY;
      logic [7:0]  		AWLEN;
      logic [2:0] AWSIZE;

    // AXI Write Data Channel
      logic [DATA_WIDTH-1:0] WDATA;
      logic                 WLAST;
      logic                 WVALID;
     logic                 WREADY;

    // AXI Write Response Channel
     logic [1:0]			 BRESP;
     logic                 BVALID;
      logic                 BREADY;
endinterface
