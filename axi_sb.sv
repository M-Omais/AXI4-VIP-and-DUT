//------------------------------------------------------------------------------
// CLASS: axi_sb
//
// DESCRIPTION:
//   UVM Scoreboard for AXI4 protocol verification. This class collects expected
//   and actual transaction items, compares them, and reports match/mismatch
//   statistics. It supports burst types (FIXED, INCR, WRAP) and handles
//   alignment, burst length, and address calculations for both write and read
//   operations.
//
// PARAMETERS:
//   - data_width:   Data bus width in bits (default: 1024).
//   - addr_width:   Address bus width, calculated as $clog2(1024 * data_width).
//   - aligned_mem:  Number of bytes per aligned memory word.
//   - memDepth:     Depth of the scoreboard memory.
//
// MEMBERS:
//   - expected_data: Array storing expected data bytes.
//   - actual_data:   Array storing actual data bytes.
//   - match:         Counter for matched transactions.
//   - mis_match:     Counter for mismatched transactions.
//   - in_port:       Analysis implementation port for expected transactions.
//   - out_port:      Analysis implementation port for actual transactions.
//
// METHODS:
//   - new():         Constructor. Initializes counters and analysis ports.
//   - build_phase(): UVM build phase. Instantiates analysis ports and resets counters.
//   - write_expected(tx_item): Collects expected write transactions and updates expected_data.
//   - write_actual(tx_item):   Collects actual read transactions, compares with expected_data,
//                              and updates match/mis_match counters.
//   - report_phase(): Reports final match/mismatch statistics and error percentage.
//
// USAGE:
//   Instantiate in UVM environment, connect analysis ports to monitor/agent outputs,
//   and use for AXI4 protocol data integrity checking.
//
//------------------------------------------------------------------------------
class axi_sb extends uvm_scoreboard;
	`uvm_component_utils(axi_sb)

	// Analysis import declarations
	`uvm_analysis_imp_decl(_expected)
	`uvm_analysis_imp_decl(_actual)

	// Analysis implementation ports
	uvm_analysis_imp_expected#(tx_item, axi_sb) in_port;
	uvm_analysis_imp_actual#(tx_item, axi_sb)   out_port;
	localparam int data_width = 1024;
	localparam int addr_width = $clog2(1024 * data_width);
	localparam int aligned_mem = data_width / 8;
	localparam int memDepth = 1 << addr_width;
	// Variables 
	reg [7:0] expected_data [0 : (1 << addr_width)];
	reg [7:0] actual_data [0 : (1 << addr_width)];
	int match, mis_match;

	// Constructor: create imp ports and initialize stats
	function new(string name, uvm_component parent);
		super.new(name, parent);
		match = 0;
		mis_match = 0;
	endfunction

	// Build phase: nothing additional needed
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		in_port  = new("in_port", this);
		out_port = new("out_port", this);
		match = 0;
		mis_match = 0;
	endfunction

	// Collect expected transactions
	virtual function void write_expected(tx_item tr);
		logic [addr_width-1:0] addr = tr.AWADDR;
		logic [7:0] len = tr.AWLEN;
		int wbpt = (1 << tr.AWSIZE);
		int total_bytes = (len + 1) * wbpt;
		logic [addr_width-1:0] wwr_l = addr & ~(total_bytes - 1);
		int offset = addr & (wbpt - 1);
		logic [addr_width-1:0] wwr_h = wwr_l + total_bytes - 1;
		bit resp = 0;
		// `uvm_info("WRITE_EXPECTED", $sformatf("wbpt = %0d, offset = %0d", wbpt, offset), UVM_LOW)
		for (int i = 0; i <= len; i++) begin
			if (resp) begin
				`uvm_error("ERROR DETECTED", "LEAVING WRITE")
				break;
			end
			if (addr + wbpt > memDepth) begin
				`uvm_error("BONDAGE", "LEAVING WRITE")
				break;
			end
			for (int j = 0; j < aligned_mem - offset; j++) begin
				if (j < wbpt) begin
					expected_data[addr + j] = tr.WDATA[i][(8*j) +: 8];
				end

			end
			// if ((addr + ((len + 1) << tr.AWSIZE) - 1) >= memDepth) begin
			// 	`uvm_warning("WRITE_EXPECTED", "Write out of bounds")
			// 	resp = 1;
			// end
			case (tr.AWBURST)
				2'b00: begin // FIXED
					if (len > 15) begin
						// `uvm_warning("WRITE_EXPECTED", "AWLEN > 16 not supported")
						len = 15;
					end
				end

				2'b01: begin // INCR
					if (addr % wbpt) begin
						addr = (addr & ~(aligned_mem - 1)) + aligned_mem;
						offset = 0;
					end
					else	addr = addr + wbpt;
				end

				2'b10: begin // WRAP
					if (!(len == 2 || len == 4 || len == 8 || len == 16)) begin
						`uvm_warning("WRITE_EXPECTED", "Unsupported AWLEN for WRAP")
						resp = 1;
					end
					if (addr % wbpt) begin
						addr = (addr & ~(aligned_mem - 1)) + aligned_mem;
						offset = 0;
						`uvm_warning("WRITE_EXPECTED", "Misaligned address in WRAP burst")
						resp = 1;
					end
					else if ((addr + wbpt) <= wwr_h) begin
						addr = addr + wbpt;
					end else begin

						addr = wwr_l;
					end
				end

				default: begin
					`uvm_warning("WRITE_EXPECTED", "Unsupported AWBURST")
					resp = 1;
				end
			endcase

			

			// offset = 0;
		end
	endfunction

	// Collect and compare actual transactions
	virtual function void write_actual(tx_item tr);
		logic [addr_width-1:0] addr = tr.ARADDR;
		int wbpt = (1 << tr.ARSIZE);
		logic [7:0] len = tr.ARLEN;
		int total_bytes = (len + 1) * wbpt;
		int wwr_l = tr.ARADDR & ~(total_bytes - 1);
		int wwr_h = wwr_l + total_bytes - 1;
		int offset = addr & (wbpt - 1);
		bit resp =0;
		for (int i = 0; i <= len; i++) begin
			logic [data_width-1:0] expected_word = '0;
			if(resp || addr + wbpt > memDepth) begin
				`uvm_error("ERROR DETECTED","LEAVING READ")
				break;
			end
			for (int j = 0; j < aligned_mem; j++) begin
				if(j < wbpt) begin
					if (j < aligned_mem - offset)	expected_word[(8 * j) +: 8] = expected_data[addr + j];
					else expected_word[(8 * j) +: 8] = 8'bx;
				end
				// `uvm_info("J_VALUE", $sformatf("j = %0d, offset = %0d", j, offset), UVM_LOW)
			end

			if (expected_word === tr.RDATA[i]) begin
				`uvm_info("MATCH", "MATCHED", UVM_MEDIUM)
				// `uvm_info("MATCH", $sformatf("Expected[%0h] = %h,\t Actual = %h,\t Size = %0d", addr, expected_word, tr.RDATA[i], wbpt), UVM_LOW)

				match++;
			end else begin
				`uvm_error("UNMATCH", $sformatf(
					"Mismatch at burst index i = %0d\n\tAddress: 0x%0h\n\tExpected Data: 0x%0h\n\tActual Data: 0x%0h\n\tWord Size (bytes): %0d\n\tARADDR: 0x%0h ARLEN: %0d ARSIZE: %0d ARBURST: 0x%0h",
					i, addr, expected_word, tr.RDATA[i], wbpt, tr.ARADDR, tr.ARLEN, tr.ARSIZE, tr.ARBURST
				))
				mis_match++;
				// `uvm_info("WRITE_EXPECTED", $sformatf("WRAP burst: addr=%0d, wbpt=%0d, wwr_h=%0d, updating addr to %0d", addr, wbpt, wwr_h, addr + wbpt), UVM_LOW)
			end

			case (tr.ARBURST)

				2'b00: begin // FIXED
					// No address update for FIXED burst
					if (len > 15) begin
						// `uvm_warning("WRITE_ACTUAL", "ARLEN > 16 not supported")
						len =15;
					end
				end

				2'b01: begin // INCR
					if (addr % wbpt) begin
						addr = (addr & ~(aligned_mem - 1)) + aligned_mem;
						offset = 0;
					end
					else addr = addr + wbpt;
				end

				2'b10: begin // WRAP
					if (!(len == 2 || len == 4 || len == 8 || len == 16)) begin
						`uvm_warning("WRITE_ACTUAL", "Unsupported ARLEN for WRAP")
						resp = 1;
					end
					if (addr % wbpt) begin
						addr = (addr & ~(aligned_mem - 1)) + aligned_mem;
						offset = 0;
						`uvm_warning("WRITE_ACTUAL", "Misaligned address in WRAP burst")
						resp = 1;
					end else if ((addr + wbpt) <= wwr_h) begin
						addr = addr + wbpt;
					end else begin
						addr = wwr_l;
					end
				end

				default: begin
					`uvm_warning("WRITE_ACTUAL", "Unsupported ARBURST")
					resp = 1;
				end
			endcase
		end
	endfunction




	// Report final statistics
	virtual function void report_phase(uvm_phase phase);
		real error_pct = (match + mis_match) ? (100.0 * mis_match / (match + mis_match)) : 0.0;
		`uvm_info("AXI_SB_REPORT", $sformatf("Total Matches: %0d, Total Mismatches: %0d, Error Percentage: %.2f%%", match, mis_match, error_pct), UVM_LOW)
	endfunction

endclass : axi_sb
