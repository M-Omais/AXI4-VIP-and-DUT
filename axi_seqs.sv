class write_seq extends uvm_sequence#(tx_item);
	`uvm_object_utils(write_seq)
	rand int rp;
	rand logic [14:0] addr;
	rand logic [1:0] burst;
	rand logic [7:0] len;
	rand logic [2:0] size;
	function new(string name = "write_seq");
		super.new(name);
	endfunction
	
	constraint write_data_size_c {
    	burst != 2'b11;
  	}
	virtual task body();
		tx_item tr;
		repeat(rp)begin
			tr = tx_item::type_id::create("tr");
			`uvm_do_with(tr, {AWADDR == addr; AWBURST == burst; AWLEN == len; AWSIZE == size; transfer == WRITE;});
		end
	endtask
endclass

class read_seq extends uvm_sequence#(tx_item);
	`uvm_object_utils(read_seq)
	rand int rp;
	rand logic [14:0] addr;
	rand logic [1:0] burst;
	rand logic [7:0] len;
	rand logic [2:0] size;
	function new(string name = "read_seq");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		repeat(rp)begin
			tr = tx_item::type_id::create("tr");
			`uvm_do_with(tr, {ARADDR == addr; ARBURST == burst; ARLEN == len; ARSIZE == size; transfer == READ;});
		end
		// for (int i = 0; i<16; i++) begin
		// end
	endtask
endclass

class fixed_burst extends uvm_sequence#(tx_item);
	`uvm_object_utils(fixed_burst)
	read_seq rd;
	write_seq wr;
	int rpt = 5;
	function new(string name = "fixed_burst");
		super.new(name);
		rd = read_seq::type_id::create("rd");
		wr = write_seq::type_id::create("wr");

	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		for (int i = 0; i < 8; i++) begin
			`uvm_do_with(wr, {addr < 5; rp == rpt; burst == 2'b00; len < 5; size == i;});
			`uvm_do_with(rd, {addr < 5; rp == rpt; burst == 2'b00; len < 5; size == i;});
		end
	endtask
endclass

class incr_burst extends uvm_sequence#(tx_item);
	`uvm_object_utils(incr_burst)
	read_seq rd;
	write_seq wr;
	int rpt = 5;
	function new(string name = "incr_burst");
		super.new(name);
	endfunction

	virtual task body();
		for (int i = 0; i < 8; i++) begin
			wr = write_seq::type_id::create("wr");
			`uvm_do_with(wr, {addr < 5; rp == rpt; burst == 2'b01; len < 5; size == i;});
			rd = read_seq::type_id::create("rd");
			`uvm_do_with(rd, {addr < 5; rp == rpt; burst == 2'b01; len < 5; size == i;});
		end
	endtask
endclass
class warp_burst extends uvm_sequence#(tx_item);
	`uvm_object_utils(warp_burst)
	read_seq rd;
	write_seq wr;
	int rpt = 5;
	function new(string name = "warp_burst");
		super.new(name);
	endfunction

	virtual task body();
		for (int i = 0; i < 8; i++) begin
			wr = write_seq::type_id::create("wr");
			`uvm_do_with(wr, {addr == 0; rp == rpt; burst == 2'b00; len == 4; size == 3;});
			rd = read_seq::type_id::create("rd");
			`uvm_do_with(rd, {addr == 0; rp == rpt; burst == 2'b00; len == 4; size == 3;});
		end
	endtask
endclass

// class b_write_5 extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(b_write_5)

// 	function new(string name = "b_write_5");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		repeat(2)
// 			`uvm_do_with(tr, {AWADDR < 2; AWBURST == 2; AWLEN == 5; AWSIZE == 1; transfer == WRITE;});
// 	endtask
// endclass

// class b_read_5 extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(b_read_5)

// 	function new(string name = "b_read_5");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		repeat(20)
// 			`uvm_do_with(tr, {ARADDR < 20; ARBURST == 2; ARLEN == 5; ARSIZE == 1; transfer == READ;});
// 	endtask
// endclass

// class read_after_write_b extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(read_after_write_b)
// 	b_read_5 rd;
// 	b_write_5 wr;
// 	function new(string name = "read_after_write_b");
// 		super.new(name);
// 		rd = b_read_5::type_id::create("rd");
// 		wr = b_write_5::type_id::create("wr");

// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		`uvm_do(wr);
// 		`uvm_do(rd);
// 	endtask
// endclass

// class i_write_5_s extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(i_write_5_s)

// 	function new(string name = "i_write_5_s");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		repeat(5)
// 			`uvm_do_with(tr, {AWADDR < 5; AWBURST == 0; AWLEN == 0; AWSIZE == 1; transfer == WRITE;});
// 	endtask
// endclass

// class i_read_5_s extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(i_read_5_s)

// 	function new(string name = "i_read_5_s");
// 		super.new(name);
// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		repeat(5)
// 			`uvm_do_with(tr, {AWADDR < 5; AWBURST == 0; AWLEN == 0; AWSIZE == 2; transfer == WRITE;});
// 		repeat(5)
// 			`uvm_do_with(tr, {ARADDR < 5; ARBURST == 0; ARLEN == 0; ARSIZE == 2; transfer == READ;});
// 	endtask
// endclass

// class parallel extends uvm_sequence#(tx_item);
// 	`uvm_object_utils(parallel)
// 	b_read_5 rd;
// 	b_write_5 wr;
// 	function new(string name = "parallel");
// 		super.new(name);
// 		rd = b_read_5::type_id::create("rd");
// 		wr = b_write_5::type_id::create("wr");

// 	endfunction

// 	virtual task body();
// 		tx_item tr;
// 		tr = tx_item::type_id::create("tr");
// 		`uvm_do(wr);
// 		fork
// 		`uvm_do(rd);
// 		`uvm_do(wr);
// 		`uvm_do(rd);
// 		join
// 	endtask
// endclass
