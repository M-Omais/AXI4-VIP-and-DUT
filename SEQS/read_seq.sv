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
