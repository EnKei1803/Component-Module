# Component-Module

A comprehensive library of essential RTL (Register Transfer Level) design components for digital circuit design. This repository provides well-documented, tested, and reusable Verilog modules for common digital logic functions.

## 📋 Overview

This project contains fundamental building blocks for digital hardware design, including arithmetic units, logic gates, and other essential components used in FPGA and ASIC development.

## 🗂️ Repository Structure

```
Component-Module/
├── src/              # Source modules (.v, .sv files)
│   └── full_adder.v  # 1-bit full adder implementation
├── tb/               # Testbenches for verification
│   └── full_adder_tb.v
├── docs/             # Module specifications and documentation
│   └── full_adder_spec.md
├── examples/         # Usage examples and demo projects
├── scripts/          # Simulation and build scripts
│   └── simulate.sh   # Automated simulation script
├── .gitignore        # Git ignore rules for Verilog projects
├── LICENSE           # MIT License
├── CONTRIBUTING.md   # Contribution guidelines
└── README.md         # This file
```

## 🚀 Getting Started

### Prerequisites

To use and simulate these modules, you'll need:
- **Icarus Verilog** (iverilog) - For compilation and simulation
- **GTKWave** - For viewing waveforms (optional)
- Any HDL synthesis tool (Vivado, Quartus, etc.) for FPGA implementation

### Installation

```bash
# Clone the repository
git clone https://github.com/EnKei1803/Component-Module.git
cd Component-Module

# Install Icarus Verilog (Ubuntu/Debian)
sudo apt-get install iverilog gtkwave

# Install Icarus Verilog (macOS)
brew install icarus-verilog gtkwave
```

### Running Simulations

Use the provided simulation script:

```bash
# Make the script executable (first time only)
chmod +x scripts/simulate.sh

# Run simulation for a module
./scripts/simulate.sh full_adder
```

Or compile and run manually:

```bash
# Compile
iverilog -o build/full_adder_sim src/full_adder.v tb/full_adder_tb.v

# Run simulation
vvp build/full_adder_sim

# View waveform (if generated)
gtkwave build/full_adder_tb.vcd
```

## 📚 Available Modules

### Arithmetic Components
- **full_adder** - 1-bit full adder with carry in/out
- *More modules coming soon...*

## 📖 Documentation

Each module has detailed documentation in the `docs/` directory, including:
- Module specifications
- Interface descriptions
- Truth tables and timing diagrams
- Usage examples
- Performance characteristics

## 🧪 Testing

All modules include comprehensive testbenches in the `tb/` directory. Testbenches are self-checking and report pass/fail status.

Example output:
```
Starting Full Adder Testbench
================================
PASS: a=0 b=0 cin=0 => sum=0 cout=0
PASS: a=0 b=0 cin=1 => sum=1 cout=0
...
================================
Test Summary:
PASSED: 8
FAILED: 0
All tests PASSED!
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Coding standards and style guide
- How to submit pull requests
- Testing requirements
- Documentation guidelines

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Verilog HDL Quick Reference](http://www.iitg.ac.in/hemangee/cs224_2014/verilog_reference.pdf)
- [Icarus Verilog Documentation](http://iverilog.icarus.com/)
- [GTKWave User Guide](http://gtkwave.sourceforge.net/)

## 📧 Contact

**Author**: EnKei1803  
**Repository**: [Component-Module](https://github.com/EnKei1803/Component-Module)

---

⭐ If you find this project useful, please consider giving it a star!
