class i_write_5 extends uvm_sequence#(tx_item);
	`uvm_object_utils(i_write_5)

	function new(string name = "i_write_5");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(5)
			`uvm_do_with(tr, {AWADDR < 5; AWBURST == 0; AWLEN == 0; AWSIZE == 0; transfer == WRITE;});
	endtask
endclass

class i_read_5 extends uvm_sequence#(tx_item);
	`uvm_object_utils(i_read_5)

	function new(string name = "i_read_5");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(5)
			`uvm_do_with(tr, {ARADDR < 5; ARBURST == 0; ARLEN == 0; ARSIZE == 0; transfer == READ;});
	endtask
endclass

class read_after_write_i extends uvm_sequence#(tx_item);
	`uvm_object_utils(read_after_write_i)
	i_read_5 rd;
	i_write_5 wr;
	function new(string name = "read_after_write_i");
		super.new(name);
		rd = i_read_5::type_id::create("rd");
		wr = i_write_5::type_id::create("wr");

	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		`uvm_do(wr);
		`uvm_do(rd);
	endtask
endclass

class b_write_5 extends uvm_sequence#(tx_item);
	`uvm_object_utils(b_write_5)

	function new(string name = "b_write_5");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(2)
			`uvm_do_with(tr, {AWADDR < 2; AWBURST == 2; AWLEN == 5; AWSIZE == 1; transfer == WRITE;});
	endtask
endclass

class b_read_5 extends uvm_sequence#(tx_item);
	`uvm_object_utils(b_read_5)

	function new(string name = "b_read_5");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(20)
			`uvm_do_with(tr, {ARADDR < 20; ARBURST == 2; ARLEN == 5; ARSIZE == 1; transfer == READ;});
	endtask
endclass

class read_after_write_b extends uvm_sequence#(tx_item);
	`uvm_object_utils(read_after_write_b)
	b_read_5 rd;
	b_write_5 wr;
	function new(string name = "read_after_write_b");
		super.new(name);
		rd = b_read_5::type_id::create("rd");
		wr = b_write_5::type_id::create("wr");

	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		`uvm_do(wr);
		`uvm_do(rd);
	endtask
endclass

class i_write_5_s extends uvm_sequence#(tx_item);
	`uvm_object_utils(i_write_5_s)

	function new(string name = "i_write_5_s");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(5)
			`uvm_do_with(tr, {AWADDR < 5; AWBURST == 0; AWLEN == 0; AWSIZE == 1; transfer == WRITE;});
	endtask
endclass

class i_read_5_s extends uvm_sequence#(tx_item);
	`uvm_object_utils(i_read_5_s)

	function new(string name = "i_read_5_s");
		super.new(name);
	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		repeat(5)
			`uvm_do_with(tr, {AWADDR < 5; AWBURST == 0; AWLEN == 0; AWSIZE == 2; transfer == WRITE;});
		repeat(5)
			`uvm_do_with(tr, {ARADDR < 5; ARBURST == 0; ARLEN == 0; ARSIZE == 2; transfer == READ;});
	endtask
endclass

class parallel extends uvm_sequence#(tx_item);
	`uvm_object_utils(parallel)
	b_read_5 rd;
	b_write_5 wr;
	function new(string name = "parallel");
		super.new(name);
		rd = b_read_5::type_id::create("rd");
		wr = b_write_5::type_id::create("wr");

	endfunction

	virtual task body();
		tx_item tr;
		tr = tx_item::type_id::create("tr");
		`uvm_do(wr);
		fork
		`uvm_do(rd);
		`uvm_do(wr);
		`uvm_do(rd);
		join
	endtask
endclass
