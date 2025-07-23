// class i_write_5_test extends uvm_test;
//     `uvm_component_utils(i_write_5_test)
//     axi_env env;

//     function new(string name = "i_write_5_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         i_write_5 seq;
//         phase.raise_objection(this, "Running i_write_5_test");
//         seq = i_write_5::type_id::create("seq");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished i_write_5_test");
//     endtask
// endclass

// class i_read_5_test extends uvm_test;
//     `uvm_component_utils(i_read_5_test)
//     axi_env env;

//     function new(string name = "i_read_5_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         i_read_5 seq;
//         phase.raise_objection(this, "Running i_read_5_test");
//         seq = i_read_5::type_id::create("seq");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished i_read_5_test");
//     endtask
// endclass

// class b_write_5_test extends uvm_test;
//     `uvm_component_utils(b_write_5_test)
//     axi_env env;

//     function new(string name = "b_write_5_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         b_write_5 seq;
//         phase.raise_objection(this, "Running b_write_5_test");
//         seq = b_write_5::type_id::create("seq");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished b_write_5_test");
//     endtask
// endclass

// class b_read_5_test extends uvm_test;
//     `uvm_component_utils(b_read_5_test)
//     axi_env env;

//     function new(string name = "b_read_5_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         b_read_5 seq;
//         phase.raise_objection(this, "Running b_read_5_test");
//         seq = b_read_5::type_id::create("seq");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished b_read_5_test");
//     endtask
// endclass

// class all_seq_test extends uvm_test;
//     `uvm_component_utils(all_seq_test)
//     axi_env env;

//     function new(string name = "all_seq_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         i_write_5 wseq = i_write_5::type_id::create("wseq");
//         i_read_5 rseq  = i_read_5::type_id::create("rseq");
//         b_write_5 bwseq = b_write_5::type_id::create("bwseq");
//         b_read_5 brseq  = b_read_5::type_id::create("brseq");

//         phase.raise_objection(this, "Running all_seq_test");

//         wseq.start(env.agt.sqr);
//         rseq.start(env.agt.sqr);
//         bwseq.start(env.agt.sqr);
//         brseq.start(env.agt.sqr);

//         phase.drop_objection(this, "Finished all_seq_test");
//     endtask
// endclass

// class read_after_write_i_test extends uvm_test;
//     `uvm_component_utils(read_after_write_i_test)
//     axi_env env;

//     function new(string name = "read_after_write_i_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         fixed_burst seq;
//         seq = fixed_burst::type_id::create("seq");
//         phase.raise_objection(this, "Running read_after_write_i_test");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished read_after_write_i_test");
//     endtask
// endclass
// class read_after_write_i_test extends uvm_test;
//     `uvm_component_utils(read_after_write_i_test)
//     axi_env env;

//     function new(string name = "read_after_write_i_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         incr_burst seq;
//         seq = incr_burst::type_id::create("seq");
//         phase.raise_objection(this, "Running read_after_write_i_test");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished read_after_write_i_test");
//     endtask
// endclass
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

class fixed_burst_test extends uvm_test;
	`uvm_component_utils(fixed_burst_test)
	axi_env env;

	function new(string name = "fixed_burst_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axi_env::type_id::create("env", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		fixed_burst seq;
		seq = fixed_burst::type_id::create("seq");
		phase.raise_objection(this, "Running fixed_burst_test");
		seq.start(env.agt.sqr);
		phase.drop_objection(this, "Finished fixed_burst_test");
	endtask
endclass

class incr_burst_test extends uvm_test;
	`uvm_component_utils(incr_burst_test)
	axi_env env;

	function new(string name = "incr_burst_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axi_env::type_id::create("env", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		incr_burst seq;
		seq = incr_burst::type_id::create("seq");
		phase.raise_objection(this, "Running incr_burst_test");
		seq.start(env.agt.sqr);
		phase.drop_objection(this, "Finished incr_burst_test");
	endtask
endclass

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

// class read_after_write_b_test extends uvm_test;
//     `uvm_component_utils(read_after_write_b_test)
//     axi_env env;

//     function new(string name = "read_after_write_b_test", uvm_component parent = null);
//         super.new(name, parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         env = axi_env::type_id::create("env", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         read_after_write_b seq;
//         seq = read_after_write_b::type_id::create("seq");
//         phase.raise_objection(this, "Running read_after_write_b_test");
//         seq.start(env.agt.sqr);
//         phase.drop_objection(this, "Finished read_after_write_b_test");
//     endtask
// endclass

// class i_write_5_s_test extends uvm_test;
// 	`uvm_component_utils(i_write_5_s_test)
// 	axi_env env;

// 	function new(string name = "i_write_5_s_test", uvm_component parent = null);
// 		super.new(name, parent);
// 	endfunction

// 	virtual function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
// 		env = axi_env::type_id::create("env", this);
// 	endfunction

// 	virtual task run_phase(uvm_phase phase);
// 		i_write_5_s seq;
// 		phase.raise_objection(this, "Running i_write_5_s_test");
// 		seq = i_write_5_s::type_id::create("seq");
// 		seq.start(env.agt.sqr);
// 		phase.drop_objection(this, "Finished i_write_5_s_test");
// 	endtask
// endclass

// class i_read_5_s_test extends uvm_test;
// 	`uvm_component_utils(i_read_5_s_test)

// 	axi_env env;

// 	function new(string name = "i_read_5_s_test", uvm_component parent = null);
// 		super.new(name, parent);
// 	endfunction

// 	virtual function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
// 		env = axi_env::type_id::create("env", this);
// 	endfunction

// 	virtual task run_phase(uvm_phase phase);
// 		i_read_5_s seq;
// 		phase.raise_objection(this, "Running i_read_5_s_test");
// 		seq = i_read_5_s::type_id::create("seq");
// 		seq.start(env.agt.sqr);
// 		phase.drop_objection(this, "Finished i_read_5_s_test");
// 	endtask
// endclass

// class parallel_test extends uvm_test;
// 	`uvm_component_utils(parallel_test)

// 	axi_env env;

// 	function new(string name = "parallel_test", uvm_component parent = null);
// 		super.new(name, parent);
// 	endfunction

// 	virtual function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
// 		env = axi_env::type_id::create("env", this);
// 	endfunction

// 	virtual task run_phase(uvm_phase phase);
// 		parallel seq;
// 		phase.raise_objection(this, "Running parallel_test");
// 		seq = parallel::type_id::create("seq");
// 		seq.start(env.agt.sqr);
// 		phase.drop_objection(this, "Finished parallel_test");
// 	endtask
// endclass



