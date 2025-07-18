class axi_sb extends uvm_scoreboard;
	`uvm_component_utils(axi_sb)

	// Analysis import declarations
	`uvm_analysis_imp_decl(_expected)
	`uvm_analysis_imp_decl(_actual)

	// Analysis implementation ports
	uvm_analysis_imp_expected#(tx_item, axi_sb) in_port;
	uvm_analysis_imp_actual#(tx_item, axi_sb)   out_port;
	
	// Variables 
	logic [7:0] expected_data [0:127];
	logic [7:0] actual_data [0:127];
	int match, mis_match;

	// Constructor: create imp ports and initialize stats
	function new(string name, uvm_component parent);
		super.new(name, parent);
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
		logic [4:0] addr = tr.AWADDR;
		int total_bytes = (tr.AWLEN + 1) * (1 << tr.AWSIZE);
		logic [4:0] wwr_l = tr.AWADDR & ~(total_bytes - 1);
		logic [4:0] wwr_h = wwr_l + total_bytes - 1;
		for (int i = 0; i <= tr.AWLEN; i++) begin
			case (tr.AWSIZE)
				3'b000: begin // 1 byte
					expected_data[addr] = tr.WDATA[i][7:0];
				end
				3'b001: begin // 2 bytes
					expected_data[addr]     = tr.WDATA[i][7:0];
					expected_data[addr + 1] = tr.WDATA[i][15:8];
				end
				3'b010: begin // 4 bytes
					expected_data[addr]     = tr.WDATA[i][7:0];
					expected_data[addr + 1] = tr.WDATA[i][15:8];
					expected_data[addr + 2] = tr.WDATA[i][23:16];
					expected_data[addr + 3] = tr.WDATA[i][31:24];
				end
				default: begin
					// handle error or unsupported size
				end
			endcase

			case (tr.AWBURST)
				2'b00: ; // FIXED: do nothing
				2'b01: addr = addr + (1 << tr.AWSIZE); // INCR
				2'b10: begin // WRAP
					if ((addr + (1 << tr.AWSIZE)) <= wwr_h)
						addr = addr + (1 << tr.AWSIZE);
					else
						addr = wwr_l;
				end
				default: `uvm_error("WRITE_EXPECTED", "Unsupported AWBURST")
			endcase
		end
	endfunction

	// Collect and compare actual transactions
	virtual function void write_actual(tx_item tr);
		logic [4:0] addr = tr.ARADDR;

		// Calculate total bytes and wrap bounds based on AR*
		int total_bytes = (tr.ARLEN + 1) * (1 << tr.ARSIZE);
		int wwr_l = tr.ARADDR & ~(total_bytes - 1);  // wrap lower bound
		int wwr_h = wwr_l + total_bytes - 1;         // wrap upper bound

		for (int i = 0; i <= tr.ARLEN; i++) begin
			logic [31:0] expected_word;

			// Build expected_word from expected_data[] based on ARSIZE
			case (tr.ARSIZE)
				3'b000: expected_word = {24'd0, expected_data[addr]};
				3'b001: expected_word = {16'd0, expected_data[addr + 1], expected_data[addr]};
				3'b010: expected_word = {expected_data[addr + 3], expected_data[addr + 2], expected_data[addr + 1], expected_data[addr]};
				default: expected_word = 32'hDEAD_BEEF; // Invalid ARSIZE
			endcase

			// Compare expected vs actual
			if (expected_word === tr.RDATA[i]) begin
				`uvm_info("MATCH", "MATCHED", UVM_MEDIUM)
				match++;
			end else begin
				`uvm_error("UNMATCH", $sformatf("Expected[%0h] = %h,\t Actual = %h", addr, expected_word, tr.RDATA[i]))
				mis_match++;
			end

			// Update address based on ARBURST
			case (tr.ARBURST)
				2'b00: ; // FIXED
				2'b01: addr = addr + (1 << tr.ARSIZE); // INCR
				2'b10: begin // WRAP
					if ((addr + (1 << tr.ARSIZE)) <= wwr_h)
						addr = addr + (1 << tr.ARSIZE);
					else
						addr = wwr_l;
				end
				default: `uvm_error("WRITE_ACTUAL", "Unsupported ARBURST")
			endcase
		end
	endfunction



	// Report final statistics
	virtual function void report_phase(uvm_phase phase);
		`uvm_info("AXI_SB_REPORT", $sformatf("Total Matches: %0d, Total Mismatches: %0d", match, mis_match), UVM_LOW)
	endfunction

endclass : axi_sb
