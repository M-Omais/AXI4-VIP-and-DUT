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
