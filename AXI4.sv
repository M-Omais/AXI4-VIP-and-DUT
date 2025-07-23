module AXI4 #(
	parameter int DATA_WIDTH = 1024,
	parameter int ADDR_WIDTH = $clog2(32 * (DATA_WIDTH))
)(
	// Global Signals
	input  logic                 ACLK,
	input  logic                 ARESET,

	// AXI Read Address Channel
	input  logic [ADDR_WIDTH-1:0] ARADDR,
	input  logic [1:0]            ARBURST,
	input  logic                  ARVALID,
	output logic                  ARREADY,
	input  logic [7:0]            ARLEN,
	input  logic [2:0]            ARSIZE,

	// AXI Read Data Channel
	output logic [DATA_WIDTH-1:0] RDATA,
	output logic                  RLAST,
	output logic                  RVALID,
	input  logic                  RREADY,
	output logic [1:0]            RRESP,

	// AXI Write Address Channel
	input  logic [ADDR_WIDTH-1:0] AWADDR,
	input  logic [1:0]            AWBURST,
	input  logic                  AWVALID,
	output logic                  AWREADY,
	input  logic [7:0]            AWLEN,
	input  logic [2:0]            AWSIZE,

	// AXI Write Data Channel
	input  logic [DATA_WIDTH-1:0] WDATA,
	input  logic                  WLAST,
	input  logic                  WVALID,
	output logic                  WREADY,

	// AXI Write Response Channel
	output logic [1:0]            BRESP,
	output logic                  BVALID,
	input  logic                  BREADY
);

	parameter memWidth = 8;
	parameter memDepth = (1 << ADDR_WIDTH);

	bit awtime, wtime, btime;
	bit artime, rtime;
	logic [ADDR_WIDTH-1:0] waddr, raddr, wwr_l, wwr_h, rwr_l, rwr_h;
	logic [1:0] wburst, rburst, wresp, rresp;
	logic [7:0] wlen, rlen;
	logic [2:0] wsize, rsize;
	reg [memWidth-1:0] BRAM [0:memDepth-1];
	int total_bytes_w, total_bytes_r, wbpt, woffset, rbpt, roffset;
	int aligned_mem = DATA_WIDTH / 8;

	// WRITE LOGIC
	always @(posedge ACLK or negedge ARESET) begin
		if (!ARESET) begin
			AWREADY <= 1'b1;
			WREADY <= 1'b0;
			BRESP <= 2'bz;
			BVALID <= 1'b0;
			awtime <= 1'b1;
			wtime <= 1'b0;
			btime <= 1'b0;
		end
		else begin
			if (awtime) begin
				AWREADY <= 1'b1;
				if (AWVALID) begin
					waddr <= AWADDR;
					wburst <= AWBURST;
					wlen <= AWLEN;
					wsize <= AWSIZE;
					awtime <= 1'b0;
					wtime <= 1'b1;
					wbpt = (1 << AWSIZE);
					total_bytes_w = (AWLEN + 1) * wbpt;
					wwr_l = AWADDR & ~(total_bytes_w - 1);
					woffset = AWADDR & (wbpt - 1);
					wwr_h = wwr_l + total_bytes_w - 1;
					wresp <= 2'b0;
				end
			end
			else AWREADY <= 1'b0;

			if (wtime) begin
				if (WVALID) begin
					WREADY <= 1'b1;
					wresp <= 2'b0;
					if ((waddr + ((wlen + 1) << wsize) - 1) >= memDepth)	wresp <= 2'b1;
					case (wburst)
						2'b00: begin
							if (wlen > 16) wresp <= 2'b1;
						end
						2'b01: begin
							if(waddr % wbpt) begin
								waddr <= (waddr & ~(aligned_mem - 1)) + aligned_mem;
								woffset <= 0;
							end
							else waddr <= waddr + wbpt;
						end
						2'b10: begin
							if (!(wlen == 2 || wlen == 4 || wlen == 8 || wlen == 16)) wresp <= 1'b1;
							if(waddr % wbpt) begin
								waddr <= (waddr & ~(aligned_mem - 1)) + aligned_mem;
								woffset <= 0;
								wresp <= 2'b1;
							end
							else if ((waddr + wbpt) <= wwr_h)	waddr <= waddr + wbpt;
							else waddr <= wwr_l;
						end
						default: wresp <= 2'b1;
					endcase
					if(wresp) $display("sdkljf");
					if(!wresp && (waddr + wbpt < memDepth) )begin
						for (int i = 0; i < aligned_mem - woffset; i++) begin
							if(i == wbpt) break;
							BRAM[waddr + i] <= WDATA[(8 * i) +: 8];
						end
						
					end
				end
				if (WLAST) begin
					btime <= 1'b1;
					wtime <= 1'b0;
				end
			end
			else WREADY <= 1'b0;

			if (btime) begin
				BVALID <= 1'b1;
				BRESP <= wresp;
				btime <= 1'b0;
				awtime <= 1'b1;
			end
			else begin
				BVALID <= 1'b0;
				BRESP <= 2'dz;
			end
		end
	end

	// READ LOGIC
	always @(posedge ACLK or negedge ARESET) begin
		if (!ARESET) begin
			ARREADY <= 1'b0;
			RDATA <= 'b0;
			RLAST <= 1'b0;
			RVALID <= 1'b0;
			RRESP <= 2'bz;
			artime <= 1'b1;
			rtime <= 1'b1;
		end
		else begin
			if (artime) begin
				ARREADY <= 1'b1;
				if (ARVALID) begin
					raddr <= ARADDR;
					rburst <= ARBURST;
					rlen <= ARLEN;
					rsize <= ARSIZE;
					artime <= 1'b0;
					rtime <= 1'b1;
					rbpt = (1 << ARSIZE);
					total_bytes_r = (ARLEN + 1) * rbpt;
					rwr_l = ARADDR & ~(total_bytes_r - 1);
					rwr_h = rwr_l + total_bytes_r - 1;
					roffset = ARADDR & (rbpt - 1);
					rresp <= 2'b0;
					if (ARBURST == 2'b10 && !(ARLEN == 2 || ARLEN == 4 || ARLEN == 8 || ARLEN == 16))	rresp <= 2'b1;
				end
			end
			else ARREADY <= 1'b0;

			if (rtime) begin
				if (RREADY) begin
					RVALID <= 1'b1;
					if ((raddr + ((rlen + 1) << rsize) - 1) >= memDepth)	rresp <= 2'b1;
					case (rburst)
						2'b00: begin  // FIXED
							if (rlen > 16) rresp <= 2'b1;
						end
						2'b01: begin  // INCR
							if (raddr % rbpt) begin
								raddr <= (raddr & ~(aligned_mem - 1)) + aligned_mem;
								roffset <= 0;
							end
							else raddr <= raddr + rbpt;
						end
						2'b10: begin  // WRAP
							if (raddr % rbpt) begin
								raddr <= (raddr & ~(aligned_mem - 1)) + aligned_mem;
								roffset <= 0;
								rresp <= 2'b1;
							end
							else if ((raddr + rbpt) <= rwr_h)	raddr <= raddr + rbpt;
							else raddr <= rwr_l;
						end
						default: rresp <= 2'b1;
					endcase
					rlen <= rlen - 1;
					RDATA = 'b0;
					if(rresp) $display("sldkfjsldkfj");
					// if (!rresp && (raddr + rbpt < memDepth)) begin
						
					for (int i = 0; i < aligned_mem; i++) begin
						if (i < rbpt) begin
							if (i < aligned_mem - roffset)
								RDATA[(8 * i) +: 8] <= BRAM[raddr + i];
							else RDATA[(8 * i) +: 8] <= 8'bx;
						end
					end
					// end
					if (rlen == 1)	RRESP <= rresp;

					if(!rlen) begin
						RLAST <= 1'b1;
						rtime <= 1'b0;
						artime <= 1'b1;
					end
				end
			end
			else begin
				RLAST <= 1'b0;
				RVALID <= 1'b0;
				RRESP <= 2'b1;
			end
		end
	end
endmodule
