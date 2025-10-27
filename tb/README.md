# Testbenches

This directory contains all testbench files for verifying module functionality.

## Naming Convention

Testbench files should be named: `<module_name>_tb.v`

Example: `full_adder_tb.v` for testing `full_adder.v`

## Testbench Guidelines

1. **Self-Checking**: Include automatic verification when possible
2. **Comprehensive**: Test all input combinations and edge cases
3. **Reporting**: Display clear pass/fail results
4. **Waveforms**: Optionally generate VCD files for debugging
5. **Documentation**: Comment test scenarios and expected behavior

## Running Tests

Use the simulation script:
```bash
../scripts/simulate.sh <module_name>
```

Or manually with Icarus Verilog:
```bash
iverilog -o build/sim src/<module>.v tb/<module>_tb.v
vvp build/sim
```

## Current Testbenches

- **full_adder_tb.v** - Tests all 8 input combinations of the full adder
