package test_pkg;
    import uvm_pkg::*;

    `include "uvm_macros.svh"
	import tx_pkg::*;
	import seq_pkg::*;

    `include "all_burst_seq_test.sv"
    `include "fixed_burst_test.sv"
    `include "incr_burst_test.sv"
    `include "warp_burst_test.sv"
    `include "random_parallel_test.sv"
endpackage