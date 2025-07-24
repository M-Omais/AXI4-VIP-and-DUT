class random_parallel_test extends uvm_test;
    `uvm_component_utils(random_parallel_test)
    axi_env env;

    function new(string name = "random_parallel_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        full_random_parallel seq;
        seq = full_random_parallel::type_id::create("seq");
        phase.raise_objection(this, "Running random_parallel_test");
        seq.start(env.agt.sqr);
        phase.drop_objection(this, "Finished random_parallel_test");
    endtask
endclass