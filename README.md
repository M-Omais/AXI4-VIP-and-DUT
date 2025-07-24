# AXI4-VIP-and-DUT

This repository provides a complete **UVM-based Verification IP (VIP)** for the AXI4 protocol, along with a sample **Design Under Test (DUT)** — the AXI4 BRAM Controller. It is designed to simulate, verify, and validate AXI4 protocol compliance using SystemVerilog and UVM methodology.

---

## 📁 Directory Structure

| File/Folder            | Description |
|------------------------|-------------|
| `AXI4.sv`,`Top.sv` | Main AXI4 interface, BRAM controller, and top-level testbench module. |
| `axi_if.sv`            | AXI4 interface definition. |
| `tx_item.sv`, `tx_pkg.sv` | Transaction item and package used for defining AXI4 transactions. |
| `axi_agent.sv`, `axi_driver.sv`, `axi_monitor.sv`, `axi_sequencer.sv`, `axi_env.sv`, `axi_sb.sv` | UVM agent components: driver, monitor, sequencer, scoreboard, and environment. |
| `SEQS/`                | UVM sequences used for various AXI burst types. |
| `TESTS/`               | UVM test classes and test package. |
| `run.do`, `run.f`      | ModelSim/Questa simulation scripts. |
---

## 🚀 How to Run

### 1. Prerequisites
- SystemVerilog simulator (e.g., **ModelSim**, **Questa**, **VCS**)
- UVM library installed and included in your simulator's path

### 2. Compilation

Run the provided script:
```sh
vsim -do run.do

