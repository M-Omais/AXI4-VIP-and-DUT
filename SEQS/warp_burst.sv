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
