//------------------------------------------------------------------------------
// AXI4 UVM Sequence Classes Documentation
//------------------------------------------------------------------------------
//
// This file defines several UVM sequence classes for AXI4 protocol verification.
// Each sequence generates AXI transactions with various burst types and parameters.
//
// Classes:
//   - write_seq: Generates write transactions with randomized parameters.
//   - read_seq: Generates read transactions with randomized parameters.
//   - fixed_burst: Generates sequences with FIXED burst type for both read and write.
//   - incr_burst: Generates sequences with INCR burst type for both read and write.
//   - warp_burst: Generates sequences with specific parameters for burst type.
//
//------------------------------------------------------------------------------
// Class: write_seq
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Generates write transactions with randomized address, burst, length, and size.
//   - Constraints: Disallows burst type 2'b11.
//   - Usage: Used to create write transaction items with specified or random parameters.
//
//------------------------------------------------------------------------------
// Class: read_seq
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Generates read transactions with randomized address, burst, length, and size.
//   - Usage: Used to create read transaction items with specified or random parameters.
//
//------------------------------------------------------------------------------
// Class: fixed_burst
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Generates a sequence of read and write transactions with FIXED burst type (2'b00).
//   - Parameters: addr < 5, rp == rpt, burst == 2'b00, len < 5, size varies from 0 to 7.
//
//------------------------------------------------------------------------------
// Class: incr_burst
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Generates a sequence of read and write transactions with INCR burst type (2'b01).
//   - Parameters: addr < 5, rp == rpt, burst == 2'b01, len < 5, size varies from 0 to 7.
//
//------------------------------------------------------------------------------
// Class: warp_burst
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Generates a sequence of read and write transactions with fixed parameters.
//   - Parameters: addr == 0, rp == rpt, burst == 2'b00, len == 4, size == 3.
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Class: full_random_parallel
//   - Extends: uvm_sequence#(tx_item)
//   - Purpose: Fully randomise and complete testing
//
//------------------------------------------------------------------------------
package seq_pkg;
	import uvm_pkg::*;
    `include "uvm_macros.svh"
	`include "tx_item.sv"
    `include "write_seq.sv"
    `include "read_seq.sv"
    `include "fixed_burst.sv"
    `include "incr_burst.sv"
    `include "warp_burst.sv"
    `include "full_random_parallel.sv"
endpackage
