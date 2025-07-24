class all_burst_seq_test extends uvm_test;
	`uvm_component_utils(all_burst_seq_test)
	axi_env env;

	function new(string name = "all_burst_seq_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axi_env::type_id::create("env", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		fixed_burst fseq;
		incr_burst iseq;
		warp_burst wseq;

		fseq = fixed_burst::type_id::create("fseq");
		iseq = incr_burst::type_id::create("iseq");
		wseq = warp_burst::type_id::create("wseq");

		phase.raise_objection(this, "Running all_burst_seq_test");

		fseq.start(env.agt.sqr);
		iseq.start(env.agt.sqr);
		wseq.start(env.agt.sqr);

		phase.drop_objection(this, "Finished all_burst_seq_test");
	endtask
endclass
