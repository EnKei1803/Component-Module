# Scripts

This directory contains utility scripts for building, simulating, and testing modules.

## Available Scripts

### simulate.sh
Automated simulation script using Icarus Verilog.

**Usage:**
```bash
./simulate.sh <module_name>
```

**Example:**
```bash
./simulate.sh full_adder
```

**Features:**
- Automatically compiles source and testbench
- Runs simulation
- Reports results
- Generates VCD waveform files (if configured in testbench)

## Adding New Scripts

Additional scripts may include:
- Synthesis scripts for various FPGA tools
- Batch testing scripts
- Code coverage analysis
- Linting and style checking
- Automated documentation generation

## Requirements

- **Icarus Verilog** (iverilog) - For simulation
- **GTKWave** (optional) - For waveform viewing
- **Bash** - For running shell scripts
