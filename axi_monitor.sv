class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)
	
    function new(string name , uvm_component parent);
        super.new(name,parent);
    endfunction //new()

    virtual axi_if vif;

    uvm_analysis_port #(tx_item) dut_write;   
    uvm_analysis_port #(tx_item) dut_read;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dut_write = new("dut_write",this);
        dut_read = new("dut_read",this);
		if (!uvm_config_db #(virtual axi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),"UNABLE TO GET VIRTUAL INTERFACE")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        fork
            write_transfer();
            read_transfer();
        join
    endtask //   
    
	virtual task write_transfer();
		forever begin
			tx_item tr = tx_item::type_id::create("tr");
			//CHECKING IF WADDR IS TRANSFERRING
			while ((vif.AWVALID !== 1'b1) || (vif.AWREADY !== 1'b1))
				@(negedge vif.clk);

				`uvm_info(get_type_name(),"ADDRESS IS BEING TRANSFERED",UVM_HIGH)	
			tr.AWADDR = vif.AWADDR;
			tr.AWBURST = vif.AWBURST;
			tr.AWSIZE = vif.AWSIZE; //right now fixed to 1 byte later will change to dynamic
			tr.AWLEN = vif.AWLEN;
			tr.WDATA = new[tr.AWLEN + 1];
			`uvm_info(get_type_name(), $sformatf("AWADDR=%0d, AWBURST=%0d, AWSIZE=%0d, AWLEN=%0d", tr.AWADDR, tr.AWBURST, tr.AWSIZE, tr.AWLEN), UVM_MEDIUM)
			
			for (int i = 0; i <= tr.AWLEN; i++) begin
				// CHECKING FOR DATA TRANSFER
				@(negedge vif.clk)
				while(!vif.WVALID || !vif.WREADY)
					@(negedge vif.clk);
				`uvm_info(get_type_name(),"DATA IS BEING TRANSFERED",UVM_HIGH)	
				tr.WDATA[i] = vif.WDATA;
				tr.WLAST = vif.WLAST;
				
			end
			// CHECKING FOR WRESPONSE
			@(posedge vif.clk)
			@(vif.BVALID && vif.BREADY);
			tr.BRESP = vif.BRESP;
			// `uvm_info(get_type_name(), $sformatf("BID=%0d, BRESP=%0d", tr.BID, tr.BRESP), UVM_MEDIUM)
			dut_write.write(tr);
		end
	endtask

	virtual task read_transfer();
		forever begin
			tx_item tr = tx_item::type_id::create("tr");
			//CHECKING IF RADDR IS TRANSFERRING
			while ((vif.ARVALID !== 1'b1) || (vif.ARREADY !== 1'b1))
				@(negedge vif.clk);
			`uvm_info(get_type_name(),"R_ADDRESS IS BEING TRANSFERED",UVM_MEDIUM)
			tr.ARADDR = vif.ARADDR;
			tr.ARBURST = vif.ARBURST;
			tr.ARSIZE = vif.ARSIZE; //right now fixed to 1 byte later will change to dynamic
			tr.ARLEN = vif.ARLEN;
			`uvm_info(get_type_name(), $sformatf("ARADDR=%0d, ARBURST=%0d, ARSIZE=%0d, ARLEN=%0d", tr.ARADDR, tr.ARBURST, tr.ARSIZE, tr.ARLEN), UVM_MEDIUM)
			tr.RDATA = new[tr.ARLEN + 1];
			for (int i = 0; i <= tr.ARLEN; i++) begin
				// CHECKING FOR DATA TRANSFER
				@(negedge vif.clk)
				while(!vif.RVALID || !vif.RREADY)
					@(negedge vif.clk);
				tr.RDATA[i] = vif.RDATA;
				tr.RLAST = vif.RLAST;
				tr.RRESP = vif.RRESP;
			end
			dut_read.write(tr);
		end
	endtask
endclass //axi_monitor extends uvm_monitor