typedef enum { READ, WRITE } transfer_type;
class tx_item extends uvm_sequence_item;

	`uvm_object_utils(tx_item)

	rand transfer_type transfer;
	// Read Address Channel
	rand logic [3:0] ARID;
	rand logic [4:0] ARADDR;
	rand logic [1:0] ARBURST;
	rand bit		ARVALID;
		bit 		ARREADY;	//----------------OUTPUT-----------------------//
	rand logic [7:0] ARLEN;
	rand logic [2:0] ARSIZE;

	// Read Data Channel
	logic [3:0] RID;
	logic [31:0] RDATA [];
	bit 		RLAST;
	bit 		RVALID;
	rand bit 	RREADY;	//---------------INPUT--------------------------//
	logic [1:0] RRESP;

	// Write Address Channel
	// rand logic [3:0] AWID;
	rand logic [4:0] AWADDR;
	rand logic [1:0] AWBURST;
		 bit		AWVALID;
		 bit		AWREADY; //----------------OUTPUT-----------------------//
	rand logic [7:0] AWLEN;
	rand logic [2:0] AWSIZE;
	
	// Write Data Channel
	rand logic [3:0] WID;
	rand logic [31:0] WDATA [];
		 bit 		WLAST;
		 bit 		WVALID;
		 bit 		WREADY;	 //----------------OUTPUT-----------------------//
							
	// Write Response Channel
		logic [3:0] 	BID;
		logic [1:0] 	BRESP;
		bit				BVALID;
		bit				BREADY; //INPUT	

	constraint transfer_type_dist_c {
    	transfer dist { WRITE := 5, READ := 1 };
	}

	constraint write_data_size_c {
    	WDATA.size() == (AWLEN + 1);
  	}


	function new(string name = "tx_item");
		super.new(name);
	endfunction
endclass
