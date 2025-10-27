# Source Modules

This directory contains all RTL design source files (Verilog/SystemVerilog modules).

## Organization

- Each module should be in its own file
- File name should match the module name
- Use `.v` extension for Verilog files
- Use `.sv` extension for SystemVerilog files

## Current Modules

### full_adder.v
1-bit full adder implementation - fundamental building block for arithmetic circuits.

## Adding New Modules

When adding a new module:
1. Create the module file in this directory
2. Add corresponding testbench in `tb/`
3. Add documentation in `docs/`
4. Update main README.md with the new module

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.
