//------------------------------------------------------------------------------
// CLASS: axi_driver
//
// DESCRIPTION:
//   UVM driver for AXI4 protocol. Responsible for driving transactions onto the
//   AXI interface using the provided virtual interface. Handles both read and
//   write transfers based on the transaction type.
//
// PARAMETERS:
//   - tx_item: Transaction item type (extends uvm_sequence_item).
//
// MEMBERS:
//   - vif: Virtual interface handle for AXI signals.
//
// METHODS:
//   - new(string name, uvm_component parent)
//       Constructor. Retrieves the virtual interface from the UVM config database.
//       Fatal error if interface is not found.
//
//   - run_phase(uvm_phase phase)
//       Main driver loop. Waits for reset deassertion, then repeatedly gets
//       transactions from the sequencer and dispatches them to read or write
//       transfer tasks.
//
//   - read_transfer(tx_item tr)
//       Drives AXI read address and data handshake. Sets AR* signals, waits for
//       ARREADY, then drives RREADY for each beat.
//
//   - write_transfer(tx_item tr)
//       Drives AXI write address and data handshake. Sets AW* signals, waits for
//       AWREADY, then drives WDATA, WVALID, WLAST, and waits for WREADY for each
//       beat. Handles BREADY for write response.
//
// USAGE:
//   Instantiate in UVM environment, connect to sequencer and AXI virtual interface.
//
//------------------------------------------------------------------------------
class axi_driver extends uvm_driver#(tx_item);
	`uvm_component_utils(axi_driver)

	virtual axi_if  vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		if (!uvm_config_db #(virtual axi_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(),"UNABLE TO GET VIRTUAL INTERFACE")
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		tx_item tr;
		@(negedge vif.rst_n);		
		@(posedge vif.rst_n);		
		forever begin	
			tr = tx_item::type_id::create("tr");
			seq_item_port.get_next_item(tr);
			if (tr.transfer ==  READ)	read_transfer(tr);
			else 						write_transfer(tr);
			seq_item_port.item_done();
		end
	endtask

	virtual task read_transfer(tx_item tr);
		`uvm_info(get_type_name(),"READ TRANS",UVM_HIGH);
		@(negedge vif.clk);
		// Sending Address
		vif.ARADDR <= tr.ARADDR;
		vif.ARBURST <= tr.ARBURST;
		vif.ARSIZE <= tr.ARSIZE;
		vif.ARLEN <= tr.ARLEN;
		vif.ARVALID <= 1'b1;	//Setting valid high
		while (!vif.ARREADY) begin
			@(posedge vif.clk);
		end
		for (int i = 0; i <= tr.ARLEN; i++) begin
			@(negedge vif.clk);
			vif.ARVALID <= 0;
			vif.RREADY <= 1'b1;
		end
			@(negedge vif.clk);
			vif.RREADY <= 1'b0;
	endtask

	virtual task write_transfer(tx_item tr);
		// Sending Address
		`uvm_info(get_type_name(),"WRITE TRANS",UVM_HIGH);

		@(negedge vif.clk);
		@(negedge vif.clk);
		vif.AWADDR <= tr.AWADDR;
		vif.AWBURST <= tr.AWBURST;
		vif.AWSIZE <= tr.AWSIZE; //right now fixed to 1 byte later will change to dynamic
		vif.AWLEN <= tr.AWLEN;
		vif.AWVALID <= 1'b1;	//Setting valid high
		while(!vif.AWREADY)	@(vif.AWREADY);

		// Sending DATA

		for (int i = 0; i <= tr.AWLEN; i++) begin
			@(negedge vif.clk);
			vif.AWVALID <= 0;
			vif.WDATA <= tr.WDATA[i];
			vif.WLAST <= (i == tr.AWLEN);
			vif.WVALID <= 1'b1;
			while(!vif.WREADY)	@(vif.WREADY);
				// `uvm_info(get_type_name(), "Waiting for slave response in write", UVM_HIGH)
		end
		@(negedge vif.clk);
		vif.WVALID <= 1'b0;
		vif.BREADY <= 1'b1;
		vif.WLAST <= 1'b0;
		@(negedge vif.clk);
		vif.BREADY <= 1'b0;
	endtask

endclass
