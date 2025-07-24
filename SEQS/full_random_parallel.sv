class full_random_parallel extends uvm_sequence#(tx_item);
	`uvm_object_utils(full_random_parallel)

	read_seq rd;
	write_seq wr;
	int rpt = 1;

	function new(string name = "full_random_parallel");
		super.new(name);
	endfunction

	virtual task body();
		wr = write_seq::type_id::create("wr");
		`uvm_do_with(wr, {addr == 0; rp == rpt; burst == 2'b01; len == 10; size == 4;}); // Initial fixed write

		// fork
			begin
				for (int i = 0; i < 8; i++) begin
					for (int j = 0; j < 256; j++) begin
						wr = write_seq::type_id::create($sformatf("wr_%0d_%0d", i, j));
						`uvm_do_with(wr, {addr < ((i+1)*5); rp == rpt; size == i; len == j;});
					end
				end
			end

			begin
				for (int i = 0; i < 8; i++) begin
					for (int j = 0; j < 256; j++) begin
						rd = read_seq::type_id::create($sformatf("rd_%0d_%0d", i, j));
						`uvm_do_with(rd, {addr < ((i+1)*5); rp == rpt; size == i;  len == j;});
					end
				end
			end
		// join
	endtask
endclass