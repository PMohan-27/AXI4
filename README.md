# AXI4 Implementation

I'm writing an AXI4 bus implementation for a RISCV SoC. I'd like to implement a UVM inspired testbench.

## Project Goals

1. Implement AXI4 Lite protocol
2. Upgrade to AXI4
3. Integrate with [RISCV core](https://github.com/PMohan-27/single-cycle-risc-v-core)

## Project Structure

```txt
rtl/ - Verilog files
test/ - Testbenches
docs/ - Documentation and diagrams
```

## Running Tests

See [test.md](test/test.md) for testing instructions.
