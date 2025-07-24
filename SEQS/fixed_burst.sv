class fixed_burst extends uvm_sequence#(tx_item);
	`uvm_object_utils(fixed_burst)
	read_seq rd;
	write_seq wr;
	int rpt = 1;
	function new(string name = "fixed_burst");
		super.new(name);
	endfunction

	virtual task body();
		for (int i = 0; i < 8; i++) begin
			rd = read_seq::type_id::create($sformatf("rd_%0d",i));
			wr = write_seq::type_id::create($sformatf("wr_%0d",i));
			`uvm_do_with(wr, {addr < 5; rp == rpt; burst == 2'b00; len > 5; size == i;});
			`uvm_do_with(rd, {addr < 5; rp == rpt; burst == 2'b00; len > 5; size == i;});
		end
	endtask
endclass
