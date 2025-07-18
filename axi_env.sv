class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)

	axi_agent      agt;
	axi_sb sb;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt = axi_agent::type_id::create("agt", this);
		sb = axi_sb::type_id::create("sb", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// Connect both monitor ports to sb
		agt.mon.dut_write.connect(sb.in_port);
		agt.mon.dut_read.connect(sb.out_port);
	endfunction

endclass : axi_env