module AXI4 (
    // Global Signals
    input  logic         ACLK,
    input  logic         ARESET,

    // AXI Read Address Channel
    input  logic [4:0]   ARADDR,
    input  logic [1:0]   ARBURST,
    input  logic         ARVALID,
    output logic         ARREADY,
    input  logic [7:0]   ARLEN,
    input  logic [2:0]   ARSIZE,

    // AXI Read Data Channel
    output logic [31:0]   RDATA,
    output logic         RLAST,
    output logic         RVALID,
    input  logic         RREADY,
    output logic [1:0]   RRESP,

    // AXI Write Address Channel
    input  logic [4:0]   AWADDR,
    input  logic [1:0]   AWBURST,
    input  logic         AWVALID,
    output logic         AWREADY,
    input  logic [7:0]   AWLEN,
    input  logic [2:0]   AWSIZE,

    // AXI Write Data Channel
    input  logic [31:0]   WDATA,
    input  logic         WLAST,
    input  logic         WVALID,
    output logic         WREADY,

    // AXI Write Response Channel
    output logic [1:0]   BRESP,
    output logic         BVALID,
    input  logic         BREADY
);

	parameter memWidth = 8;
	parameter memDepth = 128;
	parameter addressLength = 5;	

	bit awtime,wtime,btime;
	bit artime,rtime;
	logic [4:0] waddr, raddr, wwr_l, wwr_h, rwr_l, rwr_h;
	logic [1:0] wburst, rburst;
	logic [7:0] wlen, rlen;
	logic [2:0]	wsize, rsize;
	reg [memWidth-1:0] BRAM [0:memDepth-1];		// BRAM used for storing the data.
	int total_bytes_w, total_bytes_r;
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
					wtime <= 1'b1;
					awtime <= 1'b0;
					total_bytes_w = (AWLEN + 1) * (1 << AWSIZE);
					wwr_l = AWADDR & ~(total_bytes_w - 1);     // Align down to wrap boundary
					wwr_h = wwr_l + total_bytes_w - 1;         // Upper bound is end of wrapped region
				end
			end
			else	AWREADY <= 1'b0;
			if (wtime) begin
				if (WVALID) begin
					WREADY <= 1'b1;
					if (wburst == 2'b01)	waddr <= waddr + (1 << wsize);
					else if (wburst == 2'b10) begin 
						if ((waddr + (1 << wsize)) <= wwr_h) 
							waddr <= waddr +  (1 << wsize);
						else	waddr <= wwr_l;	
						
					end
					case (wsize)
						3'b000: BRAM[waddr]     <= WDATA[7:0];                // 1 byte
						3'b001: begin                                         // 2 bytes
								BRAM[waddr]     <= WDATA[7:0];
								BRAM[waddr+1]   <= WDATA[15:8];
						end
						3'b010: begin                                         // 4 bytes
								BRAM[waddr]     <= WDATA[7:0];
								BRAM[waddr+1]   <= WDATA[15:8];
								BRAM[waddr+2]   <= WDATA[23:16];
								BRAM[waddr+3]   <= WDATA[31:24];
						end
						// Add more cases for larger sizes if needed
						default: ; // Do nothing or raise error
					endcase
				end
				if (WLAST) begin
					btime <= 1'b1;
					wtime <= 1'b0;
				end
					// $display("Time=%0t | wtime=%b awtime=%b WVALID=%b WREADY=%b WLAST=%b waddr=%h wburst=%b wlen=%d wsize=%b WDATA=%h BRAM[waddr]=%h", 
					// 	$time, wtime, awtime, WVALID, WREADY, WLAST, waddr, wburst, wlen, wsize, WDATA, BRAM[waddr]);
				
			end
			else	WREADY <= 1'b0; 

			if (btime) begin
				BVALID <= 1'b1;
				BRESP <= 2'd0;
				btime <= 1'b0;
				awtime <= 1'b1;
			end
			else begin
				BVALID <= 1'b0;
				BRESP <= 2'dz;
			end
		end
	end
	//READ LOGIC
	always @(posedge ACLK or negedge ARESET) begin
		if (!ARESET) begin
			ARREADY <= 1'b0;
			RDATA <= 8'bx;
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
					total_bytes_r = (ARLEN + 1) * (1 << ARSIZE);
					rwr_l = ARADDR & ~(total_bytes_r - 1);     // Align down to wrap boundary
					rwr_h = rwr_l + total_bytes_r - 1;         // Upper bound is end of wrapped region
				end
			end
			else ARREADY <= 1'b0;
			if (rtime) begin
						// 			$display("Time=%0t | rtime=%b artime=%b RREADY=%b RVALID=%b RLAST=%b raddr=%h rburst=%b rlen=%d rsize=%b RDATA=%h BRAM[raddr]=%h",
						// $time, rtime, artime, RREADY, RVALID, RLAST, raddr, rburst, rlen, rsize, RDATA, BRAM[raddr]);
				if (RREADY) begin
					RVALID <= 1'b1;
					if (rburst == 2'b01)	raddr <= raddr + (1 << rsize);
					else if (rburst == 2'b10) begin 
						if ((raddr + (1 << rsize)) <= rwr_h) 
							raddr <= raddr +  (1 << rsize);
						else	raddr <= rwr_l;	
					end
					rlen <= rlen - 1;
					case (rsize)
						3'b000: RDATA <= {24'b0, BRAM[raddr]}; // 1 byte
						3'b001: RDATA <= {16'b0, BRAM[raddr+1], BRAM[raddr]}; // 2 bytes
						3'b010: RDATA <= {BRAM[raddr+3], BRAM[raddr+2], BRAM[raddr+1], BRAM[raddr]}; // 4 bytes
						default: RDATA <= 32'dx ; // Undefined or unsupported size
					endcase

					if(!rlen) begin
						RLAST <= 1'b1;
						RRESP <= 2'b0;
						rtime = 1'b0;
						artime = 1'b1;
					end
				end
			end
			else begin
				RLAST <= 1'b0;
				RVALID <= 1'b0;
				RRESP <= 2'bz;
			end
		end
	end
endmodule