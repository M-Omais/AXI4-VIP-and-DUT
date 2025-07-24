class warp_burst_test extends uvm_test;
	`uvm_component_utils(warp_burst_test)
	axi_env env;

	function new(string name = "warp_burst_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axi_env::type_id::create("env", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		warp_burst seq;
		seq = warp_burst::type_id::create("seq");
		phase.raise_objection(this, "Running warp_burst_test");
		seq.start(env.agt.sqr);
		phase.drop_objection(this, "Finished warp_burst_test");
	endtask
endclass
