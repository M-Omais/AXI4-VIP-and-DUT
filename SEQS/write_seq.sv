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
