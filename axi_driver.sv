class axi_driver extends uvm_driver#(tx_item);
	`uvm_component_utils(axi_driver)

	virtual axi_if vif;

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
		vif.ARID <= tr.ARID;
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
		// vif.AWID <= tr.AWID;
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
			vif.WID <= tr.WID;
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
